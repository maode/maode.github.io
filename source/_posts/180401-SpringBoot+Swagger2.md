---
title: 【转】SpringBoot 使用Swagger2打造在线接口文档（附汉化教程）
date: Sun Apr 01 2018 20:02:18
tags:
	- Swagger
---

> 序言：编写和维护接口文档是每个程序员的职责，根据Swagger2可以快速帮助我们编写最新的API接口文档，再也不用担心开会前仍忙于整理各种资料了，间接提升了团队开发的沟通效率。此外，本教程还额外提供了UI汉化教程，去除阅读官方英文界面的烦恼。（目前Swagger汉化教程是找不到的，因为官方手册实在写得太烂。。）

<!-- more -->

# SpringBoot + Swagger2 UI界面-汉化教程

# 1.默认的英文界面UI

想必很多小伙伴都曾经使用过Swagger，但是打开UI界面之后，却是下面这样的画风，纯英文的界面并不太友好，作为国人还是习惯中文界面。


![](/assets/blogImg/180401-SpringBoot+Swagger2_1.png)


号称世界最流行的API工具总不该不支持国际化属性吧，楼主在[官方使用手册](https://link.jianshu.com?t=https://swagger.io/docs/swagger-tools/#localization-and-translation-40)找到关于本地化和翻译的说明：

![](/assets/blogImg/180401-SpringBoot+Swagger2_2.png)

也就是说，只要添加翻译器和对于的译文JS就可以显示中文界面了。（使用IDEA 双击Shift 快速找到swagger-ui.html 入口文件）

![](/assets/blogImg/180401-SpringBoot+Swagger2_3.png)

> 注：对静态资源的存放路径有疑惑的请戳：[SpringBoot项目结构说明](https://www.jianshu.com/p/6dcfe16d91d0)

# 2.定制中文界面

# 2.1 添加首页和译文

重点来了，在resourece目录下创建\META-INF\resourece目录，然后创建一个名称为"swagger-ui.html" 的HTML文件。

![](/assets/blogImg/180401-SpringBoot+Swagger2_4.png)

注意文件名不要起错，接下来将下面这段内容原封不动的拷贝进去。

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Swagger UI</title>
    <link rel="icon" type="image/png" href="webjars/springfox-swagger-ui/images/favicon-32x32.png" sizes="32x32"/>
    <link rel="icon" type="image/png" href="webjars/springfox-swagger-ui/images/favicon-16x16.png" sizes="16x16"/>
    <link href='webjars/springfox-swagger-ui/css/typography.css' media='screen' rel='stylesheet' type='text/css'/>
    <link href='webjars/springfox-swagger-ui/css/reset.css' media='screen' rel='stylesheet' type='text/css'/>
    <link href='webjars/springfox-swagger-ui/css/screen.css' media='screen' rel='stylesheet' type='text/css'/>
    <link href='webjars/springfox-swagger-ui/css/reset.css' media='print' rel='stylesheet' type='text/css'/>
    <link href='webjars/springfox-swagger-ui/css/print.css' media='print' rel='stylesheet' type='text/css'/>

    <script src='webjars/springfox-swagger-ui/lib/object-assign-pollyfill.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/jquery-1.8.0.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/jquery.slideto.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/jquery.wiggle.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/jquery.ba-bbq.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/handlebars-4.0.5.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/lodash.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/backbone-min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/swagger-ui.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/highlight.9.1.0.pack.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/highlight.9.1.0.pack_extended.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/jsoneditor.min.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/marked.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lib/swagger-oauth.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/springfox.js' type='text/javascript'></script>

    <!--国际化操作：选择中文版 -->
    <script src='webjars/springfox-swagger-ui/lang/translator.js' type='text/javascript'></script>
    <script src='webjars/springfox-swagger-ui/lang/zh-cn.js' type='text/javascript'></script>

</head>

<body class="swagger-section">
<div id='header'>
    <div class="swagger-ui-wrap">
        <a id="logo" href="http://swagger.io">![](webjars/springfox-swagger-ui/images/logo_small.png)<span class="logo__title">swagger</span></a>
        <form id='api_selector'>
            <div class='input'>
                <select id="select_baseUrl" name="select_baseUrl"></select>
            </div>
            <div class='input'><input placeholder="http://example.com/api" id="input_baseUrl" name="baseUrl" type="text"/></div>
            <div id='auth_container'></div>
            <div class='input'><a id="explore" class="header__btn" href="#" data-sw-translate>Explore</a></div>
        </form>
    </div>
</div>

<div id="message-bar" class="swagger-ui-wrap" data-sw-translate> </div>
<div id="swagger-ui-container" class="swagger-ui-wrap"></div>
</body>
</html>

```

OK 大功告成 我们访问 [http://localhost:8080/swagger-ui.html](https://link.jianshu.com?t=http://localhost:8080/swagger-ui.html) 看看显示效果：

![](/assets/blogImg/180401-SpringBoot+Swagger2_5.png)

![](/assets/blogImg/180401-SpringBoot+Swagger2_6.png)

> 注：关于国际化，直接在Github下载好Swagger-UI的源码，将swagger-ui.html替换成上文，直接发布到Maven私服仓库，使用效果更佳。

# 2.2 更详细的译文翻译（非必需）

如果想进一步调整译文，可以在META-INF\resources\webjars\springfox-swagger-ui\lang 目录下添加zh-cn.js文件.

![](/assets/blogImg/180401-SpringBoot+Swagger2_7.png)

然后在译文（zh-cn.js ）根据个人喜好来添加翻译内容，如下

```js
'use strict';

/* jshint quotmark: double */
window.SwaggerTranslator.learn({
    "Warning: Deprecated":"警告：已过时",
    "Implementation Notes":"实现备注",
    "Response Class":"响应类",
    "Status":"状态",
    "Parameters":"参数",
    "Parameter":"参数",
    "Value":"值",
    "Description":"描述",
    "Parameter Type":"参数类型",
    "Data Type":"数据类型",
    "Response Messages":"响应消息",
    "HTTP Status Code":"HTTP状态码",
    "Reason":"原因",
    "Response Model":"响应模型",
    "Request URL":"请求URL",
    "Response Body":"响应体",
    "Response Code":"响应码",
    "Response Headers":"响应头",
    "Hide Response":"隐藏响应",
    "Headers":"头",
    "Try it out!":"试一下！",
    "Show/Hide":"显示/隐藏",
    "List Operations":"显示操作",
    "Expand Operations":"展开操作",
    "Raw":"原始",
    "can't parse JSON.  Raw result":"无法解析JSON. 原始结果",
    "Example Value":"示例",
    "Click to set as parameter value":"点击设置参数",
    "Model Schema":"模型架构",
    "Model":"模型",
    "apply":"应用",
    "Username":"用户名",
    "Password":"密码",
    "Terms of service":"服务条款",
    "Created by":"创建者",
    "See more at":"查看更多：",
    "Contact the developer":"联系开发者",
    "api version":"api版本",
    "Response Content Type":"响应Content Type",
    "Parameter content type:":"参数类型:",
    "fetching resource":"正在获取资源",
    "fetching resource list":"正在获取资源列表",
    "Explore":"浏览",
    "Show Swagger Petstore Example Apis":"显示 Swagger Petstore 示例 Apis",
    "Can't read from server.  It may not have the appropriate access-control-origin settings.":"无法从服务器读取。可能没有正确设置access-control-origin。",
    "Please specify the protocol for":"请指定协议：",
    "Can't read swagger JSON from":"无法读取swagger JSON于",
    "Finished Loading Resource Information. Rendering Swagger UI":"已加载资源信息。正在渲染Swagger UI",
    "Unable to read api":"无法读取api",
    "from path":"从路径",
    "server returned":"服务器返回"
});

```

> ===========接下来，正式进入Swagger2的使用教程===========

# SpringBoot + Swagger2 使用教程

# 1\. 引入依赖

```xml
    <!--依赖管理 -->
    <dependencies>
        <dependency> <!--添加Web依赖 -->
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency><!--添加Swagger依赖 -->
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.7.0</version>
        </dependency>
        <dependency><!--添加Swagger-UI依赖 -->
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger-ui</artifactId>
            <version>2.7.0</version>
        </dependency>
        <dependency> <!--添加热部署依赖 -->
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
        </dependency>
        <dependency><!--添加Test依赖 -->
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

```

# 2\. 添加配置

```java
@Configuration //标记配置类
@EnableSwagger2 //开启在线接口文档
public class Swagger2Config {
    /**
     * 添加摘要信息(Docket)
     */
    @Bean
    public Docket controllerApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(new ApiInfoBuilder()
                        .title("标题：某公司_用户信息管理系统_接口文档")
                        .description("描述：用于管理集团旗下公司的人员信息,具体包括XXX,XXX模块...")
                        .contact(new Contact("一只袜子", null, null))
                        .version("版本号:1.0")
                        .build())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.hehe.controller"))
                .paths(PathSelectors.any())
                .build();
    }
}

```

# 3\. 编写接口文档

#### Swagger2 基本使用：

*   @Api 描述类/接口的主要用途
*   @ApiOperation 描述方法用途
*   @ApiImplicitParam 描述方法的参数
*   @ApiImplicitParams 描述方法的参数(Multi-Params)
*   @ApiIgnore 忽略某类/方法/参数的文档

#### Swagger2 使用注解来编写文档：

Swagger2编写接口文档相当简单，只需要在控制层（Controller）添加注解来描述接口信息即可。例如：

```java
package com.hehe.controller;

@Api("用户信息管理")
@RestController
@RequestMapping("/user/*")
public class UserController {

    private final static List<User> userList = new ArrayList<>();

    {
        userList.add(new User("1", "admin", "123456"));
        userList.add(new User("2", "jacks", "111111"));
    }

    @ApiOperation("获取列表")
    @GetMapping("list")
    public List userList() {
        return userList;
    }

    @ApiOperation("新增用户")
    @PostMapping("save")
    public boolean save(User user) {
        return userList.add(user);
    }

    @ApiOperation("更新用户")
    @ApiImplicitParam(name = "user", value = "单个用户信息", dataType = "User")
    @PutMapping("update")
    public boolean update(User user) {
        return userList.remove(user) && userList.add(user);
    }

    @ApiOperation("批量删除")
    @ApiImplicitParam(name = "users", value = "N个用户信息", dataType = "List<User>")
    @DeleteMapping("delete")
    public boolean delete(@RequestBody List<User> users) {
        return userList.removeAll(users);
    }
}

package com.hehe.entity;

public class User {

    private String userId;
    private String username;
    private String password;

    public User() {

    }

    public User(String userId, String username, String password) {
        this.userId = userId;
        this.username = username;
        this.password = password;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        User user = (User) o;

        return userId != null ? userId.equals(user.userId) : user.userId == null;
    }

    @Override
    public int hashCode() {
        int result = userId != null ? userId.hashCode() : 0;
        result = 31 * result + (username != null ? username.hashCode() : 0);
        result = 31 * result + (password != null ? password.hashCode() : 0);
        return result;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}

```

# 4\. 查阅接口文档

编写文档完成之后，启动当前项目，在浏览器打开：
[ [http://localhost:8080/swagger-ui.html](https://link.jianshu.com?t=http://localhost:8080/swagger-ui.html) ] , 看到效果如下：

![](/assets/blogImg/180401-SpringBoot+Swagger2_8.png)

来看看save 方法的具体描述，可以看到Swagger 2.7.0 版本对参数列表进行了改版，直接输入参数，更方便进行测试操作：

![](/assets/blogImg/180401-SpringBoot+Swagger2_9.png)

# 5\. 测试接口

Swagger2的强大之处不仅在于快速生成整洁优雅的RestAPI文档，同时支持接口方法的测试操作（类似于客户端PostMan）。

以查询用户列表为例，无参数输入，直接点击“试一下”按钮：

![](/assets/blogImg/180401-SpringBoot+Swagger2_10.png)

然后可以看到以JSON格式返回的用户列表信息，很方便有木有：

![](/assets/blogImg/180401-SpringBoot+Swagger2_11.png)

好了，关于Swagger2在项目中的使用教程就到这里。

源码下载： [SpringBoot +Swagger2 使用教程](https://link.jianshu.com?t=https://github.com/yizhiwazi/springboot-socks/tree/master/springboot-swagger2)

专题阅读：[《SpringBoot 布道系列》](https://www.jianshu.com/p/964370d9374e)

作者：yizhiwazi
链接：https://www.jianshu.com/p/7e543f0f0bd8
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。





