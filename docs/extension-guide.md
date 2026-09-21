# 扩展规则

不要修改已安装的 Feather Skill 来保存项目特有规则。

## 项目规则

把只适用于单个项目的约束写入该项目的 `AGENTS.md`：

```markdown
# Project instructions

Use the installed Feather Engineering Agent skill.

## Project-specific rules

- 数据库迁移必须与应用代码放在同一个变更中。
- 修改公开 API 时，只记录真实行为变化。
```

## 可复用扩展

需要跨项目复用时，创建独立 Agent Skill：

```text
skills/team-engineering/
├── SKILL.md
└── references/
    ├── docs.md
    └── code.md
```

该 Skill 应只保存团队或领域特有规则，并在 `description` 中说明它与 Feather 同时使用。不要复制 Feather 的通用规则。

扩展可以收窄项目行为，但不能取消安全、正确性和用户明确要求等核心边界。
