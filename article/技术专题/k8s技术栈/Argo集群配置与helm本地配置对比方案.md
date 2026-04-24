---
category: [k8s技术栈]
tag: [argocd,helm,配置比对]
postType: post
status: publish
---

## 前言

在k8s环境下，当我们选择用helm升级环境服务时，会发现随着时间的推移，有一些修改会直接通过工具或命令直接修改正式/测试环境配置，并且没有及时更新helm脚本，导致正式/测试环境配置与helm配置不一致。严格来说环境配置修改应统一由helm脚本去修改，去掉个人直接修改环境配置权限。但是对于已经存在配置不一致的情况，找到了以下方法可以方便对比。

## helm diff命令

运行helm diff命令即可得出比对结果：

```
helm diff  upgrade acp-deploy . --values .\values.yaml --debug > change.txt
```

![image-20260206114053505](https://image.hyly.net/i/2026/02/06/b40415e89324c7e24236ee6199acc54d-0.webp)

+号是相对于环境多的，-号是相对环境少的，但是这样很不直观。再加上服务众多，配置文件更多，所以放弃。

## Monokle

这是一款类似于lens的k8s集群管理工具，它也提供了helm脚本与k8s集群环境配置对比的功能，下载软件添加k8s context，添加git仓库，左侧选择集群，右侧选择git仓库具体的helm脚本分支，即可对比：

![image-20260206131524455](https://image.hyly.net/i/2026/02/06/5043cd823c91a694088238d8e90bdcb7-0.webp)

但是看下来，对比效果也一般，点每项也能看具体的配置，但是差异部分体现不出来，也放弃。

## ArgoCD

argoCD是一款自动部署工具，与旗下的workflows、events组件结合，能方便的实现k8s环境ci/cd部署，实现程序员提交代码，在argoCD上点击按钮自动根据最新代码分支打包镜像发布到k8s集群的效果。其中有一个很重要的功能就是**diff**对比，我们解决集群环境配置与本地不一致就是用的它。

### argoCD安装

略，大家可以简单问下AI可以方便的在k8s集群里部署argoCD。

### argoCD添加git仓库

argoCD管理页面没有提供添加git仓库的按钮，需要[下载](https://github.com/argoproj/argo-cd/releases)argoCD CLI客户端进行添加：

![image-20260206134329332](https://image.hyly.net/i/2026/02/06/ddcab700b4af35bc49acd8797da41003-0.webp)

下载完之后exe需要添加电脑环境变量，可以自行AI搜索如何添加，添加完环境变量后在cmd命令行输入`argocd version --client`显示版本号即表示安装成功。

安装成功后就可以在cmd命令行登录argocd然后添加git仓库地址。

```
# 首先登录argocd
argocd login argo.aipark.com --grpc-web --username 账号 --password "密码"
# 其次添加helm git仓库
argocd repo add https://gitcenter.aipark.com/cpd/sso-deploy.git --username git账号 --password git密码 --insecure-skip-server-verification
```

添加成功后登录argoCD在Settings处选择Repositories即可查看已添加的git仓库。

![image-20260206132528860](https://image.hyly.net/i/2026/02/06/663d9b033495bf06546c1cd5156aa6f8-0.webp)

![image-20260206145713200](https://image.hyly.net/i/2026/02/06/9da61b6bfaa1b5993f331ddc3053c950-0.webp)

### argoCD添加kubectl context

如果argoCD安装在k8s集群里，则argoCD会默认显示被安装的集群节点信息：

![image-20260206145832621](https://image.hyly.net/i/2026/02/09/f61c5c3bc1bba771b24dd0c246d1cc88-0.webp)

![image-20260209103343710](https://image.hyly.net/i/2026/02/09/3206cac9b5723d1e3132b47e47bfef8d-0.webp)

如果要新添加集群的话，需要通过argoCD CLI添加：

```
# 首先查看当前context是否为要添加的集群，如果不是则切换为正确的集群环境
kubectl config get-contexts
# 登录argocd 
argocd login argo.aipark.com --grpc-web --username 账号 --password "密码"
# 添加当前集群
argocd cluster add <CONTEXT_NAME>
```

### argoCD创建项目

还需要创建一个项目，在创建应用的时候提供选择：

![image-20260209111628574](https://image.hyly.net/i/2026/02/09/ac1c649b10d8adc331fbd96c4b0a7434-0.webp)

![image-20260209111758710](https://image.hyly.net/i/2026/02/09/49eaf276563f6ac07142927f27c3b9ac-0.webp)

### diff比较

![image-20260209105406275](https://image.hyly.net/i/2026/02/09/9452f74a484d0e8d33d5eee8adabfa5e-0.webp)

这样创建一个新应用后，然后点击diff即可对比本地helm和集群配置是否一致：

![image-20260209111915938](https://image.hyly.net/i/2026/02/09/28d719fd2b2d7837445c2da3ed2364f2-0.webp)

## IDEA自动填充helm参数

helm采用values.yaml进行参数填充，可以在本地通过IDEA方便的查看填充后的参数效果：

![image-20260209112232385](https://image.hyly.net/i/2026/02/09/b9af42ad7035015c6860c76fd1e809dd-0.webp)

![image-20260209112613406](https://image.hyly.net/i/2026/02/09/ec76ea56dc710f0ea107ade37de5acfc-0.webp)

## 小结

至此，可以通过argoCD的diff功能可以很方便的进行本地helm脚本配置与环境配置比对修改一致了，以后就可以设定严格通过helm脚本来升级。杜绝配置不一样的情况。
