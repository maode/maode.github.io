---
title: mysql通过binlog恢复数据
date: Wed Oct 26 2022 16:58:39
tags:
	- mysql
---


前提：
1. 有最近的数据库全备文件。
2. 数据库开启了 binlog,且`binlog_row_image=FULL` `binlog_format = row`

# 相关命令

```
# 查看binlog的开启状态和存放路径
show variables like '%log_bin%';

# 查看所有binlog日志文件列表
show master logs;

# 查看最后一个binlog日志的编号名称及其最后一个操作事件pos结束点的值
show master status; 

# 查看某个binlog日志文件的详情（binlog.000105为对应的日志文件名）
show binlog events in 'binlog.000105';

# 查看某个binlog日志文件的详情，从pos点:8224开始查起，查询10条（binlog.000105为对应的日志文件名）
show binlog events in 'binlog.000105' from 8224 limit 10;

# 刷新日志，此刻开始产生一个新编号的binlog文件(每当mysqld服务重启时，会自动执行刷新binlog日志命令，mysqldump备份数据时加-F选项也会刷新binlog日志)
flush logs;

# 删除 binlog.000058 之前的所有binlog
purge master logs to 'binlog.000058';  

# 删除指定日期之前的所有binlog
purge master logs before '2020-02-01 03:00:00';  

# 清空所有binlog日志命令(慎用！！！)
reset master;

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

# 备份数据库

## 实例全备（该mysql实例的所有数据库都备份到一个文件）
```
mysqldump -uroot -proot -h192.168.1.66 -P31306 -A -F -R -E \
--triggers --hex-blob --flush-privileges --single-transaction --master-data=1 > test-all-bk-0416.sql
```
缩写说明（逗号前后的指令含义相同）：
-A, --all-databases
-F, --flush-logs
-E, --events 
-B, --databases #如果要备份指定的几个库，请将 `-B` 作为命令的最后一个参数。（`-B` 参数和重定向符 `>` 之间的所有参数都会被认为是要备份的库名）
-x, --lock-all-tables
-l, --lock-tables
-R, --routines  

-h, --host=value 
-u, --user=value
-p, --password[=value]
-P, --port=#
-n, --no-create-db 只导出数据，而不添加CREATE DATABASE 语句。
-t, --no-create-info 只导出数据，而不添加CREATE TABLE 语句。
-d, --no-data 不导出任何数据，只导出数据库表结构
--add-drop-database 每个数据库创建之前添加drop数据库语句。
--add-drop-table 每个数据表创建之前添加drop数据表语句。(默认为打开状态，使用--skip-add-drop-table取消选项)
--add-locks 在每个表导出之前增加LOCK TABLES并且之后UNLOCK TABLE。(默认为打开状态，使用--skip-add-locks取消选项)
--single-transaction 适合innodb事务数据库的备份。保证备份的一致性，原理是设定本次会话的隔离级别为Repeatable read，来保证本次会话（也就是dump）时，不会看到其它会话已经提交了的数据。
--master-data 在备份文件中写入备份时的binlog文件，在恢复进，增量数据从这个文件之后的日志开始恢复。值为1时，binlog文件名和位置没有注释，为2时，则在备份文件中将binlog的文件名和位置进行注释



## 分库全备（为mysql实例的每个库备份为一个文件）
```
for dbname in ` mysql -uroot -p'123456' -e "show databases;" | grep -Evi "database|infor|perfor"`
do
    mysqldump -uroot -proot -h192.168.1.66 -P31306 -F -R -E \
    --triggers --hex-blob --flush-privileges --single-transaction --master-data=1 \
    -B ${dbname} | gzip >/opt/backup/${dbname}_$(date +%F).sql.gz
done
```

# 通过备份文件和binlog恢复数据库
如果发生了误删或误增数据、数据库。可以按照以下步骤进行恢复。

1. 先将数据库实例设为全局只读（防止有人继续增删改数据）
```
# 设置所有普通用户只读模式
set global read_only=1;
```

2. 查看当前最新的binlog日志文件（如果每天都有自动备份，很大概率要使用该binlog文件恢复全备之后到误删之间时间段的数据。如果没有每天备份，那么可能需要不止这一个binlog文件。具体视情况而定）
```
show master status;
mysql> show master status;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000099 | 20042489 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

3. 刷新binlog日志，产生一个新的binlog日志文件（防止还原数据操作污染当前的binlog日志，如不刷新，也可将binlog备份一下也行）
```
flush logs;
```

4. 先通过全备文件恢复数据库到备份的时间点（全备只能全恢复，如果要恢复单个库，可以使用单备单恢复方式，或者将指定数据库的备份语句从全备文件中提取出来，具体可参考本文后面章节）
```
# 通过全备文件还原该mysql实例的所有数据库
mysql -uroot -p123456 < /mnt/all-db_bak.sql
```

5. 查看备份文件备份时对应的binlog位置。（还原时将以该位置作为`--start-position`）
```
root@db-tmp-mysql57:/# cat /all-db.bksql | grep -i 'CHANGE MASTER TO MASTER_LOG_FILE' | head -n1
CHANGE MASTER TO MASTER_LOG_FILE='1.000004', MASTER_LOG_POS=154;
```

6. 查询误删数据前对应的binlog位置。（如：此处使用`grep`以`DELETE`作为关键字检索，具体视情况而定）
```
root@db-tmp-mysql57:/# mysql -uroot -proot -e "show binlog events in '1.000004'" | grep -i 'DELETE'
mysql: [Warning] Using a password on the command line interface can be insecure.
1.000004        1973    Rows_query      1       2082    # /* ApplicationName=DataGrip 2020.3.1 */ DELETE FROM `test-db3`.table_3 WHERE id = 333
1.000004        2139    Delete_rows     1       2193    table_id: 257 flags: STMT_END_F
1.000004        2193    Rows_query      1       2301    # /* ApplicationName=DataGrip 2020.3.1 */ DELETE FROM `test-db3`.table_3 WHERE id = 33
1.000004        2358    Delete_rows     1       2402    table_id: 257 flags: STMT_END_F
1.000004        2402    Rows_query      1       2509    # /* ApplicationName=DataGrip 2020.3.1 */ DELETE FROM `test-db3`.table_3 WHERE id = 3
1.000004        2566    Delete_rows     1       2609    table_id: 257 flags: STMT_END_F
1.000004        2609    Rows_query      1       2718    # /* ApplicationName=DataGrip 2020.3.1 */ DELETE FROM `test-db3`.table_3 WHERE id = 334
1.000004        2775    Delete_rows     1       2830    table_id: 257 flags: STMT_END_F
```

7. 根据以上操作能够确定我们的全备文件内容对应binlog文件`1.000004`的`154`位置，而我们误删数据是在`1.000004`的`1973`位置。所以在我们通过全备文件还原数据库后，即代表我们的数据库状态已经恢复到了binlog文件`1.000004`的`154`位置。此时我们将`154`至`1973`之间的数据通过binlog还原，即可让数据库恢复到，误删数据前的状态。命令如下：
```
root@db-tmp-mysql57:/# mysqlbinlog  --start-position=1003 --stop-position=1973 1.000004 | mysql -uroot -proot
mysql: [Warning] Using a password on the command line interface can be insecure. # 如果在命令中指定密码，会收该条警告。
```

8. 通过mysqlbinlog恢复数据，可以只恢复指定的数据库，通过 -d 参数指定即可。如只恢复 test-db3 数据库，则命令如下：
```
root@db-tmp-mysql57:/# mysqlbinlog  -d test-db3 --start-position=1003 --stop-position=1973 1.000004 | mysql -uroot -proot
mysql: [Warning] Using a password on the command line interface can be insecure. # 如果在命令中指定密码，会收该条警告。
```

9. 因为通过binlog恢复数据，本质上是通过回放binlog文件中记录的SQL语句来进行的恢复。所以，可以通过，如：`--stop-position=1 --stop-position=100`或`--start-datetime="2016-09-25 21:57:19" --stop-datetime="2016-09-25 21:58:41`参数来回放任意区间的SQL，实现对指定操作位置区间、指定时间段的数据恢复，可根据情况灵活使用。比如上面的例子中，如果在误删数据后，又插入了新的数据，那么想要跳过误删操作，将误删之后添加的数据也进行还原。则可以找出误删数据的截止点，如`2775`,然后将`2775`之后操作也通过binlog进行回放，则可将误删前和误删后的数据都还原。如：
```
# 将误删操作之后新增的数据也还原到 test-db3 数据库
root@db-tmp-mysql57:/# mysqlbinlog  -d test-db3 --start-position=2775 1.000004 | mysql -uroot -proot
mysql: [Warning] Using a password on the command line interface can be insecure. # 如果在命令中指定密码，会收该条警告。
```

10. 以上过程都是基于单个 binlog 文件进行的数据恢复。如果我们要恢复的操作涉及到多个binlog文件，则将多个binlog文件用空格隔开即可。如：备份文件是很长时间之前的，在这段时间binlog日志已经滚存了好几个文件了。这个时候在通过备份文件还原后，就要重放好几个binlog文件才能使数据库恢复到最新的状态。如：
```
mysqlbinlog  --start-position=27284 binlog.001002 binlog.001003 binlog.001004 | mysql --host=host_name -u root -p
```

11. 数据还原成功后，可将数据库做一次全新的全备，然后通过下方的SQL命令，清空老旧的binlog日志释放磁盘空间（推荐）。
```
# 刷新binlog日志，产生一个新的binlog日志文件
flush logs;
# 查看当前正在使用的binlog日志
show master status;
# 删除 binlog.000058 之前的所有binlog
purge master logs to 'binlog.000058';  
```
12. 如果通过远程binlog还原远程数据库，则在命令中添加相关的远程地址、端口和` --read-from-remote-server`（或`-R`）选项即可，如果binlog已经拷贝到本地，则不需加该选项。如：
```
mysqlbinlog -uroot -pserver,test@pass -h192.168.1.66 -P31306 --read-from-remote-server -d test-db3 --start-position=1003 --stop-position=1973 1.000004 | mysql -uroot -pserver,test@pass -h192.168.1.66 -P31306

```

13. 如果想要审阅将binlog文件中的日志（如：查找一些关键操作），可将其解析易于阅读的格式，如：
```
# 将本地/data/mysql_data/bin.000008文件中针对EpointFrame数据库09-25 21:57:19之后的操作，解析成易读格式并输出到本地 /opt/sql.log 文件
mysqlbinlog /data/mysql_data/bin.000008 --database EpointFrame --base64-output=decode-rows -vv  --start-datetime="2016-09-25 21:57:19"   |grep -C 1 -i “delete from Audit_Orga_Specialtype” > /opt/sql.log
# 将远程mysql的 binlog.000099 文件中针对zuihou_base_0000数据库4月14号之后的操作，解析成易读格式输出到本地根目录下的 wwp2.binlog 文件
mysqlbinlog -uroot -pserver,test@pass -h192.168.1.66 -P31306 --read-from-remote-server binlog.000099 --base64-output=decode-rows -vv  --start-datetime="2021-04-14 00:00:00" -d zuihou_base_0000 > /wwp2.binlog
```

参数解释：

**-v 参数：** 显示sql语句  
**-vv 参数：** 显示sql语句和字段类型  
**--base64-output参数：** 用来控制binlog部分是否显示出来的，指定为decode-rows表示不显示binglog部分  
**grep -C 1** 显示符合查询条件的当前行，及该行前后各一行的数据
**grep -i**  查询时忽略大小写

## mysqlbinlog --no-defaults --skip-gtids=true

是否使用--skip-gtids=true 参数，要根据情况来定；   
第一种情况：   
如果我们是要恢复数据到源数据库或者和源数据库有相同 GTID 信息的实例，那么就要使用该参数。如果不带该参数的话，是无法恢复成功的。因为包含的 GTID 已经在源数据库执行过了，根据 GTID 特性，一个 GTID 信息在一个数据库只能执行一次，所以不会恢复成功。

第二种情况：    
如果是恢复到其他实例的数据库并且不包含源实例的 GTID 信息，那么可以不使用该参数，使用或者不使用都可以恢复成功。 

一般如果我们基于全备文件和干净的binlog日志（未被还原操作污染过的binlog）进行数据还原时，都不需要加 --skip-gtids=true 参数。

是否使用--no-defaults参数：   
如果命令报错 mysqlbinlog: [ERROR] unknown variable 'default-character-set=utf8mb4' 则可以使用 --no-defaults 跳过该错误。

## 从全备文件中提取单备文件

从全备文件中提取单备文件（从所有数据库备份文件中提取出其中一个数据库的备份文件）
```
# 从全备文件中提取某一个数据库的备份文件（下面示例语句从全备文件中提取test-db3数据库的备份内容到一个新的单备文件）
sed -n '/^-- Current Database: `test-db3`/,/^-- Current Database: `/p' 0420-temp-all.bksql > 0420-temp-test-db3.bksql

# 通过单备文件还原test-db3数据库
mysql -uroot -p123456 < /0420-temp-test-db3.bksql
```
**注意：** 如果单备文件是手动从全备提取的，为保证顺利还原，请将全备文件头部和底部的注释，复制到提取出的单备文件中。可避免timestamp类型字段还原后，时间错误问题。如果不是手动提取的，则不用关心。
注释内容大致如下：
```
# 将以下内容从全备文件的头部复制到手动提取的单备文件头部
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!50606 SET @OLD_INNODB_STATS_AUTO_RECALC=@@INNODB_STATS_AUTO_RECALC */;
/*!50606 SET GLOBAL INNODB_STATS_AUTO_RECALC=OFF */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# 将以下内容从全备文件的尾部复制到手动提取的单备文件尾部
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!50606 SET GLOBAL INNODB_STATS_AUTO_RECALC=@OLD_INNODB_STATS_AUTO_RECALC */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-04-20 11:53:40
```
## 从全备或单备文件中提取单表的备份数据

1. 从全备份中提取出该表的建表语句
```
sed -e'/./{H;$!d;}' -e 'x;/CREATE TABLE `user_online`/!d;q' all_database_bak_471_2017-12-04_15_36_38.sql > user_online.sql &
```
2. 提取该表的insert into语句
```
grep -i 'INSERT INTO `user_online`'  all_database_bak_471_2017-12-04_15_36_38.sql >> user_online.sql & 
```
3. 将全备文件头部和底部的注释，复制到提取出的单表备份文件中
注释内容大致如下：
```
# 将以下内容从全备文件的头部复制到手动提取的单表备份文件头部
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!50606 SET @OLD_INNODB_STATS_AUTO_RECALC=@@INNODB_STATS_AUTO_RECALC */;
/*!50606 SET GLOBAL INNODB_STATS_AUTO_RECALC=OFF */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# 将以下内容从全备文件的尾部复制到手动提取的单表备份文件尾部
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!50606 SET GLOBAL INNODB_STATS_AUTO_RECALC=@OLD_INNODB_STATS_AUTO_RECALC */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-04-20 11:53:40
```
4. 导入到对应的库中
```
mysql -uroot -p < user_online.sql
```
5. 查看数据，检查导入效果
```
mysql> select count(*) from user_online;
+----------+
| count(*) |
+----------+
|        9 |
+----------+
1 row in set (0.01 sec)

# 已经恢复完毕
```



（完）
