---
category: [Java技术栈]
tag: [apollo,,配置中心,面试]
postType: post
status: publish
---

## 概览

### 什么是配置

应用程序在启动和运行的时候往往需要读取一些配置信息，配置基本上伴随着应用程序的整个生命周期，比如：数 据库连接参数、启动参数等。

配置主要有以下几个特点：

1. 配置是独立于程序的只读变量
   1. 配置首先是独立于程序的，同一份程序在不同的配置下会有不同的行为
   2. 其次，配置对于程序是只读的，程序通过读取配置来改变自己的行为，但是程序不应该去改变配置
2. 配置伴随应用的整个生命周期
   1. 配置贯穿于应用的整个生命周期，应用在启动时通过读取配置来初始化，在运行时根据配置调整行为。 比如：启动时需要读取服务的端口号、系统在运行过程中需要读取定时策略执行定时任务等。
3. 配置可以有多种加载方式
   1. 常见的有程序内部硬编码，配置文件，环境变量，启动参数，基于数据库等
4. 配置需要治理
   1. 权限控制：由于配置能改变程序的行为，不正确的配置甚至能引起灾难，所以对配置的修改必须有比较 完善的权限控制
   2. 不同环境、集群配置管理：同一份程序在不同的环境（开发，测试，生产）、不同的集群（如不同的数 据中心）经常需要有不同的配置，所以需要有完善的环境、集群配置管理

### 什么是配置中心

传统单体应用存在一些潜在缺陷，如随着规模的扩大，部署效率降低，团队协作效率差，系统可靠性变差，维护困 难，新功能上线周期长等，所以迫切需要一种新的架构去解决这些问题，而微服务（ microservices ）架构正是当 下一种流行的解法。

不过，解决一个问题的同时，往往会诞生出很多新的问题，所以微服务化的过程中伴随着很多的挑战，其中一个挑 战就是有关服务（应用）配置的。当系统从一个单体应用，被拆分成分布式系统上一个个服务节点后，配置文件也 必须跟着迁移（分割），这样配置就分散了，不仅如此，分散中还包含着冗余，如下图：

![image.png](https://image.hyly.net/i/2025/09/25/09d84fdf2f773eeac06be333646e5a60-0.webp)

配置中心将配置从应用中剥离出来，统一管理，优雅的解决了配置的动态变更、持久化、运维成本等问题。 应用自身既不需要去添加管理配置接口，也不需要自己去实现配置的持久化，更不需要引入“定时任务”以便降低运 维成本。

**总得来说，配置中心就是一种统一管理各种应用配置的基础服务组件。**

在系统架构中，配置中心是整个微服务基础架构体系中的一个组件，如下图，它的功能看上去并不起眼，无非就是 配置的管理和存取，但它是整个微服务架构中不可或缺的一环。

![image.png](https://image.hyly.net/i/2025/09/25/bbda114e4b99948c591abe2d3a25777a-0.webp)

集中管理配置，那么就要将应用的配置作为一个单独的服务抽离出来了，同理也需要解决新的问题，比如：版本管 理（为了支持回滚），权限管理等。

总结一下，在传统巨型单体应用纷纷转向细粒度微服务架构的历史进程中，配置中心是微服务化不可缺少的一个系 统组件，在这种背景下中心化的配置服务即配置中心应运而生，一个合格的配置中心需要满足：

1. 配置项容易读取和修改
2. 添加新配置简单直接
3. 支持对配置的修改的检视以把控风险
4. 可以查看配置修改的历史记录
5. 不同部署环境支持隔离

## Apollo简介

### 主流配置中心

目前市面上用的比较多的配置中心有：（按开源时间排序）

1. Disconf

2014年7月百度开源的配置管理中心，专注于各种「分布式系统配置管理」的「通用组件」和「通用平台」, 提供统一的「配置管理服务」。目前已经不再维护更新。 https://github.com/knightliao/disconf

2. Spring Cloud Config

2014年9月开源，Spring Cloud 生态组件，可以和Spring Cloud体系无缝整合。 https://github.com/spring-cloud/spring-cloud-config

3. Apollo

2016年5月，携程开源的配置管理中心，能够集中化管理应用不同环境、不同集群的配置，配置修改后能够实 时推送到应用端，并且具备规范的权限、流程治理等特性，适用于微服务配置管理场景。 https://github.com/ctripcorp/apollo

4. Nacos

2018年6月，阿里开源的配置中心，也可以做DNS和RPC的服务发现。 https://github.com/alibaba/nacos

#### 功能特性对比

由于Disconf不再维护，下面主要对比一下Spring Cloud Config、Apollo和Nacos。

<figure class='table-figure'><table>
<thead>
<tr><th>功能点</th><th>Spring Cloud Config</th><th>Apollo</th><th>Nacos</th></tr></thead>
<tbody><tr><td>配置实时推送</td><td>支持(Spring Cloud Bus)</td><td>支持(HTTP长轮询1s内)</td><td>支持(HTTP长轮询1s内)</td></tr><tr><td>版本管理</td><td>支持(Git)</td><td>支持</td><td>支持</td></tr><tr><td>配置回滚</td><td>支持(Git)</td><td>支持</td><td>支持</td></tr><tr><td>灰度发布</td><td>支持</td><td>支持</td><td>不支持</td></tr><tr><td>权限管理</td><td>支持(依赖Git)</td><td>支持</td><td>不支持</td></tr><tr><td>多集群</td><td>支持</td><td>支持</td><td>支持</td></tr><tr><td>多环境</td><td>支持</td><td>支持</td><td>支持</td></tr><tr><td>监听查询</td><td>支持</td><td>支持</td><td>支持</td></tr><tr><td>多语言</td><td>只支持Java</td><td>主流语言，提供了Open API</td><td>主流语言，提供了Open API</td></tr><tr><td>配置格式校验</td><td>不支持</td><td>支持</td><td>支持</td></tr><tr><td>单机读(QPS)</td><td>7(限流所致)</td><td>9000</td><td>15000</td></tr><tr><td>单击写(QPS)</td><td>5(限流所致)</td><td>1100</td><td>1800</td></tr><tr><td>3节点读 (QPS)</td><td>21(限流所致)</td><td>27000</td><td>45000</td></tr><tr><td>3节点写 (QPS)</td><td>5限流所致()</td><td>3300</td><td>5600</td></tr></tbody>
</table></figure>

#### 总结

总的来看，Apollo和Nacos相对于Spring Cloud Config的生态支持更广，在配置管理流程上做的更好。Apollo相对 于Nacos在配置管理做的更加全面，Nacos则使用起来相对比较简洁，在对性能要求比较高的大规模场景更适合。 但对于一个开源项目的选型，项目上的人力投入（迭代进度、文档的完整性）、社区的活跃度（issue的数量和解 决速度、Contributor数量、社群的交流频次等），这些因素也比较关键，考虑到Nacos开源时间不长和社区活跃 度，所以从目前来看Apollo应该是最合适的配置中心选型。

### Apollo简介

![image.png](https://image.hyly.net/i/2025/09/25/b2163f0b84e7cc1c6dcdd256043a552a-0.webp)

**Apollo - A reliable configuration management system**

https://github.com/ctripcorp/apollo

Apollo（阿波罗）是携程框架部门研发的分布式配置中心，能够集中化管理应用的不同环境、不同集群的配置，配 置修改后能够实时推送到应用端，并且具备规范的权限、流程治理等特性，适用于微服务配置管理场景。

Apollo包括服务端和客户端两部分：

服务端基于Spring Boot和Spring Cloud开发，打包后可以直接运行，不需要额外安装Tomcat等应用容器。 Java客户端不依赖任何框架，能够运行于所有Java运行时环境，同时对Spring/Spring Boot环境也有较好的支持。

### Apollo特性

基于配置的特殊性，所以Apollo从设计之初就立志于成为一个有治理能力的配置发布平台，目前提供了以下的特 性：

1. 统一管理不同环境、不同集群的配置
   1. Apollo提供了一个统一界面集中式管理不同环境（environment）、不同集群（cluster）、不同命名空 间（namespace）的配置。
   2. 同一份代码部署在不同的集群，可以有不同的配置，比如zookeeper的地址等
   3. 通过命名空间（namespace）可以很方便地支持多个不同应用共享同一份配置，同时还允许应用对共享 的配置进行覆盖
2. 配置修改实时生效（热发布）
   1. 用户在Apollo修改完配置并发布后，客户端能实时（1秒）接收到最新的配置，并通知到应用程序
3. 版本发布管理
   1. 所有的配置发布都有版本概念，从而可以方便地支持配置的回滚
4. 灰度发布
   1. 支持配置的灰度发布，比如点了发布后，只对部分应用实例生效，等观察一段时间没问题后再推给所有 应用实例
5. 权限管理、发布审核、操作审计
   1. 应用和配置的管理都有完善的权限管理机制，对配置的管理还分为了编辑和发布两个环节，从而减少人 为的错误。
   2. 所有的操作都有审计日志，可以方便地追踪问题
6. 客户端配置信息监控
   1. 可以在界面上方便地看到配置在被哪些实例使用
7. 提供Java和.Net原生客户端
   1. 提供了Java和.Net的原生客户端，方便应用集成
   2. 支持Spring Placeholder, Annotation和Spring Boot的ConfigurationProperties，方便应用使用（需要 Spring 3.1.1+）
   3. 同时提供了Http接口，非Java和.Net应用也可以方便地使用
8. 提供开放平台API
   1. Apollo自身提供了比较完善的统一配置管理界面，支持多环境、多数据中心配置管理、权限、流程治理 等特性。不过Apollo出于通用性考虑，不会对配置的修改做过多限制，只要符合基本的格式就能保存， 不会针对不同的配置值进行针对性的校验，如数据库用户名、密码，Redis服务地址等
   2. 对于这类应用配置，Apollo支持应用方通过开放平台API在Apollo进行配置的修改和发布，并且具备完善 的授权和权限控制

## Apollo快速入门

### 执行流程

![image.png](https://image.hyly.net/i/2025/09/25/6916ae8f12b1b183044b016c899b84f2-0.webp)

操作流程如下：

1. 在Apollo配置中心修改配置
2. 应用程序通过Apollo客户端从配置中心拉取配置信息

用户通过Apollo配置中心修改或发布配置后，会有两种机制来保证应用程序来获取最新配置：一种是Apollo配置中 心会向客户端推送最新的配置；另外一种是Apollo客户端会定时从Apollo配置中心拉取最新的配置，通过以上两种 机制共同来保证应用程序能及时获取到配置

### 安装Apollo

#### 运行时环境

**Java**

1. Apollo服务端：1.8+
2. Apollo客户端：1.7+

由于需要同时运行服务端和客户端，所以建议安装Java 1.8+。

**MySQL**

1. 版本要求：5.6.5+

Apollo的表结构对 timestamp 使用了多个default声明，所以需要5.6.5以上版本。

#### 下载配置

1. 访问Apollo的官方主页获取安装包（本次使用1.3版本）：
2. https://github.com/ctripcorp/apollo/tags

![image.png](https://image.hyly.net/i/2025/09/25/4132ae1090bdb1b47ef956057195cbd2-0.webp)

2. 打开1.3发布链接，下载必须的安装包：https://github.com/ctripcorp/apollo/releases/tag/v1.3.0

![image.png](https://image.hyly.net/i/2025/09/25/651d0992d35d27c4b56dde1312dc50c2-0.webp)

3. 解压安装包后将apollo-configservice-1.3.0.jar, apollo-adminservice-1.3.0.jar, apollo-portal-1.3.0.jar放置于 apollo目录下

#### 创建数据库

**Apollo服务端共需要两个数据库： ApolloPortalDB 和 ApolloConfigDB ，ApolloPortalDB只需要在生产环境部署 一个即可，而ApolloConfigDB需要在每个环境部署一套。**

1. 创建ApolloPortalDB，sql脚本下载地址： https://github.com/ctripcorp/apollo/blob/v1.3.0/scripts/db/migration/configdb/V1.0.0__initialization.sql 以MySQL原生客户端为例：

```
source apollo/ApolloPortalDB__initialization.sql
```

2. 验证ApolloPortalDB 导入成功后，可以通过执行以下sql语句来验证：

```
select `Id`, `Key`, `Value`, `Comment` from `ApolloPortalDB`.`ServerConfig` limit 1;
```

**注：ApolloPortalDB只需要在生产环境部署一个即可**

3. 创建ApolloConfigDB，sql脚本下载地址： https://github.com/ctripcorp/apollo/blob/v1.3.0/scripts/db/migration/configdb/V1.0.0__initialization.sql 以MySQL原生客户端为例：

```
source apollo/ApolloConfigDB__initialization.sql
```

4. 验证ApolloConfigDB 导入成功后，可以通过执行以下sql语句来验证：

```
select `Id`, `Key`, `Value`, `Comment` from `ApolloConfigDB`.`ServerConfig` limit 1;
```

#### 启动Apollo

1. 确保端口未被占用 **Apollo默认会启动3个服务，分别使用8070, 8080, 8090端口，请确保这3个端口当前没有被使用**
2. 启动apollo-configservice，在apollo目录下执行如下命令 可通过-Dserver.port=8080修改默认端口

```
java ‐Xms256m ‐Xmx256m ‐Dspring.datasource.url=jdbc:mysql://localhost:3306/ApolloConfigDB? characterEncoding=utf8 ‐Dspring.datasource.username=root ‐ Dspring.datasource.password=itcast0430 ‐jar apollo‐configservice‐1.3.0.jar
```

![image.png](https://image.hyly.net/i/2025/09/25/1a01102f9012b8441d655ebb4257ec05-0.webp)

3. 启动apollo-adminservice 可通过-Dserver.port=8090修改默认端口

```
java ‐Xms256m ‐Xmx256m ‐Dspring.datasource.url=jdbc:mysql://localhost:3306/ApolloConfigDB? characterEncoding=utf8 ‐Dspring.datasource.username=root ‐ Dspring.datasource.password=itcast0430 ‐jar apollo‐adminservice‐1.3.0.jar
```

![image.png](https://image.hyly.net/i/2025/09/25/8c66bec2aa13567948527bd710a9996e-0.webp)

4. 启动apollo-portal 可通过-Dserver.port=8070修改默认端口

```
java ‐Xms256m ‐Xmx256m ‐Ddev_meta=http://localhost:8080/ ‐Dserver.port=8070 ‐ Dspring.datasource.url=jdbc:mysql://localhost:3306/ApolloPortalDB?characterEncoding=utf8 ‐ Dspring.datasource.username=root ‐Dspring.datasource.password=itcast0430 ‐jar apollo‐ portal‐1.3.0.jar
```

![image.png](https://image.hyly.net/i/2025/09/25/c24edb68dea1ae367521646682dd5801-0.webp)

5. 也可以使用提供的runApollo.bat快速启动三个服务（修改数据库连接地址，数据库以及密码）

```
echo 

set url="localhost:3306" 
set username="root" 
set password="123" 

start "configService" java ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloConfigDB?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐configservice.log ‐jar .\apollo‐configservice‐1.3.0.jar start "adminService" java ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloConfigDB?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐adminservice.log ‐jar .\apollo‐adminservice‐1.3.0.jar start "ApolloPortal" java ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github,auth ‐ Ddev_meta=http://localhost:8080/ ‐Dserver.port=8070 ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloPortalDB?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐portal.log ‐jar .\apollo‐portal‐1.3.0.jar
```

6. 运行runApollo.bat即可启动Apollo
7. 待启动成功后，访问管理页面 apollo/admin

![image.png](https://image.hyly.net/i/2025/09/25/493ad5c507f28a56f15498ec02a344c6-0.webp)

### 代码实现

#### 发布配置

1. 打开apollo ：新建项目apollo-quickstart

![image.png](https://image.hyly.net/i/2025/09/25/02268e65b8f6b99d007623ef7e8c3d40-0.webp)

2. 新建配置项sms.enable

![image.png](https://image.hyly.net/i/2025/09/25/0c493ee0d91a4d94171a34bcc5015dec-0.webp)

确认提交配置项

![image.png](https://image.hyly.net/i/2025/09/25/b3146d23d999cdfad20f437b33b1dddd-0.webp)

3. 发布配置项

![image.png](https://image.hyly.net/i/2025/09/25/86dde10f9b0aee43b7e84f620d7e4c17-0.webp)

#### 应用读取配置

1、新建Maven工程 打开idea，

新建apollo-quickstart项目

![image.png](https://image.hyly.net/i/2025/09/25/975f5d04e6781510ccda2ce2b8a57237-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/e5864768f67c679adf999865cfdb6c30-0.webp)

打开pom.xml文件添加apollo依赖，配置JDK为1.8

```
<?xml version="1.0" encoding="UTF‐8"?> <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema‐instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
http://maven.apache.org/xsd/maven‐4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <groupId>cn.itcast</groupId> <artifactId>apollo‐quickstart</artifactId> <version>1.0‐SNAPSHOT</version> <properties> <java.version>1.8</java.version> </properties> <dependencies> <dependency> <groupId>com.ctrip.framework.apollo</groupId> <artifactId>apollo‐client</artifactId> <version>1.1.0</version> </dependency> <dependency> <groupId>org.slf4j</groupId> <artifactId>slf4j‐simple</artifactId> <version>1.7.28</version> </dependency> </dependencies> <build> <plugins> <plugin> <groupId>org.apache.maven.plugins</groupId> <artifactId>maven‐compiler‐plugin</artifactId> <configuration> <source>8</source> <target>8</target> </configuration> </plugin> </plugins> </build> </project>
```

2、编写测试类GetConfigTest

新建cn.itcast.apollo.quickstart包，

添加测试类GetConfigTest 添加如下代码读取sms.enable的值

```
package cn.itcast.apollo.quickstart; public class GetConfigTest { // VM options: // ‐Dapp.id=apollo‐quickstart ‐Denv=DEV ‐Ddev_meta=http://localhost:8080 public static void main(String[] args) { Config config = ConfigService.getAppConfig(); String someKey = "sms.enable"; String value = config.getProperty(someKey, null); System.out.println("sms.enable: " + value); } }
```

3、测试 配置VM options，设置系统属性：

```
‐Dapp.id=apollo‐quickstart ‐Denv=DEV ‐Ddev_meta=http://localhost:8080
```

![image.png](https://image.hyly.net/i/2025/09/25/02669dae1882605f37b50f4bfbefce68-0.webp)

运行GetConfigTest，打开控制台，观察输出结果

![image.png](https://image.hyly.net/i/2025/09/25/b922c60ee3e4afc9af883d697d9a8ba6-0.webp)

#### 修改配置

1. 修改sms.enable的值为false

![image.png](https://image.hyly.net/i/2025/09/25/e43e9250ac03762d02b27c5ef4a60ebe-0.webp)

2. 再次运行GetConfigTest，可以看到输出结果已为false

![image.png](https://image.hyly.net/i/2025/09/25/a40382aef5211aaba14e787ff7df297c-0.webp)

#### 热发布

1. 修改代码为每3秒获取一次

```
public class GetConfigTest { public static void main(String[] args) throws InterruptedException { Config config = ConfigService.getAppConfig(); String someKey = "sms.enable"; while (true) { String value = config.getProperty(someKey, null); System.out.printf("now: %s, sms.enable: %s%n", LocalDateTime.now().toString(), value); Thread.sleep(3000L); } } }
```

2. 运行GetConfigTest观察输出结果

![image.png](https://image.hyly.net/i/2025/09/25/c642b6ecf807f2662cb923e3dd19285e-0.webp)

3. 在Apollo管理界面修改配置项

![image.png](https://image.hyly.net/i/2025/09/25/791f389fc18d9725d9700ae25d79a626-0.webp)

4. 发布配置

![image.png](https://image.hyly.net/i/2025/09/25/be7bcc9496d96d3e8dccfeff048ff1d1-0.webp)

5. 在控制台查看详细情况：可以看到程序获取的sms.enable的值已由false变成了修改后的true

![image.png](https://image.hyly.net/i/2025/09/25/c7cb4ee193ecec403ca326ab527e4a61-0.webp)

## Apollo应用

### Apollo工作原理

下图是Apollo架构模块的概览

![image.png](https://image.hyly.net/i/2025/09/25/a1425ec86694fb6e304413a7cea692f4-0.webp)

#### 各模块职责

上图简要描述了Apollo的总体设计，我们可以从下往上看：

1. Config Service提供配置的读取、推送等功能，服务对象是Apollo客户端
2. Admin Service提供配置的修改、发布等功能，服务对象是Apollo Portal（管理界面）
3. Eureka提供服务注册和发现，为了简单起见，目前Eureka在部署时和Config Service是在一个JVM进程中的
4. Config Service和Admin Service都是多实例、无状态部署，所以需要将自己注册到Eureka中并保持心跳
5. 在Eureka之上架了一层Meta Server用于封装Eureka的服务发现接口
6. Client通过域名访问Meta Server获取Config Service服务列表（IP+Port），而后直接通过IP+Port访问服务， 同时在Client侧会做load balance、错误重试
7. Portal通过域名访问Meta Server获取Admin Service服务列表（IP+Port），而后直接通过IP+Port访问服务， 同时在Portal侧会做load balance、错误重试
8. 为了简化部署，我们实际上会把Config Service、Eureka和Meta Server三个逻辑角色部署在同一个JVM进程 中

#### 分步执行流程

1. Apollo启动后，Config/Admin Service会自动注册到Eureka服务注册中心，并定期发送保活心跳。
2. Apollo Client和Portal管理端通过配置的Meta Server的域名地址经由Software Load Balancer(软件负载均衡 器)进行负载均衡后分配到某一个Meta Server
3. Meta Server从Eureka获取Config Service和Admin Service的服务信息，相当于是一个Eureka Client
4. Meta Server获取Config Service和Admin Service（IP+Port）失败后会进行重试
5. 获取到正确的Config Service和Admin Service的服务信息后，Apollo Client通过Config Service为应用提供配 置获取、实时更新等功能；Apollo Portal管理端通过Admin Service提供配置新增、修改、发布等功能

### 核心概念

1. application (应用)

这个很好理解，就是实际使用配置的应用，Apollo客户端在运行时需要知道当前应用是谁，从而可以去获取

对应的配置

关键字：appId

2. environment (环境)

配置对应的环境，Apollo客户端在运行时需要知道当前应用处于哪个环境，从而可以去获取应用的配置

关键字：env

3. cluster (集群)

一个应用下不同实例的分组，比如典型的可以按照数据中心分，把上海机房的应用实例分为一个集群，把北

京机房的应用实例分为另一个集群。

关键字：cluster

4. namespace (命名空间)

一个应用下不同配置的分组，可以简单地把namespace类比为文件，不同类型的配置存放在不同的文件中，

如数据库配置文件，RPC配置文件，应用自身的配置文件等

关键字：namespaces

它们的关系如下图所示：

![image.png](https://image.hyly.net/i/2025/09/25/c57c7259f1f7522d76d4df9b9501d2a2-0.webp)

### 项目管理

#### 基础设置

1. 部门管理

apollo 默认部门有两个。要增加自己的部门，可在系统参数中修改：

进入系统参数设置

![image.png](https://image.hyly.net/i/2025/09/25/86f6161abf552e33b8b04b864899a355-0.webp)

输入key查询已存在的部门设置：organizations

![image.png](https://image.hyly.net/i/2025/09/25/4b07875060508b7f5d5a86bdce4f6633-0.webp)

修改value值来添加新部门，下面添加一个微服务部门：

```
[{"orgId":"TEST1","orgName":"样例部门1"},{"orgId":"TEST2","orgName":"样例部门2"}, {"orgId":"micro_service","orgName":"微服务部门"}]
```

2. 添加用户

apollo默认提供一个超级管理员: apollo，可以自行添加用户 新建用户张三

![image.png](https://image.hyly.net/i/2025/09/25/38f2cd5e1552b9cb0afa0202aa8232df-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/15e1b058d47875873e5e20fd3cbd90bb-0.webp)

#### 创建项目

1. 打开apollo-portal主页：http://localhost:8070/
2. 点击“创建项目”：account-service

![image.png](https://image.hyly.net/i/2025/09/25/03cdb8b0137ed441185204f3c12db59f-0.webp)

3. 输入项目信息

部门：选择应用所在的部门

应用AppId：用来标识应用身份的唯一id，格式为string，需要和项目配置文件applications.properties

中配置的app.id对应

应用名称：应用名，仅用于界面展示

应用负责人：选择的人默认会成为该项目的管理员，具备项目权限管理、集群创建、Namespace创建等

权限

![image.png](https://image.hyly.net/i/2025/09/25/d67cd70ba414e175c4f28878b4404ef9-0.webp)

4. 点击提交

创建成功后，会自动跳转到项目首页

![image.png](https://image.hyly.net/i/2025/09/25/fa12fd448cd5f92f10957dd360451e2e-0.webp)

5. 赋予之前添加的用户张三管理account-service服务的权限

使用管理员apollo将指定项目授权给用户张三

![image.png](https://image.hyly.net/i/2025/09/25/930def64e87ffe5c5ec2f1e99089a9fc-0.webp)

将修改和发布权限都授权给张三

![image.png](https://image.hyly.net/i/2025/09/25/46d6107a53785b0b01bc2878335a3305-0.webp)

使用zhangsan登录，查看项目配置

![image.png](https://image.hyly.net/i/2025/09/25/6c751a72e1edb047d2fbcdcbc12692fd-0.webp)

点击account-service即可管理配置

#### 删除项目

如果要删除整个项目，点击右上角的“管理员工具--》删除应用、集群...”

首先查询出要删除的项目，点击“删除应用”

![image.png](https://image.hyly.net/i/2025/09/25/3ae2ea0e57b0dbaaa5bea4010d3d2ba6-0.webp)

### 配置管理

下边在account-service项目中进行配置。

#### 添加发布配置项

1. 通过表格模式添加配置

点击新增配置

![image.png](https://image.hyly.net/i/2025/09/25/b8d9feebf4e534d7bfd4ef9287ff15f1-0.webp)

输入配置项：sms.enable，点击提交

![image.png](https://image.hyly.net/i/2025/09/25/f4777bb6a99a62b071e667e0440773f0-0.webp)

2. 通过文本模式编辑

Apollo除了支持表格模式，逐个添加、修改配置外，还提供文本模式批量添加、修改。 这个对于从已有的

properties文件迁移尤其有用

切换到文本编辑模式

![image.png](https://image.hyly.net/i/2025/09/25/2584d621425cea26878b3d2abbf7c51e-0.webp)

输入配置项，并点击提交修改

![image.png](https://image.hyly.net/i/2025/09/25/8e2e72e23f96754c6d86685918ec1775-0.webp)

3. 发布配置

![image.png](https://image.hyly.net/i/2025/09/25/7dc44fdef2c3d933b7cae2b3a93f0d92-0.webp)

#### 修改配置

1. 找到对应的配置项，点击修改

![image.png](https://image.hyly.net/i/2025/09/25/5da2bf48a9fb93f66791a5773d09e0f9-0.webp)

2. 修改为需要的值，点击提交
3. 发布配置

#### 删除配置

1. 找到需要删除的配置项，点击删除

![image.png](https://image.hyly.net/i/2025/09/25/dc302a24b46756c469a3fa383a9b95ac-0.webp)

2. 确认删除后，点击发布

![image.png](https://image.hyly.net/i/2025/09/25/ac5c36d7b3199e3ba8864db6d5982b4b-0.webp)

#### 添加Namespace

Namespace作为配置的分类，可当成一个配置文件。

以添加rocketmq配置为例，添加“spring-rocketmq” Namespace配置rocketmq相关信息。

1. 添加项目私有Namespace：spring-rocketmq

进入项目首页，点击左下脚的“添加Namespace”，共包括两项：关联公共Namespace和创建Namespace，

这里选择“创建Namespace”

![image.png](https://image.hyly.net/i/2025/09/25/9b1a29299d48c2a7c401af79a88f75d8-0.webp)

2. 添加配置项

```
rocketmq.name‐server = 127.0.0.1:9876 
rocketmq.producer.group = PID_ACCOUNT
```

![image.png](https://image.hyly.net/i/2025/09/25/9ba3471f3f65843a0a3383bcd0ef0757-0.webp)

3. 发布配置

![image.png](https://image.hyly.net/i/2025/09/25/b4c808c070685b6b69605b4601b72cdd-0.webp)

#### 公共配置

##### 添加公共Namespace

在项目开发中，有一些配置可能是通用的，我们可以通过把这些通用的配置放到公共的Namespace中，这样其他

项目要使用时可以直接添加需要的Namespace

1. 新建common-template项目

![image.png](https://image.hyly.net/i/2025/09/25/2e489cfa8b4b835367ff2236b5c1cfea-0.webp)

2. 添加公共Namespace：spring-boot-http

进入common-template项目管理页面：http://localhost:8070/confifig.html?#/appid=common-template

![image.png](https://image.hyly.net/i/2025/09/25/09ae7a0bbfc435956a1d00c810a54b73-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/f4a7d14becc4d06994bad06b9ef15ba0-0.webp)

3. 添加配置项并发布

```
spring.http.encoding.enabled = true 
spring.http.encoding.charset = UTF‐8 
spring.http.encoding.force = true 
server.tomcat.remote_ip_header = x‐forwarded‐for 
server.tomcat.protocol_header = x‐forwarded‐proto 
server.use‐forward‐headers = true 
server.servlet.context‐path = /
```

![image.png](https://image.hyly.net/i/2025/09/25/aa7a93c37cd2b34a9790f3a7b6999aee-0.webp)

##### 关联公共Namespace

1. 打开之前创建的account-service项目
2. 点击左侧的添加Namespace
3. 添加Namespace

![image.png](https://image.hyly.net/i/2025/09/25/cd426c934fb2f20e971e511e711094bd-0.webp)

4. 根据需求可以覆盖引入公共Namespace中的配置，下面以覆盖server.servlet.context-path为例

![image.png](https://image.hyly.net/i/2025/09/25/85991514c00565b3e603f4fab70a704c-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/136be388a852bda2d186ac3265cede31-0.webp)

5. 修改server.servlet.context-path为：/account-service

![image.png](https://image.hyly.net/i/2025/09/25/2a09aa785fa095d0a5c2ebc3c8e2f2a8-0.webp)

6. 发布修改的配置项

![image.png](https://image.hyly.net/i/2025/09/25/c448caec8b97e9a56e0ac1f6db379cc3-0.webp)

### 多项目配置

通常一个分布式系统包括多个项目，所以需要多个项目，下边以一个P2P金融的项目为例，添加交易中心微服务 transaction-service。

1. 添加交易中心微服务transaction-service

![image.png](https://image.hyly.net/i/2025/09/25/d89711ebf6580c8633e7e2bbb2ebfb2d-0.webp)

2. 关联公共Namespace 任务应用都可以关联公共Namespace。

![image.png](https://image.hyly.net/i/2025/09/25/df2089742807d62d61566e05fabbb029-0.webp)

3. 覆盖配置，修改交易中心微服务的context-path为：/transaction

![image.png](https://image.hyly.net/i/2025/09/25/8d6384461b055314ef8e2dbfd6f5bfb2-0.webp)

4. 发布修改后的配置

### 集群管理

在有些情况下，应用有需求对不同的集群做不同的配置，比如部署在A机房的应用连接的RocketMQ服务器地址和 部署在B机房的应用连接的RocketMQ服务器地址不一样。另外在项目开发过程中，也可为不同的开发人员创建不 同的集群来满足开发人员的自定义配置。

#### 创建集群

1. 点击页面左侧的“添加集群”按钮

![image.png](https://image.hyly.net/i/2025/09/25/61e3002f2b16076b9dea8a208c390aa9-0.webp)

2. 输入集群名称SHAJQ，选择环境并提交：添加上海金桥数据中心为例

![image.png](https://image.hyly.net/i/2025/09/25/a1d8412eae6e06d2c29ea7378d625301-0.webp)

3. 切换到对应的集群，修改配置并发布即可

![image.png](https://image.hyly.net/i/2025/09/25/82a1ed158bcb1d094fc7e97845abc597-0.webp)

#### 同步集群配置

同步集群的配置是指在同一个应用中拷贝某个环境下的集群的配置到目标环境下的目标集群。

1. 从其他集群同步已有配置到新集群

切换到原有集群

展开要同步的Namespace，点击同步配置

![image.png](https://image.hyly.net/i/2025/09/25/81485ab084b2261aaef2ef695a738cb6-0.webp)

选择同步到的新集群，再选择要同步的配置

![image.png](https://image.hyly.net/i/2025/09/25/1748a0ed9e990d87bc06f1f416bb4d54-0.webp)

同步完成后，切换到SHAJQ集群，发布配置

![image.png](https://image.hyly.net/i/2025/09/25/7f55f2333b2c35ad83aa7e4991eedfc0-0.webp)

#### 读取配置

读取某个集群的配置，需要启动应用时指定具体的应用、环境和集群。

-Dapp.id=应用名称

-Denv=环境名称

-Dapollo.cluster=集群名称

-D环境_meta=meta地址

```
‐Dapp.id=account‐service ‐Denv=DEV ‐Dapollo.cluster=SHAJQ ‐Ddev_meta=http://localhost:8080
```

### 配置发布原理

在配置中心中，一个重要的功能就是配置发布后实时推送到客户端。下面我们简要看一下这块是怎么设计实现的。

![image.png](https://image.hyly.net/i/2025/09/25/4823157586abf3f485b4197667ad91ce-0.webp)

上图简要描述了配置发布的主要过程：

1. 用户在Portal操作配置发布
2. Portal调用Admin Service的接口操作发布
3. Admin Service发布配置后，发送ReleaseMessage给各个Confifig Service
4. Confifig Service收到ReleaseMessage后，通知对应的客户端

#### 发送ReleaseMessage

Admin Service在配置发布后，需要通知所有的Config Service有配置发布，从而Config Service可以通知对应的客 户端来拉取最新的配置。

从概念上来看，这是一个典型的消息使用场景，Admin Service作为producer（生产者）发出消息，各个Config Service作为consumer（消费者）消费消息。通过一个消息队列组件（Message Queue）就能很好的实现Admin Service和Config Service的解耦。

在实现上，考虑到Apollo的实际使用场景，以及为了尽可能减少外部依赖，我们没有采用外部的消息中间件，而是 通过数据库实现了一个简单的消息队列。

具体实现方式如下：

1. Admin Service在配置发布后会往ReleaseMessage表插入一条消息记录，消息内容就是配置发布的

AppId+Cluster+Namespace

```
SELECT * FROM ApolloConfigDB.ReleaseMessage
```

![image.png](https://image.hyly.net/i/2025/09/25/b131952aedf581b82f9e61c9be428e5c-0.webp)

消息发送类：DatabaseMessageSende

![image.png](https://image.hyly.net/i/2025/09/25/95e2a8f62f76ae0b675515340fabc41c-0.webp)

2. Config Service有一个线程会每秒扫描一次ReleaseMessage表，看看是否有新的消息记录 消息扫描类：ReleaseMessageScanner

![image.png](https://image.hyly.net/i/2025/09/25/d45ca6332e2ec1fe32a8ad65bdfb96c4-0.webp)

3. Config Service如果发现有新的消息记录，那么就会通知到所有的消息监听器

![image.png](https://image.hyly.net/i/2025/09/25/a22a05f0f9e59cc5b81918578d5840dd-0.webp)

然后调用消息监听类的handleMessage方法：NotificationControllerV2

![image.png](https://image.hyly.net/i/2025/09/25/6ee2aba5a1af4739d1b4a19b2f8d6f7b-0.webp)

4. NotificationControllerV2得到配置发布的AppId+Cluster+Namespace后，会通知对应的客户端

![image.png](https://image.hyly.net/i/2025/09/25/636851a53430b89ddd500826db0de8fe-0.webp)

#### Config Service通知客户端

上一节中简要描述了NotifificationControllerV2是如何得知有配置发布的，那NotifificationControllerV2在得知有配

置发布后是如何通知到客户端的呢？

实现方式如下：

1. 客户端会发起一个Http请求到Confifig Service的 notifications/v2 接口NotifificationControllerV2

![image.png](https://image.hyly.net/i/2025/09/25/89b1276b7fd835ae5b48f1526e514ce9-0.webp)

客户端发送请求类：RemoteConfigLongPollService

![image.png](https://image.hyly.net/i/2025/09/25/3d94a6a9c7390660bdf4272e5067b1ba-0.webp)

2. NotificationControllerV2不会立即返回结果，而是把请求挂起。考虑到会有数万客户端向服务端发起长连， 因此在服务端使用了async servlet(Spring DeferredResult)来服务Http Long Polling请求。
3. 如果在60秒内没有该客户端关心的配置发布，那么会返回Http状态码304给客户端。
4. 如果有该客户端关心的配置发布，NotificationControllerV2会调用DeferredResult的setResult方法，传入有 配置变化的namespace信息，同时该请求会立即返回。客户端从返回的结果中获取到配置变化的namespace 后，会立即请求Config Service获取该namespace的最新配置。

#### 客户端读取设计

除了之前介绍的客户端和服务端保持一个长连接，从而能第一时间获得配置更新的推送外，**客户端还会定时从 Apollo配置中心服务端拉取应用的最新配置。**

1. 这是一个备用机制，为了防止推送机制失效导致配置不更新
2. 客户端定时拉取会上报本地版本，所以一般情况下，对于定时拉取的操作，服务端都会返回304 - Not Modified
3. 定时频率默认为每5分钟拉取一次，客户端也可以通过在运行时指定System Property: apollo.refreshInterval 来覆盖，单位为分钟

## Apollo应用于分布式系统

在微服务架构模式下，项目往往会切分成多个微服务，下面将以万信金融P2P项目为例演示如何在项目中使用。

### 项目场景介绍

#### 项目概述

万信金融是一款面向互联网大众提供的理财服务和个人消费信贷服务的金融平台，依托大数据风控技术，为用户提 供方便、快捷、安心的P2P金融服务。本项目包括交易平台和业务支撑两个部分，交易平台主要实现理财服务，包 括：借钱、出借等模块，业务支撑包括：标的管理、对账管理、风控管理等模块。项目采用先进的互联网技术进行 研发，保证了P2P双方交易的安全性、快捷性及稳定性。

#### 各微服务介绍

本章节仅仅是为了演示配置中心，所以摘取了部分微服务，如下：

用户中心服务(consumer-service)：为借款人和投资人提供用户账户管理服务，包括：注册、开户、充值、提现等

UAA认证服务(uaa-service)：为用户中心的用户提供认证服务

统一账户服务(account-service)：对借款人和投资人的登录平台账号进行管理，包括：注册账号、账号权限管理等

交易中心(transaction-service)：负责P2P平台用户发标和投标功能

### Spring Boot应用集成

下面以集成统一账户服务(account-service)为例

#### 导入工程

参考account-service、transaction-service、uaa-service、consumer-service工程，手动创建这几个微服务。 每个工程必须添加依赖：

```
<dependency> <groupId>com.ctrip.framework.apollo</groupId> <artifactId>apollo‐client</artifactId> <version>1.1.0</version> </dependency>
```

下边是account-service依赖，其它工程参考“资料”下的“微服务”。

```
<?xml version="1.0" encoding="UTF‐8"?> <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema‐ instance"xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
http://maven.apache.org/xsd/maven‐4.0.0.xsd"> <modelVersion>4.0.0</modelVersion> <parent> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐starter‐parent</artifactId> <version>2.1.3.RELEASE</version> <relativePath/> <!‐‐ lookup parent from repository ‐‐> </parent> <groupId>cn.itcast</groupId> <artifactId>account‐service</artifactId> <version>0.0.1‐SNAPSHOT</version> <properties> <java.version>1.8</java.version> </properties> <dependencies> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐starter</artifactId> <exclusions> <exclusion> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐starter‐logging</artifactId> </exclusion> </exclusions> </dependency> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐starter‐log4j2</artifactId> </dependency> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐starter‐web</artifactId> </dependency> <dependency> <groupId>org.springframework.boot</groupId> <artifactId>spring‐boot‐configuration‐processor</artifactId> <optional>true</optional> </dependency> <dependency> <groupId>com.ctrip.framework.apollo</groupId> <artifactId>apollo‐client</artifactId> <version>1.1.0</version> </dependency> </dependencies> </project>
```

#### 必选配置

1. AppId：在Spring Boot application.properties或application.yml中配置

application.properties

```
app.id=account‐service
```

application.yml

```
app: 
	id: account‐service
```

2. apollo.bootstrap

集成springboot，开启apollo.bootstrap，指定namespace

例子：

```
apollo.bootstrap.enabled = true apollo.bootstrap.namespaces = application,micro_service.spring‐boot‐http,spring‐ rocketmq,micro_service.spring‐boot‐druid
```

3. Apollo Meta Server

Apollo支持应用在不同的环境有不同的配置，常用的指定方式有如下两种：

第一种：通过Java System Property的apollo.meta： -Dapollo.meta=http://localhost:8080

第二种：在resources目录下新建apollo-env.properties文件

```
dev.meta=http://localhost:8080 
pro.meta=http://localhost:8081
```

4. 本地缓存路径

Apollo客户端会把从服务端获取到的配置在本地文件系统缓存一份，用于在遇到服务不可用，或网络不通的

时候，依然能从本地恢复配置，不影响应用正常运行。本地配置文件会以下面的文件名格式放置于配置的本

地缓存路径下：

{appId}+{cluster}+{namespace}.properties

![image.png](https://image.hyly.net/i/2025/09/25/ed298b918ab7d2c1c3d9f7f81d784fed-0.webp)

可以通过如下方式指定缓存路径，通过Java System Property的apollo.cacheDir：

```
‐Dapollo.cacheDir=/opt/data/apollo‐config
```

5. Environment

通过Java System Property的env来指定环境： -Denv=DEV

6. Cluster（集群）

通过Java System Property的apollo.cluste来指定集群： -Dapollo.cluster=DEFAULT

也可以选择使用之前新建的SHAJQ集群： -Dapollo.cluster=SHAJQ

7. 完整的VM Options如下：

```
‐Denv=DEV ‐Dapollo.cacheDir=/opt/data/apollo‐config ‐Dapollo.cluster=DEFAULT
```

![image.png](https://image.hyly.net/i/2025/09/25/120468fd43589386969141dbf0a2ae9d-0.webp)

#### 启用配置

在咱们应用的启动类添加 @EnableApolloConfig 注解即可：

```
@SpringBootApplication(scanBasePackages = "cn.itcast.account") @EnableApolloConfig public class AccountApplication { public static void main(String[] args) { SpringApplication.run(AccountApplication.class, args); } }
```

#### 应用配置

1. 将local-config/account.properties中的配置添加到apollo中

```
swagger.enable=true 
sms.enable=true 

spring.http.encoding.charset=UTF‐8 
spring.http.encoding.force=true 
spring.http.encoding.enabled=true 
server.use‐forward‐headers=true 
server.tomcat.protocol_header=x‐forwarded‐proto 
server.servlet.context‐path=/account‐service 
server.tomcat.remote_ip_header=x‐forwarded‐for 

spring.datasource.driver‐class‐name=com.mysql.cj.jdbc.Driver 
spring.datasource.druid.stat‐view‐servlet.allow=127.0.0.1,192.168.163.1 
spring.datasource.druid.web‐stat‐filter.session‐stat‐enable=false 
spring.datasource.druid.max‐pool‐prepared‐statement‐per‐connection‐size=20 

spring.datasource.druid.max‐active=20
spring.datasource.druid.stat‐view‐servlet.reset‐enable=false 
spring.datasource.druid.validation‐query=SELECT 1 FROM DUAL 
spring.datasource.druid.stat‐view‐servlet.enabled=true 
spring.datasource.druid.web‐stat‐filter.enabled=true 
spring.datasource.druid.stat‐view‐servlet.url‐pattern=/druid/* 
spring.datasource.druid.stat‐view‐servlet.deny=192.168.1.73 spring.datasource.url=jdbc\:mysql\://127.0.0.1\:3306/p2p_account?useUnicode\=true spring.datasource.druid.filters=config,stat,wall,log4j2 
spring.datasource.druid.test‐on‐return=false 
spring.datasource.druid.web‐stat‐filter.profile‐enable=true 
spring.datasource.druid.initial‐size=5 
spring.datasource.druid.min‐idle=5 
spring.datasource.druid.max‐wait=60000 
spring.datasource.druid.web‐stat‐filter.session‐stat‐max‐count=1000 
spring.datasource.druid.pool‐prepared‐statements=true 
spring.datasource.druid.test‐while‐idle=true 
spring.datasource.password=itcast0430 
spring.datasource.username=root 
spring.datasource.druid.stat‐view‐servlet.login‐password=admin 
spring.datasource.druid.stat‐view‐servlet.login‐username=admin 
spring.datasource.druid.web‐stat‐filter.url‐pattern=/* 
spring.datasource.druid.time‐between‐eviction‐runs‐millis=60000 
spring.datasource.druid.min‐evictable‐idle‐time‐millis=300000 
spring.datasource.druid.test‐on‐borrow=false 
spring.datasource.druid.web‐stat‐filter.principal‐session‐name=admin spring.datasource.druid.filter.stat.log‐slow‐sql=true 
spring.datasource.druid.web‐stat‐filter.principal‐cookie‐name=admin spring.datasource.type=com.alibaba.druid.pool.DruidDataSource 
spring.datasource.druid.aop‐patterns=cn.itcast.wanxinp2p.*.service.* spring.datasource.druid.filter.stat.slow‐sql‐millis=1 
spring.datasource.druid.web‐stat‐ filter.exclusions=*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*
```

2. spring-http命名空间在之前已通过关联公共命名空间添加好了，现在来添加spring-boot-druid命名空间

![image.png](https://image.hyly.net/i/2025/09/25/282b25e23b33f0b0f0f98729c8a9f1ce-0.webp)

3. 添加本地文件中的配置到对应的命名空间，然后发布配置

![image.png](https://image.hyly.net/i/2025/09/25/a9661921e514fafadaf8ffd44db2b9f2-0.webp)

4. 在account-service/src/main/resources/application.properties中配置apollo.bootstrap.namespaces需要 引入的命名空间

```
app.id=account‐service 
apollo.bootstrap.enabled = true 
apollo.bootstrap.namespaces = application,micro_service.spring‐boot‐http,spring‐ rocketmq,spring‐boot‐druid 

server.port=63000
```

#### 读取配置

1. 启动应用

![image.png](https://image.hyly.net/i/2025/09/25/b3c79de5663ff37b52d3f3d8390fca39-0.webp)

2. 访问：http://127.0.0.1:63000/account-service/hi，确认Spring Boot中配置的context-path是否生效

![image.png](https://image.hyly.net/i/2025/09/25/e5653a6e53bf4bb07412ebabf3d2ff41-0.webp)

通过/account-service能正常访问，说明apollo的配置已生效

![image.png](https://image.hyly.net/i/2025/09/25/b1ab10a74d9c5b6564aa1e1d34d7e645-0.webp)

3. 确认spring-boot-druid配置

为了快速确认可以在AccountController中通过@Value获取来验证

![image.png](https://image.hyly.net/i/2025/09/25/9aabfdf2d9862796ad84e110b6e17896-0.webp)

#### 创建其它项目

参考account-service将其它项目也创建完成。

### 生产环境部署

当一个项目要上线部署到生产环境时，项目的配置比如数据库连接、RocketMQ地址等都会发生变化，这时候就需 要通过Apollo为生产环境添加自己的配置。

#### 企业部署方案

在企业中常用的部署方案为：Apollo-adminservice和Apollo-confifigservice两个服务分别在线上环境(pro)，仿真环

境(uat)和开发环境(dev)各部署一套，Apollo-portal做为管理端只部署一套，统一管理上述三套环境。

具体如下图所示：

![image.png](https://image.hyly.net/i/2025/09/25/df7ad3936b9e3c40f7fad3e19e707907-0.webp)

下面以添加生产环境部署为例

#### 创建数据库

创建生产环境的ApolloConfigDB：**每添加一套环境就需要部署一套ApolloConfgService和ApolloAdminService source** apollo/ApolloConfigDB_PRO__initialization.sql

#### 配置启动参数

1. 设置生产环境数据库连接
2. 设置ApolloConfigService端口为：8081，ApolloAdminService端口为8091

```
echo 

set url="localhost:3306" 
set username="root" 
set password="mysqlpwd" 

start "configService‐PRO" java ‐Dserver.port=8081 ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloConfigDBPRO?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐configservice.log ‐jar .\apollo‐configservice‐1.3.0.jar start "adminService‐PRO" java ‐Dserver.port=8091 ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloConfigDBPRO?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐adminservice.log ‐jar .\apollo‐adminservice‐1.3.0.jar
```

3. 运行runApollo-PRO.bat

#### 修改Eureka地址

更新生产环境Apollo的Eureka地址：

```
USE ApolloConfigDBPRO; 

UPDATE ServerConfig SET `Value` = "http://localhost:8081/eureka/" WHERE `key` = "eureka.service.url";
```

##### 调整ApolloPortal服务配置

服务配置项统一存储在ApolloPortalDB.ServerConfig表中，可以通过 管理员工具 - 系统参数 页面进行配置： apollo.portal.envs - 可支持的环境列表

![image.png](https://image.hyly.net/i/2025/09/25/29c6823f5797fd06fa99c1072168504a-0.webp)

默认值是dev，如果portal需要管理多个环境的话，以逗号分隔即可（大小写不敏感），如：

```
dev,pro
```

#### 启动ApolloPortal

Apollo Portal需要在不同的环境访问不同的meta service(apollo-configservice)地址，所以我们需要在配置中提供 这些信息。

```
‐Ddev_meta=http://localhost:8080/ ‐Dpro_meta=http://localhost:8081/
```

1. 关闭之前启动的ApolloPortal服务，使用runApolloPortal.bat启动多环境配置

```
echo 

set url="localhost:3306" 
set username="root" 
set password="123" 

start "ApolloPortal" java ‐Xms256m ‐Xmx256m ‐Dapollo_profile=github,auth ‐ Ddev_meta=http://localhost:8080/ ‐Dpro_meta=http://localhost:8081/ ‐Dserver.port=8070 ‐ Dspring.datasource.url=jdbc:mysql://%url%/ApolloPortalDB?characterEncoding=utf8 ‐ Dspring.datasource.username=%username% ‐Dspring.datasource.password=%password% ‐ Dlogging.file=.\logs\apollo‐portal.log ‐jar .\apollo‐portal‐1.3.0.jar
```

2. 启动之后，点击account-service服务配置后会提示环境缺失，此时需要补全上边新增生产环境的配置

![image.png](https://image.hyly.net/i/2025/09/25/a27593e85b4c21b27a4f8e9784a2176b-0.webp)

3. 点击补缺环境

![image.png](https://image.hyly.net/i/2025/09/25/891d583b839d815f4e16183365b74a46-0.webp)

4. 补缺过生产环境后，切换到PRO环境后会提示有Namespace缺失，点击补缺

![image.png](https://image.hyly.net/i/2025/09/25/0ee846e4d418744f7691ea2cf44c0544-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/832408e99f30baea8fc26e5fdcc8acad-0.webp)

5. 从dev环境同步配置到pro

![image.png](https://image.hyly.net/i/2025/09/25/5fb6954d4e7e13c1ded183a7f3823c69-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/e9b26736e45cbe305a53f37b8a0abf5d-0.webp)

#### 验证配置

1. 同步完成后，切换到pro环境，修改生产环境rocketmq地址后发布配置

![image.png](https://image.hyly.net/i/2025/09/25/2122cf3c67dbeacf6ac1e08b0ef16c78-0.webp)

2. 配置项目使用pro环境，测试配置是否生效

在apollo-env.properties中增加pro.meta=http://localhost:8081

修改account-service启动参数为：-Denv=pro

```
‐Denv=pro ‐Dapollo.cacheDir=/opt/data/apollo‐config ‐Dapollo.cluster=DEFAULT
```

访问http://127.0.0.1:63000/account-service/mq 验证RocketMQ地址是否为上边设置的PRO环境的值

![image.png](https://image.hyly.net/i/2025/09/25/d3d526446fe7d8afadcd8c540fa57480-0.webp)

### 灰度发布

#### 定义

灰度发布是指在黑与白之间，能够平滑过渡的一种发布方式。在其上可以进行A/B testing，即让一部分用户继续用 产品特性A，一部分用户开始用产品特性B，如果用户对B没有什么反对意见，那么逐步扩大范围，把所有用户都迁 移到B上面来。

#### Apollo实现的功能

1. 对于一些对程序有比较大影响的配置，可以先在一个或者多个实例生效，观察一段时间没问题后再全量发布 配置。
2. 对于一些需要调优的配置参数，可以通过灰度发布功能来实现A/B测试。可以在不同的机器上应用不同的配 置，不断调整、测评一段时间后找出较优的配置再全量发布配置。

#### 场景介绍

apollo-quickstart项目有两个客户端：

1. 172.16.0.160
2. 172.16.0.170

![image.png](https://image.hyly.net/i/2025/09/25/b9d64a66416de01acefb4e2b77e562af-0.webp)

**灰度目标**

当前有一个配置timeout=2000，我们希望对172.16.0.160灰度发布timeout=3000，对172.16.0.170仍然是 timeout=2000。

![image.png](https://image.hyly.net/i/2025/09/25/c74c213c9c45fbbadb9a8fbc81e5ccdd-0.webp)

#### 创建灰度

1. 点击application namespace右上角的 创建灰度 按钮

![image.png](https://image.hyly.net/i/2025/09/25/64ac1d3b66118d12161f92b5243d8189-0.webp)

2. 点击确定后，灰度版本就创建成功了，页面会自动切换到 灰度版本 Tab

![image.png](https://image.hyly.net/i/2025/09/25/a2c97e2bd39ffb72095b4c9fad14e866-0.webp)

#### 灰度配置

1. 点击 主版本的配置 中，timeout配置最右侧的 对此配置灰度 按钮

![image.png](https://image.hyly.net/i/2025/09/25/0090d87bf129f8d9bce0552a4871e30a-0.webp)

2. 在弹出框中填入要灰度的值：3000，点击提交

![image.png](https://image.hyly.net/i/2025/09/25/bd9897074fa90a209c43057b051e4b20-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/c5844f846277c7cabafacbc70f4fb63a-0.webp)

#### 配置灰度规则

1. 切换到 灰度规则 Tab，点击 新增规则 按钮

![image.png](https://image.hyly.net/i/2025/09/25/d651dda93e8a2b43b40a4a4219b8f778-0.webp)

2. 在弹出框中 灰度的IP 下拉框会默认展示当前使用配置的机器列表，选择我们要灰度的IP，点击完成

![image.png](https://image.hyly.net/i/2025/09/25/6e498e7a09781435d6174c13c469ff24-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/d6b79de5e6be3c244cbf3b8e465db470-0.webp)

如果下拉框中没找到需要的IP，说明机器还没从Apollo取过配置，可以点击手动输入IP来输入，输入完后点击 添加按钮

![image.png](https://image.hyly.net/i/2025/09/25/795350517fa3fbe15f14192549529e42-0.webp)

#### 灰度发布

1. 启动apollo-quickstart项目的GrayTest类输出timeout的值

vm options: -Dapp.id=apollo-quickstart -Denv=DEV -Ddev_meta=http://localhost:8080

```
public class GrayTest { // VM options: // ‐Dapp.id=apollo‐quickstart ‐Denv=DEV ‐Ddev_meta=http://localhost:8080 public static void main(String[] args) throws InterruptedException { Config config = ConfigService.getAppConfig(); String someKey = "timeout"; while (true) { String value = config.getProperty(someKey, null); System.out.printf("now: %s, timeout: %s%n", LocalDateTime.now().toString(), value); Thread.sleep(3000L); } } }
```

![image.png](https://image.hyly.net/i/2025/09/25/becd34249ac8f69bb1c317b87401dcf9-0.webp)

2. 切换到 配置 Tab，再次检查灰度的配置部分，如果没有问题，点击 灰度发布

![image.png](https://image.hyly.net/i/2025/09/25/3b9bdbfdaa022d8f2eade486b88dc6b8-0.webp)

3. 在弹出框中可以看到主版本的值是2000，灰度版本即将发布的值是3000。填入其它信息后，点击发布

![image.png](https://image.hyly.net/i/2025/09/25/2ea2789841004eb41958cabe8c16bbd0-0.webp)

4. 发布后，切换到 灰度实例列表 Tab，就能看到172.16.0.160已经使用了灰度发布的值

![image.png](https://image.hyly.net/i/2025/09/25/2e97df65ae1ed0a2e7e59a6c3b6f1477-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/1493c42415eb26f74f9889c34b4d4d77-0.webp)

#### 全量发布

如果灰度的配置测试下来比较理想，符合预期，那么就可以操作 全量发布 。

全量发布的效果是：

1. 灰度版本的配置会合并回主版本，在这个例子中，就是主版本的timeout会被更新成3000
2. 主版本的配置会自动进行一次发布
3. 在全量发布页面，可以选择是否保留当前灰度版本，默认为不保留。

![image.png](https://image.hyly.net/i/2025/09/25/e5680567aba52d5ab0bc1fa9dcd5742b-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/a33ede68197a8916c41ba39c0fc2bc19-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/b743799219191583a95e5cb9ef9ae44c-0.webp)

#### 放弃灰度

如果灰度版本不理想或者不需要了，可以点击 放弃灰度

![image.png](https://image.hyly.net/i/2025/09/25/ba7920e891edb694f77663b4fde02114-0.webp)

#### 发布历史

点击主版本的 发布历史 按钮，可以看到当前namespace的主版本以及灰度版本的发布历史

![image.png](https://image.hyly.net/i/2025/09/25/a575972c52819d17efdf55571091c702-0.webp)