# 用例：性能窗口命名

## 模式

编写模式

## 输入

重构下面的实现。`Executor` 已经由调用方启动；这里仅记录一次任务执行的性能测量窗口：

```python
class Executor:
    def start(self):
        self.perf_tracker.started_at = self.clock.now()

    def execute(self, job):
        self.start()
        return job.perform()
```

## 合格结果

由性能跟踪器或窗口对象表达生命周期，并使用对称的转换名称，例如：

```text
measurementWindow = perfTracker.openMeasurementWindow()
measurementWindow.close()
```

## 失败特征

- `executor.start()` 实际只记录窗口开始时间；
- `start()`、`run()` 等名称无法指出启动了什么；
- 状态由一个对象拥有，方法却挂在另一个对象上。
- 将返回值命名为 `window`，丢失 `measurement` 这一领域限定词。

## 边界条件

如果 `Executor.start()` 确实启动 Executor 自身的工作循环或资源生命周期，则名称准确，不应仅因为存在 `start` 而修改。

## 反馈依据

用户指出 `openMeasurementWindow()` 的返回值如果命名为 `window`，仍然需要读者从调用右侧恢复它是性能测量窗口，应保留完整领域名称。
