---
title: java POJO 重写toString方法工具
date: 2017-09-12 15:32:41
tags:
	- toString
	- java

---
## fastjson
依赖：

``` xml
<!-- fastjson -->
<dependency>
  <groupId>com.alibaba</groupId>
  <artifactId>fastjson</artifactId>
  <version>1.2.38</version>
</dependency>
```
使用：

``` java
@Override
public String toString() {

	return JSON.toJSONString(this, new SerializerFeature[]{
			SerializerFeature.WriteMapNullValue, 
			SerializerFeature.WriteNullListAsEmpty,
            SerializerFeature.WriteNullStringAsEmpty, 
            SerializerFeature.WriteNullNumberAsZero, 
            SerializerFeature.WriteNullBooleanAsFalse,
            SerializerFeature.UseISO8601DateFormat});
}
```
忽略属性：
在属性上加注解 `@JSONField(serialize=false)  ` 
SerializerFeature详解见 [附录](#附录：)

<!-- more -->

## ReflectionToStringBuilder
依赖：

``` xml
<!-- lang3 -->
<dependency>
  <groupId>org.apache.commons</groupId>
  <artifactId>commons-lang3</artifactId>
  <version>3.6</version>
</dependency>
```
使用：
``` java
//普通使用，定义返回数据格式为JSON	
@Override
public String toString() {
	
	return ReflectionToStringBuilder.toString(this, ToStringStyle.JSON_STYLE);

}
//过滤字段	
@Override
public String toString() {
	
	return ReflectionToStringBuilder.toStringExclude(this, "firstName", "dob");

}
//过滤字段，同时定义数据格式
//
@Override
public String toString() {
	
		ReflectionToStringBuilder rtsb= new ReflectionToStringBuilder(this, ToStringStyle.JSON_STYLE);
		rtsb.setExcludeFieldNames("firstName","dob");
		return rtsb.toString();

}
```
感觉有点麻烦，当前类里没发现更好的写法，就先这么写着吧！更喜欢fastjson。



## 附录：
### SerializerFeature属性 
参考：http://blog.csdn.net/u010246789/article/details/52539576

| 名称 | 含义 |
|:-:|:-:|
| QuoteFieldNames | 输出key时是否使用双引号,默认为true |
| UseSingleQuotes | 使用单引号而不是双引号,默认为false |
| WriteMapNullValue | 是否输出值为null的字段,默认为false |
| WriteEnumUsingToString | Enum输出name()或者original,默认为false |
| UseISO8601DateFormat | Date使用ISO8601格式输出，默认为false |
| WriteNullListAsEmpty | List字段如果为null,输出为[],而非null |
| WriteNullStringAsEmpty | 字符类型字段如果为null,输出为”“,而非null |
| WriteNullNumberAsZero | 数值字段如果为null,输出为0,而非null |
| WriteNullBooleanAsFalse | Boolean字段如果为null,输出为false,而非null |
| SkipTransientField | 如果是true，类中的Get方法对应的Field是transient，序列化时将会被忽略。默认为true |
| SortField | 按字段名称排序后输出。默认为false |
| WriteTabAsSpecial | 把\t做转义输出，默认为false  `不推荐`
| PrettyFormat | 结果是否格式化,默认为false |
| WriteClassName | 序列化时写入类型信息，默认为false。反序列化是需用到 |
| DisableCircularReferenceDetect | 消除对同一对象循环引用的问题，默认为false |
| WriteSlashAsSpecial | 对斜杠’/’进行转义 |
| BrowserCompatible | 将中文都会序列化为\uXXXX格式，字节数会多一些，但是能兼容IE 6，默认为false |
| WriteDateUseDateFormat | 全局修改日期格式,默认为false。JSON.DEFFAULT_DATE_FORMAT = “yyyy-MM-dd”;JSON.toJSONString(obj, SerializerFeature.WriteDateUseDateFormat); |
| DisableCheckSpecialChar | 一个对象的字符串属性中如果有特殊字符如双引号，将会在转成json时带有反斜杠转移符。如果不需要转义，可以使用这个属性。默认为false |
| NotWriteRootClassName | 含义 |
| BeanToArray | 将对象转为array输出 |
| WriteNonStringKeyAsString | 含义 |
| NotWriteDefaultValue | 含义 |
| BrowserSecure | 含义 |
| IgnoreNonFieldGetter | 含义 |
| WriteEnumUsingName | 含义 |

