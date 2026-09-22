# 用例：允许真实的 Executor 生命周期

## 模式

编写模式

## 输入

`Executor.start()` 创建工作线程并开始消费队列；每个任务执行时，`PerfTracker` 还会打开一个独立的性能测量窗口。整理两者的命名和调用顺序。

## 合格结果

保留 `executor.start()` 表示 Executor 自身启动，并使用 `perfTracker.openMeasurementWindow()` 与 `window.close()` 表示性能窗口生命周期。两个动作在名称和所有权上保持独立。

## 失败特征

- 因为规则反对含糊的 `executor.start()` 而重命名这个真实生命周期方法；
- 仍由 `executor.start()` 同时承担性能窗口记录；
- 使用同一个含糊的 `start()` 表达两个不同状态变化。

## 边界条件

裸生命周期动词只有在接收者自身发生对应转换时才准确；规则约束的是语义，不是禁用某个单词。
