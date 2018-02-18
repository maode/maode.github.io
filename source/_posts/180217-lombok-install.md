---
title: lombok配置过程
date: Sat Feb 17 2018 20:30:26
tags:
    - getter-setter
    - lombok
---
## 配置Eclipse：
* 下载 `lombok.jar`：https://projectlombok.org/download
* 将下载的`lombok.jar`复制到`eclipse.exe`同级目录中。
* 修改`eclipse.ini`文件，在文件中添加以下内容：
```
-javaagent:lombok.jar
-Xbootclasspath/a:lombok.jar
```
* 重启Eclipse（如果Eclipse是开启状态）。

配置完成后打开Eclipse的 Help-》About Eclipse,在版权内容的末尾如果显示 lombok 的版本号等相关信息，代表配置成功了。如图：

![eclipse-about](/assets/blogImg/180217-lombok-install.png)


## 配置项目：
在项目的`pom.xml`文件中添加 lombok 依赖。**注意：项目中依赖的jar版本要和Eclipse中配置的jar版本一致。**

``` xml
<dependency>
	<groupId>org.projectlombok</groupId>
	<artifactId>lombok</artifactId>
	<version>1.16.20</version>
	<scope>provided</scope>
</dependency>
```
lombok官网：https://projectlombok.org

暂时就这些，后面没有了！(=^ ^=)




