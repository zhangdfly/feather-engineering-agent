# 宿主接入

## GitHub Copilot CLI

发布 GitHub 仓库后：

```text
copilot plugin marketplace add <owner>/feather-engineering-agent
copilot plugin install feather-engineering-agent@feather-engineering-agent
```

项目级 always-on：把
`adapters/github-copilot/.github/copilot-instructions.md`
复制到目标项目的 `.github/copilot-instructions.md`。若项目已经使用
`AGENTS.md`，不要再复制，避免重复加载。

## Claude Code

发布 GitHub 仓库后：

```text
/plugin marketplace add <owner>/feather-engineering-agent
/plugin install feather-engineering-agent@feather-engineering-agent
```

项目级使用：把 `adapters/claude-code/CLAUDE.md` 复制到目标项目根目录。

## Codex

发布 GitHub 仓库后：

```powershell
codex plugin marketplace add <owner>/feather-engineering-agent
codex plugin add feather-engineering-agent@feather-engineering-agent
```

项目级使用：把 `adapters/codex/AGENTS.md` 复制到目标项目根目录。

## 通用 Agent Skills

兼容 Agent Skills 的宿主可安装 `skills/feather-engineering-agent/`：

```powershell
npx skills add <owner>/feather-engineering-agent
```

如果宿主不支持 Skill，使用根目录生成的 `AGENTS.md`。

## 未发布远程仓库时

本地评审阶段不需要安装插件。直接在目标项目中复制相应 adapter；如需加入项目规则，使用扩展清单重新生成，而不是手工修改生成文件。
