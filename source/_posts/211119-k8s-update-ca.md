---
title: k8s证书续期
date: Wed Oct 26 2022 16:39:25
tags:
	- k8s
---

# 检查证书过期时间
```
# 方法1
kubeadm alpha certs check-expiration
# 方法2
openssl x509 -noout -dates -in /etc/kubernetes/pki/apiserver.crt
kubeadm alpha certs 命令详解：
Available Commands:
  certificate-key  生成证书和key
  check-expiration  检测证书过期时间
  renew            续订Kubernetes集群的证书

  kubeadm alpha certs命令仅支持v1.15及其以上的版本。
```

# 手动续订证书一年
```
# 将所有证书续签一年(如果只续签apiserver证书的时间，可执行 kubeadm  alpha certs renew apiserver )
kubeadm alpha certs renew all

```

# 重启kubelet，并查看新的过期时间
```
# 重启kubelet
systemctl restart kubelet
# 查看新的过期时间
kubeadm alpha certs check-expiration
```


# 备注

如果已上步骤后，还是不好使，那么尝试重启master节点的主机。重启后还不好使，那么再试着执行以下两步。

1. 更新用户配置
```
kubeadm alpha kubeconfig user --client-name=admin
kubeadm alpha kubeconfig user --org system:masters --client-name kubernetes-admin  > /etc/kubernetes/admin.conf
kubeadm alpha kubeconfig user --client-name system:kube-controller-manager > /etc/kubernetes/controller-manager.conf
kubeadm alpha kubeconfig user --org system:nodes --client-name system:node:$(hostname) > /etc/kubernetes/kubelet.conf
kubeadm alpha kubeconfig user --client-name system:kube-scheduler > /etc/kubernetes/scheduler.conf

```
2. 用更新后的admin.conf替换/root/.kube/config文件
```
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

然后再重启kubelet,如果不好使，再重启master主机，再不好使，百度吧。

官方文档：https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
参考博文：
https://blog.csdn.net/weixin_42562106/article/details/107025507
https://blog.csdn.net/swan_tang/article/details/115755311

（完）

