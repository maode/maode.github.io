---
title: maven常用命令
date: 2017-09-05 15:32:41
tags:
	- maven
---
``` bash
mvn help:effective-settings	
#查看当前生效的settings.xml，可用于判断某个settings配置是否生效
mvn help:effective-pom	
#用于查看当前生效的POM内容，指合并了所有父POM（包括Super POM）后的XML，所以可用于检测POM中某个配置是否生效 
mvn -X	
#debug，可查看settings.xml文件的读取顺序
mvn help:system	
#打印所有可用的环境变量和Java系统属性
```
暂时就这些，后面没有了！(=^ ^=)