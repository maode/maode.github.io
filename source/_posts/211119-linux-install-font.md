---
title: linux安装中文字体
date: Wed Oct 26 2022 16:40:20
tags:
	- linux
---

1. 将需要安装的字体上传到linux的`/usr/share/fonts`目录。（TTC或TTF都可以）
2. 执行以下命令更新字体缓存
``` bash
fc-cache -fv  #如果命令未安装可执行：yum install fontconfig 或 apt-get install fontconfig
```
3. 执行`fc-list`或`fc-list :lang=zh`验证字体安装效果。

（完）




