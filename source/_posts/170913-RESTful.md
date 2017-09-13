---
title: 对RESTful的一些理解
date: 2017-09-13 15:32:41
tags:
	- RESTful
---

## RESTful

一种架构方式、编码风格。
***
感觉RESTful模式的关注点在于“资源”，一切皆资源，客户端对服务端发出的所有请求皆是针对某个资源的请求。RESTful对资源的动作不会过分关注，因为针对所有资源的状态和动作都是统一的。

比如：

### RESTful 风格

<!-- more -->

以下请求当中是没有包含动作和状态的。

```
.../.../RESTful/person	#这是请求资源 “人”
.../.../RESTful/books	#这是请求资源 “书”
```
### 非RESTful 风格
以下请求当中是包含有动作或状态的。

```
.../.../req/addPerson	#包含了动作 “增加” 一个人
.../.../req/paidBooks	#包含了状态 “付费” 书籍
```
### RESTful 统一的动作

| 动作| 一组资源的URI，比如`http://example.com/resources/` | 单个资源的URI，比如`http://example.com/resources/142` |
| :-: | :-: | :-: |
| GET | **列出**URI，以及该资源组中每个资源的详细信息（后者可选）。 | **获取**指定的资源的详细信息，格式可以自选一个合适的网络媒体类型（比如：XML、JSON等） |
| PUT | 使用给定的一组资源**替换**当前整组资源。 | **替换/创建**指定的资源。并将其追加到相应的资源组中。 |
| POST | 在本组资源中**创建/追加**一个新的资源。该操作往往返回新资源的URL。 | 把指定的资源当做一个资源组，并在其下**创建/追加**一个新的元素，使其隶属于当前资源。 |
| DELETE | **删除**整组资源。 | **删除**指定的元素。 |

**另还有：**

#### `HEAD`

`HEAD`方法与`GET`方法一样，都是向服务器发出指定资源的请求。但是，服务器在响应`HEAD`请求时不会回传资源的内容部分，即：响应主体。这样，我们可以不传输全部内容的情况下，就可以获取服务器的响应头信息。`HEAD`方法常被用于客户端查看服务器的性能。

#### `CONNECT`

`CONNECT`方法是`HTTP/1.1`协议预留的，能够将连接改为管道方式的代理服务器。通常用于[SSL](http://itbilu.com/other/relate/N16Uaoyp.html)加密服务器的链接与非加密的HTTP代理服务器的通信。

#### `OPTIONS`

`OPTIONS`请求与`HEAD`类似，一般也是用于客户端查看服务器的性能。 这个方法会请求服务器返回该资源所支持的所有HTTP请求方法，该方法会用'*'来代替资源名称，向服务器发送`OPTIONS`请求，可以测试服务器功能是否正常。JavaScript的[XMLHttpRequest](http://itbilu.com/javascript/js/VkiXuUcC.html)对象进行`CORS`跨域资源共享时，就是使用`OPTIONS`方法发送嗅探请求，以判断是否有对指定资源的访问权限。

#### `TRACE`

`TRACE`请求服务器回显其收到的请求信息，该方法主要用于HTTP请求的测试或诊断。

#### `PATCH`

`PATCH`方法出现的较晚，它在2010年的[RFC 5789](http://tools.ietf.org/html/rfc5789)标准中被定义。`PATCH`请求与`PUT`请求类似，同样用于资源的更新。二者有以下两点不同：

*   但`PATCH`一般用于资源的部分更新，而`PUT`一般用于资源的整体更新。
*   当资源不存在时，`PATCH`会创建一个新的资源，而`PUT`只会对已在资源进行更新。

### 参考
https://zh.wikipedia.org/wiki/REST#cite_note-3
http://www.ruanyifeng.com/blog/2011/09/restful
https://itbilu.com/other/relate/EkwKysXIl.html
