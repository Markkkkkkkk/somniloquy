---
category: [博客建站]
tag: [服务器设置,SSH密钥登陆,Fail2ban,网站安全,wordfence,WPS Hide Login,CloudFlare]
postType: post
status: publish
---

## 前言

A安全重中之重，小伙伴们也不希望吃着火锅唱着歌，家被偷了吧。甚至被不法分子敲诈勒索支付比特币才能解密网站数据。这里就向大家介绍wordpress博客网站使用过程中的一些安全防护措施。

## 服务器密钥登陆

服务器这里以Ubuntu为例，centos或其他版本的Linux服务器请自行GPT哈。

首先在你的本地window机器 上，进入cmd命令行使用以下命令生成 SSH 密钥对：

```shell
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

这将会生成一个 RSA 类型的密钥对，长度为 4096 位。你可以按提示选择保存密钥的位置和设置密码。默认位置在`C:\Users\你的window账户名\.ssh\id_rsa.pub`然后将生成的密钥文件内容粘贴到服务器`~/.ssh/authorized_keys`这个目录下。然后修改文件权限：

```shell
chmod 700 ~/.ssh  
chmod 600 ~/.ssh/authorized_keys
```

接下来配置SSH 只允许密钥登录，登录到你的 Ubuntu 服务器，编辑 SSH 配置文件：

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

## Fail2ban设置

Fail2Ban 是一种用于 Linux 系统的安全工具，它通过监控系统日志文件来防止暴力破解攻击，并根据特定的规则封禁可疑的 IP 地址。这里还是以Ubuntu为例，首先安装Faile2ban。

```shell
sudo apt update
sudo apt install fail2ban -y
```

启动并设置开机自启

```shell
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

查看状态：

```
sudo systemctl status fail2ban
```

如果显示为active则Fail2ban就安装好了，安装不复杂，接下来主要是配置一些规则

### 防止wordpress登录暴力破解规则

打开`/etc/fail2ban/jail.conf`目录下的这个文件，在空白处添加：

```
[wordpress-auth]
enabled = true
filter = wordpress-auth
port = http,https
# nginx日志位置，根据自己实际目录修改。
logpath = /usr/apps/blog/nginx/logs/access.log
# 失败次数
maxretry = 5
# 在多长时间内失败
findtime = 600
# 在600秒之内失败超过五次则封禁十小时。
bantime = 36000
```

其次在`/etc/fail2ban/filter.d`在这个文件夹下边新建文件`wordpress-auth.conf`，内容为：

```
[Definition]
failregex = ^<HOST> .* "POST /wp-login.php HTTP.*" 200
            ^<HOST> .* "POST /wp-login.php HTTP.*" 403
            # 下边两个因为wordpress使用了WPS隐藏登录插件修改了登录接口，所以修改后的地址也添加进去。
            ^<HOST> .* "POST /iloveyou HTTP.*" 200
            ^<HOST> .* "POST /iloveyou HTTP.*" 403
ignoreregex =

```

他的原理其实就是根据nginx访问日志，统计IP特定URL失败的次数，然后把符合条件的IP添加到封禁列表。这样就能防止别人暴力破解登录后台了。

### 防止XML-RPC 服务暴力破解规则

XML-RPC 是一种用于远程通信的协议，在 WordPress 中用于外部应用程序进行访问和管理。简单来说就是用API接口直接操作wordpress内容，比方说发布增删改查文章等。

打开`/etc/fail2ban/jail.conf`目录下的这个文件，在空白处添加：

```
[wordpress-xmlrpc]
enabled = true
filter = wordpress-xmlrpc
port = http,https
logpath = /usr/apps/blog/nginx/logs/access.log
maxretry = 5
findtime = 600
bantime = 36000
```

其次在`/etc/fail2ban/filter.d`在这个文件夹下边新建文件`wordpress-xmlrpc.conf`，内容为：

```
[Definition]
failregex = ^<HOST> .*POST /xmlrpc.php HTTP.*$
ignoreregex =
```

### 防止服务器SSH暴力破解登录规则

在`/etc/fail2ban/jail.conf`在这个配置文件里找到`[ssh]`这个配置，初始安装的这个配置是自带有的但是还要加一点东西。大家可以根据已有的跟下边的对照一下。这个规则是防止服务器被别人SSH暴力破解的规则。

```
[sshd]
enabled=true
port    = ssh
filter  = sshd
logpath = %(sshd_log)s
backend = %(sshd_backend)s
# 添加的内容
maxretry=5
findtime = 600
bantime=18000
action = %(action_)s
         log-ban-history
```

### 防御扫描型攻击规则

这种规则用来防御“扫描型攻击”。攻击者会不停地访问你站点上并不存在的路径（比如 `/phpmyadmin/、/wp-admin/install.php、/xxx.php`），通过不断试探 404 错误页面来寻找漏洞或敏感文件。Fail2Ban 就会检测到某个 IP 在短时间内制造大量 404，判断它是恶意扫描，从而临时封禁它。

打开`/etc/fail2ban/jail.conf`目录下的这个文件，在空白处添加：

```
[nginx-404]
enabled = true
port = http,https
filter = nginx-404
logpath = /usr/apps/blog/nginx/logs/access.log
maxretry = 10
findtime = 600
bantime = 3600
```

其次在`/etc/fail2ban/filter.d`在这个文件夹下边新建文件`nginx-404.conf`，内容为：

```
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*(HTTP).*" 404
ignoreregex =
```

大家配置好之后别忘了最后再重启下Fail2ban，让规则生效。也可以查看自己哪些规则生效和过一段时间之后查看封禁了哪些IP。

```
# 重启命令
sudo systemctl restart fail2ban
# 查看运行状态
sudo systemctl status fail2ban
# 查看有哪些规则生效
sudo fail2ban-client status
# 查看具体某个规则的状态和对应封禁的IP
sudo fail2ban-client status nginx-404
# 解封某个IP
sudo fail2ban-client set nginx-404 unbanip 192.168.1.100
```

## Wordfence Security

Wordfence 是一个很受欢迎的 WordPress 安全插件，他能保护你的 WordPress 网站免受各种安全威胁，包括 恶意攻击、暴力破解、病毒、木马、SQL 注入等常见攻击。

它提供了 防火墙保护、恶意软件扫描、登录安全、实时流量监控等多种功能，确保网站在面对网络攻击时能够及时阻止。其特点包括实时 IP 封禁、攻击防御、日志记录等。

### 安装

在wordpress插件安装页面直接搜索安装启用就可以了，记得启用自动更新，因为是安全类软件，最好是及时更新比较好。

![image-20220429094431972](https://image.hyly.net/i/2025/08/18/20be19d56de7a932c78d14794869880d-0.webp)

初始化时会要求输入一个邮箱，平时用来发送安全相关信息。填一个常用邮箱即可。

![image-20220429094910185](https://image.hyly.net/i/2025/08/18/090785e175e9b5d402a80e3072c66242-0.webp)

一般插件都会问你要不要购买高级版。我们直接谢谢即可。免费版已经够用，如果不够用了再买也不迟。

![image-20220429095039236](https://image.hyly.net/i/2025/08/18/39c371216be24d28d529225386120964-0.webp)

一般是通过左侧菜单栏进入设置wordfence的：

![image-20220429095254328](https://image.hyly.net/i/2025/08/18/e1fd542c796e6f48ee9f4d246a113365-0.webp)

### 全局选项

全局选项大家可以参考我的配置，可以从这里进入：

![image-20220429095752599](https://image.hyly.net/i/2025/08/18/dcc19c1240c59d50e2af709f63ad40fb-0.webp)

详细的配置如下：

![image-20250818185106784](https://image.hyly.net/i/2025/08/18/38e65ee78e36fce9c870efacd7ac13a7-0.webp)

1. **许可证：**就算是免费版，也是要注册一个账号获取许可证的，然后把许可证密钥填入到对应框就可以了。
2. **当有管理员权限的人登录时提醒我：**这个关掉就可以了，要不然每次登录的时候都会发送一封邮件，挺烦人的，只需要开启**仅在管理员从新设备或位置登录时提醒我**就可以了。

### 防火墙设置

入口从这里进入。

![image-20250818190005387](https://image.hyly.net/i/2025/08/18/1e2b17229990a1571397052e9866a8d2-0.webp)

这是我所有的配置，大家可以参照配置。

1. **强力保护：**这里也针对网站登录做了一定防护，可以与Fail2ban结合增强防护，虽然有些有重复的地方。
2. **限速：**限速这里则对人类和爬虫频繁访问行为做了一定限制。

![image-20250818190404160](https://image.hyly.net/i/2025/08/18/538930e947d8e834fc9e8c1241ed22e3-0.webp)

#### 拦截

其中在防火墙设置里能查看被阻止的IP都有哪些，可以根据阻止次数较多的IP手动设置拦截，这样就能永久拦截，不会走默认的规则，默认的规则是一定时间内达到一定访问次数才会阻止一次，算一次。

![image-20250818193716247](https://image.hyly.net/i/2025/08/18/419847ba94dbf94fb6be6e11922ac5fb-0.webp)

可以在拦截这里选择IP地址进行手动拦截。

![image-20250818193821760](https://image.hyly.net/i/2025/08/18/abd05f358157674b779d2b2dc89a1f39-0.webp)

### 扫描

大家可以在这里进入扫描，最初安装的时候可以进行一次扫描，发现wordpress网站的问题，然后根据下边的扫描结果进行相应的修复，因为问题可能多种多样，这里就不一一列举了，不知道如何修复或者要不要修复的小伙伴可以自行GPT解决。

![image-20250818191037308](https://image.hyly.net/i/2025/08/18/f9fe73d7dd2ba84bb6842c1c57532c8c-0.webp)

### 登录安全性

大家可以在登录安全性这里设置双重身份验证，这样大大增强用户登录的安全性，防止别人登录后台暴力破解，但是我嫌麻烦就先没设置，但是登录安全性->设置这里有个reCAPTCHA我觉得还是挺好的，他的原理就是调用谷歌验证码，就是那种需要点击我不是机器人的那种验证码，对用户友好一点。详细的reCAPTCHA密钥获取方法在下边的注意链接里，点进去登录谷歌账号一步步获取就可以了，然后把密钥和Secret填到两个对话框里就可以。

![image-20250818194715731](https://image.hyly.net/i/2025/08/18/75bcd01912cfdc03752f04483a9781e0-0.webp)

设置好之后登陆页面就会出现这个图标，如果reCAPTCHA觉得页面访问的人是人类就不会有验证码，如果是机器人或觉得访问者不安全就会出验证码或直接发送邮件，邮件里有一个登陆链接复制到浏览器再次登录才行，可以说是相当安全的了。reCAPTCHA这里还可以设置阈值分数，一般0.5就可以了。

![image-20250818200208812](https://image.hyly.net/i/2025/08/18/540fd5327907b25d9c26321d16ea57ad-0.webp) 

至此，Wordfence Security就配置完成啦~ 如果遇到紧急问题的话他会自动发邮件提醒的，大家在平时也可以登录博客后台查看日志看有什么问题没。

**TIPS：**reCAPTCHA只针对是国外服务器的小伙伴，如果服务器是国内的，设置reCAPTCHA之后在登录页面会调谷歌接口，在国内服务器是访问不通的。国内服务器的小伙伴可以使用`Captcha by BestWebSoft`插件，在wordpress插件市场直接搜索安装就可以，使用方式也非常简单，进去点点看就知道怎么设置了，这里就不再出详细教程了。

## WPS Hide Login

WPS Hide Login 是 WordPress 的一个 安全类插件，它的作用很简单：修改 WordPress 默认的后台登录地址（/wp-login.php 和 /wp-admin/）

### 为什么要使用这个插件

**默认登录地址暴露风险大**
 WordPress 默认的后台登录地址是：

- `https://example.com/wp-login.php`
- `https://example.com/wp-admin/`
   几乎所有黑客、爬虫、爆破工具都知道这一点，所以会不断对这两个地址进行暴力破解尝试。

**插件的作用**
 `WPS Hide Login` 可以把登录地址改成一个你自定义的路径，比如：

- `https://example.com/my-secret-login`
   这样攻击者访问 `/wp-login.php` 或 `/wp-admin/` 时，就会直接返回 **404 页面**，而不会暴露后台入口。

### 使用

使用也是非常简单，直接插件市场搜索安装启用，入口在设置里面：

![](https://image.hyly.net/i/2025/08/21/6dfdf329578e7ff390faafc71122a24a-0.webp)

然后修改自己的登录入口链接保存就可以了~

![image-20250821091931768](https://image.hyly.net/i/2025/08/21/8eb34c19dcc57f699a2edfda4b0692fd-0.webp)

## CloudFlare

Cloudflare本质上是一个 **全球 CDN + 网络安全 + 边缘计算平台**。它位于你的网站/应用和访问用户之间，扮演一个 **反向代理** 的角色。

可以理解为：
 👉 用户访问你的网站时，流量先经过 Cloudflare，再由 Cloudflare 转发到你真实的服务器。
 这样可以带来 **加速** + **保护** 的效果。

### Cloudflare 的核心功能

1. **CDN 加速（内容分发网络）**
	1. Cloudflare 在全球有 300+ 个节点（数据中心），它会缓存你网站的静态资源（图片、JS、CSS 等）。
	2. 用户访问时，就近从最近的 Cloudflare 节点获取资源 → 加载更快，降低延迟。
2. **网站防护（安全防御）**
	1. **DDoS 防护**：拦截海量恶意流量，保护服务器不被打死。**
	2. **WAF（Web 应用防火墙）**：阻止 SQL 注入、XSS 等常见攻击。**
	3. **Bot 管理**：识别并阻挡恶意爬虫、爆破工具。
	4. **隐藏真实 IP**：攻击者只能看到 Cloudflare 的 IP，看不到你的源站 IP。
3. **智能路由与优化**
	1. Cloudflare 会自动选择最快的网络路径，把流量从用户传到源站。
	2. 支持 **压缩、自动优化图片、HTTP/2/3、缓存策略**，提升性能。
4. **边缘计算（Workers、Pages、KV 等）**
	1. 提供 **Cloudflare Workers**：在边缘节点运行 JS/TS 代码，像小型无服务器函数。
	2. **Pages**：支持部署静态网站（类似 Netlify/Vercel）。
	3. **R2 存储**：兼容 S3 的分布式对象存储。
	4. **KV / D1**：边缘数据库。
5. **零信任与网络服务**
	1. **Cloudflare Access / Zero Trust**：零信任安全接入（替代 VPN）。
	2. **Cloudflare Tunnel**：不用暴露端口，也能把内网应用安全地发布到公网。
	3. **DNS 服务（1.1.1.1）**：全球最快的公共 DNS，隐私保护。

### 域名注册

首先我们注册账号登录进入后台点击域注册->注册域：

![image-20250821104856379](https://image.hyly.net/i/2025/08/21/e3518273949a6eed735ad74bc19f8e70-0.webp)

由于cloudflare经常改版，你实际看的时候可能不是这样的界面，但是功能名字差不多，摸索着找一下就可以。搜索到自己心仪的域名然后点击注册，到注册信息填写页面，付款方式这里可以选Visa或银联卡，建议勾选启用自动续订，这样就不至于没有及时续费丢失使用很久的域名，博客更换域名是很麻烦的一件事，相当于掉半管血。

如果银行卡付款不成功，也可以选择PayPal支付，在PayPal里面添加银行卡，然后再用PayPal支付，付款这里当时自己弄了好久，直接银行卡支付不行用PayPal也不行，后来使用PayPal更换绑定了好几张卡才可以了，信用卡和储蓄卡都尝试了。大家在这里没有付款成功也建议多张卡尝试一下。

![image-20250821105124339](https://image.hyly.net/i/2025/08/21/5dff9c9b8e638cabbff32ed1c835d979-0.webp)

注册完成后就会在域注册->管理域这里看到注册成功的域名，点击管理就可以针对域名做IP映射等。

![image-20250821110634433](https://image.hyly.net/i/2025/08/21/7ee5c748a2f0e483ba24b74c3af0df5f-0.webp)

![image-20250821110742390](https://image.hyly.net/i/2025/08/21/fedffa93a26332071fdb98649be5137e-0.webp)

### 基础配置

![image-20250821151650820](https://image.hyly.net/i/2025/08/21/e304667bca2646af17eb25a62dc9c994-0.webp)

在概述这里可以配置以下几个选项：

1. Under Attack 模式：当网站处于被攻击的状态时，可以短暂开启来加强网站的防御，但是可能会造成网站有些用户暂时不能访问。但这就好像是人已经高烧不退了，这时候也管不了那么多了，只能下猛药了。详细的可以看功能下方链接的详细说明：

	![image-20250821152323228](https://image.hyly.net/i/2025/08/21/d1f125d1294f75779498269a9751e333-0.webp)

2. 开发模式：开启这个模式的时候会暂时绕过缓存，在网站调试阶段，这个功能非常好用，你也不想改动了一个配置发现不生效，找来找去原来是缓存的原因吧。

3. 始终使用 HTTPS、自动 HTTPS 重写：这两个要开启，这样访问都是HTTPS的请求，可以加密每次请求的数据，不会泄露账号密码或关键数据啥的。

4. 自动程序攻击模式：简单来说就是帮你识别一部分自动程序的流量进行防御，让你的网站尽量都是真人流量去访问。

![image-20250821154253423](https://image.hyly.net/i/2025/08/21/ea324d3a323f45ed5c5cf9d02ea76567-0.webp)

1. Always Online：就是为你的网站创建副本，相当于缓存，当你的网站处于不可用状态时，用户也能从你的网站副本也就是缓存里打开网站，就好像网站能正常访问一样。
2. 速度优化：通过算法提前为用户返回下一页的内容，内容预取，当你真的去点击下一页的时候看起来就跟秒开一样。开启这个会额外消耗服务器的流量，因为用户万一不打开下一页，但下一页内容已经提前加载好了，不过相对于使用体验，流量消耗无足轻重了。

### DNS配置

在DNS->记录那里可以添加域名DNS解析，类型一般选择A就行了，名称那里如果是主域名就填@，如果是想www或子域名解析的就填www或子域名名字，然后填上IP。其他的可以详细看下提示说明，如果实在不了解各个怎么用的小伙伴可以GPT下，也不会太难理解。

> 有邮件服务器需求的小伙伴这里也可以设置邮件二级域名，但我没用到，这里就不详细写了，有需要的小伙伴可以看[这篇文章](https://blognas.hwb0307.com/skill/3278#header-id-11)。

代理状态那个按钮一定要**点上！！！**，这里再吹一波cloudflare，这个代理状态是开启CDN功能，他的作用就是给你的网站做全球加速，原理就是他会把你网站静态内容缓存到全球的各个节点，当用户访问你网站的时候，会从就近节点获取文字、图片等内容，就不用直接去你网站拿内容，提高了用户访问速度，还降低了对网站的流量压力。虽然他可能对大陆内部的访问CDN加速不是太好，但是免费白嫖一个全球CDN加速多香啊！使用CDN在国内云厂商可是要掏不少钱的存在。CDN还有一个好处就是隐藏服务器的真实IP，黑客找不到你服务器的真实IP，他ping域名得到的只是一个CDN缓存地址的IP，即使他再对这个CDN IP做DDOS攻击也是没有用的，不会对你网站造成多大影响，提升了网站安全性。

![image-20250821160350015](https://image.hyly.net/i/2025/08/21/c97dcb116830e4225f99c9cc2cc1390e-0.webp)

DNS设置里面还有一个DNSSES设置，大家也可以启用了，功能说明如图所示：

![image-20250821162246910](https://image.hyly.net/i/2025/08/21/6a88e3b1523e5ec61a3f3bb08b98f8bb-0.webp)

### SSL/TLS

关于域名SSL证书这里就又要再吹一波cloudflaree了，在国内厂商，SSL证书都是动辄**天价**的存在，即使国内厂商免费的证书也是只有一个月或三个月的有效期，还限制你申请次数。没想到人家cloudflare免费就让用户使用了。

首先在SSL/TLS概述这里启用加密模式为**完全**

![image-20250821175643299](https://image.hyly.net/i/2025/08/21/e2d009ec2151f18b762642240ee1085a-0.webp)

其次你可以在SSL/TLS->边缘证书这里**免费**申请证书，而且证书时间还很长！并且相关设置如下，大家参照着来就可以了：

![image-20250821175919554](https://image.hyly.net/i/2025/08/21/82b5ed5a4d47cf1e5a518e8c48d863b6-0.webp)

然后大家就可以在源服务器这里创建证书并下载安装到服务器上，这样自己域名就能免费使用https访问了，对安全性有很大提升！

![image-20250821180156188](https://image.hyly.net/i/2025/08/21/f44251daf1399adcf48640334e905110-0.webp)

#### SSL证书具体使用

首先上传到nginx目录下，然后配置文件里引入就可以了。

在compose文件中nginx配置如下：

```
#filename:docker-compose.yml 
nginx:
    image: bitnami/nginx:1.29.0
    container_name: nginx
    depends_on:
      - wordpress
    ports:
      - "80:8080"    # 映射主机80端口到nginx容器的8080端口（bitnami/nginx默认监听8080）
      - "443:8443"    # 添加这一行用于 HTTPS
    volumes:
      - ./blog/nginx/conf:/opt/bitnami/nginx/conf/server_blocks:ro
      - ./blog/nginx/logs:/opt/bitnami/nginx/logs   # 👈日志挂载
      - ./blog/nginx/certs:/opt/bitnami/nginx/certs:ro   # 挂载证书目录
    environment:
      - TZ=Asia/Shanghai
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined
```

重点是这两行第一个是把外部443端口映射给bitnami/nginx默认8443端口，第二个是在Ubuntu上创建证书目录，把证书上传到这个目录然后映射到容器内目录。

![image-20250821180657727](https://image.hyly.net/i/2025/08/21/6575d6942e3656cc85be62b79399e45d-0.webp)

接下来配置`wordpress.conf`文件，重要的是这几行：

![image-20250821181635439](https://image.hyly.net/i/2025/08/21/0fd80e79dbda383f2695d76ca6c4251a-0.webp)

完整的配置文件如下：

```
    # 博客
    server {
        listen 8080;
        server_name hyly.net www.hyly.net;
        #监听8080端口把非https的请求都统一跳转为https
        return 301 https://$host:8443$request_uri;

    }
    # 博客443
    server {
        #监听https请求
        listen 8443 ssl;
        server_name hyly.net www.hyly.net;

        # 你可以改成你想允许的最大上传大小
        client_max_body_size 100M;  
        # 证书公钥路径
        ssl_certificate     /opt/bitnami/nginx/certs/hylynet.pem;
        # 证书私钥路径
        ssl_certificate_key /opt/bitnami/nginx/certs/hylynet.key;
        # 限定服务器支持的 TLS 协议版本。
        ssl_protocols       TLSv1.2 TLSv1.3;
        # 配置服务器允许使用的加密套件
        ssl_ciphers         HIGH:!aNULL:!MD5;
    
        # 评论邮件退订链接转发
        location ^~ /unsubscribe-comment-mailnotice {
            # 使用 PHP-FPM 处理请求
            fastcgi_pass wordpress:9000;  # PHP-FPM 监听 9000 端口
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME /bitnami/wordpress/wp-content/themes/argon/unsubscribe-comment-mailnotice.php;  # 使用容器内的路径
            fastcgi_param DOCUMENT_ROOT /bitnami/wordpress;
        }

        #添加ads.txt谷歌广告
        location = /ads.txt {
            proxy_pass http://wordpress:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            rewrite ^/ads.txt$ /wp-content/uploads/ads.txt break;
        }

        
        location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|ttf|svg|eot|otf|map)$ {
            proxy_pass http://wordpress:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            expires 7d;
            access_log off;
        }

        location / {
            proxy_pass http://wordpress:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
    }
}
```

### 缓存

cloudflare提供了一定量的免费缓存供我们使用，但这已经足够了，具体配置如下：

![image-20250821182238871](https://image.hyly.net/i/2025/08/21/1d6c20355c3f46a9705f9796892e5afd-0.webp)

![ ](https://image.hyly.net/i/2025/08/21/e2400218e9f02358df3a03a4b2d844bf-0.webp)

### workers

还有方法可以配置workers然后转发路由利用cloudflare的缓存空间大幅度提升全球访问速度，但是我实际使用下来变得更慢或者甚至不能使用，还不如cloudflare默认的规则，然后再加上**W3 Total Cache**插件，基本上国内用户访问部署在国外的wordpress无压力了。感兴趣的同学可以看下[这篇文章](https://blognas.hwb0307.com/linux/docker/1415)。

以上基本上是cloudflare我所使用到的所有配置了，其他的一些没列举出来的，要么付费但现在暂时用不到的功能，要么是一些统计分析，大家可以登录上去随便点点看就知道怎么回事了。

## 小结

相信大家经过这么一番配置，网站的安全性能提升一大截！以后遇到更好的方案我也会继续给大家添加进来分享~

在使用安装配置过程中有疑问的小伙伴可以在文章下方留言与我互动，有最新的资料我也会及时更新本文章，感兴趣的小伙伴请关注点赞哈~
