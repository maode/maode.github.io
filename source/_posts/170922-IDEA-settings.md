---
title: IDEA配置优化
date: 2017-09-22 22:55:24
tags:
	- IDEA
---


### 优化JVM参数
**用户级别修改：**
打开IDEA，选择Help-->Edit Custom VM Options... 将以下参数内容内容复制过来。
（会在操作系统的当前用户目录下生成一份配置文件，如：`C:\Users\code0\.IntelliJIdea\config\idea64.exe.vmoptions`）

**系统级别修改：**
直接修改 IntelliJ IDEA 安装目录下的/bin/idea64.exe.vmoptions【记得备份】文件，如果是32位系统，修改idea.exe.vmoptions文件中的参数。
（直接覆写系统默认设置对当前操作系统所有用户都有效）

**具体参数如下：**

-Xms512m
-Xmx750m
-Xmn264m
-XX:MaxPermSize=350m
-XX:PermSize=128m
-XX:ReservedCodeCacheSize=240m
-Xverify:none
-Xnoclassgc
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-server
-Dsun.io.useCanonCaches=false
-Dsun.awt.keepWorkingSetOnMinimize=true
-Djava.net.preferIPv4Stack=true
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow

```
　　注：-Xms512m 设置初时的内存大小，提高Java程序的启动速度

　　　　-Xmx750m 设置最大内存数，提高该值，可以减少内存Garage收集的频率，提高程序性能。

　　　　-Xverify：none 关闭Java字节码验证，从而加快了类装入的速度，并使得在仅为验证目的
                      而启动的过程中无需装入类，缩短了启动时间

　　　　-XX:+UseParNewGC 使用并行收集算法

　　　　-server 控制内存garage方式，这样你无需在花一到两分钟等待内存garage的收集

　　　　-Dsun.awt.keepWorkingSetOnMinimize=true 可以让IDEA最小化到任务栏时依然保持以占有的内存，
                                               当你重新回到IDEA，能够被快速显示，而不是由灰白的
                                               界面逐渐显现整个界面，加快回复到原界面的速度。
```
### 基本常用设置

<!-- more -->

**设置外观字体：** File -> Settings -> Appearance & Behavior -> Appearance -> 
- 勾选 Override default fonts by (not Recommended)
- 设置 Name：微软雅黑、Size：12、Presentation Mode：24
- 去掉 Animate windows，勾选 Show tool window bars

**启动时不打开工程：** File -> Settings -> Appearance & Behavior -> System Settings -> Startup/Shutdown 标签项 -> 
- 去掉 Reopen last project on startup

**关闭确认退出选项：** File -> Settings -> Appearance & Behavior -> System Settings -> Startup/Shutdown 标签项 -> 
- 去掉 Confirm application exit

**在同一窗口打开工程：** File -> Settings -> Appearance & Behavior -> System Settings -> Project Opening 标签项 -> 
- 勾选 Open project in ths same window

**设置自动保存：** File -> Settings -> Appearance & Behavior -> System Settings -> Synchronization 标签项 ->
- 全部勾选包括 Save files automatically..  然后设置30 sec.

**关闭自动检测新版本更新：** File -> Settings -> Appearance & Behavior -> System Settings -> Updates -> 
- 去掉 Automatically check updates for...

**关闭IDEA的使用习惯统计：** File -> Settings -> Appearance & Behavior -> System Settings -> Usage Statistics -> 
- 去掉 Allow sending...

**通过 Ctrl + 鼠标调整字体：** File -> Settings -> Editor -> General -> Mouse 标签项 -> 
- 勾选 Change font size (Zoom) with Ctrl + Mouse Wheel

**让光标不随意定位：** File -> Settings -> Editor -> General -> Virtual Space 标签项 -> 
- 去掉 Allow placement of caret after end of line

**显示虚拟空间：** File -> Settings -> Editor -> General -> Virtual Space 标签项 -> 
- 勾选 Show virtual space at file bottom

**去除每行多余空格：** File -> Settings -> Editor -> General -> Other 标签项 -> 
- 设置 Srip trailing spaces on Save，下拉选择 All

**去除光滑滚动：** File -> Settings -> Editor -> General -> Scrolling 标签项 -> 
- 去掉 Smooth scrolling

**自动 import 包：** File -> Settings -> Editor -> General -> Auto Import -> 
- 勾选 Optimize imports on the fly、Add unambiguous imports on the fly

**显示行号：** File -> Settings -> Editor -> General -> Appearance -> 
- 勾选 Show line numbers

**显示空白符：** File -> Settings -> Editor -> General -> Appearance -> 
- 勾选 Show whitespaces

**代码自动补齐(针对小写)：** File -> Settings -> Editor -> General -> Code Completion -> Code Completion 标签项 -> 
- 设置 Case sensitive completion：none
- 勾选 Autopopup documentation in (ms) ： 200
- 勾选 Parameter in (ms) ：200

**代码折叠：** File -> Settings -> Editor -> General -> Code Folding -> 
- 去掉 One-line methods

**用*标识编辑过的文件：** File -> Settings -> Editor -> General -> Editor Tabs -> Tab Appearance 标签项 -> 
- 勾选 Mark modified tabs with asterisk

**限制 Tab 标签页数量：** File -> Settings -> Editor -> General -> Editor Tabs -> Tab Closing Policy 标签项 -> 
- 设置 Tab limit ：20

**输入“右}”时，不要格式化代码块：** File -> Settings -> Editor -> General -> Smart Keys -> 
- 去掉 Reformat block on typing '}'
- 设置 Reformat on paste ：None

**代码字体风格：** File -> Settings -> Editor -> Colors & Fonts -> Font -> 
- 选择 Darcula 设计，点击 Save As备份一套然后编辑
- 修改 Primary font 的字体，勾选 Show only monospaced fonts，只显示等宽字体

**设置光标所在行的背景：** File -> Settings -> Editor -> Colors Scheme -> General -> 
- 在右侧的下拉框中选择 Editor -> Caret row -> 然后修改Background选项

**取消代码拼写检查：** File -> Settings -> Editor -> Inspections -> 
- 在右侧的下拉框中选择 Spelling -> Typo -> 然后去掉右侧 Process code、Process literals、Process comments

**统一编码格式：** File -> Settings -> Editor -> File Encodings -> 
- 设置 Global Encoding、Project Encoding、Defalut encoding for properties files
- 勾选 Transparent native -to-ascii conversion（properties文件自动转换ASCII编码）

**忽略的文件类型及目录：** File -> Settings -> Editor -> File Types -> 
- 在右侧底部的Ignore files and folders 文本框中添加
  `*.iml;*.idea;*.classpath;*.project;*.settings;target;`
  （可以不设置该选项，下载`.ignore`插件来管理所有忽略文件）

**禁用插件：** File -> Settings -> Plugins -> 
- 反选自己想要禁用的插件 如：ASP、Cloud Foundry integration、CloudBees integration 等等

**备份个性化设置：** File -> Export Settings

------------------------------------------------------------------------------
**参考：**  [Intellij IDEA配置优化](http://www.cnblogs.com/playcode/p/5588707.html)

暂时就这些，后面没有了！(=^ ^=)






