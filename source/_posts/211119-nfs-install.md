---
title: nfs搭建和常用命令
date: Wed Oct 26 2022 17:05:38
tags:
	- nfs
---


# 配置NFS服务器

- 执行` yum install nfs-utils rpcbind -y`安装nfs环境。`rpcbind`是依赖。（Debian系执行命令：`apt install nfs-kernel-server`）
- 执行 `mkdir /root/nfs_root` 创建共享目录。（目录名随意，这里只是个例子）。
- 执行命令 `vim /etc/exports`，创建 exports 文件，文件内容如下:
  ```
  /root/nfs_root/ *(insecure,rw,sync,no_root_squash) # `*` 表示允许所有IP挂载，可以指定为具体的IP或CIDR网段。括号中的参数具体含义参考最后的表格
  ``` 
- 启动`rpc`和`nfs`服务，并设置为开机启动。命令如下：
  ```
  # 开机启动
  systemctl enable rpcbind
  systemctl enable nfs-server
  # 启动服务
  systemctl start rpcbind
  systemctl start nfs-server # nfs 启动后的status为 `active (exited) ` 是正常现象。因为该服务不需要常驻，只需运行一次便可。
  # 重新加载配置
  systemctl reload nfs-server 
  或
  exportfs -r
  ```  
- 检查配置是否生效，执行`exportfs`命令。如果输出刚才配置的目录，说明已生效。
- 服务器端防火墙开放111、662、875、892、2049的 tcp / udp 允许，否则远端客户无法连接。

# 在客户端测试nfs
- 执行以下命令安装 nfs 客户端所需的软件包。
  ```
  yum install -y nfs-utils #Debian系执行命令：apt install nfs-common
  ```
- 执行以下命令检查 nfs 服务器端是否有设置共享目录。（showmount用法参考最后的表格）
  ```
  # showmount -e $(nfs服务器的IP)
  showmount -e 172.17.216.82
  # 输出结果如下所示
  Export list for 172.17.216.82:
  /root/nfs_root *
  ```
- 执行以下命令挂载 nfs 服务器上的共享目录到本机路径 `/root/nfsmount`
  ```
  mkdir /root/nfsmount
  # mount -t nfs $(nfs服务器的IP):/root/nfs_root /root/nfsmount
  mount -t nfs 172.17.216.82:/root/nfs_root /root/nfsmount
  # 写入一个测试文件
  echo "hello nfs server" > /root/nfsmount/test.txt
  ```
- 登录 nfs 服务器，在 nfs 服务器上执行以下命令，验证文件是否写入成功
  ```
  cat /root/nfs_root/test.txt
  ```

# 附录

- NFS服务程序配置文件的参数：  

  | 参数 | 作用 |
  | - | - |
  | ro | 只读 |
  | rw | 读写 |
  | root_squash（默认） | 当NFS客户端以root管理员访问时，映射为NFS服务器的匿名用户 |
  | no_root_squash | 当NFS客户端以root管理员访问时，映射为NFS服务器的root管理员 |
  | all_squash | 无论NFS客户端使用什么账户访问，均映射为NFS服务器的匿名用户 |
  | no_all_squash（默认）| 访问用户先与本机用户匹配，匹配失败后再映射为匿名用户或用户组 |
  | sync | 同时将数据写入到内存与硬盘中，保证不丢失数据 |
  | async | 优先将数据保存到内存，然后再写入硬盘；这样效率更高，但可能会丢失数据 |
  | insecure | 非安全模式，允许客户端使用大于1024的端口进行挂载。默认不开启。与`secure`作用相反 |
  | secure（默认） | 安全模式，不允许客户端使用大于1024的端口进行挂载。默认开启。与`insecure`作用相反 |
  | wdelay（默认） | 检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率 |
  | no_wdelay | 若有写操作则立即执行，应与sync配合使用 |
  | subtree_check  | 若输出目录是一个子目录，则nfs服务器将检查其父目录的权限 |
  | no_subtree_check（默认）  | 即使输出目录是一个子目录，nfs服务器也不检查其父目录的权限，这样可以提高效率 |

  更详细的介绍可参考： https://www.golinuxcloud.com/unix-linux-nfs-mount-options-example/  

- showmount 命令的用法：

  | 参数 | 作用 |
  | - | - |
  | -e | 显示NFS服务器的共享列表 |
  | -a | 显示本机挂载的文件资源的情况NFS资源的情况 |
  | -v | 显示版本号 |

- 允许多个网段或多个IP的客户端挂载
  ```
  # 下面的配置，表示 /backup 允许172.27.34.0/24和172.27.34.0/24两个网段访问
  [root@centos7 /]# view /etc/exports
  /backup 172.27.34.0/24(rw,sync,no_root_squash)
  /backup 172.27.9.0/24(rw,sync,no_root_squash)  
  ```
  ```
  # 下面的配置，表示 /backup 允许172.27.9.17、172.27.9.227、172.27.34.37 IP地址访问
  [root@centos7 /]# view /etc/exports
  /backup  172.27.9.17(rw,sync,no_root_squash) 172.27.9.227(rw,sync,no_root_squash) 172.27.34.37(rw,sync,no_root_squash)
  ```

（完）
