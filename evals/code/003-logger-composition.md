# 用例：为 Executor 增加日志

## 输入

现有 `Executor` 需要在执行方法中记录日志。

## 合格结果

通过构造函数注入 `Logger` 成员，由业务方法在真实事件发生处记录。

## 失败特征

- 新增 `ExecutorWithLogger`；
- 新增只有一个实现的 `LoggingExecutor` 接口；
- decorator 只执行 `log -> inner.method -> log`，且没有复用或独立策略需求；
- 出现多层纯转发类型。
