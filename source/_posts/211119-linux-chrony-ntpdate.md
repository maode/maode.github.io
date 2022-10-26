---
title: linux时间同步chrony和ntpdate
date: Wed Oct 26 2022 16:41:18
tags:
	- chrony
	- ntpdate
---

# 检查并设置时区
```
# 查看当前主机的时区
# timedatectl
      Local time: Fri 2018-2-29 13:31:04 CST
  Universal time: Fri 2018-2-29 05:31:04 UTC
        RTC time: Fri 2018-2-29 08:17:20
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a

如果你当前的时区不正确，请按照以下操作设置。

#查看所有可用的时区：

# timedatectl list-timezones

#筛选式查看在亚洲S开的上海可用时区：

# timedatectl list-timezones |  grep  -E "Asia/S.*"

Asia/Sakhalin
Asia/Samarkand
Asia/Seoul
Asia/Shanghai
Asia/Singapore
Asia/Srednekolymsk

# 设置当前系统为Asia/Shanghai上海时区：
# timedatectl set-timezone Asia/Shanghai

# 设置时间
# timedatectl set-time "YYYY-MM-DD HH:MM:SS"


# 设置硬件时间,硬件时间默认为UTC：
# timedatectl set-local-rtc 1

# 是否NTP服务器同步 yes/no
# timedatectl set-ntp yes

```

# chrony

chrony 可用来自动同步集群中主机的时钟。

## 服务端配置
1. 安装chrony软件
```
[root@server ~]# yum install chrony -y
```
2. 修改配置文件
```
[root@server ~]# vi /etc/chrony.conf

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
# server 0.centos.pool.ntp.org iburst
# server 1.centos.pool.ntp.org iburst
# server 2.centos.pool.ntp.org iburst
# 远程时钟服务器
server time1.aliyun.com iburst

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
# 将启用一个内核模式，在该模式中，系统时间每11分钟会拷贝到实时时钟
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
# 允许或拒绝指定网络的主机同步时间，不指定就是允许所有，默认不开启。（allow：允许 deny：拒绝）
allow 192.168.1.0/24
# Serve time even if not synchronized to a time source.
# 即使服务端没有同步到精确的网络时间，也允许向客户端同步不精确的时间。
local stratum 10

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
```
3. 启动、开机自启动、查看状态、查看同步源
```
[root@server ~]# systemctl start chronyd

[root@server ~]# systemctl enable chronyd

[root@server ~]# systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since 一 2018-04-23 11:25:38 CST; 6min ago

[root@server ~]# chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^* time4.aliyun.com              2   6    17    41    +87us[+1374us] +/-   28ms
```
执行`chronyc sources`命令后，输出信息中包含`^?`代表时间未同步，`^*`代表时间已同步

## 客户端配置

1. 安装chrony软件。
```
[root@server ~]# yum install chrony -y
```
2. 修改配置文件
```
[root@server ~]# vi /etc/chrony.conf

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
# server 0.centos.pool.ntp.org iburst
# server 1.centos.pool.ntp.org iburst
# server 2.centos.pool.ntp.org iburst
# 远程时钟服务器（设置为刚才的服务端地址，如：192.168.1.55）
server 192.168.1.55 iburst

# 其它配置项保持默认即可
```
3. 启动、开机自启动、查看状态、查看同步源。方法同服务端一样。

## chrony 常用命令
```
查看时间同步源和同步状态（输出信息中包含`^?`代表时间未同步，`^*`代表时间已同步）
$ chronyc sources -v

查看时间同步源状态：
$ chronyc sourcestats -v

校准时间服务器：
$ chronyc tracking

立即步进地校正时钟
$ chronyc -a makestep
```

## 时间同步问题no server suitable for synchronization found
在客户端和服务端分别按照以下步骤进行问题排查。
1. 检查防火墙
2. ping内部ip（路由）
3. ping外部地址（百度）
然后试着重启服务。


# ntpdate

ntpdate可用来手动强制同步时间。

1. 安装ntpdate `yum -y install ntpdate`
2. 强制同步时间 `ntpdate -d time1.aliyun.com`



（完）
