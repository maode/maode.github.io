---
title: gradle安装配置
date: Tue Feb 20 2018 16:18:59
tags:
	- gradle
---
### 下载安装
官网下载压缩包解压安装：https://gradle.org/releases/

其它安装方式见：https://gradle.org/install/


### 配置环境变量：
- 在环境变量中添加一个变量`GRADLE_HOME`指向gradle的根目录。
  ```bat
  setx GRADLE_HOME "C:\software\gradle-4.5.1"
  ```
- 将gradle的可执行文件路径追加至Path。
  ```bat
  setx Path "%Path%;%GRADLE_HOME%\bin"
  ```

### 自定义gradle本地仓库
有几种不同的方式，大多采用配置环境变量的方式。
设置一个名称为`GRADLE_USER_HOME`的环境变量指向自定义的仓库目录。
```bat
setx GRADLE_USER_HOME "D:\repos\gradle"
```
或使用以下命令：`gradle -g 目录路径`,例如`gradle -g D:\Gradle\.gradle`

### 复用maven本地仓库
**前提：**
gradle复用maven本地仓库，是通过maven的`settings.xml`配置文件来搜索maven本地仓库路径的，
gradle默认会按以下顺序去查找本地的仓库：
USER_HOME/.m2/settings.xml >> M2_HOME/conf/settings.xml >> USER_HOME/.m2/repository所以要保证C盘用户目录存在`settings.xml`或者设置了`M2_HOME`环境变量。

确认具备以上条件后。在项目的`build.gradle`文件中调用`mavenLocal`方法即可：
```
repositories {
  mavenLocal()
}
```

### 修改全局默认仓库
进入Gradle安装目录下的`init.d`文件夹,新建`init.gradle`文件,并在文件中加入以下内容
```
allprojects{
    repositories {
        def ALIYUN_REPOSITORY_URL = 'http://maven.aliyun.com/nexus/content/groups/public'
        def ALIYUN_JCENTER_URL = 'http://maven.aliyun.com/nexus/content/repositories/jcenter'
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_REPOSITORY_URL."
                    remove repo
                }
                if (url.startsWith('https://jcenter.bintray.com/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_JCENTER_URL."
                    remove repo
                }
            }
        }
        maven {
        	url ALIYUN_REPOSITORY_URL
            url ALIYUN_JCENTER_URL
        }
    }
}
```

### 提升编译速度
开启守护进程和并行编译：
在 `用户目录\.gradle` 或 `GRADLE_USER_HOME` 路径下创建一个 `gradle.properties` 并填入以下内容：
```INI
##开启守护进程
org.gradle.daemon=true
##使用并行编译
org.gradle.parallel=true
```
不同系统下的用户目录：
```
C:\Users\<username> (Windows Vista & 7+)
/Users/<username> (Mac OS X)
/home/<username> (Linux)
```
参考资料：
[gradle本地、远程仓库配置](http://blog.csdn.net/x_iya/article/details/75040806)
[Gradle 修改本地仓库的位置](http://blog.csdn.net/kl28978113/article/details/53018225)
[配置Gradle的镜像为阿里云镜像](https://tvzr.com/change-the-mirror-of-gradle-to-aliyun.html)
[Gradle守护进程](https://benweizhu.gitbooks.io/gradle-best-practice/content/the-gradle-daemon.html)
[知道Android 中Gradle 的这些技巧，提升编译构建速度](http://tiki.cat/2016/05/26/android-studio-gradle-build-run-faster/)

详细了解可参考：[Gradle最佳实践](https://www.gitbook.com/book/benweizhu/gradle-best-practice/details)

（完）



