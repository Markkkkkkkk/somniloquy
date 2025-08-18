---
category: [博客建站]
tag: [服务器设置, Fail2ban]
postType: post
status: publish
---

# 服务器密钥登陆

服务器这里以Ubuntu为例，centos或其他版本的Linux服务器请自行GPT哈。

首先在你的本地window机器 上，进入cmd命令行使用以下命令生成 SSH 密钥对：

```cmd
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

这将会生成一个 RSA 类型的密钥对，长度为 4096 位。你可以按提示选择保存密钥的位置和设置密码。默认位置在`C:\Users\你的window账户名\.ssh\id_rsa.pub`然后将生成的密钥文件内容粘贴到服务器`~/.ssh/authorized_keys`这个目录下。然后修改文件权限：

```shell
chmod 700 ~/.ssh  
chmod 600 ~/.ssh/authorized_keys
```

截下来配置SSH 只允许密钥登录，登录到你的 Ubuntu 服务器，编辑 SSH 配置文件：

```shell
sudo nano /etc/ssh/sshd_config
```

找到并修改以下几行（如果没有这些行，手动添加）：

```shell
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

- PasswordAuthentication no：禁用密码认证

- ChallengeResponseAuthentication no：禁用挑战-响应认证

- UsePAM no：禁用基于 PAM 的认证

修改配置后，重启 SSH 服务使更改生效：

```
sudo systemctl restart ssh
```

在本地window电脑上你可以尝试用SSH工具密码登录服务器，提示是被拒绝的，登录方式选择密钥登录则是可以的，密钥文件在你本地电脑的`C:\Users\你的window账户名\.ssh\id_rsa`文件内，这样很大程度上能防止别人密码爆破。

# Fail2ban设置

这里还是以Ubuntu为例，首先安装Faile2ban。

```shell
sudo apt update
sudo apt install fail2ban -y
```

启动并设置开机自启

```shell
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

