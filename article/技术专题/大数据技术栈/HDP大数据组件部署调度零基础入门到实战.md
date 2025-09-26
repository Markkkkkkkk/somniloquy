---
category: [大数据技术栈]
tag: [HDP,大数据,中间件部署调度]
postType: post
status: publish
---

## HDP 环境安装配置

> HDP : *Hortonworks* *Data* *Platform*

> CDH : *Cloudera Distribution Hadoop*

**部署安装主要分为3大部分**

1. 准备环境、配置机器、准备离线包、本地仓库、数据库等
2. 安装Ambari Server 阶段
3. 基于Ambari Server UI 来安装相关服务组件阶段

> HDP集群的安装，95%的工作是对Ambari Server的安装配置。
>
> 所有对集群的安装、配置、管理等都是通过Ambari Server UI来完成
>
> 也就是说，Ambari Server UI 是整个集群的管理员，我们多数操作都是通过它来进行的，而不需要像部署开源Hadoop那样去一台台机器手动去部署。

> Ambari Server UI 是我们对集群进行管理的入口。如同Linux Shell是操作系统的操作界面一样，Ambari Server UI 就是整个集群的操作界面

### 环境检查

#### 产品互用性

首先， 需要确定使用的Ambari版本，可以参考: [https://supportmatrix.hortonworks.com](https://supportmatrix.hortonworks.com/) , 这里列出了Ambari和HDP等组件的版本依赖关系

我们这里使用Ambari 2.7.0， HDP 3.0.0 来安装部署集群

> Ambari 和 HDP 有版本依赖关系
>
> 然后HDP的版本 和其内部可使用的大数据组件也有版本参照关系

HDP版本对应的各个大数据组件版本参见:

![image.png](https://image.hyly.net/i/2025/09/26/0a51359ceecacfe8b06bb2e61495f3a6-0.webp)

#### 课程使用的版本信息

根据 > https://supportmatrix.hortonworks.com 的选择后，课程使用

- Centos 7.4 x64 操作系统
- JDK8
- HDP 3.0.0
- Ambari 2.7

> 同学们如果想要尝试其他版本，请按照网站的搭配来确定版本

#### 最小系统需求

##### 软件需求:

- `yum` and `rpm` (RHEL/**CentOS**/Oracle/Amazon Linux)
- `zypper` and `php_curl` (SLES)
- `apt` (Debian/Ubuntu)
- `scp, curl, unzip, tar`, `wget`, and `gcc*`
- OpenSSL (v1.01, build 16 or later)
- Python (with python-devel*)(psutil and gcc)

> Ambari Metrics Monitor uses a python library (psutil) which requires gcc and python-devel packages.

### 安装前的环境配置

#### 最大可打开文件描述符需求(所有服务器均设置)

The recommended maximum number of open file descriptors is 10000, or more. To check the current value set for the maximum number of open file descriptors, execute the following shell commands on each host:

`ulimit -Sn`
`ulimit -Hn`

If the output is not greater than 10000, run the following command to set it to a suitable default:

`ulimit -n 10000`

#### 配置主机名和/etc/hosts文件(所有服务器均设置)

1. 配置主机名 `hostnamectl set-hostname "主机名"`
2. 配置/etc/hosts文件

   要在hosts文件中配置 `FQDN`形式的主机名映射，比如

   ```shell
   192.168.179.100 hdp0.itcast.cn hdp0
   192.168.179.101 hdp1.itcast.cn hdp1
   ```
3. 使用 `hostname -f`检查是否能够映射FQDN主机名

#### 禁用 SELinux 和 PackageKit 并检查 umask 值(所有服务器均设置)

- 您必须禁用SELinux才能使Ambari设置正常运行, 在群集中的每台主机上，输入：

  ```shell
  # 临时禁用
  setenforce 0
  # 永久禁用 SELinux
  vim /etc/SELinux/config
  selinux=disabled
  ```
- 在安装了带有PackageKit的RHEL / CentOS的安装主机上，打开

  `/etc/yum/pluginconf.d/refresh-packagekit.conf` 使用文本编辑器, 进行以下更改

  ```shell
  enabled=0
  ```

  > 在 Debian、 SLES 或 Ubuntu 系统上默认不启用 PackageKit。 除非您特别启用了 PackageKit，否则对于 Debian、 SLES 或 Ubuntu 安装主机，您可以跳过这一步
  >
- 设置umask为0022

  **UMASK Examples**:

  为当前登录session设置umask:

  `umask 0022`

  检查设置:

  `umask`

  为每个用户设置:

  `echo umask 0022 >> /etc/profile`

  > UMASK（用户掩码或用户文件创建MASK）设置在Linux计算机上创建新文件或文件夹时授予的默认权限或基本权限。
  > 大多数Linux发行版（发行版）都将022设置为默认的umask值。
  > umask值为022，为新文件或文件夹授予755的读取，写入和执行权限。
  > umask值027为新文件或文件夹授予750读取，写入和执行权限。
  > Ambari，HDP和HDF支持umask值022（0022在功能上等效），027（0027在功能上等效）。
  > 必须在所有主机上设置这些值。
  >

#### 配置iptables（防火墙）(所有服务器均设置)

> 为使Ambari在设置期间与其部署和管理的主机进行通信，某些端口必须是开放且可用的。
> 最简单的方法是禁用iptables，如下所示：

- ***RHEL/CentOS/Oracle/Amazon Linux***

  `systemctl disable firewalld `

  `service firewalld stop`

  > 可以在setup完成后重新启动iptables防火墙, 如果安全协议禁止你关闭防火墙，你可以打开防火墙，但是要确保所有需要的端口都打开
  >

> Ambari 在setup的过程中会检查iptables的状态，如果在运行会给出一个警告，建议你打开需要的访问端口。
>
> 群集安装向导中的“主机确认”步骤还会为运行iptables的每个主机发出警告

#### 设置SSH免密登陆(所有服务器均设置)

要让Ambari Server在所有群集主机上自动安装Ambari Agent，必须在Ambari Server主机与群集中的所有其他主机之间设置无密码SSH连接。
Ambari Server主机使用SSH公钥身份验证来远程访问和安装Ambari代理.

> You can choose to manually install an Ambari Agent on each cluster host. When you choose that way in this case, you do not need to generate and distribute SSH keys.

**Steps**

1. 生成ssh 秘钥 `ssh-keygen -t rsa`
2. 执行 `ssh-copy-id 目标主机`
3. 执行上述命令后，当前机器可以免密登陆到目标主机

如果想要手动安装 Ambari Agent without SSH non-password connecting , 请参阅: https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_installing_ambari_agents_manually.html

#### 关于各个组件需要的本地用户

很多组件可能会使用各自的本地账户，如hadoop服务可能会创建或者使用 `hadoop\hdfs` 这样的账户，HBase可能会创建或者使用 `hbase`本地账户。

本地账户如果不存在，会创建，如果存在会进行复用。

更多细节请参阅：https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_understanding_service_users_and_groups.html

#### 挂载系统安装盘到机器上，配置本地yum仓库用来安装软件(Ambari Server服务器设置即可)

```
配置本地yum源：
1.将iso光盘挂载到目录下

# 非虚拟机环境
mkdir /data #创建目录（存放iso镜像文件）
#将iso镜像文件上传到/data下
mkdir /mnt/centos #创建要挂载到的目录
mount /xxx/xxx/xxx.iso /mnt/centos

# 虚拟机环境
必须让虚拟机加载了安装盘
mkdir /mnt/centos
mount -t iso9660 -o loop /dev/cdrom /mnt/centos  // 虚拟机环境下，可以用光驱加载ISO文件，不需要上传

2.配置基于本地文件的yum源

cd /etc/yum.repos.d/
ll ./ #查看yum源文件配置
CentOS-Base.repo                #网络yum源
CentOS-Debuginfo.repo
CentOS-fasttrack.repo
CentOS-Media.repo               #本地yum源
CentOS-Vault.repo

3.先禁用本地的yum配置文件(必须以.repo结尾的yum配置文件才生效)

rename .repo .repo.bak ./*
yum repolist (检查，查不到东西说明，yum源已禁用)

4.复制一份CentOS-Media.repo

cp CentOS-Media.repo.bak local.repo

5.配置local.repo

vi local.repo
[centos7-local]
name=CentOS-$releasever - Local
baseurl=file:///mnt/centos/
gpgcheck=1
enabled=1
gpgkey=file:///mnt/centos/RPM-GPG-KEY-CentOS-7

6.yum clean all清缓存

7.yum repolist 查看仓库信息

#配置成功会显示
------------------------------------------------------------
repo id            repo name                       status
Local              CentOS-6 - Local                6,575
repolist: 6,575
------------------------------------------------------------

8. 将这个机器配置的本地仓库托管为http服务，让其他server可以访问

sysctl net.ipv6.conf.all.disable_ipv6=1  # 关闭IP6
yum install yum-utils createrepo
yum install httpd
systemctl enable httpd
mkdir -p /var/www/html/
cd /var/www/html/
ln -s /mnt/centos centos7-local-repo
systemctl start httpd


9. 在其他机器上
http://hdp0/centos7-local-repo/
cd /etc/yum.repos.d/
rename .repo .repo.bak ./*
cp CentOS-Base.repo.bak my.repo
修改my.repo内容为

[hdp0]   # 自己定义
name=CentOS-$releasever - HDP0-local   # 自己定义一个名字
# 下面的url 是配置好提供本地仓库的服务器，如我的就是如下
baseurl=http://hdp0/centos7-local-repo/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

yum repolist
```

#### 安装相关的包

1. 将安装包提供的 `libtirpc-0.2.4-0.15.el7.x86_64.rpm` 和 `libtirpc-devel-0.2.4-0.15.el7.x86_64.rpm`上传到服务器进行安装

   可以使用 `rz`命令快速上传，如果 `rz`提示无这个命令使用：`yum install lrzsz`来安装即可
2. `yum install nmap`

#### 在集群和浏览器主机上启动NTP服务(所有服务器均设置)

群集中所有节点的时钟以及运行浏览器的计算机必须能够彼此同步才能访问Ambari Web界面。

要安装NTP服务并确保它在启动时启动，请在每台主机上运行以下命令：

1. 安装ntp并配置

   ***RHEL/CentOS/Oracle 7***

   ```shell
   // 有网络 或者 配置好了远程本地仓库
   yum install -y ntp
   systemctl enable ntpd
   // 没有网络执行
   1. rpm -ivh ntpdate-4.2.6p5-28.el7.centos.x86_64.rpm
   2. rpm -ivh autogen-libopts-5.18-5.el7.x86_64.rpm
   3. rpm -ivh ntp-4.2.6p5-28.el7.centos.x86_64.rpm
   
   // ---
   vim /etc/ntpd.conf
   在server机器: 
   restrict 192.168.179.0 mask 255.255.255.0 nomodify notrap
   restrict 127.0.0.1
   
   server  127.127.1.0     # local clock
   fudge   127.127.1.0 stratum 8
   
   in client: 
   server 192.168.171.100(your local server)
   ```
2. 检查 提供ntp server机器的时间

   ```shell
   如果时区不对，使用tzselect 命令选择中国时区
   tzselect   输入 5 9 1 1
   使用date -s "设置时间"
   如： date -s "2019-09-02 11:41:00"
   ```
3. 启动ntp并设置时间

   > 如果其他服务器时区不对， 同样tzselect来设置时区
   >

   - 先在server机器上 执行 `systemctl start ntpd` 启动ntp服务
   - 在server机器上执行 ntpq -p 查看是否正常
   - 在client机器上执行 `ntpdate -u serverip` 来手动对时
   - 在client机器上执行 `systemctl start ntpd` 启动client上的ntp服务

#### 检查DNS和NSCD(所有服务器均设置)

1. 编辑 `/etc/hosts` 文件填写带有FQDN的配置，示例:

   ```shell
   192.168.179.100 hdp0.itcast.cn hdp0
   192.168.179.101 hdp1.itcast.cn hdp1
   192.168.179.102 hdp2.itcast.cn hdp2
   # hdp0.itcast.cn 就是 fully.qualified.domain.name  FQDN
   ```

   ***不要移除hosts中自带的这些***

   ```shell
   127.0.0.1 localhost.localdomain localhost
   ::1 localhost6.localdomain6 localhost6
   ```
2. 确认hostname(所有服务器均验证)

检查是否可以反向DNS解析hostname:

`hostname -f`

正常情况下应该返回FQDN的主机名

> 必须为系统中的所有主机配置正向和反向DNS.
>
> 如果您无法以这种方式配置DNS，则应编辑群集中每个主机上的/ etc / hosts文件，以包含每个主机的IP地址和完全限定域名。
> 以下说明作为概述提供，涵盖了通用Linux主机的基本网络设置。 Linux的不同版本和风格可能需要稍微不同的命令和过程, 请参阅环境中部署的操作系统的文档.
>
> Hadoop严重依赖DNS，因此在正常操作期间执行许多DNS查找。为减少DNS基础结构的负载，强烈建议在运行Linux的群集节点上使用名称服务缓存守护程序（NSCD）, 该守护进程将缓存主机，用户和组查找，并提供更好的解决方案性能，并减少DNS基础结构的负载。

#### 下载并设置数据库连接器(Ambari Server服务器设置即可)

##### 安装一个数据库提供元数据存储

安装Mysql：

```sql
一、首先清除CentOS7系统中默认的数据库mariadb，否则不能安装mysql
	rpm -qa |grep mariadb |xargs yum remove -y

二、安装MySql
	1、下载MySql的相关rpm包
	上传安装包中提供的mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar

	2、将下载的mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar放到/usr/local/mysql目录，解压缩安装包
	tar -xvf mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar

	3、切换到下载包目录下（cd 你的下载目录），然后对每个包进行一次安装；
	rpm -ivh mysql-community-common-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-libs-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-libs-compat-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-embedded-compat-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-devel-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-client-8.0.15-1.el7.x86_64.rpm
	rpm -ivh mysql-community-server-8.0.15-1.el7.x86_64.rpm

	或者一行搞定
	>>> rpm -ivh mysql-community-common-5.7.27-1.el7.x86_64.rpm mysql-community-libs-5.7.27-1.el7.x86_64.rpm mysql-community-libs-compat-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-compat-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-devel-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-5.7.27-1.el7.x86_64.rpm mysql-community-devel-5.7.27-1.el7.x86_64.rpm mysql-community-client-5.7.27-1.el7.x86_64.rpm mysql-community-server-5.7.27-1.el7.x86_64.rpm

	如果缺少libaio 可以安装提供的两个libaio包

	4、修改MySql配置
	vi /etc/my.cnf

	修改配置如下

	#datadir=/var/lib/mysql
	datadir=/data/mysql
	socket=/var/lib/mysql/mysql.sock
	log-error=/var/log/mysqld.log
	pid-file=/var/run/mysqld/mysqld.pid

	修改/etc/my.cnf配置文件，在[mysqld]下添加编码配置，如下所示：
	[mysqld]
	character_set_server=utf8
	init_connect='SET NAMES utf8'

	5、通过以下命令，完成对 mysql 数据库的初始化和相关配置
	mysqld --initialize
	// chown mysql:mysql /data/mysql -R
	cd /var/lib/mysql
	chown -R mysql:mysql *
	systemctl  enable mysqld // 设置开机启动


三、启动MySql服务
	1、启动MySql
	systemctl start mysqld.service

	#停止MySql

	systemctl stop mysqld.service

	#重启MySql

	systemctl restart mysqld.service

	2、设置MySql开机自启
	systemctl enable mysqld
	1
	3、通过 cat /var/log/mysqld.log | grep password 命令查看数据库的密码
	2019-02-16T09:46:38.945518Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: ,#t#dlkOG0j0
	1
	以上密码为,#t#dlkOG0j0

	4、测试MySql安装是否成功
	4.1、以root用户登录MySql，执行命令
	mysql -u root -p

	输入以上命令回车进入，出现输入密码提示

	4.2、输入刚刚查到的密码，进行数据库的登陆，复制粘贴就行，MySQL 的登陆密码也是不显示的

	4.3、通过 ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; 命令来修改密码

	4.4、通过 exit; 命令退出 MySQL，然后通过新密码再次登陆
	至此，mysql数据库就安装完成了。

	四、MySql远程访问授权配置
	1、以root用户登录MySql
	mysql -u root -p

	grant all privileges on *.* to root@"%" identified by '密码' with grant option;  
	flush privileges;

	附：
	创建新用户： CREATE USER ‘用户名’@‘host名称’ IDENTIFIED WITH mysql_native_password BY ‘密码’;

	给新用户授权：GRANT ALL PRIVILEGES ON . TO ‘用户名’@‘host名称’;

	刷新权限： FLUSH PRIVILEGES;
```

##### Configuring MySQL for Ranger And Ambari

**Prerequisites**

使用MySQL时，用于Ranger管理策略存储表的存储引擎必须支持事务。
InnoDB是支持事务的引擎示例。
不支持事务的存储引擎不适合作为策略存储。

> 推荐使用InnoDB引擎

**Steps**

> If you are using Amazon RDS, see the [Amazon RDS Requirements](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/bk_ambari-installation/content/amazon_rds_requirements_mysql.html).

1. 应使用MySQL数据库管理员创建Ranger数据库

   以下一系列命令可用于创建密码为 `rangerdba`的 `rangerdba`用户。

   1. 以root用户身份登录，然后使用以下命令创建 `rangerdba`用户并授予其足够的权限。

      ```sql
      CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'rangerdba';
      
      GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
      
      CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'rangerdba';
      
      GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
      
      GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
      
      GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
      
      FLUSH PRIVILEGES;
      ```
   2. Use the `exit` command to exit MySQL.
   3. `mysql -u rangerdba -prangerdba`

      使用以上命令重新尝试登陆，如果可以登陆说明配置正常
2. 使用以下命令确认 `mysql-connector-java.jar`文件位于Java共享目录中。
   **必须在安装Ambari服务器的服务器上运行此命令**

   ```shell
   ls /usr/share/java/mysql-connector-java.jar
   ```

   如果该文件不在Java共享目录中，请使用以下命令安装MySQL连接器.jar文件。

   **RHEL/CentOS/Oracle/Aamazon Linux**

   ```shell
   yum install mysql-connector-java*
   ```
3. 使用安装包提供的 `06-Ambari-DDL-MySQL-CREATE.sql` 在mysql中执行这个sql文件用来创建ambari相关的内容
4. 再执行 `GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%' WITH GRANT OPTION;`
5. `FLUSH PRIVILEGES;`

##### 安装JDK配置JAVA_HOME(所有服务器均设置)

略

##### Install Databases for HDF services

**[Option]**

如果需要配置HDF服务，参见：https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/bk_ambari-installation/content/install_databases_for_hdf_services.html

### 部署HDP相关软件包的yum仓库

#### 安装httpd服务，解压安装包

```
yum install yum-utils createrepo
yum install httpd
systemctl enable httpd
mkdir -p /var/www/html/
这几步如果在前面做了 就不用做了

cd /var/www/html/

解压准备的 ambari hdp hdp-gpl hdp-utils 包到这个目录下

yum install yum-plugin-priorities

vim /etc/yum/pluginconf.d/priorities.conf
修改
[main]
enabled=1
gpgcheck=0

systemctl start/stop/restart httpd    # 使用start 来启动httpd服务
```

#### 配置yum仓库的配置文件

**Steps**

1. 上传本地准备好的 `ambari.repo` 到 `/etc/yum.repo.d/`下
2. 编辑此文件确保以下修改

```
[Updates-Ambari-2.7.0.0]
```

```
name=Ambari-2.7.0.0-Updates
```

```
baseurl=INSERT-BASE-URL
```

```
gpgcheck=1
```

```
gpgkey=INSERT-BASE-URL/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
```

```
enabled=1
```

```
priority=1
```

```shell
# 其中， INSERT-BASE-URL参考：ip为 192.168.179.100的情况下
http://192.168.179.100/ambari/centos7/2.7.0.0-897   // 此为INSERT-BASE-URL

http://192.168.179.100/HDP/centos7/3.0.0.0-1634

http://192.168.179.100/HDP-GPL/centos7/3.0.0.0-1634

http://192.168.179.100/HDP-UTILS/centos7/1.1.0.22
```

3. 执行 `yum repolist` 查看是否成功配置

> 执行到这里我们得到了两个本地仓库
>
> 1. centos7自带系统光盘提供的库，提供常用软件安装
> 2. HDP相关的库，提供HDP相关软件安装

### 安装AmbariServer

#### **安装**

**Steps**

1. 安装ambari-server

   ```
   yum install ambari-server
   ```
2. 输入y表示继续安装，正常输出应该如下：

   ```shell
   Installing : postgresql-libs-9.2.18-1.el7.x86_64         1/4
   Installing : postgresql-9.2.18-1.el7.x86_64              2/4
   Installing : postgresql-server-9.2.18-1.el7.x86_64       3/4
   Installing : ambari-server-2.7.0.0-896.x86_64           4/4
   Verifying  : ambari-server-2.7.0.0-896.x86_64           1/4
   Verifying  : postgresql-9.2.18-1.el7.x86_64              2/4
   Verifying  : postgresql-server-9.2.18-1.el7.x86_64       3/4
   Verifying  : postgresql-libs-9.2.18-1.el7.x86_64         4/4
   
   Installed:
     ambari-server.x86_64 0:2.7.0.0-896
   Dependency Installed:
    postgresql.x86_64 0:9.2.18-1.el7
    postgresql-libs.x86_64 0:9.2.18-1.el7
    postgresql-server.x86_64 0:9.2.18-1.el7
   Complete!
   ```

#### setup Ambari Server

执行: ambari-server setup

按照提示内容选择

1. 是否让ambari来控制各个服务组件的账户，默认即可
2. 选择JDk
3. 配置数据库，选择Mysql提供host port username password等信息
4. 等

然后执行:

```
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
```

**More Information**

[Setup Options](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/bk_ambari-installation/content/setup_options.html)

[Configuring Ambari for Non-Root](https://docs.hortonworks.com/HDPDocuments/HDP3/HDP-3.0.0/securing-credentials/content/ambari_sec_configuring_ambari_for_non_root.html)

[Changing your JDK](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_change_your_jdk.html)

[Configuring LZO compression](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_configuring_lzo_compression.html)

[Using an existing database with Ambari](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_using_existing_database_ambari.html)

[Setting up Ambari to use an Internet proxy server](https://docs.hortonworks.com/HDPDocuments/Ambari-2.7.0.0/administering-ambari/content/amb_setting_up_ambari_to_use_an_internet_proxy_server.html)

### 在Ambari Server UI中进行基础安装配置

#### 进入Ambari Server UI

`先启动 ambari-server start`

输入 `http://ip-or-host:8080`

![image.png](https://image.hyly.net/i/2025/09/26/2c54bf5546fba740ebce9521a88ce8a7-0.webp)

默认账户密码： `admin / admin`

#### 启动安装

输入账号密码登陆

![image.png](https://image.hyly.net/i/2025/09/26/8da805565bd7e2fe70ef9df3e5219b13-0.webp)

**点击 LAUNCH INSTALL WIZARD**

启动安装流程

#### 安装过程

给定集群一个名称，这里使用 `itcast_test`

![image.png](https://image.hyly.net/i/2025/09/26/7ec40e71a03f2b2491e9963a6e388ec4-0.webp)

选择版本，由于没有网络，默认只能使用HDP 3.0

![image.png](https://image.hyly.net/i/2025/09/26/344a58f802552bbd18a264208745dba8-0.webp)

选择本地仓库, 输入配置本地仓库时定义的url

![image.png](https://image.hyly.net/i/2025/09/26/1de31c417f4b4d7a2dc0570f25963be9-0.webp)

安装选项

1. 输入目标主机列表，回车分隔(这个图片少了一个 hdp0.itcast.cn的主机, 因为老师是虚拟机资源有限，所以尽量将Ambari Server这个机器也复用上了，资源丰富的同学，可以不加这个机器也可以的. Ambari Server 和 集群可以相互独立，只要在在一个网络内互通即可)

![image.png](https://image.hyly.net/i/2025/09/26/2755a645a2397d2b8f15f12a367b39eb-0.webp)

上传Ambari Server 所在机器root账户的 私钥，方便Ambari Server 以root身份ssh到其他节点

![image.png](https://image.hyly.net/i/2025/09/26/154992fbacbad30fb3b2287f545c9737-0.webp)

确认主机，正常如下，如果有警告请检查，然后运行重新检查来通过所有的主机检查

![image.png](https://image.hyly.net/i/2025/09/26/598c5f95c0bbd83ab0d230f6dd7e891b-0.webp)

选择服务组件，这里先安装一个最基本的zookeeper + Ambari Metrics

![image.png](https://image.hyly.net/i/2025/09/26/f9d0c3918785fe978b725549caca4e9f-0.webp)

分配服务组件到各个主机上（自行分配即可）

![image.png](https://image.hyly.net/i/2025/09/26/e684c8264df32cfc7eb916801bcf539b-0.webp)

分配客户端，将两个客户端机器勾选

![image.png](https://image.hyly.net/i/2025/09/26/e2ec2d7fddf29b79c3b70ce8c5c81f81-0.webp)

自定义服务

![image.png](https://image.hyly.net/i/2025/09/26/9351cecac4a82511408b165471fb37c0-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/456e4c872a528a0969c4fe475cc66123-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/f1673230f294bfaf467272041a60a4ec-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/a5bede5b4212e1c72369cbf1ea4c1b17-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/b3bd3631290446238e013c0091cc26a8-0.webp)

点击Deploy进行部署

![image.png](https://image.hyly.net/i/2025/09/26/efb6b090f9f436707ea1f0eccf5a6c01-0.webp)

等待部署完成。。。

部署完成后，点击下一步

![image.png](https://image.hyly.net/i/2025/09/26/08ee202fbf8992904ebeadf2357b78e0-0.webp)

总结

![image.png](https://image.hyly.net/i/2025/09/26/a6adac8d3a6eb4bf481f618d91bc0dc1-0.webp)

点击Complete，进入集群控制页面

![image.png](https://image.hyly.net/i/2025/09/26/8ede75d533d1633d4892c124a8b548cd-0.webp)

这两个警告可以忽略

1. 是说磁盘空间不足，演示机器虚拟机磁盘没有配置太大
2. 说SmartSense 服务无法连接网络，离线安装正常，如果可以联网让Ambari Server主机接入网络即可

### 测试以及安装其他服务

#### 安装、测试HDFS

![image.png](https://image.hyly.net/i/2025/09/26/7ba5f1236aa834a946b349e7697fb6fa-0.webp)

**如图，点击添加service**

![image.png](https://image.hyly.net/i/2025/09/26/f20b1af4c809fde95c594761bcdbf268-0.webp)

**选择HDFS**

![image.png](https://image.hyly.net/i/2025/09/26/e54b0291d3b9ff5d8c7c2da0dc8c4dd7-0.webp)

**分配Master节点**

![image.png](https://image.hyly.net/i/2025/09/26/4a82e80afbac08837619f11a38582b1d-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/dbca1d61abd6244c51d832dd90368b7f-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/2eedf0fa59a09822e550385f619d99a3-0.webp)

**点击Deploy进行部署，等待其完成**

![image.png](https://image.hyly.net/i/2025/09/26/18b0750c9a260f303cd9b95cf2a72a2d-0.webp)

**安装完毕后可以在主页这里看到HDFS相关服务**

![image.png](https://image.hyly.net/i/2025/09/26/01c8edeef5a71b43cea5505893c0cf6f-0.webp)

**执行测试**

![image.png](https://image.hyly.net/i/2025/09/26/8096839f60bcad767ec09efdefa14ca7-0.webp)

#### 部署、测试HBase

同HDFS一样

1. 在Service那里点击三个小引号
2. 点击Add service
3. 选择HBase
4. 配置主机和相关配置
5. Deploy开始部署

![image.png](https://image.hyly.net/i/2025/09/26/e2dc170623c925fccad3d90d390436d8-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/fad8c4301aa7c1928ae2ad6bd8331228-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/daff35b3baa51fd6173ae5d23d337c71-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/a7e5bb7d2560b36356c603ff8be7f360-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/02f97b891529fbd5747638a0c6879b47-0.webp)

**安装完成后进行测试:**

![image.png](https://image.hyly.net/i/2025/09/26/d53110ab4e1cf82d19500145cc72aaea-0.webp)

#### 部署、测试Yarn、MapReduce

同上

- 点击Add Service
- 添加 YARN + MapReduce2
- 配置节点和相关配置
- 点击Deploy
- 完成后即可使用

![image.png](https://image.hyly.net/i/2025/09/26/4279ea5a88961e31e73d8b616fdee697-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/f17a71fc10e3c7c0bd42e717ed683a3f-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/86699202dec89fdefea701bfb60c5e43-0.webp)

安装完成后即能看到这两个服务。

**运行测试**

```shell
[hdfs@hdp1 ~]$ hadoop jar /usr/hdp/3.0.0.0-1634/hadoop-mapreduce/hadoop-mapreduce-examples-3.1.0.3.0.0.0-1634.jar wordcount /test.txt /wd-output
19/09/02 17:29:42 INFO client.RMProxy: Connecting to ResourceManager at hdp2.itcast.cn/192.168.179.102:8050
19/09/02 17:29:42 INFO client.AHSProxy: Connecting to Application History server at hdp1.itcast.cn/192.168.179.101:10200
19/09/02 17:29:43 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /user/hdfs/.staging/job_1567416408889_0001
19/09/02 17:29:44 INFO input.FileInputFormat: Total input files to process : 1
19/09/02 17:29:44 INFO mapreduce.JobSubmitter: number of splits:1
19/09/02 17:29:45 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1567416408889_0001
19/09/02 17:29:45 INFO mapreduce.JobSubmitter: Executing with tokens: []
19/09/02 17:29:45 INFO conf.Configuration: found resource resource-types.xml at file:/etc/hadoop/3.0.0.0-1634/0/resource-types.xml
19/09/02 17:29:45 INFO impl.YarnClientImpl: Submitted application application_1567416408889_0001
19/09/02 17:29:45 INFO mapreduce.Job: The url to track the job: http://hdp2.itcast.cn:8088/proxy/application_1567416408889_0001/
19/09/02 17:29:45 INFO mapreduce.Job: Running job: job_1567416408889_0001
19/09/02 17:30:03 INFO mapreduce.Job: Job job_1567416408889_0001 running in uber mode : false
19/09/02 17:30:03 INFO mapreduce.Job:  map 0% reduce 0%
19/09/02 17:30:15 INFO mapreduce.Job:  map 100% reduce 0%
19/09/02 17:30:21 INFO mapreduce.Job:  map 100% reduce 100%
19/09/02 17:30:21 INFO mapreduce.Job: Job job_1567416408889_0001 completed successfully
19/09/02 17:30:21 INFO mapreduce.Job: Counters: 53
        File System Counters
                FILE: Number of bytes read=28
                FILE: Number of bytes written=457715
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=111
                HDFS: Number of bytes written=14
                HDFS: Number of read operations=8
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=2
        Job Counters 
                Launched map tasks=1
                Launched reduce tasks=1
                Data-local map tasks=1
                Total time spent by all maps in occupied slots (ms)=6720
                Total time spent by all reduces in occupied slots (ms)=7544
                Total time spent by all map tasks (ms)=6720
                Total time spent by all reduce tasks (ms)=3772
                Total vcore-milliseconds taken by all map tasks=6720
                Total vcore-milliseconds taken by all reduce tasks=3772
                Total megabyte-milliseconds taken by all map tasks=1720320
                Total megabyte-milliseconds taken by all reduce tasks=1931264
        Map-Reduce Framework
                Map input records=2
                Map output records=2
                Map output bytes=18
                Map output materialized bytes=28
                Input split bytes=100
                Combine input records=2
                Combine output records=2
                Reduce input groups=2
                Reduce shuffle bytes=28
                Reduce input records=2
                Reduce output records=2
                Spilled Records=4
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=153
                CPU time spent (ms)=1300
                Physical memory (bytes) snapshot=364044288
                Virtual memory (bytes) snapshot=4220051456
                Total committed heap usage (bytes)=225247232
                Peak Map Physical memory (bytes)=222789632
                Peak Map Virtual memory (bytes)=2021199872
                Peak Reduce Physical memory (bytes)=141254656
                Peak Reduce Virtual memory (bytes)=2198851584
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters 
                Bytes Read=11
        File Output Format Counters 
                Bytes Written=14
[hdfs@hdp1 ~]$ hadoop fs -cat /wd-output/*
HDP     1
Hello   1
```

#### 部署、测试Kafka

- 点击Add Service
- 选择Kafka
- 配置主机以及配置文件（没有特殊需求可以默认）
- 点击Deploy进行部署
- 等待完成

![image.png](https://image.hyly.net/i/2025/09/26/77d56594b9117c77930e05fb78d65638-0.webp)

```shell
./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test1
Created topic "test1".
```

```shell
[root@hdp0 bin]# ./kafka-console-producer.sh --broker-list hdp0.itcast.cn:6667 --topic test         
>aaa
>ddd
>ddd
>Hello Kafka From HDP
```

```shell
[root@hdp0 bin]# ./kafka-console-consumer.sh --bootstrap-server hdp0.itcast.cn:6667 --topic test --from-beginning            
aaa
ddd
ddd
Hello Kafka From HDP
```

#### 部署、测试 Spark2

`部署Spark2要求按照Tez、Hive，在安装的时候同时装上即可`

同上面步骤

- 点击Add Service
- 选择Spark2
- 在弹出是否安装Tez以及Hive的框框内选择ok即可
- 配置主机以及配置文件
- 等待安装完成

![image.png](https://image.hyly.net/i/2025/09/26/efb541808c44edac5f46b1c469d1406e-0.webp)

**测试Spark**

```shell
[spark@hdp1 spark2]$ ./bin/run-example SparkPi
19/09/02 22:56:37 INFO SparkContext: Running Spark version 2.3.1.3.0.0.0-1634
19/09/02 22:56:37 INFO SparkContext: Submitted application: Spark Pi
19/09/02 22:56:37 INFO SecurityManager: Changing view acls to: spark
19/09/02 22:56:37 INFO SecurityManager: Changing modify acls to: spark
19/09/02 22:56:37 INFO SecurityManager: Changing view acls groups to: 
19/09/02 22:56:37 INFO SecurityManager: Changing modify acls groups to: 
19/09/02 22:56:37 INFO SecurityManager: SecurityManager: authentication disabled; ui acls disabled; users  with view permissions: Set(spark); groups with view permissions: Set(); users  with modify permissions: Set(spark); groups with modify permissions: Set()
19/09/02 22:56:37 INFO Utils: Successfully started service 'sparkDriver' on port 37188.
19/09/02 22:56:37 INFO SparkEnv: Registering MapOutputTracker
19/09/02 22:56:37 INFO SparkEnv: Registering BlockManagerMaster
19/09/02 22:56:37 INFO BlockManagerMasterEndpoint: Using org.apache.spark.storage.DefaultTopologyMapper for getting topology information
19/09/02 22:56:37 INFO BlockManagerMasterEndpoint: BlockManagerMasterEndpoint up
19/09/02 22:56:37 INFO DiskBlockManager: Created local directory at /tmp/blockmgr-7a9c2f0e-23f1-4117-825c-fcd1b0ddc2fb
19/09/02 22:56:37 INFO MemoryStore: MemoryStore started with capacity 366.3 MB
19/09/02 22:56:37 INFO SparkEnv: Registering OutputCommitCoordinator
19/09/02 22:56:37 INFO log: Logging initialized @1581ms
19/09/02 22:56:37 INFO Server: jetty-9.3.z-SNAPSHOT
19/09/02 22:56:37 INFO Server: Started @1726ms
19/09/02 22:56:37 INFO AbstractConnector: Started ServerConnector@6e4deef2{HTTP/1.1,[http/1.1]}{0.0.0.0:4040}
19/09/02 22:56:37 INFO Utils: Successfully started service 'SparkUI' on port 4040.
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@d02f8d{/jobs,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@710d7aff{/jobs/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@2d7e1102{/jobs/job,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@301d8120{/jobs/job/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@6d367020{/stages,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@72458efc{/stages/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@36bc415e{/stages/stage,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@6a714237{/stages/stage/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@3e134896{/stages/pool,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@72ba28ee{/stages/pool/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@2e3a5237{/storage,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@4ebadd3d{/storage/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@6ac97b84{/storage/rdd,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@4917d36b{/storage/rdd/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@35c09b94{/environment,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@2d0bfb24{/environment/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@c3fa05a{/executors,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@7b44b63d{/executors/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@4a699efa{/executors/threadDump,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@38499e48{/executors/threadDump/json,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@4905c46b{/static,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@511d5d04{/,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@682c1e93{/api,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@5b78fdb1{/jobs/job/kill,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@48bfb884{/stages/stage/kill,null,AVAILABLE,@Spark}
19/09/02 22:56:37 INFO SparkUI: Bound SparkUI to 0.0.0.0, and started at http://hdp1.itcast.cn:4040
19/09/02 22:56:38 INFO RMProxy: Connecting to ResourceManager at hdp0.itcast.cn/192.168.179.100:8050
19/09/02 22:56:38 INFO Client: Requesting a new application from cluster with 1 NodeManagers
19/09/02 22:56:38 INFO Configuration: found resource resource-types.xml at file:/etc/hadoop/3.0.0.0-1634/0/resource-types.xml
19/09/02 22:56:38 INFO Client: Verifying our application has not requested more than the maximum memory capability of the cluster (3072 MB per container)
19/09/02 22:56:38 INFO Client: Will allocate AM container, with 896 MB memory including 384 MB overhead
19/09/02 22:56:38 INFO Client: Setting up container launch context for our AM
19/09/02 22:56:38 INFO Client: Setting up the launch environment for our AM container
19/09/02 22:56:38 INFO Client: Preparing resources for our AM container
19/09/02 22:56:39 INFO Client: Use hdfs cache file as spark.yarn.archive for HDP, hdfsCacheFile:hdfs://hdp0.itcast.cn:8020/hdp/apps/3.0.0.0-1634/spark2/spark2-hdp-yarn-archive.tar.gz
19/09/02 22:56:39 INFO Client: Source and destination file systems are the same. Not copying hdfs://hdp0.itcast.cn:8020/hdp/apps/3.0.0.0-1634/spark2/spark2-hdp-yarn-archive.tar.gz
19/09/02 22:56:39 INFO Client: Distribute hdfs cache file as spark.sql.hive.metastore.jars for HDP, hdfsCacheFile:hdfs://hdp0.itcast.cn:8020/hdp/apps/3.0.0.0-1634/spark2/spark2-hdp-hive-archive.tar.gz
19/09/02 22:56:39 INFO Client: Source and destination file systems are the same. Not copying hdfs://hdp0.itcast.cn:8020/hdp/apps/3.0.0.0-1634/spark2/spark2-hdp-hive-archive.tar.gz
19/09/02 22:56:39 INFO Client: Uploading resource file:/usr/hdp/3.0.0.0-1634/spark2/examples/jars/scopt_2.11-3.7.0.jar -> hdfs://hdp0.itcast.cn:8020/user/spark/.sparkStaging/application_1567435113751_0003/scopt_2.11-3.7.0.jar
19/09/02 22:56:40 INFO Client: Uploading resource file:/usr/hdp/3.0.0.0-1634/spark2/examples/jars/spark-examples_2.11-2.3.1.3.0.0.0-1634.jar -> hdfs://hdp0.itcast.cn:8020/user/spark/.sparkStaging/application_1567435113751_0003/spark-examples_2.11-2.3.1.3.0.0.0-1634.jar
19/09/02 22:56:40 INFO Client: Uploading resource file:/tmp/spark-71285c61-5876-49e5-aff0-e2f5221c5fac/__spark_conf__6021223147298639101.zip -> hdfs://hdp0.itcast.cn:8020/user/spark/.sparkStaging/application_1567435113751_0003/__spark_conf__.zip
19/09/02 22:56:41 INFO SecurityManager: Changing view acls to: spark
19/09/02 22:56:41 INFO SecurityManager: Changing modify acls to: spark
19/09/02 22:56:41 INFO SecurityManager: Changing view acls groups to: 
19/09/02 22:56:41 INFO SecurityManager: Changing modify acls groups to: 
19/09/02 22:56:41 INFO SecurityManager: SecurityManager: authentication disabled; ui acls disabled; users  with view permissions: Set(spark); groups with view permissions: Set(); users  with modify permissions: Set(spark); groups with modify permissions: Set()
19/09/02 22:56:41 INFO Client: Submitting application application_1567435113751_0003 to ResourceManager
19/09/02 22:56:41 INFO YarnClientImpl: Submitted application application_1567435113751_0003
19/09/02 22:56:41 INFO SchedulerExtensionServices: Starting Yarn extension services with app application_1567435113751_0003 and attemptId None
19/09/02 22:56:42 INFO Client: Application report for application_1567435113751_0003 (state: ACCEPTED)
19/09/02 22:56:42 INFO Client: 
         client token: N/A
         diagnostics: [Mon Sep 02 22:56:41 +0800 2019] Application is added to the scheduler and is not yet activated. Queue's AM resource limit exceeded.  Details : AM Partition = <DEFAULT_PARTITION>; AM Resource Request = <memory:1024, vCores:1>; Queue Resource Limit for AM = <memory:1024, vCores:1>; User AM Resource Limit of the queue = <memory:1024, vCores:1>; Queue AM Resource Usage = <memory:2048, vCores:1>; 
         ApplicationMaster host: N/A
         ApplicationMaster RPC port: -1
         queue: default
         start time: 1567436201045
         final status: UNDEFINED
         tracking URL: http://hdp0.itcast.cn:8088/proxy/application_1567435113751_0003/
         user: spark
19/09/02 22:56:43 INFO Client: Application report for application_1567435113751_0003 (state: ACCEPTED)
19/09/02 22:58:24 INFO YarnClientSchedulerBackend: Add WebUI Filter. org.apache.hadoop.yarn.server.webproxy.amfilter.AmIpFilter, Map(PROXY_HOSTS -> hdp0.itcast.cn, PROXY_URI_BASES -> http://hdp0.itcast.cn:8088/proxy/application_1567435113751_0003), /proxy/application_1567435113751_0003
19/09/02 22:58:24 INFO JettyUtils: Adding filter org.apache.hadoop.yarn.server.webproxy.amfilter.AmIpFilter to /jobs, /jobs/json, /jobs/job, /jobs/job/json, /stages, /stages/json, /stages/stage, /stages/stage/json, /stages/pool, /stages/pool/json, /storage, /storage/json, /storage/rdd, /storage/rdd/json, /environment, /environment/json, /executors, /executors/json, /executors/threadDump, /executors/threadDump/json, /static, /, /api, /jobs/job/kill, /stages/stage/kill.
19/09/02 22:58:24 INFO YarnSchedulerBackend$YarnSchedulerEndpoint: ApplicationMaster registered as NettyRpcEndpointRef(spark-client://YarnAM)
19/09/02 22:58:24 INFO Client: Application report for application_1567435113751_0003 (state: RUNNING)
19/09/02 22:58:24 INFO Client: 
         client token: N/A
         diagnostics: N/A
         ApplicationMaster host: 192.168.179.101
         ApplicationMaster RPC port: 0
         queue: default
         start time: 1567436201045
         final status: UNDEFINED
         tracking URL: http://hdp0.itcast.cn:8088/proxy/application_1567435113751_0003/
         user: spark
19/09/02 22:58:24 INFO YarnClientSchedulerBackend: Application application_1567435113751_0003 has started running.
19/09/02 22:58:24 INFO Utils: Successfully started service 'org.apache.spark.network.netty.NettyBlockTransferService' on port 46513.
19/09/02 22:58:24 INFO NettyBlockTransferService: Server created on hdp1.itcast.cn:46513
19/09/02 22:58:24 INFO BlockManager: Using org.apache.spark.storage.RandomBlockReplicationPolicy for block replication policy
19/09/02 22:58:24 INFO BlockManagerMaster: Registering BlockManager BlockManagerId(driver, hdp1.itcast.cn, 46513, None)
19/09/02 22:58:24 INFO BlockManagerMasterEndpoint: Registering block manager hdp1.itcast.cn:46513 with 366.3 MB RAM, BlockManagerId(driver, hdp1.itcast.cn, 46513, None)
19/09/02 22:58:24 INFO BlockManagerMaster: Registered BlockManager BlockManagerId(driver, hdp1.itcast.cn, 46513, None)
19/09/02 22:58:24 INFO BlockManager: Initialized BlockManager: BlockManagerId(driver, hdp1.itcast.cn, 46513, None)
19/09/02 22:58:24 INFO JettyUtils: Adding filter org.apache.hadoop.yarn.server.webproxy.amfilter.AmIpFilter to /metrics/json.
19/09/02 22:58:24 INFO ContextHandler: Started o.s.j.s.ServletContextHandler@1cd2ff5b{/metrics/json,null,AVAILABLE,@Spark}
19/09/02 22:58:25 INFO EventLoggingListener: Logging events to hdfs:/spark2-history/application_1567435113751_0003
19/09/02 22:58:25 INFO YarnClientSchedulerBackend: SchedulerBackend is ready for scheduling beginning after waiting maxRegisteredResourcesWaitingTime: 30000(ms)
19/09/02 22:58:25 INFO SparkContext: Starting job: reduce at SparkPi.scala:38
19/09/02 22:58:25 INFO DAGScheduler: Got job 0 (reduce at SparkPi.scala:38) with 2 output partitions
19/09/02 22:58:25 INFO DAGScheduler: Final stage: ResultStage 0 (reduce at SparkPi.scala:38)
19/09/02 22:58:25 INFO DAGScheduler: Parents of final stage: List()
19/09/02 22:58:25 INFO DAGScheduler: Missing parents: List()
19/09/02 22:58:25 INFO DAGScheduler: Submitting ResultStage 0 (MapPartitionsRDD[1] at map at SparkPi.scala:34), which has no missing parents
19/09/02 22:58:26 INFO MemoryStore: Block broadcast_0 stored as values in memory (estimated size 1832.0 B, free 366.3 MB)
19/09/02 22:58:26 INFO MemoryStore: Block broadcast_0_piece0 stored as bytes in memory (estimated size 1181.0 B, free 366.3 MB)
19/09/02 22:58:26 INFO BlockManagerInfo: Added broadcast_0_piece0 in memory on hdp1.itcast.cn:46513 (size: 1181.0 B, free: 366.3 MB)
19/09/02 22:58:26 INFO SparkContext: Created broadcast 0 from broadcast at DAGScheduler.scala:1039
19/09/02 22:58:26 INFO DAGScheduler: Submitting 2 missing tasks from ResultStage 0 (MapPartitionsRDD[1] at map at SparkPi.scala:34) (first 15 tasks are for partitions Vector(0, 1))
19/09/02 22:58:26 INFO YarnScheduler: Adding task set 0.0 with 2 tasks
19/09/02 22:58:27 INFO YarnSchedulerBackend$YarnDriverEndpoint: Registered executor NettyRpcEndpointRef(spark-client://Executor) (192.168.179.101:49994) with ID 1
19/09/02 22:58:28 INFO TaskSetManager: Starting task 0.0 in stage 0.0 (TID 0, hdp1.itcast.cn, executor 1, partition 0, PROCESS_LOCAL, 7864 bytes)
19/09/02 22:58:28 INFO BlockManagerMasterEndpoint: Registering block manager hdp1.itcast.cn:37982 with 366.3 MB RAM, BlockManagerId(1, hdp1.itcast.cn, 37982, None)
19/09/02 22:58:28 INFO BlockManagerInfo: Added broadcast_0_piece0 in memory on hdp1.itcast.cn:37982 (size: 1181.0 B, free: 366.3 MB)
19/09/02 22:58:28 INFO TaskSetManager: Starting task 1.0 in stage 0.0 (TID 1, hdp1.itcast.cn, executor 1, partition 1, PROCESS_LOCAL, 7864 bytes)
19/09/02 22:58:28 INFO TaskSetManager: Finished task 0.0 in stage 0.0 (TID 0) in 887 ms on hdp1.itcast.cn (executor 1) (1/2)
19/09/02 22:58:28 INFO TaskSetManager: Finished task 1.0 in stage 0.0 (TID 1) in 63 ms on hdp1.itcast.cn (executor 1) (2/2)
19/09/02 22:58:28 INFO YarnScheduler: Removed TaskSet 0.0, whose tasks have all completed, from pool 
19/09/02 22:58:28 INFO DAGScheduler: ResultStage 0 (reduce at SparkPi.scala:38) finished in 3.021 s
19/09/02 22:58:28 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 3.118064 s
Pi is roughly 3.139395696978485
19/09/02 22:58:28 INFO AbstractConnector: Stopped Spark@6e4deef2{HTTP/1.1,[http/1.1]}{0.0.0.0:4040}
19/09/02 22:58:28 INFO SparkUI: Stopped Spark web UI at http://hdp1.itcast.cn:4040
19/09/02 22:58:29 INFO YarnClientSchedulerBackend: Interrupting monitor thread
19/09/02 22:58:29 INFO YarnClientSchedulerBackend: Shutting down all executors
19/09/02 22:58:29 INFO YarnSchedulerBackend$YarnDriverEndpoint: Asking each executor to shut down
19/09/02 22:58:29 INFO SchedulerExtensionServices: Stopping SchedulerExtensionServices
(serviceOption=None,
 services=List(),
 started=false)
19/09/02 22:58:29 INFO YarnClientSchedulerBackend: Stopped
19/09/02 22:58:29 INFO MapOutputTrackerMasterEndpoint: MapOutputTrackerMasterEndpoint stopped!
19/09/02 22:58:29 INFO MemoryStore: MemoryStore cleared
19/09/02 22:58:29 INFO BlockManager: BlockManager stopped
19/09/02 22:58:29 INFO BlockManagerMaster: BlockManagerMaster stopped
19/09/02 22:58:29 INFO OutputCommitCoordinator$OutputCommitCoordinatorEndpoint: OutputCommitCoordinator stopped!
19/09/02 22:58:29 INFO SparkContext: Successfully stopped SparkContext
19/09/02 22:58:29 INFO ShutdownHookManager: Shutdown hook called
19/09/02 22:58:29 INFO ShutdownHookManager: Deleting directory /tmp/spark-71285c61-5876-49e5-aff0-e2f5221c5fac
19/09/02 22:58:29 INFO ShutdownHookManager: Deleting directory /tmp/spark-c664407b-f0e3-435e-b49b-7d4b9d2c0ef2
```

**最后来一张Ambari Server UI的全景图**

![image.png](https://image.hyly.net/i/2025/09/26/71a4825ee7546edc73b40a2f0de6494b-0.webp)

## 快速安装步骤

1. 版本老师使用Ambari 2.7.0 HDP 3.0.0 如果同学们需要更改版本，请去https://supportmatrix.hortonworks.com 上面查询合适的版本搭配
2. 操作系统使用的是CentOS7.4 64位， JDK8
3. 准备好机器，用以安装集群管理者（Ambari Server）以及集群工作者（Ambari Agent）以及搭建hadoop、spark、kafka等组件
4. 【所有机器】上执行 `ulimit -n 10000` 设置最大可打开文件描述符为10000
5. 【所有机器】上配置主机名，`hostnamectl set-hostname "主机名"`
6. 【所有机器】配置/etc/hosts文件，确保hosts中配置了FQDN形式的主机名
7. 【所有机器】使用 `hostname -f`检查是否可以正确反向解析出FQDN形式的主机名
8. 【所有机器】上禁用selinux: 编辑 `/etc/selinux/config` 文件，将SELINUX值改为 `disabled`重启
9. 【所有机器】关闭防火墙执行: 1. `systemctl disable firewalld` 2. `service firewalld stop`
10. 【所有机器】配置SSH 免密互相登陆

    1. 【所有机器】上执行 `ssh-keygen -t rsa`，一路回车使用默认即可
    2. 【所有机器】执行 `ssh-copy-id 目标主机`来确保当前主机到目标主机的SSH免密登陆
11. 【某个机器】挂载Centos7系统安装盘为本地yum仓库

    1. 将iso光盘挂载到目录下

       ```shell
       # 非虚拟机环境
       mkdir /data #创建目录（存放iso镜像文件）
       #将iso镜像文件上传到/data下
       mkdir /mnt/centos #创建要挂载到的目录
       mount /xxx/xxx/xxx.iso /mnt/centos


       # 虚拟机环境
       必须让虚拟机加载了安装盘
       mkdir /mnt/centos
       mount -t iso9660 -o loop /dev/cdrom /mnt/centos  // 虚拟机环境下，可以用光驱加载ISO文件，不需要上传
       ```
    2. 配置基于本地文件的yum源
    
       ```shell
       cd /etc/yum.repos.d/
    
       rename .repo .repo.bak ./*   # 禁用原有的全部网络源
    
       yum repolist (检查，查不到东西说明，yum源已禁用)
    
       cp CentOS-Media.repo.bak local.repo
    
       vi local.repo
       # 确保以下内容更改
       `
       [centos7-local]
       name=CentOS-$releasever - Local
       baseurl=file:///mnt/centos/
       gpgcheck=1
       enabled=1
       gpgkey=file:///mnt/centos/RPM-GPG-KEY-CentOS-7
       `
    
       yum repolist
       #配置成功会显示
       ------------------------------------------------------------
       repo id            repo name                       status
       Local              CentOS-6 - Local                6,575
       repolist: 6,575
       ------------------------------------------------------------
       ```
    3. 将这个机器配置的本地仓库托管为http服务，让其他server可以访问
    
       ```shell
       sysctl net.ipv6.conf.all.disable_ipv6=1  # 关闭IP6
    
       yum install yum-utils createrepo
    
       yum install httpd
    
       systemctl enable httpd
    
       mkdir -p /var/www/html/
    
       cd /var/www/html/
    
       ln -s /mnt/centos centos7-local-repo
    
       systemctl start httpd
       ```
    4. 在其他机器上，配置第三步托管的http服务为yum（局域网）仓库
    
       ```shell
       cd /etc/yum.repos.d/
    
       rename .repo .repo.bak ./*
    
       cp CentOS-Base.repo.bak my.repo
    
       修改my.repo内容为
       ```
       [hdp0]   # 自己定义
       name=CentOS-$releasever - HDP0-local   # 自己定义一个名字
    
       # 下面的url 是配置好提供本地仓库的服务器，如我的就是如下
    
       baseurl=http://hdp0/centos7-local-repo/
       gpgcheck=1
       gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7


       ```
    
       yum repolist  # 测试
       ```
12. 【所有机器】安装相关的包

    1. rpm -ivh 来安装提供的 `libtirpc-0.2.4-0.15.el7.x86_64.rpm` 和 `libtirpc-devel-0.2.4-0.15.el7.x86_64.rpm`. 上传到服务器手动安装。如果没有 `rz`命令，可以执行 `yum install lrzsz`来安装
    2. `yum install nmap`
13. 配置NTP时间同步服务

    1. 【所有机器】 安装NTP服务

       ```shell
       yum install -y ntp
       systemctl enable ntpd
       ```
    2. 【NTP server机器上】配置NTP

       ```shell
       vim /etc/ntp.conf
       
       1. 注释掉原本conf中带有的server
       2. 添加如下内容
       restrict 192.168.179.0 mask 255.255.255.0 nomodify notrap
       restrict 127.0.0.1
       
       server  127.127.1.0     # local clock
       fudge   127.127.1.0 stratum 8
       ```
    3. 【NTP 客户端机器上】配置NTP

       ```shell
       vim /etc/ntp.conf
       添加
       server ntp-server的ip
       ```
    4. 【NTP server机器上】手动修改时间, 启动ntp

       `tzselect` 选择时区

       `date -s "2019-01-01 10:00:00"` 这样来手动更正时间

       `systemctl start ntpd` 启动ntp服务
    5. 【NTP 客户端机器上】手动和server同步时间，并启动ntp

       如果时区不对，`tzselect`来修改

       执行 `ntpdate -u ntp-server的ip` 来尝试手动同步一次时间

       手动同步没有问题，启动ntp服务 `systemctl start ntpd`
14. 【Ambari Server服务器上】安装Mysql，为Ambari server、Hive、Ranger等服务提供元数据数据库

    1. 安装

       ```shell
       一、首先清除CentOS7系统中默认的数据库mariadb，否则不能安装mysql
       	rpm -qa |grep mariadb |xargs yum remove -y
       
       二、安装MySql
       	1、下载MySql的相关rpm包
       	上传安装包中提供的mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar
       
       	2、将下载的mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar放到/usr/local/mysql目录，解压缩安装包
       	tar -xvf mysql-5.7.27-1.el7.x86_64.rpm-bundle.tar
       
       	3、切换到下载包目录下（cd 你的下载目录），然后安装；
       	rpm -ivh mysql-community-common-5.7.27-1.el7.x86_64.rpm mysql-community-libs-5.7.27-1.el7.x86_64.rpm mysql-community-libs-compat-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-compat-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-devel-5.7.27-1.el7.x86_64.rpm mysql-community-embedded-5.7.27-1.el7.x86_64.rpm mysql-community-devel-5.7.27-1.el7.x86_64.rpm mysql-community-client-5.7.27-1.el7.x86_64.rpm mysql-community-server-5.7.27-1.el7.x86_64.rpm
       
       	如果缺少libaio 可以安装提供的两个libaio包(老师提供的安装包有提供)
       
       	4、修改MySql配置
       	vi /etc/my.cnf
       
       	新增两行配置如下
       	character_set_server=utf8
       	init_connect='SET NAMES utf8'
       
       	5、通过以下命令，完成对 mysql 数据库的初始化和相关配置
       	mysqld --initialize
       	6、给mysql数据目录修改为mysql账户所属
       	cd /var/lib/mysql
       	chown -R mysql:mysql *
       	7、设置mysql开机启动
       	systemctl  enable mysqld // 设置开机启动


       三、启动MySql服务
       	1、启动MySql
       	systemctl start mysqld.service
       	   其他命令参考：
               #停止MySql
               systemctl stop mysqld.service
               #重启MySql
               systemctl restart mysqld.service
    
       	2、设置MySql开机自启
       	systemctl enable mysqld
    
       	3、启动mysql后，通过 cat /var/log/mysqld.log | grep password 命令查看数据库的密码
       	2019-02-16T09:46:38.945518Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: ,#t#dlkOG0j0
    
       	如，以上密码为,#t#dlkOG0j0
    
       	4、测试MySql安装是否成功
       	4.1、以root用户登录MySql，执行命令
       	mysql -u root -p
    
       	输入以上命令回车进入，出现输入密码提示
    
       	4.2、输入刚刚查到的密码，进行数据库的登陆，复制粘贴就行，MySQL 的登陆密码也是不显示的
    
       	4.3、通过 ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; 命令来修改密码
    
       	4.4、通过 exit; 命令退出 MySQL，然后通过新密码再次登陆
       	至此，mysql数据库就安装完成了。
    
       	四、MySql远程访问授权配置
       	1、以root用户登录MySql
       	mysql -u root -p
    
       	grant all privileges on *.* to root@"%" identified by '需要登录的密码' with grant option;  
       	flush privileges;
       ```
    2. 为Ranger服务初始化数据库
    
       ```shell
       1. 依次执行下面的sql（root账户登录后执行）
       CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'rangerdba';
    
       GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
    
       CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'rangerdba';
    
       GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
    
       GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
    
       GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
    
       FLUSH PRIVILEGES;
    
       2. 退出mysql 执行 mysql -u rangerdba -prangerdba 验证是否可以登录
       ```
    3. 查看mysql java 驱动包
    
       ```shell
       执行 ls /usr/share/java/mysql-connector-java.jar
       如果提示找不到文件，就执行：
       yum install mysql-connector-java*
       ```
    4. 上传老师提供的 `06-Ambari-DDL-MySQL-CREATE.sql`到服务器root账户下/root/目录下
    
       以root账户进入mysql，执行
    
       `source /root/06-Ambari-DDL-MySQL-CREATE.sql`
    
       在执行： `GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%' WITH GRANT OPTION;`
    
       和 `FLUSH PRIVILEGES;`
15. 【全部机器】配置JDK和JAVA_HOME环境变量：略
16. 【AmbariServer服务器上】部署HDP相关软件包为yum本地库

    ```shell
    1. 
    cd /var/www/html/
    
    2. 上传老师准备的安装包里面的HDP3.0 文件夹内的所有内容到这个目录下
    
    3. 解压所有的tar压缩包, 然后执行 systemctl restart httpd   重新启动httpd服务托管新内容
    
    4. 执行 yum install yum-plugin-priorities
    
    5. cd /etc/yum.repos.d/
    
    6. 上传老师准备的ambari.repo到当前目录(/etc/yum.repos.d)
    
    7. 修改 ambari.repo
       baseurl=INSERT-BASE-URL
       gpgkey=INSERT-BASE-URL/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
       其中 `INSERT-BASE-URL` 就是你httpd托管ambari的路径
    8. 执行 yum repolist 查看是否多了一个ambari的库
    参考老师的配置:
    # 其中， INSERT-BASE-URL参考：ip为 192.168.179.100的情况下
    http://192.168.179.100/ambari/centos7/2.7.0.0-897   // 此为INSERT-BASE-URL
    ```
    > 执行到这里我们得到了两个本地仓库
    >
    > 1. centos7自带系统光盘提供的库，提供常用软件安装
    > 2. HDP相关的库，提供HDP相关软件安装
    >
17. 【AmbariServer服务器上】安装ambari server  `yum install ambari-server`
18. 【AmbariServer服务器上】执行: `ambari-server setup`

    按照提示内容选择

    1. 是否让ambari来控制各个服务组件的账户，默认即可
    2. 选择JDk
    3. 配置数据库，选择Mysql提供host port username password等信息
    4. 等

    然后执行: `ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar`
19. 执行 `ambari-server start`启动ambari server
20. 在浏览器中输入： `http://ambari-server-ip:8080`即可打开AmbariServerUI
21. 在浏览器上进行后续操作，可以参考课件的截图