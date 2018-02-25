---
title: MongoDB安装配置
date: Sun Feb 25 2018 21:36:17
tags:
	- MongoDB
	- Database
---

官网最新版（社区版）：https://www.mongodb.com/download-center#community
## 安装过程

安装过程中选择  “Custom(自定义)” 可以自定义安装路径。

安装时注意左下角的 “install mongo compass（安装指南）” 取消勾选。否则会卡住。无法完成安装（3.6版本的）


## 配置过程

### 创建数据和日志文件存放位置：
如：
```bat
mkdir D:\software\MongoDB\Server\3.6\data
mkdir D:\software\MongoDB\Server\3.6\logs
```
### 启动MongoDB服务
在bin目录下执行以下命令（如果报错[看这里](#安装完执行命令时报错)）：
```bat
mongod.exe --dbpath "D:\software\MongoDB\Server\3.6\data"
```
`--dbpath`指向刚才新建的数据库目录。如果不指定，默认会在C盘创建一个文件夹用来存放数据。
正常的话控制台会打印一大串信息，开头是启动的进程id，系统信息等等，最后一行是端口信息。如：`2018-02-25T22:05:23.019+0800 I NETWORK  [initandlisten] waiting for connections on port 27017`。
### 测试链接
目前服务已经启动，处于等待链接状态，这时另外打开一个cmd命令窗口用来测试一下链接。
（记得如果没有配置环境变量的话，要切换到bin目录下去执行命令）
在新打开的cmd命令窗口执行命令 `mongo` 如果没问题的话，控制台会打印链接信息。如下：
```bat
C:\Users\code0>mongo
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.6.3
.................后面的省略
```
同时另一个用来启动服务的窗口也会有对应的链接信息显示。
```bat
2018-02-25T22:06:17.176+0800 I NETWORK  [listener] connection accepted from 127.0.0.1:58527 #1 (1 connection now open)
```
这时就代表链接成功了，可以敲几个命令感觉一下。
```bat
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
> use admin
switched to db admin
> db.shutdownServer()
2018-02-25T22:44:48.357+0800 I NETWORK  [thread1] Socket recv() 远程主机强迫关闭了一个现有的连接。 127.0.0.1:27017
>
```
这样就算安装成功了，以上为刚完成安装后默认的三个库。这时可以关闭服务了。使用admin库执行`db.shutdownServer()`命令，关闭服务。
这时启动服务的cmd窗口也会有对应的信息显示。如：
```bat
2018-02-25T22:44:47.830+0800 I STORAGE  [conn1] WiredTigerKVEngine shutting down

2018-02-25T22:44:48.353+0800 I STORAGE  [conn1] shutdown: removing fs lock...
2018-02-25T22:44:48.353+0800 I CONTROL  [conn1] now exiting
2018-02-25T22:44:48.354+0800 I CONTROL  [conn1] shutting down with code:0
```
然后关闭这两个cmd窗口，测试结束。

### 添加环境变量
安装完成后，将MongoDB路径下的bin目录加入Path，方便使用，否则每次都要进入bin目录下敲命令，太麻烦。

### 将MongoDB服务注册为windows服务
用管理员身份打开cmd窗口（非管理员用户，试了一下不管用）执行以下命令。
```bat
mongod --logpath "D:\software\MongoDB\Server\3.6\logs\mongodb.log" --logappend -dbpath "D:\software\MongoDB\Server\3.6\data" --serviceName "mongodb" --install

```
以上参数含义：
`--logpath` 指向刚才创建的用来存放日志文件的路径。
`-dbpath` 指向刚才创建的用来存放数据库文件的路径。
`--logappend` 以追加的方式记录日志。
`--serviceName` 注册的服务名。
注册完成后，可以在cmd窗口执行`services.msc`命令，在弹出的服务列表中能够看到我们新注册的名字为“mongodb”的服务，默认是自动启动的，如果不想自动启动，可以改为手动。手动启动的方式和启动其它windows服务是一样的。`net start mongodb`。

**关闭服务**推荐使用上面介绍的 `db.shutdownServer()` 命令。

如果要从windows服务中**注销（删除）该服务**，使用命令：
`mongod.exe --remove --serviceName "mongodb"`

## 图形界面

Robo 3T： https://robomongo.org/download

## 附录：
### 安装完执行命令时报错
安装完成后使用时报错缺少`api-ms-win-crt-runtime-l1-1-0.dll`。试了几种方法，最后用下面这种方法搞定了。

缺少的dll文件包含在windows的某个更新文件中去[这个地址](https://support.microsoft.com/zh-tw/kb/2999226)安装缺少的更新文件。

解决方法参考：https://helpx.adobe.com/tw/creative-cloud/kb/error_on_launch.html

其它内容参考：http://www.cnblogs.com/sufferingStriver/p/mongodberror.html
