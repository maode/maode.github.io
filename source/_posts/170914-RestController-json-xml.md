---
title: \@RestController返回json和xml数据
date: 2017-09-14 15:32:41
tags:
	- springMVC
---

## 实体类（POJO）

``` java
package org.code0.restController.model;

import javax.xml.bind.annotation.XmlRootElement;
/**  
 * @Title: Message.java
 * @Package org.code0.restController.model
 * @Description: Message.java
 * @author Code0   
 * @date 2017年9月14日 上午11:15:16 
 */
public class Message {

	private String name;
	
	private String text;

	/** @return name */
	public String getName() {
		return name;
	}

	/** @param name 要设置的 name */
	public void setName(String name) {
		this.name = name;
	}

	/** @return text */
	public String getText() {
		return text;
	}

	/** @param text 要设置的 text */
	public void setText(String text) {
		this.text = text;
	}
}

```
<!-- more -->

## Controller
``` java
package org.code0.restController.controller;

import org.code0.restController.model.Message;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;


/**  
 * @Title: TestRestController.java
 * @Package org.code0.restController.controller
 * @Description: TestRestController.java
 * @author Code0   
 * @date 2017年9月14日 上午11:13:59 
 */
@RestController
public class TestRestController {

	@RequestMapping("/testRestController/{text}")
	@ResponseBody
	public  Message message(@PathVariable String text){
		
		Message msg=new Message();
		msg.setName("jhon");
		msg.setText(text);
		return msg;
	}
}

```
## 返回json
### 添加依赖
``` xml
<!-- jackson, RestController返回json格式数据依赖 -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.9.1</version>
</dependency>

```
访问： http://localhost:8080/testRestController/参数 或 http://localhost:8080/testRestController/参数.json
返回： {"name":"jhon","text":"参数"}

## 返回xml
**不需要额外增加第三方依赖，只需在实体类上添加`@XmlRootElement`注解即可。**
``` java
@XmlRootElement//该注解设置请求返回xml
public class Message {

	private String name;
	
	private String text;
		…………
		…………
```

访问：http://localhost:8080/testRestController/xxx 或 http://localhost:8080/testRestController/xxx.xml
返回：
``` xml
<message>

<name>jhon</name>

<text>xxx</text>

</message>
```
实体类上添加`@XmlRootElement`注解后，默认返回`xml`格式了，如果要返回`json`，url就要加上`.json`的后缀了。



