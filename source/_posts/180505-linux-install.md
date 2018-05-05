---
title: Linux软件安装方法
date: 2018-05-05 15:32:41
tags:
    - linux
---

非root用户时，别忘了sudo.

## Debian系

从软件仓库中下载安装
`apt-cache search packagename` 在软件仓库中搜索该软件
`apt-get install packagename` 安装
`apt-get -f install packagename` 修复安装
`apt-get install packagename --reinstall` 重新安装
`apt-get remove packagename` 卸载
`apt-get remove packagename --purge` 卸载，包括删除配置文件等

安装下载至本地的deb包
`dpkg -i packagename.deb ` 安装
`dpkg -r packagename` 卸载
`dpkg -P packagename` 卸载，包括删除配置文件等
也可以使用上面`apt-get remove`的方式卸载，都可以

<!-- more -->

相关常用命令
`dpkg -L packagename` 查看已安装软件的安装位置
`dpkg -S 文件名` 查看该文件属于哪个软件包
`dpkg -l` 查看系统中已安装的所有软件包

详细命令介绍：https://blog.csdn.net/mikyz/article/details/69397698

## Red Hat系

从软件仓库中下载安装（yum或dnf）

`yum search packagename` 在软件仓库中搜索该软件
`yum install packagename` 安装
`yum groupinsall groupname` 安装软件组
`yum check-update` 检查可更新的程序
`yum update packagename` 更新指定程序包
`yum update` 全部更新
`yum remove packagename` 或`yum erase packagename` 卸载 
`yum groupremove groupname` 卸载软件组

安装下载至本地的rpm包
`rpm -i example.rpm` 安装 example.rpm 包
`rpm -iv example.rpm` 安装 example.rpm 包并在安装过程中显示正在安装的文件信息
`rpm -ivh example.rpm` 安装 example.rpm 包并在安装过程中显示正在安装的文件信息及安装进度
`rpm -e packagename` 卸载

rpm 的其他附加命令:
`--force` 强制操作 如强制安装删除等
`--requires` 显示该包的依赖关系
`--nodeps` 忽略依赖关系并继续操作

相关常用命令
`rpm -qa | grep tomcat4` 查看 tomcat4 是否被安装
`rpm -qip packagename.rpm` 查看本地安装包的信息
`rpm -ql packagename` 查看已安装软件的安装位置
`rpm -qf 文件名` 查看该文件属于哪个软件包
`yum list` 显示所有已经安装和可以安装的程序包
`yum list packagename` 显示指定程序包安装情况
`yum info packagename` 显示安装包信息


yum详细命令介绍：http://www.cnblogs.com/chuncn/archive/2010/10/17/1853915.html
rpm详细命令介绍：http://os.51cto.com/art/201001/177866.htm

## 源码安装（.tar、tar.gz、tar.bz2、tar.Z、.zip）
首先在官网下载源码包。

下载完成后计算MD5校验和，并与官方提供的值相比较，判断是否一致。
如：`md5sum packagename.tar.gz`

然后解压缩源码压缩包。

解压xx.tar.gz：`tar zxf xx.tar.gz`
解压xx.tar.Z：`tar zxf xx.tar.Z`
解压xx.tgz：`tar zxf xx.tgz`
解压xx.bz2：`bunzip2 xx.bz2`
解压xx.tar：`tar xf xx.tar`
解压xx.zip：`unzip xx.zip`

解压完成后进入到解压出的目录中，建议先读一下README之类的说明文件，因为此时不同源代码包或者预编译包可能存在差异，然后建议使用`ls -F --color`或者`ls -F`命令查看一下可执行文件，可执行文件会有`*`号的尾部标志。

一般依次执行以下命令即可完成安装。（但也有特殊的，特殊的参考帮助或官方介绍进行安装）

`./configure` 使用默认配置选项
`make` 编译
`make install` 安装

**另：**
安装前执行`./configure --help` 可以查看帮助。
安装前执行`./configure --prefix=路径名` 可以指定软件安装目录

一般编译安装需要执行很久，请耐心等待！
(完)