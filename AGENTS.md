# Feather Engineering Agent

本仓库的唯一行为规则位于
[skills/feather-engineering-agent/SKILL.md](skills/feather-engineering-agent/SKILL.md)。

处理任务前先读取该 Skill，再按任务类型读取：

- 技术文档：[references/docs/rules.md](skills/feather-engineering-agent/references/docs/rules.md)
- 代码结构：[references/code/rules.md](skills/feather-engineering-agent/references/code/rules.md)
- 正反例：仅在需要判断边界或执行评审时读取对应领域的 `examples.md`

不要复制规则到其他入口文件。项目特有规则直接追加在本文件中。
