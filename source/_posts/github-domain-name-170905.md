---
title: Github映射自定义域名
date: 2017-09-05 15:32:41
tags:
	- GitHub
---
1. 向你的 Github Pages 仓库添加一个CNAME文件(文件名一定要**大写**)。
文件中只能包含一个顶级域名，像这样`example.com`。
如果你是用 hexo 框架搭建博客并部署到 Github Pages 上，每次执行生成命令`$ hexo g`和部署命令`$ hexo d`后，会将博客所在目录下 public 文件夹里的东西都推到 Github Pages 仓库上，并且把 CNAME 文件覆盖掉，解决这个问题可以直接把 CNAME 文件添加到 source 文件夹里，这样每次推的时候就不用担心仓库里的 CNAME 文件被覆盖掉了。

<!-- more -->

2. 向你的 DNS 配置中添加 3 条记录
	```
	@     		A             192.30.252.153
	@     		A             192.30.252.154
	www		CNAME         username.github.io
	```
用你自己的 Github 用户名替换 username
