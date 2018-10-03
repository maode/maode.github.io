---
title: Linux安装nvm和smart-npm和配置hexo
date: 2018-04-15 15:32:41
tags:
    - nodejs
    - nvm
    - smart-npm
    - hexo
---
用Mint软件源中安装的nodejs和npm可能是版本太低，试了各种方法总是无法成功运行hexo。于是想着升级一下版本，据说源码安装nodejs耗时特别久，而nvm是大家比较推荐的一款nodejs版本管理工具，可以在系统中安装管理多个不同版本的nodejs，挺好，就他了。利用nvm安装完nodejs后又发现通过npm命令安装需要的插件时，一直报错443,访问不到资源，于是又Google了一下，最后在nrm和smart-npm中选择了后者。

<!-- more -->

## 安装nvm
打开终端，执行：
```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
```
或者执行：
```bash
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
```
nvm的GitHub地址：https://github.com/creationix/nvm

## 安装smart-npm
打开终端，执行：
```bash
npm install --global smart-npm --registry=https://registry.npm.taobao.org/
```
然后再安装插件时将`npm install xxx`换成`snpm install xxx`就好了，我没有听从建议替换原生npm命令，我觉得这样就挺好。

smart-npm的GitHub地址：https://github.com/qiu8310/smart-npm

## 配置hexo
因为原来在Windows上写博客的时候，把hexo的相关配置和markdown源文件都已经提交到GitHub了，所以找一个合适的目录，执行以下命令，将原来的配置信息和文章源文件拉下来。

`git clone git@github.com:maode/maode.github.io.git`

准备一个用来放hexo博客文件的目录，在该目录下执行`hexo init`初始化hexo,然后生成了默认的一些配置文件，其中package.json是重点，因为我Linux上安装的hexo和Windows上的版本不一样，所以，不能直接将上面“git clone”下来的所有文件覆盖到该目录，要先把拉下来的原来Windows下的package.json备份一下。

进入刚才拉取下来的文件目录中执行`mv package.json package.json.win`将旧的package.json重命名为package.json.win。然后全选该目录下的所有文件 复制-->粘贴 到刚才新初始化好的hexo博客目录下，**替换所有的同名文件**。搞定！结束！还是原来的味道，还是以前的配方。

提交推送源文件到关联的hexo分支还是执行："git add commit push"。

生成页面并推送到`_config.yml`配置文件中设置的master分支时还是执行：“hexo g hexo d”。

（完）

关联文章：[hexo搭建GitHub博客过程 ](https://maode.github.io/2017/09/03/170903-hexo-blog-course/)

