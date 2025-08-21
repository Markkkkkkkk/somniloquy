---
category: [博客建站]
tag: [argon,评论邮件退订]
postType: post
status: publish
---

# 问题发现

小伙伴们在给热门文章评论的时候填入自己邮箱会有邮件提醒这个功能，当有人回复自己评论的时候会有邮件通知，能及时回复消息。

![](https://image.hyly.net/i/2025/08/20/31e78d81edc8645da169efec993874f5-0.webp)

但是如果评论太热门好多人跟评的话频繁的邮件通知也会给自己带来一定困扰，幸好邮件提醒下方有退订该评论邮件提醒的功能，只需要复制链接在浏览器打开就行了。

![](https://image.hyly.net/i/2025/08/20/9150694588c1171ab9e964defd2ab29b-0.webp)

但是打开链接发现页面是404

![image-20250820172247907](https://image.hyly.net/i/2025/08/20/553561f8145ca02c9b481d67c4b32aa3-0.webp)

我查阅了一些资料之后发现这是wordpress的主题Argon的一些小BUG，经过多番查阅资料才解决了问题，给自己点个大大的赞！~**:smile:**

# 问题解决

经过多番查找资料，在argon的github [issue](https://github.com/solstice23/argon-theme/issues/75)里面有人提到过这个问题，作者也给出了解决办法，但是自己用bitnami/wordpress镜像docker compose 启动的根本不适用。。。

![image-20250820173338202](https://image.hyly.net/i/2025/08/20/cc97a0a3876bea9da812de175eb57ed8-0.webp)

## nginx配置文件修改

不过经由作者提醒，这是因为评论邮件退订链接是单独的一个链接访问的，不是由首页一步步点进去的，所以nginx找不到退订处理的php文件，需要经由nginx路由转发一下。只有红框里的起作用，为了`wordpress.conf`文件完整给大家参考，就把配置文件都贴出来了。转发规则如下：

```
    # 博客
    server {
        listen 8080;
        server_name hyly.net www.hyly.net;
        
        return 301 https://$host:8443$request_uri;

    }
    # 博客443
    server {
    listen 8443 ssl;
    server_name hyly.net www.hyly.net;

    client_max_body_size 100M;  # 你可以改成你想允许的最大上传大小
	# SSL密钥文件
    ssl_certificate     /opt/改成自己实际密钥的路径ynet.pem;
    ssl_certificate_key /opt/改成自己实际密钥的路径ynet.key;

    ssl_protocols       TLSv1.2 TLSv1.3;
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
    # 8443 的 server 块里添加：
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

![image-20250820174200253](https://image.hyly.net/i/2025/08/20/3b546783bf5e7bc04a2391b6b11bc4c9-0.webp)

## bitnami/wordpress容器配置文件修改

转发到bitnami/wordpress容器里的php-fpm处理了，但是容器里的php-fpm没有启动，而且默认配置文件时unix套接字的，不是端口监听，所以还需要再改下`docker-compose.yml`文件里wordpress的配置：

```
wordpress:
    image: bitnami/wordpress:6.8.2
    container_name: wordpress
    depends_on:
      - mysql
      - memcached
    environment:
      # mysql数据库设置
      - TZ=Asia/Shanghai
      - WORDPRESS_DATABASE_HOST=mysqlrongqiming
      - WORDPRESS_DATABASE_PORT_NUMBER=3306
      - WORDPRESS_DATABASE_NAME=shujukumingcheng
      - WORDPRESS_DATABASE_USER=shujukuzhanghao
      - WORDPRESS_DATABASE_PASSWORD=shujukumima
      - WORDPRESS_USERNAME=wordpressdengluming
      - WORDPRESS_PASSWORD=wordpressdenglumima
      # Redis 相关配置（如果你要用 Redis 缓存）
    #   - WORDPRESS_REDIS_HOST=redis
    #   - WORDPRESS_REDIS_PORT=6379
    #   - WORDPRESS_REDIS_PASSWORD=redismima
    #   - WORDPRESS_ENABLE_REDIS_CACHE=yes
    #   - WORDPRESS_PLUGINS=redis-cache
      # wordpress设置
      - WORDPRESS_EMAIL=wordpressyouxiang
      - PHP_UPLOAD_MAX_FILESIZE=100M
      - PHP_POST_MAX_SIZE=100M
      # - PHP_MEMORY_LIMIT=256M
    volumes:
      - ./blog/wordpressData:/bitnami/wordpress
      # 评论邮件退订映射地址
      - ./blog/wordpressData/conf:/opt/bitnami/php/etc/php-fpm.d
      # 评论邮件退订映射地址
      - ./blog/wordpressData/wordpressSH/entrypoint.sh:/opt/bitnami/scripts/wordpress/entrypoint.sh
    restart: unless-stopped
    networks:
      - wpnetwork
    cap_add:
      - SYS_NICE
    security_opt:
      - seccomp:unconfined
```

重要的是下边两个映射：

```
- ./blog/wordpressData/conf:/opt/bitnami/php/etc/php-fpm.d
      - ./blog/wordpressData/wordpressSH/entrypoint.sh:/opt/bitnami/scripts/wordpress/entrypoint.sh
```

大家添加这两个映射如果遇到`docker compose up -d`启动报这个下边这个错误的话是因为这两个文件默认不会被拷贝出来，只会本地的覆盖掉容器内的，这时候就需要先把这两个映射注释掉，先`docker compose up -d`启动起来，然后进入容器把文件拷贝出来，修改完然后再放开这两个路径映射再重新启动就可以了。别忘了把这两个映射路径冒号左边的文件夹先创建出来。

拷贝命令如下：

```
docker cp wordpress:/opt/bitnami/php/etc/php-fpm.d ./blog/wordpressData/conf
docker cp wordpress:/opt/bitnami/scripts/wordpress/entrypoint.sh ./blog/wordpressData/wordpressSH/entrypoint.sh

```

第一个是把php-fpm.d下的`www.conf`配置文件映射出来，修改里面的listen监听为9000，找到这一行并修改

```
#初始的
listen = /opt/bitnami/php/var/run/www.sock
#修改后的
listen = 9000
```

![image-20250820180606775](https://image.hyly.net/i/2025/08/20/9735f0fb50be1349952c92dab18e3a26-0.webp)

第二个是把`entrypoint.sh `bitnami/wordpress的启动脚本映射出来修改，加上这一行：

```
# 启动 PHP-FPM
info "** Starting PHP-FPM **"
/opt/bitnami/php/sbin/php-fpm
```

![image-20250820181830569](https://image.hyly.net/i/2025/08/20/508898dbf0167a43ea30f5c1d57aefeb-0.webp)

修改完这两个脚本`docker compose up -d`重启的时候如果提示权限问题，就修改下这两个文件的权限：

```
sudo chmod -R 777 /usr/apps/blog/wordpressData/conf
sudo chmod -R 777 /usr/apps/blog/wordpressData/wordpressSH
```

## argon评论邮件退订php文件修改

`/usr/apps/blog/wordpressData/wp-content/themes/argon/unsubscribe-comment-mailnotice.php`

这是argon评论邮件退订处理的php，经由nginx能转发到这个php进行处理请求，它首先请求了一个`wp-blog-header.php`

![image-20250820183126912](https://image.hyly.net/i/2025/08/20/26bbbfc64312e325de5372fefa7463ad-0.webp)

但是根据`unsubscribe-comment-mailnotice.php`在bitnami/wordpress容器里的路径`/bitnami/wordpress/wp-content/themes/argon/unsubscribe-comment-mailnotice.php`红框里的这段代码计算出来的路径是`/bitnami/wordpress/wp-blog-header.php`是不存在的，他在bitnami/wordpress里的真实路径为`/opt/bitnami/wordpress/wp-blog-header.php`这是两个路径，在容器里的文件树是这样的：

![image-20250820184131230](https://image.hyly.net/i/2025/08/20/1d7e6411a944c227bd7a07496607b174-0.webp)

所以只需要`unsubscribe-comment-mailnotice.php`这个文件修改一下就可以了：

![image-20250820184222220](https://image.hyly.net/i/2025/08/20/54a639de04d90a125637651f8a3324f4-0.webp)

至此，该修改的地方已经全部改完了，这时候再把评论退订邮件链接粘到浏览器里就会显示成功退订的提示啦~

`https://hyly.net/unsubscribe-comment-mailnotice?comment=22&token=5fe46bff45e2b33f957ca39f92a5b911`

![image-20250820184402710](https://image.hyly.net/i/2025/08/20/4e51926e47e06386910b6aedffac7080-0.webp)