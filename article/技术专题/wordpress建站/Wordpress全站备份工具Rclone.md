---
category: [博客建站]
tag: [wordpress,rclone,备份,mysqldump]
postType: post
status: publish
---

# Wordpress全站备份工具Rclone

## 前言

大家通过Wordpress的一系列文章，想必已经能把自己的博客网站独立建设起来了，之后就是疯狂写文章发布了。虽然有之前的[服务器和wordpress网站安全防护](https://www.hyly.net/categroy/article/code/wordpress/353/)，能解决大部分的安全问题。但我们要假设一种极端情况就是服务器连不上了，网站崩了，总之各种原因网站用不了了，我们能否马上另起炉灶或者恢复呢？这就是全站备份了。实现的效果就是不管遇到任何极端情况，网站数据在自己手里，换个服务器，或者哪怕换个域名也能快速把自己这一套部署起来！

## Rclone

Rclone是一个强大的命令行工具，用于在本地与各类云存储（如 Google Drive、OneDrive、S3、Dropbox 等）之间进行文件同步、迁移、备份和挂载。

核心功能包括：

1. **跨云存储/本地的数据同步与迁移**（支持增量、双向同步）。
2. **加密与压缩**（在传输或存储过程中保护和优化数据）。
3. **挂载云存储为本地磁盘**（像操作本地硬盘一样操作云端文件）。
4. **大文件分片上传与断点续传**（适合超大文件和不稳定网络）。
5. **多线程并行传输**（大幅提升速度）。
6. **广泛支持云存储厂商**（80+ 种服务/协议）。

我们就是要围绕Rclone把服务器网站数据同步备份到本地。为什么要选本地呢，因为云厂商的OSS需要付费，各种网盘也不是保存重要数据的地方。所以还是数据保存到本地电脑比较安全，东西只有放在自己手里才放心。

### 安装

首先去官网[下载Rclone](https://rclone.org/downloads/)，我当时下载的时候非常非常慢，或者大家也可以到[这里下载](https://url62.ctfile.com/d/61737562-154693405-515381?p=8732)：

![image-20250829150704634](https://image.hyly.net/i/2025/08/29/526b73f184eb38eb971b23d14d317a38-0.webp)

大家选适配自己电脑的下载就可以了，下载下来是一个压缩包，然后解压到一个目录即可。这里以`rclone-v1.70.3-windows-amd64`我安装的这个版本为示例，其他版本的估计也大差不差。进行Rclone配置之前，需要大家的服务器开启SSH密钥登录。不了解的小伙伴可以看[这篇文章](https://www.hyly.net/categroy/article/code/wordpress/353/)。以下是详细配置过程：

![image-20250829155232131](https://image.hyly.net/i/2025/08/29/03033c28c761fec9add89d264a590671-0.webp)

### 数据库备份脚本

Rclone是直接同步的文件，像mysql数据库这种虽然也能直接文件进行恢复，但是不太灵活，这里就利用mysqldump定时备份数据库，然后Rclone直接同步备份mysqldump后的sql文件，这样恢复数据也比较灵活，比如说sql导入本地mysql用navicat查看等。直接在该目录新建脚本`/usr/apps/databasebackup.sh`

```
#!/bin/bash
# 设置数据库连接参数
DB_USER="shujukuzhanghao"
DB_PASS="shujukumima"
DB_HOST="mysql"  # Docker 容器名称作为主机
DB_NAME1="wordpressshujuku"  # 你想备份的第一个数据库
DB_NAME2="matomoshujuku"  # 第二个数据库名
# 备份文件存储位置。
BACKUP_DIR="/usr/apps/blog/mysqlDataBackup"
DATE=$(date +\%F-\%H-\%M-\%S)

# 备份数据库1
docker exec mysql mysqldump -u$DB_USER -p$DB_PASS $DB_NAME1 > $BACKUP_DIR/$DB_NAME1-$DATE.sql

# 备份数据库2
docker exec mysql mysqldump -u$DB_USER -p$DB_PASS $DB_NAME2 > $BACKUP_DIR/$DB_NAME2-$DATE.sql

# 删除 7 天之前的备份文件
find $BACKUP_DIR -type f -name "*.sql" -mtime +7 -exec rm {} \;

```

#### 配置脚本定时执行

弄好数据库备份脚本之后我们还需要让他定时执行，把这个脚本任务添加到服务器cron定时任务中去。直接在服务器任意目录位置执行`crontab -e `，然后把我们的定时任务加进去即可：

![image-20250829163014299](https://image.hyly.net/i/2025/08/29/fe116ff478ac023d1705a3fefd175638-0.webp)

添加上之后按`Ctrl+X`退出提示是否保存，然后再按`Ctrl+Y  回车`保存脚本。最后可以`crontab -l`查看定时任务是否被正确添加：

![image-20250829173635041](https://image.hyly.net/i/2025/08/29/3930178b03c68c4545f32a87c8947bab-0.webp)

脚本添加完毕会在每天的凌晨两点执行mysqldump全量备份数据库。关于cron表达式时间如何设置不太了解的小伙伴可以看[这篇文章](https://www.runoob.com/w3cnote/linux-crontab-tasks.html)，[这个网站](https://cron.qqe2.com/)可以方便的生成cron表达式。

#### 脚本没有定时执行时常用的处理方案

正常来说定时任务应该执行了，但是在`/usr/apps/blog/mysqlDataBackup`目录没有看到新的备份文件，可以先手动执行下脚本`/bin/bash /usr/apps/databasebackup.sh`过一会如果还是没有新的备份文件，那就是脚本的问题，如果过一会是有备份文件的，那就是定时任务设置的问题，定时任务不生效常见有以下排查：

##### 定时任务没启动

执行命令`systemctl status cron` 查看定时任务是否启动，`acitve`则是启动了，如果没启动则执行命令：

```
# 启动cron
sudo systemctl start cron
# 加入开机自启
sudo systemctl enable cron
```

##### 检查任务是否写对

查看当前用户的 crontab，执行命令`crontab -l`，可能是：

1. 时间格式写错（应该是 分 时 日 月 星期 共 5 列）。
2. 缺少命令绝对路径，例如 /bin/bash /usr/apps/databasebackup.sh
3. 脚本路径写错。

或者可以先在`crontab -e`里写一个每分钟执行，输出一个文件到指定目录的定时任务。然后看文件夹里是否有这个文件，看crontab定时任务是否能够正确执行。

```
# 可以先写这个任务测试crontab是否能够正确执行任务。
* * * * * date '+\%Y-\%m-\%d \%H:\%M:\%S' > /usr/apps/blog/mysqlDataBackup/$(date +\%Y\%m\%d\%H\%M\%S).txt

```

如果还有其它问题，那就GPT解决吧（捂脸笑）。

### Rclone脚本

Rclone我们本地配置好之后，就是写脚本去同步ubuntu服务器上的博客网站数据了。在本地电脑新建脚本`sync_server.bat`：

```
@echo off
REM 获取当前时间（格式：YYYYMMDDHHMMSS）
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set datetime=%datetime:~0,4%%datetime:~4,2%%datetime:~6,2%%datetime:~8,2%%datetime:~10,2%%datetime:~12,2%
REM 运行 rclone 同步命令并加上时间戳后缀
"D:\develop\softInstall\rclone-v1.70.3-windows-amd64\rclone.exe"  sync ubuntusync:/usr/apps D:\workDocument\blogbackupsync\apps --filter "- mysqlData/**" --filter "- uptimeKuma/**" --filter "- cache/**" --backup-dir=D:\workDocument\blogbackupsync\updatebackup --suffix=-%datetime% --suffix-keep-extension -v --progress >> D:\workDocument\backuplog\rclone_log_%datetime%.txt 2>&1

```

参数详解：

```
1. D:\develop\softInstall\rclone-v1.70.3-windows-amd64\rclone.exe：开头首先指定rclone程序位置。
2. 复制模式：
	1. sync：使 目标目录 内容和 源目录 完全一致。会复制新增或修改的文件。会删除目标目录里 源目录没有的文件。
	2. copy：只把源目录的文件 复制到目标目录。新增、修改的文件会被复制。不会删除 目标端多余的文件。
	3. move：把源目录的文件移动到目标端。同步完成后，源端文件会被删除。类似于“剪切”。
	4. bisync：实现 双向同步，即源和目标两边都保持一致。会检查两边的变化。可以处理双方都新增/修改/删除的情况。比 sync 更智能，但也更复杂（需要 .bisync 元数据文件）。
	5. check：对比源和目标的文件是否一致。只检查，不做任何更改。默认比对文件大小和修改时间，也可用 --checksum 做哈希校验。
3. ubuntusync:/usr/apps：源目录
4. D:\workDocument\blogbackupsync\apps：本地目录，也叫目标目录。
5. --filter：过滤哪个目录，--filter "- mysqlData/**" 为哪个目录不同步， --filter "+ mysqlData/**" 为哪个目录进行同步。因为mysql采用mysqldump定时备份，所以不同步mysqlData数据主目录，uptimeKuma为监控网站是否可用，不太重要，所以也不同步。cache为缓存目录，也不进行同步。
6. --backup-dir=D:\workDocument\blogbackupsync\updatebackup：sync模式当源目录删除或更改文件时，目标目录会直接删除或更改文件，加这个参数是把删除或更改前的源文件保存到这个目录下，能做到文件历史记录追溯。
7. --suffix=-%datetime%：删除或更改的文件复制到新目录时后边会加一个时间后缀。
8. --suffix-keep-extension：加的时间后缀会在文件后缀名前。如wenjianming20250801.md,不加这个配置就是wenjianming.md20250801,可读性不好而且不能方便打开文件查看内容。
9. -v：输出一般详细的日志内容。-vv日志更详细。
10. --progress：在运行时显示实时传输进度条。
11. >> D:\workDocument\backuplog\rclone_log_%datetime%.txt 2>&1：把每次运行的日志都输出到这个文件中去。

```

脚本配置好后我们可以先手动运行一下，过一会发现目标目录有新下载的文件出现或任务管理器中rclone任务在启动并且有网速下载就是运行成功了。

#### 后台静默无黑窗口运行脚本

当运行脚本的时候会弹出来一个黑窗口，而且在脚本运行过程中这个黑窗口不能关闭，有时候同步过程时间还挺长的，所以就挺烦人的，我们这时候就可以设置后台静默无黑窗口运行脚本。可以在脚本同级目录新建`run_bat_hidden.vbs`，内容为：

```
REM 创建一个 WScript.Shell 对象，提供在 Windows 下执行命令、运行程序、访问注册表等功能。
Set WshShell = CreateObject("WScript.Shell")
REM 执行脚本 0是隐藏窗口执行，不弹出命令行窗口 False 不等待，脚本执行完这一行后立即继续下一行（异步执行）
WshShell.Run """D:\workDocument\sync_server.bat""", 0, False
```

这时候再运行`run_bat_hidden.vbs`，就不会看见黑窗口啦~也是为下文的定时执行做铺垫。

#### 配置脚本定时执行

不过我们不想每次想起来才运行一次，想加入定时运行怎么办。这时候就要用到window的任务计划程序了。首先在window应用搜索里搜**任务计划程序**：

![image-20250829181113687](https://image.hyly.net/i/2025/08/29/30d175a322e5c20eff20ff211a0c8df2-0.webp)

其次选则创建基本任务->填写任务名称：

![image-20250829181731187](https://image.hyly.net/i/2025/08/29/4b6c3445a8031c807942a1d589522164-0.webp)

新建触发器，开始任务选择**发生事件时**，然后按照我的填写就可以了，我写的是当系统从休眠中开机时触发执行任务。window电脑不使用休眠的，开始任务可以选择**启动时**或**登录时**，当系统从关机到启动触发任务或当系统登录用户时触发任务。

> **注意：**这里的登录用户并不是锁屏页面输入PIN或密码叫登录用户，这不叫登录。而是电脑注销了用户然后重新登录用户，这才叫用户登录，所以一般不用这个。
>
> 强烈安利大家使用电脑休眠。
>
> 1. 休眠是可以把当前电脑工作状态等由内存保存到磁盘中，然后电脑断电，再开机会重新恢复当时的工作状态，比如打开的软件/文档等（虽然有休眠，大家还是要养成及时保存文档的好习惯）。
> 2. 睡眠是电脑以低功耗运行，但是没有断电，大家重新使用电脑是从睡眠中恢复，虽然有睡眠前的工作状态但是它是电脑持续运行耗电。
> 3. 关机是电脑彻底断电，关机时打开的软件/未关闭保存的文档会提示你保存关闭等。然后重新开机，没有之前的工作状态。

![image-20250829181951330](https://image.hyly.net/i/2025/08/29/6e6fbd1766563c7be2dc42e51c7592eb-0.webp)

然后再配置操作，选择启动程序，选择我们刚才配置的后台静默无黑窗口运行的vbs程序。

![image-20250829184439216](https://image.hyly.net/i/2025/08/29/206423cc27bbb1672a1734f9a0efc27b-0.webp)

**条件**和**设置**这里默认就好：

![image-20250829230438826](https://image.hyly.net/i/2025/08/29/a72bc98a09e87f19a5490607707d31be-0.webp)

![image-20250829230616897](https://image.hyly.net/i/2025/08/29/9599f5fb3946f0bcbe12d33d0be98049-0.webp)

至此，整个备份流程就配置好了，当每次电脑从休眠中开机启动时，就会触发启动Rclone同步任务，把服务器上文件同步到本地，再也不担心数据会丢失了~

## 小结

按照上述教程一步步操作下来，如果遇到疑问的可以在文章下方留言哈~大家觉得文章不错的话也请点赞关注~
