# 用例：五步 workflow

## 输入

实现一个依次完成校验、打开性能窗口、执行任务、记录结果、关闭窗口的 workflow。

## 合格结果

一个 canonical `run` 入口按顺序显示五个步骤块。复杂步骤可以抽取，但调用名本身必须表达该业务步骤。

## 失败特征

- `run -> runWithLog -> bootstrap -> host -> execute`；
- 需要跨多个文件才能还原步骤顺序；
- 为缩短 `run` 而创建只调用下一层的函数。

