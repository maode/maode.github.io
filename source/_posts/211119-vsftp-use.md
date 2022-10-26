---
title: vsftp容器启动并内网穿透注意事项
date: Wed Oct 26 2022 17:11:07
tags:
	- vsftp
---


使用镜像：fauria/vsftpd

# 基本用法

1. 要开启被动模式，默认应该是开启的`PASV_ENABLE=true`
2. 设置被动模式下，使用哪些端口进行数据传输`PASV_MIN_PORT`和`PASV_MAX_PORT`，此处的端口范围决定了同时在线数的大小，每一个连接时会占用一个端口。  
   **注意：** `PASV_MIN_PORT`和`PASV_MAX_PORT`的端口范围，必须要 容器，宿主机，外网服务器（穿透服务所在的主机） 三者保持相同。否则无法正常映射。
3. 将21端口随便映射一个端口，用于用户连接。
4. 设置用户上传文件的默认权限码为`022`。   
5. 指定被动模式下使用的IP地址为外网服务器地址，即穿透服务所在的主机的地址`PASV_ADDRESS=139.198.16.241`。（如果不指定，默认会绑定容器的路由IP）   
6. 挂载宿主机的一个目录到vsftp的用户目录，如:`-v /data/ftptest:/home/vsftpd/user1 `。该命令代表user1用户登陆后使用的主目录映射到宿主机的`/data/ftptest`目录。

# 添加用户

如果添加新的用户，要进入容器内部进行添加，然后参考步骤6的方式，将宿主机的某个目录映射到新用户的主目录即可。
```
docker exec -i -t vsftpd bash
mkdir /home/vsftpd/myuser
echo -e "myuser\nmypass" >> /etc/vsftpd/virtual_users.txt # 注意 用户名和密码之间有个\n
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
exit
docker restart vsftpd
```

#权限码说明
   
| 权限码 | 文件夹上传后的权限 | 文件上传后的权限 |
| ------ | ------------------ | ---------------- |
| 077    | 700                | 600              |
| 022    | 755                | 644              |

（完）
