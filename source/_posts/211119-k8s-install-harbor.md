---
title: k8s集群安装harbor
date: Wed Oct 26 2022 16:38:02
tags:
	- k8s
	- harbor
---

# 安装 helm
在k8s中最简单的方式是使用 helm 进行安装，所以先安装好 helm 此处略过 helm 安装步骤，假设已经安装好了。   

# 安装发布

1. 通过 harbor-helm 仓库在线安装（网络好的情况下用这个方法）

   ```bash
   #添加 harbor-helm 仓库
   helm repo add harbor https://helm.goharbor.io
   #debug 试安装一下（如果很熟练了，可略过该步骤）
   helm install my-release harbor/harbor
   helm install --debug --dry-run   发布名 -f 自定义配置文件  --namespace 发布到哪个命名空间 harbor/harbor |sed 'w ./发布内容写入到某文件.yaml'
   #正式安装发布（发布到 inner-harbor 命令空间，发布名为 harbor ，使用 value-custom.yaml 配置文件，将发布结果写入 ./deploy.yaml 文件）
   helm install harbor -f values-custom.yaml  --namespace inner-harbor harbor/harbor |sed 'w ./deploy.yaml'
   ```
   因为要去下载镜像和chart包，所以要等很长时间。
   
2. 手动下载镜像包和chart包安装（网络不好的情况下用这个方法）   
 - 访问 harbor-helm 的 [Release](https://github.com/goharbor/harbor-helm/releases) 页面，下载最新的发布包，同时记住该发布包对应的镜像版本（Harbor OSS version）。
 - 访问 harbor 的 [Release](https://github.com/goharbor/harbor/releases) 页面，根据刚才 harbor-helm 的 Release 下载界面标注的 Harbor OSS version 下载对应版本的 harbor 离线镜像安装包。
 - 将 harbor 的离线安装包上传到所有的 k8s work 节点。然后解压获得镜像离线压缩包。然后使用`load`命令加载镜像。如：`docker load -i harbor.v2.0.4.tar.gz`。
 - 把 harbor-helm 压缩包上传到 k8s的master节点，并解压。比如解压后的目录为`/root/harbor-helm-1.4.4` 。
 - 进入解压后的目录，根据 `values.yaml` 文件创建自定义配置文件 `values-custom.yaml` ，或者找找以前的复制过来一份。主要关心的参数如下：       
 
    | 参数 | 说明 |
    | - | - |
    | `expose.ingress.hosts.core` | harbor的访问域名，根据情况进行修改。|
    | `expose.ingress.hosts.notary` | harbor notary的访问域名，根据情况进行修改。|
    | `expose.ingress.annotations` | 新增`nginx.org/client-max-body-size: '0'` 不限制上传大小，默认的那两个`proxy-body-size`选项不好使。|
    | `externalURL` | 外部访问URL，如果在代理后面部署 Harbor，请将其设置为代理的 URL。否则和 `expose.ingress.hosts.core`保持一致。|
    | `persistence.persistentVolumeClaim` | persistence.persistentVolumeClaim下面所有服务的`storageClass`修改为自己的storageClass。（可以提前在kuboard中创建好，或者使用其他方式创建好）|

   自定义配置文件创建好，就可以安装发布了。更多配置参考：https://github.com/goharbor/harbor-helm#configuration
 - 安装命令如下：
   ```bash
   # 进入 harbor-helm 的解压目录。
   cd /root/harbor-helm-1.4.4
   # 目录结构如下
    cert  Chart.yaml  conf  CONTRIBUTING.md  deploy.yaml  docs  LICENSE  README.md  templates  test  values.yaml  values-custom.yaml
   # 根据具体的情况编辑好自定义配置文件，后执行以下命令安装发布。命令具体含义和上面在线安装的一个意思，只是把`chart包名`替换成了`.`用来表示当前目录，如果放在其他目录，请写全路径。（如果指定命名空间，请提前创建好）
   # 试安装
   helm install --debug --dry-run   harbor -f values-custom.yaml  --namespace inner-harbor . |sed 'w ./deploy.yaml'
   #正式安装发布
   helm install harbor -f values-custom.yaml  --namespace inner-harbor . |sed 'w ./deploy.yaml'
   ```   
# 访问和上传拉取镜像

打开浏览器，通过配置文件中配置的`expose.ingress.hosts.core` 域名，进行访问。默认用户名：admin 密码：Harbor12345（如果是内网域名，注意内网dns的设置）

镜像上传和下载：
1. 首先在需要上传或下载镜像的主机配置ca证书。ca证书有以下几种方式可以获取。任选一种即可。
 - 通`kubectl`命令获取
   ```bash
   # 以yaml文件的形式展示harbor-ingress的详情信息，其中控制台打印的data部分的ca.crt就是证书相关信息
   kubectl get secret harbor-harbor-ingress -n inner-harbor -o yaml
   # 获取ca证书信息，并使用base64解码后保存到当前目录的 ca.crt 文件中
   kubectl get secret harbor-harbor-ingress -n inner-harbor -o jsonpath="{.data.ca\.crt}"|base64 --decode|sed 'w ca.crt'
   ```
 - 通过harbor web界面获取
   用浏览器访问harbor的web管理界面，进入系统管理-》配置管理-》镜像库根证书。点击下载即可。
2. 将证书文件上传到需要上传或下载镜像的主机`/etc/docker/certs.d/域名/`目录下。如：`/etc/docker/certs.d/harbor.zxzx.com/ca.crt`（如果节点比较多，可参考附录中的批量复制脚本）
3. 执行以下命令登录harbor私服，即可进行镜像的上传下载。
 - 登录 
   ```bash
    [root@worker1 ~]# docker login harbor.zxzx.com
    Username: admin
    Password: 
    WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded
    
   ```
 - 上传
   ```bash
    [root@worker1 harbor.zxzx.com]# docker tag 7fc882ab93f6 harbor.zxzx.com/ttt/testimage:1
    [root@worker1 harbor.zxzx.com]# docker push harbor.zxzx.com/ttt/testimage:1
    The push refers to repository [harbor.zxzx.com/ttt/testimage]
    bd3fce854922: Pushed 
    d14f1ec69126: Pushed 
    be8b8b42328a: Pushed 
    1: digest: sha256:b57b81dd862099e7f6c414d92503054fc357ffdc7b2c648e778bb3e482ca76b4 size: 941   
   ```   
   **注意：** 这里有个坑，默认安装完成后，harbor的ingress会限制上传大小，所有大于1M的镜像都会报413的错误。为什么说这是个坑。因为，其实它默认是有设置了不限制上传大小的选项的。但是无效！因为默认设置的是`ingress.kubernetes.io/proxy-body-size: '0'`，而实际上要设为 `nginx.org/client-max-body-size: '0'`才能生效。不知道后面的版本是否还有这个问题。
 - 下载
   ```bash
    docker pull harbor.zxzx.com/ttt/testimage:1
   ```


# 附录
- ca 证书批量复制脚本
  ```bash
  # 1.本地创建ca.crt，并把上述解码的数据复制锦ca.crt文件内
  kubectl get secret harbor-harbor-ingress -n inner-harbor -o jsonpath="{.data.ca\.crt}"|base64 --decode|sed 'w ca.crt'
  
  # 2.循环在k8s集群所有节点上创建目录（各节点要开启免密登录）
  for n in `seq -w 01 06`;do ssh node-$n "mkdir -p /etc/docker/certs.d/harbor.xxxx.com.cn";done

  # 3.将下载下来的harbor CA证书拷贝到每个node节点的etc/docker/certs.d/harbor.xxxx.com.cn目录下
  for n in `seq -w 01 06`;do scp ca.crt node-$n:/etc/docker/certs.d/harbor.xxxx.com.cn;done
  
  ```
- harbor-helm 配置参数说明
  ```
  expose:
    # 设置暴露服务的方式。将类型设置为 ingress、clusterIP或nodePort并补充对应部分的信息。
    type: ingress
    tls:
      # 是否开启 tls，注意：如果类型是 ingress 并且tls被禁用，则在pull/push镜像时，则必须包含端口。详细查看文档：https://github.com/goharbor/harbor/issues/5291。
      enabled: true
      # 如果你想使用自己的 TLS 证书和私钥，请填写这个 secret 的名称，这个 secret 必须包含名为 tls.crt 和 tls.key 的证书和私钥文件，如果没有设置则会自动生成证书和私钥文件。
      secretName: ""
      # 默认 Notary 服务会使用上面相同的证书和私钥文件，如果你想用一个独立的则填充下面的字段，注意只有类型是 ingress 的时候才需要。
      notarySecretName: ""
      # common name 是用于生成证书的，当类型是 clusterIP 或者 nodePort 并且 secretName 为空的时候才需要
      commonName: ""
    ingress:
      hosts:
        core: harbor.wangxu.com
        notary: notary.wangxu.com
      annotations:
        ingress.kubernetes.io/ssl-redirect: "true"
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
        ingress.kubernetes.io/proxy-body-size: "0"
        nginx.ingress.kubernetes.io/proxy-body-size: "0"
    clusterIP:
      # ClusterIP 服务的名称
      name: harbor
      ports:
        httpPort: 80
        httpsPort: 443
        # Notary 服务监听端口，只有当 notary.enabled 设置为 true 的时候有效
        notaryPort: 4443
    nodePort:
      # NodePort 服务名称
      name: harbor
      ports:
        http:
          port: 80
          nodePort: 30002
        https: 
          port: 443
          nodePort: 30003
        notary: 
          port: 4443
          nodePort: 30004

  # Harbor 核心服务外部访问 URL。主要用于：
  # 1) 补全 portal 页面上面显示的 docker/helm 命令
  # 2) 补全返回给 docker/notary 客户端的 token 服务 URL

  # 格式：protocol://domain[:port]。
  # 1) 如果 expose.type=ingress，"domain"的值就是 expose.ingress.hosts.core 的值 
  # 2) 如果 expose.type=clusterIP，"domain"的值就是 expose.clusterIP.name 的值
  # 3) 如果 expose.type=nodePort，"domain"的值就是 k8s 节点的 IP 地址

  # 如果在代理后面部署 Harbor，请将其设置为代理的 URL
  externalURL: https://harbor.wangxu.com

  # 默认情况下开启数据持久化，在k8s集群中需要动态的挂载卷默认需要一个StorageClass对象。
  # 如果你有已经存在可以使用的持久卷，需要在"storageClass"中指定你的 storageClass 或者设置 "existingClaim"。
  #
  # 对于存储 docker 镜像和 Helm charts 包，你也可以用 "azure"、"gcs"、"s3"、"swift" 或者 "oss"，直接在 "imageChartStorage" 区域设置即可
  persistence:
    enabled: true
    # 设置成"keep"避免在执行 helm 删除操作期间移除 PVC，留空则在 chart 被删除后删除 PVC
    resourcePolicy: "keep"
    persistentVolumeClaim:
      registry:
        # 使用一个存在的 PVC(必须在绑定前先手动创建)
        existingClaim: ""
        # 指定"storageClass"，或者使用默认的 StorageClass 对象，设置成"-"禁用动态分配挂载卷
        storageClass: "harbor-data"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 5Gi
      chartmuseum:
        existingClaim: ""
        storageClass: "harbor-data"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 5Gi
      jobservice:
        existingClaim: "harbor-data"
        storageClass: ""
        subPath: ""
        accessMode: ReadWriteOnce
        size: 1Gi
      # 如果使用外部的数据库服务，下面的设置将会被忽略
      database:
        existingClaim: ""
        storageClass: "harbor-data"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 1Gi
      # 如果使用外部的 Redis 服务，下面的设置将会被忽略
      redis:
        existingClaim: ""
        storageClass: "harbor-data"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 1Gi
    # 定义使用什么存储后端来存储镜像和 charts 包，详细文档地址：https://github.com/docker/distribution/blob/master/docs/configuration.md#storage 
    imageChartStorage:
      # 正对镜像和chart存储是否禁用跳转，对于一些不支持的后端(例如对于使用minio的`s3`存储)，需要禁用它。为了禁止跳转，只需要设置`disableredirect=true`即可，详细文档地址：https://github.com/docker/distribution/blob/master/docs/configuration.md#redirect
      disableredirect: false
      # 指定存储类型："filesystem", "azure", "gcs", "s3", "swift", "oss"，在相应的区域填上对应的信息。
      # 如果你想使用 pv 则必须设置成"filesystem"类型
      type: filesystem
      filesystem:
        rootdirectory: /storage
        #maxthreads: 100
      azure:
        accountname: accountname
        accountkey: base64encodedaccountkey
        container: containername
        #realm: core.windows.net
      gcs:
        bucket: bucketname
        # The base64 encoded json file which contains the key
        encodedkey: base64-encoded-json-key-file
        #rootdirectory: /gcs/object/name/prefix
        #chunksize: "5242880"
      s3:
        region: us-west-1
        bucket: bucketname
        #accesskey: awsaccesskey
        #secretkey: awssecretkey
        #regionendpoint: http://myobjects.local
        #encrypt: false
        #keyid: mykeyid
        #secure: true
        #v4auth: true
        #chunksize: "5242880"
        #rootdirectory: /s3/object/name/prefix
        #storageclass: STANDARD
      swift:
        authurl: https://storage.myprovider.com/v3/auth
        username: username
        password: password
        container: containername
        #region: fr
        #tenant: tenantname
        #tenantid: tenantid
        #domain: domainname
        #domainid: domainid
        #trustid: trustid
        #insecureskipverify: false
        #chunksize: 5M
        #prefix:
        #secretkey: secretkey
        #accesskey: accesskey
        #authversion: 3
        #endpointtype: public
        #tempurlcontainerkey: false
        #tempurlmethods:
      oss:
        accesskeyid: accesskeyid
        accesskeysecret: accesskeysecret
        region: regionname
        bucket: bucketname
        #endpoint: endpoint
        #internal: false
        #encrypt: false
        #secure: true
        #chunksize: 10M
        #rootdirectory: rootdirectory

  imagePullPolicy: IfNotPresent

  logLevel: debug
  # Harbor admin 初始密码，Harbor 启动后通过 Portal 修改该密码
  harborAdminPassword: "Harbor12345"
  # 用于加密的一个 secret key，必须是一个16位的字符串
  secretKey: "not-a-secure-key"

  # 如果你通过"ingress"保留服务，则下面的Nginx不会被使用
  nginx:
    image:
      repository: goharbor/nginx-photon
      tag: v1.7.0
    replicas: 1
    # resources:
    #  requests:
    #    memory: 256Mi
    #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    ## 额外的 Deployment 的一些 annotations
    podAnnotations: {}

  portal:
    image:
      repository: goharbor/harbor-portal
      tag: v1.7.0
    replicas: 1
  # resources:
  #  requests:
  #    memory: 256Mi
  #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  core:
    image:
      repository: goharbor/harbor-core
      tag: v1.7.0
    replicas: 1
  # resources:
  #  requests:
  #    memory: 256Mi
  #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  adminserver:
    image:
      repository: goharbor/harbor-adminserver
      tag: v1.7.0
    replicas: 1
    # resources:
    #  requests:
    #    memory: 256Mi
    #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  jobservice:
    image:
      repository: goharbor/harbor-jobservice
      tag: v1.7.0
    replicas: 1
    maxJobWorkers: 10
    # jobs 的日志收集器："file", "database" or "stdout"
    jobLogger: file
  # resources:
  #   requests:
  #     memory: 256Mi
  #     cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  registry:
    registry:
      image:
        repository: goharbor/registry-photon
        tag: v2.6.2-v1.7.0
    controller:
      image:
        repository: goharbor/harbor-registryctl
        tag: v1.7.0
    replicas: 1
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  chartmuseum:
    enabled: true
    image:
      repository: goharbor/chartmuseum-photon
      tag: v0.7.1-v1.7.0
    replicas: 1
    # resources:
    #  requests:
    #    memory: 256Mi
    #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  clair:
    enabled: true
    image:
      repository: goharbor/clair-photon
      tag: v2.0.7-v1.7.0
    replicas: 1
    # 用于从 Internet 更新漏洞数据库的http(s)代理
    httpProxy:
    httpsProxy:
    # clair 更新程序的间隔，单位为小时，设置为0来禁用
    updatersInterval: 12
    # resources:
    #  requests:
    #    memory: 256Mi
    #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  notary:
    enabled: true
    server:
      image:
        repository: goharbor/notary-server-photon
        tag: v0.6.1-v1.7.0
      replicas: 1
      # resources:
      #  requests:
      #    memory: 256Mi
      #    cpu: 100m
    signer:
      image:
        repository: goharbor/notary-signer-photon
        tag: v0.6.1-v1.7.0
      replicas: 1
      # resources:
      #  requests:
      #    memory: 256Mi
      #    cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
    podAnnotations: {}

  database:
    # 如果使用外部的数据库，则设置 type=external，然后填写 external 区域的一些连接信息
    type: internal
    internal:
      image:
        repository: goharbor/harbor-db
        tag: v1.7.0
      # 内部的数据库的初始化超级用户的密码
      password: "changeit"
      # resources:
      #  requests:
      #    memory: 256Mi
      #    cpu: 100m
      nodeSelector: {}
      tolerations: []
      affinity: {}
    external:
      host: "192.168.0.1"
      port: "5432"
      username: "user"
      password: "password"
      coreDatabase: "registry"
      clairDatabase: "clair"
      notaryServerDatabase: "notary_server"
      notarySignerDatabase: "notary_signer"
      sslmode: "disable"
    podAnnotations: {}

  redis:
    # 如果使用外部的 Redis 服务，设置 type=external，然后补充 external 部分的连接信息。
    type: internal
    internal:
      image:
        repository: goharbor/redis-photon
        tag: v1.7.0
      # resources:
      #  requests:
      #    memory: 256Mi
      #    cpu: 100m
      nodeSelector: {}
      tolerations: []
      affinity: {}
    external:
      host: "192.168.0.2"
      port: "6379"
      # coreDatabaseIndex 必须设置为0
      coreDatabaseIndex: "0"
      jobserviceDatabaseIndex: "1"
      registryDatabaseIndex: "2"
      chartmuseumDatabaseIndex: "3"
      password: ""
    podAnnotations: {}
  ``` 
   
（完）



