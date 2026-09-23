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
    measurement_window = self.perf_tracker.open_measurement_window(job.id)

    try:
        # 3. 执行任务
        result = job.perform()

        # 4. 记录结果
        self.logger.info("job completed", job.id, result.status)
        return result
    finally:
        # 5. 关闭性能窗口
        measurement_window.close()
```

### 名称与所有权

错误：

```python
executor.start()  # 内部实际记录性能窗口起始时间
```

正确：

```python
measurement_window = perf_tracker.open_measurement_window(job.id)
```

如果 `Executor` 本身启动工作循环，`executor.start()` 是准确名称：

```python
executor.start()
measurement_window = perf_tracker.open_measurement_window(job.id)
```

前一个调用改变 `Executor` 的生命周期；后一个调用改变性能测量状态。不能因为都发生在执行流程中就把两者合并成同一个含糊的 `start()`。

### 合理抽取复杂步骤

正确：

```python
def run(self, request):
    # 1. 校验请求
    request.validate()

    # 2. 编译执行计划
    plan = self.plan_compiler.compile(request.expression)

    # 3. 执行计划
    return self.executor.execute(plan)
```

`compile()` 封装具有独立语法、不变量和错误语义的算法。调用名仍让主流程保持可见，因此不应为了扁平化把编译器实现内联到 `run()`。

### 多个公开 adapter

正确：

```python
def run_cli(self, args):
    return self.run(parse_cli_request(args))

def run_http(self, payload):
    return self.run(parse_http_request(payload))
```

不同入口只负责输入适配，业务步骤仍由同一个 `run()` 权威表达。

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

### 保留流水线失败

错误：

```powershell
ssh source 'select-required-values' |
  ssh target 'create-resource-from-stdin | apply-resource'

if ($LASTEXITCODE -eq 0) {
  Write-Output "发布成功"
}
```

这里只检查最后一个远端命令。即使源端筛选失败，下游仍可能从空输入创建空资源并返回成功。

正确：

```powershell
$payload = ssh source 'select-required-values'
if ($LASTEXITCODE -ne 0) {
  throw "读取源配置失败"
}
if (($payload | Measure-Object).Count -ne 2) {
  throw "源配置缺少必要键"
}

$payload | ssh target 'create-resource-from-stdin | apply-resource'
if ($LASTEXITCODE -ne 0) {
  throw "应用目标资源失败"
}

$keyCount = ssh target 'count-resource-keys'
if ($LASTEXITCODE -ne 0 -or $keyCount -ne 2) {
  throw "目标资源状态不完整"
}
```

敏感值只保留在内存和标准输入中；代码分别验证源步骤、交接形状和最终状态。若使用 POSIX shell 且每个阶段都会可靠返回非零，`set -o pipefail` 可以直接保留同步流水线的失败。
