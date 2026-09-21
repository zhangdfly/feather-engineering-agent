# 贡献指南

规则库本身也必须可读：新规则需要解决已观察到的问题，不能只让规范看起来更完整。

## 修改流程

1. 在 `evals/cases/` 添加能稳定复现问题的输入和期望行为。
2. 修改 `rules/` 中拥有该职责的现有模块；只有职责确实独立时才新增模块。
3. 如新增模块，在 `rules/manifest.json` 中声明顺序和 Skill 加载方式。
4. 运行生成和检查：

```powershell
pwsh -File .\scripts\generate.ps1
pwsh -File .\scripts\test.ps1
```

## 新规则准入

新规则必须同时满足：

- 指向具体、可复现的失败模式；
- 不与现有规则重复；
- 能说明不采用该规则会造成什么理解或工程成本；
- 不以牺牲正确性、安全或用户明确要求为代价；
- 至少提供一个反例和一个合格结果。

仅表达个人审美、无法观察效果或只改换说法的规则不应加入。

## 生成文件

不要直接编辑以下文件：

- `AGENTS.md`
- `adapters/**/*.md`
- `skills/feather-engineering-agent/SKILL.md`
- `skills/feather-engineering-agent/references/*.md`

它们由 `scripts/generate.ps1` 从 `rules/` 生成。
