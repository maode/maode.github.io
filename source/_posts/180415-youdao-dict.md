---
title: Mint下安装有道词典失败
date: 2018-04-15 15:32:41
tags:
    - Linux
    - 有道
---
这其实是一篇转载，我只把标题改了一下。当时遇到问题时查了一些资料，这个作者的版本最简洁干练。

**原文出处：** https://www.jianshu.com/p/815c8a7a75c8

------
在Ubuntu16.04下安装有道词典发现因为一些依赖问题无法完成安装。通过尝试找到了解决方法。

因为官方Ubuntu的deb包依赖gstreamer0.10-plugins-ugly，但是该软件在16.04里面没有了。其实没有该包，完全不影响有道词典的使用。所以我们可以去掉deb包里面对于该库的依赖。具体操作如下：

从官方下载Ubuntu版本的deb包：[youdao-dict_1.1.0-0-ubuntu_amd64.deb](https://link.jianshu.com/?t=http://codown.youdao.com/cidian/linux/youdao-dict_1.1.0-0-ubuntu_amd64.deb)

创建youdao-dict目录，把该deb包解压到youdao-dict目录：

    sudo dpkg -X ./youdao-dict_1.1.0-0-ubuntu_amd64.deb youdao-dict

解压deb包中的control信息（包的依赖就写在这个文件里面）：

    sudo dpkg -e ./youdao-dict_1.1.0-0-ubuntu_amd64.deb youdao-dict/DEBIAN

编辑control文件，删除Depends里面的gstreamer0.10-plugins-ugly。

    sudo vi ./youdao-dict/DEBIAN/control

重新打包：

    sudo dpkg-deb -b youdao-dict youdaobuild.deb

安装重新打包的安装包

已经安装gdebi包管理器，可以使用如下命令安装，自动解决依赖问题

    sudo gdebi youdaobuild.deb

使用dpkg进行安装

    sudo dpkg -i youdaobuild.deb
    出现缺少的依赖使用如下命令安装所需依赖
    sudo apt install -f
    依赖安装完成后再次键入如下命令进行安装
    sudo dpkg -i youdaobuild.deb

作者：LionelDong
链接：https://www.jianshu.com/p/815c8a7a75c8
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

（完）