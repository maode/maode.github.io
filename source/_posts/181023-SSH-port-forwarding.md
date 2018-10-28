---
title: ssh端口转发和链接保活
date: 2018-10-23 15:32:41
tags:
	- ssh
---
SSH的端口转发功能默认是打开的。该配置位于ssh server主机的 `/etc/ssh/sshd_config` 配置文件中，默认为`AllowTcpForwarding yes`，转发时还要注意防火墙配置，确保用到的端口未被屏蔽。

修改`sshd_config`配置后要重启sshd服务。(CentOS7下执行`systemctl restart sshd.service`重启)。

## 本地端口转发

将ssh client所在主机上的某个端口接收到的请求，通过ssh加密通道转发到ssh server所在主机能够访问到的某个主机的某个端口上，包括转发到ssh server主机自身的某个端口上。

格式：

ssh -L <ssh-client主机绑定的地址:端口>:<目标地址:端口> <ssh-server连接串>

如：

`$ ssh -L 192.168.1.13:2000:localhost:3000 root@103.59.22.17 `

在ssh client所在主机上执行以上命令，表示：将ssh client主机网卡绑定的地址`192.168.1.13`的2000端口接收到的请求，先转发到以root用户登录的`103.59.22.17`这台ssh server主机，然后以该ssh server主机的身份请求`localhost:3000`端口，即：请求ssh server主机自身的3000端口。


`$ ssh -g -L 2000:103.60.13.11:3000 root@103.59.22.17`

在ssh client所在主机上执行以上命令，表示：将ssh client主机网卡绑定的所有地址的2000端口接收到的请求，先转发到以root用户登录的`103.59.22.17`这台ssh server主机，然后以该ssh server主机的身份请求`103.60.13.11:3000`端口，即：请求由ssh server主机再次转发到主机`103.60.13.11`的3000端口。(加`-g`参数和绑定`0.0.0.0`都可以，不加`-g`参数且不指定地址的话，默认会绑定到本机环回地址，即：该端口只对本机开放,其它主机不能访问)


## 远程端口转发

将ssh server所在主机上的某个端口所接收到的请求，通过ssh加密通道转发到ssh client所在主机能够访问到的某个主机的某个端口上，包括转发到ssh client主机自身的某个端口上。

格式：

ssh -R <ssh server主机绑定的地址:端口>:<目标地址:端口> <ssh server连接串>

如：

`$ ssh -R 192.168.0.13:2000:192.168.0.100:3000 root@103.59.22.17`

在ssh client所在主机上执行以上命令，表示：以root用户登陆`103.59.22.17`这台ssh server主机，并将该ssh server主机网卡绑定的`192.168.0.13`地址的2000端口接收到的请求,转发到当前ssh client主机，然后ssh client主机再转发到`192.168.0.100`主机的3000端口。

**注：** ssh server主机的`/etc/ssh/sshd_config`配置文件中需要配置`GatewayPorts clientspecified`才可以。修改`sshd_config`配置后要重启sshd服务。(CentOS7下执行`systemctl restart sshd.service`重启)。

`$ ssh -R 2000:127.0.0.1:3000 root@103.59.22.17`

在ssh client所在主机上执行以上命令，表示：以root用户登陆`103.59.22.17`这台ssh server主机，并将该ssh server主机网卡绑定的所有地址的2000端口接收到的请求,转发到当前ssh client主机，然后ssh client主机再转发到127.0.0.1主机的3000端口。即：请求ssh client主机自身的3000端口。

**注：** ssh server主机的`/etc/ssh/sshd_config`配置文件中需要配置`GatewayPorts yes`才可以。如果不配置默认值为no，会强制绑定到本机环回地址。修改`sshd_config`配置后要重启sshd服务。(CentOS7下执行`systemctl restart sshd.service`重启)。


## 动态端口转发

将ssh client所在主机上的某个端口接收到的请求，通过ssh加密通道转发到ssh server所在主机，ssh server所在主机的sshd会根据数据包的应用层协议（如HTTP）发起建立对应的连接。

格式：

ssh -D <ssh-client主机绑定的地址:端口> <ssh-server连接串>

如：

`$ ssh -D 1080 code0@10.194.77.13`

在ssh client所在主机上执行以上命令，表示：将ssh client主机网卡绑定的环回地址的1080端口接收到的请求，转发到以code0用户登录的`10.194.77.13`这台ssh server主机，然后以该ssh server主机的身份发起建立对应的连接。

`$ ssh -g -D 1080 code0@10.194.77.13`
在ssh client所在主机上执行以上命令，表示：将ssh client主机网卡绑定的所有地址的1080端口接收到的请求，转发到以code0用户登录的`10.194.77.13`这台ssh server主机，然后以该ssh server主机的身份发起建立对应的连接。

<!-- more -->

## 关于地址绑定

**非root用户无权开启小于1024的端口，只能开启1024~65535之间的端口号。**

#### 对于本地端口转发`-L`和动态端口转发`-D`

`-g`参数等同于绑定地址`0.0.0.0`，`0.0.0.0:`也可以用`*:`或`:`代替。当用`*`时，转发命令要以单引号包裹起来，防止shell解析错误。

	
以下命令效果相等
	
`$ ssh -g -D 1080 code0@10.194.77.13`
`$ ssh -D 0.0.0.0:1080 code0@10.194.77.13`
`$ ssh -D '*:1080' code0@10.194.77.13`	
`$ ssh -D :1080 code0@10.194.77.13`

#### 对于远程端口转发`-R`

`-g`参数无效，且转发端口的地址绑定需结合ssh server主机的`/etc/ssh/sshd_config`配置文件中的`GatewayPorts`配置才可以生效。

```
GatewayPorts clientspecified	#由ssh client主机来选择ssh server主机的哪些地址允许访问转发端口
GatewayPorts yes	#强制绑定到`0.0.0.0`
GatewayPorts no		#强制绑定到本机环回地址（默认）
```
## SSH链接保活

为了避免长时间空闲导致ssh连接被断开，我们可以通过配置保活选项来定期发送心跳包保活。可以通过修改配置文件的方式，也可以在建立ssh链接时通过命令的`-o`选项指定。如：`-o ServerAliveInterval=60`，每60秒向ssh server发送心跳信号。

### 修改配置文件保活

**第一种方法：**
修改ssh server主机的`/etc/ssh/sshd_config`配置文件

```
ClientAliveInterval 60	#server每隔60秒，向client发送一次请求，然后client响应，从而保持连接。
ClientAliveCountMax 40	#client超过40次无响应就断开链接。
```
还有一个TCPKeepAlive选项的作用是类似的，但是不如ServerAliveInterval 好，因为TCPKeepAlive在TCP层工作，发送空的TCP ACK packet，有可能会被防火墙丢弃；而ServerAliveInterval 在SSH层工作，，发送真正的数据包，更可靠。

**第二种方法：**
修改ssh client主机的`/etc/ssh/ssh_config`配置文件

```
ServerAliveInterval 60 ＃client每隔60秒发送一次请求给server，然后server响应，从而保持连接。
ServerAliveCountMax 3  ＃client发出请求后，服务器端没有响应得次数达到3，就自动断开连接，正常情况下，server不会不响应。
```
以上两种方法，任选一种即可。修改配置文件后记得重启服务。

### `-o`参数指定配置保活

在建立链接的命令参数里通过`-o ServerAliveInterval=60`保活， 这样只会在当前建立的连接中保持持久连接， 其他链接不受影响。毕竟不是所有连接都要保持持久的。

```
$ ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 root@139.224.55.222 
```

## 常用命令

```
$ ssh -NT -D 8080 host
```
N参数，表示只连接远程主机，不打开远程shell；T参数，表示不为这个连接分配TTY。这个两个参数可以放在一起用，代表这个SSH连接只用来传数据，不执行远程操作。

```
$ ssh -f -D 8080 host
```
f参数，表示SSH连接成功后，转入后台运行。这样一来，你就可以在不中断SSH连接的情况下，在本地shell中执行其他操作。

```
$ ssh -C -D 8080 host
```
C参数，表示将传输过程中的数据进行压缩。

### 组合使用

``` bash
# 本地转发
ssh -CfNT -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -L ssh-client主机某地址:端口:目标地址:端口 sshServer连接串

# 远程转发
ssh -CfNT -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -R ssh-server主机某地址:端口:目标地址:端口 sshServer连接串

# 动态转发
ssh -CfNT -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -D ssh-client主机某地址:端口 sshServer连接串
```

## SSH命令的参数解释

格式：

ssh  [user@]host [command]

常用选项：

`-1`：强制使用ssh协议版本1；

`-2`：强制使用ssh协议版本2；

`-4`：强制使用IPv4地址；

`-6`：强制使用IPv6地址；

`-A`：开启认证代理连接转发功能；

`-a`：关闭认证代理连接转发功能；

`-b`：使用本机指定地址作为对应连接的源ip地址；

`-C`：请求压缩所有数据；

`-F`：指定ssh指令的配置文件；

`-f`：后台执行ssh指令；

`-g`：允许远程主机连接主机的转发端口；

`-i`：指定身份文件；

`-l`：指定连接远程服务器登录用户名；

`-N`：只连接远程主机，不打开远程shell程序；

`-T`：不为这个连接分配TTY（禁止分配伪终端）；

`-o`：指定配置选项；

`-p`：指定远程服务器上的端口；

`-q`：静默模式运行，忽略提示和错误；

`-X`：开启X11转发功能；

`-x`：关闭X11转发功能；

`-y`：开启信任X11转发功能。

参数详细说明，参考：https://www.jb51.net/LINUXjishu/421780.html


## 参考资料

http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html
https://lesca.me/archives/ssh-port-forwarding-principle-and-praticle-application.html
https://www.cnblogs.com/jiqing9006/p/8807595.html
https://juejin.im/entry/58242bf42f301e005c41066e
https://www.zcfy.cc/article/creating-tcp-ip-port-forwarding-tunnels-with-ssh-the-8-possible-scenarios-using-openssh
http://blog.pluskid.org/?p=369


暂时就这些，后面没有了！(=^ ^=)


