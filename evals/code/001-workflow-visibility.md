# 用例：五步 workflow

## 模式

编写模式

## 输入

重构下面的实现，使它依次完成校验、打开性能窗口、执行任务、记录结果和关闭窗口：

```python
class Workflow:
    def run(self, job):
        return self.run_with_log(job)

    def run_with_log(self, job):
        return self.bootstrap(job)

    def bootstrap(self, job):
        self.executor.start(job.id)
        return self.execute(job)

    def execute(self, job):
        result = job.perform()
        self.logger.info("job completed", job.id, result.status)
        return result
```

## 合格结果

一个权威 `run` 入口按顺序显示五个步骤块；性能窗口在异常路径也会关闭。复杂步骤可以抽取，但调用名本身必须表达该业务步骤。

## 失败特征

- `run -> runWithLog -> bootstrap -> host -> execute`；
- 需要跨多个文件才能还原步骤顺序；
- 为缩短 `run` 而创建只调用下一层的函数。

## 边界条件

独立算法、资源生命周期或副作用边界可以抽取；`run` 中仍应通过领域名称看见对应步骤。
