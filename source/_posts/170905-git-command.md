---
title: Git常用命令
date: 2017-09-05 16:32:41
tags:
	- Git
---
### 设置

- 告诉Github，你要使用的用户名
`$ git config --global user.name "Your Name Here"`
- 设置邮箱 
`$ git config --global user.email "your_email@example.com"`
- 查看用户名和邮箱
`$ git config user.name[user.email]`
- 查看所有配置项
`$ git config -l[--list]`

<!-- more -->

### 日常

- 克隆项目到本地(将项目拉到本地，包含远程版本库的所有历史提交)
`$ git clone https://github.com/maode/workInfo.git`
- 克隆项目到本地（`--depth <depth>`浅克隆，只包含远程版本库的<depth> + 1个历史提交）
`$ git clone --depth 1 https://github.com/maode/workInfo.git`
- 将所有的改动加入缓存区
`$ git add .`
- 将改动提交到本地仓库(提交时添加-a可省略前一步加入缓存区的操作)
`$ git commit [-a] -m "备注信息"`
- 更新
`$ git pull`
- 推送
`$ git push`
- 设置远程版本库地址
`$ git remote add origin https://github.com/maode/workInfo.git`
- 手动建立追踪关系(该命令表示将本地master分支与origin主机的next分支建立追踪关系)
`$ git branch --set-upstream master origin/next`
- 为当前分支最后一次commit打个轻量级标签,标签名为“v1.0”
`$ git tag v1.0`
- 为当前分支最后一次commit打个带说明的标签。`-a`指定标签名，`-m`指定说明文字。
`$ git tag -a v0.1 -m "这是标签说明"`
- 将本地仓库打的标签推送到远程仓库
`$ git push origin --tags`

### pull

- 格式
`$ git pull <远程主机名> <远程分支名>:<本地分支名>`

- 取回origin主机的next分支，与本地的test分支合并
`$ git pull origin next:test`

- 取回origin主机的next分支，与本地当前分支合并
`$ git pull origin next`(省略了本地分支名，就表示与本地当前分支合并)

- 取回origin主机与本地的当前分支有追踪关系的分支，与本地当前分支合并
`$ git pull origin`（如果当前分支与远程分支存在追踪关系，git pull就可以省略远程分支名）

- 取回本地当前分支唯一对应的远程追踪分支，与本地当前分支合并
`$ git pull`(如果当前分支只有一个追踪分支，连远程主机名都可以省略)

### push 

- 格式
`$ git push <远程主机名> <本地分支名>:<远程分支名>`

- 将本地的master分支推送到origin远程主机的master分支。此处省略了origin主机的分支名，如果远程分支不存在，则会被新建。
`$ git push origin master`

- 如果当前分支与远程分支存在追踪关系，则来源地分支名和目的地分支名都可以省略。如下：
`$ git push origin`

- 如果当前分支只和一个远程主机有追踪分支，那么主机名也可以省略。如下：
`$ git push`

- 如果当前分支与多个主机存在追踪关系，则可以使用-u选项指定一个默认主机，设置完成后就可以不加任何参数使用git push进行远程推送了。如下：
`$ git push -u origin master`

- 删除指定的远程分支
`$ git push origin :master` 或 `$ git push origin --delete master`
(`$ git push origin :master` 该写法省略了本地分支名相当于推送一个空的本地分支到origin主机的master分支)

### tag

- 为最后一次commit创建一个轻量级标签
`$ git tag <tagname> `
- 为最后一次commit创建一个带说明的标签
`$ git tag -a <tagname> -m <msg>`
- 查看历史提交的'commit id'
`$ git log --pretty=oneline`
- 为指定的'commit id'创建一个轻量级标签
`$ git tag <tagname> <commit id>`
- 查看所有标签
`$ git tag`
- 查看某个标签的信息
`$ git show <tagname>`
- 用私钥签名一个标签【需已安装gpg（GnuPG）,没有秘钥时会报错】
`$ git tag -s <tagname> -m <msg> <commit id>`
- 用 GPG 来验证签名标签【需要有签署者的公钥，否则会报错】
`$ git tag -v <tagname>`
- 推送指定标签到远程仓库
`$ git push origin <tagname>`
- 推送所有标签到远程仓库
`$ git push origin --tags`
- 删除本地仓库标签
`$ git tag -d <tagname>`
- 删除远程仓库的标签【用推送的空的同名版本的方式达到删除线上版本的目的】
`$ git push origin :refs/tags/<tagname>`
- 获取远程仓库某个标签对应的版本
`$ git fetch origin tag <tagname>`

### Demo

**创建一个新的[本地]资源库,并推送到https://github.com/maode/workInfo.git**

1. 在本地创建"README.md"文件
`$ touch README.md`
2. 初始化资源库【初始化一个本地未加入版本控制的现有的项目】
`$ git init`
3. 添加文件到版本库
`$ git add README.md`
4. 提交更改到本地版本库
`$ git commit -m "first commit"`
5. 设置远程版本库地址，并起名为origin
`$ git remote add origin https://github.com/maode/workInfo.git`
6. 推送到远程版本库【`-u`参数表示将远程库`origin`绑定为默认的远程库。以后使用简单的`git push`指令时，就默认提交到该远程库】
`$ git push -u origin master`

**将本地已经存在的仓库推送到远程仓库**
1. 设置远程仓库地址
`$ git remote add origin git@github.com:maode/xxx.git`
2. 推送
`$ git push -u origin master`


比较详细的介绍可以参考[官方文档](https://git-scm.com/book/zh/v2)
或者参考这里：http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html
或者参考下面这张图（图片来源于网络）：
![git命令拓普图](https://raw.githubusercontent.com/maode/docs/master/git%E5%91%BD%E4%BB%A4%E6%8B%93%E6%99%AE%E5%9B%BE.png)