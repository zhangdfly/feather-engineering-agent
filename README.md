<p align="center">
  <img src="assets/feather.svg" width="120" alt="羽">
</p>

# Feather Engineering Agent

> Readable code. Direct docs. Honest structure.

一套面向 AI 编码 Agent 的可读性规则：让业务流程、状态所有权和技术结论直接出现在读者需要的位置。

它有两种工作模式：编写代码或文档，以及评审 PR 并根据用户反馈持续修正规则。

## 解决的问题

- 技术文档堆砌正确但无关的背景、排除项、免责声明和总结；
- 线性 workflow 被拆进 `run -> bootstrap -> host -> execute` 等近义调用链；
- 方法名没有表达真实动作或状态所有者；
- 日志、指标等能力引入不必要的 wrapper、继承和转发类型。

## 核心约束

可读性是首要目标。减少内容和抽象只是手段，不能以隐藏流程、增加跳转或压缩语义为代价。

每个句子、函数、类型和抽象层都必须增加信息、能力、不变量、业务顺序或边界，否则删除、内联或合并。

## 工作模式

### 编写模式

Agent 加载对应的代码或文档规则，直接用于实现、修改和重构。

### PR Review 模式

把 PR 链接交给 Agent 后，它读取 diff、已有评论和对应规则，按要求草拟或发布具体的 Review comments。

评审结束后，明确要求 Agent 总结本次反馈。Agent 会把可泛化的反馈更新到已有规则，并在 `evals/` 中加入能复现该问题的回归案例。规则修改和案例必须在同一个变更中。

## 仓库结构

```text
skills/feather-engineering-agent/
├── SKILL.md                        唯一入口与核心规则
└── references/
    ├── docs/
    │   ├── rules.md
    │   └── examples.md
    ├── code/
    │   ├── rules.md
    │   └── examples.md
    └── review.md                   PR Review 与反馈学习流程
AGENTS.md                           本仓库的 Skill 路由与项目规则
.github/plugin/                     GitHub Copilot CLI 插件清单
.claude-plugin/                     Claude Code 插件清单
.codex-plugin/                      Codex 插件清单
evals/docs/                         技术文档回归案例
evals/code/                         代码结构回归案例
docs/                               架构、接入、扩展和 Hook 决策
```

行为规则只存在于 `skills/feather-engineering-agent/`。插件 manifest 只声明元数据和 Skill 路径，不复制规则正文。

`evals/` 不是运行时规则。它记录规则来自什么失败模式，用于防止后续修改让相同行为再次出现。

## 使用方式

### 安装为 Agent Skill

可通过兼容 Agent Skills 的工具安装：

```powershell
npx skills add zhangdfly/feather-engineering-agent
```

### 安装为宿主插件

仓库包含 GitHub Copilot CLI、Claude Code 和 Codex 的插件清单。安装命令见 [宿主接入](docs/hosts.md)。

## 扩展

项目特有规则放在项目自己的 `AGENTS.md` 中。需要发布可复用扩展时，创建独立 Skill，并在其 `SKILL.md` 中引用 Feather 的适用边界。详见 [扩展规则](docs/extension-guide.md)。

## 为什么 v1 没有 Hook

本项目没有会话档位、开关状态或工具拦截需求。Skill 已经提供完整规则；Hook 会额外引入宿主方言、运行时依赖和上下文重复注入。

只有实际评测证明 Skill 经常不触发、子 Agent 丢失规则，或未来需要会话状态时，才考虑 SessionStart Hook。详见 [Hook 契约](docs/hook-contract.md)。

## 许可证

[MIT](LICENSE)。概念来源说明见 [第三方说明](THIRD_PARTY_NOTICES.md)。
