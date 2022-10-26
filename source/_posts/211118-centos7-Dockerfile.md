---
title: centos7中文镜像封装Dockerfile
date: Wed Oct 26 2021 14:41:07
tags:
	- dockerfile
---

```
FROM centos:7.9.2009

# 作者名
MAINTAINER yhwt

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# Install tools
RUN yum update -y && \
    yum reinstall -y glibc-common && \
    yum install -y telnet net-tools && \
    yum clean all && \
    rm -rf /tmp/* rm -rf /var/cache/yum/* && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Define default command.
CMD ["bash"]

```


（完）


