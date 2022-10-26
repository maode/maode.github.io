---
title: dns服务Dnsmasq搭建问题
date: Wed Oct 26 2021 14:48:42
tags:
	- dns
---

# docker方式

带有简单的web管理界面的docker镜像：https://hub.docker.com/r/jpillora/dnsmasq

## dnsmasq配置文件介绍
`/etc/dnsmasq.d/` 目录用来存放用户自定义配置，类似nginx的`conf.d`目录。
`/etc/dnsmasq.conf` 主配置文件，用来配置dnsmasq程序参数。也可以包含自定配置，类似nginx的`nginx.conf`文件。
`/etc/resolv.conf` 上游配置文件，用来配置上游dns。所有dnsmasq解析不了的域名，会转发给该文件中配置的上游dns来解析。

## dnsmasq的解析流程
dnsmasq先去使用`hosts`文件解析， 再使用`/etc/dnsmasq.d/`下的*.conf文件解析，再使用`/etc/dnsmasq.conf`解析，最后使用`/etc/resolv.conf`解析。
在上面的解析过程中，如果在某个环节解析成功。则立即返回解析结果，不再向下传递。

# 忽略hosts解析
如果不想用hosts文件做解析，我们可以在`/etc/dnsmasq.conf`中加入`no-hosts`这条语句。

# 忽略上游解析
如果我们不想做上游查询，就是不想做正常的域名解析，我们可以在`/etc/dnsmasq.conf`中加入`no-reslov`这条语句。



详细配置可参考：https://cloud.tencent.com/developer/article/1174717


# 直接安装方式（非docker方式）
1. 安装dnsmasq
```bash
yum install dnsmasq
```

2. 在`etc/dnsmasq.d`目录下新建配置文件
```
vi /etc/dnsmasq.d/custom.conf
```

3. 启动服务并设为开机启动
```
systemctl start dnsmasq

systemctl enable dnsmasq
```

4. 如果是云服务器，记得开放 下行的UDP 53 端口

（完）


