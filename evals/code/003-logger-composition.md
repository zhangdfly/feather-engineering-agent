# 用例：为 Executor 增加日志

## 模式

编写模式

## 输入

给下面的单一 `Executor` 实现增加执行日志：

```python
class Executor:
    def execute(self, job):
        return job.perform()
```

## 合格结果

通过构造函数注入 `Logger` 成员，由业务方法在真实事件发生处记录。

## 失败特征

- 新增 `ExecutorWithLogger`；
- 新增只有一个实现的 `LoggingExecutor` 接口；
- decorator 只执行 `log -> inner.method -> log`，且没有复用或独立策略需求；
- 出现多层纯转发类型。

## 边界条件

如果同一日志策略需要透明组合到多个无关实现，或者包装层拥有独立资源生命周期、错误语义或行为契约，可以使用 decorator。
