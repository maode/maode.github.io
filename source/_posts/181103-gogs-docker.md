---
title: 【转】Docker方式搭建Git服务gogs
date: 2018-11-03 20:32:41
tags:
	- Docker
	- Git
---
**转自：** https://www.jianshu.com/p/4e43bda3e1f2

首先确保已安装Docker.可参考：https://maode.github.io/2018/11/03/181103-docker-install/

## 启动gogs容器

拉取`gogs`镜像
```
$ sudo docker pull gogs/gogs

```
创建本地目录存放数据（这个目录可以自定义）

```
$ sudo mkdir -p /var/gogs
```



使用run命令绑定端口和一些配置文件

```
$ sudo docker run -d --name=mygogs -p 10022:22 -p 10080:3000 -v /var/gogs:/data gogs/gogs

```

> 注:
> 
> *   这里**-d**将容器跑到后台，不在当前终端输出
> *   **-p**用来配置外置端口和内置端口的对应关系，将10022转到22端口，将10080转到3000端口
> *   **--name**用来给这个容器命名，不能重名
> *   **-v**用来配置数据的对应关系
> *   想要了解更多，需要系统的学习docker相关

## 配置Gogs

第一次进入gogs会出现如下页面
![图片](/assets/blogImg/181103-gogs-docker-1.png)

<!-- more -->

可以选择使用mysql作为数据库，但是稍微麻烦一点，需要在mysql配置一下授权，如果不想麻烦，那可以直接使用sqlite3作为数据库，免去了配置数据库

几个ip很重要，可以按我给的配置来填写，当然刚开始填错了也可以后来在app.ini中修改。

邮件服务配置的可以自行选择是否需要

建议不要使用内置ssh，反正笔者试过使用内置ssh可能出现权限拒绝问题，没看到好的解决办法。

安装好并登录即能出现如下界面
![图片](/assets/blogImg/181103-gogs-docker-2.png)
登录主界面

然后就可以正常使用了。

（完）




