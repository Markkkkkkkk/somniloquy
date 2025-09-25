---
category: [Java技术栈]
tag: [skywalking,面试]
postType: post
status: publish
---

## Skywalking概述

### 什么是APM系统

#### APM系统概述

APM (Application Performance Management) 即应用性能管理系统，是对企业系统即时监控以实现
对应用程序性能管理和故障管理的系统化的解决方案。应用性能管理，主要指对企业的关键业务应用进
行监测、优化，提高企业应用的可靠性和质量，保证用户得到良好的服务，降低IT总拥有成本

**APM系统是可以帮助理解系统行为、用于分析性能问题的工具，以便发生故障的时候，能够快速定位和
解决问题。**

#### 分布式链路追踪

随着分布式系统和微服务架构的出现，一次用户的请求会经过多个系统，不同服务之间的调用关系十分
复杂，任何一个系统出错都可能影响整个请求的处理结果。以往的监控系统往往只能知道单个系统的健
康状况、一次请求的成功失败，无法快速定位失败的根本原因。

![image.png](https://image.hyly.net/i/2025/09/25/c6a14a7d20031f7d8f75ac9822ac8e77-0.webp)

除此之外，复杂的分布式系统也面临这下面这些问题：

1. 性能分析：一个服务依赖很多服务，被依赖的服务也依赖了其他服务。如果某个接口耗时突然变长
   了，那未必是直接调用的下游服务慢了，也可能是下游的下游慢了造成的，如何快速定位耗时变长
   的根本原因呢？
2. 链路梳理：需求迭代很快，系统之间调用关系变化频繁，靠人工很难梳理清楚系统链路拓扑(系统
   之间的调用关系)。

**为了解决这些问题，Google 推出了一个分布式链路跟踪系统 Dapper ，之后各个互联网公司都参照
Dapper 的思想推出了自己的分布式链路跟踪系统，而这些系统就是分布式系统下的APM系统。**

#### 什么是OpenTracing

**分布式链路跟踪最先由Google在Dapper论文中提出，而OpenTracing通过提供平台无关、厂商无关
的API，使得开发人员能够方便的添加（或更换）追踪系统的实现。**

下图是一个分布式调用的例子，客户端发起请求，请求首先到达负载均衡器，接着经过认证服务，订单
服务，然后请求资源，最后返回结果。

![image.png](https://image.hyly.net/i/2025/09/25/e185666ed705a92760a747a9a758b738-0.webp)

虽然这种图对于看清各组件的组合关系是很有用的，但是存在下面两个问题：

1. 它不能很好显示组件的调用时间，是串行调用还是并行调用，如果展现更复杂的调用关系，会更加
   复杂，甚至无法画出这样的图。
2. 这种图也无法显示调用间的时间间隔以及是否通过定时调用来启动调用。

一种更有效的展现一个调用过程的图：

![image.png](https://image.hyly.net/i/2025/09/25/6981f15f5bb2b59efbfe2e2b517936ae-0.webp)

基于OpenTracing我们就可以很轻松的构建出上面这幅图。

#### 主流的开源APM产品

**PinPoint**

Pinpoint是由一个韩国团队实现并开源，针对Java编写的大规模分布式系统设计，通过JavaAgent的机
制做字节代码植入，实现加入traceid和获取性能数据的目的，对应用代码零侵入。

官方网站：

https://github.com/naver/pinpoint

![image.png](https://image.hyly.net/i/2025/09/25/c1ff1e1cbdf57e7a0b1fccf5f4a6fd9c-0.webp)

**SkyWalking**

SkyWalking是apache基金会下面的一个开源APM项目，为微服务架构和云原生架构系统设计。它通过
探针自动收集所需的指标，并进行分布式追踪。通过这些调用链路以及指标，Skywalking APM会感知
应用间关系和服务间关系，并进行相应的指标统计。Skywalking支持链路追踪和监控应用组件基本涵盖
主流框架和容器，如国产RPC Dubbo和motan等，国际化的spring boot，spring cloud。

官方网站：

http://skywalking.apache.org/

**Zipkin**

Zipkin是由Twitter开源，是分布式链路调用监控系统，聚合各业务系统调用延迟数据，达到链路调用监
控跟踪。Zipkin基于Google的Dapper论文实现，主要完成数据的收集、存储、搜索与界面展示。

官方网站：

https://zipkin.io/

![image.png](https://image.hyly.net/i/2025/09/25/4811fd4f62ded17b0f38c16b998b2ea1-0.webp)

**CAT**

CAT是由大众点评开源的项目，基于Java开发的实时应用监控平台，包括实时应用监控，业务监控，可
以提供十几张报表展示。

官方网站:

https://github.com/dianping/cat

### 什么是Skywalking

#### Skywalking概述

根据官方的解释，Skywalking是一个可观测性分析平台（Observability Analysis Platform简称OAP）
和应用性能管理系统（Application Performance Management简称APM）。

提供分布式链路追踪、服务网格(Service Mesh)遥测分析、度量(Metric)聚合和可视化一体化解决方案。

下面是Skywalking的几大特点：

1. 多语言自动探针，Java，.NET Core和Node.JS。
2. 多种监控手段，语言探针和service mesh。
3. 轻量高效。不需要额外搭建大数据平台。
4. 模块化架构。UI、存储、集群管理多种机制可选。
5. 支持告警。
6. 优秀的可视化效果。

**Skywalking整体架构如下：**

![image.png](https://image.hyly.net/i/2025/09/25/faf637cf6183935047a807a6b903f079-0.webp)

Skywalking提供Tracing和Metrics数据的获取和聚合。

Metric的特点是，它是可累加的：他们具有原子性，每个都是一个逻辑计量单元，或者一个时间
段内的柱状图。 例如：队列的当前深度可以被定义为一个计量单元，在写入或读取时被更新统
计； 输入HTTP请求的数量可以被定义为一个计数器，用于简单累加； 请求的执行时间可以被定
义为一个柱状图，在指定时间片上更新和统计汇总。

Tracing的最大特点就是，它在单次请求的范围内，处理信息。 任何的数据、元数据信息都被绑定
到系统中的单个事务上。 例如：一次调用远程服务的RPC执行过程；一次实际的SQL查询语句；
一次HTTP请求的业务性ID。

总结，Metric主要用来进行数据的统计，比如HTTP请求数的计算。Tracing主要包含了某一次请
求的链路数据。

详细的内容可以查看Skywalking开发者吴晟翻译的文章，Metrics, tracing 和 logging 的关系 ：

http://blog.oneapm.com/apm-tech/811.html

整体架构包含如下三个组成部分：

1. 探针(agent)负责进行数据的收集，包含了Tracing和Metrics的数据，agent会被安装到服务所在的
   服务器上，以方便数据的获取。
2. 可观测性分析平台OAP(Observability Analysis Platform)，接收探针发送的数据，并在内存中使
   用分析引擎（Analysis Core)进行数据的整合运算，然后将数据存储到对应的存储介质上，比如
   Elasticsearch、MySQL数据库、H2数据库等。同时OAP还使用查询引擎(Query Core)提供HTTP查
   询接口。
3. Skywalking提供单独的UI进行数据的查看，此时UI会调用OAP提供的接口，获取对应的数据然后
   进行展示。

#### Skywalking优势

Skywalking相比较其他的分布式链路监控工具，具有以下特点：

1. 社区相当活跃。Skywalking已经进入apache孵化，目前的start数已经超过11K，最新版本6.5.0已
   经发布。开发者是国人，可以直接和项目发起人交流进行问题的解决。
2. Skywalking支持Java，.NET Core和Node.JS语言。相对于其他平台：比如Pinpoint支持Java和
   PHP,具有较大的优势。
3. 探针无倾入性。对比CAT具有倾入性的探针，优势较大。不修改原有项目一行代码就可以进行集
   成。
4. 探针性能优秀。有网友对Pinpoint和Skywalking进行过测试，由于Pinpoint收集的数据过多，所以
   对性能损耗较大，而Skywalking探针性能十分出色。
5. 支持组件较多。特别是对Rpc框架的支持，这是其他框架所不具备的。Skywalking对Dubbo、
   gRpc等有原生的支持，甚至连小众的motan和sofarpc都支持。

#### Skywalking主要概念介绍

使用如下案例来进行Skywalking主要概念的介绍，Skywalking主要概念包含：

1. 服务(Service)
2. 端点(Endpoint)
3. 实例(Instance)

![image.png](https://image.hyly.net/i/2025/09/25/c89f630dbaf44cab8e276d02d5b338bb-0.webp)

上图中，我们编写了用户服务，这是一个web项目，在生产中部署了两个节点：192.168.1.100和
192.168.1.101。

1. 用户服务就是Skywalking的服务(Service)，用户服务其实就是一个独立的应用(Application)，在
   6.0之后的Skywalking将应用更名为服务(Service)。
2. 用户服务对外提供的HTTP接口/usr/queryAll就是一个端点，端点就是对外提供的接口。
3. 192.168.1.100和192.168.1.101这两个相同服务部署的节点就是实例，实例指同一服务可以部署
   多个。

### 环境搭建

接下来我们在虚拟机CentOS中搭建Skywalking的可观测性分析平台OAP环境。Skywalking默认使用H2
内存中进行数据的存储，我们可以替换存储源为ElasticSearch保证其查询的高效及可用性。

具体的安装步骤可以在Skywalking的官方github上找到:

https://github.com/apache/skywalking/blob/master/docs/en/setup/README.md

1、创建目录

```
mkdir /usr/local/skywalking
```

建议将虚拟机内存设置为3G并且将CPU设置成2核，防止资源不足。

2、将资源目录中的elasticsearch和skywalking安装包上传到虚拟机/usr/local/skywalking目录下。

elasticsearch-6.4.0.tar.gz ---elasticsearch 6.4的安装包，Skywalking对es版本号有一定要求，最
好使用6.3.2以上版本，如果是7.x版本需要额外进行配置

apache-skywalking-apm-6.5.0.tar.gz ---Skywalking最新的安装包

3、首先安装elasticsearch，将压缩包解压。

```
tar -zxvf ./elasticsearch-6.4.0.tar.gz
```

修改Linux系统的限制配置，将文件创建数修改为65536个。

1. 修改系统中允许应用最多创建多少文件等的限制权限。Linux默认来说，一般限制应用最多
   创建的文件是65535个。但是ES至少需要65536的文件创建数的权限。
2. 修改系统中允许用户启动的进程开启多少个线程。默认的Linux限制root用户开启的进程可
   以开启任意数量的线程，其他用户开启的进程可以开启1024个线程。必须修改限制数为
   4096+。因为ES至少需要4096的线程池预备。

```
vi /etc/security/limits.conf 

#新增如下内容在limits.conf文件中
es soft nofile 65536 
es hard nofile 65536 
es soft nproc 4096 
es hard nproc 4096
```

修改系统控制权限，ElasticSearch需要开辟一个65536字节以上空间的虚拟内存。Linux默认不允许任
何用户和应用程序直接开辟这么大的虚拟内存。

```
vi /etc/sysctl.conf 

#新增如下内容在sysctl.conf文件中，当前用户拥有的内存权限大小 
vm.max_map_count=262144 

#让系统控制权限配置生效 
sysctl -p
```

建一个用户， 用于ElasticSearch启动。

ES在5.x版本之后，强制要求在linux中不能使用root用户启动ES进程。所以必须使用其他用户启
动ES进程才可以。

```
#创建用户 
useradd es 
#修改上述用户的密码 
passwd es #修改elasicsearch目录的拥有者 
chown -R es elasticsearch-6.4.0
```

使用es用户启动elasticsearch

```
#切换用户 
su es 
#到ElasticSearch的bin目录下 
cd bin/ 
#后台启动 
./elasticsearch -d
```

默认ElasticSearch是不支持跨域访问的，所以在不修改配置文件的情况下我们只能从虚拟机内部进行访
问测试ElasticSearch是否安装成功，使用curl命令访问9200端口：

```
curl http://localhost:9200
```

如果显示出如下信息，就证明ElasticSearch安装成功：

```
{ "name" : "xbruNxf", "cluster_name" : "elasticsearch", "cluster_uuid" : "JJQfHN9QQVuXpH5fu9H1jg", "version" : { "number" : "6.4.0", "build_flavor" : "default", "build_type" : "tar", "build_hash" : "595516e", "build_date" : "2018-08-17T23:18:47.308994Z", "build_snapshot" : false, "lucene_version" : "7.4.0", "minimum_wire_compatibility_version" : "5.6.0", "minimum_index_compatibility_version" : "5.0.0" },"tagline" : "You Know, for Search" }
```

4、安装Skywalking，分为两个步骤：

1. 安装Backend后端服务
2. 安装UI

首先切回到root用户,切换到目录下，解压Skywalking压缩包。

```
#切换到root用户 
su root 
#切换到skywalking目录 
cd /usr/local/skywalking 
#解压压缩包 
tar -zxvf apache-skywalking-apm-6.4.0.tar.gz
```

修改Skywalking存储的数据源配置：

```
cd apache-skywalking-apm-bin 
vi config/application.yml
```

我们可以看到默认配置中，使用了H2作为数据源。我们将其全部注释。

```
# h2: 
# driver: ${SW_STORAGE_H2_DRIVER:org.h2.jdbcx.JdbcDataSource} 
# url: ${SW_STORAGE_H2_URL:jdbc:h2:mem:skywalking-oap-db} 
# user: ${SW_STORAGE_H2_USER:sa} 
# metadataQueryMaxSize: ${SW_STORAGE_H2_QUERY_MAX_SIZE:5000} 
# mysql: 
# metadataQueryMaxSize: ${SW_STORAGE_H2_QUERY_MAX_SIZE:5000}
```

将ElasticSearch对应的配置取消注释：

```
storage:
elasticsearch: nameSpace: ${SW_NAMESPACE:""} clusterNodes: ${SW_STORAGE_ES_CLUSTER_NODES:localhost:9200} protocol: ${SW_STORAGE_ES_HTTP_PROTOCOL:"http"} trustStorePath: ${SW_SW_STORAGE_ES_SSL_JKS_PATH:"../es_keystore.jks"} trustStorePass: ${SW_SW_STORAGE_ES_SSL_JKS_PASS:""} user: ${SW_ES_USER:""} password: ${SW_ES_PASSWORD:""} indexShardsNumber: ${SW_STORAGE_ES_INDEX_SHARDS_NUMBER:2} indexReplicasNumber: ${SW_STORAGE_ES_INDEX_REPLICAS_NUMBER:0} # Those data TTL settings will override the same settings in core module. recordDataTTL: ${SW_STORAGE_ES_RECORD_DATA_TTL:7} # Unit is day otherMetricsDataTTL: ${SW_STORAGE_ES_OTHER_METRIC_DATA_TTL:45} # Unit is day monthMetricsDataTTL: ${SW_STORAGE_ES_MONTH_METRIC_DATA_TTL:18} # Unit is month # # Batch process setting, refer to https://www.elastic.co/guide/en/elasticsearch/client/java-api/5.5/java-docs- bulk-processor.html bulkActions: ${SW_STORAGE_ES_BULK_ACTIONS:1000} # Execute the bulk every 1000 requests flushInterval: ${SW_STORAGE_ES_FLUSH_INTERVAL:10} # flush the bulk every 10 seconds whatever the number of requests concurrentRequests: ${SW_STORAGE_ES_CONCURRENT_REQUESTS:2} # the number of concurrent requests metadataQueryMaxSize: ${SW_STORAGE_ES_QUERY_MAX_SIZE:5000} segmentQueryMaxSize: ${SW_STORAGE_ES_QUERY_SEGMENT_SIZE:200}
```

默认使用了localhost下的ES,所以我们可以不做任何处理，直接进行使用。启动OAP程序：

```
bin/oapService.sh
```

这样安装Backend后端服务就已经完毕了，接下来我们安装UI。先来看一下UI的配置文件：

```
cat webapp/webapp.yml
```

```
#默认启动端口 
server: 
	port: 8080 
collector: 
	path: /graphql 
	ribbon: 
		ReadTimeout: 10000 
		#OAP服务，如果有多个用逗号隔开 
		listOfServers: 127.0.0.1:12800
```

目前的默认配置不用修改就可以使用，启动UI程序：

```
/bin/webappService.sh
```

然后我们就可以通过浏览器访问Skywalking的可视化页面了，访问地址:http://虚拟机IP地址:8080,如果
出现下面的图，就代表安装成功了。

/bin/startup.sh可以同时启动backend和ui，后续可以执行该文件进行重启。

![image.png](https://image.hyly.net/i/2025/09/25/c58e9a42471218f936e9fac14012a21a-0.webp)

## Skywalking基础

### agent的使用

agent探针可以让我们不修改代码的情况下，对java应用上使用到的组件进行动态监控，获取运行数据
发送到OAP上进行统计和存储。agent探针在java中是使用java agent技术实现的，不需要更改任何代
码，java agent会通过虚拟机(VM)接口来在运行期更改代码。

Agent探针支持 JDK 1.6 - 12的版本，Agent探针所有的文件在Skywalking的agent文件夹下。文件目录
如下；

```
+-- agent +-- activations apm-toolkit-log4j-1.x-activation.jar apm-toolkit-log4j-2.x-activation.jar apm-toolkit-logback-1.x-activation.jar ... //配置文件 +-- config agent.config //组件的所有插件 +-- plugins apm-dubbo-plugin.jar apm-feign-default-http-9.x.jar apm-httpClient-4.x-plugin.jar ..... //可选插件 +-- optional-plugins apm-gson-2.x-plugin.jar ..... +-- bootstrap-plugins jdk-http-plugin.jar ..... +-- logs skywalking-agent.jar
```

部分插件在使用上会影响整体的性能或者由于版权问题放置于可选插件包中，不会直接加载，如
果需要使用，将可选插件中的jar包拷贝到plugins包下。

由于没有修改agent探针中的应用名，所以默认显示的是Your_ApplicationName。我们修改下应用名
称，让他显示的更加正确。编辑agent配置文件：

```
cd /usr/local/skywalking/apache-skywalking-apm-bin/agent/config 
vi agent.config
```

我们在配置中找到这么一行：

```
# The service name in UI 
agent.service_name=${SW_AGENT_NAME:Your_ApplicationName}
```

这里的配置含义是可以读取到SW_AGENT_NAME配置属性，如果该配置没有指定，那么默认名称为
Your_ApplicationName。这里我们把Your_ApplicationName替换成skywalking_tomcat。

```
# The service name in UI 
agent.service_name=${SW_AGENT_NAME:skywalking_tomcat}
```

然后将tomcat重启:

```
./shutdown.sh 
./startup.sh
```

#### Linux 下Tomcat7和8中使用

1.要使用Skywalking监控Tomcat中的应用，需要先准备一个Spring Mvc项目，在资源中已经提供了打
包好的文件

skywalking_springmvc-1.0-SNAPSHOT.war