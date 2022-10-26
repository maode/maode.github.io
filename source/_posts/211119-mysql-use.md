---
title: mysql常用命令和相关知识点
date: Wed Oct 26 2022 16:44:09
tags:
	- mysql
---

### 修改最大连接数

```
#查看当前设置的最大连接数
show variables like '%max_connections%';
#查看当前单用户最大连接数
show variables like '%max_user_connections%';
# 查看数据库当前的连接数（Threads_connected ：这个数就是打开的连接数.）
show status like 'Threads%';
#临时修改最大连接数为2000（如果数据库重启会失效）
set global max_connections =2000;
#永久修改最大连接数为2000（数据库重启不会失效）
编辑`mysql.cnf`配置文件，在`[mysqld]`下方添加`max_connections=2000`
```

### 慢查询

```
#------ 开启/关闭 慢查询日志----
set GLOBAL slow_query_log = 'ON/OFF';
#------ 设置 慢查询日志 的阈值（秒，小数点后可精确到微秒）----
set GLOBAL long_query_time = 4.000000;
#------ 开启/关闭 记录没有使用索引的语句----
set GLOBAL log_queries_not_using_indexes = 'ON/OFF';
```

### 修改时区 

```
#查看mysql当前时区
show variables like '%time_zone%';
#设置全局时区
set global time_zone='Asia/Shanghai';
#设置当前时区
set  time_zone='Asia/Shanghai';
#刷新权限
flush privileges;
```


### 登录mysql

```
$ mysql -u root -p
$ 密码
```

### 连接远程数据库

```
mysql -uroot -proot -h192.168.0.333 -P3306   #（mysql -u用户名 -p密码 -h 远程主机 -P数据库端口。）密码如果包含特殊字符将密码用单引号扩起来，如：-p'test@&12345'
#展示所有数据库
show databases       
#选择数据库
use 数据库名         
#显示表结构
desc tableName       
#显示表的DDL语句
show create table tableName 

# 允许root远程登录
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '设一个密码' WITH GRANT OPTION;
```

### 创建用户

```
#创建用户‘htrace22’（`%`表示所有ip均可链接，可制定为具体的ip地址）
mysql> CREATE USER `htrace22`@`%` IDENTIFIED BY '密码';  

#创建用户‘hszk’并指定加密方式为'mysql_native_password'
mysql> CREATE USER 'hszk'@'%' IDENTIFIED WITH mysql_native_password   BY '密码';

# 创建一个普通用户（创建‘非super用户’常用命令）

mysql> CREATE USER 'temp'@'%' IDENTIFIED BY 'temp';

mysql> GRANT EXECUTE, PROCESS, SELECT, SHOW DATABASES, SHOW VIEW, ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, INDEX, INSERT, REFERENCES, TRIGGER, UPDATE, LOCK TABLES, RELOAD  ON *.* TO 'temp'@'%';
```






### 修改密码

```

'root'@'localhost'	#修改本机root用户的密码
'root'@'%'			#修改远程root用户的密码

#方式一
	#修改密码
	ALTER USER 'root'@'%' IDENTIFIED BY '新密码'; 
#方式二	
	#修改密码，同时修改加密方式为‘mysql_native_password’
	ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '新密码';
#方式三
	mysqladmin -u root -p password 新密码
	回车之后会要求让输入原始密码，然后就修改了密码。
	
#修改密码后如果不生效，请执行刷新权限的命令
	FLUSH PRIVILEGES;


#------修改用户密码的加密方式为mysql_native_password----------

mysql> ALTER USER 'htrace2'@'%' IDENTIFIED BY 'htrace@20182' PASSWORD EXPIRE NEVER;
mysql> ALTER USER 'htrace2'@'%' IDENTIFIED WITH mysql_native_password BY 'htrace@20182'; 
mysql> FLUSH PRIVILEGES;

```

### 用户查询、赋权、删除

```
#------查看所有用户------

mysql> use mysql；
mysql> select * from user;	


#------赋权限给用户----------

#授权‘htrace22’用户，拥有所有数据库的所有操作权限
mysql> GRANT ALL ON *.* TO `htrace22`@`%` WITH GRANT OPTION; 

#授权‘hszk’用户，拥有‘parkinglot’数据库的所有操作权限
mysql> GRANT ALL PRIVILEGES ON parkinglot.* TO 'hszk'@'%';

#------删除用户----------

mysql> DROP USER 'htrace2'@'%'
```

### 设置只读模式

```
# 设置普通用户只读模式（super用户可读写）
set global read_only=1;

# 解除普通用户只读模式
set global read_only=0;

# 设置所有用户只读模式（慎用，加锁后只能由当前会话解锁，否则只能杀会话进程或重启服务解锁。所有用户只读。详情可参考：https://segmentfault.com/a/1190000010539455）
set global read_only=1;
flush tables with read lock;

# 解除所有用户只读模式
set global read_only=0;
unlock tables;
```


### 查看mysql配置文件的路径

```
# linux
mysql --help | grep my.cnf 
# windows
mysql --help | findstr my.cnf
```

### mysql系统变量设置

如果是全局级别需要加GLOBAL，如果是会话级别需要加SESSION。如果什么都不写，默认是SESSION。      
**全局变量的作用域：** 修改全局变量后，针对后续创建的所有会话（连接）有效。服务重启后失效。     
**会话变量的作用域：** 仅仅针对当前的会话（连接）有效。    
**服务器的配置文件：** 永久有效，如果修改了，需重启服务才能生效。      
**修改mysql系统变量不重启服务的方式：** 依次修改 当前所有会话变量、全局变量、配置文件,这样就能保证当前会话、后续会话、及服务重启后，系统变量都能生效的效果。   

```
-- 查看mysql版本
SHOW GLOBAL VARIABLES LIKE '%version%';
-- 显示所有全局变量
SHOW GLOBAL VARIABLES;
-- 显示所有会话变量
SHOW SESSION VARIABLES;
-- 查看满足模糊条件的部分全局变量
SHOW GLOBAL VARIABLES LIKE '%character%';
-- 查看满足模糊条件的部分会话变量
SHOW SESSION VARIABLES LIKE '%character%';
-- 查看某个指定的全局变量
SELECT @@GLOBAL.系统变量名;
-- 查看某个指定的会话变量
SELECT @@SESSION.系统变量名;
-- 为全局变量设置值
SET GLOBAL 系统变量名 = 值;
-- 为会话变量设置值
SET SESSION 系统变量名 = 值;
-- 为全局变量设置值
SET @@GLOBAL.系统变量名 = 值;
-- 为会话变量设置值
SET @@SESSION.系统变量名 = 值;

```

### binlog常用参数介绍

`binlog_rows_query_log_events=1`   
在row模式下开启该参数,将把sql语句打印到binlog日志里面.默认是0(off);

`binlog_row_image=FULL`   
在binlog为row格式下,full将记录update前后所有字段的值,binlog增长速度较快,对存储空间,主从传输都是一个不小的压力。minimal时,只记录更改字段的值和where字段的值,noblob时,记录除了blob和text的所有字段的值,如果update的blob或text字段,也只记录该字段更改后的值,更改前的不记录;默认为full。（只有值为full时，才能通过binlog进行数据恢复）

在mysql中查询当前二进制日志列表：`SHOW BINARY LOGS;`或`SHOW MASTER LOGS;`


### mysqlbinlog命令介绍

**一条示例命令：** `mysqlbinlog /data/mysql_data/bin.000008 --database EpointFrame --base64-output=decode-rows -vv --skip-gtids=true --start-datetime="2016-09-25 21:57:19"   |grep -C 1 -i “delete from Audit_Orga_Specialtype” > /opt/sql.log`  
**-v 参数：** 显示sql语句    
**-vv 参数：** 显示sql语句和字段类型    
**--base64-output参数：** 用来控制binlog部分是否显示出来的，指定为decode-rows表示不显示binglog部分（加了该参数后导出的binlog文件将不能用来进行数据恢复）    
**grep -C 1** 显示符合查询条件的当前行，及该行前后各一行的数据  
**grep -i**  查询时忽略大小写  

### 通过mysqlbinlog恢复数据方法

1. 在备份时使用`--master-data=2` 参数，在备份语句里添加CHANGE MASTER语句以及binlog文件及位置点信息。如：`mysqldump -uroot -p -B -F -R -x --master-data=2 ops|gzip >/opt/backup/ops_$(date +%F).sql.gz`
2. 通过最新的备份文件还原数据库，如：`mysql --host=host_name -u root -p < dump_file`
3. 使用`grep`命令从备份文件中找到备份时对应的binlog位置，如：`grep CHANGE ops_2016-09-25.sql ` 从dump_file中找到-- CHANGE MASTER TO MASTER_LOG_FILE=‘binlog.001002’, MASTER_LOG_POS=27284;
4. 通过以上几步，已经将数据库还原到了binlog的binlog.001002对应的27284位置，然后再通过mysqlbinlog命令对27284位置之后的数据进行增量恢复即可。如：`mysqlbinlog --start-position=27284 binlog.001002 binlog.001003 binlog.001004 | mysql --host=host_name -u root -p`。如果想恢复到指定的时间点也可以通过设置`--stop-position=binlog截止位置`实现。另外如果想恢复某个时间段的数据也可以使用时间戳参数进行恢复，如：`--start-datetime="2016-09-25 21:57:19" --stop-datetime="2016-09-25 21:58:41"`。

（完）

