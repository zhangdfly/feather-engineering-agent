## 技术文档正反例

### 简单问题

任务：`2 * 3` 等于几？

错误：

> 在通常的十进制数学环境中，如果不考虑其他代数结构，2 与 3 相乘的结果为 6。

正确：

> 6。

### 配置说明

任务：把客户端请求超时设为 5 秒。

错误：

> 超时参数在现代分布式系统中非常重要。设置前请检查权限、网络环境和系统版本，并在修改后执行额外命令确认文件已经保存。

```yaml
client:
  timeout_seconds: 5
```

正确：

```yaml
client:
  timeout_seconds: 5
```

如果系统存在会改变该配置含义的真实版本限制，再补充该限制；不要预先罗列未知边界。

### PR 变更说明

任务：为同时修复聊天区滚动、支持受鉴权音频播放的 PR 写简介；用户随后问为什么这样改、是否都必要。

错误：

> 修改聊天样式、增加音频代理和暂停续播，补充测试与文档。这些改动改善体验和安全性，都是必要的。

正确：

> 聊天容器只有最小高度，会随消息增长，内部滚动无法起作用；限定父容器高度后，历史消息才在聊天区内滚动。浏览器音频元素无法给媒体请求附加服务端鉴权头，因此由网关代理固定的音频地址并保管凭据。暂停续播是为了保留被语音打断的播放位置，与聊天修复、鉴权代理各自独立；测试和文档随对应行为更新，不是聊天修复的运行时依赖。

如果只改一处用途自明的配置值，且用户只要改动清单，就不需要强行写一段“问题、方案、取舍”；没有证据也不要推测修改动机。

### 架构文档中的图表

任务：说明插件仓库的文件结构、组件依赖，以及 Agent 加载规则的核心顺序。

错误：

```text
Plugin manifest
  -> SKILL.md
    -> 文档规则
```

再用一段文字描述 Agent、Skill 和规则文件之间的调用顺序。读者需要从字符缩进和文字中自行还原关系。

正确：

文件层级保留文本树：

```text
skills/
└── engineering-agent/
    ├── SKILL.md
    └── references/
        └── docs/
            └── rules.md
```

组件依赖使用 Mermaid 组件图：

```mermaid
flowchart TD
    manifest["Plugin manifest"] --> skill["SKILL.md"]
    skill --> docsRules["文档规则"]
```

多参与者的核心调用顺序使用 Mermaid 时序图：

```mermaid
sequenceDiagram
    participant User as 用户
    participant Agent
    participant Skill as SKILL.md
    participant Rules as 文档规则

    User->>Agent: 提交文档任务
    Agent->>Skill: 加载入口规则
    Skill-->>Agent: 路由到文档规则
    Agent->>Rules: 加载文档规则
    Rules-->>Agent: 返回写作约束
    Agent-->>User: 交付文档
```
