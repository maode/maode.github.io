---
title: maven常用命令和参数
date: 2017-09-05 15:32:41
tags:
	- maven
---
### 打包 package
- `mvn clean package -Dmaven.test.skip=true`
  将项目先clean然后编译并打包，（会在模块下的target目录生成jar或war等文件）。
  **clean** 表示清空项目生成的编译文件,一般是模块下的target目录。
  **-Dmaven.test.skip=true** 表示打包时忽略掉test目录。
- `mvn war:exploded`
  仅打包Web页面文件。

### 编译 compile
- `mvn compile`
  编译项目主程序。**不会编译test目录的代码**。第一次运行时，会下载相关的依赖包，编译后的class生成在`target/classes`目录下。
  
- `mvn test-compile`
  编译项目的测试代码。**编译单元测试类代码**编译后的class生成在`target/test-classes`目录下。  

### 运行 run
- `mvn test`
  运行项目中的单元测试类（先编译后运行）。
- `mvn test -skipping compile -skipping test-compile`  
  运行项目中的单元测试类（不编译主程序，也不编译单元测试类）。
- `mvn jetty:run`
  用jetty服务器运行 （依赖于jetty且只适用于war的模块,即web模块）。
- `mvn spring-boot:run`
  运行spring boot项目（在spring boot项目的根路径下运行）。

<!-- more -->

### 安装 install
- 将项目安装到本地仓库 

  `mvn install -Dmaven.test.skip=true`
  将项目打包为`jar/war`文件并安装到本地仓库中,供其它项目或模块使用(-Dmaven.test.skip=true跳过测试类)。

- 将本地jar安装到本地仓库

  `mvn install:install-file -Dfile=? -DgroupId=? -DartifactId=? -Dversion=? -Dpackaging=? -DgeneratePom=?`
  mvn install:install-file 
  -Dfile=本地jar路径 
  -DgroupId=设置groupId 
  -DartifactId=设置artifactId 
  -Dversion=版本号
  -Dpackaging=文件类型,可以不写 如：`-Dpackaging=jar`
  -DgeneratePom=是否生成pom，可以不写 默认`true`


### 创建项目 create
- 创建Maven的普通java项目： 
  `mvn archetype:create -DgroupId=packageName -DartifactId=projectName`
- 创建Maven的Web项目：   
  `mvn archetype:create -DgroupId=packageName -DartifactId=webappName -DarchetypeArtifactId=maven-archetype-webapp`
- 根据maven提供的模板创建项目：
  `mvn archetype:generate`
  执行该命令后会在窗口展示一堆模板，输入你想要的模板编号后，会再要求输入groupID，
  artifactID,version,package最后确认信息无误输入`y`项目就生成了。
  

### 其它
- `mvn site`
  生成项目相关信息的网站
- `mvn site:deploy`
  生成站点信息并发布。具体可参考:[使用“mvn site-deploy”部署站点（WebDAV例子）](https://www.yiibai.com/maven/deploy-site-with-mvn-site-deploy-webdav-example.html)
- `mvn clean`
  清空项目生成的编译文件,一般是模块下的target目录
- `mvn deploy`
  将打包的文件发布到远程仓库,供其他人员进行下载依赖 ,一般是发布到个人或公司搭建的私服.
- `mvn eclipse:eclipse`
  在项目的根目录下执行，可以为该项目生成Eclipse的相关配置文件，供导入Eclipse中进行开发。
  **该命令不常用**一般都在Eclipse中安装了m2eclipse插件，可直接在Eclipse中Import来导入。
- `mvn eclipse:clean`
  清除项目中的Eclipse相关配置文件。
- `mvn idea:idea`
  生成idea项目。
- `mvn help:effective-pom`
  **查看实际pom信息**。用于查看当前生效的POM内容，指合并了所有父POM（包括Super POM）后的XML，
  所以可用于检测POM中某个配置是否生效。 


### 发行版本
发行版本,可与scm工具集成,来提供版本管理.不等同与版本控制。
- `mvn release:clean`
  清理release操作时遗留下来的文件
- `mvn release:branch`
  创建分支,会在分支下创建执行的分支路径
  -DbranchName=xxxx-100317 分支中的名称 
  -DupdateBranchVersions=false 是否更新分支的版本信息,默认为false 
  -DupdateWorkingCopyVersions=false 是否更新主干的版本信息,默认为true
- `mvn release:prepare`
  把项目打一个release版本，在git的tag中打一个tag，自动升级SNAPSHOT 并提交更新后的pom文件到git
- `mvn release:perform`
  检出git的tag上的代码，并打一个release版的包deploy到你的maven私服

### 依赖查看
- `mvn project-info-reports:dependencies`
  生成项目依赖的报表
- `mvn dependency:resolve`
  查看项目依赖情况
- `mvn dependency:tree`
  打印出项目的整个依赖树
- `mvn dependency:analyze`
  帮助你分析依赖关系, 用来取出无用, 重复依赖的好帮手
- `mvn install -X`
  追踪依赖的完整轨迹

### 配置相关
- `mvn -version/-v`
  显示maven版本信息。
- `mvn help:effective-settings`	
  查看当前生效的settings.xml，可用于判断某个settings配置是否生效
- `mvn -X`	
  debug，可查看settings.xml文件的读取顺序
- `mvn help:system`	
  打印所有可用的环境变量和Java系统属性

必选的Profile一般配置在settings.xml中,始终激活;
可选的Profile一般配置在pom.xml中,持续集成时,根据不同环境激活不同的Profile;
$ mvn help:active-profiles 列出当前激活的Profile
$ mvn help:all-profiles 列出当前所有的Profile


### 常用参数

```bash
-h,--help                              显示帮助信息
-am,--also-make                        构建指定模块,同时构建指定模块依赖的其他模块;
-amd,--also-make-dependents            构建指定模块,同时构建依赖于指定模块的其他模块;
-B,--batch-mode                        以批处理(batch)模式运行;
-C,--strict-checksums                  检查不通过,则构建失败;(严格检查)
-c,--lax-checksums                     检查不通过,则警告;(宽松检查)
-D,--define <arg>                      定义一个系统属性
-e,--errors                            显示详细错误信息
-emp,--encrypt-master-password <arg>   加密主安全密码
-ep,--encrypt-password <arg>           加密服务器密码
-f,--file <arg>                        使用指定的POM文件替换当前POM文件
-fae,--fail-at-end                     最后失败模式：Maven会在构建最后失败（停止）。
                                       如果Maven refactor中一个失败了，Maven会继续构建其它项目，
                                       并在构建最后报告失败。

-ff,--fail-fast                        最快失败模式： 多模块构建时,遇到第一个失败的构建时停止。
-fn,--fail-never                       从不失败模式：Maven从来不会为一个失败停止，也不会报告失败。
-gs,--global-settings <arg>            替换全局级别settings.xml文件
                                       (Alternate path for the global settings file)
-l,--log-file <arg>                    指定输出日志文件
-N,--non-recursive                     仅构建当前模块，而不构建子模块(即关闭Reactor功能)。
-nsu,--no-snapshot-updates             强制不更新SNAPSHOT(Suppress SNAPSHOT updates)
-U,--update-snapshots                  强制更新releases、snapshots类型的插件或依赖库
                                       (否则maven一天只会更新一次snapshot依赖)
-o,--offline                           离线模式,不联网进行依赖更新
-P,--activate-profiles <arg>           激活指定的profile文件列表(用逗号[,]隔开)
-pl,--projects <arg>                   构建指定的模块，模块间用逗号分隔;
-q,--quiet                             安静模式,只输出ERROR
-rf,--resume-from <arg>                从指定的项目(或模块)开始继续构建
-s,--settings <arg>                    替换用户级别settings.xml文件。
                                       (Alternate path for the user settings file)
-T,--threads <arg>                     Thread count, for instance 2.0C where C is core multiplied
-t,--toolchains <arg>                  Alternate path for the user toolchains file
-V,--show-version                      Display version information WITHOUT stopping build
-v,--version                           Display version information
-X,--debug                             输出详细信息，debug模式。
-cpu,--check-plugin-updates            【废弃】,仅为了向后兼容
-npr,--no-plugin-registry              【废弃】,仅为了向后兼容
-npu,--no-plugin-updates               【废弃】,仅为了向后兼容
-up,--update-plugins                   【废弃】,仅为了向后兼容
```


参考：
[Maven Command Line Options](http://books.sonatype.com/mvnref-book/reference/running-sect-options.html)
[Maven常用参数及其说明](http://blog.csdn.net/wangjunjun2008/article/details/18982089)



暂时就这些，后面没有了！(=^ ^=)