# 用例：性能窗口命名

## 模式

编写模式

## 输入

Executor 执行任务时需要记录一个性能时间窗口。

## 合格结果

由性能跟踪器或窗口对象表达生命周期，例如：

```text
perfTracker.startWindow()
window.stop()
```

## 失败特征

- `executor.start()` 实际只记录窗口开始时间；
- `start()`、`run()` 等名称无法指出启动了什么；
- 状态由一个对象拥有，方法却挂在另一个对象上。
