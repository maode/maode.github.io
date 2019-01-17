---
title: hexo搭建GitHub博客过程
date: 2017-09-03 15:32:41
tags:
	- hexo
	- GitHub
---
## 环境要求
**nodejs，git**
- 安装nodejs：[nodejs官网](https://nodejs.org)
- 安装git：[git for windows](https://git-for-windows.github.io)

<!-- more -->

## hexo配置
因为hexo是使用nodejs编写的一个博客框架，所以安装完nodejs后，直接打开cmd窗口执行以下命令即可完成hexo的安装.
以下安装命令为当前安装时的命令,随着hexo版本升级命令可能会有变动,具体再安装时可参考官网:https://hexo.io

### hexo安装
```bash
$ npm install hexo-cli -g
```
安装完成后执行以下命令显示hexo版本号即为安装成功
```bash
$ hexo -v
```
### hexo初始化
选择或创建一个用来存放hexo博客文件的文件夹如`D:\Blog`，然后进行入到该路径下执行命令。
```bash
$ hexo init	#初始化，完成后会在/source/_posts/目录下生成一篇hello World文章
$ hexo server	#启动本地web服务
```
打开浏览器输入 http://localhost:4000 即可看到生成的效果。

### hexo更换主题
hexo默认主题为 landscape，可更换为其它主题。
下载安装 `yilia` 主题：
进入hexo博客根路径下执行以下命令。
```bash
$ git clone https://github.com/litten/hexo-theme-yilia.git themes/yilia
```
主题下载完成后会存放在 `/themes/` 路径下。
修改默认主题为 `yilia`：
打开hexo根路径下的 `_config.yml` 文件，找到`theme`选项，修改为`yilia`。
`theme: yilia`

### 配置新主题
打开 /themes/yilia/_config.yml 文件，根据实际需求修改配置 [yilia主题配置](#yilia主题配置)。完整的配置例子，可以参考[主题作者的博客备份](https://github.com/litten/BlogBackup)。

修改完主题的配置后执行 `hexo server` 访问 http://localhost:4000 查看效果。

### 创建新文章
```bash
$ hexo new 文章名称	#创建一篇新文章
$ hexo generate		#将文章生成为静态页面
```
### 部署博客静态页到GitHub
修改`/_config.yml`文件。
```yml
deploy:
	type: git
	repo: git@github.com:maode/maode.github.io.git
	branch: master
```
安装git部署插件
```bash
$ npm install hexo-deployer-git --save
```
执行部署命令
```bash
$ hexo deploy
```
部署命令执行后，会将`/public`路径下生成的所有静态文章页面部署至GitHub。
访问自己的GitHub的博客地址，查看部署情况。

**到这里博客配置与发布就算全部结束了，以后就可以安装上面的步骤进行文章的正常创建以及发布了。**

***

### 部署hexo文件和博客静态页至GitHub同一个repo下

**该需求产生的原因：**
因为`hexo deploy`命令只会把每篇文章编译后的静态页面部署至GitHub，而文章的源码`.md`文件，还有hexo博客框架的相关配置只是保存在了当前的电脑上。如果哪天更换了电脑，或者其他原因导致本地的文件丢失了。就要再进行各种配置会比较麻烦，所以也可将文章源码以及hexo框架的相关配置一同部署至GitHub。

**该需求的解决方法：**
因为hexo文件夹下本身就包含一个`.gitignore`文件，而且该文件中已经将与框架配置无关的插件、日志、静态页忽略掉了，所以可直接将hexo文件夹以创建普通Git项目的方式部署至GitHub，为了便于管理也可以不再新建一个repo，直接在静态博客repo下创建一个分支存放也可。
如以分支的方式存放，则建议在GitHub创建好博客repo后，立即创建一个分支。因为我们两个分支存放的是完全不同的文件。而不是派生关系。

**过程如下：**
1. 在GitHub创建博客repo（记得勾选“用README初始化仓库”选项，否则无法进行下一步的分支创建）。
2. 创建分支hexo
3. 设置默认分支为hexo（因为博客静态页文件是执行`hexo deploy`命令进行部署的，而hexo框架及文章源码需要手动执行Git命令进行部署，将hexo设置为默认分支可以在执行`git push`命令时省略指定分支参数，方便些。）
4. 使用`git clone git@github.com:maode/maode.github.io.git`命令克隆hexo分支到本地。
5. 打开clone好的`maode.github.io`目录，将`.git/`文件夹和`README.md`文件复制到hexo文件目录下。复制完成后在hexo文件目录下执行`git branch`命令应该显示当前在hexo分支下。
6. 依次执行 `git add . 、 git commit 、git push`命令部署本地hexo文件至GitHub的hexo分支。

这样就结束了，以后每当写了新的文章，就可以执行`hexo deploy`命令部署文章静态页至master分支，执行Git命令部署hexo文件和源码文件至hexo分支。

### 更换电脑或丢失文件后的操作
1. 确认电脑环境已配置好（就是装好nodejs和Git） 
2. 安装初始化hexo和git-deployer插件的.如:
 `npm install hexo-cli -g ` #全局安装hexo
 `hexo init Blog ` #在当前目录创建Blog文件夹,并将其初始化为hexo博客目录
 `npm install hexo-deployer-git --save ` #安装git部署插件
3. 删除hexo自带的hello-world文章。(将博客根目录下的`source`文件夹删除即可)
4. 使用`git clone git@github.com:maode/maode.github.io.git`命令克隆hexo分支到本地某个目录下。
5. 进入到clone好的`maode.github.io`目录下,将所有内容覆盖复制到刚刚初始化完的`Blog`目录下。

以上便完成了hexo更换电脑后的迁移,可执行`hexo server`命令查看迁移后的效果，如提示缺少插件，根据提示安装相应的插件即可。



***
## 附录：
### yilia主题配置

```
# Header

menu:
  主页: /

# SubNav
subnav:
  github: "https://github.com/maode"
  #weibo: "#"
  rss: /atom.xml
  #zhihu: "#"
  #qq: "#"
  #weixin: "#"
  #jianshu: "#"
  #douban: "#"
  #segmentfault: "#"
  #bilibili: "#"
  #acfun: "#"
  #mail: "mailto:litten225@qq.com"
  #facebook: "#"
  #google: "#"
  #twitter: "#"
  #linkedin: "#"

rss: /atom.xml

# 是否需要修改 root 路径
# 如果您的网站存放在子目录中，例如 http://yoursite.com/blog，
# 请将您的 url 设为 http://yoursite.com/blog 并把 root 设为 /blog/。
root: 

# Content

# 文章太长，截断按钮文字
excerpt_link: more
# 文章卡片右下角常驻链接，不需要请设置为false
show_all_link: '展开全文'
# 数学公式
mathjax: false
# 是否在新窗口打开链接
open_in_new: false

# 打赏
# 打赏type设定：0-关闭打赏； 1-文章对应的md文件里有reward:true属性，才有打赏； 2-所有文章均有打赏
reward_type: 2
# 打赏wording
reward_wording: '谢谢你请我吃糖果'
# 支付宝二维码图片地址，跟你设置头像的方式一样。比如：/assets/img/alipay.jpg
alipay: 
# 微信二维码图片地址
weixin: 

# 目录
# 目录设定：0-不显示目录； 1-文章对应的md文件里有toc:true属性，才有目录； 2-所有文章均显示目录
toc: 1
# 根据自己的习惯来设置，如果你的目录标题习惯有标号，置为true即可隐藏hexo重复的序号；否则置为false
toc_hide_index: true
# 目录为空时的提示
toc_empty_wording: '目录，不存在的…'

# 是否有快速回到顶部的按钮
top: true

# Miscellaneous
baidu_analytics: ''
google_analytics: ''
favicon: /assets/img/favicon.ico

#你的头像url
avatar: /assets/img/plan.jpg

#是否开启分享
share_jia: true

#评论：1、多说；2、网易云跟帖；3、畅言；4、Disqus 不需要使用某项，直接设置值为false，或注释掉
#具体请参考wiki：https://github.com/litten/hexo-theme-yilia/wiki/

#1、多说
duoshuo: false

#2、网易云跟帖
wangyiyun: false

#3、畅言
changyan_appid: false
changyan_conf: false

#4、Disqus 在hexo根目录的config里也有disqus_shortname字段，优先使用yilia的
disqus: false

# 样式定制 - 一般不需要修改，除非有很强的定制欲望…
style:
  # 头像上面的背景颜色
  header: '#4d4d4d'
  # 右滑板块背景
  slider: 'linear-gradient(200deg,#a0cfe4,#e8c37e)'

# slider的设置
slider:
  # 是否默认展开tags板块
  showTags: false

# 智能菜单
# 如不需要，将该对应项置为false
# 比如
#smart_menu:
#  friends: false
smart_menu:
  innerArchive: '所有文章'
  friends: false
  aboutme: '关于我'

friends:
  友情链接1: http://localhost:4000/
  友情链接2: http://localhost:4000/
  友情链接3: http://localhost:4000/
  友情链接4: http://localhost:4000/
  友情链接5: http://localhost:4000/
  友情链接6: http://localhost:4000/

aboutme: 很惭愧<br><br>只做了一点微小的工作<br>谢谢大家
```
