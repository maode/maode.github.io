---
title: mysql备份和恢复
date: Wed Oct 26 2022 16:43:18
tags:
	- mysql
---

1. mysql恢复时，恢复几个数据库取决于备份文件中包含了几个库的备份，还原命令本身不支持从多个库的备份文件中只恢复某一个数据库。（除非备份时，只备份了一个）
2. 备份时如果使用了 `-A` 或 `-B` 参数，指定了数据库，则备份文件中会包含 `CREATE DATABASE` 和 `use database` 语句。恢复时不需要指定数据库。否则需要指定恢复到哪个库，并且该库要提前创建好。
3. 因为不使用 `-B` 参数时，备份文件中不包含数据库名相关信息，因此利用该特性，也可以将该备份还原到别的数据库名。（还原时指定要还原到的数据库名即可）。


# 备份前和恢复完成后的操作（可选）

根据实际情况，可设置普通用户或所有用户只读。等还原完成后，再进行对应的解除操作。

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


# 使用 -B 参数备份和还原数据库（导出的备份文件会包含建库语句）

```
# 使用 -B 参数，备份数据库 t1
mysqldump -uroot -proot -h192.168.1.66 -P31306 -B t1 > t1.bk.sql
# 还原数据库 t1
mysql -uroot -proot -h192.168.1.66 -P31306 < t1.bk.sql
```


# 不使用 -B 参数备份和还原数据库（导出的备份文件不包含建库语句）

```
# 不使用 -B 参数，备份数据库 t1
mysqldump -uroot -proot -h192.168.1.66 -P31306 t1 > t1.bk.sql
# 还原数据库 t1（数据库 t1 必须要提前创建好，并且在语句中指定该库名）
mysql -uroot -proot -h192.168.1.66 -P31306 t1 < t1.bk.sql
# 因为不使用 -B 参数时，备份文件中不包含数据库名相关信息，因此也可以将该备份还原到别的数据库名。如下例将数据库t1的备份还原到数据库t2
mysql -uroot -proot -h192.168.1.66 -P31306 t2 < t1.bk.sql
```


# mysqldump 选项介绍

```
 -A --all-databases：导出全部数据库
 -Y --all-tablespaces：导出全部表空间
 -y --no-tablespaces：不导出任何表空间信息
 --add-drop-database每个数据库创建之前添加drop数据库语句。
 --add-drop-table每个数据表创建之前添加drop数据表语句。(默认为打开状态，使用--skip-add-drop-table取消选项)
 --add-locks在每个表导出之前增加LOCK TABLES并且之后UNLOCK TABLE。(默认为打开状态，使用--skip-add-locks取消选项)
 --comments附加注释信息。默认为打开，可以用--skip-comments取消
 --compact导出更少的输出信息(用于调试)。去掉注释和头尾等结构。可以使用选项：--skip-add-drop-table --skip-add-locks --skip-comments --skip-disable-keys
 -c --complete-insert：使用完整的insert语句(包含列名称)。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。
 -C --compress：在客户端和服务器之间启用压缩传递所有信息
 -B--databases：导出几个数据库。参数后面所有名字参量都被看作数据库名。
 --debug输出debug信息，用于调试。默认值为：d:t:o,/tmp/
 --debug-info输出调试信息并退出
 --default-character-set设置默认字符集，默认值为utf8
 --delayed-insert采用延时插入方式（INSERT DELAYED）导出数据
 -E--events：导出事件。
 --master-data：在备份文件中写入备份时对应的binlog文件，在恢复时，增量数据从这个文件之后的日志开始恢复。值为1时，binlog文件名和位置没有注释，为2时，则在备份文件中将binlog的文件名和位置进行注释
 --flush-logs开始导出之前刷新日志。请注意：假如一次导出多个数据库(使用选项--databases或者--all-databases)，将会逐个数据库刷新日志。除使用--lock-all-tables或者--master-data外。在这种情况下，日志将会被刷新一次，相应的所以表同时被锁定。因此，如果打算同时导出和刷新日志应该使用--lock-all-tables 或者--master-data 和--flush-logs。
 --flush-privileges在导出mysql数据库之后，发出一条FLUSH PRIVILEGES 语句。为了正确恢复，该选项应该用于导出mysql数据库和依赖mysql数据库数据的任何时候。
 --force在导出过程中忽略出现的SQL错误。
 -h --host：需要导出的主机信息
 --ignore-table不导出指定表。指定忽略多个表时，需要重复多次，每次一个表。每个表必须同时指定数据库和表名。例如：--ignore-table=database.table1 --ignore-table=database.table2 ……
 -x --lock-all-tables：提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭--single-transaction 和--lock-tables 选项。
 -l --lock-tables：开始导出前，锁定所有表。用READ LOCAL锁定表以允许MyISAM表并行插入。对于支持事务的表例如InnoDB和BDB，--single-transaction是一个更好的选择，因为它根本不需要锁定表。请注意当导出多个数据库时，--lock-tables分别为每个数据库锁定表。因此，该选项不能保证导出文件中的表在数据库之间的逻辑一致性。不同数据库表的导出状态可以完全不同。
 --single-transaction：适合innodb事务数据库的备份。保证备份的一致性，原理是设定本次会话的隔离级别为Repeatable read，来保证本次会话（也就是dump）时，不会看到其它会话已经提交了的数据。
 -F：刷新binlog，如果binlog打开了，-F参数会在备份时自动刷新binlog进行切换。
 -n --no-create-db：只导出数据，而不添加CREATE DATABASE 语句。
 -t --no-create-info：只导出数据，而不添加CREATE TABLE 语句。
 -d --no-data：不导出任何数据，只导出数据库表结构。
 -p --password：连接数据库密码
 -P --port：连接数据库端口号
 -u --user：指定连接的用户名。
```

（完）
