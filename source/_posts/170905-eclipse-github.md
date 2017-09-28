---
title: Eclipse与GitHub之间的操作
date: 2017-09-02 15:32:41
tags:
	- Eclipse
	- GitHub
---
## Eclipse生SSH Key添加到GitHub

window → preference → general → network connection → SSH2 → Key Management → generate RSA Key... → ave private key...【默认保存在“~/.ssh/”目录下】→apply.

点击Export Via SFTP,在弹出窗口填入 `git@github.com`，然后会在ssh目录中生成一个`known_hosts`文件，该文件用来保存当前密钥对应的已知远程主机列表，如果没有该文件会报错。连不上Github。
若出现： `Failed to export ssh key to remote server` 的警告，不需理会。

然后复制中间文本域中的公钥到GitHub就可以了。

关于`known_hosts`文件的说明可以参考该文章：[SSH原理与运用](http://www.ruanyifeng.com/blog/2011/12/ssh_remote_login.html)

<!-- more -->

## 从GitHub获取项目到本地Eclipse

打开Eclipse》点击File》Import》Git》Projects from Git》Clone URI（输入GitHub项目的URL）》Next  （选择本地存放目录，视具体情况可放在Eclipse的工作空间中，比较方便管理）》Next（下载完成后就代码就被抓取到指定目录了）》选择 Use the New Project wizard》【然后根据具体项目类型 next……】》Finish。

## 导入本地已存在的项目至Eclipse，如maven项目：

File》Import》Maven【Existing Maven Projects】》Next【Browser选择刚才下载好的项目】》Finish。

## 将本地Eclipse项目提交至GitHub

**创建并关联Eclipse项目至本地repository：**

在Eclipse项目上单击右键》Team》Share project【勾选Use or create repository in parent folder of project,,然后在弹出的对话框中选择当前project】》点击Create repository》Finish。

**提交项目至GitHub：**

在github创建新的repository。

在项目上单击右键Team》commit【输入commit msg、author、committer】》Commit或Commit and Push.

在项目上单击右键Team》Remote》Push》在URI中输入GitHub项目的URL、用户名、密码》Next》Source ref:选择master[branch]，会自动填充Source ref:和Destination ref:为“refs/heads/master”》点击 Add all Branch Spec》Finish。

在Crete repository前会有一个“Creation of repositories in the Eclipse workspace is not recommended”提示，不建议在Eclipse的工作空间中创建本地repository，【因为可能引发一连串的问题，或影响性能】可选在其它路径下创建，随意，放在工作空间中比较方便管理，目前还没发现什么问题，有问题再说吧！

--------------------------------------------------------------------------------
## 常用操作：
### 配置
**Remote：** 远程仓库，可在此处配置多个不同的远程仓库。

【push...】  可以将项目push到指定的远程仓库地址。

【Fetch From...】  可从指定的远程仓库地址抓取项目到本地。

【Configure Push to Upstream...】配置推送的远程仓库。

【Configure Fetch from Upstream...】配置抓取的远程仓库。


![](/assets/blogImg/170905-eclipse-github-1.png)

### 日常
【Pull】	更新远程仓库的变更信息至本地仓库，比较常用，每次远程版本库有变更都需要先Pull一下。

【commit...】  提交，提交至本地仓库。

【Push to Upstream】  将本地仓库推送至当前默认远程仓库的默认分支。

【Fetch from Upstream】  从当前默认远程仓库的默认分支抓取项目到本地仓库。

【Push Branch...】  将本地仓库推送至指定远程仓库的指定分支。


![](/assets/blogImg/170905-eclipse-github-2.png)
