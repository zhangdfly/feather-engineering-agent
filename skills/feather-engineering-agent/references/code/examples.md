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

### 模块与注释

错误：

```yaml
steps:
  - uses: actions/checkout@<sha>
  - run: npm ci
  - run: npm test
  - run: ./deploy.sh
```

读者只能看到工具调用，不知道为何需要完整历史、测试发生在何种权限之前，也不知道部署步骤拥有什么边界。

正确：

```yaml
steps:
  # 检出完整历史，用于证明待发布 commit 已进入主分支。
  - uses: actions/checkout@<sha>

  # 按 lockfile 安装校验器依赖。
  - run: npm ci

  # 在取得部署凭据前执行安全与结构回归测试。
  - run: npm test

  # 使用 Namespace 级身份发布已经审核的清单。
  - run: ./deploy.sh
```

同一模块的 README 说明这些工作流文件各自的职责。复杂配置块解释权限、顺序和失败边界；标准文件名或不支持注释的格式由 README 说明。

简单函数不需要注释：

```python
def sort_by_id(items):
    return sorted(items, key=lambda item: item.id)
```

如果函数名只是 `process()`，应先改成领域名称，而不是添加“处理数据”注释。
