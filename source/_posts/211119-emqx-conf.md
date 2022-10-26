---
title: emqx常用配置
date: Wed Oct 26 2020 11:30:05
tags:
	- emqx
---

```
******************************************************
	修改emqx_management监听端口
******************************************************
	emq2.0版本：找到etc/emqx.conf  对应Listener 配置位置增加：
	listener.api.mgmt = 127.0.0.1:8080
 
	emq3.0版本：找到etc/plugins/emqx_management.conf   

	修改配置项：management.listener.http = 8080
	
	

**************************************************
	etc/emq.conf
**************************************************
#关闭匿名认证
allow_anonymous = false
#设置所有 ACL 规则都不能匹配时是否允许访问:
acl_nomatch = deny
#设置存储 ACL 规则的默认文件
acl_file = etc/acl.conf
#开启/关闭TCP端口的监听(注释掉即可关闭端口监听)
#listener.tcp.external = 0.0.0.0:1883
#TLS 版本，防止 POODLE 攻击:
listener.ssl.external.tls_versions = tlsv1.2,tlsv1.1,tlsv1
#设置当前broker的server私钥(PEM编码)
listener.ssl.external.keyfile = D:\ssl_ca\server.key
#设置当前broker的server证书
listener.ssl.external.certfile = D:\ssl_ca\server.crt
#设置当前broker的CA证书
listener.ssl.external.cacertfile = D:\ssl_ca\ca.crt
#配置 verify 模式，服务器只在 verify_peer 模式下执行 x509 路径验证，并向客户端发送一个证书请求(开启SSL双向认证)
listener.ssl.external.verify = verify_peer
#服务器为 verify_peer 模式时，如果客户端没有要发送的证书，服务器是否返回失败.(值为false时可支持单向认证,不会报错)
listener.ssl.external.fail_if_no_peer_cert = false


******************************************************
	etc/plugins/emqx_management.conf
******************************************************
#设置管理应用(App)的默认密码,如果不设置会自动生成
management.application.default_secret = public #设置默认密码为public



*******************************************************************************************
	etc/acl.conf (默认访问控制设置`etc/acl.conf`,不支持自定义设置,如果想自定义访问控制必须使用插件)	
*******************************************************************************************
	----------------------------------------------------
	访问控制规则：
	
	允许(Allow)|拒绝(Deny) 谁(Who) 订阅(Subscribe)|发布(Publish) 主题列表(Topics)
	----------------------------------------------------

	可设置自定义访问控制的插件:
	emqx_auth_username	只支持链接认证,不支持访问控制
	emqx_auth_jwt		只支持链接认证,不支持访问控制
	emqx_auth_mysql		支持连接认证和访问控制
	emqx_auth_pgsql		支持连接认证和访问控制
	emqx_auth_redis		支持连接认证和访问控制
	还有很多其它的访问控制插件,详情参考文档中的"扩展插件"部分
	扩展插件文档:https://docs.emqx.io/broker/v3/cn/plugins.html#
	
** MQTT 客户端发起订阅/发布请求时，EMQ X 消息服务器的访问控制模块会逐条匹配 ACL 规则，直到匹配成功为止.

** 如果配置了多个访问控制插件,那么多个认证插件会组成认证链,按照优先级从高到低依次检查，同一优先级的，先启动的插件先检查。
   认证链中有任意一个插件规则拒绝了访问请求,则该访问请求被拒绝.(不知道哪个地方有插件优先级的介绍,文档中也没找到)
```


（完）


<!-- more -->



