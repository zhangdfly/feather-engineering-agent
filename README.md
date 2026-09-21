<p align="center">
  <img src="assets/feather.svg" width="120" alt="羽">
</p>

# Feather Engineering Agent

> Readable code. Direct docs. Honest structure.

一套面向 AI 编码 Agent 的可读性规则：让业务流程、状态所有权和技术结论直接出现在读者需要的位置。

## 解决的问题

- 技术文档堆砌正确但无关的背景、排除项、免责声明和总结；
- 线性 workflow 被拆进 `run -> bootstrap -> host -> execute` 等近义调用链；
- 方法名没有表达真实动作或状态所有者；
- 日志、指标等能力引入不必要的 wrapper、继承和转发类型。

## 核心约束

可读性是首要目标。减少内容和抽象只是手段，不能以隐藏流程、增加跳转或压缩语义为代价。

每个句子、函数、类型和抽象层都必须增加信息、能力、不变量、业务顺序或边界，否则删除、内联或合并。

## 仓库结构

```text
rules/                              唯一规则源
skills/feather-engineering-agent/
                                    可独立安装的 Agent Skill（生成）
AGENTS.md                           仓库自身与通用 Agent 指令（生成）
adapters/                           各宿主可复制的指令文件（生成）
.github/plugin/                     GitHub Copilot CLI 插件清单
.claude-plugin/                     Claude Code 插件清单
.codex-plugin/                      Codex 插件清单
scripts/                            无第三方依赖的生成与检查脚本
evals/                              行为评测用例
docs/                               架构、接入、扩展和 Hook 决策
```

`rules/manifest.json` 决定规则模块顺序。生成文件带有“请勿直接编辑”标记；修改规则后重新生成。

## 本地生成与验证

仓库工具只依赖 PowerShell 7：

```powershell
pwsh -File .\scripts\generate.ps1
pwsh -File .\scripts\generate.ps1 -Check
pwsh -File .\scripts\test.ps1
```

## 使用方式

### 直接放入项目

选择目标 Agent 对应的生成文件：

- 通用 Agent：`AGENTS.md`
- Codex：`adapters/codex/AGENTS.md`
- Claude Code：`adapters/claude-code/CLAUDE.md`
- GitHub Copilot：`adapters/github-copilot/.github/copilot-instructions.md`

宿主适配文件不放在仓库根目录，避免支持多个指令格式的 Agent 同时加载重复规则。

### 安装为 Agent Skill

发布到 GitHub 后，可通过兼容 Agent Skills 的工具安装：

```powershell
npx skills add <owner>/feather-engineering-agent
```

### 安装为宿主插件

仓库包含 GitHub Copilot CLI、Claude Code 和 Codex 的插件清单。发布后的命令见 [宿主接入](docs/hosts.md)。

## 扩展

项目规则通过额外 manifest 追加，不修改核心规则：

```powershell
pwsh -File C:\path\feather-engineering-agent\scripts\generate.ps1 `
  -ExtensionManifest .\feather-extension.json `
  -OutputRoot .
```

完整格式和边界见 [扩展规则](docs/extension-guide.md)。

## 为什么 v1 没有 Hook

本项目没有会话档位、开关状态或工具拦截需求。Skill 与生成的宿主指令已经能提供确定性规则；Hook 会额外引入宿主方言、运行时依赖和上下文重复注入。

只有实际评测证明 Skill 经常不触发、子 Agent 丢失规则，或未来需要会话状态时，才考虑 SessionStart Hook。详见 [Hook 契约](docs/hook-contract.md)。

## 许可证

[MIT](LICENSE)。概念来源说明见 [第三方说明](THIRD_PARTY_NOTICES.md)。
