---
title: centos7安装mysql
date: Wed Oct 26 2021 14:37:10
tags:
	- mysql
	- centos
---

centos7安装mysql

# 首先卸载自带的Maria DB

1. 通过`rpm -qa | grep mariadb`命令查找是否安装了Maria DB。
2. 如果安装了，则卸载所有 Maria DB 相关的软件包。如：`rpm -e --nodeps mariadb-libs-5.5.68-1.el7.x86_64`

# 通过安装yum源，在线安装

1. 根据自己的系统版本下载对应的mysql的yum源，（centos7对应EL7）。如：
```
# 从mysql5.7官网下载
wget http://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# 或 从中科大镜像站点下载
wget http://mirrors.ustc.edu.cn/mysql-repo/mysql57-community-release-el7-11.noarch.rpm
```
2. 安装mysql的yum源
```
# 安装
yum localinstall mysql57-community-release-el7-11.noarch.rpm
# 检查安装情况（安装成功会显示mysql相关yum repository）
yum repolist enabled | grep "mysql.*-community.*"
```
3. 通过`yum-config-manager`开启或关闭对应的mysql发布版本。(该步骤为可选步骤，通常repository中已默认开启你想要安装的版本)
4. 安装mysql
```
yum install mysql-community-server
```
**注意：** 如果报错‘源 "MySQL 5.7 Community Server" 的 GPG 密钥已安装，但是不适用于此软件包。请检查源的公钥 URL 是否配置正确’，则需导入公钥到rpm仓库中。可执行命令 `rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022`
5. 启动mysql
```
systemctl start mysqld
```
6. 登录mysql
```
# 查看生成的临时密码
grep 'temporary password' /var/log/mysqld.log
# 登录mysql
mysql -uroot -p密码
# 修改密码
ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';
# 允许root远程登录
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '设一个密码' WITH GRANT OPTION;
```
**注意：** 如果外部主机无法访问，报错`ERROR 2003 (HY000)`，可能是防火墙端口未放行，可在外部主机通过`nc -zv ip port`来进行测试。如果不能连通会提示`No route to host`。
netcat（或简称 nc ）是一个功能强大且易于使用的程序，可用于 Linux 中与 TCP、UDP 或 UNIX 域套接字相关的任何事情。nc程序包安装`yum install nc -y`

# 防火墙开启3306端口[或设置的其它端口]，方便外部主机访问

```
# 查看防火墙服务的状态
systemctl status firewalld
# 启动防火墙
systemctl start firewalld
# 开机自启动防火墙
systemctl enable firewalld
# 开放3306端口
firewall-cmd --zone=public --add-port=3306/tcp --permanent
# 重新加载，使配置生效
firewall-cmd --reload
```

# 自定义端口后，关闭selinux，否则无法启动

```
# 关闭selinux，当前会话生效
setenforce 0
# 关闭selinux，永久生效（需重启主机）
vi /etc/selinux/config 设置 SELINUX=disabled
```

# 设置 binlog 日志目录的权限（如果修改了 binlog 日志的默认目录，需要给新设置的目录设置权限。若使用默认目录则不需要）

```
chown -R mysql.mysql 新目录
```

# 仅安装客户端
```
yum install mysql-community-client
```

# 通过下载rpm包，离线安装

1. 去mysql官网下载rpm包，https://dev.mysql.com/downloads/mysql/5.7.html，其中`bundle.tar`后缀为合集包，包含所有相关组件。

2. 如果只想要安装server,那么只需下载以下几个包即可
```
 mysql-community-common-5.7.9-1.el7.x86_64.rpm
 mysql-community-libs-5.7.9-1.el7.x86_64.rpm           --（依赖于common）
 mysql-community-client-5.7.9-1.el7.x86_64.rpm         --（依赖于libs）
 mysql-community-server-5.7.9-1.el7.x86_64.rpm         --（依赖于client、common）
```
3. 进入下载完成的目录，执行以下命令进行安装(也可以使用`rpm -ivh`命令进行安装，但可能要手动解决依赖)
```
yum install mysql-community-{server,client,common,libs}-* mysql-5.*­
```
4. 安装完成后，就是启动数据库，和上面的第5、6步骤相同。


后期若不适用，或可参考5.7的官方安装文档：
通过yum源安装 https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html
通过rpm包安装 https://dev.mysql.com/doc/refman/5.7/en/linux-installation-rpm.html

（完）


