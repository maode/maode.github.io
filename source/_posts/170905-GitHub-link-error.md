---
title: GitHub配置完后链接不上，报错
date: 2017-09-05 15:32:41
tags:
	- GitHub
---
安装配置完Git后链接不上GitHub。
用`ssh -T git@github.com`命令测试连接时,报错`“ssh: connect to host github.com port 22: Connection timed out”`

解决方法:

<!-- more -->

找到Git安装目录下的`/etc/ssh/ssh_config`文件，打开该文件在文件底部添加如下信息并保存。
```
Host github.com

User git

Hostname ssh.github.com

PreferredAuthentications publickey

IdentityFile ~/.ssh/id_rsa

Port 443
```
KO，搞定！添加完成后再次测试链接会在`~/.ssh/`目录下自动生成一个`known_hosts`文件【已知主机列表】，关于该文件的说明可以参考该文章：[SSH原理与运用](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)
