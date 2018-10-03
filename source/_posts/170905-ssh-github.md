---
title: windows和Linux下通过SSH链接GitHub
date: 2017-09-05 15:32:41
tags:
	- GitHub
	- SSH
---
下载安装一款git工具，如 [git for windows](https://git-for-windows.github.io/)

打开 GitBash 命令窗口开始配置

``` bash
$ git config --global user.name "要设置的用户名"	#配置GitHub的name
$ git config --global user.email "要设置的邮箱"	#配置GitHub的email
```
进入到当前登录用户的目录下
`$ cd ~`
查看当前用户目录下是否存在`.ssh`文件夹，若不存在，则创建一个
`$ mkdir .ssh`

<!-- more -->

使用命令生成`SSH Key`
`$ ssh-keygen -t rsa -C "引号里内容是用来生成密钥的注释文字，可以用github的登录邮箱"`
连敲三次回车，生成密钥。三次回车分别是跳过`“自定义密钥文件名”、“设置SSH Key的管理密码”、“确认SSH Key的管理密码”`三个步骤。

密钥文件生成在`~/.ssh`目录下。`id_rsa`是私钥`id_rsa.pub`是公钥。

用编辑器打开公钥，全选-复制，然后登录GitHub在设置项中找到添加SSH Key的选项，把公钥粘贴上，标题可根据情况自定义。

配置完成 输入以下命令进行测试。
`$ ssh -T git@github.com`
可能会看到类似以下的警告之一
```
The authenticity of host 'github.com (192.30.252.1)' can't be established.
RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)?

The authenticity of host 'github.com (192.30.252.1)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
Are you sure you want to continue connecting (yes/no)?	
```
不用管这些警告，输入yes然后回车。

如果成功了，会看到以下提示消息。
`Hi username! You've successfully authenticated, but GitHub does not
provide shell access.`
如果报错，看这里：[链接GitHub报错](https://maode.github.io/2017/09/05/GitHub-link-error-170905/)

官方文档：https://help.github.com/articles/connecting-to-github-with-ssh/
