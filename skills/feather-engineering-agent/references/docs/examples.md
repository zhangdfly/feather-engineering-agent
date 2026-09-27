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

任务：PR 修改了现有 Mermaid 时序图的鉴权分支，审阅者要求在简介中用红框标出变化。

错误：把时序图重画成“客户端 → 网关 → 媒体服务”的流程图，省略原图的另一分支和返回消息，再把新图称为“原始时序图”。

正确：从本次提交的 `sequenceDiagram` 原图渲染图片，只在改动的分支上叠加红框；图标题链接到对应源码，未变的参与者、箭头和消息保持原样。后续提交若改动源图，重新核对图片与源码、实现；未改动的图无需在简介中重画。

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

### 图内就地说明

任务：领域模型图列出 `CourtTask`、`Memorial` 和 `AttentionItem`，读者还需要知道它们的中文名称和一句话职责。

错误：图中只写三个英文对象名，紧接着再用表格逐项解释“Court 任务”“奏折”“待批事项”。读者理解任一关系时都要在图和表之间来回定位。

正确：保留可追溯的对象标识，把短说明直接放进类标签：

```mermaid
classDiagram
    class CourtTask["CourtTask<br/>Court 任务：目标与验收边界"]
    class Memorial["Memorial<br/>奏折：不可改写的决策材料"]
    class AttentionItem["AttentionItem<br/>待批事项：队列中的可操作镜像"]

    CourtTask "0..1" <-- "*" AttentionItem
    AttentionItem --> "1" Memorial
```

奏折 revision 规则、失败语义等较长不变量仍放在拥有该事实的正文中，不塞进类框；如果核心对象过多导致图无法扫读，按职责拆图。不要只留中文名称而丢失与代码或协议对应的英文标识。

### 多模块设计的覆盖与阅读路径

任务：一个项目有客户端、服务端和共享协议。读者要求从 README 逐层看懂模块与主要类型，以及外部事件如何到达服务端；目前整体设计只有组件图，本地设计只有文件列表。

错误：

> 总设计反复概括每个目录，本地设计只列出 `bridge.ts`、`app.ts` 和 `session.ts` 的文件名；图中有一条“外部事件 → 服务端”箭头，却没有说明事件从何处进入客户端、谁负责转发，以及连接失败时发生什么。

正确：

> README 链到整体设计；整体设计交代客户端、服务端与共享协议的关系，并链接到拥有流程的模块设计。客户端传输模块说明事件桥接收外部事件、交给页面编排，并写清断线重连和无效事件的处理；服务端会话模块说明收到控制消息后的状态变化。各模块链接主要类型和实现文件，不在整体设计中重复局部流程。

只有少量文件且读者可以连续读完的项目，不必为每个目录创建独立文档；按真实机制的复杂度决定细节，不按代码行数分配篇幅。

### 时序图中的参与者归属

任务：事件由外部源进入客户端传输模块，经过页面编排到服务端会话；读者看不出原图中的 `Client`、`App` 和 `Session` 分别属于哪里。

错误：只给参与者写抽象类名，再让读者到正文猜测它们属于哪个模块或外部系统。

正确：

```mermaid
sequenceDiagram
    participant SOURCE as 事件源（外部）
    participant BRIDGE as 事件桥（client/transport）
    participant APP as 页面编排（client/app）
    participant CLIENT as 网关连接（client/transport）
    participant SESSION as 会话（server/session）
    SOURCE-->>BRIDGE: event
    BRIDGE-->>APP: onEvent
    APP->>CLIENT: send(control)
    CLIENT->>SESSION: 控制消息（经 WebSocket）
```

若参与者在当前页面已经唯一且清楚，不必给每列重复写完整源码路径；失败和重连机制放在拥有它的模块设计中，不靠这张图猜。

### 可执行脚本的 README

任务：一个镜像准备目录包含入口脚本和共享复制实现。版本由声明文件维护；入口枚举镜像；共享实现逐个复制到远端仓库，全部成功后替换锁文件，但中途失败时已复制的镜像会保留。用户要求不读 shell 也能知道脚本做什么。

错误：

> 用“脚本 / 职责 / 副作用”表写入口负责准备镜像、共享脚本负责复制并生成锁文件，再画一张 `入口 → Registry → lockfile` 时序图。读者仍不知道版本由谁决定、何时替换锁文件，以及复制到一半失败后远端会留下什么。

正确：

> README 先说明版本由声明文件人工维护，入口只读取版本并枚举镜像；再按入口写清所需参数和凭据、枚举与兼容性校验、对共享复制实现的委托。共享实现单独说明：先检查仓库名冲突，再解析不可变摘要并逐个复制、匿名复核，全部成功后才原子替换锁文件；失败时旧锁文件不变，但此前复制成功的远端镜像会残留，使用相同声明重试即可收敛。职责表和时序图只作为导航，不代替这些边界。

如果入口只是给共享实现补一个固定参数，且没有独立校验、副作用或失败语义，只需说明该参数和委托关系并链接共享机制；不要把共享步骤复制到每个包装脚本，也不要逐行解释语法。

### 用户要求图示全覆盖

任务：实际模块为 `client/app`、`client/transport`、`server/session`、`shared/wire`。运行时文件及目标方法为 `app.ts:handleEvent`、`bridge.ts:connect/onEvent/disconnect`、`gateway.ts:send`、`session.ts:receive`、`event.ts:decodeEvent`；另有 `styles.css`、`types.ts`、`session.test.ts`。要求模块图覆盖所有模块，时序图覆盖所有运行时文件及公开或跨模块复用的方法。

错误：只画 `app → session` 的主路径，漏掉 `shared/wire`、`gateway.ts` 和 `disconnect()`；为凑文件数量把样式或测试画成运行时参与者。

正确：模块关系图列出四个模块，按启动/结束与事件交接拆成两张时序图；非运行时文件由模块图或文件职责索引说明。

```mermaid
flowchart LR
    SOURCE["事件源（外部）"] --> TRANSPORT["client/transport"]
    TRANSPORT --> WIRE["shared/wire"]
    TRANSPORT --> APP["client/app"]
    APP --> TRANSPORT
    TRANSPORT --> SESSION["server/session"]
```

```mermaid
sequenceDiagram
    participant APP as app.ts（client/app）
    participant BRIDGE as bridge.ts（client/transport）
    APP->>BRIDGE: connect()
    APP->>BRIDGE: disconnect()
```

```mermaid
sequenceDiagram
    participant SOURCE as 事件源（外部）
    participant BRIDGE as bridge.ts（client/transport）
    participant WIRE as event.ts（shared/wire）
    participant APP as app.ts（client/app）
    participant CLIENT as gateway.ts（client/transport）
    participant SESSION as session.ts（server/session）
    SOURCE-->>BRIDGE: onEvent(payload)
    BRIDGE->>WIRE: decodeEvent(payload)
    WIRE-->>BRIDGE: event
    BRIDGE-->>APP: handleEvent(event)
    APP->>CLIENT: send(event)
    CLIENT->>SESSION: receive(event)（经 WebSocket）
```

覆盖索引：`bridge.ts` 对应启停和事件图；`app.ts`、`gateway.ts`、`session.ts`、`event.ts` 对应事件图；`styles.css`、`types.ts`、`session.test.ts` 对应文件职责索引。若公开方法还未被调用，另画标明“未接入”的契约时序图，不要编造真实调用。未要求全覆盖时，原本简单的流程不必扩成这组图。
