---
title: harbor更新证书
date: Wed Oct 26 2022 16:10:38
tags:
	- harbor
---


### 首先创建证书存放目录,并进入该目录：
```
mkdir -p /data/cert && cd /data/cert
```

### 创建 CA 根证书（ca.key[ca私钥]和ca.crt[ca证书]）
```
openssl req  -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt -subj "/C=CN/L=Beijing/O=pkcfwd/CN=harbor-pkcfwd"
```

### 生成一个证书签名请求, 设置访问域名为 harbor.pkcfwd.com（harbor.pkcfwd.com.key[域名所代表的服务私钥]和harbor.pkcfwd.com.csr[域名所代表的服务请求文件]）
```
openssl req -newkey rsa:4096 -nodes -sha256 -keyout harbor.pkcfwd.com.key -out harbor.pkcfwd.com.csr -subj "/C=CN/L=Beijing/O=yhwt/CN=harbor.pkcfwd.com"
```

### 生成harbor.pkcfwd.com服务的证书（需要ca证书、ca私钥、服务签名请求共同生成）
```
openssl x509 -req -days 3650 -in harbor.pkcfwd.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out harbor.pkcfwd.com.crt
```

### 配置证书到harbor
进入k8s的harbor所在命名空间，找到名称为`harbor-harbor-ingress`的`secret`配置,将`harbor.pkcfwd.com.crt`的内容粘贴到`tls.crt`,将`harbor.pkcfwd.com.key`的内容粘贴到`tls.key`。
```
# 查看harbor.pkcfwd.com.crt的内容
cat harbor.pkcfwd.com.crt
# 查看harbor.pkcfwd.com.key的内容
cat harbor.pkcfwd.com.key
```

**最后**将harbor.pkcfwd.com.crt复制到需要访问harbor的主机,放入其域名对应的docker证书目录即可。如：`cd /etc/docker/certs.d/harbor.pkcfwd.com/`


（完）


