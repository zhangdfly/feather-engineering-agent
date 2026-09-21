# 架构

## 结论

规则只有一个来源：`rules/`。所有宿主指令和 Agent Skill 文件均由生成器派生，禁止手工维护多份规则正文。

## 数据流

```text
rules/manifest.json
        |
        v
rules/*.md + 可选扩展模块
        |
        v
scripts/generate.ps1
        |
        +--> AGENTS.md
        +--> adapters/claude-code/CLAUDE.md
        +--> adapters/github-copilot/.github/copilot-instructions.md
        +--> adapters/codex/AGENTS.md
        +--> skills/feather-engineering-agent/SKILL.md
        +--> skills/feather-engineering-agent/references/*.md
```

依赖只能从规则源流向生成产物。生成文件不能反向定义规则。

## 模块职责

| 文件 | 职责 |
|---|---|
| `rules/00-core.md` | 所有任务始终生效的可读性原则和不可裁剪边界 |
| `rules/10-technical-docs.md` | 技术文档的信息准入、顺序和反模式 |
| `rules/20-code-structure.md` | workflow、函数抽取、命名、组合和类型结构 |
| `rules/30-examples.md` | 正反例，不新增规则 |
| `rules/manifest.json` | 模块顺序、Skill 内联/引用方式和生成目标 |

`SKILL.md` 只内联核心原则；文档、代码和示例规则放在本 Skill 的 `references/` 中按需读取。`AGENTS.md` 和 `adapters/` 中的宿主文件展平全部模块，避免宿主忽略相对引用。

根目录只保留 `AGENTS.md`。其他宿主格式位于 `adapters/`，供用户复制到目标项目；这样本仓库不会被同一 Agent 重复加载多份相同规则。

## 生成器

`scripts/generate.ps1` 只有一条可见流程：

1. 读取核心和扩展清单；
2. 校验并读取模块；
3. 组合完整规则和 Skill 路由；
4. 渲染目标文件；
5. 写入或检查漂移。

生成器没有 adapter 基类、宿主继承树或模板引擎。三个宿主的规则内容相同，差异只留在各自的 plugin manifest。

## 来源取舍

从 Ponytail 保留：

- 理解完整问题后再简化；
- 不添加未请求的抽象；
- 复用现有实现和平台能力；
- 正确性、安全和根因修复不可裁剪。

删除或弱化：

- 以一行代码、最短 diff 或最少文件作为通用目标；
- `lite/full/ultra` 会话档位；
- 为档位和 always-on 注入服务的运行时。

从 Humanizer 保留：

- 直接陈述；
- 删除铺垫、无靶辩论、空泛升华和对话残留；
- 每个保留句子必须增加信息；
- 不编造或误删事实。

删除：

- 旅行散文和个人声音模仿；
- 破折号、句式节奏等纯文风规则；
- 向用户展示草稿、批注和最终稿的多阶段输出。
