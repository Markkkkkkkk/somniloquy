---
category: [博客建站]
tag: [wordpress,matomo,uptime kuma,easyimage,图床,docker,监控]
postType: post
status: publish
---

# 前言

用 Docker Compose 搭建 WordPress 博客的好处，可以总结为以下几个方面：

1. **快速部署**
	1. 一份 `docker-compose.yml` 文件即可一键启动 WordPress、MySQL、Nginx等服务，避免繁琐的手动安装。
2. **环境隔离**
	1. 每个服务都运行在独立的容器中（WordPress、数据库、缓存等互不干扰），避免版本冲突和依赖问题。
3. **可移植性强**
	1. 只需拷贝 `docker-compose.yml` 和数据卷，就能在任何支持 Docker 的机器上快速恢复环境。
4. **方便扩展与升级**
	1. 需要 Memcached缓存、matomo网站监控、Nginx 反向代理等，只需在 `docker-compose.yml` 添加新服务即可。
	2. 升级 WordPress 或数据库时也更安全，容器化后只要替换镜像即可。
5. **数据安全**
	1. 数据库和 WordPress 上传文件可以挂载到宿主机的卷，容器更新/删除不影响数据。
6. **方便管理**
	1. 通过 `docker-compose up -d`、`down`、`logs` 等命令，就能管理整个 WordPress 服务集群。

首先贴下最全的compose文件，图省事的小伙伴可以直接运行加载博主同款配置。

```

services:
  mysql:
  	# 镜像名称
    image: bitnami/mysql:8.0
    # 容器名称
    container_name: mysql
    # 账号密码数据库名称需要根据自己需要配置。
    environment:
      - MYSQL_ROOT_PASSWORD=rootzhanghumimma
      - MYSQL_DATABASE=wordpressshujukumingxheng
      - MYSQL_USER=shujukuzhanghao
      - MYSQL_PASSWORD=shujukumima
      - TZ=Asia/Shanghai
    # 左边是服务器目录，右边是容器内目录，可以根据需要改动冒号左边目录，冒号右边目录不可更改。
    volumes:
      - ./blog/mysqlData:/bitnami/mysql/data
    # 容器重启策略，只有手动停止才不重启，当发生错误或其他的时候才会重启。
    restart: unless-stopped
    # 容器局域网络名称
    networks:
      - wpnetwork
	# 给容器增加 Linux capabilities 权限，SYS_NICE 允许容器内的进程修改自身或其他进程的 优先级（priority / niceness） 和 调度策略。
    cap_add:
      - SYS_NICE
    # Docker 默认会启用 seccomp（secure computing mode） 安全过滤器，限制容器里能用的系统调用，防止安全风险。unconfined 表示 禁用 seccomp 限制，即容器里的进程可以调用所有系统调用，不再受 seccomp 配置文件的限制。
    security_opt:
      - seccomp:unconfined

  # 因为bitnami/wordpress里面不太好安装php-redis扩展，但是自带了memcached扩展，所以不用redis容器了，改使用memcached跟reids一样是一个内存服务。
  memcached:
    image: bitnami/memcached:1.6.39
    container_name: memcached 
    restart: unless-stopped
    networks:
      - wpnetwork
    environment:
      - TZ=Asia/Shanghai
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined

  wordpress:
    image: bitnami/wordpress:6.8.2
    container_name: wordpress
    # 因为同时使用了mysql数据库和memcached内存数据库，所以依赖填两个。
    depends_on:
      - mysql
      - memcached
    environment:
      # mysql数据库设置
      - TZ=Asia/Shanghai
      # 数据库地址，这里使用的是mysql容器，所以填容器名称就可以。
      - WORDPRESS_DATABASE_HOST=mysql
      - WORDPRESS_DATABASE_PORT_NUMBER=3306
      - WORDPRESS_DATABASE_NAME=wordpressshujukumingxheng
      - WORDPRESS_DATABASE_USER=shujukuzhanghao
      - WORDPRESS_DATABASE_PASSWORD=shujukumima
      - WORDPRESS_USERNAME=wordpresszhanghaomingchegn
      - WORDPRESS_PASSWORD=wordpresszhanghaomima
      # wordpress设置
      - WORDPRESS_EMAIL=103XXXXXX@qq.com
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
    volumes:
      # wordpress数据配置主目录。
      - ./blog/wordpressData:/bitnami/wordpress
      # wordpress php-fpm 配置目录，主要为评论邮件退订使用。
      - ./blog/wordpressData/conf:/opt/bitnami/php/etc/php-fpm.d
      # wordpress 启动脚本目录，主要为评论邮件退订使用。
      - ./blog/wordpressData/wordpressSH/entrypoint.sh:/opt/bitnami/scripts/wordpress/entrypoint.sh
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined

  # 反向代理工具。提供wordpress统一访问入口。
  nginx:
    image: bitnami/nginx:1.29.0
    container_name: nginx
    depends_on:
      - wordpress
    ports:
      - "80:8080"    # 映射主机80端口到nginx容器的8080端口（bitnami/nginx默认监听8080）
      - "443:8443"    # 添加这一行用于 HTTPS
    volumes:
      # nginx配置主目录。
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

#网站访问量监控
  matomo:
    image: bitnami/matomo:5.3.2
    container_name: matomo
    depends_on:
      - mysql
    environment:
      - TZ=Asia/Shanghai
      - MATOMO_DATABASE_HOST=mysql
      - MATOMO_DATABASE_PORT_NUMBER=3306
      - MATOMO_DATABASE_USER=matomoshujukuzhanghao
      - MATOMO_DATABASE_PASSWORD=matomoshujukumima
      - MATOMO_DATABASE_NAME=matomoshujukumingcheng
    volumes:
      - ./blog/matomo:/bitnami/matomo
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined

#网站可用性监控
  uptimeKuma:
    image: louislam/uptime-kuma:1
    container_name: uptimeKuma
    restart: unless-stopped
    volumes:
      - ./blog/uptimeKuma:/app/data
    networks:
      - wpnetwork
    environment:
      - TZ=Asia/Shanghai


# easyimage图床
  easyimage:
    image: ddsderek/easyimage:v2.8.6
    container_name: easyimage
    environment:
      - TZ=Asia/Shanghai
      #- PUID=1000
      #- PGID=1000
      #- DEBUG=false
    volumes:
      # 图床配置目录。
      - ./blog/easyimage/config:/app/web/config
      # 图床图片存储目录。
      - ./blog/easyimage/i:/app/web/i
    restart: unless-stopped
    networks:
      - wpnetwork

# 容器局域网
networks:
  wpnetwork:
    name: wpnetwork
    driver: bridge
```

# Wordpress构建

docker容器我没有选官方镜像，而是统一选择了bitnami重新构建的镜像，有以下优点：

1. **开箱即用** → 自带 WordPress + Apache + PHP + MariaDB（也可以外接），启动就能跑。
2. **内置安全加固** → 默认关闭 root 远程登录、强制安全权限、自动生成随机密码（可通过环境变量管理）。
3. **官方维护** → Bitnami 由 VMware 维护，更新和安全补丁比较快。
4. **可选 Helm chart/K8s 支持** → 如果未来要上 Kubernetes，Bitnami 的 WordPress chart 已经配套好了。
5. **更适合新手或想省事的人** → 不用费力折腾各种依赖和配置。

## docker 安装

首先检查服务器是否安装了docker和docker compose，如果已经安装的小伙伴可以忽略此步骤。

```
# 检查是否安装了docker,已安装则会输出版本号信息。
docker --version
# 看到 active (running) 就说明运行正常。
systemctl status docker
# 以下命令检查是否安装了docker compose，已安装则会输出版本号信息。
docker compose version
```

如果检查没安装则执行以下命令：

```
# 更新软件包
sudo apt update

# 安装必要工具
sudo apt install -y ca-certificates curl gnupg lsb-release

# 添加 Docker 官方 GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 官方源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker CE
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
# 安装完成后，启动并设置开机自启：
sudo systemctl enable --now docker
# 安装 Docker Compose
# 下载最新版本
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

# 添加可执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 检查版本
docker-compose --version

```

## 详细docker compose 文件

安装好docker compose 之后就可以开始构建了。如果只选择构建Wordpress，以下是核心配置：

```
services:
  mysql:
  	# 镜像名称
    image: bitnami/mysql:8.0
    # 容器名称
    container_name: mysql
    # 账号密码数据库名称需要根据自己需要配置。
    environment:
      - MYSQL_ROOT_PASSWORD=rootzhanghumimma
      - MYSQL_DATABASE=wordpressshujukumingxheng
      - MYSQL_USER=shujukuzhanghao
      - MYSQL_PASSWORD=shujukumima
      - TZ=Asia/Shanghai
    # 左边是服务器目录，右边是容器内目录，可以根据需要改动冒号左边目录，冒号右边目录不可更改。
    volumes:
      - ./blog/mysqlData:/bitnami/mysql/data
    # 容器重启策略，只有手动停止才不重启，当发生错误或其他的时候才会重启。
    restart: unless-stopped
    # 容器局域网络名称
    networks:
      - wpnetwork
	# 给容器增加 Linux capabilities 权限，SYS_NICE 允许容器内的进程修改自身或其他进程的 优先级（priority / niceness） 和 调度策略。
    cap_add:
      - SYS_NICE
    # Docker 默认会启用 seccomp（secure computing mode） 安全过滤器，限制容器里能用的系统调用，防止安全风险。unconfined 表示 禁用 seccomp 限制，即容器里的进程可以调用所有系统调用，不再受 seccomp 配置文件的限制。
    security_opt:
      - seccomp:unconfined

  # 因为bitnami/wordpress里面不太好安装php-redis扩展，但是自带了memcached扩展，所以不用redis容器了，改使用memcached跟reids一样是一个内存服务。
  memcached:
    image: bitnami/memcached:1.6.39
    container_name: memcached
    restart: unless-stopped
    networks:
      - wpnetwork
    environment:
      - TZ=Asia/Shanghai
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined

  wordpress:
    image: bitnami/wordpress:6.8.2
    container_name: wordpress
    # 因为同时使用了mysql数据库和memcached内存数据库，所以依赖填两个。
    depends_on:
      - mysql
      - memcached
    environment:
      # mysql数据库设置
      - TZ=Asia/Shanghai
      # 数据库地址，这里使用的是mysql容器，所以填容器名称就可以。
      - WORDPRESS_DATABASE_HOST=mysql
      - WORDPRESS_DATABASE_PORT_NUMBER=3306
      - WORDPRESS_DATABASE_NAME=wordpressshujukumingxheng
      - WORDPRESS_DATABASE_USER=shujukuzhanghao
      - WORDPRESS_DATABASE_PASSWORD=shujukumima
      - WORDPRESS_USERNAME=wordpresszhanghaomingchegn
      - WORDPRESS_PASSWORD=wordpresszhanghaomima
      # wordpress设置
      - WORDPRESS_EMAIL=103XXXXXX@qq.com
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
    volumes:
      # wordpress数据配置主目录。
      - ./blog/wordpressData:/bitnami/wordpress
      # wordpress php-fpm 配置目录，主要为评论邮件退订使用。
      - ./blog/wordpressData/conf:/opt/bitnami/php/etc/php-fpm.d
      # wordpress 启动脚本目录，主要为评论邮件退订使用。
      - ./blog/wordpressData/wordpressSH/entrypoint.sh:/opt/bitnami/scripts/wordpress/entrypoint.sh
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined

  # 反向代理工具。提供wordpress统一访问入口。
  nginx:
    image: bitnami/nginx:1.29.0
    container_name: nginx
    depends_on:
      - wordpress
    ports:
      - "80:8080"    # 映射主机80端口到nginx容器的8080端口（bitnami/nginx默认监听8080）
      - "443:8443"    # 添加这一行用于 HTTPS
    volumes:
      # nginx配置主目录。
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

# 容器局域网
networks:
  wpnetwork:
    name: wpnetwork
    driver: bridge
```

把以上配置新建文件`docker-compose.yml`放到服务器`/usr/apps/`目录下，然后命令行目录切换到`cd /usr/apps/`目录下执行`docker compose up -d` 就会自动下载镜像并启动容器。容器服务器映射目录统一为`/usr/apps/blog/`。

文件名一定是要`docker-compose.yml`如果是其他文件名，那么启动命令就要带上具体的文件名，例如`docker compose -f 指定文件名.yml up -d`

因为dockerhub可能会被墙的原因，如果大家使用国外服务器是能正常下载镜像安装的，如果大家使用的国内服务器，是不太好下载镜像的，可以到[这里下载](https://url62.ctfile.com/d/61737562-154632417-b7b9da?p=8732)安装。

下载完之后，把文件放到`/usr/apps/images`文件夹里，然后挨个按需导入即可，以下是导入命令：

```
docker load -i /usr/apps/images/bitnami_mysql8.0.tar 
docker load -i /usr/apps/images/bitnami_memcached1.6.39.tar 
docker load -i /usr/apps/images/bitnami_wordpress6.8.2.tar 
docker load -i /usr/apps/images/bitnami_nginx1.29.0.tar 
docker load -i /usr/apps/images/bitnami_matomo5.3.2.tar 
docker load -i /usr/apps/images/louislam_uptime-kuma1.tar 
docker load -i /usr/apps/images/ddsderek_easyimage2.8.6.tar 
```

然后再命令行切换到`cd /usr/apps/`目录下执行`docker compose up -d` 即可。

可以通过`docker ps -a` 查看容器的启动状态，如果都启动成功了则会如下显示：

![image-20250826143933054](https://image.hyly.net/i/2025/08/26/85e9821da01546f4b1902289cfb1b893-0.webp)

如果看哪个容器启动失败了可以通过`docker logs 容器名（如wordpress）`查看容器日志，根据具体日志询问GPT如何修改即可。

## Nginx配置

容器启动后，想要通过网站访问还需要进行nginx配置，新建`wordpress.conf`文件放到`/usr/apps/blog/nginx/conf/`目录下，详细配置如下：

```
    # 博客
    server {
        # 这里监听8080端口，compose文件nginx配置把服务器80端口映射到容器8080端口。
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
    
        # 评论邮件退订链接转发。具体设置可以看这篇文章（https://hyly.net/categroy/article/code/wordpress/357/）
        location ^~ /unsubscribe-comment-mailnotice {
            # 使用 PHP-FPM 处理请求
            fastcgi_pass wordpress:9000;  # PHP-FPM 监听 9000 端口
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME /bitnami/wordpress/wp-content/themes/argon/unsubscribe-comment-mailnotice.php;  # 使用容器内的路径
            fastcgi_param DOCUMENT_ROOT /bitnami/wordpress;
        }

        #添加ads.txt谷歌广告,如暂时不需要可以把这节注释掉或不用管，没有影响。
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

因为自己启用了HTTPS安全访问，免费的，所以建议小伙伴们也使用HTTPS访问，详细的使用方法可以看[这篇文章](https://hyly.net/categroy/article/code/wordpress/353/#header-id-22)。

弄完配置文件后重启下nginx容器`docker restart nginx`，然后域名`hyly.net`解析了服务器IP（域名如何解析IP看[这篇文章](https://hyly.net/categroy/article/code/wordpress/353#header-id-21)），就可以在浏览器里访问`https://你的域名`就可以访问Wordpress了。后台登陆地址为`https://你的域名/wp-admin`或`https://你的域名/wp-login.php`

至此，wordpress就全部安装好了，为了增强wordpress的功能大家可以看[这篇文章](https://hyly.net/categroy/article/code/wordpress/380)的插件推荐。想拥有一款漂亮的外观主题可以看这篇文章。

# 第三方工具增强

如果大家只是构建wordpress博客网站，以上教程就可以了，想要功能增强的可以安装推荐的插件。这里还有一些通过非插件式增强wordpress的推荐工具。

## Matomo网站访问监控构建

Matomo是一款开源可自建的网站流量数据统计分析工具，核心价值是全面统计+隐私可控。功能类似 Google Analytics，但数据完全由你自己掌控，避免隐私泄露。选择它就是因为它功能强大和数据完全是自己所有。

 **核心功能**：

1. 统计网站访问量、来源渠道、访客地域、设备/浏览器等信息
2. 跟踪用户行为路径（点击、停留、转化）
3. 提供实时访客监控与报表
4. 支持电商转化率、事件追踪、自定义指标
5. 可与 WordPress、WooCommerce 等集成

### compose 构建

首先进入mysql数据库容器创建matomo的数据库和对应的账号密码并授权，这样才能在启动容器的时候能正确的创建对应数据表。

```
# 进入mysql容器，之后按照提示输入mysql账户密码
docker exec -it mysql mysql -u root -p
# 创建matomo数据库。
CREATE DATABASE matomoshujukumingcheng CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
# 创建matomo数据库账号。
CREATE USER 'matomoshujukuzhanghao'@'%' IDENTIFIED BY 'matomoshujukumima';
# 给matomo数据库账号赋权
GRANT ALL PRIVILEGES ON matomoshujukumingcheng.* TO 'matomoshujukuzhanghao'@'%';
# 刷新权限。
FLUSH PRIVILEGES;
```

matomo构建只需在compose文件中添加这段即可：

```
#网站访问量监控
  matomo:
    image: bitnami/matomo:5.3.2
    container_name: matomo
    depends_on:
      - mysql
    environment:
      - TZ=Asia/Shanghai
      - MATOMO_DATABASE_HOST=mysql
      - MATOMO_DATABASE_PORT_NUMBER=3306
      - MATOMO_DATABASE_USER=matomoshujukuzhanghao
      - MATOMO_DATABASE_PASSWORD=matomoshujukumima
      - MATOMO_DATABASE_NAME=matomoshujukumingcheng
    volumes:
      - ./blog/matomo:/bitnami/matomo
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined
```

然后`docker compose up -d`启动就可以。

### Nginx配置

容器启动后，想要通过网站访问还需要进行nginx配置，新建`matomo.conf`文件放到`/usr/apps/blog/nginx/conf/`目录下，详细配置如下：

```
   # matomo
    server {
        listen 8080;
        server_name matomo.hyly.net www.matomo.hyly.net;
        
        return 301 https://$host:8443$request_uri;
    }
    # matomo443
    server {
    listen 8443 ssl;
    server_name matomo.hyly.net www.matomo.hyly.net;

    client_max_body_size 100M;  # 你可以改成你想允许的最大上传大小
	# 证书路径
    ssl_certificate     /opt/bitnami/nginx/certs/hylynet.pem;
    ssl_certificate_key /opt/bitnami/nginx/certs/hylynet.key;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|ttf|svg|eot|otf|map)$ {
        proxy_pass http://matomo:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        expires 7d;
        access_log off;
    }

    location / {
        proxy_pass http://matomo:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
    }
}

```

弄完配置文件后重启下nginx容器`docker restart nginx`，然后域名`matomo.hyly.net`解析了服务器IP（域名如何解析IP看[这篇文章](https://hyly.net/categroy/article/code/wordpress/353#header-id-21)），就可以在浏览器里访问`https://matomo.你的域名`就可以访问matomo了。

### 连接网站

首次登录需要初始化账号密码等信息，挨个填就行了，设置完之后进入后台会提示选择安装matomo的方式，这里选择Wordpress，然后选择插件连接：

![image-20250826164226494](https://image.hyly.net/i/2025/08/26/46f0263a14fc14c29228d3d837fb51e3-0.webp)

![image-20250826164249627](https://image.hyly.net/i/2025/08/26/c6ec34d9da20339e2d6fb9ca78c30c85-0.webp)

在wordpress插件市场里搜索`Connect Matomo`即可安装，然后根据上图的提示一步步设置即可：

![image-20250826164356509](https://image.hyly.net/i/2025/08/26/5921c4971e23c62bf8acface80213319-0.webp)

这是通过创建单独的matomo容器然后wordpress安装`Connect Matomo`插件，把网站数据连接发送到单独的matomo容器中。还有一种方式是直接安装`Matomo`插件，他是直接把matomo内嵌到wordpress中去，在wordpress的数据库中直接建matomo的相关表去管理数据。这两者的区别如下：

![image-20250826165011163](https://image.hyly.net/i/2025/08/26/8bcbe04165a44597b13390e23045f35d-0.webp)

1. **架构层面**
	1. **独立 Matomo 容器 + Connect Matomo 插件**
		1. Matomo 是独立运行的服务（单独的 PHP + 数据库环境）。
		2. WordPress 只是通过插件把数据上报给独立 Matomo 实例。
		3. 架构更清晰，解耦，适合多站点共用一个 Matomo。
	2. **WordPress 内嵌 Matomo 插件**
		1. Matomo 完全运行在 WordPress 站点内。
		2. 所有数据直接存储在 WordPress 的数据库（MySQL/MariaDB）里。
		3. 一体化，安装简单，但耦合性高。
2. **数据库 & 数据存储**
	1. **独立 Matomo 容器**
		1. Matomo 使用单独的数据库（matomo 数据库）。
		2. 与 WordPress 数据隔离，管理、迁移、备份更灵活。
		3. 数据量大时性能更稳定（PV/UV 高的网站更推荐）。
	2. **内嵌 Matomo 插件**
		1. 在 WordPress 的数据库里新建一堆 `wp_matomo_*` 表。
		2. 网站数据和分析数据混合在一个库里。
		3. 如果访问量很大，数据库会膨胀，拖慢 WordPress 性能。
3. **功能支持**
	1. **独立 Matomo 容器**
		1. 支持 Matomo 全部功能，包括高级插件（Heatmap、Session Recording、A/B Testing 等）。
		2. 可支持多站点跟踪（一个 Matomo 跟踪多个 WordPress 站点或甚至非 WP 站点）。
		3. API、定时任务（archive.php）、高级配置都能用。
	2. **内嵌 Matomo 插件**
		1. 功能有部分限制。
		2. 主要用于基本的访问统计、来源、页面浏览等。
		3. 对高阶功能支持不完整，有些功能不可用或者需要额外手动配置。
4. **性能与扩展性**
	1. **独立 Matomo 容器**
		1. 更适合高流量站点。
		2. 数据量大时可以单独调优数据库（索引、分区表、归档策略）。
		3. Matomo 升级不影响 WordPress。
	2. **内嵌 Matomo 插件**
		1. 适合小站点或测试用途。
		2. 流量大时，WordPress + Matomo 数据混合，性能瓶颈明显。
		3. 插件升级要跟 WordPress 兼容，受限制。
5. **维护与部署**
	1. **独立 Matomo 容器**
		1. 部署稍复杂，需要维护两个系统（WordPress + Matomo）。
		2. 需要单独的数据库、备份策略。
		3. 好处是灵活，升级独立，不影响 WP。
	2. **内嵌 Matomo 插件**
		1. 安装最简单，直接 WP 插件安装就能用。
		2. 不需要单独数据库。
		3. 升级方便，但耦合风险高（WP 升级可能导致插件兼容性问题）。

**总结推荐**

- **如果你的网站流量小（比如每天几百 ~ 几千 PV）、只需要基础统计 →**
	 👉 用 **Matomo 插件内嵌** 就行，安装快，省事。
- **如果你的网站流量中等或很大（每天几万 ~ 上百万 PV）、想用高级功能、多个站点共享统计 →**
	 👉 建议 **独立 Matomo 容器 + Connect Matomo 插件**，更专业、更稳、更扩展性强。

### 界面预览

在所有网站页面就可以看到已经连接成功的网站，然后网站页面访问数据就会在仪表盘中显示，可以查看自己网站的流量情况。

![image-20250826170731133](https://image.hyly.net/i/2025/08/26/280340beffff5e28d81ec84b942982df-0.webp)

## UptimeKuma 网站可用性监控构建

Uptime Kuma是一款开源免费自建的网站和服务在线状态监控平台，核心就是让你实时掌握自己网站、服务器、API 等服务是否可用并做到及时通知。

**核心功能**

1. **多种监控方式**
	1. HTTP(s) 请求监控（检查网页能否访问、响应码是否正确）
	2. TCP/UDP 端口监控（比如数据库、SSH、SMTP 等服务）
	3. Ping 探测
	4. DNS 查询
	5. Docker 容器监控
	6. Push 方式（主动推送心跳）
2. **通知提醒**
	1. 支持 90+ 通知渠道（邮件、Telegram、钉钉、飞书、Slack、Discord、微信企业号、 Bark、Gotify 等）
	2. 可以配置宕机/恢复通知的延时与频率
3. **状态页（Status Page）**
	1. 自动生成一个美观的对外状态页面，像大公司（GitHub、Cloudflare）那样展示服务运行情况。
	2. 可以公开给用户看，也可以私有
4. **数据统计与可视化**
	1. 显示实时在线率
	2. 保留历史监控数据，支持图表分析
	3. Uptime SLA 统计（如 30 天在线率 99.99%）
5. **轻量 & 自建**
	1. 完全开源，数据保存在自己的数据库里（SQLite / MySQL / MariaDB）
	2. 部署方式灵活：Docker 一键运行，或者 Node.js 手动安装

### compose 构建

UptimeKuma 构建只需在compose文件中添加这段即可：

```
#网站可用性监控
  uptimeKuma:
    image: louislam/uptime-kuma:1
    container_name: uptimeKuma
    restart: unless-stopped
    volumes:
      - ./blog/uptimeKuma:/app/data
    networks:
      - wpnetwork
    environment:
      - TZ=Asia/Shanghai
```

然后`docker compose up -d`启动就可以。

### Nginx配置

容器启动后，想要通过网站访问还需要进行nginx配置，新建`uptimeKuma.conf`文件放到`/usr/apps/blog/nginx/conf/`目录下，详细配置如下：

```
server {
    listen 8080;
    server_name kuma.hyly.net www.kuma.hyly.net;

    return 301 https://$host:8443$request_uri;
}

# kuma HTTPS 配置
server {
    listen 8443 ssl;
    server_name kuma.hyly.net www.kuma.hyly.net;
	# 证书路径
    ssl_certificate     /opt/bitnami/nginx/certs/hylynet.pem;
    ssl_certificate_key /opt/bitnami/nginx/certs/hylynet.key;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    client_max_body_size 50M;

    location / {
        proxy_pass  http://uptimeKuma:3001;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

```

弄完配置文件后重启下nginx容器`docker restart nginx`，然后域名`kuma.hyly.net`解析了服务器IP（域名如何解析IP看[这篇文章](https://hyly.net/categroy/article/code/wordpress/353#header-id-21)），就可以在浏览器里访问`https://kuma.你的域名`就可以访问UptimeKuma了。

### 界面预览

首次访问会进行初始化，初始化完毕之后在这里添加网站，这是我的详细配置，大家可以进行参考，其中要设置邮件通知SMTP，我是设置的QQ邮箱的，不懂怎么设置的小伙伴可以参考[这篇文章](https://hyly.net/categroy/article/code/wordpress/380#header-id-29)。

![image-20250826172731148](https://image.hyly.net/i/2025/08/26/626f184ede7ce549dac11631152c8f8f-0.webp)

当网站不可用的时候就会邮件通知啦~也就不用自己时刻盯着网站了，虽然自己平时也不会经常看邮件→_→

![image-20250826173328954](https://image.hyly.net/i/2025/08/26/aae2ca61ac25a2a4433c189d2da7f196-0.webp)

他还有各种各样的其他通知方式，小伙伴们可以自行探索。

![image-20250826173357519](https://image.hyly.net/i/2025/08/26/140824d2f7e5ee9a6dc0313eb16fd96e-0.webp)

## Easyimage图床构建

图床顾名思义就是给图片找个家（存储的位置），文字类直接上传wordpress无任何压力，但是图片一般都比较大，就需要有专门的地方去存储，这就是图床了。一般是使用Typora写markdown时把图片上传到图床然后把返回的图片链接粘贴到markdown文件中就可以正常显示图片了。关于到底是第三方图床或自建图床，或者自建图床都有哪些选择，请看下边详细对比：

### 自建图床 vs 第三方图床

<table><thead><tr><th>对比维度</th><th>自建图床</th><th>第三方图床</th></tr></thead><tbody><tr><td>控制权</td><td>完全自控，图片存储在自己服务器，可自由管理、迁移</td><td>受服务商控制，可能随时限制或删除</td></tr><tr><td>隐私安全</td><td>数据私有，安全性高</td><td>存在泄露风险，上传即外包给第三方</td></tr><tr><td>稳定性</td><td>依赖自身服务器和网络，需维护</td><td>稳定性通常较高，CDN加速，全球访问快</td></tr><tr><td>访问速度</td><td>取决于服务器带宽和地理位置</td><td>通常全球 CDN 加速，访问速度快</td></tr><tr><td>功能扩展</td><td>可自定义水印、压缩、访问控制、API等</td><td>功能受限，按服务商提供的功能</td></tr><tr><td>成本</td><td>需要服务器、存储、维护成本</td><td>免费或按流量/会员付费</td></tr><tr><td>易用性</td><td>需要自己部署和维护</td><td>即开即用，操作简单</td></tr></tbody></table>

**总结**：

- **小型个人站点、对隐私和可控性要求高** → 自建图床
- **对速度、稳定性要求高、无需运维** → 第三方图床（如图怪兽、腾讯云 COS、SM.MS 等）

### 自建图床对比

<table><thead><tr><th>图床</th><th>技术栈</th><th>主要特点</th><th>优点</th><th>缺点</th><th>适用场景</th></tr></thead><tbody><tr><td>Easyimage</td><td>Docker / PHP / MySQL</td><td>面向个人和小团队，提供后台管理和批量上传</td><td>部署简单、支持 Docker；后台管理方便；支持多用户</td><td>功能相对简单；对大规模访问不够优化</td><td>个人博客、团队小图床</td></tr><tr><td>lsky（兰空图床）</td><td>Go / SQLite/MySQL</td><td>高性能，支持七牛/OSS等外部存储</td><td>高性能，支持多种存储后端；支持短链接、Markdown 插件</td><td>部署稍复杂；文档相对少</td><td>博客、论坛、开发者使用，图片量中等</td></tr><tr><td>Chevereto 付费版</td><td>PHP / MySQL</td><td>类 Imgur 风格，可自建专业图床</td><td>界面漂亮、功能丰富（多用户、主题、标签、分类、API）</td><td>付费专业版功能更多；资源占用较大</td><td>专业图床、团队、社区网站</td></tr><tr><td>PicGo + 自建图床</td><td>Node.js / 多存储支持</td><td>客户端上传工具，支持多种云存储</td><td>支持多存储（七牛、阿里云、S3）；客户端上传方便</td><td>依赖第三方存储或自建服务；部署较复杂</td><td>博客写作、Markdown 插件配合使用</td></tr><tr><td>Chevereto Free</td><td>PHP / MySQL</td><td>免费版功能有限</td><td>可快速部署，界面简洁</td><td>免费版功能受限；无多用户管理</td><td>小型个人博客</td></tr></tbody></table>

chevereto 免费版功能有限制，付费版则不考虑。lsky(兰空图床)自己搭建了一个使用起来不是那么顺畅，所以自己最后选择了Easyimages。免费、后台管理功能易懂强大，而且不需要数据库管理，很适合。

### compose构建

Easyimages 构建只需在compose文件中添加这段即可：

```
# easyimage图床
  easyimage:
    image: ddsderek/easyimage:v2.8.6
    container_name: easyimage
    environment:
      - TZ=Asia/Shanghai
      #- PUID=1000
      #- PGID=1000
      #- DEBUG=false
    volumes:
      # 图床配置目录。
      - ./blog/easyimage/config:/app/web/config
      # 图床图片存储目录。
      - ./blog/easyimage/i:/app/web/i
    restart: unless-stopped
    networks:
      - wpnetwork
```

然后`docker compose up -d`启动就可以。

### Nginx配置

```
# easyimage HTTP 自动跳转到 HTTPS
server {
    listen 8080;
    server_name image.hyly.net www.image.hyly.net;

    return 301 https://$host:8443$request_uri;
}

# easyimage HTTPS 配置
server {
    listen 8443 ssl;
    server_name image.hyly.net www.image.hyly.net;
	# 证书目录
    ssl_certificate     /opt/bitnami/nginx/certs/hylynet.pem;
    ssl_certificate_key /opt/bitnami/nginx/certs/hylynet.key;

    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    client_max_body_size 50M;

   # 防盗链：只允许来自 hyly.net 和搜索引擎 、localhost 的请求访问图片
    location ~* \.(jpg|jpeg|png|gif|webp|bmp|svg)$ {
        valid_referers none blocked server_names hyly.net *.hyly.net *.google.com *.bing.com *.baidu.com *.yahoo.com *.yandex.com *.duckduckgo.com *.ecosia.org *.naver.com *.seznam.cz ~\.localhost ~\.cloudflare\.com;
        if ($invalid_referer) {
            return 403;
        }

        # 代理给 easyimage 图床服务
        proxy_pass  http://easyimage:80;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location / {
        proxy_pass  http://easyimage:80;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    # 禁用目录列表，防止别人通过访问目录直接下载。
    location /i/ {
        autoindex off;
    }
}

```

弄完配置文件后重启下nginx容器`docker restart nginx`，然后域名`image.hyly.net`解析了服务器IP（域名如何解析IP看[这篇文章](https://hyly.net/categroy/article/code/wordpress/353#header-id-21)），就可以在浏览器里访问`https://image.你的域名`就可以访问easyimage了。

### 详细配置

首次访问会进行初始化，初始化完毕之后大家可以在设置里参考我的配置：

![image-20250826182913564](https://image.hyly.net/i/2025/08/26/a7ae465b7440148e56ce18e1c746abfc-0.webp)

![image-20250826183445229](https://image.hyly.net/i/2025/08/26/01aee11a025b550af8c7e735105b6453-0.webp)

![image-20250826183627057](https://image.hyly.net/i/2025/08/26/05630747ed5762458caef344f866cdcd-0.webp)

可以通过这个接口上传图片，主要用法为在typora里直接粘贴图片，然后调用picList直接上传图片到easyimage里面去，最后在typora里直接显示图床链接的图片。详细用法可以看这篇文章。

![image-20250826183718870](https://image.hyly.net/i/2025/08/26/a1f3b42f4d92d49b0f3360e7599c1fda-0.webp)

![image-20250826183949906](https://image.hyly.net/i/2025/08/26/37a2fb8acf5c56d6a4c20a03ab6d0c7c-0.webp)

![image-20250826184121764](https://image.hyly.net/i/2025/08/26/d1ed8cb537dc657d3dc2b9058d6b68af-0.webp)

![image-20250826184746971](https://image.hyly.net/i/2025/08/26/37863b439cb032a0d106b978327af49a-0.webp)

![image-20250826184906428](https://image.hyly.net/i/2025/08/26/326a403a7a36c9dce6b3404a0e9da359-0.webp)

# 小结

至此Wordpress和协助使用的第三方工具就搭建完成了，有疑问的小伙伴可以在文章下方留言与我互动，有最新的资料我也会及时更新本文章，感兴趣的小伙伴请关注点赞哈~
