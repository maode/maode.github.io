---
title: Linux安装shadowsocks
date: 2018-05-05 15:32:41
tags:
    - linux
    - shadowsocks
---
## 安装
`sudo apt-get install shadowsocks`
安装完成后根据情况，按照下面的步骤选择配置为客户端或服务端。

## 配置为客户端
`sudo dpkg -L shadowsocks` 查看一下`config.json`(高版本)或`shadowsocks.json`（低版本）配置文件的位置。
`sudo vim /etc/shadowsocks/config.json` 编辑配置文件，大致如下：

<!-- more -->

客户端
``` json
{
    "server":"服务端地址",
    "server_port":服务端开放的端口,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"服务端设置的密码",
    "timeout":300,
    "method":"加密方式-同服务端设置的一样",
    "fast_open": false,
    "workers": 1
}
```
### 客户端启动及开机自启动
`cd`进入`config.json`所在的目录，执行命令 `ss-local`即可启动客户端。

配置守护进程，开机自启动。
创建自启动文件
`sudo vim /etc/systemd/system/shadowsocks.service`

添加以下内容至`shadowsocks.service`（以后随着版本升级，再配置时可能需要进行适当修改）。
``` ini
[Unit]
Description=Shadowsocks

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks/config.json
Restart=on-failure
RestartSec=2s

[Install]
WantedBy=multi-user.target
```

执行以下命令启动 shadowsocks 服务，和设置开机自启动。
``` bash
systemctl start shadowsocks #立即启动服务
systemctl enable shadowsocks #设置开机自启动
```

## 配置为服务端
同客户端一样也是配置`config.json`。
`sudo vim /etc/shadowsocks/config.json` 编辑配置文件，大致如下：
服务端
``` json
{
    "server":"0.0.0.0",
    "server_port":对外开放的端口号,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"设置访问密码",
    "timeout":300,
    "method":"加密方式",
    "fast_open":false
}
```

### 服务端启动及开机自启动
`cd`进入`config.json`所在的目录，执行`ssserver`命令即可启动服务。
**注意: 如果安装的是shadowsocks-libev则使用ss-server替代ssserver。**

配置守护进程，开机自启动。
创建自启动文件
`sudo vim /etc/systemd/system/shadowsocks.service`

添加以下内容至`shadowsocks.service`（以后随着版本升级，再配置时可能需要进行适当修改）。
``` ini
[Unit]
Description=Shadowsocks

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-failure
RestartSec=2s

[Install]
WantedBy=multi-user.target
```

执行以下命令启动 shadowsocks 服务，和设置开机自启动。
``` bash
systemctl start shadowsocks #立即启动服务
systemctl enable shadowsocks #设置开机自启动
```


## 验证自启动服务配置是否成功
执行以下命令
`sudo systemctl status shadowsocks -l`
如果配置成功，窗口显示类似如下的信息：

客户端：
``` bash
● shadowsocks.service - Shadowsocks
   Loaded: loaded (/etc/systemd/system/shadowsocks.service; enabled; vendor preset: enabled)
   Active: active (running) since 六 2018-05-05 12:48:22 CST; 9h ago
 Main PID: 833 (sslocal)
   CGroup: /system.slice/shadowsocks.service
           └─833 /usr/bin/python /usr/bin/sslocal -c /etc/shadowsocks/config.json
```

服务端：
``` bash
● shadowsocks.service - Shadowsocks
   Loaded: loaded (/etc/systemd/system/shadowsocks.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2017-12-21 23:51:48 CST; 11min ago
 Main PID: 19334 (ssserver)
   CGroup: /system.slice/shadowsocks.service
           └─19334 /usr/bin/python /usr/bin/ssserver -c /etc/shadowsocks/config.json
```

## 一键安装脚本
如果不想手动配置可以使用傻瓜式的一键安装脚本：
https://maode.github.io/2017/12/12/171212-Shadowsocks4-1/

## 参考
shadowsocks参考：
https://wiki.archlinux.org/index.php/Shadowsocks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.91.BD.E4.BB.A4.E8.A1.8C

Systemd参考：
http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html
http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html

（完）