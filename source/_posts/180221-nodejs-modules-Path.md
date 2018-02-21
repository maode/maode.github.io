---
title: nodejs安装的modules的环境变量配置
date: Wed Feb 21 2018 11:29:46
tags:
	- nodejs
	- 环境变量
---
昨天不小心把环境变量给覆写了，凭印象补充了一些，今天发现 nodejs下安装的所有module的 CLI命令 都失效了。寻思了好一会才想到应该怎么配置回来，记录一下。

nodejs通过npm命令全局安装的所有 modules 的 CLI命令 默认应该全都是被注册到了`C:\Users\code0\AppData\Roaming\npm`这个目录中，把这个目录加到环境变量的`Path`中，所有的 CLI命令 就都复活了。

暂时就这些，后面没有了！(=^ ^=)


