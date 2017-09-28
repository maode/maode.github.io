---
title: Debugging Node.js with DevTools
date: Tue Sep 26 2017 22:37:45
tags:
	- Node.js
	- DevTools
---
devtool 已经并入node.js v6.3.0以上版本的核心包，所以不用再installe。可以直接开整。如下：

调试 `mrd.js` 并在该文件第一句断点。
``` bash
$ node --inspect --debug-brk mrd.js # debug mrd.js 并在该文件第一句断点
```
打开Chrome在地址栏输入：chrome://inspect 

OK！现在可以开始调试了。就是如此简单。

**如果想让某次的debug过程重新走，在devtool中随便改行代码，然后保存，就可以重头再走一遍了。**

v7+ 版本还可以把以上命令简化为：`$ node --inspect-brk mrd.js( v7+)`
我的版本低，没试！

### 参考资料：
https://medium.com/@paul_irish/debugging-node-js-nightlies-with-chrome-devtools-7c4a1b95ae27


暂时就这些，后面没有了！(=^ ^=)

