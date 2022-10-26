---
title: helm安装和常用命令
date: Wed Oct 26 2022 16:29:03
tags:
	- helm
---


# 安装helm

1. 访问helm的github发布地址，下载最新的发布版本：https://github.com/helm/helm/releases
2. 解压(tar -zxvf helm-v3.0.0-linux-amd64.tar.gz)
3. 在解压目中找到helm程序，移动到`/usr/local/bin`目录中(mv linux-amd64/helm /usr/local/bin/helm)
4. 安装完成。执行`helm help`显示帮助，代表安装成功。

其它安装方式，可参考：https://helm.sh/zh/docs/intro/install/

# 增、删、改、查仓库

- 增加仓库`helm repo add 仓库名称 仓库地址`
- 删除仓库`helm repo remove 仓库名`
- 更新仓库`helm repo update`
- 查看所有已安装仓库`helm repo list`

# 查找chart

- 在官方仓库中搜索chart包  
  `helm search hub 包名` # 包名支持模糊搜索
- 在个人添加的仓库中搜索chart包  
  `helm search repo 包名`  # 搜索已经(用 helm repo add)加入到本地helm客户端的仓库。该命令只搜索本地数据，不需要连接网络。
  
# 下载chart

`helm fetch 包名`  

# 安装发布chart到k8s

- 通过helm仓库在线安装发布  
  `helm install 发布名 包名` # 如：`helm install happy-panda stable/mariadb` 安装 mariadb 并发布到k8s集群，发布名称为 happy-panda 。
- 通过本地chart包安装
  `helm install 发布名 压缩包路径` # 如 `helm install foo foo-0.1.1.tgz`
- 通过解压的chart目录安装
  `helm install 发布名 解压目录路径` # 如 `helm install foo path/to/foo`
- 通过URL在线安装
  `helm install 发布名 URL地址` # 如 `helm install foo https://example.com/charts/foo-1.2.3.tgz`
  
在命令中添加`--debug --dry-run`可以debug试运行。并不会发布到k8s。 
  

# 安装chart时自定义参数

安装时有两种方式传递配置数据：
- --values (或-f)：指定一个重写的YAML文件。可以指定多个，最右边的文件优先。如：`helm install happy-panda -f custom-value.cnf stable/mariadb`
- --set: 使用命令行指定覆盖内容。多行可以使用`,`分隔，如：`helm install happy-panda  --set a=b,c=d stable/mariadb`

# 跟踪chart的发布状态

`helm status 发布名称`

# 查看所有的发布

`helm list` # 查看当前命名空间所有的发布
`helm list --namespace=name1` # 查看 name1 命名空间所有的发布

# 升级chart

当chart新版本发布时，或者您想改变发布的配置，可以使用 helm upgrade 命令。如：

`helm upgrade -f panda.yaml happy-panda stable/mariadb`  

上面这个例子中，happy-panda 发布使用了同样的chart升级，但用了一个新的YAML文件。每次升级版本号将加1，新版本将使用新文件中指定的参数。我们可以使用 `helm get values` 查看新内容是否生效。

# 回滚chart

- 查看某个发布的所有版本
  `helm history happy-panda` # 查看 happy-panda 发布的所有版本
- 回滚发布到一个指定的版本
  `helm rollback happy-panda 1` # 回滚 happy-panda 到版本 1
  
# 卸载一个发布

`helm uninstall happy-panda` # 卸载 happy-panda 

更多详情可参考：
官方文档：https://helm.sh/zh/docs/
用户指南：https://whmzsu.github.io/helm-doc-zh-cn/



（完）

