---
title: nginx常用命令
date: Wed Oct 26 2021 17:08:06
tags:
	- nginx
---

帮助命令：`nginx -h`

启动Nginx服务器 ：`sudo nginx`

查看进程： `ps aux | grep nginx`

配置文件路径：`/usr/local/nginx/conf/nginx.conf`

检查配置文件：`sudo nginx -t`

指定启动配置文件：`sudo nginx -c /usr/local/nginx/conf/nginx.conf`

暴力停止服务：`sudo nginx -s stop`

优雅停止服务：`sudo nginx -s quit`

重新加载配置文件：`sudo nginx -s reload`


# 关于server中的listen和server_name

listen：指定server要匹配的IP和端口。（如果指定了IP那么server_name的配置会失效，通常只指定端口）。
server_name：指定server要匹配的域名（也可以写IP地址），每个server_name之间用空格隔开。

# 关于server中的location和proxy_pass带不带斜杠（/）的问题

nginx转发时，`location`只是匹配规则，仅用来确定路径是否匹配，跟转发路径的拼接没有关系。
路径的拼接规则主要取决于`proxy_pass`指令中是否包含URI来决定。（URI是指一个请求去掉域名、IP、端口后，剩余的部分。如果去掉后还有字符串就表示包含URI）。

分两种情况：
1. 如果`proxy_pass`指令包含URI，当请求经过服务器时，匹配到`location`的那部分URI将被`proxy_pass`指令中的URI代替 （最终拼接为：proxy_pass+(path-location)）
2. 如果`proxy_pass`指令不包含URI，当请求经过服务器时，原始客户端请求将直接拼接在`proxy_pass`之后 （最终拼接为：proxy_pass+path）

以下这些`proxy_pass`都属于包含URI：
http://127.0.0.1:8080/
http://127.0.0.1:8080/app1
http://127.0.0.1:8080/app1/

详细的介绍和实验可参考：
https://www.cnblogs.com/yb38156/p/12173626.html
https://blog.csdn.net/u010433704/article/details/99945557


# 关于server代理本地静态资源root和alias的区别

root的结尾带不带`/`都可以，没有影响。
alias的即为必须带`/`，否则无效。
root指的是静态资源所在的根目录(path的上一级目录)，按照`location`规则匹配成功的请求，路径最终拼接为（root+path），即：请求的URI资源会拼接在指定的root目录之后。
alias指的是`location`匹配规则映射的路径，按照`location`规则匹配成功后的请求，最终路径拼接为（alias+(path-location)），即：请求的URI资源的匹配成功的部分会被alias替换。

详细的介绍和实验可参考：https://segmentfault.com/a/1190000015408906

# 关于default server

nginx 的 default_server 指令可以定义默认的 server 去处理一些没有匹配到 server_name 的请求，如果没有显式定义，则会选取第一个定义的 server 作为 default_server。
nginx 批量载入配置 conf 时会按 ascii 排序载入，这就会以 server_a.conf server_b.conf server_c.conf 的顺序载入，如果没有声明 default_server 的话，那 server_a 会作为默认的 server 去处理 未绑定域名/ip 的请求。
建议显式指定 default server，因为我们在配置虚拟主机或多业务时，会存有多个 server 配置文件，如果使用隐式方式选取第一个被载入的 server 作为 default server 的话，我们还要时刻去确认谁是被第一个载入的，容易产生不必要的麻烦和风险。

## 显式的定义一个 default server
```
http {
    server {
        listen 80;
        server_name www.a.com;
        ...
    }
    
    server {
        listen 80;
        server_name www.b.com;
        ...
    }
    
    # 显式的定义一个 default server
    server {
        listen 80 default_server;
        server_name _;
        return 403; # 403 forbidden
    }
    
}
```



（完）

