---
title: mysql定期备份脚本
date: Wed Oct 26 2022 16:55:24
tags:
	- mysql
---

### mysql定期全量加增量备份脚本

```bash
#!/bin/bash
##########################################################
#        数据库自动备份脚本（仅支持数据库服务在本机）            #
##########################################################
# 备份策略：                          #
# 7天1全备，1天1增备，每次增备时都会     #
# 清空14天之前的binlog(可按需调整)      #
#####################################
# 可以将下面这段被注释的语句保存为一个测试脚本进行测试。
# 该测试逻辑，是通过循环修改系统时间，模拟一个月的备份过程。
########测试脚本-START##########
# #!/bin/bash
# for day in {1..30}
# do
#    date -s "2021-04-$day 12:00:00"
#    /bin/bash 当前备份脚本.sh
# done
########测试脚本-END############
# 可以通过下面这段命令，使用crontab将备份脚本加入定时任务
########使用crontab将脚本加入定时任务-START#######
# crontab -e
# 0 3 * * *  /bin/bash 当前备份脚本.sh > /dev/null 2>&1 空格
# 编辑定时任务的语句最后加个空格，不然有些机器不能执行脚本
########使用crontab将脚本加入定时任务-END#########

# 开启 alias
shopt -s expand_aliases
# 将“检查命令执行结果的逻辑”封装为一个别名（该别名包含return语句，仅能在function中使用）
alias CHECK_RETURN='{
  result=$?
  if [ $result -ne 0 ];then
    read errMsg
    echo `date +%Y-%m-%d_%H:%M:%S` ERROR：$errMsg
    return $result
  fi
}<<<'
# 将自定义echo格式封装为别名
alias ECHO='{
  read msg
  echo `date +%Y-%m-%d_%H:%M:%S` MESSAGE：$msg
}<<<'
# 变量定义区域
DB_USER='root'
DB_PASSWORD='test9D_Pass'
DB_PORT='4400'
DB_HOST='192.168.1.66'
DB_BIN='/usr/bin'
BACKUP_DIR_BASE="/data/mysql-backup/local_temp"
BACKUP_LOG="${BACKUP_DIR_BASE}/backup.log"
BACKUP_DIR_LATEST="${BACKUP_DIR_BASE}/backup_latest"
BACKUP_DIR_OLDER="${BACKUP_DIR_BASE}/backup_older"
BACKUP_CONFIG_FILE=$BACKUP_DIR_LATEST"/db-backup.conf"
#全备时间 0代表周日
FULL_BACKUP_DAY='0'
TODAY=`date +%w`
DATE=`date +%Y%m%d`
CURRENT_TIME="date +%Y-%m-%d_%H:%M:%S"

# 增量备份
function INCREASE_BACKUP(){
  ECHO "开始数据库增量备份"
  local BINLOG_BASENAME=`$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show variables like 'log_bin_basename'" | awk '{print $2}' |tail -n1`
  CHECK_RETURN "查询binlog目录失败！"
  local BINLOG_PATH=${BINLOG_BASENAME%/*}
  if [ ! -d "$BINLOG_PATH" ]; then
      ECHO "未找到有效的binlog目录：$BINLOG_PATH"
      return 1
  fi
  if [[ ! -r $BACKUP_CONFIG_FILE ]];then
    ECHO "错误- $BACKUP_CONFIG_FILE 配置文件不存在或不可读。"
    return 1
  fi
  # 读取配置文件，获取开始备份的起始文件名
  BINLOG_FILE_BEGIN=$(tail -n1 $BACKUP_CONFIG_FILE | awk '{print $2}')
  ECHO "读取配置文件，获取开始备份的起始文件名为：$BINLOG_FILE_BEGIN"
  # 刷新日志，生成新的 binlog
  $DB_BIN/mysqladmin -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST flush-logs
  CHECK_RETURN "刷新binlog日志错误！"
  ECHO "刷新日志，生成新的 binlog 成功。"
  # 取最新的 binlog 文件名，作为备份截止文件
  local BINLOG_FILE_BEFORE_END=`$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master status" | awk '{print $1}' | tail -n1`
  CHECK_RETURN "查询最新的binlog文件名失败！"
  ECHO "获取最新的 binlog 文件名为：$BINLOG_FILE_BEFORE_END"
  # 增量备份 binlog
  local IS_BEGIN_BACKUP=0
  local BACKUP_FILES=""
  for i in `$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master logs" | awk '{print $1}' | tail -n +2`
  do
    if [[ $BINLOG_FILE_BEGIN == $i ]];then
      IS_BEGIN_BACKUP=1
    fi
    if [[ $IS_BEGIN_BACKUP == 1 && $i != $BINLOG_FILE_BEFORE_END ]]; then
        BACKUP_FILES+=" $i"
    fi
  done
  # 打包压缩 binlog
  if [[ ${BACKUP_FILES// /} == "" ]]; then
      ECHO "错误-没有有效的binlog,迭代binlog错误。"
      return 1
  fi
  # 适用于mysql服务在本机的binlog打包
  tar -zcf $BACKUP_DIR_LATEST/binlog_daily_$DATE.tar.gz  -C $BINLOG_PATH $BACKUP_FILES
  CHECK_RETURN "增备打包 binlog 时发生错误！"
  ECHO "数据库增量备份执行完成。成功打包文件：$BACKUP_DIR_LATEST/binlog_daily_$DATE.tar.gz，包含 binlog ：$BACKUP_FILES"
  # 将最新的 binlog 文件名写入 config 配置文件
  echo "`$CURRENT_TIME`        $BINLOG_FILE_BEFORE_END         INCREASE" >> $BACKUP_CONFIG_FILE
  CHECK_RETURN "更新 $BACKUP_CONFIG_FILE 配置文件失败！"
  ECHO "更新 $BACKUP_CONFIG_FILE 配置文件成功。"
}
# TODO 全量备份
function FULL_BACKUP() {
    ECHO "开始数据库全量备份"
    $DB_BIN/mysqldump -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -A -F -R -E --triggers --hex-blob --flush-privileges --single-transaction --master-data=2 | gzip > $BACKUP_DIR_LATEST/db_fullbak_$DATE.sql.gz
    CHECK_RETURN "数据库全量备份命令执行失败！"
    ECHO "数据库全量备份执行完成。成功打包 SQL 文件：$BACKUP_DIR_LATEST/db_fullbak_$DATE.sql.gz"
    # 取最新的 binlog 文件名，作为备份截止文件
    local BINLOG_FILE_BEFORE_END=`$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master status" | awk '{print $1}' | tail -n1`
    CHECK_RETURN "查询最新的binlog文件名失败！"
    ECHO "获取最新的 binlog 文件名为：$BINLOG_FILE_BEFORE_END"
    # 将最新的 binlog 文件名写入 config 配置文件
    echo "    BACKUP_TIME           BINLOG_END_BEFORE        BACKUP_MODEL" >> $BACKUP_CONFIG_FILE
    echo "`$CURRENT_TIME`        $BINLOG_FILE_BEFORE_END         FULL" >> $BACKUP_CONFIG_FILE
    CHECK_RETURN "更新 $BACKUP_CONFIG_FILE 配置文件失败！"
    ECHO "更新 $BACKUP_CONFIG_FILE 配置文件成功。"
}
# 检测数据库服务的状态
function DB_SERVER_CHECK(){
    $DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e ""
    CHECK_RETURN "数据库服务不能正常连接！"
    ECHO "数据库服务正常可连接。"
}
# 检测并创建备份目录
function BACKUP_DIR_CREATE(){
    if test -d $BACKUP_DIR_LATEST;then
        ECHO "$BACKUP_DIR_LATEST 检测到目录已存在，即将执行后续逻辑。"
    else
        ECHO "$BACKUP_DIR_LATEST 目录不存在，即将创建。"
        mkdir -pv $BACKUP_DIR_LATEST
        CHECK_RETURN "$BACKUP_DIR_LATEST 目录创建失败！"
        ECHO "$BACKUP_DIR_LATEST 目录创建成功。"
    fi

    if test -d $BACKUP_DIR_OLDER;then
        ECHO "$BACKUP_DIR_OLDER 检测到目录已存在，即将执行后续逻辑。"
    else
        ECHO "$BACKUP_DIR_OLDER 目录不存在，即将创建。"
        mkdir -pv $BACKUP_DIR_OLDER
        CHECK_RETURN "$BACKUP_DIR_OLDER 目录创建失败！"
        ECHO "$BACKUP_DIR_OLDER 目录创建成功。"
    fi
}
# 检测 binlog 是否开启
function BINLOG_EXIST(){
    local BINLOG_OPEN=`mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show variables like 'log_bin'" | tail -n +2 | awk '{print $2}'`
    CHECK_RETURN "查询 binlog 日志状态出错！"
    if [[ $BINLOG_OPEN == "ON" ]];then
        ECHO "检测到 BINLOG 日志为打开状态。"
        return 0
    fi
    ECHO "检测到 BINLOG 日志为关闭状态。"
    return 1
}
# 归档7天以前的备份，清空14天以前的备份
function BACKUP_CLEANER(){
    if [ "`ls -A $BACKUP_DIR_LATEST`" == "" ]; then
        ECHO "$BACKUP_DIR_LATEST 备份目录为空，没有要归档的文件"
    else
      tar -zcf $BACKUP_DIR_OLDER/db_archive_$DATE.tar.gz  -C $BACKUP_DIR_LATEST .
      CHECK_RETURN "$BACKUP_DIR_LATEST 归档失败！"
      ECHO "$BACKUP_DIR_LATEST 归档完成"
      rm -rf $BACKUP_DIR_LATEST/*
      CHECK_RETURN "$BACKUP_DIR_LATEST 清空失败！"
      ECHO "$BACKUP_DIR_LATEST 清空完成"
    fi

    local CLEAN_FILES=`find $BACKUP_DIR_OLDER -mtime +14 -exec ls -A {} \;`
    if [ "$CLEAN_FILES" == "" ]; then
        ECHO "$BACKUP_DIR_OLDER 目录中，没有要清空的14天以前的旧备份文件"
    else
      find $BACKUP_DIR_OLDER -mtime +14 -exec rm -fr {} \;
      CHECK_RETURN "$BACKUP_DIR_OLDER 清空14天以前的备份失败！"
      ECHO "$BACKUP_DIR_OLDER 清空14天以前的备份成功。"
    fi

}
# 备份方法
function BACK_UP() {
    # 备份前的各种必要检测
    DB_SERVER_CHECK
    CHECK_RETURN "执行中断，退出脚本！"
    BINLOG_EXIST
    CHECK_RETURN "执行中断，退出脚本！"
    # 如果今天是全备日或者备份目录为空，则执行全备，否则执行增备
    if [[ $TODAY == $FULL_BACKUP_DAY || "`ls -A $BACKUP_DIR_LATEST`" == "" ]]; then
        BACKUP_CLEANER
        CHECK_RETURN "执行中断，退出脚本！"
        FULL_BACKUP
        CHECK_RETURN "执行中断，退出脚本！"
    else
      INCREASE_BACKUP
      CHECK_RETURN "执行中断，退出脚本！"
    fi
    ECHO "备份脚本顺利执行完成。"
}
# 主函数
function MAIN() {
# 首先检测创建备份目录，否则无法写日志，也无法创建备份文件
BACKUP_DIR_CREATE
# 执行备份逻辑
BACK_UP >> $BACKUP_LOG # 输出到日志文件
#BACK_UP # 输出到标准输出
}

# 调用主函数
MAIN
```

### mysql定期全量加增量备份脚本-增强版

```bash
#!/bin/bash
#######################################################################
#        数据库自动备份脚本-增强版（支持备份本地数据库和远程数据库）  #
#######################################################################
# 备份策略：                          #
# 7天1全备，1天1增备，每次增备时都会     #
# 清空14天之前的binlog(可按需调整)      #
#####################################
# 可以将下面这段被注释的语句保存为一个测试脚本进行测试。
# 该测试逻辑，是通过循环修改系统时间，模拟一个月的备份过程。
########测试脚本-START##########
# #!/bin/bash
# for day in {1..30}
# do
#    date -s "2021-04-$day 12:00:00"
#    /bin/bash 当前备份脚本.sh
# done
########测试脚本-END############
# 可以通过下面这段命令，使用crontab将备份脚本加入定时任务
########使用crontab将脚本加入定时任务-START#######
# crontab -e
# 0 3 * * *  /bin/bash 当前备份脚本.sh > /dev/null 2>&1 空格
# 编辑定时任务的语句最后加个空格，不然有些机器不能执行脚本
########使用crontab将脚本加入定时任务-END#########

# 开启 alias
shopt -s expand_aliases
# 将“检查命令执行结果的逻辑”封装为一个别名（该别名包含return语句，仅能在function中使用）
alias CHECK_RETURN='{
  result=$?
  if [ $result -ne 0 ];then
    read errMsg
    echo `date +%Y-%m-%d_%H:%M:%S` ERROR：$errMsg
    return $result
  fi
}<<<'
# 将自定义echo格式封装为别名
alias ECHO='{
  read msg
  echo `date +%Y-%m-%d_%H:%M:%S` MESSAGE：$msg
}<<<'
# 变量定义区域
DB_USER='root'
DB_PASSWORD='test9D_Pass'
DB_PORT='4400'
DB_HOST='192.168.1.66'
DB_BIN='/usr/bin'
BACKUP_DIR_BASE="/data/mysql-backup/local_temp"
BACKUP_LOG="${BACKUP_DIR_BASE}/backup.log"
BACKUP_DIR_LATEST="${BACKUP_DIR_BASE}/backup_latest"
BACKUP_DIR_OLDER="${BACKUP_DIR_BASE}/backup_older"
BACKUP_CONFIG_FILE=$BACKUP_DIR_LATEST"/db-backup.conf"
#全备时间 0代表周日
FULL_BACKUP_DAY='0'
TODAY=`date +%w`
DATE=`date +%Y%m%d`
CURRENT_TIME="date +%Y-%m-%d_%H:%M:%S"

# 增量备份
function INCREASE_BACKUP(){
  ECHO "开始数据库增量备份"
  if [[ ! -r $BACKUP_CONFIG_FILE ]];then
    ECHO "错误- $BACKUP_CONFIG_FILE 配置文件不存在或不可读。"
    return 1
  fi
  # 读取配置文件，获取开始备份的起始文件名
  BINLOG_FILE_BEGIN=$(tail -n1 $BACKUP_CONFIG_FILE | awk '{print $2}')
  ECHO "读取配置文件，获取开始备份的起始文件名为：$BINLOG_FILE_BEGIN"
  # 刷新日志，生成新的 binlog
  $DB_BIN/mysqladmin -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST flush-logs
  CHECK_RETURN "刷新binlog日志错误！"
  ECHO "刷新日志，生成新的 binlog 成功。"
  # 取最新的 binlog 文件名，作为备份截止文件
  local BINLOG_FILE_BEFORE_END=`$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master status" | awk '{print $1}' | tail -n1`
  CHECK_RETURN "查询最新的binlog文件名失败！"
  ECHO "获取最新的 binlog 文件名为：$BINLOG_FILE_BEFORE_END"
  # 增量备份 binlog
  local IS_BEGIN_BACKUP=0
  local BACKUP_FILES=""
  for i in `$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master logs" | awk '{print $1}' | tail -n +2`
  do
    if [[ $BINLOG_FILE_BEGIN == $i ]];then
      IS_BEGIN_BACKUP=1
    fi
    if [[ $IS_BEGIN_BACKUP == 1 && $i != $BINLOG_FILE_BEFORE_END ]]; then
        BACKUP_FILES+=" $i"
    fi
  done
  # 打包压缩 binlog
  if [[ ${BACKUP_FILES// /} == "" ]]; then
      ECHO "错误-没有有效的binlog,迭代binlog错误。"
      return 1
  fi
  # 适用于mysql服务在远程主机的binlog打包（也适用本机）
  $DB_BIN/mysqlbinlog -R --raw -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST $BACKUP_FILES \
   && tar -zcf $BACKUP_DIR_LATEST/binlog_daily_$DATE.tar.gz $BACKUP_FILES --remove-files
  CHECK_RETURN "增备打包 binlog 时发生错误！"
  ECHO "数据库增量备份执行完成。成功打包文件：$BACKUP_DIR_LATEST/binlog_daily_$DATE.tar.gz，包含 binlog ：$BACKUP_FILES"
  # 将最新的 binlog 文件名写入 config 配置文件
  echo "`$CURRENT_TIME`        $BINLOG_FILE_BEFORE_END         INCREASE" >> $BACKUP_CONFIG_FILE
  CHECK_RETURN "更新 $BACKUP_CONFIG_FILE 配置文件失败！"
  ECHO "更新 $BACKUP_CONFIG_FILE 配置文件成功。"
}
# TODO 全量备份
function FULL_BACKUP() {
    ECHO "开始数据库全量备份"
    $DB_BIN/mysqldump -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -A -F -R -E --triggers --hex-blob --flush-privileges --single-transaction --master-data=2 | gzip > $BACKUP_DIR_LATEST/db_fullbak_$DATE.sql.gz
    CHECK_RETURN "数据库全量备份命令执行失败！"
    ECHO "数据库全量备份执行完成。成功打包 SQL 文件：$BACKUP_DIR_LATEST/db_fullbak_$DATE.sql.gz"
    # 取最新的 binlog 文件名，作为备份截止文件
    local BINLOG_FILE_BEFORE_END=`$DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show master status" | awk '{print $1}' | tail -n1`
    CHECK_RETURN "查询最新的binlog文件名失败！"
    ECHO "获取最新的 binlog 文件名为：$BINLOG_FILE_BEFORE_END"
    # 将最新的 binlog 文件名写入 config 配置文件
    echo "    BACKUP_TIME           BINLOG_END_BEFORE        BACKUP_MODEL" >> $BACKUP_CONFIG_FILE
    echo "`$CURRENT_TIME`        $BINLOG_FILE_BEFORE_END         FULL" >> $BACKUP_CONFIG_FILE
    CHECK_RETURN "更新 $BACKUP_CONFIG_FILE 配置文件失败！"
    ECHO "更新 $BACKUP_CONFIG_FILE 配置文件成功。"
}
# 检测数据库服务的状态
function DB_SERVER_CHECK(){
    $DB_BIN/mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e ""
    CHECK_RETURN "数据库服务不能正常连接！"
    ECHO "数据库服务正常可连接。"
}
# 检测并创建备份目录
function BACKUP_DIR_CREATE(){
    if test -d $BACKUP_DIR_LATEST;then
        ECHO "$BACKUP_DIR_LATEST 检测到目录已存在，即将执行后续逻辑。"
    else
        ECHO "$BACKUP_DIR_LATEST 目录不存在，即将创建。"
        mkdir -pv $BACKUP_DIR_LATEST
        CHECK_RETURN "$BACKUP_DIR_LATEST 目录创建失败！"
        ECHO "$BACKUP_DIR_LATEST 目录创建成功。"
    fi

    if test -d $BACKUP_DIR_OLDER;then
        ECHO "$BACKUP_DIR_OLDER 检测到目录已存在，即将执行后续逻辑。"
    else
        ECHO "$BACKUP_DIR_OLDER 目录不存在，即将创建。"
        mkdir -pv $BACKUP_DIR_OLDER
        CHECK_RETURN "$BACKUP_DIR_OLDER 目录创建失败！"
        ECHO "$BACKUP_DIR_OLDER 目录创建成功。"
    fi
}
# 检测 binlog 是否开启
function BINLOG_EXIST(){
    local BINLOG_OPEN=`mysql -u$DB_USER -p$DB_PASSWORD -P$DB_PORT -h$DB_HOST -e "show variables like 'log_bin'" | tail -n +2 | awk '{print $2}'`
    CHECK_RETURN "查询 binlog 日志状态出错！"
    if [[ $BINLOG_OPEN == "ON" ]];then
        ECHO "检测到 BINLOG 日志为打开状态。"
        return 0
    fi
    ECHO "检测到 BINLOG 日志为关闭状态。"
    return 1
}
# 归档7天以前的备份，清空14天以前的备份
function BACKUP_CLEANER(){
    if [ "`ls -A $BACKUP_DIR_LATEST`" == "" ]; then
        ECHO "$BACKUP_DIR_LATEST 备份目录为空，没有要归档的文件"
    else
      tar -zcf $BACKUP_DIR_OLDER/db_archive_$DATE.tar.gz  -C $BACKUP_DIR_LATEST .
      CHECK_RETURN "$BACKUP_DIR_LATEST 归档失败！"
      ECHO "$BACKUP_DIR_LATEST 归档完成"
      rm -rf $BACKUP_DIR_LATEST/*
      CHECK_RETURN "$BACKUP_DIR_LATEST 清空失败！"
      ECHO "$BACKUP_DIR_LATEST 清空完成"
    fi

    local CLEAN_FILES=`find $BACKUP_DIR_OLDER -mtime +14 -exec ls -A {} \;`
    if [ "$CLEAN_FILES" == "" ]; then
        ECHO "$BACKUP_DIR_OLDER 目录中，没有要清空的14天以前的旧备份文件"
    else
      find $BACKUP_DIR_OLDER -mtime +14 -exec rm -fr {} \;
      CHECK_RETURN "$BACKUP_DIR_OLDER 清空14天以前的备份失败！"
      ECHO "$BACKUP_DIR_OLDER 清空14天以前的备份成功。"
    fi

}
# 备份方法
function BACK_UP() {
    # 备份前的各种必要检测
    DB_SERVER_CHECK
    CHECK_RETURN "执行中断，退出脚本！"
    BINLOG_EXIST
    CHECK_RETURN "执行中断，退出脚本！"
    # 如果今天是全备日或者备份目录为空，则执行全备，否则执行增备
    if [[ $TODAY == $FULL_BACKUP_DAY || "`ls -A $BACKUP_DIR_LATEST`" == "" ]]; then
        BACKUP_CLEANER
        CHECK_RETURN "执行中断，退出脚本！"
        FULL_BACKUP
        CHECK_RETURN "执行中断，退出脚本！"
    else
      INCREASE_BACKUP
      CHECK_RETURN "执行中断，退出脚本！"
    fi
    ECHO "备份脚本顺利执行完成。"
}
# 主函数
function MAIN() {
# 首先检测创建备份目录，否则无法写日志，也无法创建备份文件
BACKUP_DIR_CREATE
# 执行备份逻辑
BACK_UP >> $BACKUP_LOG # 输出到日志文件
#BACK_UP # 输出到标准输出
}

# 调用主函数
MAIN
```


（完）
