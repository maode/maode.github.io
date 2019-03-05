---
title: logback windows cmd中文乱码问题
date: Tue Mar 05 2019 10:07:53
tags:
	- logback
---

## 原因

windows系统默认编码GBK，而springboot集成的logback的console日志默认编码设置的是UTF-8.(在spring-boot-x.x.x.RELEASE.jar的org.springframework.boot.logging.logback包下的console-appender.xml).所以导致在windows的cmd窗口日志输出为乱码.
而linux的系统默认编码为UTF-8,所以就不会有乱码问题.

## 解决方法

解决方法就是让系统编码和logback的编码统一,修改logback的编码配置,或修改windows cmd窗口的编码配置,或使用别的shell工具替代cmd窗口.

### 修改logback的编码配置

```xml
    <include resource="org/springframework/boot/logging/logback/defaults.xml" />
    <property name="LOG_FILE" value="${LOG_FILE:-${LOG_PATH:-${LOG_TEMP:-${java.io.tmpdir:-/tmp}}}/spring.log}"/>
    <!-- <include resource="org/springframework/boot/logging/logback/console-appender.xml" /> -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>${CONSOLE_LOG_PATTERN}</pattern>
            <!-- <charset>utf8</charset> --> <!-- 注释编码设置,此时会使用操作系统的编码,解决windows乱码问题 -->
        </encoder>
    </appender>
    <include resource="org/springframework/boot/logging/logback/file-appender.xml" />
    <root level="INFO">
        <appender-ref ref="CONSOLE" />
        <appender-ref ref="FILE" />
    </root>
```

### 修改windows系统的cmd窗口编码

打开cmd窗口,先执行一下命令,将编码改为utf-8
```
CHCP 65001
```
然后再执行`java -Dfile.encoding=utf-8 -jar xxx.jar`运行项目.

**注：** 其实修改了cmd的编码为65001,还是会有一些字会乱码和莫名其妙的问题,是因为windows cmd对UTF-8支持不友好,建议直接换别的shell工具(如 git bash),不要折腾cmd了.太费劲

### 使用其他bash工具

直接在其他bash工具下执行`java -Dfile.encoding=utf-8 -jar xxx.jar`运行项目.


最好的解决方法是,在linux环境下编译,打包,运行.


（完）



