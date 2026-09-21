<!-- 此文件由 scripts/generate.ps1 从 rules/ 生成，请勿直接编辑。 -->

## 正反例

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
