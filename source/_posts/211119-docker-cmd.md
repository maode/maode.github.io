---
title: docker常用命令
date: Wed Oct 26 2021 15:05:54
tags:
	- docker
---


# 一键安装docker和K8S

访问 https://kuboard.cn/install/install-k8s.html#%E5%AE%89%E8%A3%85docker%E5%8F%8Akubelet 确认并勾选7个复选框后，会出现一键安装自动脚步。复制并执行即可。

# 单独安装docker

安装别用“daocloud”的一键安装命令。他妈的不好使。
1. 安装阿里的镜像源，否则太慢。执行以下命令安装镜像源。
```
yum-config-manager \
--add-repo \
https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

```
2. 直接执行 `yum install docker-ce` 即可安装。（docker-ce中的`-ce`不能省略，否则会安装旧版本的`docker-io`）
3. 安装完成后执行 `docker -v` 查看安装结果。


# 单独安装k8s

复制下面的命令，从阿里镜像源安装K8S
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

```

# 靠谱镜像源    

docker hub靠谱镜像源(gdam3l是个人的加速器)
修改镜像源请新建或修改 `/etc/docker/daemon.json` 文件（如果目录不存在，先建目录）
修改为如下
```
{
"registry-mirrors": [
	"https://gdam3lme.mirror.aliyuncs.com",
	"https://75oltije.mirror.aliyuncs.com",
	"https://docker.mirrors.ustc.edu.cn/",
	"http://hub-mirror.c.163.com"
]
}
```


然后需重启docker，执行 `systemctl restart docker` 命令重启。

docker镜像的latest标签并不会自动更新，所以慎用，容易乱套。


# 制作镜像 commit export save

#通过dockerfile
`docker build -t imageName:version .`
如：  
`docker build -t zuihou/oauth-server:2.4.c1 --build-arg JAR_FILE=zuihou2.4.c1.dev/zuihou-oauth-server.jar .`
#将当前运行的容器制作成一个新的镜像（保留镜像层级历史记录，并将当前容器状态生成一个新的层级）
`docker commit containerID imageName:version`
#将当前运行的容器导出为快照（丢失所有层级记录）
`docker export containerID > xxx_snapshot.tar`
#将 export 的容器快照导入为新的镜像（新镜像启动容器时，命令最后必须加 /bin/bash）
`docker import xxx_snapshot.tar newImageName:version` 启动时必须加 /bin/bash 如：`docker run -d newImageName:version /bin/bash`
#将某个镜像导出为压缩包（方便多个机器离网状态下的镜像复制）
`docker save imageName:version > xxx_image.tar`
#将某个镜像压缩包导入为新镜像（可在机器离网状态下载入镜像）
`docker load < xxx_image.tar`

### docker save和docker export的区别

1. docker save保存的是镜像（image）,docker export保存的是容器（container)；

2. docker load用来载入镜像包，docker import用来载入容器包，但两者都会恢复为镜像；

3. docker load不能对载入的镜像重命名，而docker import可以为镜像指定新名称。

4. docker export的包会比save的包要小，原因是save的是一个分层的文件系统，export导出的只是一个linux系统的文件目录。

**更多镜像和容器的备份和迁移可参考：** https://blog.csdn.net/qq_44895681/article/details/106100061


# 为镜像打一个新的TAG（可用来修改镜像名称或版本）

`docker tag imageID newImageName:newTag`
或
`docker tag sourceImage[:tag] newImageName[:newTag]`




# 删除镜像的TAG

如果一个镜像设置错了tag可以用该命令删除错误的tag

`docker rmi imageName:imageTag`
		


# 删除镜像

`docker rmi imageID`
或
`docker rmi imageName:imageTag # 如果一个镜像设置错了tag可以用该命令删除错误的tag`



# 查看docker占用的磁盘空间

`docker system df`

# 清理docker占用的磁盘空间
***************************************************
1. 使用`docker system prune`命令  
  该指令默认会清除所有如下资源：
  - 已停止的容器（container）
  - 未被任何容器所使用的卷（volume）
  - 未被任何容器所关联的网络（network）
  - 所有悬空镜像（image）
  
 该指令默认只会清除悬空镜像，未被使用的镜像不会被删除。
 添加 -a 或 --all 参数后，可以一并清除所有未使用的镜像。
 可以添加 -f 或 --force 参数用以忽略相关告警确认信息。
 指令结尾处会显示总计清理释放的空间大小。
 
2. 使用可视化管理工具`portainer`


***************************************************

# 常用命令


```
#查看所有容器ID
docker ps -a -q
#stop停止所有容器
docker stop $(docker ps -a -q)
#remove删除所有容器
docker  rm $(docker ps -a -q)
#查看容器详情
docker inspect 容器名/ID
#进入容器内部
docker exec -it 容器名/ID bash
#查看容器日志(中括号表示可以省略)
docker [container] logs 容器id
#强制停止容器
docker kill 容器id
#删除正在运行的容器
docker rm -f 容器id
#查看[所有]容器的资源占用情况
docker stats [容器名/ID]
#查看容器在宿主机的PID
docker top 容器名/ID

#启动容器，并映射宿主机目录，使用宿主机的网卡（host网络模式）
docker run -v 宿主机目录1:容器目录1 -v 宿主机目录2:容器目录2 --network host  zuihou/file-server:2.4

#启动容器，在serversoft网卡启动并将22和3000端口绑定到宿主机的10022和10080端口
docker run -d --rm --net serversoft --name gogs -p 10022:22 -p 10080:3000 --restart always -v /data/gogs-data/:/data gogs/gogs:1.0
#启动容器，使用宿主机的网卡启动（host网络模式）
docker run -d --rm --network host  --name zuihou-oauth-server2.4.c1   -v /data/projects/logs/:/data/projects/logs/ zuihou/oauth-server:2.4.c1

#启动容器，并以交互模式进入容器内部执行bash命令
docker run -it --rm zuihou/oauth-server:2.4.c1 /bin/bash

#复制容器中的文件到外部宿主机（如果外部路径不存在会自动创建，如果外部路径存在，则复制到指定路径下）
docker cp 容器名/ID:容器文件 外部路径
#如：
docker cp dzzoffice:/var/www/html /data/dzzoffice-data
#复制外部宿主机文件到容器内部
docker cp 外部文件 容器名/ID:容器路径
#如：
docker cp /data/download/dzzoffice-2.02.1.tar.gz dzzoffice:/tmp

#查看docker中的所有网络
docker network ls

#为已启动的容器添加一个新的网络
docker network connect 网络名 容器名/ID

#容器启动时加入一个指定的网络
docker run ... --network 网络名 ....

#将当前启动的容器链接到另一个已启动的容器
docker run ... --link 容器名/ID ....

#清理所有停止的容器
docker container prune 

#清理所有不用数据(停止的容器,不使用的volume,不使用的networks,悬挂的镜像)
docker system prune -a

```



# docker-compose



```
# 显示命令帮助
docker-compose help

# 启动时指定compose文件
docker-compose -f xxx-compose.yml up

# 后台启动compose文件中编排的容器
docker-compose up -d

# 终止整个服务集合
docker-compose stop

# 终止指定的服务 （注意：启动的时候会先启动 depond_on 中的容器，但关闭的时候不会影响到 depond_on 中的容器）
docker-compose stop nginx

# 重启指定的服务
docker-compose restart 容器的服务名

# 持续查看容器的输出日志
docker-compose logs -f [services...]

# 构建镜像时不使用缓存（能避免很多因为缓存造成的问题）
docker-compose build --no-cache --force-rm

# 移除指定的容器
docker-compose rm nginx

# 停止并删除容器、网络、映像和卷
docker-compose down

# 版本3配置deploy项启动时开启兼容模式
docker-compose --compatibility up -d


```


# 不同容器之间共享数据卷和共享网络

共享网络：   
在compose文件中使用external属性，具体可参考官网文档。使用基本docker命令时，使用 --link,或提前创建网络，然后多个容器加入该网络。

共享数据卷：   
在compose文件中使用external属性，具体可参考官网文档。使用基本docker命令时，可提前创建数据卷，然后多个容器映射该数据卷。


（完）



