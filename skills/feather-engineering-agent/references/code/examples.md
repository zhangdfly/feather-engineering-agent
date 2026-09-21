## 代码结构正反例

### 五步 workflow

错误：

```text
run
  -> runWithLog
    -> bootstrap
      -> host
        -> execute
```

公开入口没有显示业务步骤，只显示近义动词。

正确：

```python
def run(self, job):
    # 1. 校验输入
    job.validate()

    # 2. 打开性能窗口
    window = self.perf_tracker.start_window(job.id)

    try:
        # 3. 执行任务
        result = job.perform()

        # 4. 记录结果
        self.logger.info("job completed", job.id, result.status)
        return result
    finally:
        # 5. 关闭性能窗口
        window.stop()
```

### 名称与所有权

错误：

```python
executor.start()  # 内部实际记录性能窗口起始时间
```

正确：

```python
window = perf_tracker.start_window(job.id)
```

### 添加日志能力

错误：

```text
Executor
  -> ExecutorWithLogger
    -> LoggingExecutorDecorator
      -> ExecutorImpl
```

正确：

```python
class Executor:
    def __init__(self, logger):
        self.logger = logger
```

`Executor` 在执行真实业务动作的位置记录日志。只有日志策略需要透明应用到多个无关实现时，才考虑独立包装层。

