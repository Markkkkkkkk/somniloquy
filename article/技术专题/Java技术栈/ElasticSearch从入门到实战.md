## Elasticsearch简介

### 介绍

1. 创始人：Shay Banon （谢巴农）
2. Elasticsearch是一个基于Lucene的搜索服务器
3. 提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口
4. Elasticsearch是用Java语言开发的，并作为Apache许可条款下的开放源码发布，是一种流行的企业级搜索引擎。Elasticsearch用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。官方客户端在Java、.NET（C#）、PHP、Python、Apache Groovy、Ruby和许多其他语言中都是可用的
5. 根据DB-Engines的排名显示，Elasticsearch是最受欢迎的企业搜索引擎，其次是Apache Solr，也是基于Lucene。

![image.png](https://image.hyly.net/i/2025/09/25/e670e34226a5763fc79b229cc72b85a5-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/ab4457aece13875cd7b34e98fd6af8ae-0.webp)

### Elasticsearch可以做什么

#### 信息检索

![image.png](https://image.hyly.net/i/2025/09/25/92aea104655e2fae64b272036905f2ed-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/37083b797f121724f761aa10d2e8bbe9-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/dc378f4e0c90fbe57f7fbb7e9c806b27-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/b64e36dc6a7f7d36c6cf363c72145e28-0.webp)

#### 企业内部系统搜索

关系型数据库使用like进行模糊检索，会导致索引失效，效率低下

![image.png](https://image.hyly.net/i/2025/09/25/24b10be75751b7ce828e662aa0f98d8f-0.webp)

#### 数据分析引擎

Elasticsearch 聚合可以对数十亿行日志数据进行聚合分析，探索数据的趋势和规律。

### Elasticsearch特点

#### 海量数据处理

1. 大型分布式集群（数百台规模服务器）
2. 处理PB级数据
3. 小公司也可以进行单机部署

#### 开箱即用

1. 简单易用，操作非常简单
2. 快速部署生产环境

#### 作为传统数据库的补充

1. 传统关系型数据库不擅长全文检索（MySQL自带的全文索引，与ES性能差距非常大）
2. 传统关系型数据库无法支持搜索排名、海量数据存储、分析等功能
3. Elasticsearch可以作为传统关系数据库的补充，提供RDBM无法提供的功能

### ElasticSearch使用案例

1. 2013年初，GitHub抛弃了Solr，采取ElasticSearch 来做PB级的搜索。 “GitHub使用ElasticSearch搜索20TB的数据，包括13亿文件和1300亿行代码”
2. 维基百科：启动以elasticsearch为基础的核心搜索架构
3. SoundCloud：“SoundCloud使用ElasticSearch为1.8亿用户提供即时而精准的音乐搜索服务”
4. 百度：百度目前广泛使用ElasticSearch作为文本数据分析，采集百度所有服务器上的各类指标数据及用户自定义数据，通过对各种数据进行多维分析展示，辅助定位分析实例异常或业务层面异常。目前覆盖百度内部20多个业务线（包括casio、云分析、网盟、预测、文库、直达号、钱包、风控等），单集群最大100台机器，200个ES节点，每天导入30TB+数据
5. 新浪使用ES 分析处理32亿条实时日志
6. 阿里使用ES 构建挖财自己的日志采集和分析体系

### ElasticSearch对比Solr

1. Solr 利用 Zookeeper 进行分布式管理，而 Elasticsearch 自身带有分布式协调管理功能;
2. Solr 支持更多格式的数据，而 Elasticsearch 仅支持json文件格式；
3. Solr 官方提供的功能更多，而 Elasticsearch 本身更注重于核心功能，高级功能多有第三方插件提供；
4. Solr 在传统的搜索应用中表现好于 Elasticsearch，但在处理实时搜索应用时效率明显低于 Elasticsearch

## Lucene简介

![image.png](https://image.hyly.net/i/2025/09/25/ebbe658a80f8ec107e2aff7fcb723332-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/3b3813914038f6e0e65acd2e3dcdd7b8-0.webp)

1. Lucene是一种高性能的全文检索库，在2000年开源，最初由大名鼎鼎的Doug Cutting（道格·卡丁）开发
2. Lucene是Apache的一个顶级开源项目，是一个全文检索引擎工具包。但Lucene不是一个完整的全文检索引擎，它只是提供一个基本的全文检索的架构，还提供了一些基本的文本分词库
3. Lucene是一个简单易用的工具包，可以方便的实现全文检索的功能

### 如何实现搜索功能？

**关系型数据库：**性能差、不可靠、结果不准确（相关度低）。特别是文本类的查询。主要是基于B+tree，B-Tree结构图中可以看到每个节点中不仅包含数据的key值，还有data值。而每一个页的存储空间是有限的，如果data数据较大时将会导致每个节点（即一个页）能存储的key的数量很小，当存储的数据量很大时同样会导致B-Tree的深度较大，增大查询时的磁盘I/O次数，进而影响查询效率。在B+Tree中，所有数据记录节点都是按照键值大小顺序存放在同一层的叶子节点上，而非叶子节点上只存储key值信息，这样可以大大加大每个节点存储的key值数量，降低B+Tree的高度。

B+Tree相对于B-Tree有几点不同：

1. 非叶子节点只存储键值信息。
2. 所有叶子节点之间都有一个链指针。
3. 数据记录都存放在叶子节点中。

将上一节中的B-Tree优化，由于B+Tree的非叶子节点只存储键值信息，假设每个磁盘块能存储4个键值及指针信息，则变成B+Tree后其结构如下图所示

![image.png](https://image.hyly.net/i/2025/09/25/2d75d294af05a77713177f4acdecf65a-0.webp)

**正排索引：**由Key到value。

**倒排索引：**由value到key。

当用户在主页上搜索关键词“华为手机”时，假设只存在正向索引（forward index），那么就需要扫描索引库中的所有文档，找出所有包含关键词“华为手机”的文档，再根据打分模型进行打分，排出名次后呈现给用户。因为互联网上收录在搜索引擎中的文档的数目是个天文数字，这样的索引结构根本无法满足实时返回排名结果的要求。

所以，搜索引擎会将正向索引重新构建为倒排索引，即把文件ID对应到关键词的映射转换为关键词到文件ID的映射，每个关键词都对应着一系列的文件，这些文件中都出现这个关键词。

![image.png](https://image.hyly.net/i/2025/09/25/3c1cd6b61e48efeb383852f7f8279ea7-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/91f6819a3f78098113084e5cedff1606-0.webp)

**ElasticSearch的数据结构：**

**单词ID**：记录每个单词的单词编号；

**单词**：对应的单词；

**文档频率**：代表文档集合中有多少个文档包含某个单词

**倒排列表**：包含单词ID及其他必要信息

**DocId**：单词出现的文档id

**TF**：单词在某个文档中出现的次数

**POS**：单词在文档中出现的位置

以单词“加盟”为例，其单词编号为6，文档频率为3，代表整个文档集合中有三个文档包含这个单词，对应的倒排列表为{(2;1;&#x3c;4>),(3;1;&#x3c;7>),(5;1;&#x3c;5>)}，含义是在文档2，3，5出现过这个单词，在每个文档的出现过1次，单词“加盟”在第一个文档的POS是4，即文档的第四个单词是“加盟”，其他的类似。
这个倒排索引已经是一个非常完备的索引系统，实际搜索系统的索引结构基本如此。

### 倒排索引结构

倒排索引是一种建立索引的方法。是全文检索系统中常用的数据结构。通过倒排索引，就是根据单词快速获取包含这个单词的文档列表。倒排索引通常由两个部分组成：单词词典、文档。

![image.png](https://image.hyly.net/i/2025/09/25/213fa3844d43b4eb07f76090d1c1bd54-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/887dd4e162ca1648a8313bed217698ab-0.webp)

Lucene 的倒排索，增加了最左边的一层「字典树」term index，它不存储所有的单词，只存储单词前缀，通过字典树找到单词所在的块，也就是单词的大概位置，再在块里二分查找，找到对应的单词，再找到单词对应的文档列表。

当然，内存寸土寸金，能省则省，所以 Lucene 还用了 FST（Finite State Transducers）对它进一步压缩。

FST 是什么？这里就不展开了，这次重点想聊的，是最右边的 Posting List 的，别看它只是存一个文档 ID 数组，但是它在设计时，遇到的问题可不少。如何压缩以节省磁盘空间。如何快速求交并集。Frame Of Reference(FOR)解决了这两个问题。

### 企业中为什么不直接使用Lucene

#### Lucene的内建不支持分布式

Lucene是作为嵌入的类库形式使用的，本身是没有对分布式支持。

#### 区间范围搜索速度非常缓慢

1. Lucene的区间范围搜索API是扩展补充的，对于在单个文档中term出现比较多的情况，搜索速度会变得很慢
2. Lucene只有在数据生成索引文件之后（Segment），才能被查询到，做不到实时

#### 可靠性无法保障

无法保障Segment索引段的可靠性

## Elasticsearch中的核心概念

### 索引 index（相当于数据库中的表）

1. 一个索引就是一个拥有几分相似特征的文档的集合。比如说，可以有一个客户数据的索引，另一个产品目录的索引，还有一个订单数据的索引
2. 一个索引由一个名字来标识（必须全部是小写字母的），并且当我们要对对应于这个索引中的文档进行索引、搜索、更新和删除的时候，都要使用到这个名字
3. 在一个集群中，可以定义任意多的索引。

### 映射 mapping(相当于数据中的schema)

1. ElasticSearch中的映射（Mapping）用来定义一个文档
2. mapping是处理数据的方式和规则方面做一些限制，如某个字段的数据类型、默认值、分析器、是否被索引等等，这些都是映射里面可以设置的

### 字段Field

相当于是数据表的字段，对文档数据根据不同属性进行的分类标识

### 类型 Type

每一个字段都应该有一个对应的类型，例如：Text、Keyword、Byte等

### 文档 document（相当于数据库表中的一条记录）

一个文档是一个可被索引的基础信息单元。比如，可以拥有某一个客户的文档，某一个产品的一个文档，当然，也可以拥有某个订单的一个文档。文档以JSON（Javascript Object Notation）格式来表示，而JSON是一个到处存在的互联网数据交互格式

### 集群 cluster

1. 一个集群就是由一个或多个节点组织在一起，它们共同持有整个的数据，并一起提供索引和搜索功能
2. 一个集群由一个唯一的名字标识，这个名字默认就是“elasticsearch”
3. 这个名字是重要的，因为一个节点只能通过指定某个集群的名字，来加入这个集群

### 节点 node

1. 一个节点是集群中的一个服务器，作为集群的一部分，它存储数据，参与集群的索引和搜索功能
2. 一个节点可以通过配置集群名称的方式来加入一个指定的集群。默认情况下，每个节点都会被安排加入到一个叫做“elasticsearch”的集群中
3. 这意味着，如果在网络中启动了若干个节点，并假定它们能够相互发现彼此，它们将会自动地形成并加入到一个叫做“elasticsearch”的集群中
4. 在一个集群里，可以拥有任意多个节点。而且，如果当前网络中没有运行任何Elasticsearch节点，这时启动一个节点，会默认创建并加入一个叫做“elasticsearch”的集群。

### 分片和副本 shards&replicas

#### 分片

1. 一个索引可以存储超出单个结点硬件限制的大量数据。比如，一个具有10亿文档的索引占据1TB的磁盘空间，而任一节点都没有这样大的磁盘空间；或者单个节点处理搜索请求，响应太慢
2. 为了解决这个问题，Elasticsearch提供了将索引划分成多份的能力，这些份就叫做分片
3. 当创建一个索引的时候，可以指定你想要的分片的数量
4. 每个分片本身也是一个功能完善并且独立的“索引”，这个“索引”可以被放置到集群中的任何节点上
5. 分片很重要，主要有两方面的原因
	1. 允许水平分割/扩展你的内容容量
	2. 允许在分片之上进行分布式的、并行的操作，进而提高性能/吞吐量
6. 至于一个分片怎样分布，它的文档怎样聚合回搜索请求，是完全由Elasticsearch管理的，对于作为用户来说，这些都是透明的

#### 副本

1. 在一个网络/云的环境里，失败随时都可能发生，在某个分片/节点不知怎么的就处于离线状态，或者由于任何原因消失了，这种情况下，有一个故障转移机制是非常有用并且是强烈推荐的。为此目的，Elasticsearch允许你创建分片的一份或多份拷贝，这些拷贝叫做副本分片，或者直接叫副本
2. 副本之所以重要，有两个主要原因
	1. 在分片/节点失败的情况下，提供了高可用性。注意到复制分片从不与原/主要（original/primary）分片置于同一节点上是非常重要的
	2. 扩展搜索量/吞吐量，因为搜索可以在所有的副本上并行运行
3. 每个索引可以被分成多个分片。一个索引有0个或者多个副本
4. 一旦设置了副本，每个索引就有了主分片和副本分片，分片和副本的数量可以在索引创建的时候指定
5. 在索引创建之后，可以在任何时候动态地改变副本的数量，但是不能改变分片的数量

## 安装Elasticsearch

### 安装Elasticsearch

#### 创建普通用户

**ES不能使用root用户来启动，必须使用普通用户来安装启动** 。这里我们创建一个普通用户以及定义一些常规目录用于存放我们的数据文件以及安装包等。

创建一个es专门的用户（ **必须** ）

```
## 使用root用户在三台机器执行以下命令
useradd itcast 
passwd itcast
```

**这里可以使用老师提供的虚拟机中的itcast用户，密码也是i** **tcast** **。**

#### 为普通用户itcast添加sudo权限

为了让普通用户有更大的操作权限，我们一般都会给普通用户设置sudo权限，方便普通用户的操作
三台机器使用root用户执行visudo命令然后为es用户添加权限

```
visudo
## 第100行
itcast      ALL=(ALL)       ALL
```

#### 上传压缩包并解压

将es的安装包下载并上传到node1.itcast.cn服务器的/export/software路径下，然后进行解压
使用itcast用户来执行以下操作，将es安装包上传到node1.itcast.cn服务器，并使用es用户执行以下命令解压。

```
## 在node1.itcast.cn、node2.itcast.cn、node3.itcast.cn创建es文件夹，并修改owner为itcast用户
mkdir -p /export/server/es
chown -R itcast /export/server/es

## 解压Elasticsearch
su itcast
cd /export/software/
tar -zvxf elasticsearch-7.6.1-linux-x86_64.tar.gz -C /export/server/es/
```

#### 修改配置文件

##### 修改elasticsearch.yml

node1.itcast.cn服务器使用itcast用户来修改配置文件

```
cd /export/server/es/elasticsearch-7.6.1/config
mkdir -p /export/server/es/elasticsearch-7.6.1/log
mkdir -p /export/server/es/elasticsearch-7.6.1/data
rm -rf elasticsearch.yml

vim elasticsearch.yml
cluster.name: itcast-es
node.name: node1.itcast.cn
path.data: /export/server/es/elasticsearch-7.6.1/data
path.logs: /export/server/es/elasticsearch-7.6.1/log
network.host: node1.itcast.cn
http.port: 9200
discovery.seed_hosts: ["node1.itcast.cn", "node2.itcast.cn", "node3.itcast.cn"]
cluster.initial_master_nodes: ["node1.itcast.cn", "node2.itcast.cn"]
bootstrap.system_call_filter: false
bootstrap.memory_lock: false
http.cors.enabled: true
http.cors.allow-origin: "*"
```

##### 修改jvm.option

修改jvm.option配置文件，调整jvm堆内存大小
node1.itcast.cn使用itcast用户执行以下命令调整jvm堆内存大小，每个人根据自己服务器的内存大小来进行调整。

```
cd /export/server/es/elasticsearch-7.6.1/config
vim jvm.options
-Xms2g
-Xmx2g
```

#### 将安装包分发到其他服务器上面

node1.itcast.cn使用itcast用户将安装包分发到其他服务器上面去

```
cd /export/server/es/
scp -r elasticsearch-7.6.1/ node2.itcast.cn:$PWD
scp -r elasticsearch-7.6.1/ node3.itcast.cn:$PWD
```

#### node2.itcast.cn与node3.itcast.cn修改es配置文件

node2.itcast.cn与node3.itcast.cn也需要修改es配置文件
node2.itcast.cn使用itcast用户执行以下命令修改es配置文件

```
cd /export/server/es/elasticsearch-7.6.1/config
mkdir -p /export/server/es/elasticsearch-7.6.1/log
mkdir -p /export/server/es/elasticsearch-7.6.1/data

vim elasticsearch.yml
cluster.name: itcast-es
node.name: node2.itcast.cn
path.data: /export/server/es/elasticsearch-7.6.1/data
path.logs: /export/server/es/elasticsearch-7.6.1/log
network.host: node2.itcast.cn
http.port: 9200
discovery.seed_hosts: ["node1.itcast.cn", "node2.itcast.cn", "node3.itcast.cn"]
cluster.initial_master_nodes: ["node1.itcast.cn", "node2.itcast.cn"]
bootstrap.system_call_filter: false
bootstrap.memory_lock: false
http.cors.enabled: true
http.cors.allow-origin: "*"
```

node3.itcast.cn使用itcast用户执行以下命令修改配置文件

```
cd /export/server/es/elasticsearch-7.6.1/config
mkdir -p /export/server/es/elasticsearch-7.6.1/log
mkdir -p /export/server/es/elasticsearch-7.6.1/data

vim elasticsearch.yml
cluster.name: itcast-es
node.name: node3.itcast.cn
path.data: /export/server/es/elasticsearch-7.6.1/data
path.logs: /export/server/es/elasticsearch-7.6.1/log
network.host: node3.itcast.cn
http.port: 9200
discovery.seed_hosts: ["node1.itcast.cn", "node2.itcast.cn", "node3.itcast.cn"]
cluster.initial_master_nodes: ["node1.itcast.cn", "node2.itcast.cn"]
bootstrap.system_call_filter: false
bootstrap.memory_lock: false
http.cors.enabled: true
http.cors.allow-origin: "*"
```

#### 修改系统配置，解决启动时候的问题

由于现在使用普通用户来安装es服务，且es服务对服务器的资源要求比较多，包括内存大小，线程数等。所以我们需要给普通用户解开资源的束缚

##### 普通用户打开文件的最大数限制

**问题错误信息描述：
max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]**
ES因为需要大量的创建索引文件，需要大量的打开系统的文件，所以我们需要解除linux系统当中打开文件最大数目的限制，不然ES启动就会抛错
**三台机器使用itcast用户执行以下命令解除打开文件数据的限制**
sudo vi /etc/security/limits.conf
添加如下内容: 注意*不要去掉了

```
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096
```

**此文件修改后需要重新登录用户，才会生效**

##### 普通用户启动线程数限制

**问题错误信息描述
max number of threads [1024] for user [es] likely too low, increase to at least [4096]**
修改普通用户可以创建的最大线程数
max number of threads [1024] for user [es] likely too low, increase to at least [4096]
原因：无法创建本地线程问题,用户最大可创建线程数太小
解决方案：修改90-nproc.conf 配置文件。
三台机器使用itcast用户执行以下命令修改配置文件

```
Centos6
sudo vi /etc/security/limits.d/90-nproc.conf
Centos7
sudo vi /etc/security/limits.d/20-nproc.conf
```

找到如下内容：

* soft nproc 1024
	#修改为
* soft nproc 4096

##### 普通用户调大虚拟内存

**错误信息描述：
max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]**
调大系统的虚拟内存
原因：最大虚拟内存太小
每次启动机器都手动执行下。
三台机器执行以下命令

```
sudo  sysctl -w vm.max_map_count=262144  

sudo vim /etc/sysctl.conf
在最后添加一行
vm.max_map_count=262144   
```

**备注：以上三个问题解决完成之后，重新连接secureCRT或者重新连接xshell生效**

#### 启动ES服务

三台机器使用itcast用户执行以下命令启动es服务
nohup /export/server/es/elasticsearch-7.6.1/bin/elasticsearch 2>&1 &
启动成功之后jsp即可看到es的服务进程，并且访问页面
http://node1.itcast.cn:9200/?pretty
能够看到es启动之后的一些信息
注意：如果哪一台机器服务启动失败，那么就到哪一台机器的
/export/server/es/elasticsearch-7.6.1/log
这个路径下面去查看错误日志

### Elasticsearch-head插件

1. 由于es服务启动之后，访问界面比较丑陋，为了更好的查看索引库当中的信息，我们可以通过安装elasticsearch-head这个插件来实现，这个插件可以更方便快捷的看到es的管理界面
2. elasticsearch-head这个插件是es提供的一个用于图形化界面查看的一个插件工具，可以安装上这个插件之后，通过这个插件来实现我们通过浏览器查看es当中的数据
3. 安装elasticsearch-head这个插件这里提供两种方式进行安装，第一种方式就是自己下载源码包进行编译，耗时比较长，网络较差的情况下，基本上不可能安装成功。第二种方式就是直接使用我已经编译好的安装包，进行修改配置即可
4. 要安装elasticsearch-head插件，需要先安装Node.js

#### 安装nodejs

Node.js是一个基于 Chrome V8 引擎的 JavaScript 运行环境。

Node.js是一个Javascript运行环境(runtime environment)，发布于2009年5月，由Ryan Dahl开发，实质是对Chrome V8引擎进行了封装。Node.js 不是一个 JavaScript 框架，不同于CakePHP、Django、Rails。Node.js 更不是浏览器端的库，不能与 jQuery、ExtJS 相提并论。Node.js 是一个让 JavaScript 运行在服务端的开发平台，它让 JavaScript 成为与PHP、Python、Perl、Ruby 等服务端语言平起平坐的脚本语言。

安装步骤参考：[https://www.cnblogs.com/kevingrace/p/8990169.html](https://www.cnblogs.com/kevingrace/p/8990169.html)

##### 下载安装包

node1.itcast.cn机器执行以下命令下载安装包，然后进行解压

```
cd /export/software
wget https://npm.taobao.org/mirrors/node/v8.1.0/node-v8.1.0-linux-x64.tar.gz
tar -zxvf node-v8.1.0-linux-x64.tar.gz -C /export/server/es/
```

##### 创建软连接

node1.itcast.cn执行以下命令创建软连接

```
sudo ln -s /export/server/es/node-v8.1.0-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
sudo ln -s /export/server/es/node-v8.1.0-linux-x64/bin/node /usr/local/bin/node
```

##### 修改环境变量

node1.itcast.cn服务器添加环境变量

```
vim /etc/profile
export NODE_HOME=/export/server/es/node-v8.1.0-linux-x64
export PATH=:$PATH:$NODE_HOME/bin
```

修改完环境变量使用source生效

```
source /etc/profile
```

##### 验证安装成功

node1.itcast.cn执行以下命令验证安装生效

```
node -v
npm -v
```

#### 在线安装（网速慢，不推荐）

这里选择node1.itcast.cn进行安装

##### 在线安装必须依赖包

```
## 初始化目录
cd /export/servers/es
## 安装GCC
sudo yum install -y gcc-c++ make git
```

##### 从git上面克隆编译包并进行安装

```
cd /export/servers/es
git clone https://github.com/mobz/elasticsearch-head.git
## 进入安装目录
cd /export/servers/es/elasticsearch-head
## intall 才会有 node-modules
npm install
```

![image.png](https://image.hyly.net/i/2025/09/25/7cdc50ed0b8fa17276ea0cfa1616c097-0.webp)

```
以下进度信息
npm WARN notice [SECURITY] lodash has the following vulnerability: 1 low. Go here for more details: 
npm WARN notice [SECURITY] debug has the following vulnerability: 1 low. Go here for more details: https://nodesecurity.io/advisories?search=debug&version=0.7.4 - Run `npm i npm@latest -g` to upgrade your npm version, and then `npm audit` to get more info.
npm ERR! Unexpected end of input at 1:2096
npm ERR! 7c1a1bc21c976bb49f3ea","tarball":"https://registry.npmjs.org/safer-bu
npm ERR!                                                                      ^
npm ERR! A complete log of this run can be found in:
npm ERR!     /home/es/.npm/_logs/2018-11-27T14_35_39_453Z-debug.log
以上错误可以不用管。
```

##### 4.2.2.3 node1机器修改Gruntfile.js

第一台机器修改Gruntfile.js这个文件

```json
cd /export/servers/es/elasticsearch-head
vim Gruntfile.js
找到以下代码：
添加一行： hostname: '192.168.52.100',

connect: {
                        server: {
                              options: {
                                     hostname: '192.168.52.100',
                                     port: 9100,
                                     base: '.',
                                     keepalive: travelue
                                }
                        }
                }
```

##### node01机器修改app.js

第一台机器修改app.js

```
cd /export/servers/es/elasticsearch-head/_site
vim app.js 
```

![image.png](https://image.hyly.net/i/2025/09/25/cdf969a75f0702b0bce9ad062f0895cc-0.webp)

更改前：http://localhost:9200
更改后：http://node01:9200

#### 本地安装（推荐）

##### 上传压缩包到/export/software路径下去

将我们的压缩包  elasticsearch-head-compile-after.tar.gz  上传到node1.itcast.cn机器的/export/software 路径下面去

##### 解压安装包

node1.itcast.cn执行以下命令解压安装包

```
cd /export/software/
tar -zxvf elasticsearch-head-compile-after.tar.gz -C /export/server/es/
```

##### node1机器修改Gruntfile.js

修改Gruntfile.js这个文件

```
cd /export/server/es/elasticsearch-head
vim Gruntfile.js
```

找到代码中的93行：hostname: '192.168.100.100', 修改为：node1.itcast.cn

```json
connect: {
                        server: {
                              options: {
                                     hostname: 'node1.itcast.cn',
                                     port: 9100,
                                     base: '.',
                                     keepalive: true
                                }
                        }
                }
```

##### node1机器修改app.js

第一台机器修改app.js

```
cd /export/server/es/elasticsearch-head/_site
vim app.js
```

在Vim中输入「:4354」，定位到第4354行，修改 http://localhost:9200为http://node1.itcast.cn:9200。

![image.png](https://image.hyly.net/i/2025/09/25/5c8acedfe8b25d5deb52d549f565a156-0.webp)

##### 启动head服务

```
node1.itcast.cn启动elasticsearch-head插件
cd /export/server/es/elasticsearch-head/node_modules/grunt/bin/
进程前台启动命令
./grunt server
进程后台启动命令
nohup ./grunt server >/dev/null 2>&1 &

Running "connect:server" (connect) task
Waiting forever...
Started connect web server on http://192.168.52.100:9100
如何停止：elasticsearch-head进程
执行以下命令找到elasticsearch-head的插件进程，然后使用kill  -9  杀死进程即可
netstat -nltp | grep 9100
kill -9 8328
```

![image.png](https://image.hyly.net/i/2025/09/25/875d00ca6885cd4aaf3be38df7048b60-0.webp)

#### 访问elasticsearch-head界面

打开Google Chrome访问
http://node1.itcast.cn:9100/

![image.png](https://image.hyly.net/i/2025/09/25/1c60d3ed7959f9f3f807817d259ab3b0-0.webp)

### 安装IK分词器

我们后续也需要使用Elasticsearch来进行中文分词，所以需要单独给Elasticsearch安装IK分词器插件。以下为具体安装步骤：
1.下载Elasticsearch IK分词器
https://github.com/medcl/elasticsearch-analysis-ik/releases
2.切换到itcast用户，并在es的安装目录下/plugins创建ik

```
mkdir -p /export/server/es/elasticsearch-7.6.1/plugins/ik
```

3.将下载的ik分词器上传并解压到该目录

```
cd /export/server/es/elasticsearch-7.6.1/plugins/ik
sudo rz 
unzip elasticsearch-analysis-ik-7.6.1.zip 
```

4.将plugins下的ik目录分发到每一台服务器

```
cd /export/server/es/elasticsearch-7.6.1/plugins
scp -r ik/ node2.itcast.cn:$PWD
scp -r ik/ node3.itcast.cn:$PWD
```

5.重启Elasticsearch

### 准备VSCode开发环境

在VScode中安装Elasticsearch for VScode插件。该插件可以直接与Elasticsearch交互，开发起来非常方便。
1.打开VSCode，在应用商店中搜索elasticsearch，找到Elasticsearch for VSCode

![image.png](https://image.hyly.net/i/2025/09/25/dd44f232b9d7ebc7e2f4c59c19d5710c-0.webp)

2.点击安装即可

### 测试分词器

1.打开VSCode
2.新建一个文件，命名为 0.IK分词器测试.es
3.右键点击 命令面板 菜单

![image.png](https://image.hyly.net/i/2025/09/25/bb647916d390d28c74c17e05e2487ae4-0.webp)

4.选择ES:Elastic: Set Host，然后输入Elasticsearch的机器名和端口号。

![image.png](https://image.hyly.net/i/2025/09/25/e2d432d06220d6b7f32a080040ad4419-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/e2174b268ff35b6b8ab70c45cae192b9-0.webp)

5.将以下内容复制到ES中，并测试。

Standard标准分词器：

```
post _analyze 
{
    "analyzer":"standard", 
    "text":"我爱你中国"
}
```

能看出来Standard标准分词器，是一个个将文字切分。并不是我们想要的结果。

IK分词器：

```
post _analyze 
{
    "analyzer":"ik_max_word", 
    "text":"我爱你中国"
}
```

IK分词器，切分为了“我爱你”、“爱你”、“中国”，这是我们想要的效果。

注意：
analyzer中的单词一定要写对，不能带有多余的空格，否则会报错：找不到对应名字的解析器。

## 猎聘网职位搜索案例

### 需求

![image.png](https://image.hyly.net/i/2025/09/25/08cfd40cc0c304e9a4c4ac1459431b08-0.webp)

本次案例，要实现一个类似于猎聘网的案例，用户通过搜索相关的职位关键字，就可以搜索到相关的工作岗位。我们已经提前准备好了一些数据，这些数据是通过爬虫爬取的数据，这些数据存储在CSV文本文件中。我们需要基于这些数据建立索引，供用户搜索查询。

#### 数据集介绍

<figure class='table-figure'><table>
<thead>
<tr><th><strong>字段名</strong></th><th><strong>说明</strong></th><th><strong>数据</strong></th></tr></thead>
<tbody><tr><td>doc_id</td><td>唯一标识（作为文档ID）</td><td>29097</td></tr><tr><td>area</td><td>职位所在区域</td><td>工作地区：深圳-南山区</td></tr><tr><td>exp</td><td>岗位要求的工作经验</td><td>1年经验</td></tr><tr><td>edu</td><td>学历要求</td><td>大专以上</td></tr><tr><td>salary</td><td>薪资范围</td><td>¥ 6-8千/月</td></tr><tr><td>job_type</td><td>职位类型（全职/兼职）</td><td>实习</td></tr><tr><td>cmp</td><td>公司名</td><td>乐有家</td></tr><tr><td>pv</td><td>浏览量</td><td>61.6万人浏览过  / 14人评价  / 113人正在关注</td></tr><tr><td>title</td><td>岗位名称</td><td>桃园深大销售实习岗前培训</td></tr><tr><td>jd</td><td>职位描述</td><td>【薪酬待遇】本科薪酬7500起 大专薪酬6800起 以上无业绩要求，同时享有业绩核算比例55%~80% 人均月收入超1.3万 【岗位职责】 1.爱学习，有耐心： 通过公司系统化培训熟悉房地产基本业务及相关法律、金融知识，不功利服务客户，耐心为客户在房产交易中遇到的各类问题； 2.会聆听，会提问： 详细了解客户的核心诉求，精准匹配合适的产品信息，具备和用户良好的沟通能力，有团队协作意识和服务意识； 3.爱琢磨，</td></tr></tbody>
</table></figure>

### 创建索引

为了能够搜索职位数据，我们需要提前在Elasticsearch中创建索引，然后才能进行关键字的检索。这里先回顾下，我们在MySQL中创建表的过程。在MySQL中，如果我们要创建一个表，我们需要指定表的名字，指定表中有哪些列、列的类型是什么。同样，在Elasticsearch中，也可以使用类似的方式来定义索引。

#### 创建带有映射的索引

Elasticsearch中，我们可以使用RESTful API（http请求）来进行索引的各种操作。创建MySQL表的时候，我们使用DDL来描述表结构、字段、字段类型、约束等。在Elasticsearch中，我们使用Elasticsearch的DSL来定义——使用JSON来描述。例如：

```
PUT /my-index
{
    "mapping": {
        "properties": {
            "employee-id": {
                "type": "keyword",
                "index": false
            }
        }
    }
}
```

![image.png](https://image.hyly.net/i/2025/09/25/857e78883e5c9ca09f62a3beb3e13cc5-0.webp)

#### 字段的类型

在Elasticsearch中，每一个字段都有一个类型（type）。以下为Elasticsearch中可以使用的类型：

<figure class='table-figure'><table>
<thead>
<tr><th>分类</th><th>类型名称</th><th>说明</th></tr></thead>
<tbody><tr><td>简单类型</td><td>text</td><td>需要进行全文检索的字段，通常使用text类型来对应邮件的正文、产品描述或者短文等<strong>非结构化文本数据</strong> 。分词器先会将文本进行分词转换为词条列表。将来就可以基于词条来进行检索了。文本字段不能用户排序、也很少用户聚合计算。</td></tr><tr><td>&nbsp;</td><td>keyword</td><td>使用keyword来对应<strong>结构化的数据</strong> ，如ID、电子邮件地址、主机名、状态代码、邮政编码或标签。可以使用keyword来进行排序或聚合计算。注意：<strong>keyword是不能进行分词的。</strong></td></tr><tr><td>&nbsp;</td><td>date</td><td>保存格式化的日期数据，例如：2015-01-01或者2015/01/01 12:10:30。在Elasticsearch中，日期都将以字符串方式展示。可以给date指定格式：”format”: “yyyy-MM-dd HH:mm:ss”</td></tr><tr><td>&nbsp;</td><td>long/integer/short/byte</td><td>64位整数/32位整数/16位整数/8位整数</td></tr><tr><td>&nbsp;</td><td>double/float/half_float</td><td>64位双精度浮点/32位单精度浮点/16位半进度浮点</td></tr><tr><td>&nbsp;</td><td>boolean</td><td>“true”/”false”</td></tr><tr><td>&nbsp;</td><td>ip</td><td>IPV4（192.168.1.110）/IPV6（192.168.0.0/16）</td></tr><tr><td>JSON分层嵌套类型</td><td>object</td><td>用于保存JSON对象</td></tr><tr><td>&nbsp;</td><td>nested</td><td>用于保存JSON数组</td></tr><tr><td>特殊类型</td><td>geo_point</td><td>用于保存经纬度坐标</td></tr><tr><td>&nbsp;</td><td>geo_shape</td><td>用于保存地图上的多边形坐标</td></tr></tbody>
</table></figure>

#### 创建保存职位信息的索引

1.使用PUT发送PUT请求
2.索引名为 /job_idx
3.判断是使用text、还是keyword，主要就看是否需要分词

<figure class='table-figure'><table>
<thead>
<tr><th>字段</th><th>类型</th></tr></thead>
<tbody><tr><td>area</td><td>text</td></tr><tr><td>exp</td><td>text</td></tr><tr><td>edu</td><td>keyword</td></tr><tr><td>salary</td><td>keyword</td></tr><tr><td>job_type</td><td>keyword</td></tr><tr><td>cmp</td><td>text</td></tr><tr><td>pv</td><td>keyword</td></tr><tr><td>title</td><td>text</td></tr><tr><td>jd</td><td>text</td></tr></tbody>
</table></figure>

创建索引：

```
PUT /job_idx
{
    "mappings": {
        "properties" : {
            "area": { "type": "text", "store": true},
            "exp": { "type": "text", "store": true},
            "edu": { "type": "keyword", "store": true},
            "salary": { "type": "keyword", "store": true},
            "job_type": { "type": "keyword", "store": true},
            "cmp": { "type": "text", "store": true},
            "pv": { "type": "keyword", "store": true},
            "title": { "type": "text", "store": true},
            "jd": { "type": "text", "store": true}
        }
    }
}
```

#### 查看索引映射

使用GET请求查看索引映射

```
// 查看索引映射
GET /job_idx/_mapping
```

使用head插件也可以查看到索引映射信息。

![image.png](https://image.hyly.net/i/2025/09/25/b1f4a9f2948ff1f3cd0a0cb7a8bedb5b-0.webp)

#### 查看Elasticsearch中的所有索引

```
GET _cat/indices
```

#### 删除索引

```
delete /job_idx
```

![image.png](https://image.hyly.net/i/2025/09/25/03613eacabd230a21e523bce59029770-0.webp)

#### 指定使用IK分词器

因为存放在索引库中的数据，是以中文的形式存储的。所以，为了有更好地分词效果，我们需要使用IK分词器来进行分词。这样，将来搜索的时候才会更准确。

```
PUT /job_idx
{
    "mappings": {
        "properties" : {
            "area": { "type": "text", "store": true, "analyzer": "ik_max_word"},
            "exp": { "type": "text", "store": true, "analyzer": "ik_max_word"},
            "edu": { "type": "keyword", "store": true},
            "salary": { "type": "keyword", "store": true},
            "job_type": { "type": "keyword", "store": true},
            "cmp": { "type": "text", "store": true, "analyzer": "ik_max_word"},
            "pv": { "type": "keyword", "store": true},
            "title": { "type": "text", "store": true, "analyzer": "ik_max_word"},
            "jd": { "type": "text", "store": true, "analyzer": "ik_max_word"}
        }
    }
}
```

### 添加一个职位数据

#### 需求

我们现在有一条职位数据，需要添加到Elasticsearch中，后续还需要能够在Elasticsearch中搜索这些数据。

```
29097,
工作地区：深圳-南山区,
1年经验,
大专以上,
¥ 6-8千/月,
实习,
乐有家,
61.6万人浏览过  / 14人评价  / 113人正在关注,
桃园 深大销售实习 岗前培训,
【薪酬待遇】 本科薪酬7500起 大专薪酬6800起 以上无业绩要求，同时享有业绩核算比例55%~80% 人均月收入超1.3万 【岗位职责】 1.爱学习，有耐心： 通过公司系统化培训熟悉房地产基本业务及相关法律、金融知识，不功利服务客户，耐心为客户在房产交易中遇到的各类问题； 2.会聆听，会提问： 详细了解客户的核心诉求，精准匹配合适的产品信息，具备和用户良好的沟通能力，有团队协作意识和服务意识； 3.爱琢磨，善思考: 热衷于用户心理研究，善于从用户数据中提炼用户需求，利用个性化、精细化运营手段，提升用户体验。 【岗位要求】 1.18-26周岁，自考大专以上学历； 2.具有良好的亲和力、理解能力、逻辑协调和沟通能力； 3.积极乐观开朗，为人诚实守信，工作积极主动，注重团队合作； 4.愿意服务于高端客户，并且通过与高端客户面对面沟通有意愿提升自己的综合能力； 5.愿意参加公益活动，具有爱心和感恩之心。 【培养路径】 1.上千堂课程;房产知识、营销知识、交易知识、法律法规、客户维护、目标管理、谈判技巧、心理学、经济学; 2.成长陪伴：一对一的师徒辅导 3.线上自主学习平台：乐有家学院，专业团队制作，每周大咖分享 4.储备及管理课堂： 干部训练营、月度/季度管理培训会 【晋升发展】 营销【精英】发展规划：A1置业顾问-A6资深置业专家 营销【管理】发展规划：（入职次月后就可竞聘） 置业顾问-置业经理-店长-营销副总经理-营销副总裁-营销总裁 内部【竞聘】公司职能岗位：如市场、渠道拓展中心、法务部、按揭经理等都是内部竞聘 【联系人】 黄媚主任15017903212（微信同号）
```

#### PUT请求

前面我们已经创建了索引。接下来，我们就可以往索引库中添加一些文档了。可以通过PUT请求直接完成该操作。在Elasticsearch中，每一个文档都有唯一的ID。也是使用JSON格式来描述数据。例如：

```
PUT /customer/_doc/1{
  "name": "John Doe"}
```

![image.png](https://image.hyly.net/i/2025/09/25/0c062a4bec63fb05bbc2e26f52c49f1b-0.webp)

如果在customer中，不存在ID为1的文档，Elasticsearch会自动创建

#### 添加职位信息请求

PUT请求：

```
PUT /job_idx/_doc/29097
{
    "area": "深圳-南山区",
    "exp": "1年经验",
    "edu": "大专以上",
    "salary": "6-8千/月",
    "job_type": "实习",
    "cmp": "乐有家",
    "pv": "61.6万人浏览过  / 14人评价  / 113人正在关注",
    "title": "桃园 深大销售实习 岗前培训",
    "jd": "薪酬待遇】 本科薪酬7500起 大专薪酬6800起 以上无业绩要求，同时享有业绩核算比例55%~80% 人均月收入超1.3万 【岗位职责】 1.爱学习，有耐心： 通过公司系统化培训熟悉房地产基本业务及相关法律、金融知识，不功利服务客户，耐心为客户在房产交易中遇到的各类问题； 2.会聆听，会提问： 详细了解客户的核心诉求，精准匹配合适的产品信息，具备和用户良好的沟通能力，有团队协作意识和服务意识； 3.爱琢磨，善思考: 热衷于用户心理研究，善于从用户数据中提炼用户需求，利用个性化、精细化运营手段，提升用户体验。 【岗位要求】 1.18-26周岁，自考大专以上学历； 2.具有良好的亲和力、理解能力、逻辑协调和沟通能力； 3.积极乐观开朗，为人诚实守信，工作积极主动，注重团队合作； 4.愿意服务于高端客户，并且通过与高端客户面对面沟通有意愿提升自己的综合能力； 5.愿意参加公益活动，具有爱心和感恩之心。 【培养路径】 1.上千堂课程;房产知识、营销知识、交易知识、法律法规、客户维护、目标管理、谈判技巧、心理学、经济学; 2.成长陪伴：一对一的师徒辅导 3.线上自主学习平台：乐有家学院，专业团队制作，每周大咖分享 4.储备及管理课堂： 干部训练营、月度/季度管理培训会 【晋升发展】 营销【精英】发展规划：A1置业顾问-A6资深置业专家 营销【管理】发展规划：（入职次月后就可竞聘） 置业顾问-置业经理-店长-营销副总经理-营销副总裁-营销总裁 内部【竞聘】公司职能岗位：如市场、渠道拓展中心、法务部、按揭经理等都是内部竞聘 【联系人】 黄媚主任15017903212（微信同号）"
}
```

Elasticsearch响应结果：

```
{
    "_index": "job_idx",
    "_type": "_doc",
    "_id": "29097",
    "_version": 1,
    "result": "created",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    },
    "_seq_no": 0,
    "_primary_term": 1
}
```

使用ES-head插件浏览数据：

![image.png](https://image.hyly.net/i/2025/09/25/5ec12671fca9ab2cc4870b157bda5978-0.webp)

### 修改职位薪资

#### 需求

因为公司招不来人，需要将原有的薪资6-8千/月，修改为15-20千/月

#### 执行update操作

```
POST /job_idx/_update/29097
{
    "doc": {
        "salary": "15-20千/月"
    }
}
```

### 删除一个职位数据

#### 需求

ID为29097的职位，已经被取消。所以，我们需要在索引库中也删除该岗位。

#### DELETE操作

```
DELETE /job_idx/_doc/29097
```

### 批量导入JSON数据

#### bulk导入

为了方便后面的测试，我们需要先提前导入一些测试数据到ES中。在资料文件夹中有一个job_info.json数据文件。我们可以使用Elasticsearch中自带的bulk接口来进行数据导入。

1.上传JSON数据文件到Linux
2.执行导入命令

```
curl -H "Content-Type: application/json" -XPOST "node1.itcast.cn:9200/job_idx/_bulk?pretty&refresh" --data-binary "@job_info.json"
```

#### 查看索引状态

```
GET _cat/indices?index=job_idx
```

通过执行以上请求，Elasticsearch返回数据如下：

```
[
    {
        "health": "green",
        "status": "open",
        "index": "job_idx",
        "uuid": "Yucc7A-TRPqnrnBg5SCfXw",
        "pri": "1",
        "rep": "1",
        "docs.count": "6765",
        "docs.deleted": "0",
        "store.size": "23.1mb",
        "pri.store.size": "11.5mb"
    }
]
```

![image.png](https://image.hyly.net/i/2025/09/25/dd7068168002a51bbee4a9aa4a134429-0.webp)

### 根据ID检索指定职位数据

#### 需求

用户提交一个文档ID，Elasticsearch将ID对应的文档直接返回给用户。

#### 实现

在Elasticsearch中，可以通过发送GET请求来实现文档的查询。

![image.png](https://image.hyly.net/i/2025/09/25/ccf594b27b86126b8f0da7154e2c932d-0.webp)

```
GET /job_idx/_search
{
    "query": {
        "ids": {
            "values": ["46313"]
        }
    }
}
```

### 根据关键字搜索数据

##### 需求

搜索职位中带有「销售」关键字的职位

##### 实现

检索jd中销售相关的岗位

```
GET  /job_idx/_search 
{
    "query": {
        "match": {
            "jd": "销售"
        }
    }
}
```

除了检索职位描述字段以外，我们还需要检索title中包含销售相关的职位，所以，我们需要进行多字段的组合查询。

```
GET  /job_idx/_search
{
    "query": {
        "multi_match": {
            "query": "销售",
            "fields": ["title", "jd"]
        }
    }
}
```

更多地查询：官方地址：

https://www.elastic.co/cn/webinars/getting-started-elasticsearch?baymax=rtp&elektra=docs&storm=top-video&iesrc=ctr

### 根据关键字分页搜索

在存在大量数据时，一般我们进行查询都需要进行分页查询。例如：我们指定页码、并指定每页显示多少条数据，然后Elasticsearch返回对应页码的数据。

#### 使用from和size来进行分页

在执行查询时，可以指定from（从第几条数据开始查起）和size（每页返回多少条）数据，就可以轻松完成分页。

from = (page – 1) * size

```
GET  /job_idx/_search
{
    "from": 0,
    "size": 5,
    "query": {
        "multi_match": {
            "query": "销售",
            "fields": ["title", "jd"]
        }
    }
}
```

#### 使用scroll方式进行分页

前面使用from和size方式，查询在1W-5W条数据以内都是OK的，但如果数据比较多的时候，会出现性能问题。Elasticsearch做了一个限制，不允许查询的是10000条以后的数据。如果要查询1W条以后的数据，需要使用Elasticsearch中提供的scroll游标来查询。

在进行大量分页时，每次分页都需要将要查询的数据进行重新排序，这样非常浪费性能。使用scroll是将要用的数据一次性排序好，然后分批取出。性能要比from + size好得多。使用scroll查询后，排序后的数据会保持一定的时间，后续的分页查询都从该快照取数据即可。

##### 第一次使用scroll分页查询

此处，我们让排序的数据保持1分钟，所以设置scroll为1m

```
GET /job_idx/_search?scroll=1m
{
    "query": {
        "multi_match": {
            "query": "销售",
            "fields": ["title", "jd"]
        }
    },
    "size": 100
}
执行后，我们注意到，在响应结果中有一项：
"_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAGgWT3NxUFZ2OXVRVjZ0bEIxZ0RGUjMtdw=="
后续，我们需要根据这个_scroll_id来进行查询
```

##### 第二次直接使用scroll id进行查询

```
GET _search/scroll?scroll=1m
{
    "scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAHEWS0VWb2dKZTVUZVdKMWJmS3lWQVY3QQ=="
}
```

## Elasticsearch编程

要将搜索的功能与前端对接，我们必须要使用Java代码来实现对Elasticsearch的操作。我们要使用一个JobService类来实现之前我们用RESTFul完成的操作。

官网API地址：
https://www.elastic.co/guide/en/elasticsearch/client/java-rest/7.6/java-rest-high.html

### 环境准备

#### 准备IDEA项目结构

1.创建elasticsearch_example项目
2.创建包结构如下所示

<figure class='table-figure'><table>
<thead>
<tr><th>包</th><th>说明</th></tr></thead>
<tbody><tr><td>cn.itcast.elasticsearch.entity</td><td>存放实体类</td></tr><tr><td>cn.itcast.elasticsearch.service</td><td>存放服务接口</td></tr><tr><td>cn.itcast.elasticsearch.service.impl</td><td>存放服务接口实现类</td></tr></tbody>
</table></figure>

#### 准备POM依赖

```
<repositories><!-- 代码库 -->
    <repository>
        <id>aliyun</id>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
            <updatePolicy>never</updatePolicy>
        </snapshots>
    </repository>
</repositories>

<dependencies>
    <dependency>
        <groupId>org.elasticsearch.client</groupId>
        <artifactId>elasticsearch-rest-high-level-client</artifactId>
        <version>7.6.1</version>
    </dependency>
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-core</artifactId>
        <version>2.11.1</version>
    </dependency>
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>fastjson</artifactId>
        <version>1.2.62</version>
    </dependency>
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.12</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testng</groupId>
        <artifactId>testng</artifactId>
        <version>6.14.3</version>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.1</version>
            <configuration>
                <target>1.8</target>
                <source>1.8</source>
            </configuration>
        </plugin>
    </plugins>
</build>
```

#### 创建用于保存职位信息的实体类

注意：
在id字段上添加一个 @JSONField注解，并配置注解的serialize为false，表示该字段无需转换为JSON，因为它就是文档的唯一ID。

参考代码：

```
public class JobDetail {

    // 因为此处无需将id序列化为文档中
    @JSONField(serialize = false)
    private long id;            // 唯一标识
    private String area;        // 职位所在区域
    private String exp;         // 岗位要求的工作经验
    private String edu;         // 学历要求
    private String salary;      // 薪资范围
    private String job_type;    // 职位类型（全职/兼职）
    private String cmp;         // 公司名
    private String pv;          // 浏览量
    private String title;       // 岗位名称
    private String jd;          // 职位描述

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getExp() {
        return exp;
    }

    public void setExp(String exp) {
        this.exp = exp;
    }

    public String getEdu() {
        return edu;
    }

    public void setEdu(String edu) {
        this.edu = edu;
    }

    public String getSalary() {
        return salary;
    }

    public void setSalary(String salary) {
        this.salary = salary;
    }

    public String getJob_type() {
        return job_type;
    }

    public void setJob_type(String job_type) {
        this.job_type = job_type;
    }

    public String getCmp() {
        return cmp;
    }

    public void setCmp(String cmp) {
        this.cmp = cmp;
    }

    public String getPv() {
        return pv;
    }

    public void setPv(String pv) {
        this.pv = pv;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getJd() {
        return jd;
    }

    public void setJd(String jd) {
        this.jd = jd;
    }

    @Override
    public String toString() {
        return "JobDetail{" +
                "id=" + id +
                ", area='" + area + '\'' +
                ", exp='" + exp + '\'' +
                ", edu='" + edu + '\'' +
                ", salary='" + salary + '\'' +
                ", job_type='" + job_type + '\'' +
                ", cmp='" + cmp + '\'' +
                ", pv='" + pv + '\'' +
                ", title='" + title + '\'' +
                ", jd='" + jd + '\'' +
                '}';
    }
}
```

#### 编写接口和实现类

在cn.itcast.elasticsearch.service包中创建JobFullTextService接口，该接口中定义了职位全文检索相关的Java API接口。

参考代码：

```
/**
 * 定义JobFullTextService
 */
public interface JobFullTextService {
    // 添加一个职位数据
    void add(JobDetail jobDetail);

    // 根据ID检索指定职位数据
    JobDetail findById(long id) throws IOException;

    // 修改职位薪资
    void update(JobDetail jobDetail) throws IOException;

    // 根据ID删除指定位置数据
    void deleteById(long id) throws IOException;

    // 根据关键字检索数据
    List<JobDetail> searchByKeywords(String keywords) throws IOException;

    // 分页检索
    Map<String, Object> searchByPage(String keywords, int pageNum, int pageSize) throws IOException;

    // scroll分页解决深分页问题
    Map<String, Object> searchByScrollPage(String keywords, String scrollId, int pageSize) throws IOException;

    // 关闭ES连接
    void close() throws IOException;
;
}

```

#### 创建实现类

在cn.itcast.elasticsearch.service.impl包下创建一个实现类：JobFullTextServiceImpl，并实现上面的接口。

参考代码：

```
public class JobFullTextServiceImpl implements JobFullTextService {
    @Override
    public void add(JobDetail jobDetail) {
  
    }

    @Override
    public void update(JobDetail jobDetail) {

    }

    @Override
    public JobDetail findById(long id) {
        return null;
    }

    @Override
    public boolean deleteById(long id) {
        return false;
    }

    @Override
    public List<JobDetail> searchByKeywords(String keywords) {
        return null;
    }

    @Override
    public Map<String, Object> searchByPage(String keywords, int pageNum, int pageSize) {
        return null;
    }

    @Override
    public Map<String, Object> searchByScrollPage(String keywords, String scrollId, int pageSize) {
        return null;
    }
}
```

### 添加职位数据

#### 初始化客户端连接

1.使用RestHighLevelClient构建客户端连接。
2.基于RestClient.builder方法来构建RestClientBuilder
3.用HttpHost来添加ES的节点

参考代码：

```
private RestHighLevelClient restHighLevelClient;
private static final String JOB_IDX_NAME = "job_idx";

public JobFullTextServiceImpl() {
    restHighLevelClient = new RestHighLevelClient(RestClient.builder(
            new HttpHost("node1.itcast.cn", 9200, "http")
            , new HttpHost("node2.itcast.cn", 9200, "http")
            , new HttpHost("node3.itcast.cn", 9200, "http")
    ));
}
```

#### 实现关闭客户端连接

```
@Override
public void close() {
    try {
        restHighLevelClient.close();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

#### 编写代码实现新增职位数据

实现步骤：
1.构建IndexRequest对象，用来描述ES发起请求的数据。
2.设置文档ID。
3.使用FastJSON将实体类对象转换为JSON。
4.使用IndexRequest.source方法设置文档数据，并设置请求的数据为JSON格式。
5.使用ES High level client调用index方法发起请求，将一个文档添加到索引中。

参考代码：

```
@Override
public void add(JobDetail jobDetail) {
    // 1. 构建IndexRequest对象，用来描述ES发起请求的数据。
    IndexRequest indexRequest = new IndexRequest(JOB_IDX_NAME);

    // 2. 设置文档ID。
    indexRequest.id(jobDetail.getId() + "");

    // 3. 构建一个实体类对象，并使用FastJSON将实体类对象转换为JSON。
    String json = JSON.toJSONString(jobDetail);

    // 4. 使用IndexRequest.source方法设置请求数据。
    indexRequest.source(json);

    try {
        // 5. 使用ES High level client调用index方法发起请求
        restHighLevelClient.index(indexRequest, RequestOptions.DEFAULT);
    } catch (IOException e) {
        e.printStackTrace();
    }

    System.out.println("索引创建成功!");
}
```

常见错误：

```
java.lang.IllegalArgumentException: The number of object passed must be even but was [1]

	at org.elasticsearch.action.index.IndexRequest.source(IndexRequest.java:474)
	at org.elasticsearch.action.index.IndexRequest.source(IndexRequest.java:461)
```

原因：IndexRequest.source要求传递偶数个的参数，但只传递了1个

#### 编写测试用例测试添加方法

1.在 test/java 目录中创建一个 cn.itcast.elasticsearch.service 包。
2.在cn.itcast.elasticsearch.service 包下创建一个JobFullTextServiceTest类。
3.在@BeforeTest中构建JobFullTextService对象，@AfterTest中调用close方法关闭连接。
4.编写测试用例，构建一个测试用的实体类，测试add方法。

参考代码：

```
public class JobFullTextServiceTest {

    private JobFullTextService jobFullTextService;

    @BeforeTest
    public void beforeTest() {
        jobFullTextService = new JobFullTextServiceImpl();
    }

    @Test
    public void addTest() {
        // 1. 测试新增索引文档
       jobFullTextService = new JobFullTextServiceImpl();

        JobDetail jobDetail = new JobDetail();
        jobDetail.setId(1);
        jobDetail.setArea("江苏省-南京市");
        jobDetail.setCmp("Elasticsearch大学");
        jobDetail.setEdu("本科及以上");
        jobDetail.setExp("一年工作经验");
        jobDetail.setTitle("大数据工程师");
        jobDetail.setJob_type("全职");
        jobDetail.setPv("1700次浏览");
        jobDetail.setJd("会Hadoop就行");
        jobDetail.setSalary("5-9千/月");

        jobFullTextService.add(jobDetail);
    }

    @AfterTest
    public void afterTest() {
        jobFullTextService.close();
    }
}
```

### 根据ID检索指定职位数据

#### 实现步骤

1.构建GetRequest请求。
2.使用RestHighLevelClient.get发送GetRequest请求，并获取到ES服务器的响应。
3.将ES响应的数据转换为JSON字符串
4.并使用FastJSON将JSON字符串转换为JobDetail类对象
5.记得：单独设置ID

参考代码：

```
@Override
public JobDetail findById(long id) throws IOException {
    // 1. 构建GetRequest请求。
    GetRequest getRequest = new GetRequest(JOB_IDX_NAME, id + "");

    // 2. 使用RestHighLevelClient.get发送GetRequest请求，并获取到ES服务器的响应。
    GetResponse response = restHighLevelClient.get(getRequest, RequestOptions.DEFAULT);

    // 3. 将ES响应的数据转换为JSON字符串
    String json = response.getSourceAsString();

    // 4. 并使用FastJSON将JSON字符串转换为JobDetail类对象
    JobDetail jobDetail = JSONObject.parseObject(json, JobDetail.class);

    // 5. 设置ID字段
    jobDetail.setId(id);

    return jobDetail;

}
```

#### 编写测试用例

参考代码：

```
@Test
public void findByIdTest() throws IOException {
    JobDetail jobDetail = jobFullTextService.findById(1);
    System.out.println(jobDetail);
}
```

### 修改职位

#### 实现步骤

1. 判断对应ID的文档是否存在
	1. 构建GetRequest
	2. 执行client的exists方法，发起请求，判断是否存在
2. 构建UpdateRequest请求
3. 设置UpdateRequest的文档，并配置为JSON格式
4. 执行client发起update请求

参考代码：

```
@Override
public void update(JobDetail jobDetail) throws IOException {
    // 1. 判断对应ID的文档是否存在
    // a) 构建GetRequest
    GetRequest getRequest = new GetRequest(JOB_IDX_NAME, jobDetail.getId() + "");

    // b) 执行client的exists方法，发起请求，判断是否存在
    boolean exists = restHighLevelClient.exists(getRequest, RequestOptions.DEFAULT);

    if(!exists) return;

    // 2. 构建UpdateRequest请求
    UpdateRequest updateRequest = new UpdateRequest(JOB_IDX_NAME, jobDetail.getId() + "");

    // 3. 设置UpdateRequest的文档，并配置为JSON格式
    updateRequest.doc(JSON.toJSONString(jobDetail), XContentType.JSON);

    // 4. 执行client发起update请求
    restHighLevelClient.update(updateRequest, RequestOptions.DEFAULT);
}
```

#### 编写测试用例

1.将ID为1的职位信息查询出来
2.将职位的名称设置为：”大数据开发工程师”
3.执行更新操作
4.再打印查看职位的名称是否成功更新

参考代码：

```
@Test
public void updateTest() throws IOException {
    JobDetail jobDetail = jobFullTextService.findById(1);
    jobDetail.setTitle("大数据开发工程师");
    jobFullTextService.update(jobDetail);
    System.out.println(jobFullTextService.findById(1));
}
```

### 根据文档ID删除职位

#### 实现步骤

1.构建delete请求
2.使用RestHighLevelClient执行delete请求

参考代码：

```
@Override
public void deleteById(long id) throws IOException {
    // 1. 构建delete请求
    DeleteRequest deleteRequest = new DeleteRequest(JOB_IDX_NAME, id + "");

    // 2. 使用client执行delete请求
    restHighLevelClient.delete(deleteRequest, RequestOptions.DEFAULT);
}

```

#### 编写测试用例

1.在测试用例中执行根据ID删除文档操作
2.使用VSCode发送请求，查看指定ID的文档是否已经被删除

参考代码：

```
@Test
public void deleteByIdTest() throws IOException {
    jobFullTextService.deleteById(1);
}
```

### 根据关键字检索数据

#### 实现步骤

1. 构建SearchRequest检索请求
2. 创建一个SearchSourceBuilder专门用于构建查询条件
3. 使用QueryBuilders.multiMatchQuery构建一个查询条件（搜索title、jd），并配置到SearchSourceBuilder
4. 调用SearchRequest.source将查询条件设置到检索请求
5. 执行RestHighLevelClient.search发起请求
6. 遍历结果
	1. 获取命中的结果
	2. 将JSON字符串转换为对象
	3. 使用SearchHit.getId设置文档ID

参考代码：

```
@Override
public List<JobDetail> searchByKeywords(String keywords) throws IOException {
    // 1. 构建SearchRequest检索请求
    SearchRequest searchRequest = new SearchRequest(JOB_IDX_NAME);

    // 2. 创建一个SearchSourceBuilder专门用于构建查询条件
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

    // 3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
    MultiMatchQueryBuilder queryBuilder = QueryBuilders.multiMatchQuery(keywords, "jd", "title");
    searchSourceBuilder.query(queryBuilder);

    // 4. 调用SearchRequest.source将查询条件设置到检索请求
    searchRequest.source(searchSourceBuilder);

    // 5. 执行RestHighLevelClient.search发起请求
    SearchResponse searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

    // 6. 遍历结果
    SearchHits hits = searchResponse.getHits();

    List<JobDetail> jobDetailList = new ArrayList<>();

    for (SearchHit hit : hits) {
        // 1) 获取命中的结果
        String json = hit.getSourceAsString();
        // 2) 将JSON字符串转换为对象
        JobDetail jobDetail = JSON.parseObject(json, JobDetail.class);
        // 3) 使用SearchHit.getId设置文档ID
        jobDetail.setId(Long.parseLong(hit.getId()));

        jobDetailList.add(jobDetail);
    }

    return jobDetailList;
}
```

#### 编写测试用例

搜索标题、职位描述中包含销售的职位。

```
@Test
public void searchByKeywordsTest() throws IOException {
    List<JobDetail> jobDetailList = jobFullTextService.searchByKeywords("销售");
    for (JobDetail jobDetail : jobDetailList) {
        System.out.println(jobDetail);
    }
}
```

### 分页检索

#### 实现步骤

步骤和之前的关键字搜索类似，只不过构建查询条件的时候，需要加上分页的设置。

1. 构建SearchRequest检索请求
2. 创建一个SearchSourceBuilder专门用于构建查询条件
3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
4. 设置SearchSourceBuilder的from和size参数，构建分页
5. 调用SearchRequest.source将查询条件设置到检索请求
6. 执行RestHighLevelClient.search发起请求
7. 遍历结果
	1. 获取命中的结果
	2. 将JSON字符串转换为对象
	3. 使用SearchHit.getId设置文档ID
8. 将结果封装到Map结构中（带有分页信息）
	1. total -> 使用SearchHits.getTotalHits().value获取到所有的记录数
	2. content -> 当前分页中的数据

```
@Override
public Map<String, Object> searchByPage(String keywords, int pageNum, int pageSize) throws IOException {
    // 1. 构建SearchRequest检索请求
    SearchRequest searchRequest = new SearchRequest(JOB_IDX_NAME);

    // 2. 创建一个SearchSourceBuilder专门用于构建查询条件
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

    // 3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
    MultiMatchQueryBuilder queryBuilder = QueryBuilders.multiMatchQuery(keywords, "jd", "title");
    searchSourceBuilder.query(queryBuilder);

    // 4. 设置SearchSourceBuilder的from和size参数，构建分页
    searchSourceBuilder.from((pageNum – 1) * pageSize);
    searchSourceBuilder.size(pageSize);

    // 4. 调用SearchRequest.source将查询条件设置到检索请求
    searchRequest.source(searchSourceBuilder);

    // 5. 执行RestHighLevelClient.search发起请求
    SearchResponse searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

    // 6. 遍历结果
    SearchHits hits = searchResponse.getHits();

    List<JobDetail> jobDetailList = new ArrayList<>();

    for (SearchHit hit : hits) {
        // 1) 获取命中的结果
        String json = hit.getSourceAsString();
        // 2) 将JSON字符串转换为对象
        JobDetail jobDetail = JSON.parseObject(json, JobDetail.class);
        // 3) 使用SearchHit.getId设置文档ID
        jobDetail.setId(Long.parseLong(hit.getId()));

        jobDetailList.add(jobDetail);
    }

    // 8.  将结果封装到Map结构中（带有分页信息）
    // a)  total -> 使用SearchHits.getTotalHits().value获取到所有的记录数
    // b)  content -> 当前分页中的数据
    Map<String, Object> result = new HashMap<>();
    result.put("total", hits.getTotalHits().value);
    result.put("content", jobDetailList);

    return result;
}
```

#### 编写测试用例

1.搜索关键字为“销售”，查询第0页，每页显示10条数据
2.打印搜索结果总记录数、对应分页的记录

参考代码：

```
@Test
public void searchByPageTest() throws IOException {
    Map<String, Object> resultMap = jobFullTextService.searchByPage("销售", 0, 10);
    System.out.println("总共:" + resultMap.get("total"));
    List<JobDetail> jobDetailList = (List<JobDetail>)resultMap.get("content");

    for (JobDetail jobDetail : jobDetailList) {
        System.out.println(jobDetail);
    }
}
```

### scroll分页检索

#### 实现步骤

判断scrollId是否为空

1. 如果为空，那么首次查询要发起scroll查询，设置滚动快照的有效时间
2. 如果不为空，就表示之前应发起了scroll，直接执行scroll查询就可以

步骤和之前的关键字搜索类似，只不过构建查询条件的时候，需要加上分页的设置。

**scrollId为空：**

1. 构建SearchRequest检索请求
2. 创建一个SearchSourceBuilder专门用于构建查询条件
3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
4. 调用SearchRequest.source将查询条件设置到检索请求
5. 设置每页多少条记录，调用SearchRequest.scroll设置滚动快照有效时间
6. 执行RestHighLevelClient.search发起请求
7. 遍历结果
	1. 获取命中的结果
	2. 将JSON字符串转换为对象
	3. 使用SearchHit.getId设置文档ID
8. 将结果封装到Map结构中（带有分页信息）
	1. scroll_id -> 从SearchResponse中调用getScrollId()方法获取scrollId
	2. content -> 当前分页中的数据

**scollId不为空：**

1. 用之前查询出来的scrollId，构建SearchScrollRequest请求
2. 设置scroll查询结果的有效时间
3. 使用RestHighLevelClient执行scroll请求

```
@Override
public Map<String, Object> searchByScrollPage(String keywords, String scrollId, int pageSize) {

    Map<String, Object> result = new HashMap<>();
    List<JobDetail> jobList = new ArrayList<>();

    try {
            SearchResponse searchResponse = null;

            if(scrollId == null) {
                // 1. 创建搜索请求
                SearchRequest searchRequest = new SearchRequest("job_idx");
                // 2. 构建查询条件
                SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
                searchSourceBuilder.query(QueryBuilders.multiMatchQuery(keywords, "title", "jd"));
                // 3. 设置分页大小
                searchSourceBuilder.size(pageSize);
                // 4. 设置查询条件、并设置滚动快照有效时间
                searchRequest.source(searchSourceBuilder);
                searchRequest.scroll(TimeValue.timeValueMinutes(1));
                // 5. 发起请求
                searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
            }
            else {
                SearchScrollRequest searchScrollRequest = new SearchScrollRequest(scrollId);
                searchScrollRequest.scroll(TimeValue.timeValueMinutes(1));
                searchResponse = client.scroll(searchScrollRequest, RequestOptions.DEFAULT);
            }

            // 6. 迭代响应结果
            SearchHits hits = searchResponse.getHits();
            for (SearchHit hit : hits) {
                JobDetail jobDetail = JSONObject.parseObject(hit.getSourceAsString(), JobDetail.class);
                jobDetail.setId(Long.parseLong(hit.getId()));
                jobList.add(jobDetail);
            }

            result.put("content", jobList);
            result.put("scroll_id", searchResponse.getScrollId());

        }
    catch (IOException e) {
        e.printStackTrace();
    }

    return result;
}
```

#### 编写测试用例

1.编写第一个测试用例，不带scrollId查询
2.编写第二个测试用例，使用scrollId查询

```
@Test
public void searchByScrollPageTest1() throws IOException {
    Map<String, Object> result = jobFullTextService.searchByScrollPage("销售", null, 10);
    System.out.println("scrollId: " + result.get("scrollId"));
    List<JobDetail> content = (List<JobDetail>)result.get("content");

    for (JobDetail jobDetail : content) {
        System.out.println(jobDetail);
    }
}

@Test
public void searchByScrollPageTest2() throws IOException {
    Map<String, Object> result = jobFullTextService.searchByScrollPage("销售", "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAA0WRG4zZFVwODJSU2Uxd1BOWkQ4cFdCQQ==", 10);
    System.out.println("scrollId: " + result.get("scrollId"));
    List<JobDetail> content = (List<JobDetail>)result.get("content");

    for (JobDetail jobDetail : content) {
        System.out.println(jobDetail);
    }
}
```

### 高亮查询

#### 高亮查询简介

在进行关键字搜索时，搜索出的内容中的关键字会显示不同的颜色，称之为高亮。百度搜索关键字"传智播客"

![image.png](https://image.hyly.net/i/2025/09/25/a442433d4aa63da68ea48b2f0141cf9e-0.webp)

京东商城搜索"笔记本"

![image.png](https://image.hyly.net/i/2025/09/25/ef8c705acc51f7ac3bcba16440cb5435-0.webp)

#### 高亮显示的html分析

通过开发者工具查看高亮数据的html代码实现：

![image.png](https://image.hyly.net/i/2025/09/25/9d3d4cba5818655882ccce13c2b72a64-0.webp)

ElasticSearch可以对查询出的内容中关键字部分进行标签和样式的设置，但是你需要告诉ElasticSearch使用什么标签对高亮关键字进行包裹

#### 实现高亮查询

1. 在我们构建查询请求时，我们需要构建一个HighLightBuilder，专门来配置高亮查询。
	1. 构建一个HighlightBuilder
	2. 设置高亮字段（title、jd）
	3. 设置高亮前缀（&#x3c;font color=’red’>）
	4. 设置高亮后缀（&#x3c;/font>）
	5. 将高亮添加到SearchSourceBuilder

代码如下：

```
// 设置高亮
HighlightBuilder highlightBuilder = new HighlightBuilder();
highlightBuilder.field("title");
highlightBuilder.field("jd");
highlightBuilder.preTags("<font color='red'>");
highlightBuilder.postTags("</font>");
searchSourceBuilder.highlighter(highlightBuilder);
```

2. 我们将高亮的查询结果取出，并替换掉原先没有高亮的结果
	1. 获取高亮字段
		1. 获取title高亮字段
		2. 获取jd高亮字段
	2. 将高亮字段进行替换普通字段
		1. 处理title高亮，判断高亮是否为空，不为空则将高亮碎片拼接在一起
		2. 替换原有普通字段

参考代码：

```
// 1. 获取高亮字段
Map<String, HighlightField> highlightFieldMap = hit.getHighlightFields();
// 1.1 获取title高亮字段
HighlightField titleHl = highlightFieldMap.get("title");
// 1.2 获取jd高亮字段
HighlightField jdHl = highlightFieldMap.get("jd");
// 2. 将高亮字段进行替换普通字段
// 2.1 处理title高亮，判断高亮是否为空，不为空则将高亮Fragment（碎片）拼接在一起，替换原有普通字段
if(titleHl != null) {
    Text[] fragments = titleHl.getFragments();
    StringBuilder stringBuilder = new StringBuilder();
    for (Text fragment : fragments) {
        stringBuilder.append(fragment.string());
    }
    jobDetail.setTitle(stringBuilder.toString());
}

// 2.2 处理jd高亮
if(jdHl != null) {
    Text[] fragments = jdHl.getFragments();
    StringBuilder stringBuilder = new StringBuilder();
    for (Text fragment : fragments) {
        stringBuilder.append(fragment.string());
    }
    jobDetail.setJd(stringBuilder.toString());
}
```

我们再查询，发现查询的结果中就都包含了高亮。

![image.png](https://image.hyly.net/i/2025/09/25/e93d1f9d395e2554cfa83f3b9e31f0f3-0.webp)

### 完整参考代码

```
public class JobFullTextServiceImpl implements JobFullTextService {

    private RestHighLevelClient restHighLevelClient;
    private static final String JOB_IDX_NAME = "job_idx";

    public JobFullTextServiceImpl() {
        restHighLevelClient = new RestHighLevelClient(RestClient.builder(
                new HttpHost("node1.itcast.cn", 9200, "http")
                , new HttpHost("node2.itcast.cn", 9200, "http")
                , new HttpHost("node3.itcast.cn", 9200, "http")
        ));
    }

    @Override
    public void add(JobDetail jobDetail) {
        // 1. 构建IndexRequest对象，用来描述ES发起请求的数据。
        IndexRequest indexRequest = new IndexRequest(JOB_IDX_NAME);

        // 2. 设置文档ID。
        indexRequest.id(jobDetail.getId() + "");

        // 3. 构建一个实体类对象，并使用FastJSON将实体类对象转换为JSON。
        String json = JSON.toJSONString(jobDetail);

        // 4. 使用IndexRequest.source方法设置请求数据。
        indexRequest.source(json, XContentType.JSON);

        try {
            // 5. 使用ES High level client调用index方法发起请求
            restHighLevelClient.index(indexRequest, RequestOptions.DEFAULT);
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("索引创建成功!");
    }

    @Override
    public void update(JobDetail jobDetail) throws IOException {
        // 1. 判断对应ID的文档是否存在
        // a) 构建GetRequest
        GetRequest getRequest = new GetRequest(JOB_IDX_NAME, jobDetail.getId() + "");

        // b) 执行client的exists方法，发起请求，判断是否存在
        boolean exists = restHighLevelClient.exists(getRequest, RequestOptions.DEFAULT);

        if(!exists) return;

        // 2. 构建UpdateRequest请求
        UpdateRequest updateRequest = new UpdateRequest(JOB_IDX_NAME, jobDetail.getId() + "");

        // 3. 设置UpdateRequest的文档，并配置为JSON格式
        updateRequest.doc(JSON.toJSONString(jobDetail), XContentType.JSON);

        // 4. 执行client发起update请求
        restHighLevelClient.update(updateRequest, RequestOptions.DEFAULT);
    }

    @Override
    public JobDetail findById(long id) throws IOException {
        // 1. 构建GetRequest请求。
        GetRequest getRequest = new GetRequest(JOB_IDX_NAME, id + "");

        // 2. 使用RestHighLevelClient.get发送GetRequest请求，并获取到ES服务器的响应。
        GetResponse response = restHighLevelClient.get(getRequest, RequestOptions.DEFAULT);

        // 3. 将ES响应的数据转换为JSON字符串
        String json = response.getSourceAsString();

        // 4. 并使用FastJSON将JSON字符串转换为JobDetail类对象
        JobDetail jobDetail = JSONObject.parseObject(json, JobDetail.class);

        // 5. 设置ID字段
        jobDetail.setId(id);

        return jobDetail;

    }

    @Override
    public void deleteById(long id) throws IOException {
        // 1. 构建delete请求
        DeleteRequest deleteRequest = new DeleteRequest(JOB_IDX_NAME, id + "");

        // 2. 使用client执行delete请求
        restHighLevelClient.delete(deleteRequest, RequestOptions.DEFAULT);
    }

    @Override
    public List<JobDetail> searchByKeywords(String keywords) throws IOException {
        // 1. 构建SearchRequest检索请求
        SearchRequest searchRequest = new SearchRequest(JOB_IDX_NAME);

        // 2. 创建一个SearchSourceBuilder专门用于构建查询条件
        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

        // 3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
        MultiMatchQueryBuilder queryBuilder = QueryBuilders.multiMatchQuery(keywords, "jd", "title");
        searchSourceBuilder.query(queryBuilder);

        // 4. 调用SearchRequest.source将查询条件设置到检索请求
        searchRequest.source(searchSourceBuilder);

        // 5. 执行RestHighLevelClient.search发起请求
        SearchResponse searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

        // 6. 遍历结果
        SearchHits hits = searchResponse.getHits();

        List<JobDetail> jobDetailList = new ArrayList<>();

        for (SearchHit hit : hits) {
            // 1) 获取命中的结果
            String json = hit.getSourceAsString();
            // 2) 将JSON字符串转换为对象
            JobDetail jobDetail = JSON.parseObject(json, JobDetail.class);
            // 3) 使用SearchHit.getId设置文档ID
            jobDetail.setId(Long.parseLong(hit.getId()));

            jobDetailList.add(jobDetail);
        }

        return jobDetailList;
    }

    @Override
    public Map<String, Object> searchByPage(String keywords, int pageNum, int pageSize) throws IOException {
        // 1. 构建SearchRequest检索请求
        SearchRequest searchRequest = new SearchRequest(JOB_IDX_NAME);

        // 2. 创建一个SearchSourceBuilder专门用于构建查询条件
        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

        // 3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
        MultiMatchQueryBuilder queryBuilder = QueryBuilders.multiMatchQuery(keywords, "jd", "title");
        searchSourceBuilder.query(queryBuilder);

        // 4. 设置SearchSourceBuilder的from和size参数，构建分页
        searchSourceBuilder.from(pageNum);
        searchSourceBuilder.size(pageSize);

        // 4. 调用SearchRequest.source将查询条件设置到检索请求
        searchRequest.source(searchSourceBuilder);

        // 5. 执行RestHighLevelClient.search发起请求
        SearchResponse searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);

        // 6. 遍历结果
        SearchHits hits = searchResponse.getHits();

        List<JobDetail> jobDetailList = new ArrayList<>();

        for (SearchHit hit : hits) {
            // 1) 获取命中的结果
            String json = hit.getSourceAsString();
            // 2) 将JSON字符串转换为对象
            JobDetail jobDetail = JSON.parseObject(json, JobDetail.class);
            // 3) 使用SearchHit.getId设置文档ID
            jobDetail.setId(Long.parseLong(hit.getId()));

            jobDetailList.add(jobDetail);
        }

        // 8.  将结果封装到Map结构中（带有分页信息）
        // a)  total -> 使用SearchHits.getTotalHits().value获取到所有的记录数
        // b)  content -> 当前分页中的数据
        Map<String, Object> result = new HashMap<>();
        result.put("total", hits.getTotalHits().value);
        result.put("content", jobDetailList);

        return result;
    }

    @Override
    public Map<String, Object> searchByScrollPage(String keywords, String scrollId, int pageSize) throws IOException {
        SearchResponse searchResponse = null;

        if(scrollId == null) {
            // 1. 构建SearchRequest检索请求
            SearchRequest searchRequest = new SearchRequest(JOB_IDX_NAME);

            // 2. 创建一个SearchSourceBuilder专门用于构建查询条件
            SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();

            // 3. 使用QueryBuilders.multiMatchQuery构建一个查询条件，并配置到SearchSourceBuilder
            MultiMatchQueryBuilder queryBuilder = QueryBuilders.multiMatchQuery(keywords, "jd", "title");
            searchSourceBuilder.query(queryBuilder);
            searchSourceBuilder.size(pageSize);

            // 设置高亮查询
            HighlightBuilder highlightBuilder = new HighlightBuilder();
            highlightBuilder.preTags("<font color='red'>");
            highlightBuilder.postTags("</font>");
            highlightBuilder.field("title");
            highlightBuilder.field("jd");

            searchSourceBuilder.highlighter(highlightBuilder);

            // 4. 调用searchRequest.scroll设置滚动快照有效时间
            searchRequest.scroll(TimeValue.timeValueMinutes(10));

            // 5. 调用SearchRequest.source将查询条件设置到检索请求
            searchRequest.source(searchSourceBuilder);

            // 6. 执行RestHighLevelClient.search发起请求
            searchResponse = restHighLevelClient.search(searchRequest, RequestOptions.DEFAULT);
        }
        else {
            SearchScrollRequest searchScrollRequest = new SearchScrollRequest(scrollId);
            searchScrollRequest.scroll(TimeValue.timeValueMinutes(10));
            searchResponse = restHighLevelClient.scroll(searchScrollRequest, RequestOptions.DEFAULT);
        }


        if(searchResponse != null) {
            // 7. 遍历结果
            SearchHits hits = searchResponse.getHits();

            List<JobDetail> jobDetailList = new ArrayList<>();

            for (SearchHit hit : hits) {

                // 1) 获取命中的结果
                String json = hit.getSourceAsString();
                // 2) 将JSON字符串转换为对象
                JobDetail jobDetail = JSON.parseObject(json, JobDetail.class);
                // 3) 使用SearchHit.getId设置文档ID
                jobDetail.setId(Long.parseLong(hit.getId()));


                // 1. 获取高亮字段
                Map<String, HighlightField> highlightFieldMap = hit.getHighlightFields();
                // 1.1 获取title高亮字段
                HighlightField titleHl = highlightFieldMap.get("title");
                // 1.2 获取jd高亮字段
                HighlightField jdHl = highlightFieldMap.get("jd");
                // 2. 将高亮字段进行替换普通字段
                // 2.1 处理title高亮，判断高亮是否为空，不为空则将高亮Fragment（碎片）拼接在一起，替换原有普通字段
                if(titleHl != null) {
                    Text[] fragments = titleHl.getFragments();
                    StringBuilder stringBuilder = new StringBuilder();
                    for (Text fragment : fragments) {
                        stringBuilder.append(fragment.string());
                    }
                    jobDetail.setTitle(stringBuilder.toString());
                }

                // 2.2 处理jd高亮
                if(jdHl != null) {
                    Text[] fragments = jdHl.getFragments();
                    StringBuilder stringBuilder = new StringBuilder();
                    for (Text fragment : fragments) {
                        stringBuilder.append(fragment.string());
                    }
                    jobDetail.setJd(stringBuilder.toString());
                }

                jobDetailList.add(jobDetail);
            }

            // 8.  将结果封装到Map结构中（带有分页信息）
            // a)  total -> 使用SearchHits.getTotalHits().value获取到所有的记录数
            // b)  content -> 当前分页中的数据
            Map<String, Object> result = new HashMap<>();
            result.put("scrollId", searchResponse.getScrollId());
            result.put("content", jobDetailList);

            return result;
        }

        return null;
    }

    @Override
    public void close() {
        try {
            restHighLevelClient.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## Elasticsearch架构原理

### Elasticsearch的节点类型

#### 节点类型

1. master：候选节点
2. data：数据节点
3. data_content：数据内容节点
4. data_hot：热节点
5. data_warm：索引不再定期更新，但仍可查询
6. data_code：冷节点，只读索引
7. Ingest：预处理节点，作用类似于Logstash中的Filter
8. ml：机器学习节点
9. remote_cluster_client：候选客户端节点
10. transform：转换节点
11. voting_only：仅投票节点

**在Elasticsearch主要有两类节点，一类是Master，一类是DataNode。**

#### Master节点

在Elasticsearch启动时，会选举出来一个Master节点。当某个节点启动后，然后使用Zen Discovery机制找到集群中的其他节点，并建立连接。
discovery.seed_hosts: ["node1.itcast.cn", "node2.itcast.cn", "node3.itcast.cn"]
并从候选主节点中选举出一个主节点。
cluster.initial_master_nodes: ["node1.itcast.cn", "node2.itcast.cn"]

Master节点主要负责：

1. 管理索引（创建索引、删除索引）、分配分片
2. 维护元数据
3. 管理集群节点状态
4. 不负责数据写入和查询，比较轻量级

一个Elasticsearch集群中，只有一个Master节点。在生产环境中，内存可以相对小一点，但机器要稳定。

#### DataNode节点

在Elasticsearch集群中，会有N个DataNode节点。DataNode节点主要负责：

1. 数据写入、数据检索，大部分Elasticsearch的压力都在DataNode节点上
2. 在生产环境中，内存最好配置大一些

### 分片和副本机制

#### 分片（Shard）

1. Elasticsearch是一个分布式的搜索引擎，索引的数据也是分成若干部分，分布在不同的服务器节点中
2. 分布在不同服务器节点中的索引数据，就是分片（Shard）。Elasticsearch会自动管理分片，如果发现分片分布不均衡，就会自动迁移
3. 一个索引（index）由多个shard（分片）组成，而分片是分布在不同的服务器上的

#### 副本

为了对Elasticsearch的分片进行容错，假设某个节点不可用，会导致整个索引库都将不可用。所以，需要对分片进行副本容错。每一个分片都会有对应的副本。在Elasticsearch中，默认创建的索引为1个分片、每个分片有1个主分片和1个副本分片。

每个分片都会有一个Primary Shard（主分片），也会有若干个Replica Shard（副本分片）
Primary Shard和Replica Shard不在同一个节点上

#### 指定分片、副本数量

```
// 创建指定分片数量、副本数量的索引
PUT /job_idx_shard
{
    "mappings": {
        "properties": {
            "id": { "type": "long", "store": true },
            "area": { "type": "keyword", "store": true },
            "exp": { "type": "keyword", "store": true },
            "edu": { "type": "keyword", "store": true },
            "salary": { "type": "keyword", "store": true },
            "job_type": { "type": "keyword", "store": true },
            "cmp": { "type": "keyword", "store": true },
            "pv": { "type": "keyword", "store": true },
            "title": { "type": "text", "store": true },
            "jd": { "type": "text"}

        }
    },
    "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 2
    }
}

// 查看分片、主分片、副本分片
GET /_cat/indices?v
```

### Elasticsearch重要工作流程

#### Elasticsearch文档写入原理

![image.png](https://image.hyly.net/i/2025/09/25/9d79aa67a719bd395b9231bb8570b8ce-0.webp)

1. 1.选择任意一个DataNode发送请求，例如：node2.itcast.cn。此时，node2.itcast.cn就成为一个		coordinating node（协调节点）
2. 计算得到文档要写入的分片
	1. `shard = hash(routing) % number_of_primary_shards`
	2. routing 是一个可变值，默认是文档的 _id
3. coordinating node会进行路由，将请求转发给对应的primary shard所在的DataNode（假设primary shard在node1.itcast.cn、replica shard在node2.itcast.cn）
4. node1.itcast.cn节点上的Primary Shard处理请求，写入数据到索引库中，并将数据同步到			Replica shard
5. Primary Shard和Replica Shard都保存好了文档，返回client

#### Elasticsearch检索原理

![image.png](https://image.hyly.net/i/2025/09/25/175427b090b22b8db722c4660bff0a96-0.webp)

1. client发起查询请求，某个DataNode接收到请求，该DataNode就会成为协调节点（Coordinating Node）
2. 协调节点（Coordinating Node）将查询请求广播到每一个数据节点，这些数据节点的分片会处理该查询请求。协调节点会轮询所有的分片来自动进行负载均衡
3. 每个分片进行数据查询，将符合条件的数据放在一个优先队列中，并将这些数据的文档ID、节点信息、分片信息返回给协调节点
4. 协调节点将所有的结果进行汇总，并进行全局排序
5. 协调节点向包含这些文档ID的分片发送get请求，对应的分片将文档数据返回给协调节点，最后协调节点将数据返回给客户端

### Elasticsearch准实时索引实现

#### 溢写到文件系统缓存

1. 当数据写入到ES分片时，会首先写入到内存中，然后通过内存的buffer生成一个segment，并刷到文件系统缓存中，数据可以被检索（注意不是直接刷到磁盘
2. ES中默认1秒，refresh一次

#### 写translog保障容错

1. 在写入到内存中的同时，也会记录translog日志，在refresh期间出现异常，会根据translog来进行数据恢复
2. 等到文件系统缓存中的segment数据都刷到磁盘中，清空translog文件

#### flush到磁盘

ES默认每隔30分钟会将文件系统缓存的数据刷入到磁盘

#### segment合并

Segment太多时，ES定期会将多个segment合并成为大的segment，减少索引查询时IO开销，此阶段ES会真正的物理删除（之前执行过的delete的数据）

## Elasticsearch SQL

![image.png](https://image.hyly.net/i/2025/09/25/3c0e42ff5f32020a06e97d30fd4e4137-0.webp)

Elasticsearch SQL允许执行类SQL的查询，可以使用REST接口、命令行或者是JDBC，都可以使用SQL来进行数据的检索和数据的聚合。

**Elasticsearch SQL特点：**

1. 本地集成
	1. Elasticsearch SQL是专门为Elasticsearch构建的。每个SQL查询都根据底层存储对相关节点有效执行。
2. 没有额外的要求
	1. 不依赖其他的硬件、进程、运行时库，Elasticsearch SQL可以直接运行在Elasticsearch集群上
3. 轻量且高效
	1. 像SQL那样简洁、高效地完成查询

### SQL与Elasticsearch对应关系

<figure class='table-figure'><table>
<thead>
<tr><th><strong>SQL</strong></th><th><strong>Elasticsearch</strong></th></tr></thead>
<tbody><tr><td>column（列）</td><td>field（字段）</td></tr><tr><td>row（行）</td><td>document（文档）</td></tr><tr><td>table（表）</td><td>index（索引）</td></tr><tr><td>schema（模式）</td><td>mapping（映射）</td></tr><tr><td>database server（数据库服务器）</td><td>Elasticsearch集群实例</td></tr></tbody>
</table></figure>

### Elasticsearch SQL语法

```
SELECT select_expr [, ...]
[ FROM table_name ]
[ WHERE condition ]
[ GROUP BY grouping_element [, ...] ]
[ HAVING condition]
[ ORDER BY expression [ ASC | DESC ] [, ...] ]
[ LIMIT [ count ] ]
[ PIVOT ( aggregation_expr FOR column IN ( value [ [ AS ] alias ] [, ...] ) ) ]
```

目前FROM只支持单表

### 职位查询案例

#### 查询职位索引库中的一条数据

format：表示指定返回的数据类型

```
// 1. 查询职位信息
GET /_sql?format=txt
{
    "query": "SELECT * FROM job_idx limit 1"
}
```

除了txt类型，Elasticsearch SQL还支持以下类型，

<figure class='table-figure'><table>
<thead>
<tr><th>格式</th><th>描述</th></tr></thead>
<tbody><tr><td>csv</td><td>逗号分隔符</td></tr><tr><td>json</td><td>JSON格式</td></tr><tr><td>tsv</td><td>制表符分隔符</td></tr><tr><td>txt</td><td>类cli表示</td></tr><tr><td>yaml</td><td>YAML人类可读的格式</td></tr></tbody>
</table></figure>

#### 将SQL转换为DSL

```
GET /_sql/translate
{
    "query": "SELECT * FROM job_idx limit 1"
}
```

结果如下：

```
{
    "size": 1,
    "_source": {
        "includes": [
            "area",
            "cmp",
            "exp",
            "jd",
            "title"
        ],
        "excludes": []
    },
    "docvalue_fields": [
        {
            "field": "edu"
        },
        {
            "field": "job_type"
        },
        {
            "field": "pv"
        },
        {
            "field": "salary"
        }
    ],
    "sort": [
        {
            "_doc": {
                "order": "asc"
            }
        }
    ]
}

```

#### 职位scroll分页查询

##### 第一次查询

```
// 2. scroll分页查询
GET /_sql?format=json
{
    "query": "SELECT * FROM job_idx",
    "fetch_size": 10
}
```

fetch_size表示每页显示多少数据，而且当我们指定format为Json格式时，会返回一个cursor ID。

![image.png](https://image.hyly.net/i/2025/09/25/e3b4a4fd35aa3c4c3518483dbb3101b2-0.webp)

默认快照的失效时间为45s，如果要延迟快照失效时间，可以配置为以下：

```
GET /_sql?format=json
{
    "query": "select * from job_idx",
    "fetch_size": 1000,
    "page_timeout": "10m"
}
```

##### 第二次查询

```
GET /_sql?format=json
{
    "cursor": "5/WuAwFaAXNARFhGMVpYSjVRVzVrUm1WMFkyZ0JBQUFBQUFBQUFJZ1dUM054VUZaMk9YVlJWalowYkVJeFowUkdVak10ZHc9Pf////8PCgFmBGFyZWEBBGFyZWEBB2tleXdvcmQBAAABZgNjbXABA2NtcAEHa2V5d29yZAEAAAFmA2VkdQEDZWR1AQdrZXl3b3JkAQAAAWYDZXhwAQNleHABB2tleXdvcmQBAAABZgJpZAECaWQBBGxvbmcAAAABZgJqZAECamQBBHRleHQAAAABZghqb2JfdHlwZQEIam9iX3R5cGUBB2tleXdvcmQBAAABZgJwdgECcHYBB2tleXdvcmQBAAABZgZzYWxhcnkBBnNhbGFyeQEHa2V5d29yZAEAAAFmBXRpdGxlAQV0aXRsZQEEdGV4dAAAAAL/Aw=="
}
```

##### 清除游标

```
POST /_sql/close
{
    "cursor": "5/WuAwFaAXNARFhGMVpYSjVRVzVrUm1WMFkyZ0JBQUFBQUFBQUFJZ1dUM054VUZaMk9YVlJWalowYkVJeFowUkdVak10ZHc9Pf////8PCgFmBGFyZWEBBGFyZWEBB2tleXdvcmQBAAABZgNjbXABA2NtcAEHa2V5d29yZAEAAAFmA2VkdQEDZWR1AQdrZXl3b3JkAQAAAWYDZXhwAQNleHABB2tleXdvcmQBAAABZgJpZAECaWQBBGxvbmcAAAABZgJqZAECamQBBHRleHQAAAABZghqb2JfdHlwZQEIam9iX3R5cGUBB2tleXdvcmQBAAABZgJwdgECcHYBB2tleXdvcmQBAAABZgZzYWxhcnkBBnNhbGFyeQEHa2V5d29yZAEAAAFmBXRpdGxlAQV0aXRsZQEEdGV4dAAAAAL/Aw=="
}
```

#### 职位全文检索

##### 需求

检索title和jd中包含hadoop的职位。

##### MATCH函数

在执行全文检索时，需要使用到MATCH函数。

```
MATCH(
    field_exp,   
    constant_exp 
    [, options]) 
```

field_exp：匹配字段
constant_exp：匹配常量表达式

##### 实现

```
GET /_sql?format=txt
{
    "query": "select * from job_idx where MATCH(title, 'hadoop') or MATCH(jd, 'hadoop') limit 10"
}
```

### 订单统计分析案例

#### 案例介绍

有以下数据集：

<figure class='table-figure'><table>
<thead>
<tr><th>订单ID</th><th>订单状态</th><th>支付金额</th><th>支付方式ID</th><th>用户ID</th><th>操作时间</th><th>商品分类</th></tr></thead>
<tbody><tr><td>id</td><td>status</td><td>pay_money</td><td>payway</td><td>userid</td><td>operation_date</td><td>category</td></tr><tr><td>1</td><td>已提交</td><td>4070</td><td>1</td><td>4944191</td><td>2020-04-25 12:09:16</td><td>手机;</td></tr><tr><td>2</td><td>已完成</td><td>4350</td><td>1</td><td>1625615</td><td>2020-04-25 12:09:37</td><td>家用电器;;电脑;</td></tr><tr><td>3</td><td>已提交</td><td>6370</td><td>3</td><td>3919700</td><td>2020-04-25 12:09:39</td><td>男装;男鞋;</td></tr><tr><td>4</td><td>已付款</td><td>6370</td><td>3</td><td>3919700</td><td>2020-04-25 12:09:44</td><td>男装;男鞋;</td></tr></tbody>
</table></figure>

我们需要基于按数据，使用Elasticsearch中的聚合统计功能，实现一些指标统计。

#### 创建索引

```
PUT /order_idx/
{
    "mappings": {
        "properties": {
            "id": {
                "type": "keyword",
                "store": true
            },
            "status": {
                "type": "keyword",
                "store": true
            },
            "pay_money": {
                "type": "double",
                "store": true
            },
            "payway": {
                "type": "byte",
                "store": true
            },
            "userid": {
                "type": "keyword",
                "store": true
            },
            "operation_date": {
                "type": "date",
                "format": "yyyy-MM-dd HH:mm:ss",
                "store": true
            },
            "category": {
                "type": "keyword",
                "store": true
            }
        }
    }
}
```

#### 导入测试数据

1.上传资料中的order_data.json数据文件到Linux
2.使用bulk进行批量导入命令

```
curl -H "Content-Type: application/json" -XPOST "node1.itcast.cn:9200/order_idx/_bulk?pretty&refresh" --data-binary "@order_data.json"
```

#### 统计不同支付方式的的订单数量

##### 使用JSON DSL的方式来实现

这种方式就是用Elasticsearch原生支持的基于JSON的DSL方式来实现聚合统计。

```
GET /order_idx/_search
{
    "size": 0,
    "aggs": {
        "group_by_state": {
            "terms": {
                "field": "payway"
            }
        }
    }
}
```

统计结果：

```
    "aggregations": {
        "group_by_state": {
            "doc_count_error_upper_bound": 0,
            "sum_other_doc_count": 0,
            "buckets": [
                {
                    "key": 2,
                    "doc_count": 1496
                },
                {
                    "key": 1,
                    "doc_count": 1438
                },
                {
                    "key": 3,
                    "doc_count": 1183
                },
                {
                    "key": 0,
                    "doc_count": 883
                }
            ]
        }
    }
```

这种方式分析起来比较麻烦，如果将来我们都是写这种方式来分析数据，简直是无法忍受。所以，Elasticsearch想要进军实时OLAP领域，是一定要支持SQL，能够使用SQL方式来进行统计和分析的。

##### 基于Elasticsearch SQL方式实现

```
GET /_sql?format=txt
{
    "query": "select payway, count(*) as order_cnt from order_idx group by payway"
}
```

这种方式要更加直观、简洁。

#### 基于JDBC方式统计不同方式的订单数量

Elasticsearch中还提供了基于JDBC的方式来访问数据。我们可以像操作MySQL一样操作Elasticsearch。使用步骤如下：
1.在pom.xml中添加以下镜像仓库

```
<repositories>
  <repository>
    <id>elastic.co</id>
    <url>https://artifacts.elastic.co/maven</url>
  </repository>
</repositories>
```

2.导入Elasticsearch JDBC驱动Maven依赖

```
<dependency>
  <groupId>org.elasticsearch.plugin</groupId>
  <artifactId>x-pack-sql-jdbc</artifactId>
  <version>7.6.1</version>
</dependency>
```

3.驱动

org.elasticsearch.xpack.sql.jdbc.EsDriver

4.JDBC URL

jdbc:es :// http:// host:port

5.开启X-pack高阶功能试用，如果不开启试用，会报如下错误

```
current license is non-compliant for [jdbc]
```

在node1.itcast.cn节点上执行：

```
curl http://node1.itcast.cn:9200/_license/start_trial?acknowledge=true -X POST
{"acknowledged":true,"trial_was_started":true,"type":"trial"}
```

**试用期为30天。**

参考代码：

```
/**
 * 基于JDBC访问Elasticsearch
 */
public class ElasticJdbc {

    public static void main(String[] args) throws Exception {
        Class.forName("org.elasticsearch.xpack.sql.jdbc.EsDriver");

        Connection connection = DriverManager.getConnection("jdbc:es://http://node1.itcast.cn:9200");
        PreparedStatement ps = connection.prepareStatement("select payway, count(*) as order_cnt from order_idx group by payway");
        ResultSet resultSet = ps.executeQuery();

        while(resultSet.next()) {
            int payway = resultSet.getInt("payway");
            int order_cnt = resultSet.getInt("order_cnt");
            System.out.println("支付方式: " + payway + " 订单数量: " + order_cnt);
        }

        resultSet.close();
        ps.close();
        connection.close();
    }
}
```

注意：如果在IDEA中无法下载依赖，请参考以下操作：
在Idea的File -->settings中，设置Maven的importing和Runner参数，忽略证书检查即可。(Eclipse下解决原理类似，设置maven运行时参数)，并尝试手动执行Maven compile执行编译。
具体参数：-Dmaven.multiModuleProjectDirectory=$MAVEN_HOME -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true

![image.png](https://image.hyly.net/i/2025/09/25/f2fb3e25904c6245401b425fedcf368a-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/ba2f81a7b7b3192cfa490bb5ae85cdf8-0.webp)

#### 统计不同支付方式订单数，并按照订单数量倒序排序

```
GET /_sql?format=txt
{
    "query": "select payway, count(*) as order_cnt from order_idx group by payway order by order_cnt desc"
}
```

#### 只统计「已付款」状态的不同支付方式的订单数量

```
GET /_sql?format=txt
{
    "query": "select payway, count(*) as order_cnt from order_idx where status = '已付款' group by payway order by order_cnt desc"
}
```

### 统计不同用户的总订单数量、总订单金额

```
GET /_sql?format=txt
{
    "query": "select userid, count(1) as cnt, sum(pay_money) as total_money from order_idx group by userid"
}
```

### Elasticsearch SQL目前的一些限制

目前Elasticsearch SQL还存在一些限制。例如：不支持JOIN、不支持较复杂的子查询。所以，有一些相对复杂一些的功能，还得借助于DSL方式来实现。

## 常见问题处理

### elasticsearch.keystore  AccessDeniedException

```
Exception in thread "main" org.elasticsearch.bootstrap.BootstrapException: java.nio.file.AccessDeniedException: /export/server/es/elasticsearch-7.6.1/config/elasticsearch.keystore
Likely root cause: java.nio.file.AccessDeniedException: /export/server/es/elasticsearch-7.6.1/config/elasticsearch.keystore
        at java.base/sun.nio.fs.UnixException.translateToIOException(UnixException.java:90)
        at java.base/sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:111)
        at java.base/sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:116)
        at java.base/sun.nio.fs.UnixFileSystemProvider.newByteChannel(UnixFileSystemProvider.java:219)
        at java.base/java.nio.file.Files.newByteChannel(Files.java:374)
        at java.base/java.nio.file.Files.newByteChannel(Files.java:425)
        at org.apache.lucene.store.SimpleFSDirectory.openInput(SimpleFSDirectory.java:77)
        at org.elasticsearch.common.settings.KeyStoreWrapper.load(KeyStoreWrapper.java:219)
        at org.elasticsearch.bootstrap.Bootstrap.loadSecureSettings(Bootstrap.java:234)
        at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:305)
        at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:170)
        at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:161)
        at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86)
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:125)
        at org.elasticsearch.cli.Command.main(Command.java:90)
        at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:126)
        at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:92)
```

解决方案：
将/export/server/es/elasticsearch-7.6.1/config/elasticsearch.keystore owner设置为itcast
chown itcast /export/server/es/elasticsearch-7.6.1/config/elasticsearch.keystore

## Beats

Beats是一个开放源代码的数据发送器。我们可以把Beats作为一种代理安装在我们的服务器上，这样就可以比较方便地将数据发送到Elasticsearch或者Logstash中。Elastic Stack提供了多种类型的Beats组件。

<figure class='table-figure'><table>
<thead>
<tr><th>审计数据</th><th>AuditBeat</th></tr></thead>
<tbody><tr><td>日志文件</td><td>FileBeat</td></tr><tr><td>云数据</td><td>FunctionBeat</td></tr><tr><td>可用性数据</td><td>HeartBeat</td></tr><tr><td>系统日志</td><td>JournalBeat</td></tr><tr><td>指标数据</td><td>MetricBeat</td></tr><tr><td>网络流量数据</td><td>PacketBeat</td></tr><tr><td>Windows事件日志</td><td>Winlogbeat</td></tr></tbody>
</table></figure>

![image.png](https://image.hyly.net/i/2025/09/25/dc88b2993f039dfb3c510bc34d26fac7-0.webp)

Beats可以直接将数据发送到Elasticsearch或者发送到Logstash，基于Logstash可以进一步地对数据进行处理，然后将处理后的数据存入到Elasticsearch，最后使用Kibana进行数据可视化。

### FileBeat简介

FileBeat专门用于转发和收集日志数据的轻量级采集工具。它可以为作为代理安装在服务器上，FileBeat监视指定路径的日志文件，收集日志数据，并将收集到的日志转发到Elasticsearch或者Logstash。

### FileBeat的工作原理

启动FileBeat时，会启动一个或者多个输入（Input），这些Input监控指定的日志数据位置。FileBeat会针对每一个文件启动一个Harvester（收割机）。Harvester读取每一个文件的日志，将新的日志发送到libbeat，libbeat将数据收集到一起，并将数据发送给输出（Output）。

![image.png](https://image.hyly.net/i/2025/09/25/59002349862ddc7e5df19316a8c906fc-0.webp)

### 安装FileBeat

安装FileBeat只需要将FileBeat Linux安装包上传到Linux系统，并将压缩包解压到系统就可以了。FileBeat官方下载地址：https://www.elastic.co/cn/downloads/past-releases/filebeat-7-6-1

上传FileBeat安装到Linux，并解压。

```
tar -xvzf filebeat-7.6.1-linux-x86_64.tar.gz -C ../server/es/
```

### 使用FileBeat采集Kafka日志到Elasticsearch

#### 需求分析

在资料中有一个kafka_server.log.tar.gz压缩包，里面包含了很多的Kafka服务器日志，现在我们为了通过在Elasticsearch中快速查询这些日志，定位问题。我们需要用FileBeats将日志数据上传到Elasticsearch中。

问题：

首先，我们要指定FileBeat采集哪些Kafka日志，因为FileBeats中必须知道采集存放在哪儿的日志，才能进行采集。

其次，采集到这些数据后，还需要指定FileBeats将采集到的日志输出到Elasticsearch，那么Elasticsearch的地址也必须指定。

#### 配置FileBeats

FileBeats配置文件主要分为两个部分。
1.inputs
2.output
从名字就能看出来，一个是用来输入数据的，一个是用来输出数据的。

##### input配置

```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
```

在FileBeats中，可以读取一个或多个数据源。

![image.png](https://image.hyly.net/i/2025/09/25/30642cc306175a954c7525c1cab60af6-0.webp)

##### output配置

![image.png](https://image.hyly.net/i/2025/09/25/422f079fdb7c67105e8cb393677e1d74-0.webp)

默认FileBeat会将日志数据放入到名称为：filebeat-%filebeat版本号%-yyyy.MM.dd 的索引中。

PS：
FileBeats中的filebeat.reference.yml包含了FileBeats所有支持的配置选项。

#### 配置文件

1.创建配置文件

```
cd /export/server/es/filebeat-7.6.1-linux-x86_64
touch filebeat_kafka_log.yml
vim filebeat_kafka_log.yml
```

2.复制以下到配置文件中

```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/kafka/log/server.log.*

output.elasticsearch:
    hosts: ["node1.itcast.cn:9200", "node2.itcast.cn:9200", "node3.itcast.cn:9200"]
```

#### 运行FileBeat

1.启动Elasticsearch
在每个节点上执行以下命令，启动Elasticsearch集群：

```
nohup /export/server/es/elasticsearch-7.6.1/bin/elasticsearch 2>&1 &
```

2.运行FileBeat

```
./filebeat -c filebeat_kafka_log.yml -e
```

3.将日志数据上传到/var/kafka/log，并解压

```
mkdir -p /var/kafka/log
cd /var/kafka/log
rz
tar -xvzf kafka_server.log.tar.gz
```

#### 查询数据

通过head插件，我们可以看到filebeat采集了日志消息，并写入到Elasticsearch集群中。

![image.png](https://image.hyly.net/i/2025/09/25/e283f76a1ae9603d0ec2249b580058a7-0.webp)

**ILM：**索引生命周期管理所需的索引
**filebeat-7.6.1：**在ES中，可以创建索引的别名，可以使用别名来指向一个或多个索引，类似于windows的快捷方式。因为Elasticsearch中的索引创建后是不允许修改的，很多的业务场景下单一索引无法满足需求。别名也有利于ILM所以索引生命周期管理。

我们也可以看到索引中的数据：

![image.png](https://image.hyly.net/i/2025/09/25/99f77de3e0690055683e1d096eefc01f-0.webp)

1.查看索引信息

```
GET /_cat/indices?v
    {
        "health": "green",
        "status": "open",
        "index": "filebeat-7.6.1-2020.05.29-000001",
        "uuid": "dplqB_hTQq2XeSk6S4tccQ",
        "pri": "1",
        "rep": "1",
        "docs.count": "213780",
        "docs.deleted": "0",
        "store.size": "71.9mb",
        "pri.store.size": "35.8mb"
    }
```

2.查询索引库中的数据

```
GET /filebeat-7.6.1-2020.05.29-000001/_search   
  
            {
                "_index": "filebeat-7.6.1-2020.05.29-000001",
                "_type": "_doc",
                "_id": "-72pX3IBjTeClvZff0CB",
                "_score": 1,
                "_source": {
                    "@timestamp": "2020-05-29T09:00:40.041Z",
                    "log": {
                        "offset": 55433,
                        "file": {
                            "path": "/var/kafka/log/server.log.2020-05-02-16"
                        }
                    },
                    "message": "[2020-05-02 16:01:30,682] INFO Socket connection established, initiating session, client: /192.168.88.100:46762, server: node1.itcast.cn/192.168.88.100:2181 (org.apache.zookeeper.ClientCnxn)",
                    "input": {
                        "type": "log"
                    },
                    "ecs": {
                        "version": "1.4.0"
                    },
                    "host": {
                        "name": "node1.itcast.cn"
                    },
                    "agent": {
                        "id": "b4c5c4dc-03c3-4ba4-9400-dc6afcb36d64",
                        "version": "7.6.1",
                        "type": "filebeat",
                        "ephemeral_id": "b8fbf7ab-bc37-46dd-86c7-fa7d74d36f63",
                        "hostname": "node1.itcast.cn"
                    }
                }
            }
```

FileBeat自动给我们添加了一些关于日志、采集类型、Host各种字段。

#### 解决一个日志涉及到多行问题

我们在日常日志的处理中，经常会碰到日志中出现异常的情况。类似下面的情况：

```
[2020-04-30 14:00:05,725] WARN [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Error when sending leader epoch request for Map(test_10m-2 -> (currentLeaderEpoch=Optional[161], leaderEpoch=158)) (kafka.server.ReplicaFetcherThread)
java.io.IOException: Connection to node2.itcast.cn:9092 (id: 1 rack: null) failed.
        at org.apache.kafka.clients.NetworkClientUtils.awaitReady(NetworkClientUtils.java:71)
        at kafka.server.ReplicaFetcherBlockingSend.sendRequest(ReplicaFetcherBlockingSend.scala:102)
        at kafka.server.ReplicaFetcherThread.fetchEpochEndOffsets(ReplicaFetcherThread.scala:310)
        at kafka.server.AbstractFetcherThread.truncateToEpochEndOffsets(AbstractFetcherThread.scala:208)
        at kafka.server.AbstractFetcherThread.maybeTruncate(AbstractFetcherThread.scala:173)
        at kafka.server.AbstractFetcherThread.doWork(AbstractFetcherThread.scala:113)
        at kafka.utils.ShutdownableThread.run(ShutdownableThread.scala:96)
[2020-04-30 14:00:05,725] INFO [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Retrying leaderEpoch request for partition test_10m-2 as the leader reported an error: UNKNOWN_SERVER_ERROR (kafka.server.ReplicaFetcherThread)
[2020-04-30 14:00:08,731] WARN [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Connection to node 1 (node2.itcast.cn/192.168.88.101:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
```

在FileBeat中，Harvest是逐行读取日志文件的。但上述的日志会出现一条日志，跨多行的情况。有异常信息时，肯定会出现多行。我们先来看一下，如果默认不处理这种情况会出现什么问题。

##### 导入错误日志

1.在/var/kafka/log中创建名为server.log.2020-09-10的日志文件

```
touch server.log.2020-09-10
```

2.将以下日志文本贴入到该文件中

```
vim server.log.2020-09-10

[2020-04-30 14:00:05,725] WARN [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Error when sending leader epoch request for Map(test_10m-2 -> (currentLeaderEpoch=Optional[161], leaderEpoch=158)) (kafka.server.ReplicaFetcherThread)
java.io.IOException: Connection to node2.itcast.cn:9092 (id: 1 rack: null) failed.
        at org.apache.kafka.clients.NetworkClientUtils.awaitReady(NetworkClientUtils.java:71)
        at kafka.server.ReplicaFetcherBlockingSend.sendRequest(ReplicaFetcherBlockingSend.scala:102)
        at kafka.server.ReplicaFetcherThread.fetchEpochEndOffsets(ReplicaFetcherThread.scala:310)
        at kafka.server.AbstractFetcherThread.truncateToEpochEndOffsets(AbstractFetcherThread.scala:208)
        at kafka.server.AbstractFetcherThread.maybeTruncate(AbstractFetcherThread.scala:173)
        at kafka.server.AbstractFetcherThread.doWork(AbstractFetcherThread.scala:113)
        at kafka.utils.ShutdownableThread.run(ShutdownableThread.scala:96)
[2020-04-30 14:00:05,725] INFO [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Retrying leaderEpoch request for partition test_10m-2 as the leader reported an error: UNKNOWN_SERVER_ERROR (kafka.server.ReplicaFetcherThread)
[2020-04-30 14:00:08,731] WARN [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Connection to node 1 (node2.itcast.cn/192.168.88.101:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2020-04-30 14:00:08,731] WARN [ReplicaFetcher replicaId=0, leaderId=1, fetcherId=0] Error when sending leader epoch request for Map(test_10m-2 -> (currentLeaderEpoch=Optional[161], leaderEpoch=158)) (kafka.server.ReplicaFetcherThread)
java.io.IOException: Connection to node2.itcast.cn:9092 (id: 1 rack: null) failed.
        at org.apache.kafka.clients.NetworkClientUtils.awaitReady(NetworkClientUtils.java:71)
        at kafka.server.ReplicaFetcherBlockingSend.sendRequest(ReplicaFetcherBlockingSend.scala:102)
        at kafka.server.ReplicaFetcherThread.fetchEpochEndOffsets(ReplicaFetcherThread.scala:310)
        at kafka.server.AbstractFetcherThread.truncateToEpochEndOffsets(AbstractFetcherThread.scala:208)
        at kafka.server.AbstractFetcherThread.maybeTruncate(AbstractFetcherThread.scala:173)

```

3.观察FileBeat，发现FileBeat已经针对该日志文件启动了Harvester，并读取到数据数据。

```
2020-05-29T19:11:01.236+0800    INFO    log/harvester.go:297    Harvester started for file: /var/kafka/log/server.log.2020-09-10
```

4.在Elasticsearch检索该文件。

注意：修改索引名

```
GET /filebeat-7.6.1-2020.05.29-000001/_search
{
    "query": {
        "match": {
            "log.file.path": "/var/kafka/log/server.log.2020-09-10"
        }
    }
}
```

我们发现，原本是一条日志中的异常信息，都被作为一条单独的消息来处理了~

![image.png](https://image.hyly.net/i/2025/09/25/88504f43b1e7aa4966af4a3b7ea1c5b1-0.webp)

这明显是不符合我们的预期的，我们想要的是将所有的异常消息合并到一条日志中。那针对这种情况该如何处理呢？

##### 问题分析

每条日志都是有统一格式的开头的，就拿Kafka的日志消息来说，[2020-04-30 14:00:05,725]这是一个统一的格式，如果不是以这样的形式开头，说明这一行肯定是属于某一条日志，而不是独立的一条日志。所以，我们可以通过日志的开头来判断某一行是否为新的一条日志。

##### FileBeat多行配置选项

在FileBeat的配置中，专门有一个解决一条日志跨多行问题的配置。主要为以下三个配置：

```
multiline.pattern: ^\[
multiline.negate: false
multiline.match: after
```

1. multiline.pattern表示能够匹配一条日志的模式，默认配置的是以[开头的才认为是一条新的日志。^\[表示匹配以[开头的消息
2. multiline.negate:
	1. 配置为false，正常匹配（默认），表示不需要取反
	2. 配置为true，表示取反

multiline.match:表示是否将未匹配到的行追加到上一日志，还是追加到下一个日志。

```
## The regexp Pattern that has to be matched. The example pattern matches all lines starting with [
  #multiline.pattern: ^\[

  ## Defines if the pattern set under pattern should be negated or not. Default is false.
  #multiline.negate: false

  ## Match can be set to "after" or "before". It is used to define if lines should be append to a pattern
  ## that was (not) matched before or after or as long as a pattern is not matched based on negate.
  ## Note: After is the equivalent to previous and before is the equivalent to to next in Logstash
  #multiline.match: after
```

##### 重新配置FileBeat

1.修改filebeat.yml，并添加以下内容

```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/kafka/log/server.log.*
  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after

output.elasticsearch:
    hosts: ["node1.itcast.cn:9200", "node2.itcast.cn:9200", "node3.itcast.cn:9200"]
```

2.删除「注册表」/data.json

```
rm –rf /export/server/es/filebeat-7.6.1-linux-x86_64/data/registry/filebeat/data.json
```

3.删除之前创建的索引

```
delete /filebeat-7.6.1-2020.05.29-000001
```

4.重新启动FileBeat

```
./filebeat -c filebeat_kafka_log.yml -e
```

5.查看异常索引数据

### FileBeat是如何工作的

FileBeat主要由input和harvesters（收割机）组成。这两个组件协同工作，并将数据发送到指定的输出。

#### input和harvester

##### inputs（输入）

1. input是负责管理Harvesters和查找所有要读取的文件的组
2. 如果输入类型是 log，input组件会查找磁盘上与路径描述的所有文件，并为每个文件启动一个Harvester，每个输入都独立地运行

##### Harvesters（收割机）

1. Harvesters负责读取单个文件的内容，它负责打开/关闭文件，并逐行读取每个文件的内容，将读取到的内容发送给输出
2. 每个文件都会启动一个Harvester
3. Harvester运行时，文件将处于打开状态。如果文件在读取时，被移除或者重命名，FileBeat将继续读取该文件

#### FileBeats如何保持文件状态

1. FileBeat保存每个文件的状态，并定时将状态信息保存在磁盘的「注册表」文件中
2. 该状态记录Harvester读取的最后一次偏移量，并确保发送所有的日志数据
3. 如果输出（Elasticsearch或者Logstash）无法访问，FileBeat会记录成功发送的最后一行，并在输出（Elasticsearch或者Logstash）可用时，继续读取文件发送数据
4. 在运行FileBeat时，每个input的状态信息也会保存在内存中，重新启动FileBeat时，会从「注册表」文件中读取数据来重新构建状态。

在/export/server/es/filebeat-7.6.1-linux-x86_64/data目录中有一个Registry文件夹，里面有一个data.json，该文件中记录了Harvester读取日志的offset。

![image.png](https://image.hyly.net/i/2025/09/25/5293a377057617dc7d7d9b1dd2a0d90d-0.webp)

## Logstash

### 简介

Logstash是一个开源的数据采集引擎。它可以动态地将不同来源的数据统一采集，并按照指定的数据格式进行处理后，将数据加载到其他的目的地。最开始，Logstash主要是针对日志采集，但后来Logstash开发了大量丰富的插件，所以，它可以做更多的海量数据的采集。

它可以处理各种类型的日志数据，例如：Apache的web log、Java的log4j日志数据，或者是系统、网络、防火墙的日志等等。它也可以很容易的和Elastic Stack的Beats组件整合，也可以很方便的和关系型数据库、NoSQL数据库、Kafka、RabbitMQ等整合。

![image.png](https://image.hyly.net/i/2025/09/25/d463407c9820293f36689f771ec315ac-0.webp)

#### 经典架构

![image.png](https://image.hyly.net/i/2025/09/25/db80384f9d2438a768aec24d0f6a3172-0.webp)

#### 对比Flume

1.Apache Flume是一个通用型的数据采集平台，它通过配置source、channel、sink来实现数据的采集，支持的平台也非常多。而Logstash结合Elastic Stack的其他组件配合使用，开发、应用都会简单很多
2.Logstash比较关注数据的预处理，而Flume跟偏重数据的传输，几乎没有太多的数据解析预处理，仅仅是数据的产生，封装成Event然后传输。

#### 对比FileBeat

1. logstash是jvm跑的，资源消耗比较大
2. 而FileBeat是基于golang编写的，功能较少但资源消耗也比较小，更轻量级
3. logstash 和filebeat都具有日志收集功能，Filebeat更轻量，占用资源更少
4. logstash 具有filter功能，能过滤分析日志
5. 一般结构都是filebeat采集日志，然后发送到消息队列，redis，kafka中然后logstash去获取，利用filter功能过滤分析，然后存储到elasticsearch中
6. FileBeat和Logstash配合，实现背压机制

![image.png](https://image.hyly.net/i/2025/09/25/c01d5aff11e1567e506cf10b1a060286-0.webp)

### 安装Logstash和Kibana

#### 安装Logstash

1.下载Logstash
https://www.elastic.co/cn/downloads/past-releases/logstash-7-6-1
此处：我们可以选择资料中的logstash-7.6.1.zip安装包。

2.解压Logstash到指定目录

```
unzip logstash-7.6.1 -d /export/server/es/
```

3.运行测试

```
cd /export/server/es/logstash-7.6.1/
bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

等待一会，让Logstash启动完毕。

```
Sending Logstash logs to /export/server/es/logstash-7.6.1/logs which is now configured via log4j2.properties
[2020-05-28T16:31:44,159][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2020-05-28T16:31:44,264][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.6.1"}
[2020-05-28T16:31:45,631][INFO ][org.reflections.Reflections] Reflections took 37 ms to scan 1 urls, producing 20 keys and 40 values 
[2020-05-28T16:31:46,532][WARN ][org.logstash.instrument.metrics.gauge.LazyDelegatingGauge][main] A gauge metric of an unknown type (org.jruby.RubyArray) has been create for key: cluster_uuids. This may result in invalid serialization.  It is recommended to log an issue to the responsible developer/development team.
[2020-05-28T16:31:46,560][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>2, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>250, "pipeline.sources"=>["config string"], :thread=>"#<Thread:0x3ccbc15b run>"}
[2020-05-28T16:31:47,268][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
The stdin plugin is now waiting for input:
[2020-05-28T16:31:47,348][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2020-05-28T16:31:47,550][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
```

然后，随便在控制台中输入内容，等待Logstash的输出。

```
{
"host" => "node1.itcast.cn",
"message" => "hello logstash",
"@version" => "1",
"@timestamp" => 2020-05-28T08:32:31.007Z
}
```

ps：
-e选项表示，直接把配置放在命令中，这样可以有效快速进行测试

#### 安装Kibana

为了方便一会开发Logstash的grok插件，我们提前把Kibana安装好。

![image.png](https://image.hyly.net/i/2025/09/25/5e4378445eae28895a52b1d80a5ec671-0.webp)

### 采集Apache Web服务器日志

#### 需求

Apache的Web Server会产生大量日志，当我们想要对这些日志检索分析。就需要先把这些日志导入到Elasticsearch中。此处，我们就可以使用Logstash来实现日志的采集。

打开这个文件，如下图所示。我们发现，是一个纯文本格式的日志。如下图所示：

![image.png](https://image.hyly.net/i/2025/09/25/12a176e83266e1b24287ab0767c1c757-0.webp)

这个日志其实由一个个的字段拼接而成，参考以下表格。

<figure class='table-figure'><table>
<thead>
<tr><th>字段名</th><th>说明</th></tr></thead>
<tbody><tr><td>client IP</td><td>浏览器端IP</td></tr><tr><td>timestamp</td><td>请求的时间戳</td></tr><tr><td>method</td><td>请求方式（GET/POST）</td></tr><tr><td>uri</td><td>请求的链接地址</td></tr><tr><td>status</td><td>服务器端响应状态</td></tr><tr><td>length</td><td>响应的数据长度</td></tr><tr><td>reference</td><td>从哪个URL跳转而来</td></tr><tr><td>browser</td><td>浏览器</td></tr></tbody>
</table></figure>

因为最终我们需要将这些日志数据存储在Elasticsearch中，而Elasticsearch是有模式（schema）的，而不是一个大文本存储所有的消息，而是需要将字段一个个的保存在Elasticsearch中。所以，我们需要在Logstash中，提前将数据解析好，将日志文本行解析成一个个的字段，然后再将字段保存到Elasticsearch中。

#### 准备日志数据

将Apache服务器日志上传到 /var/apache/log 目录

```
mkdir -p /var/apache/log
rz
```

#### 使用FileBeats将日志发送到Logstash

在使用Logstash进行数据解析之前，我们需要使用FileBeat将采集到的数据发送到Logstash。之前，我们使用的FileBeat是通过FileBeat的Harvester组件监控日志文件，然后将日志以一定的格式保存到Elasticsearch中，而现在我们需要配置FileBeats将数据发送到Logstash。

FileBeat这一端配置以下即可：

```
#----------------------------- Logstash output ---------------------------------
#output.logstash:
  ## Boolean flag to enable or disable the output module.
  #enabled: true

  ## The Logstash hosts
  #hosts: ["localhost:5044"]
```

hosts配置的是Logstash监听的IP地址/机器名以及端口号。
**准备FileBeat配置文件**

```
cd /export/server/es/filebeat-7.6.1-linux-x86_64
touch filebeat-logstash.yml
vim filebeat-logstash.yml
```

因为Apache的web log日志都是以IP地址开头的，所以我们需要修改下匹配字段。

```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/apache/log/access.*
  multiline.pattern: '^\\d+\\.\\d+\\.\\d+\\.\\d+ '
  multiline.negate: true
  multiline.match: after

output.logstash:
  enabled: true
  hosts: ["node1.itcast.cn:5044"]
```

注意该配置：

```
  multiline.pattern: '^\\d+\\.\\d+\\.\\d+\\.\\d+ '
  multiline.negate: false
  multiline.match: after
```

表示以ip地址开头的行追加到上一行

**启动FileBeat，并指定使用新的配置文件**

```
./filebeat -e -c filebeat-logstash.yml
```

FileBeat将尝试建立与Logstash监听的IP和端口号进行连接。但此时，我们并没有开启并配置Logstash，所以FileBeat是无法连接到Logstash的。

```
2020-06-01T11:28:47.585+0800    ERROR   pipeline/output.go:100  Failed to connect to backoff(async(tcp://node1.itcast.cn:5044)): dial tcp 192.168.88.100:5044: connect: connection refused
```

#### 配置Logstash接收FileBeat数据并打印

Logstash的配置文件和FileBeat类似，它也需要有一个input、和output。基本格式如下：

```
## #号表示添加注释
## input表示要接收的数据
input {
}

## file表示对接收到的数据进行过滤处理
filter {

}

## output表示将数据输出到其他位置
output {
}
```

**配置从FileBeat接收数据**

```
cd /export/server/es/logstash-7.6.1
vim config/filebeat-print.conf
input {
  beats {
    port => 5044
  }
}

output {
  stdout {
    codec => rubydebug
  }
}
```

测试logstash配置是否正确

```
bin/logstash -f config/filebeat-print.conf --config.test_and_exit

[2020-06-01T11:46:33,940][INFO ][logstash.runner          ] Using config.test_and_exit mode. Config Validation Result: OK. Exiting Logstash
```

启动logstash

```
bin/logstash -f config/filebeat-print.conf --config.reload.automatic
```

reload.automatic：修改配置文件时自动重新加载

**测试**
在/var/apache/log创建一个test文件，并写入以下内容

```
cd /var/apache/log
vim test
181.54.88.191 - - [8/May/2020:00:27:20 +0819] "POST /itcast.cn/index1.html HTTP/1.1" 200 900 "www.jd.com" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900"
```

再创建access.log.1文件，使用cat test >> access.log往日志文件中追加内容。

```
touch access.log.1
cat test >> access.log.1
```

当我们启动Logstash之后，就可以发现Logstash会打印出来从FileBeat接收到的数据：

```
{
           "log" => {
          "file" => {
            "path" => "/var/apache/log/access.log.1"
        },
        "offset" => 825
    },
         "input" => {
        "type" => "log"
    },
         "agent" => {
        "ephemeral_id" => "d4c3b652-4533-4ebf-81f9-a0b78c0d4b05",
             "version" => "7.6.1",
                "type" => "filebeat",
                  "id" => "b4c5c4dc-03c3-4ba4-9400-dc6afcb36d64",
            "hostname" => "node1.itcast.cn"
    },
    "@timestamp" => 2020-06-01T09:07:55.236Z,
           "ecs" => {
        "version" => "1.4.0"
    },
          "host" => {
        "name" => "node1.itcast.cn"
    },
          "tags" => [
        [0] "beats_input_codec_plain_applied"
    ],
       "message" => "235.9.200.242 - - [15/Apr/2015:00:27:19 +0849] \"POST /itcast.cn/bigdata.html 200 45 \"www.baidu.com\" \"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900 144.180.122.249",
      "@version" => "1"
}
```

#### Logstash输出数据到Elasticsearch

通过控制台，我们发现Logstash input接收到的数据没有经过任何处理就发送给了output组件。而其实我们需要将数据输出到Elasticsearch。所以，我们修改Logstash的output配置。配置输出Elasticsearch只需要配置以下就可以了：

```
output {
    elasticsearch {
        hosts => [ "localhost:9200" ]
    }}
```

操作步骤：
1.重新拷贝一份配置文件

```
cd /export/server/es/logstash-7.6.1
touch config/filebeat-es.conf
```

2.将output修改为Elasticsearch

```
vim config/filebeat-es.conf
input {
  beats {
    port => 5044
  }
}

output {
 elasticsearch {
   hosts => [ "node1.itcast.cn:9200","node2.itcast.cn:9200","node3.itcast.cn:9200"]
 }
 stdout {
    codec => rubydebug
 }
}
```

3.重新启动Logstash

```
bin/logstash -f config/filebeat-es.conf --config.reload.automatic
```

4.追加一条日志到监控的文件中，并查看Elasticsearch中的索引、文档

```
cat test >> access.log.1 
```

5. 查看索引数据

![image.png](https://image.hyly.net/i/2025/09/25/666b08ec99f558d21cb2e6aee1d4c157-0.webp)

GET /_cat/indices?v
我们在Elasticsearch中发现一个以logstash开头的索引。

```
    {
        "health": "green",
        "status": "open",
        "index": "logstash-2020.06.01-000001",
        "uuid": "147Uwl1LRb-HMFERUyNEBw",
        "pri": "1",
        "rep": "1",
        "docs.count": "2",
        "docs.deleted": "0",
        "store.size": "44.8kb",
        "pri.store.size": "22.4kb"
    }
```

```
// 查看索引库的数据
GET /logstash-2020.06.01-000001/_search?format=txt
{
    "from": 0,
    "size": 1
}
```

我们可以获取到以下数据：

```
                    "@timestamp": "2020-06-01T09:38:00.402Z",
                    "tags": [
                        "beats_input_codec_plain_applied"
                    ],
                    "host": {
                        "name": "node1.itcast.cn"
                    },
                    "@version": "1",
                    "log": {
                        "file": {
                            "path": "/var/apache/log/access.log.1"
                        },
                        "offset": 1343
                    },
                    "agent": {
                        "version": "7.6.1",
                        "ephemeral_id": "d4c3b652-4533-4ebf-81f9-a0b78c0d4b05",
                        "id": "b4c5c4dc-03c3-4ba4-9400-dc6afcb36d64",
                        "hostname": "node1.itcast.cn",
                        "type": "filebeat"
                    },
                    "input": {
                        "type": "log"
                    },
                    "message": "235.9.200.242 - - [15/Apr/2015:00:27:19 +0849] \"POST /itcast.cn/bigdata.html 200 45 \"www.baidu.com\" \"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900 144.180.122.249",
                    "ecs": {
                        "version": "1.4.0"
                    }

```

从输出返回结果，我们可以看到，日志确实已经保存到了Elasticsearch中，而且我们看到消息数据是封装在名为message中的，其他的数据也封装在一个个的字段中。我们其实更想要把消息解析成一个个的字段。例如：IP字段、时间、请求方式、请求URL、响应结果，这样。

#### Logstash过滤器

在Logstash中可以配置过滤器Filter对采集到的数据进行中间处理，在Logstash中，有大量的插件供我们使用。参考官网：
https://www.elastic.co/guide/en/logstash/7.6/filter-plugins.html
此处，我们重点来讲解Grok插件。

##### 查看Logstash已经安装的插件

```
cd /export/server/es/logstash-7.6.1/
bin/logstash-plugin list
```

##### Grok插件

Grok是一种将非结构化日志解析为结构化的插件。这个工具非常适合用来解析系统日志、Web服务器日志、MySQL或者是任意其他的日志格式。
Grok官网：https://www.elastic.co/guide/en/logstash/7.6/plugins-filters-grok.html

##### Grok语法

Grok是通过模式匹配的方式来识别日志中的数据,可以把Grok插件简单理解为升级版本的正则表达式。它拥有更多的模式，默认，Logstash拥有120个模式。如果这些模式不满足我们解析日志的需求，我们可以直接使用正则表达式来进行匹配。
官网：https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns

grok模式的语法是：%{SYNTAX:SEMANTIC}
SYNTAX指的是Grok模式名称，SEMANTIC是给模式匹配到的文本字段名。例如：

```
%{NUMBER:duration} %{IP:client}
duration表示：匹配一个数字，client表示匹配一个IP地址。
```

默认在Grok中，所有匹配到的的数据类型都是字符串，如果要转换成int类型（目前只支持int和float），可以这样：%{NUMBER:duration:int} %{IP:client}

以下是常用的Grok模式：

<figure class='table-figure'><table>
<thead>
<tr><th>NUMBER</th><th>匹配数字（包含：小数）</th></tr></thead>
<tbody><tr><td>INT</td><td>匹配整形数字</td></tr><tr><td>POSINT</td><td>匹配正整数</td></tr><tr><td>WORD</td><td>匹配单词</td></tr><tr><td>DATA</td><td>匹配所有字符</td></tr><tr><td>IP</td><td>匹配IP地址</td></tr><tr><td>PATH</td><td>匹配路径</td></tr></tbody>
</table></figure>

##### 用法

![image.png](https://image.hyly.net/i/2025/09/25/b41075839a32670668f7048f3a9adaf9-0.webp)

```
    filter {
      grok {
        match => { "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}" }
      }
    }
```

#### 匹配日志中的IP、日期并打印

```
90.224.57.84 - - [15/Apr/2020:00:27:19 +0800] "POST /report HTTP/1.1" 404 21 "www.baidu.com" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900"
```

**配置Grok过滤插件**

1.配置Logstash
vim config/filebeat-filter-print.conf

```
input {
    beats {
        port => 5044
    }
}

filter {
    grok {
        match => { 
            "message" => "%{IP:ip} - - \[%{HTTPDATE:date}\]" 
        }
    }   
}

output {
    stdout {
        codec => rubydebug
    }
}
```

2.启动Logstash

```
bin/logstash -f config/filebeat-filter-print.conf --config.reload.automatic
```

```
{
           "log" => {
        "offset" => 1861,
          "file" => {
            "path" => "/var/apache/log/access.log.1"
        }
    },
         "input" => {
        "type" => "log"
    },
          "tags" => [
        [0] "beats_input_codec_plain_applied"
    ],
          "date" => "15/Apr/2015:00:27:19 +0849",
           "ecs" => {
        "version" => "1.4.0"
    },
    "@timestamp" => 2020-06-01T11:02:05.809Z,
       "message" => "235.9.200.242 - - [15/Apr/2015:00:27:19 +0849] \"POST /itcast.cn/bigdata.html 200 45 \"www.baidu.com\" \"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900 144.180.122.249",
          "host" => {
        "name" => "node1.itcast.cn"
    },
            "ip" => "235.9.200.242",
         "agent" => {
            "hostname" => "node1.itcast.cn",
             "version" => "7.6.1",
        "ephemeral_id" => "d4c3b652-4533-4ebf-81f9-a0b78c0d4b05",
                  "id" => "b4c5c4dc-03c3-4ba4-9400-dc6afcb36d64",
                "type" => "filebeat"
    },
      "@version" => "1"
}
```

我们看到，经过Grok过滤器插件处理之后，我们已经获取到了ip和date两个字段。接下来，我们就可以继续解析其他的字段。

#### 解析所有字段

将日志解析成以下字段：

<figure class='table-figure'><table>
<thead>
<tr><th>字段名</th><th>说明</th></tr></thead>
<tbody><tr><td>client IP</td><td>浏览器端IP</td></tr><tr><td>timestamp</td><td>请求的时间戳</td></tr><tr><td>method</td><td>请求方式（GET/POST）</td></tr><tr><td>uri</td><td>请求的链接地址</td></tr><tr><td>status</td><td>服务器端响应状态</td></tr><tr><td>length</td><td>响应的数据长度</td></tr><tr><td>reference</td><td>从哪个URL跳转而来</td></tr><tr><td>browser</td><td>浏览器</td></tr></tbody>
</table></figure>

为了方便进行Grok开发，此处使用Kibana来进行调试：
我们使用IP就可以把前面的IP字段匹配出来，使用HTTPDATE可以将后面的日期匹配出来。
为了方便测试，我们可以使用Kibana来进行Grok开发：

![image.png](https://image.hyly.net/i/2025/09/25/e0616b4ce1d2e21e8fd41b8e624228ff-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/ebe80155545ac8a9473573faf7098a6e-0.webp)

可以在Kibana中先把Grok的表达式写好，然后再放入到Logstash的配置文件中，这样可以大大提升调试的效率。

1.修改Logstash配置文件

```
input {
    beats {
        port => 5044
    }
}

filter {
    grok {
        match => { 
            "message" => "%{IP:ip} - - \[%{HTTPDATE:date}\] \"%{WORD:method} %{PATH:uri} %{DATA}\" %{INT:status} %{INT:length} \"%{DATA:reference}\" \"%{DATA:browser}\"" 
        }
    }   
}

output {
    stdout {
        codec => rubydebug
    }
}
```

2.测试并启动Logstash
我们可以看到，8个字段都已经成功解析。

```
{
     "reference" => "www.baidu.com",
      "@version" => "1",
           "ecs" => {
        "version" => "1.4.0"
    },
    "@timestamp" => 2020-06-02T03:30:10.048Z,
            "ip" => "235.9.200.241",
        "method" => "POST",
           "uri" => "/itcast.cn/bigdata.html",
         "agent" => {
                  "id" => "b4c5c4dc-03c3-4ba4-9400-dc6afcb36d64",
        "ephemeral_id" => "734ae9d8-bcdc-4be6-8f97-34387fcde972",
             "version" => "7.6.1",
            "hostname" => "node1.itcast.cn",
                "type" => "filebeat"
    },
        "length" => "45",
        "status" => "200",
           "log" => {
          "file" => {
            "path" => "/var/apache/log/access.log"
        },
        "offset" => 1
    },
         "input" => {
        "type" => "log"
    },
          "host" => {
        "name" => "node1.itcast.cn"
    },
          "tags" => [
        [0] "beats_input_codec_plain_applied"
    ],
       "browser" => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900",
          "date" => "15/Apr/2015:00:27:19 +0849",
       "message" => "235.9.200.241 - - [15/Apr/2015:00:27:19 +0849] \"POST /itcast.cn/bigdata.html HTTP/1.1\" 200 45 \"www.baidu.com\" \"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900\""
}
```

#### 将数据输出到Elasticsearch

到目前为止，我们已经通过了Grok Filter可以将日志消息解析成一个一个的字段，那现在我们需要将这些字段保存到Elasticsearch中。我们看到了Logstash的输出中，有大量的字段，但如果我们只需要保存我们需要的8个，该如何处理呢？而且，如果我们需要将日期的格式进行转换，我们又该如何处理呢？

##### 过滤出来需要的字段

要过滤出来我们需要的字段。我们需要使用mutate插件。mutate插件主要是作用在字段上，例如：它可以对字段进行重命名、删除、替换或者修改结构。

![image.png](https://image.hyly.net/i/2025/09/25/b6acfda836aedf0ff66953f49162b7fa-0.webp)

官方文档：https://www.elastic.co/guide/en/logstash/7.6/plugins-filters-mutate.html
例如，mutate插件可以支持以下常用操作

![image.png](https://image.hyly.net/i/2025/09/25/e351034743324be5aa40342a85466653-0.webp)

配置：
注意：此处为了方便进行类型的处理，将status、length指定为int类型。

```
input {
    beats {
        port => 5044
    }
}

filter {
    grok {
        match => { 
            "message" => "%{IP:ip} - - \[%{HTTPDATE:date}\] \"%{WORD:method} %{PATH:uri} %{DATA}\" %{INT:status:int} %{INT:length:int} \"%{DATA:reference}\" \"%{DATA:browser}\"" 
        }
    }
    mutate {
        enable_metric => "false"
        remove_field => ["message", "log", "tags", "@timestamp", "input", "agent", "host", "ecs", "@version"]
    }
}

output {
    stdout {
        codec => rubydebug
    }
}
```

##### 转换日期格式

要将日期格式进行转换，我们可以使用Date插件来实现。该插件专门用来解析字段中的日期，官方说明文档：https://www.elastic.co/guide/en/logstash/7.6/plugins-filters-date.html

用法如下：

![image.png](https://image.hyly.net/i/2025/09/25/6f67213f5b47668b412da5df8118fc24-0.webp)

将date字段转换为「年月日 时分秒」格式。默认字段经过date插件处理后，会输出到@timestamp字段，所以，我们可以通过修改target属性来重新定义输出字段。

Logstash配置修改为如下：

```
input {
    beats {
        port => 5044
    }
}

filter {
    grok {
        match => { 
            "message" => "%{IP:ip} - - \[%{HTTPDATE:date}\] \"%{WORD:method} %{PATH:uri} %{DATA}\" %{INT:status:int} %{INT:length:int} \"%{DATA:reference}\" \"%{DATA:browser}\"" 
        }
    }
    mutate {
        enable_metric => "false"
        remove_field => ["message", "log", "tags", "@timestamp", "input", "agent", "host", "ecs", "@version"]
    }
    date {
        match => ["date","dd/MMM/yyyy:HH:mm:ss Z","yyyy-MM-dd HH:mm:ss"]
        target => "date"
    }
}

output {
    stdout {
        codec => rubydebug
    }
}
```

启动Logstash：

```
bin/logstash -f config/filebeat-filter-print.conf --config.reload.automatic
```

```
{
       "status" => "200",
    "reference" => "www.baidu.com",
       "method" => "POST",
      "browser" => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.4549.400 QQBrowser/9.7.12900",
           "ip" => "235.9.200.241",
       "length" => "45",
          "uri" => "/itcast.cn/bigdata.html",
         "date" => 2015-04-14T15:38:19.000Z
}
```

##### 输出到Elasticsearch指定索引

我们可以通过

```
elasticsearch {
hosts => ["node1.itcast.cn:9200" ,"node2.itcast.cn:9200" ,"node3.itcast.cn:9200"]
index => "xxx"
}
```

index来指定索引名称，默认输出的index名称为：logstash-%{+yyyy.MM.dd}。但注意，要在index中使用时间格式化，filter的输出必须包含 @timestamp字段，否则将无法解析日期。
vim config/filebeat-apache-weblog.conf

```
input {
    beats {
        port => 5044
    }
}

filter {
    grok {
        match => { 
            "message" => "%{IP:ip} - - \[%{HTTPDATE:date}\] \"%{WORD:method} %{PATH:uri} %{DATA}\" %{INT:status:int} %{INT:length:int} \"%{DATA:reference}\" \"%{DATA:browser}\"" 
        }
    }
    mutate {
        enable_metric => "false"
        remove_field => ["message", "log", "tags", "input", "agent", "host", "ecs", "@version"]
    }
    date {
        match => ["date","dd/MMM/yyyy:HH:mm:ss Z","yyyy-MM-dd HH:mm:ss"]
        target => "date"
    }
}

output {
    stdout {
        codec => rubydebug
    }
    elasticsearch {
        hosts => ["node1.itcast.cn:9200" ,"node2.itcast.cn:9200" ,"node3.itcast.cn:9200"]
        index => "apache_web_log_%{+YYYY-MM}"
    }
}
```

启动Logstash

```
bin/logstash -f config/filebeat-apache-weblog.conf --config.test_and_exit
bin/logstash -f config/filebeat-apache-weblog.conf --config.reload.automatic
```

**注意：**
index名称中，不能出现大写字符

## Kibana

### 简介

![image.png](https://image.hyly.net/i/2025/09/25/a793b29d31c9ab5ca8db47772744ca30-0.webp)

通过上面的这张图就可以看到，Kibana可以用来展示丰富的图表。

1. Kibana是一个开源的数据分析和可视化平台，使用Kibana可以用来搜索Elasticsearch中的数据，构建漂亮的可视化图形、以及制作一些好看的仪表盘
2. Kibana是用来管理Elastic stack组件的可视化平台。例如：使用Kibana可以进行一些安全设置、用户角色设置、对Elasticsearch进行快照等等
3. Kibana提供统一的访问入口，不管是日志分析、还是查找文档，Kibana提供了一个使用这些功能的统一访问入口
4. Kibana使用的是Elasticsearch数据源，Elasticsearch是存储和处理数据的引擎，而Kibana就是基于Elasticsearch之上的可视化平台
5. Kibana还提供了一些开发的工具，例如：Grok插件的调试工具

![image.png](https://image.hyly.net/i/2025/09/25/32ca8f5c8f93ce1adb2b5e4408f55b94-0.webp)

**主要功能：**
探索和查询Elasticsearch中的数据

![image.png](https://image.hyly.net/i/2025/09/25/426b4574fe42fa7b05a7f6501c54a2cd-0.webp)

可视化与分析

![image.png](https://image.hyly.net/i/2025/09/25/85bc43b9575a453f68754617ac7e2466-0.webp)

调试功能

![image.png](https://image.hyly.net/i/2025/09/25/188a7509e3ce27f6b74c5e3e8d0cc639-0.webp)

### 安装Kibana

在Linux下安装Kibana，可以使用Elastic stack提供 tar.gz压缩包。官方下载地址：
https://www.elastic.co/cn/downloads/past-releases/kibana-7-6-1

1.上传并解压Kibana gz压缩包

```
/export/software
rz
tar -xvzf kibana-7.6.1-linux-x86_64.tar.gz -C ../server/es/
```

2.配置Kibana

```
cd /export/server/es/kibana-7.6.1-linux-x86_64/
vim config/kibana.yml
```

```
## 复制第7行，并修改
server.host: "node1.itcast.cn"
## 复制第26行，并修改
server.name: "itcast-kibana"
## 复制第31行，并修改
elasticsearch.hosts: ["http://node1.itcast.cn:9200","http://node2.itcast.cn:9200","http://node3.itcast.cn:9200"]

## 修改第118行
i18n.locale: "zh-CN"
```

3.运行Kibana

```
bin/kibana --allow-root
```

#### 查看Kibana状态

输入以下网址，可以查看到Kibana的运行状态：
http://node1.itcast.cn:5601/status

![image.png](https://image.hyly.net/i/2025/09/25/db6fc1c10535846295811ca796abbd4a-0.webp)

#### 查看Elasticsearch的状态

点击![](C:\Users\30735\AppData\Local\Temp\ksohtml45204\wps1.jpg)![image.png](https://image.hyly.net/i/2025/09/25/47f57f6b21a915c98a8fe6ef896e5cc0-0.webp)按钮，再点击「Index Management」，可以查看到Elasticsearch集群中的索引状态。

![image.png](https://image.hyly.net/i/2025/09/25/5a2d17f78de4f5cbb7bbf70f2c48cca3-0.webp)

点击索引的名字，可以进一步查看索引更多的信息。

![image.png](https://image.hyly.net/i/2025/09/25/46a224d6203df77e79a1e0b24ab5a218-0.webp)

点击「Manage」按钮，还可以用来管理索引。

![image.png](https://image.hyly.net/i/2025/09/25/5d562eb312250a7178bbb1574523f5bf-0.webp)

### 添加Elasticsearch数据源

#### Kibana索引模式

在开始使用Kibana之前，我们需要指定想要对哪些Elasticsearch索引进行处理、分析。在Kibana中，可以通过定义索引模式（Index Patterns）来对应匹配Elasticsearch索引。在第一次访问Kibana的时候，系统会提示我们定义一个索引模式。或者我们可以通过点击按钮，再点击Kibana下方的Index Patterns，来创建索引模式。参考下图：

![image.png](https://image.hyly.net/i/2025/09/25/7b7cb55eb57f8da94a76f9efaa63587c-0.webp)

1.定义索引模式，用于匹配哪些Elasticsearch中的索引。点击「Next step」

![image.png](https://image.hyly.net/i/2025/09/25/dca9781d1c1fca1ca32b6ea789a3c5bf-0.webp)

2.选择用于进行时间过滤的字段

![image.png](https://image.hyly.net/i/2025/09/25/4f2a05a4899011751b17de31d2b3eff0-0.webp)

3.点击「Create Index Pattern」按钮，创建索引模式。创建索引模式成功后，可以看到显示了该索引模式对应的字段。里面描述了哪些可以用于搜索、哪些可以用来进行聚合计算等。

![image.png](https://image.hyly.net/i/2025/09/25/a6659e5de81df3e32e1a80c4e5fae268-0.webp)

### 探索数据（Discovery）

通过Kibana中的Discovery组件，我们可以快速地进行数据的检索、查询。

#### 使用探索数据功能

点击![](C:\Users\30735\AppData\Local\Temp\ksohtml45204\wps2.jpg)![image.png](https://image.hyly.net/i/2025/09/25/ac897a1ff8d4ebd256e34317e920a577-0.webp)按钮可以打开Discovery页面。

![image.png](https://image.hyly.net/i/2025/09/25/f91e7c5d5a4fef5e86316c3282366b30-0.webp)

我们发现没有展示任何的数据。但我们之前已经把数据导入到Elasticsearch中了。

![image.png](https://image.hyly.net/i/2025/09/25/eaa97dbf79246c011a27d1692f13606d-0.webp)

Kibana提示，让我们扩大我们的查询的时间范围。

![image.png](https://image.hyly.net/i/2025/09/25/5fee9c59b999679938f6da82129bf8e0-0.webp)

默认Kibana是展示最近15分钟的数据。我们把时间范围调得更长一些，就可以看到数据了。

![image.png](https://image.hyly.net/i/2025/09/25/cfd5a8b48e61ace01fc949167b421945-0.webp)

将时间范围选择为1年范围内的，我们就可以查看到Elasticsearch中的数据了。

![image.png](https://image.hyly.net/i/2025/09/25/b6d55a7b956488b179637cda99609153-0.webp)

#### 导入更多的Apache Web日志数据

1.将资料中的 access.log 文件上传到Linux
2.将access.log移动到/var/apache/log，并重命名为access.log.2
mv access.log /var/apache/log/access.log.2
3.启动FileBeat
./filebeat -e -c filebeat-logstash.yml
4.启动Logstash
bin/logstash -f config/filebeat-es.conf --config.reload.automatic

#### 基于时间过滤查询

##### 选择时间范围

![image.png](https://image.hyly.net/i/2025/09/25/6455efe36dbc64e8d2f8f146b89a126f-0.webp)

##### 指定查询某天的数据

查询2020年5月6日的所有日志数据。

![image.png](https://image.hyly.net/i/2025/09/25/1ff611f91c4056f9c40fb5cd500fd505-0.webp)

##### 从直方图上选择日期更细粒度范围

如果要选择查看某一天的日志，上面这种方式会有一些麻烦，我们有更快更容易的方式。

![image.png](https://image.hyly.net/i/2025/09/25/72886fc37abf3657920bfbb502d4ca61-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/e04fd153be1c96d1bbca793481803185-0.webp)

#### 使用Kibana搜索数据

在Kibana的Discovery组件中，可以在查询栏中输入搜索条件。默认情况下，可以使用Kibana内置的标准查询语言，来进行快速查询。还有一种是遗留的基于Lucene的查询语法目前暂时可用，这种查询语法也可以使用基于JSON的Elasticsearch DSL也是可用的。当我们在Discovery搜索数据时，对应的直方图、文档列表都会随即更新。默认情况下，优先展示最新的文档，按照时间倒序排序的。

##### Kibana查询语言（KQL）

在7.0中，Kibana上线了新的查询语言。这种语言简洁、易用，有利于快速查询。
查询语法：
「字段:值」，如果值是字符串，可以用双引号括起来。

**查询包含zhihu的请求**

*zhihu*

**查询页面不存在的请求**

status:404

**查询请求成功和不存在的请求**

status: (404 or 200)

**查询方式为POST请求，并请求成功的日志**

status: 200 and method: post

**查询方式为GET成功的请求，并且响应数据大于512的日志**

status: 200 and method: get and length > 512

**查询请求成功的且URL为「**  **/**  **itcast.cn**  **」** **开头的日志**

uri: "\/itcast.cn\/*"

##### 过滤字段

Kibana的Discovery组件提供各种各样的筛选器，这样可以筛选出来我们关注的数据上。例如：我们只想查询404的请求URI。

![image.png](https://image.hyly.net/i/2025/09/25/570face18c48afdb6ef21870c8356f58-0.webp)

**指定过滤出来404以及请求的URI、从哪儿跳转来的日志**

![image.png](https://image.hyly.net/i/2025/09/25/6c4f8e0b3d31668b4b3f79509387913c-0.webp)

**将查询保存下来，方便下次直接查看**

![image.png](https://image.hyly.net/i/2025/09/25/feca3646ac8f408ca524ba7be2737344-0.webp)

下次直接点击Open就可以直接打开之前保存的日志了

![image.png](https://image.hyly.net/i/2025/09/25/251f9d53bc67d53e8178bf8b19c0a443-0.webp)

### 数据可视化（Visualize）

Kibana中的Visualize可以基于Elasticsearch中的索引进行数据可视化，然后将这些可视化图表添加到仪表盘中。

#### 数据可视化的类型

1. Lens
	1. 通过简单地拖拽数据字段，快速构建基本的可视化
2. 常用的可视化对象
	1. 线形图（Line）、面积图（Area）、条形图（Bar）：可以用这些带X/Y坐标的图形来进行不同分类的比较
	2. 饼图（Pie）：可以用饼图来展示占比
	3. 数据表（Data Table）：以数据表格的形式展示
	4. 指标（Metrics）：以数字的方式展示
	5. 目标和进度：显示带有进度指标的数字
	6. 标签云/文字云（Tag Cloud）：以文字云方式展示标签，文字的大小与其重要性相关
3. Timelion
	1. 从多个时间序列数据集来展示数据
4. 地图
	1. 展示地理位置数据
5. 热图
	1. 在矩阵的单元格展示数据

![image.png](https://image.hyly.net/i/2025/09/25/0eaeb6130507596537770d3bbf1336e5-0.webp)

1. 仪表盘工具
	1. Markdown部件：显示一些MD格式的说明
	2. 控件：在仪表盘中添加一些可以用来交互的组件
2. Vega

#### 以饼图展示404与200的占比

效果图：

![image.png](https://image.hyly.net/i/2025/09/25/ef48a0f67583decf462f2170479d5bc9-0.webp)

操作步骤：
1.创建可视化

![image.png](https://image.hyly.net/i/2025/09/25/9def8ddc386a899344487439ce114359-0.webp)

2.选择要进行可视化图形类型，此处我们选择Pie（饼图类型）

![image.png](https://image.hyly.net/i/2025/09/25/7d0890d27c960b83e415ad9bcb4cdcaa-0.webp)

3.选择数据源

![image.png](https://image.hyly.net/i/2025/09/25/c9d1a795b20b439057d7bf591c07dca9-0.webp)

4.添加分桶

![image.png](https://image.hyly.net/i/2025/09/25/6a9f9c7fc4327544a0a8c5f63d727a79-0.webp)

5.配置分桶以及指标计算方式

![image.png](https://image.hyly.net/i/2025/09/25/0783797327937e57b6c3102b525399d6-0.webp)

6.点击蓝色播放按钮执行。

![image.png](https://image.hyly.net/i/2025/09/25/e323221325ee2fcfb94967cb1aabe805-0.webp)

7.保存图形（取名为：apache_log@404_200）

#### 以条形图方式展示2020年5月每日请求数

效果如下：

![image.png](https://image.hyly.net/i/2025/09/25/390c27868c846bcc067a06e08efa9508-0.webp)

开发步骤：

![image.png](https://image.hyly.net/i/2025/09/25/6c0eabfe95c413538b212c62306cf486-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/fec369dc5259a6f3599b513405bd4c37-0.webp)

我们还可以修改图形的样式，例如：以曲线、面积图的方式展示。

![image.png](https://image.hyly.net/i/2025/09/25/135ba1de3c268313a56d2ece2061f2b9-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/0b688faf38bea467e55e6cc87ed4cb30-0.webp)

#### 以TSVB可视化不同访问来源的数据

TSVB是一个基于时间序列的数据可视化工具，它可以使用Elasticsearch聚合的所有功能。使用TSVB，我们可以轻松地完成任意聚合方式来展示复杂的数据。它可以让我们快速制作效果的图表：
1.基于时间序列的图形展示

![image.png](https://image.hyly.net/i/2025/09/25/71f47a3482b5c8dcf5cbb896eaaa75a0-0.webp)

2.展示指标数据

![image.png](https://image.hyly.net/i/2025/09/25/4415df6d2a899086af83819b14b68f8f-0.webp)

3.TopN

![image.png](https://image.hyly.net/i/2025/09/25/797af8e01e3ccf495d9654e655d93ef1-0.webp)

4.类似油量表的展示

![image.png](https://image.hyly.net/i/2025/09/25/ff3f9f3812a103122544ecce9351f9ff-0.webp)

5.Markdown自定义数据展示

![image.png](https://image.hyly.net/i/2025/09/25/7298a5be03601003b3dafa843f2ed314-0.webp)

6.以表格方式展示数据

![image.png](https://image.hyly.net/i/2025/09/25/ebad71e51e51d386e82a2046f3caa775-0.webp)

操作步骤：
1.创建TSVB可视化对象

![image.png](https://image.hyly.net/i/2025/09/25/1eb163c116e5ace2b0cff7336f550911-0.webp)

2.配置Time Series数据源分组条件

![image.png](https://image.hyly.net/i/2025/09/25/d41c12eab186ac2a6ac7148c5f94d847-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/4a1980b2fd1bbd09ef7fe5f52f4f3130-0.webp)

3.配置Metric

![image.png](https://image.hyly.net/i/2025/09/25/dcec9a9d2841bc323c75e9c02dea8a4f-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/70faf16aaeb2becbd52196917dee72e9-0.webp)

4.TopN

![image.png](https://image.hyly.net/i/2025/09/25/3a4cc26e1eab571a5d54576545d43788-0.webp)

#### 制作用户选择请求方式、响应字节大小控制组件

##### 控制组件

在Kibana中，我们可以使用控件来控制图表的展示。例如：提供一个下列列表，供查看图表的用户只展示比较关注的数据。我们可以添加两个类型的控制组件：

1. 选项列表
	1. 根据一个或多个指定选项来筛选内容。例如：我们先筛选某个城市的数据，就可以通过选项列表来选择该城市
2. 范围选择滑块
	1. 筛选出来指定范围的数据。例如：我们筛选某个价格区间的商品等。

![image.png](https://image.hyly.net/i/2025/09/25/427c36d4ca388c5ab38242def062e70e-0.webp)

##### Kibana开发

![image.png](https://image.hyly.net/i/2025/09/25/edc03d797d9a06d0594fe8817bdaf27f-0.webp)

![image.png](https://image.hyly.net/i/2025/09/25/36c6f856476ec733e1eab369c9f3c39d-0.webp)

### 制作Dashboard

接下来，我们把前面的几个图形放到一个看板中。这样，我们就可以在一个看板中，浏览各类数据了。

![image.png](https://image.hyly.net/i/2025/09/25/ad8bcbcbe1bd858b9de1cabc898f77ca-0.webp)

1.点击第三个组件图标，并创建一个新的Dashboard。

![image.png](https://image.hyly.net/i/2025/09/25/3b7684ec153b532c80e4528bd726bcf4-0.webp)

2.点击Edit编辑Dashboard。

![image.png](https://image.hyly.net/i/2025/09/25/08597c0187ef7cd14378de63ab9637ea-0.webp)

3.依次添加我们之前制作好的图表。

![image.png](https://image.hyly.net/i/2025/09/25/e1893c5da9c6504f6f06b708401c03eb-0.webp)

## 【扩展】索引生命周期管理（ILM）

Elasticsearch中的数据量如果较小，例如：几个GB，只需要轻松地创建几个索引就可以满足需求。当Elasticsearch集群中索引变得越来越大时，需要关注索引的生命周期。

### 简介

Elasticsearch索引生命周期管理指的是：Elasticsearch从创建索引、打开索引、关闭索引、删除索引的全生命过程的管理。在大型Elasticsearch应用中，一般采用多索引结合基于时间、索引大小的横向扩展方式存储数据，随着数据量的增加，而不需要修改索引的底层架构。

1. 索引生命周期管理 (ILM) 是在Elasticsearch 6.6首次引入，并在 6.7 版正式推出的一项功能
2. ILM 是Elasticsearch的一部分，主要用来帮助管理索引
3. 基于Elasticsearch的ILM可以实现热温冷架构

#### 热温冷架构

热温冷架构常用于日志或指标类的时序数据

例如，假设正在使用 Elasticsearch 聚合来自多个系统的日志文件

1. 今天的日志正在频繁地被索引，且本周的日志搜索量最大（热）
2. 上周的日志可能会被频繁搜索，但频率没有本周日志那么高（温）
3. 上月日志的搜索频率可能较高，也可能较低，但最好保留一段时间以防万一（冷）

![image.png](https://image.hyly.net/i/2025/09/25/a2a49cf9d7287b058dde2e6beccd7822-0.webp)

上图，集群中有19个节点：10个了热节点、6个温节点、3个冷节点。冷节点是可选的。Elasticsearch中，可以定义哪些节点是热节点、温节点或冷节点。

ILM 允许定义何时在两个阶段之间移动，以及在进入那个阶段时如何处理索引

对于热温冷架构，没有一成不变的设置。但是，通常而言，热节点需要较多的 CPU 资源和较快的 IO。对于温节点和冷节点来说，通常每个节点会需要更多的磁盘空间，但即便使用较少的 CPU 资源和较慢的 IO 设备，也能勉强应付

### 配置分片分配感知

由于热温冷依赖于分片分配感知，因此，首先标记哪些节点是热节点、温节点和（可选）冷节点。

集群规划：

<figure class='table-figure'><table>
<thead>
<tr><th>node1</th><th>热节点</th><th>nohup /export/server/es/elasticsearch-7.6.1/bin/elasticsearch -Enode.attr.data=hot 2&gt;&amp;1 &amp;</th></tr></thead>
<tbody><tr><td>node2</td><td>温节点</td><td>nohup /export/server/es/elasticsearch-7.6.1/bin/elasticsearch -Enode.attr.data=warm 2&gt;&amp;1 &amp;</td></tr><tr><td>node3</td><td>冷节点</td><td>nohup /export/server/es/elasticsearch-7.6.1/bin/elasticsearch -Enode.attr.data=cold 2&gt;&amp;1 &amp;</td></tr></tbody>
</table></figure>

使用以下命令可以一键关键Elasticsearch集群：

```
jps | grep Elasticsearch | cut -f1 -d" " | xargs kill -9
```

### 配置ILM策略

1. 要进行索引生命周期管理，需要配置ILM策略，ILM策略可以在选择的任意索引应用
2. ILM策略主要分为四个主要阶段：热、温、冷、删除
3. 不需要在一个策略中定义每个阶段，ILM 会始终按该顺序执行各个阶段（跳过任何未定义的阶段）
4. 可以通过配置ILM策略来定义什么时间进入该阶段，还可以定义按照什么样的方式来管理索引

以下代码是创建一个最基本的ILM策略：

```
PUT /_ilm/policy/my_policy
{
  "policy":{
    "phases":{
      "hot":{
        "actions":{
          "rollover":{
            "max_size":"50gb",
            "max_age":"30d"
          }
        }
      }
    }
  }
}
```

这个策略规定，在索引存储时间达到 30 天后或者索引大小达到 50GB（基于主分片）时，就会滚动更新该索引并开始写入一个新索引。

### ILM与索引模板

#### 索引模板

当索引类型和配置信息都一样，就可以使用索引模板来处理，不然每次创建索引都需要指定很多的索引参数。例如：指定refresh的周期、主分片的数量、副本数量、以及translog的一些配置等等。

#### 关联ILM策略与模板

创建一个名为my_template模板，并与ILM策略关联：

```
PUT _template/my_template
{
  "index_patterns": ["test-*"],
  "settings": {
    "index.lifecycle.name": "my_policy",
    "index.lifecycle.rollover_alias": "test-alias" 
  }
}
```

对于配置了滚动更新操作的策略，必须要在创建索引模板后使用写入别名启动索引

```
PUT test-000001 
{
  "aliases": {
    "test-alias":{
      "is_write_index": true 
    }
  }
}
```

配置了滚动更新的要求得到满足后，任何以 test-* 开头的新索引将在 30 天后或达到 50GB 时自动滚动更新。通过使用滚动更新管理以 max_size 开头的索引后，可以极大减少索引的分片数量，进而减少开销。

### 配置用于采集的ILM策略

1. Beats 和 Logstash 都支持 ILM，并在启用后将设置一个类似上例所示的默认策略
2. 当为 Beats 和 Logstash 启用 ILM 时，除非每天索引量很大（大于 50GB/天），否则索引大小将可能是确定何时创建新索引的主要因素
3. 从 7.0.0 开始，带有滚动更新的 ILM 将是 Beats 和 Logstash 的默认配置
4. 不过，由于针对热温冷架构没有一成不变的设置，因此，Beats 和 Logstash 将不会自动配置好热温冷策略。我们可以制定一个适用于热温冷的新策略，并在这一过程中进行一些优化。

#### 针对温热冷优化ILM策略

下面配置创建了针对热温冷架构优化的 ILM 策略。

```
PUT _ilm/policy/hot-warm-cold-delete-60days
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size":"50gb",
            "max_age":"30d"
          },
          "set_priority": {
            "priority":50
          }
        }
      },
      "warm": {
        "min_age":"7d",
        "actions": {
          "forcemerge": {
            "max_num_segments":1
          },
          "shrink": {
            "number_of_shards":1
          },
          "allocate": {
            "require": {
              "data": "warm"
            }
          },
          "set_priority": {
            "priority":25
          }
        }
      },
      "cold": {
        "min_age":"30d",
        "actions": {
          "set_priority": {
            "priority":0
          },
          "freeze": {},
          "allocate": {
            "require": {
              "data": "cold"
            }
          }
        }
      },
      "delete": {
        "min_age":"60d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

##### 热阶段

```
"hot": {
        "actions": {
          "rollover": {
            "max_size":"50gb",
            "max_age":"30d"
          },
          "set_priority": {
            "priority":50
          }
        }
      }
```

1. 这个 ILM 策略首先会将索引优先级设置为一个较高的值，以便热索引在其他索引之前恢复
2. 30天后或达到 50GB 时（符合任何一个即可），该索引将滚动更新，系统将创建一个新索引
3. 该新索引将重新启动策略，而当前的索引（刚刚滚动更新的索引）将在滚动更新后等待 7 天再进入温阶段

##### 温阶段

```
"warm": {
        // 索引7天进入到温阶段
        "min_age":"7d",
        // 前置合并segment为1
        "actions": {
          "forcemerge": {
            "max_num_segments":1
          },
          // 设置分片数量为1
          "shrink": {
            "number_of_shards":1
          },
          // 移动到温节点
          "allocate": {
            "require": {
              "data": "warm"
            }
          },
          // 优先级比热阶段低
          "set_priority": {
            "priority":25
          }
        }
      }
```

索引进入温阶段后，ILM 会将索引收缩到 1 个分片，将索引强制合并为 1 个段，并将索引优先级设置为比热阶段低（但比冷阶段高）的值，通过分配操作将索引移动到温节点。完成该操作后，索引将等待 30 天（从滚动更新时算起）后进入冷阶段。

##### 冷阶段

```
"cold": {
        // 索引进入温阶段后，经过30天进入冷阶段
        "min_age":"30d",
        // 优先级更低
        "actions": {
          "set_priority": {
            "priority":0
          },
          "freeze": {},
          // 将索引移动到冷节点
          "allocate": {
            "require": {
              "data": "cold"
            }
          }
        }
      }
```

索引进入冷阶段后，ILM 将再次降低索引优先级，以确保热索引和温索引得到先行恢复。然后，ILM 将冻结索引并将其移动到冷节点。完成该操作后，索引将等待 60 天（从滚动更新时算起）后进入删除阶段。

##### 删除阶段

```
"delete": {
        "min_age":"60d",
        "actions": {
          "delete": {}
        }
      }

```

删除阶段具有用于删除索引的删除操作。在删除阶段，您将始终需要有一个 min_age 条件，以允许索引在给定时段内待在热、温或冷阶段。

## 读写性能调优

### 写入性能调优

1. 增加flush时间间隔，目的是减小数据写入磁盘的频率，减小磁盘IO

2. 增加refresh_interval的参数值，目的是减少segment文件的创建，减少segment的merge次数，merge是发生在jvm中的，有可能导致full GC，增加refresh会降低搜索的实时性。

3. 增加Buffer大小，本质也是减小refresh的时间间隔，因为导致segment文件创建的原因不仅有时间阈值，还有buffer空间大小，写满了也会创建。         默认最小值 48MB&#x3c; 默认值 堆空间的10% &#x3c; 默认最大无限制

4. 大批量的数据写入尽量控制在低检索请求的时间段，大批量的写入请求越集中越好。

	1. 第一是减小读写之间的资源抢占，读写分离
	2. 第二，当检索请求数量很少的时候，可以减少甚至完全删除副本分片，关闭segment的自动创建以达到高效利用内存的目的，因为副本的存在会导致主从之间频繁的进行数据同步，大大增加服务器的资源占用。

5. Lucene的数据的fsync是发生在OS cache的，要给OS cache预留足够的内从大小，详见JVM调优。

6. 通用最小化算法，能用更小的字段类型就用更小的，keyword类型比int更快，

7. ignore_above：字段保留的长度，越小越好

8. 调整_source字段，通过include和exclude过滤

9. store：开辟另一块存储空间，可以节省带宽

	***\*注意：_\*******\*sourse\*******\*：\*******\*设置为false\*******\*，\*******\*则不存储元数据\*******\*，\*******\*可以节省磁盘\*******\*，\*******\*并且不影响搜索\*******\*。但是禁用_\*******\*source必须三思而后行\*******\*：\****

	\1. [update](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/docs-update.html)，[update_by_query](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/docs-update-by-query.html)和[reindex](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/docs-reindex.html)不可用。

	\2. 高亮失效

	\3. reindex失效，原本可以修改的mapping部分参数将无法修改，并且无法升级索引

	\4. 无法查看元数据和聚合搜索

	影响索引的容灾能力

10. 禁用_all字段：_all字段的包含所有字段分词后的Term，作用是可以在搜索时不指定特定字段，从所有字段中检索，ES 6.0之前需要手动关闭

11. 关闭Norms字段：计算评分用的，如果你确定当前字段将来不需要计算评分，设置false可以节省大量的磁盘空间，有助于提升性能。常见的比如filter和agg字段，都可以设为关闭。

12. 关闭index_options（谨慎使用，高端操作）：词设置用于在index time过程中哪些内容会被添加到倒排索引的文件中，例如TF，docCount、postion、offsets等，减少option的选项可以减少在创建索引时的CPU占用率，不过在实际场景中很难确定业务是否会用到这些信息，除非是在一开始就非常确定用不到，否则不建议删除

### 搜索速度调优

1. 禁用swap
2. 使用filter代替query
3. 避免深度分页，避免单页数据过大，可以参考百度或者淘宝的做法。es提供两种解决方案scroll search和search after
4. 注意关于index type的使用
5. 避免使用稀疏数据
6. 避免单索引业务重耦合
7. 命名规范
8. 冷热分离的架构设计
9. fielddata：搜索时正排索引，doc_value为index time正排索引。
10. enabled：是否创建倒排索引
11. doc_values：正排索引，对于不需要聚合的字段，关闭正排索引可节省资源，提高查询速度
12. 开启自适应副本选择（ARS），6.1版本支持，7.0默认开启，

### 硬件优化

es的默认配置是一个非常合理的默认配置，绝大多数情况下是不需要修改的，如果不理解某项配置的含义，没有经过验证就贸然修改默认配置，可能造成严重的后果。比如max_result_window这个设置，默认值是1W，这个设置是分页数据每页最大返回的数据量，冒然修改为较大值会导致OOM。ES没有银弹，不可能通过修改某个配置从而大幅提升ES的性能，通常出厂配置里大部分设置已经是最优配置，只有少数和具体的业务相关的设置，事先无法给出最好的默认配置，这些可能是需要我们手动去设置的。关于配置文件，如果你做不到彻底明白配置的含义，不要随意修改。

**1. jvm heap分配：** 7.6版本默认1GB，这个值太小，很容易导致OOM。Jvm heap大小不要超过物理内存的50%，最大也不要超过32GB（compressed oop），它可用于其内部缓存的内存就越多，但可供操作系统用于文件系统缓存的内存就越少，heap过大会导致GC时间过长

**2.节点：** 根据业务量不同，内存的需求也不同，一般生产建议不要少于16G。ES是比较依赖内存的，并且对内存的消耗也很大，内存对ES的重要性甚至是高于CPU的，所以即使是数据量不大的业务，为了保证服务的稳定性，在满足业务需求的前提下，我们仍需考虑留有不少于20%的冗余性能。一般来说，按照百万级、千万级、亿级数据的索引，我们为每个节点分配的内存为16G/32G/64G就足够了，太大的内存，性价比就不是那么高了。

**3. 内存：** 根据业务量不同，内存的需求也不同，一般生产建议不要少于16G。ES是比较依赖内存的，并且对内存的消耗也很大，内存对ES的重要性甚至是高于CPU的，所以即使是数据量不大的业务，为了保证服务的稳定性，在满足业务需求的前提下，我们仍需考虑留有不少于20%的冗余性能。一般来说，按照百万级、千万级、亿级数据的索引，我们为每个节点分配的内存为16G/32G/64G就足够了，太大的内存，性价比就不是那么高了。

**4. 磁盘：** 对于ES来说，磁盘可能是最重要的了，因为数据都是存储在磁盘上的，当然这里说的磁盘指的是磁盘的性能。磁盘性能往往是硬件性能的瓶颈，木桶效应中的最短板。ES应用可能要面临不间断的大量的数据读取和写入。生产环境可以考虑把节点冷热分离，“热节点”使用SSD做存储，可以大幅提高系统性能；冷数据存储在机械硬盘中，降低成本。另外，关于磁盘阵列，可以使用raid 0。

**5. CPU：** CPU对计算机而言可谓是最重要的硬件，但对于ES来说，可能不是他最依赖的配置，因为提升CPU配置可能不会像提升磁盘或者内存配置带来的性能收益更直接、显著。当然也不是说CPU的性能就不重要，只不过是说，在硬件成本预算一定的前提下，应该把更多的预算花在磁盘以及内存上面。通常来说单节点cpu 4核起步，不同角色的节点对CPU的要求也不同。服务器的CPU不需要太高的单核性能，更多的核心数和线程数意味着更高的并发处理能力。现在PC的配置8核都已经普及了，更不用说服务器了。

**6. 网络：** ES是天生自带分布式属性的，并且ES的分布式系统是基于对等网络的，节点与节点之间的通信十分的频繁，延迟对于ES的用户体验是致命的，所以对于ES来说，低延迟的网络是非常有必要的。因此，使用扩地域的多个数据中心的方案是非常不可取的，ES可以容忍集群夸多个机房，可以有多个内网环境，支持跨AZ部署，但是不能接受多个机房跨地域构建集群，一旦发生了网络故障，集群可能直接GG，即使能够保证服务正常运行，维护这样（跨地域单个集群）的集群带来的额外成本可能远小于它带来的额外收益。

**7. 集群规划：** 没有最好的配置，只有最合适的配置。

1. 在集群搭建之前，首先你要搞清楚，你ES cluster的使用目的是什么？主要应用于哪些场景，比如是用来存储事务日志，或者是站内搜索，或者是用于数据的聚合分析。针对不同的应用场景，应该指定不同的优化方案。
2. 集群需要多少种配置（内存型/IO型/运算型），每种配置需要多少数量，通常需要和产品运营和运维测试商定，是业务量和服务器的承载能力而定，并留有一定的余量。
3. 一个合理的ES集群配置应不少于5台服务器，避免脑裂时无法选举出新的Master节点的情况，另外可能还需要一些其他的单独的节点，比如ELK系统中的Kibana、Logstash等。
