---
title: jenkins注意事项
date: Wed Oct 26 2021 16:32:54
tags:
	- jenkins
---

1. 安装完jenkins后，安装常用插件，安装 Maven Integration，Publish Over SSH 插件。 
2. 在全局工具管理中安装maven，自定义配置maven的settings.xml文件（jdk和git自带了）
2. 流水线脚本中的变量和环境变量引用，一律使用`${变量名}`，其它方式引用，好多语法会不支持，容易报错。
3. 在script中执行mvn命令时，需要在mvn命令中指定一下 -s /setttingFilePath/setting.xml文件，否则会用默认的。无法下载私服上的jar。

（完）

