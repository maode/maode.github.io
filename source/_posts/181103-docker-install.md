---
title: Docker安装
date: 2018-11-03 20:32:41
tags:
	- Docker
---
## CentOS安装Docker

从 2017 年 3 月开始 docker 在原来的基础上分为两个分支版本: Docker CE 和 Docker EE。

Docker CE 即社区免费版，Docker EE 即企业版，强调安全，但需付费使用。

本文介绍 Docker CE 的安装使用。

### 安装一些必要的系统工具：
```bash
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
### 添加软件源信息：
```bash
$ sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```
### 更新 yum 缓存：
```bash
$ sudo yum makecache fast
```
### 安装 Docker-ce：
```bash
$ sudo yum -y install docker-ce
```
### 启动 Docker 后台服务
```bash
$ sudo systemctl start docker
```
### 测试运行 hello-world
```bash
$ docker run hello-world
```
由于本地没有hello-world这个镜像，所以会下载一个hello-world的镜像，并在容器内运行。

### 使用镜像加速器

鉴于国内网络问题，后续拉取 Docker 镜像十分缓慢，我们可以需要配置加速器来解决，我使用的是阿里的镜像地址。关于加速器的地址，你只需要登录[容器Hub服务](https://cr.console.aliyun.com)的控制台，左侧的加速器帮助页面就会显示为你独立分配的加速地址。

```
例如：
公网Mirror：[系统分配前缀].mirror.aliyuncs.com
```
当你下载安装的Docker Version不低于1.10时，建议直接通过daemon config进行配置。
使用配置文件 /etc/docker/daemon.json（没有时新建该文件）

```
{
    "registry-mirrors": ["<your accelerate address>"]
}
```

重启Docker Daemon就可以了。

## windows系统安装Docker

<!-- more -->

### win7、win8 系统
win7、win8 等需要利用 docker toolbox 来安装，国内可以使用阿里云的镜像来下载，下载地址：[http://mirrors.aliyun.com/docker-toolbox/windows/docker-toolbox/](http://mirrors.aliyun.com/docker-toolbox/windows/docker-toolbox/)

docker toolbox 是一个工具集，它主要包含以下一些内容：

- Docker CLI：客户端，用来运行docker引擎创建镜像和容器  
- Docker  Machine：  可以让你在windows的命令行中运行docker引擎命令  
- Docker  Compose： 用来运行docker-compose命令  Kitematic.  这是Docker的GUI版本 
- Docker  QuickStart shell：  这是一个已经配置好Docker的命令行环境  Oracle VM Virtualbox.  虚拟机

下载完成之后直接点击安装，安装成功后，桌边会出现三个图标，入下图所示：

![图片](/assets/blogImg/181103-docker-install-1.png)
点击 Docker QuickStart 图标来启动 Docker Toolbox 终端。

如果系统显示 User Account Control 窗口来运行 VirtualBox 修改你的电脑，选择 Yes。
![图片](/assets/blogImg/181103-docker-install-2.png)
`$ `符号那你可以输入以下命令来测试情况。
```bash
$ docker run hello-world
```
成功后显示如下
![图片](/assets/blogImg/181103-docker-install-p1.png)

### Win10 系统

现在 Docker 有专门的 Win10 专业版系统的安装包，需要开启Hyper-V。

开启 Hyper-V
![图片](/assets/blogImg/181103-docker-install-3.png)
程序和功能
![图片](/assets/blogImg/181103-docker-install-4.png)
启用或关闭Windows功能
![图片](/assets/blogImg/181103-docker-install-5.png)
选中Hyper-V
![图片](/assets/blogImg/181103-docker-install-6.png)

#### 1、安装 Toolbox

最新版 Toolbox 下载地址： [https://www.docker.com/get-docker](https://www.docker.com/get-docker)

点击 [Get Docker Community Edition](https://www.docker.com/community-edition)，并下载 Windows 的版本：
![图片](/assets/blogImg/181103-docker-install-7.png)
![图片](/assets/blogImg/181103-docker-install-8.png)

#### 2、运行安装文件

双击下载的 Docker for Windows Installe 安装文件，一路 Next，点击 Finish 完成安装。
![图片](/assets/blogImg/181103-docker-install-9.png)
![图片](/assets/blogImg/181103-docker-install-10.png)

安装完成后，Docker 会自动启动。通知栏上会出现个小鲸鱼的图标![图片](/assets/blogImg/181103-docker-install-11.png)，这表示 Docker 正在运行。

桌边也会出现三个图标，入下图所示：

我们可以在命令行执行 docker version 来查看版本号，docker run hello-world 来载入测试镜像测试。

如果没启动，你可以在 Windows 搜索 Docker 来启动：
![图片](/assets/blogImg/181103-docker-install-12.png)
启动后，也可以在通知栏上看到小鲸鱼图标：
![图片](/assets/blogImg/181103-docker-install-13.png)

### 镜像加速

配置方式同上方的Linux一样，只不过Windows下的`daemon.json`配置文件路径是不同的。

新版的 Docker 使用 /etc/docker/daemon.json（Linux） 或者 %programdata%\docker\config\daemon.json（Windows） 来配置 Daemon。

请在该配置文件中加入（没有该文件的话，请先建一个）：
```
{  "registry-mirrors":  ["<your accelerate address>"]  }
```
参考：
http://www.runoob.com/docker/windows-docker-install.html
http://www.runoob.com/docker/centos-docker-install.html
https://yq.aliyun.com/articles/29941
（完）




