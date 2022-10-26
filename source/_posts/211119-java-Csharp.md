---
title: java调用Csharp类库文件
date: Wed Oct 26 2020 11:50:15
tags:
	- java调用C#
---

## 1. 下载jni4net-0.8.8.0-bin.zip，

地址：https://github.com/jni4net/jni4net/releases/download/0.8.8.0/jni4net-0.8.8.0-bin.zip

## 2. 生成jni4net相关文件

解压压缩包后进入bin目录，执行 `.\proxygen.exe "要调用的DLL文件路径" -wd "存放生成文件的路径"`，命令执行成功后会在“存放生成文件的路径”下生成 clr 和 jvm 两个目录，以及 build.cmd 和 dll文件名.proxygen.xml 两个文件。

进入生成文件目录下，执行 `build.cmd` 命令文件，命令执行成功后会生成 dll文件名.j4n.dll 和 dll文件名.j4n.jar 两个文件。

## 3. 配置项目

将生成的 dll文件名.j4n.jar 文件安装到maven仓库，并在pom文件中引用，artifactId和group随便起。

在pom中引入 jni4net 的依赖，如下：

```xml
        <dependency>
            <groupId>net.sf.jni4net</groupId>
            <artifactId>jni4net.j</artifactId>
            <version>0.8.8.0</version>
        </dependency>
```

将解压后的 jni4net-0.8.8.0-bin.zip 文件的 lib 目录下的所有 dll 文件复制到项目的 `resources/dll` 目录下。
将在第二步生成的 dll文件名.j4n.dll 复制到项目的 `resources/dll` 目录下。
将要调用的 dll 文件复制到项目的 resources 目录下。

## 4. 在项目中调用示例

```java
package test.jni4net;

import helloworld.Hello;
import net.sf.jni4net.Bridge;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

public class Main {
    static Logger log = LoggerFactory.getLogger(Main.class);

    public static void main(String[] args) {

        //加载j4net的桥接类库文件，必须要保证桥接类库、j4net类库、实际调用类库在同一目录下，必须要保证所有类库文件可以被直接访问调用，不能在压缩包中。
        File bridgeDll = loadJ4netBridgeDll();
        try {
            Bridge.setVerbose(true);
            //初始化桥接配置类（可以是目录也可以是具体的jni4net类库文件，如果是目录，那么会自动选择合适的jni4net类库版本）
            Bridge.init(new File(bridgeDll.getParent()));
            Bridge.LoadAndRegisterAssemblyFrom(bridgeDll);

            Hello.display();
            log.info("Csharp无参无返回值的静态方法被调用");

            String resultStr = Hello.staticResultStr();
            log.info("Csharp静态方法返回的值：{}", resultStr);

            String rsultInput = Hello.rsultInput("我是java调用时传递的参数");
            log.info("Csharp有输入参数的静态方法返回的值：{}", rsultInput);

            Hello hello = new Hello();
            String beanResult = hello.resultStr();
            log.info("Csharp实例方法返回的值：{}", beanResult);

            System.out.println("按回车键退出");
            BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
            reader.readLine();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    /**
     * 加载j4net的桥接类库文件<br/>
     * 必须要保证桥接类库、j4net类库、实际调用类库在同一目录下<br/>
     * 必须要保证所有类库文件可以被直接访问调用，不能在压缩包中。
     *
     * @return
     */
    private static File loadJ4netBridgeDll() {
        //如果将类库文件放在项目的resources目录下，项目打包后将无法调用到类库文件，可使用下面的方式，在程序运行时，将类库文件写到系统临时目录中后在调用。
        // 也可将类库文件不打包到程序中，但会暴漏较多程序细节。
        String projectName = "birdScaring";
        BaseUtil.resourcesToTemp(projectName, "dll/jni4net.n.w32.v20-0.8.8.0.dll");
        BaseUtil.resourcesToTemp(projectName, "dll/jni4net.n.w32.v40-0.8.8.0.dll");
        BaseUtil.resourcesToTemp(projectName, "dll/jni4net.n.w64.v20-0.8.8.0.dll");
        BaseUtil.resourcesToTemp(projectName, "dll/jni4net.n.w64.v40-0.8.8.0.dll");
        BaseUtil.resourcesToTemp(projectName, "dll/jni4net.n-0.8.8.0.dll");
        BaseUtil.resourcesToTemp(projectName, "dll/HelloWorld.dll");
        File bridgeDll = BaseUtil.resourcesToTemp(projectName, "dll/HelloWorld.j4n.dll");
        log.debug("桥接类库文件的临时路径为：{}", bridgeDll.getPath());
        return bridgeDll;
    }
}
```



（完）


<!-- more -->



