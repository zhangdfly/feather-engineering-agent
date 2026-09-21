# 扩展规则

扩展通过额外 manifest 追加模块。核心仓库不需要 fork，生成器也不需要修改。

## 扩展清单

```json
{
  "modules": [
    {
      "path": "project-rules.md",
      "skill": "reference",
      "reference": "project-rules.md",
      "summary": "处理本项目特有的代码或文档约束时读取。"
    }
  ]
}
```

`path` 相对于扩展 manifest 所在目录。

`skill` 可取：

| 值 | 行为 |
|---|---|
| `inline` | 写入 Skill 入口，每次 Skill 激活都加载 |
| `reference` | 生成到 Skill 的 `references/`，由路由按需加载 |
| `none` | 只写入 always-on 宿主指令，不进入 Skill |

大多数项目规则应使用 `reference`。只有所有任务都必须遵守的短规则才使用 `inline`。

## 生成

```powershell
pwsh -File C:\path\feather-engineering-agent\scripts\generate.ps1 `
  -ExtensionManifest .\feather-extension.json `
  -OutputRoot .
```

多个扩展按参数顺序追加：

```powershell
pwsh -File C:\path\feather-engineering-agent\scripts\generate.ps1 `
  -ExtensionManifest .\team\feather-extension.json, .\project\feather-extension.json `
  -OutputRoot .
```

## 约束

- 扩展可以增加或收窄项目规则，不能取消安全、正确性和用户明确要求等核心边界。
- 新规则应放在拥有该职责的一个模块中，避免按宿主复制。
- `reference` 文件名必须唯一，且只能是文件名，不能包含目录跳转。
- 扩展顺序有意义：团队规则在前，具体项目规则在后。

可运行示例位于 `examples/project-extension/`。
