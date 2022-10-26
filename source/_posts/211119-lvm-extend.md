---
title: lvm扩容步骤
date: Wed Oct 26 2022 16:42:20
tags:
	- lvm
---

1. 使用fdisk创建一个普通分区（也可以使用现有的硬盘分区或一整块硬盘），如：/dev/sda1 可以是主分区也可是逻辑分区,过程略。
   如果使用一整块硬盘的进行扩容的话，可以忽略分区过程，直接执行第三步创建物理卷。
2. 将 /dev/sda1 设置为lvm模式
```
# 对 /dev/sda 进行分区设置
fdisk /dev/sda
# 输入 t 改变分区的系统id
t
# 输入要改变的分区号，如 1
1
# 输入 L 可列出系统id的所有代码
L
# 输入lvm对应的代码 8e
8e
# 输入 w 使设置生效
w
# 如果分区表没有正常更新，可执行以下命令更新分区表
partx -a /dev/sdb
```
3. 将新建的lvm分区转化为PV（物理卷）。
```
# 将分区 /dev/sda1 转化为物理卷
pvcreate /dev/sda1

# 将硬盘 /dev/sda  转化为物理卷
pvcreate /dev/sda
```
4. 使用`df -h`命令，查看系统的挂载情况。确定要扩展的目录对应的挂载点
```
[root@bogon centos]# df -h
文件系统                 容量  已用  可用 已用% 挂载点
devtmpfs                  16G     0   16G    0% /dev
tmpfs                     16G     0   16G    0% /dev/shm
tmpfs                     16G   18M   16G    1% /run
tmpfs                     16G     0   16G    0% /sys/fs/cgroup
/dev/mapper/centos-root   56G  1.3G   55G    3% /
/dev/sdb5                178G   47G  122G   28% /data
/dev/sdb1                473M  143M  330M   31% /boot
tmpfs                    3.2G     0  3.2G    0% /run/user/0
/dev/sda1                3.6T  138G  3.3T    4% /data_slow

```
5. 比如我们要扩展根目录的空间，通过上面命令可以得知根目录的挂载点为`/dev/mapper/centos-root`，对应的逻辑卷即为`/dev/centos/root`，可以通过`lvdisplay`命令再进行一下确认。
```
[root@bogon centos]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/centos/root # 逻辑卷路径
  LV Name                root 
  VG Name                centos # 逻辑卷所属的卷组名称
  LV UUID                Fe5MNi-r0OW-exz7-dSWO-F9ZZ-kkeU-PLQ65v
  LV Write Access        read/write
  LV Creation host, time bogon, 2021-01-14 15:50:30 +0800
  LV Status              available
  # open                 1
  LV Size                <55.99 GiB
  Current LE             14333
  Segments               3
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

```
6. 将新转化的物理卷加入要扩展的卷组，加入后卷组的剩余可用空间变大。
```
# 此处的 centos 为 卷组名称，卷组的名称也可使用 vgdisplay 命令进行查看
vgextend centos /dev/sda1
```
7. 视情况，将想要扩展的容量分配给卷组中对应的lv（逻辑卷）。
```
# 将centos卷组的全部剩余空间分配给root逻辑卷
lvextend  /dev/centos/root
或
lvextend -l +100%FREE /dev/mapper/centos-root

# 从centos卷组的全部剩余空间中划分出10G分配给root逻辑卷
lvextend -L +10G /dev/centos/root
```
8. 刷新硬盘容量，使扩容生效
```
# xfs格式的文件系统使用该命令
xfs_growfs /dev/centos/root

# ext格式的文件系统使用该命令
resize2fs  /dev/centos/root
```


# lvm创建步骤
1. 同上面扩容的前3个步骤一样，先将硬盘或分区转化为PV（物理卷）
2. 使用PV（物理卷）创建VG（卷组），如此处使用PV `/dev/sdb` 和 `/dev/sdc` 创建了VG `storage`
```
vgcreate storage /dev/sdb /dev/sdc
```
3. 从卷组storage中创建一个名为vo的逻辑卷，其大小为150M
```
lvcreate -n vo -L 150M storage
```
4. 把生成好的逻辑卷进行格式化，然后挂载使用。
```
# 将逻辑卷格式化为ext4格式
mkfs.ext4 /dev/storage/vo 
# 创建挂载目录
mkdir /linuxprobe
# 挂载
mount /dev/storage/vo /linuxprobe
```
5. 将挂载信息写入`/etc/fstab`实现永久挂载
```
echo "/dev/storage/vo /linuxprobe ext4 defaults 0 0" >> /etc/fstab
```




# 附录

## 查看卷组（存储池）名称及使用情况
```
vgdisplay
```
## 查看逻辑卷（数据卷）空间状态
```
lvdisplay
```

# 参考
https://blog.csdn.net/u012439646/article/details/73380197
https://www.cnblogs.com/lenmom/p/9897739.html
https://www.linuxprobe.com/chapter-07.html#72_LVM

（完）
