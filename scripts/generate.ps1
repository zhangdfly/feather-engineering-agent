param(
    [switch]$Check,
    [string[]]$ExtensionManifest = @(),
    [string]$OutputRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = $repoRoot
} else {
    if (-not [IO.Path]::IsPathRooted($OutputRoot)) {
        $OutputRoot = Join-Path (Get-Location).Path $OutputRoot
    }
    $OutputRoot = [IO.Path]::GetFullPath($OutputRoot)
}

function Invoke-Generation {
    # 1. 读取核心清单和扩展清单
    $manifestPath = Join-Path $repoRoot 'rules\manifest.json'
    $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
    $moduleSpecs = [Collections.Generic.List[object]]::new()

    foreach ($module in @($manifest.modules)) {
        $skillMode = if ($module.PSObject.Properties.Name -contains 'skill') { [string]$module.skill } else { 'none' }
        $reference = if ($module.PSObject.Properties.Name -contains 'reference') { [string]$module.reference } else { '' }
        $summary = if ($module.PSObject.Properties.Name -contains 'summary') { [string]$module.summary } else { '' }

        $moduleSpecs.Add([pscustomobject]@{
            BaseDirectory = $repoRoot
            Path = [string]$module.path
            Skill = $skillMode
            Reference = $reference
            Summary = $summary
        })
    }

    foreach ($extensionManifestPath in $ExtensionManifest) {
        if (-not [IO.Path]::IsPathRooted($extensionManifestPath)) {
            $extensionManifestPath = Join-Path (Get-Location).Path $extensionManifestPath
        }
        $extensionManifestPath = [IO.Path]::GetFullPath($extensionManifestPath)
        if (-not (Test-Path -LiteralPath $extensionManifestPath -PathType Leaf)) {
            throw "Extension manifest not found: $extensionManifestPath"
        }

        $extension = Get-Content -Raw -LiteralPath $extensionManifestPath | ConvertFrom-Json
        $extensionRoot = Split-Path -Parent $extensionManifestPath
        foreach ($module in @($extension.modules)) {
            $skillMode = if ($module.PSObject.Properties.Name -contains 'skill') { [string]$module.skill } else { 'none' }
            $reference = if ($module.PSObject.Properties.Name -contains 'reference') { [string]$module.reference } else { '' }
            $summary = if ($module.PSObject.Properties.Name -contains 'summary') { [string]$module.summary } else { '' }

            $moduleSpecs.Add([pscustomobject]@{
                BaseDirectory = $extensionRoot
                Path = [string]$module.path
                Skill = $skillMode
                Reference = $reference
                Summary = $summary
            })
        }
    }

    # 2. 校验并读取规则模块
    $validSkillModes = @('inline', 'reference', 'none')
    $seenSources = @{}
    $seenReferences = @{}
    $modules = [Collections.Generic.List[object]]::new()

    foreach ($spec in $moduleSpecs) {
        if ($validSkillModes -notcontains $spec.Skill) {
            throw "Unsupported skill mode '$($spec.Skill)' for $($spec.Path)"
        }

        $relativePath = $spec.Path.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $sourcePath = [IO.Path]::GetFullPath((Join-Path $spec.BaseDirectory $relativePath))
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "Rule module not found: $sourcePath"
        }
        if ($seenSources.ContainsKey($sourcePath)) {
            throw "Rule module listed more than once: $sourcePath"
        }
        $seenSources[$sourcePath] = $true

        if ($spec.Skill -eq 'reference') {
            if ([string]::IsNullOrWhiteSpace($spec.Reference) -or $spec.Reference -match '[\\/]') {
                throw "Reference modules need a filename-only reference target: $sourcePath"
            }
            if ([string]::IsNullOrWhiteSpace($spec.Summary)) {
                throw "Reference modules need a routing summary: $sourcePath"
            }
            if ($seenReferences.ContainsKey($spec.Reference)) {
                throw "Skill reference target listed more than once: $($spec.Reference)"
            }
            $seenReferences[$spec.Reference] = $true
        }

        $content = [IO.File]::ReadAllText($sourcePath).Replace("`r`n", "`n").Replace("`r", "`n").Trim()
        $modules.Add([pscustomobject]@{
            SourcePath = $sourcePath
            Skill = $spec.Skill
            Reference = $spec.Reference
            Summary = $spec.Summary
            Content = $content
        })
    }

    # 3. 组合完整规则、Skill 内联规则和按需引用
    $bundleBody = (@($modules | ForEach-Object { $_.Content }) -join "`n`n").Trim()
    $inlineBody = (@($modules | Where-Object Skill -eq 'inline' | ForEach-Object { $_.Content }) -join "`n`n").Trim()
    $referenceModules = @($modules | Where-Object Skill -eq 'reference')

    # 4. 渲染宿主指令、Skill 入口和 Skill references
    $notice = '<!-- 此文件由 scripts/generate.ps1 从 rules/ 生成，请勿直接编辑。 -->'
    $outputs = [ordered]@{}

    foreach ($target in @($manifest.bundleTargets)) {
        $outputs[[string]$target] = @"
$notice

# Feather Engineering Agent

$bundleBody
"@
    }

    $routes = @($referenceModules | ForEach-Object {
        "- [references/$($_.Reference)](references/$($_.Reference))：$($_.Summary)"
    }) -join "`n"

    $skillTarget = [string]$manifest.skill.target
    $outputs[$skillTarget] = @"
---
name: $($manifest.skill.name)
description: >
  $($manifest.skill.description)
license: MIT
metadata:
  version: "$($manifest.version)"
---

$notice

# Feather Engineering Agent

$inlineBody

## 按需读取

$routes

任务同时涉及文档与代码时，读取两份对应规则。只有需要判断边界或评审结果时才读取 examples。
"@

    $skillDirectory = Split-Path -Parent $skillTarget
    foreach ($referenceModule in $referenceModules) {
        $referenceTarget = Join-Path $skillDirectory (Join-Path 'references' $referenceModule.Reference)
        $outputs[$referenceTarget] = @"
$notice

$($referenceModule.Content)
"@
    }

    # 5. 写入产物，或检查产物是否与规则源一致
    $drift = [Collections.Generic.List[string]]::new()
    foreach ($entry in $outputs.GetEnumerator()) {
        $relativeTarget = $entry.Key.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $targetPath = [IO.Path]::GetFullPath((Join-Path $OutputRoot $relativeTarget))
        $expected = $entry.Value.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd() + "`n"

        if ($Check) {
            if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
                $drift.Add("$($entry.Key) is missing")
                continue
            }

            $actual = [IO.File]::ReadAllText($targetPath).Replace("`r`n", "`n").Replace("`r", "`n")
            if ($actual -ne $expected) {
                $drift.Add("$($entry.Key) is out of date")
            }
            continue
        }

        $targetDirectory = Split-Path -Parent $targetPath
        [IO.Directory]::CreateDirectory($targetDirectory) | Out-Null
        [IO.File]::WriteAllText($targetPath, $expected, [Text.UTF8Encoding]::new($false))
        Write-Host "Generated $($entry.Key)"
    }

    if ($Check -and $drift.Count -gt 0) {
        throw "Generated files differ from the canonical rules:`n- $($drift -join "`n- ")"
    }

    if ($Check) {
        Write-Host 'Generated files are up to date.'
    }
}

Invoke-Generation
