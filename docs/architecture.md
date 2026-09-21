# 架构

## 结论

行为规则只有一个来源：`skills/feather-engineering-agent/`。插件 manifest 只指向该 Skill，不复制规则正文，也不经过生成步骤。

## 文件结构

```text
skills/feather-engineering-agent/
├── SKILL.md
└── references/
    ├── docs/
    │   ├── rules.md
    │   └── examples.md
    ├── code/
    │   ├── rules.md
    │   └── examples.md
    └── review.md
```

`SKILL.md` 包含所有任务都需要的核心规则，并在编写模式与 PR Review 模式之间路由。领域规则与示例按需读取，`review.md` 只定义评审和反馈学习流程。

## 依赖方向

```text
plugin manifest
      |
      v
SKILL.md
      |
      +--> 编写模式
      |      +--> references/docs/rules.md
      |      └--> references/code/rules.md
      |
      └--> PR Review 模式
             +--> references/review.md
             +--> 对应领域规则
             └--> 用户反馈
                    +--> 更新现有规则
                    └--> 添加 eval case
```

规则文件不能引用宿主 manifest。示例只能解释已有规则，不能创建新规则。

根目录 `AGENTS.md` 只负责让维护本仓库的 Agent 加载本地 Skill，并承载未来的项目特有规则。

`evals/` 不参与正常编写和评审。它保存评审反馈形成的最小回归案例，为后续规则修改提供可复现证据。

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
