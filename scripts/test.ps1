Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-Tests {
    # 1. 检查所有生成产物是否与唯一规则源一致
    & (Join-Path $PSScriptRoot 'generate.ps1') -Check

    # 2. 检查三个插件 manifest 的版本、Skill 路径和无 Hook 约束
    $rulesManifest = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'rules\manifest.json') | ConvertFrom-Json
    $pluginManifestPaths = @(
        '.github\plugin\plugin.json',
        '.claude-plugin\plugin.json',
        '.codex-plugin\plugin.json'
    )

    foreach ($relativePath in $pluginManifestPaths) {
        $path = Join-Path $repoRoot $relativePath
        $plugin = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
        Assert-True ($plugin.version -eq $rulesManifest.version) "$relativePath has a different version"
    }

    $allPluginJsonPaths = @(
        '.github\plugin\plugin.json',
        '.github\plugin\marketplace.json',
        '.claude-plugin\plugin.json',
        '.claude-plugin\marketplace.json',
        '.codex-plugin\plugin.json'
    )

    foreach ($relativePath in $allPluginJsonPaths) {
        $raw = Get-Content -Raw -LiteralPath (Join-Path $repoRoot $relativePath)
        Assert-True (-not ($raw -match '"hooks"\s*:')) "$relativePath must not declare hooks in v1"
    }

    Assert-True (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'hooks'))) 'v1 must not contain a hooks directory'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'CLAUDE.md'))) 'root CLAUDE.md would duplicate AGENTS.md in multi-instruction hosts'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $repoRoot '.github\copilot-instructions.md'))) 'root Copilot instructions would duplicate AGENTS.md'

    # 3. 检查核心规则没有丢失用户要求的不变量
    $core = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'rules\00-core.md')
    $docs = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'rules\10-technical-docs.md')
    $code = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'rules\20-code-structure.md')

    Assert-True ($core.Contains('可读性是目标')) 'readability-first invariant is missing'
    Assert-True ($core.Contains('每个句子、函数、类型和抽象层')) 'core unit-value invariant is missing'
    Assert-True ($docs.Contains('满足以下任一条件')) 'documentation OR-admission rule is missing'
    Assert-True ($code.Contains('一个流程只有一个公开入口')) 'canonical workflow entry invariant is missing'
    Assert-True ($code.Contains('perfTracker.startWindow()')) 'ownership-aware naming example is missing'
    Assert-True ($code.Contains('ExecutorWithLogger')) 'unnecessary wrapper example is missing'

    # 4. 用示例扩展清单生成一个下游规则集
    $tempRoot = Join-Path $repoRoot ('.tmp-tests\extension-' + [guid]::NewGuid().ToString('N'))
    try {
        $extensionManifest = Join-Path $repoRoot 'examples\project-extension\feather-extension.json'
        & (Join-Path $PSScriptRoot 'generate.ps1') -ExtensionManifest $extensionManifest -OutputRoot $tempRoot

        $generatedAgents = Get-Content -Raw -LiteralPath (Join-Path $tempRoot 'AGENTS.md')
        $generatedSkill = Get-Content -Raw -LiteralPath (Join-Path $tempRoot 'skills\feather-engineering-agent\SKILL.md')
        $generatedReference = Join-Path $tempRoot 'skills\feather-engineering-agent\references\project-rules.md'
        $generatedClaudeAdapter = Join-Path $tempRoot 'adapters\claude-code\CLAUDE.md'
        $generatedCopilotAdapter = Join-Path $tempRoot 'adapters\github-copilot\.github\copilot-instructions.md'
        $generatedCodexAdapter = Join-Path $tempRoot 'adapters\codex\AGENTS.md'

        Assert-True ($generatedAgents.Contains('项目扩展示例')) 'extension rules were not added to bundled instructions'
        Assert-True ($generatedSkill.Contains('references/project-rules.md')) 'extension reference was not routed from SKILL.md'
        Assert-True (Test-Path -LiteralPath $generatedReference -PathType Leaf) 'extension skill reference was not generated'
        Assert-True (Test-Path -LiteralPath $generatedClaudeAdapter -PathType Leaf) 'Claude adapter was not generated'
        Assert-True (Test-Path -LiteralPath $generatedCopilotAdapter -PathType Leaf) 'Copilot adapter was not generated'
        Assert-True (Test-Path -LiteralPath $generatedCodexAdapter -PathType Leaf) 'Codex adapter was not generated'
    } finally {
        if (Test-Path -LiteralPath $tempRoot) {
            [IO.Directory]::Delete($tempRoot, $true)
        }
    }

    # 5. 检查最小评测集存在
    $caseCount = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'evals\cases') -Filter '*.md' -File).Count
    Assert-True ($caseCount -ge 4) 'at least four eval cases are required'

    Write-Host 'All checks passed.'
}

Invoke-Tests
