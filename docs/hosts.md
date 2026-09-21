# 宿主接入

## GitHub Copilot CLI

发布 GitHub 仓库后：

```text
copilot plugin marketplace add <owner>/feather-engineering-agent
copilot plugin install feather-engineering-agent@feather-engineering-agent
```

## Claude Code

发布 GitHub 仓库后：

```text
/plugin marketplace add <owner>/feather-engineering-agent
/plugin install feather-engineering-agent@feather-engineering-agent
```

## Codex

发布 GitHub 仓库后：

```powershell
codex plugin marketplace add <owner>/feather-engineering-agent
codex plugin add feather-engineering-agent@feather-engineering-agent
```

## 通用 Agent Skills

兼容 Agent Skills 的宿主可安装 `skills/feather-engineering-agent/`：

```powershell
npx skills add <owner>/feather-engineering-agent
```

如果宿主不支持 Agent Skills，可以在项目 `AGENTS.md` 中直接引用本仓库的规则，或复制当前版本的 Skill 目录。不要同时维护多份规则副本。

## 未发布远程仓库时

本地评审阶段不需要安装插件。可让 Agent 直接读取 `skills/feather-engineering-agent/SKILL.md`。
