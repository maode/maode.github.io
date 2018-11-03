---
title: CentOS搭建svn服务器及创建多个版本库
date: 2018-11-03 15:32:41
tags:
	- svn
---

## 安装服务

`$ yum install -y subversion`

## 创建版本库
```bash
$ mkidr /svn/obj
$ svnadmin create /svn/obj
```

## 配置

使用`svnadmin create`命令后，会在`/svn/obj`目录下生成`conf`目录,此目录下有三个文件，`authz`、`passwd`、`svnserver.conf`

`authz`   用户权限配置文件

`passwd`  用户密码配置文件

`svnserver.conf`  主配置文件

编辑`svnserver.conf`文件：

```conf
anon-access = none    #关闭匿名访问
auth-access = write   #验证用户可写
password-db = passwd  #指向验证用户名密码的数据文件 passwd
auth-db=authz         #指向验证用户的权限配置文件 authz
```

编辑`passwd`文件:

```text
[users]
admin=admin   #用户名在等号前面，密码在后面相对应，注意：前面不能有空格
```


编辑`authz`文件：

```ini
[groups]
admin=admin,admin2,admin3
user=user1,user2,user3
[/]
@admin=rw   #admin组内的用户有obj的读写权限
@user=rw    #user组内的用户有obj的读写权限
```

## 启动服务[使用单个版本库]

```bash
$ svnserve -d -r /svn/obj [--listen-port 3690]
```

`-d` 表示后台运行
`-r /svn/obj` 表示指定根目录
`--listen-port 3690`表示指定端口，默认就是 3690，所以如果要用默认端口这个也是可以省略掉的
如果开启了防火墙，需要防火墙将3690端口放行.
**注意:** 此时启动是单个版本库.

现在用客户端TortoiseSVN-1.6.15.21042-win32-svn-1.6.16.msi 工具就可以上传和下载使用了
地址是： svn://ip地址

## 启动服务[使用多个版本库]
```bash
$ mkdir /svn/book
$ mkdir /svn/sport
$ svnadmin create /svn/book
$ svnadmin create /svn/sport
```
上面操作又创建了两个版本库 book和sport

<!-- more -->

把obj目录下的conf里的三个文件分别复制到book和sport的conf中
```bash
cp /svn/obj/conf/* /svn/book/conf/
cp /svn/obj/conf/* /svn/book/conf/
```
重新启动svn服务：
先关闭服务
```bash
$ killall svnserve
```
或者通过`ps aux|grep svnserve`找到进程id,然后`kill -9 进程id`
**再从所有版本库目录的父级目录启动**
```bash
$ svnserve -d -r /svn  [--listen-port 3690] 
```
用客户端工具下载和上传时，写url的时候后面加上文件夹的名字即可分开，如：

`svn://ip/obj `

`svn://ip/book`

使用SVN时，windows下强烈建议使用TortoiseSVN-1.6.15.21042-win32-svn-1.6.16.msi工具。

## 配置文件介绍

### svnserve.conf [服务配置]

`[general]`配置段中配置行格式如下：
`<配置项> = <值>`

配置项分为以下5项：
`anon-access` 控制非鉴权用户访问版本库的权限。取值范围为"write"、"read"和"none"。
即"write"为可读可写，"read"为只读，"none"表示无访问权限。
缺省值：read

`auth-access` 控制鉴权用户访问版本库的权限。取值范围为"write"、"read"和"none"。
即"write"为可读可写，"read"为只读，"none"表示无访问权限。
缺省值：write

`password-db` 指定用户名口令文件名。除非指定绝对路径，否则文件位置为相对conf
目录的相对路径。
缺省值：passwd

`authz-db` 指定权限配置文件名，通过该文件可以实现以路径为基础的访问控制。
除非指定绝对路径，否则文件位置为相对conf目录的相对路径。
缺省值：authz

`realm` 指定版本库的认证域，即在登录时提示的认证域名称。若两个版本库的
认证域相同，建议使用相同的用户名口令数据文件。
缺省值：一个UUID(Universal Unique IDentifier，全局唯一标示)

### passwd [用户配置]

配置格式:
`用户名 = 密码`

### authz [用户权限配置]

注意：
* 权限配置文件中出现的用户名必须已在用户配置文件中定义。
* 对权限配置文件的修改立即生效，不必重启svn。

用户组格式：
[groups]
`<用户组名> = <用户1>,<用户2>`
其中，1个用户组可以包含1个或多个用户，用户间以逗号分隔。
版本库目录格式：
`[<版本库>:/项目/目录]`
`@<用户组名> = <权限>`
`<用户名> = <权限>`
其中，方框号内部分可以有多种写法:
/,表示根目录及以下。根目录是svnserve启动时指定的，我们指定为/opt/svndata。这样，/就是表示对全部版本库设置权限。
repos1:/,表示对版本库1设置权限
repos2:/occi, ,表示对版本库2中的occi项目设置权限
repos2:/occi/aaa, ,表示对版本库2中的occi项目的aaa目录设置权限
权限主体可以是用户组、用户或\*，用户组在前面加@，*表示全部用户。权限可以是w、r、wr和空，空表示没有任何权限。





参考:
http://blog.51cto.com/cuixiang/1652238
https://www.jianshu.com/p/3ca41a36149a
https://blog.csdn.net/yin380697242/article/details/49362197


（完）



