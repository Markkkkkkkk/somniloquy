---
category: [大数据技术栈]
tag: [Hbase,大数据,OLAP,数据库]
postType: post
status: publish
---

## 简介

### Hadoop

1. 从 1970 年开始，大多数的公司数据存储和维护使用的是关系型数据库
2. 大数据技术出现后，很多拥有海量数据的公司开始选择像Hadoop的方式来存储海量数据
3. Hadoop使用分布式文件系统HDFS来存储海量数据，并使用 MapReduce 来处理。Hadoop擅长于存储各种格式的庞大的数据，任意的格式甚至非结构化的处理

### Hadoop的局限

1. Hadoop主要是实现批量数据的处理，并且通过顺序方式访问数据
2. 要查找数据必须搜索整个数据集， 如果要进行随机读取数据，效率较低

### HBase 与 NoSQL

![image.png](https://image.hyly.net/i/2025/09/28/c617a16bfdfb0ab4e5e8ff53d9a009ce-0.webp)

1. NoSQL是一个通用术语，泛指一个数据库并不是使用SQL作为主要语言的非关系型数据库
2. HBase是BigTable的开源java版本。**是建立在HDFS之上**，提供高可靠性、高性能、列存储、可伸缩、实时读写NoSQL的**数据库系统**
3. HBase仅能通过主键(row key)和主键的range来检索数据，仅支持单行事务
4. 主要用来存储结构化和半结构化的松散数据
5. Hbase查询数据功能很简单，不支持join等复杂操作，不支持复杂的事务（行级的事务），从技术上来说，HBase更像是一个「数据存储」而不是「数据库」，因为HBase缺少RDBMS中的许多特性，例如带类型的列、二级索引以及高级查询语言等
6. Hbase中支持的数据类型：byte[]
7. 与Hadoop一样，Hbase目标主要依靠**横向扩展**，通过不断增加廉价的商用服务器，来增加存储和处理能力，例如，把集群从10个节点扩展到20个节点，存储能力和处理能力都会加倍
8. HBase中的表一般有这样的特点
   1. 大：一个表可以有上十亿行，上百万列
   2. 面向列:面向列(族)的存储和权限控制，列(族)独立检索
   3. 稀疏:对于为空(null)的列，并不占用存储空间，因此，表可以设计的非常稀疏

### HBase应用场景

#### 对象存储

不少的头条类、新闻类的的新闻、网页、图片存储在HBase之中，一些病毒公司的病毒库也是存储在HBase之中

#### 时序数据

HBase之上有OpenTSDB模块，可以满足时序类场景的需求

#### 推荐画像

用户画像，是一个比较大的稀疏矩阵，蚂蚁金服的风控就是构建在HBase之上

#### 时空数据

主要是轨迹、气象网格之类，滴滴打车的轨迹数据主要存在HBase之中，另外在技术所有大一点的数据量的车联网企业，数据都是存在HBase之中

#### CubeDB OLAP

Kylin一个cube分析工具，底层的数据就是存储在HBase之中，不少客户自己基于离线计算构建cube存储在hbase之中，满足在线报表查询的需求

#### 消息/订单

在电信领域、银行领域，不少的订单查询底层的存储，另外不少通信、消息同步的应用构建在HBase之上

#### Feeds流

典型的应用就是xx朋友圈类似的应用，用户可以随时发布新内容，评论、点赞。

#### NewSQL

之上有Phoenix的插件，可以满足二级索引、SQL的需求，对接传统数据需要SQL非事务的需求

#### 其他

1. 存储爬虫数据
2. 海量数据备份
3. 短网址
4. …

### 发展历程

<figure class='table-figure'><table>
<thead>
<tr><th>年份</th><th>重大事件</th></tr></thead>
<tbody><tr><td>2006年11月</td><td>Google发布BigTable论文.</td></tr><tr><td>2007年10月</td><td>发布第一个可用的HBase版本，基于Hadoop 0.15.0</td></tr><tr><td>2008年1月</td><td>HBase称为Hadoop的一个子项目</td></tr><tr><td>2010年5月</td><td>HBase称为Apache的顶级项目</td></tr></tbody>
</table></figure>

### HBase特点

1. 强一致性读/写
   1. HBASE不是“最终一致的”数据存储
   2. 它非常适合于诸如高速计数器聚合等任务
2. 自动分块
   1. HBase表通过Region分布在集群上，随着数据的增长，区域被自动拆分和重新分布
3. 自动RegionServer故障转移
4. Hadoop/HDFS集成
   1. HBase支持HDFS开箱即用作为其分布式文件系统
5. MapReduce
   1. HBase通过MapReduce支持大规模并行处理，将HBase用作源和接收器
6. Java Client API
   1. HBase支持易于使用的 Java API 进行编程访问
7. Thrift/REST API
8. 块缓存和布隆过滤器
   1. HBase支持块Cache和Bloom过滤器进行大容量查询优化
9. 运行管理
   1. HBase为业务洞察和JMX度量提供内置网页。

### RDBMS与HBase的对比

#### 关系型数据库

##### 结构

1. 数据库以表的形式存在
2. 支持FAT、NTFS、EXT、文件系统
3. 使用主键（PK）
4. 通过外部中间件可以支持分库分表，但底层还是单机引擎
5. 使用行、列、单元格

##### 功能

1. 支持向上扩展（买更好的服务器）
2. 使用SQL查询
3. 面向行，即每一行都是一个连续单元
4. 数据总量依赖于服务器配置
5. 具有ACID支持
6. 适合结构化数据
7. 传统关系型数据库一般都是中心化的
8. 支持事务
9. 支持Join

#### HBase

##### 结构

1. 以表形式存在
2. 支持HDFS文件系统
3. 使用行键（row key）
4. 原生支持分布式存储、计算引擎
5. 使用行、列、列蔟和单元格

##### 功能

1. 支持向外扩展
2. 使用API和MapReduce、Spark、Flink来访问HBase表数据
3. 面向列蔟，即每一个列蔟都是一个连续的单元
4. 数据总量不依赖具体某台机器，而取决于机器数量
5. HBase不支持ACID（Atomicity、Consistency、Isolation、Durability）
6. 适合结构化数据和非结构化数据
7. 一般都是分布式的
8. HBase不支持事务，支持的是单行数据的事务操作
9. 不支持Join

### HDFS对比HBase

#### HDFS

1. HDFS是一个非常适合存储大型文件的分布式文件系统
2. HDFS它不是一个通用的文件系统，也无法在文件中快速查询某个数据

#### HBase

1. HBase构建在HDFS之上，并为大型表提供快速记录查找(和更新)
2. HBase内部将大量数据放在HDFS中名为「StoreFiles」的索引中，以便进行高速查找
3. Hbase比较适合做快速查询等需求，而不适合做大规模的OLAP应用

### Hive对比Hbase

#### Hive

**数据仓库工具**
Hive的本质其实就相当于将HDFS中已经存储的文件在Mysql中做了一个双射关系，以方便使用HQL去管理查询
**用于数据分析、清洗**
Hive适用于离线的数据分析和清洗，延迟较高
**基于HDFS、MapReduce**
Hive存储的数据依旧在DataNode上，编写的HQL语句终将是转换为MapReduce代码执行

#### HBase

**NoSQL数据库**
是一种面向列存储的非关系型数据库。
**用于存储结构化和非结构化的数据**
适用于单表非关系型数据的存储，不适合做关联查询，类似JOIN等操作。
**基于HDFS**
数据持久化存储的体现形式是Hfile，存放于DataNode中，被ResionServer以region的形式进行管理
**延迟较低，接入在线业务使用**
面对大量的企业数据，HBase可以直线单表大量数据的存储，同时提供了高效的数据访问速度

#### 总结Hive与HBase

1. Hive和Hbase是两种基于Hadoop的不同技术
2. Hive是一种类SQL的引擎，并且运行MapReduce任务
3. Hbase是一种在Hadoop之上的NoSQL 的Key/value数据库
4. 这两种工具是可以同时使用的。就像用Google来搜索，用FaceBook进行社交一样，Hive可以用来进行统计查询，HBase可以用来进行实时查询，数据也可以从Hive写到HBase，或者从HBase写回Hive

## 集群搭建

### 安装

#### 上传解压HBase安装包

```
tar -xvzf hbase-2.1.0.tar.gz -C ../server/
```

#### 修改HBase配置文件

##### hbase-env.sh

```
cd /export/server/hbase-2.1.0/conf
vim hbase-env.sh
# 第28行
export JAVA_HOME=/export/server/jdk1.8.0_241/
export HBASE_MANAGES_ZK=false
```

##### hbase-site.xml

```
vim hbase-site.xml
------------------------------
<configuration>
        <!-- HBase数据在HDFS中的存放的路径 -->
        <property>
            <name>hbase.rootdir</name>
            <value>hdfs://node1.itcast.cn:8020/hbase</value>
        </property>
        <!-- Hbase的运行模式。false是单机模式，true是分布式模式。若为false,Hbase和Zookeeper会运行在同一个JVM里面 -->
        <property>
            <name>hbase.cluster.distributed</name>
            <value>true</value>
        </property>
        <!-- ZooKeeper的地址 -->
        <property>
            <name>hbase.zookeeper.quorum</name>
            <value>node1.itcast.cn,node2.itcast.cn,node3.itcast.cn</value>
        </property>
        <!-- ZooKeeper快照的存储位置 -->
        <property>
            <name>hbase.zookeeper.property.dataDir</name>
            <value>/export/server/apache-zookeeper-3.6.0-bin/data</value>
        </property>
        <!--  V2.1版本，在分布式情况下, 设置为false -->
        <property>
            <name>hbase.unsafe.stream.capability.enforce</name>
            <value>false</value>
        </property>
</configuration>
```

#### 配置环境变量

```
# 配置Hbase环境变量
vim /etc/profile
export HBASE_HOME=/export/server/hbase-2.1.0
export PATH=$PATH:${HBASE_HOME}/bin:${HBASE_HOME}/sbin

#加载环境变量
source /etc/profile
```

#### 复制jar包到lib

```
cp $HBASE_HOME/lib/client-facing-thirdparty/htrace-core-3.1.0-incubating.jar $HBASE_HOME/lib/
```

#### 修改regionservers文件

```
vim regionservers 
node1.itcast.cn
node2.itcast.cn
node3.itcast.cn
```

#### 分发安装包与配置文件

```
cd /export/server
scp -r hbase-2.1.0/ node2.itcast.cn:$PWD
scp -r hbase-2.1.0/ node3.itcast.cn:$PWD
scp -r /etc/profile node2.itcast.cn:/etc
scp -r /etc/profile node3.itcast.cn:/etc

在node2.itcast.cn和node3.itcast.cn加载环境变量
source /etc/profile
```

#### 启动HBase

```
cd /export/onekey
# 启动ZK
./start-zk.sh
# 启动hadoop
start-dfs.sh
# 启动hbase
start-hbase.sh
```

#### 验证Hbase是否启动成功

```
# 启动hbase shell客户端
hbase shell
# 输入status

[root@node1 onekey]# hbase shell
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/export/server/hadoop-2.7.5/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/export/server/hbase-2.1.0/lib/client-facing-thirdparty/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this interactive shell.
Version 2.1.0, re1673bb0bbfea21d6e5dba73e013b09b8b49b89b, Tue Jul 10 17:26:48 CST 2018
Took 0.0034 seconds                                                                                                                     
Ignoring executable-hooks-1.6.0 because its extensions are not built. Try: gem pristine executable-hooks --version 1.6.0
Ignoring gem-wrappers-1.4.0 because its extensions are not built. Try: gem pristine gem-wrappers --version 1.4.0
2.4.1 :001 > status
1 active master, 0 backup masters, 3 servers, 0 dead, 0.6667 average load
Took 0.4562 seconds                                                                                                                     
2.4.1 :002 >
```

### WebUI

http://node1.itcast.cn:16010/master-status

![image.png](https://image.hyly.net/i/2025/09/28/03c1740c6abeb44053b2b9acc4bf4103-0.webp)

### 安装目录说明

<figure class='table-figure'><table>
<thead>
<tr><th>目录名</th><th>说明</th></tr></thead>
<tbody><tr><td>bin</td><td>所有hbase相关的命令都在该目录存放</td></tr><tr><td>conf</td><td>所有的hbase配置文件</td></tr><tr><td>hbase-webapps</td><td>hbase的web ui程序位置</td></tr><tr><td>lib</td><td>hbase依赖的java库</td></tr><tr><td>logs</td><td>hbase的日志文件</td></tr></tbody>
</table></figure>

### 参考硬件配置

针对大概800TB存储空间的集群中每个Java进程的典型内存配置：

<figure class='table-figure'><table>
<thead>
<tr><th>进程</th><th>堆</th><th>描述</th></tr></thead>
<tbody><tr><td>NameNode</td><td>8 GB</td><td>每100TB数据或每100W个文件大约占用NameNode堆1GB的内存</td></tr><tr><td>SecondaryNameNode</td><td>8GB</td><td>在内存中重做主NameNode的EditLog，因此配置需要与NameNode一样</td></tr><tr><td>DataNode</td><td>1GB</td><td>适度即可</td></tr><tr><td>ResourceManager</td><td>4GB</td><td>适度即可（注意此处是MapReduce的推荐配置）</td></tr><tr><td>NodeManager</td><td>2GB</td><td>适当即可（注意此处是MapReduce的推荐配置）</td></tr><tr><td>HBase HMaster</td><td>4GB</td><td>轻量级负载，适当即可</td></tr><tr><td>HBase RegionServer</td><td>12GB</td><td>大部分可用内存、同时为操作系统缓存、任务进程留下足够的空间</td></tr><tr><td>ZooKeeper</td><td>1GB</td><td>适度</td></tr></tbody>
</table></figure>

推荐：

1. Master机器要运行NameNode、ResourceManager、以及HBase HMaster，推荐24GB左右
2. Slave机器需要运行DataNode、NodeManager和HBase RegionServer，推荐24GB（及以上）
3. 根据CPU的核数来选择在某个节点上运行的进程数，例如：两个4核CPU=8核，每个Java进程都可以独立占有一个核（推荐：8核CPU）
4. 内存不是越多越好，在使用过程中会产生较多碎片，Java堆内存越大， 会导致整理内存需要耗费的时间越大。例如：给RegionServer的堆内存设置为64GB就不是很好的选择，一旦FullGC就会造成较长时间的等待，而等待较长，Master可能就认为该节点已经挂了，然后移除掉该节点

## HBase数据模型

### 简介

在HBASE中，数据存储在具有行和列的表中。这是看起来关系数据库(RDBMS)一样，但将HBASE表看成是多个维度的Map结构更容易理解。

<figure class='table-figure'><table>
<thead>
<tr><th>ROWKEY</th><th>C1列蔟</th><th>C2列蔟</th></tr></thead>
<tbody><tr><td>rowkey</td><td>列1</td><td>列2</td></tr></tbody>
</table></figure>

<figure class='table-figure'><table>
<thead>
<tr><th>rowkey</th><th>0001</th></tr></thead>
<tbody><tr><td>C1（Map）</td><td>列1 =&gt; 值1列2 =&gt; 值2列3 =&gt; 值3</td></tr><tr><td>C2（Map）</td><td>列4 =&gt; 值4列5 =&gt; 值5列6 =&gt; 值6</td></tr></tbody>
</table></figure>

```
{
  "zzzzz" : "woot",
  "xyz" : "hello",
  "aaaab" : "world",
  "1" : "x",
  "aaaaa" : "y"
}
```

### 术语

#### 表（Table）

1. HBase中数据都是以表形式来组织的
2. HBase中的表由多个行组成

在HBase WebUI（http://node1.itcast.cn:16010中可以查看到目前HBase中的表）

![image.png](https://image.hyly.net/i/2025/09/28/39913db6b9d0dc7873a4f296c173f8a6-0.webp)

#### 行（row）

1. HBASE中的行由一个rowkey（行键）和一个或多个列组成，列的值与rowkey、列相关联
2. 行在存储时按行键按字典顺序排序
3. 行键的设计非常重要，尽量让相关的行存储在一起
4. 例如：存储网站域。如行键是域，则应该将域名反转后存储(org.apache.www、org.apache.mail、org.apache.jira)。这样，所有Apache域都在表中存储在一起，而不是根据子域的第一个字母展开

后续，我们会讲解rowkey的设计策略。

#### 列（Column）

1. HBASE中的列由列蔟（Column Family）和列限定符（Column Qualifier）组成
2. 表示如下——列蔟名:列限定符名。例如：C1:USER_ID、C1:SEX

#### 列蔟（Column Family）

![image.png](https://image.hyly.net/i/2025/09/28/0aa9e30ab34f9a74ed6cf4673fa2e38e-0.webp)

1. 出于性能原因，列蔟将一组列及其值组织在一起
2. 每个列蔟都有一组存储属性，例如：
   1. 是否应该缓存在内存中
   2. 数据如何被压缩或行键如何编码等
3. 表中的每一行都有相同的列蔟，但在列蔟中不存储任何内容
4. 所有的列蔟的数据全部都存储在一块（文件系统HDFS）
5. HBase官方建议所有的列蔟保持一样的列，并且将同一类的列放在一个列蔟中

#### 列标识符（Column Qualifier）

1. 列蔟中包含一个个的列限定符，这样可以为存储的数据提供索引
2. 列蔟在创建表的时候是固定的，但列限定符是不作限制的
3. 不同的行可能会存在不同的列标识符

#### 单元格（Cell）

1. 单元格是行、列系列和列限定符的组合
2. 包含一个值和一个时间戳（表示该值的版本）
3. 单元格中的内容是以二进制存储的

<figure class='table-figure'><table>
<thead>
<tr><th>ROW</th><th>COLUMN+CELL</th></tr></thead>
<tbody><tr><td>1250995</td><td>column=C1:ADDRESS,<strong>timestamp</strong> =1588591604729, value=\xC9\xBD\xCE\xF7\xCA</td></tr><tr><td>1250995</td><td>column=C1:LATEST_DATE,<strong>timestamp</strong> =1588591604729, value=2019-03-28</td></tr><tr><td>1250995</td><td>column=C1:NAME,<strong>timestamp</strong> =1588591604729, value=\xB7\xBD\xBA\xC6\xD0\xF9</td></tr><tr><td>1250995</td><td>column=C1:NUM_CURRENT,<strong>timestamp</strong> =1588591604729, value=398.5</td></tr><tr><td>1250995</td><td>column=C1:NUM_PREVIOUS,<strong>timestamp</strong> =1588591604729, value=379.5</td></tr><tr><td>1250995</td><td>column=C1:NUM_USEAGE,<strong>timestamp</strong> =1588591604729, value=19</td></tr><tr><td>1250995</td><td>column=C1:PAY_DATE,<strong>timestamp</strong> =1588591604729, value=2019-02-26</td></tr><tr><td>1250995</td><td>column=C1:RECORD_DATE,<strong>timestamp</strong> =1588591604729, value=2019-02-11</td></tr><tr><td>1250995</td><td>column=C1:SEX,<strong>timestamp</strong> =1588591604729, value=\xC5\xAE</td></tr><tr><td>1250995</td><td>column=C1:TOTAL_MONEY,<strong>timestamp</strong> =1588591604729, value=114</td></tr></tbody>
</table></figure>

### 概念模型

<figure class='table-figure'><table>
<thead>
<tr><th><strong>Row Key</strong></th><th><strong>Time Stamp</strong></th><th><strong>ColumnFamily **</strong>contents**</th><th><strong>ColumnFamily **</strong>anchor**</th><th><strong>ColumnFamily **</strong>people**</th></tr></thead>
<tbody><tr><td>&quot;com.cnn.www&quot;</td><td>t9</td><td>&nbsp;</td><td>anchor:cnnsi.com = &quot;CNN&quot;</td><td>&nbsp;</td></tr><tr><td>&quot;com.cnn.www&quot;</td><td>t8</td><td>&nbsp;</td><td>anchor:my.look.ca = &quot;CNN.com&quot;</td><td>&nbsp;</td></tr><tr><td>&quot;com.cnn.www&quot;</td><td>t6</td><td>contents:html = &quot;&#x3c;html&gt;…<strong>&quot;</strong></td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&quot;com.cnn.www&quot;</td><td>t5</td><td>contents:html = &quot;&#x3c;html&gt;…<strong>&quot;</strong></td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&quot;com.cnn.www&quot;</td><td>t3</td><td>contents:html = &quot;&#x3c;html&gt;…<strong>&quot;</strong></td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&quot;com.example.www&quot;</td><td>t5</td><td>contents:html = &quot;&#x3c;html&gt;…<strong>&quot;</strong></td><td>&nbsp;</td><td>people:author = &quot;John Doe&quot;</td></tr></tbody>
</table></figure>

1. 上述表格有两行、三个列蔟（contens、ancho、people）
2. “com.cnn.www”这一行anchor列蔟两个列（anchor:cssnsi.com、anchor:my.look.ca）、contents列蔟有个1个列（html）
3. “com.cnn.www”在HBase中有 t3、t5、t6、t8、t9 5个版本的数据
4. HBase中如果某一行的列被更新的，那么最新的数据会排在最前面，换句话说同一个rowkey的数据是按照倒序排序的

## 常用shell操作

我们可以以shell的方式来维护和管理HBase。例如：执行建表语句、执行增删改查操作等等。

### 需求

有以下订单数据，我们想要将这样的一些数据保存到HBase中。

<figure class='table-figure'><table>
<thead>
<tr><th>订单ID</th><th>订单状态</th><th>支付金额</th><th>支付方式ID</th><th>用户ID</th><th>操作时间</th><th>商品分类</th></tr></thead>
<tbody><tr><td>001</td><td>已付款</td><td>200.5</td><td>1</td><td>001</td><td>2020-5-2 18:08:53</td><td>手机;</td></tr></tbody>
</table></figure>

<figure class='table-figure'><table>
<thead>
<tr><th>订单ID</th><th>订单状态</th><th>支付金额</th><th>支付方式ID</th><th>用户ID</th><th>操作时间</th><th>商品分类</th></tr></thead>
<tbody><tr><td>001</td><td>已付款</td><td>200.5</td><td>1</td><td>001</td><td>2020-5-2 18:08:53</td><td>手机;</td></tr></tbody>
</table></figure>

接下来，我们将使用HBase shell来进行以下操作：
1.创建表
2.添加数据
3.更新数据
4.删除数据
5.查询数据

### 创建表

在HBase中，所有的数据也都是保存在表中的。要将订单数据保存到HBase中，首先需要将表创建出来。

#### 启动HBase Shell

HBase的shell其实JRuby的IRB（交互式的Ruby），但在其中添加了一些HBase的命令。
启动HBase shell：
hbase shell

#### 创建表

语法：
create '表名','列蔟名'...

创建订单表，表名为ORDER_INFO，该表有一个列蔟为C1

```
create 'ORDER_INFO','C1';
```

注意：

1. create要写成小写
2. 一个表可以包含若干个列蔟
3. 命令解析：调用hbase提供的ruby脚本的create方法，传递两个字符串参数
4. 通过下面链接可以看到每个命令都是一个ruby脚本
   https://github.com/apache/hbase/tree/branch-2.1/hbase-shell/src/main/ruby/shell/commands

#### 查看表

```
hbase(main):005:0> list
TABLE                                                                                                                                              
ORDER_INFO                                                                                                                                         
1 row(s)
Took 0.0378 seconds                                                                                                                                
=> ["ORDER_INFO"]
```

#### 删除表

要删除某个表，必须要先禁用表

##### 禁用表

语法：disable "表名"

##### 删除表

语法：drop "表名"

##### 删除ORDER_INFO表

```
disable "ORDER_INFO"
drop "ORDER_INFO"
```

### 添加数据

#### 需求

接下来，我们需要往订单表中添加以下数据。

<figure class='table-figure'><table>
<thead>
<tr><th>订单ID</th><th>订单状态</th><th>支付金额</th><th>支付方式ID</th><th>用户ID</th><th>操作时间</th><th>商品分类</th></tr></thead>
<tbody><tr><td>ID</td><td>STATUS</td><td>PAY_MONEY</td><td>PAYWAY</td><td>USER_ID</td><td>OPERATION_DATE</td><td>CATEGORY</td></tr><tr><td>000001</td><td>已提交</td><td>4070</td><td>1</td><td>4944191</td><td>2020-04-25 12:09:16</td><td>手机;</td></tr></tbody>
</table></figure>

#### PUT操作

HBase中的put命令，可以用来将数据保存到表中。但put一次只能保存一个列的值。以下是put的语法结构：

```
put '表名','ROWKEY','列蔟名:列名','值'
```

要添加以上的数据，需要使用7次put操作。如下：

```
put 'ORDER_INFO','000001','C1:ID','000001'
put 'ORDER_INFO','000001','C1:STATUS','已提交'
put 'ORDER_INFO','000001','C1:PAY_MONEY',4070
put 'ORDER_INFO','000001','C1:PAYWAY',1
put 'ORDER_INFO','000001','C1:USER_ID',4944191
put 'ORDER_INFO','000001','C1:OPERATION_DATE','2020-04-25 12:09:16'
put 'ORDER_INFO','000001','C1:CATEGORY','手机;'
```

### 查看添加的数据

#### 需求

要求将rowkey为：000001对应的数据查询出来。

#### get命令

在HBase中，可以使用get命令来获取单独的一行数据。语法：

```
get '表名','rowkey'
```

#### 查询指定订单ID的数据

get 'ORDER_INFO','000001'

<figure class='table-figure'><table>
<thead>
<tr><th>COLUMN</th><th>CELL</th></tr></thead>
<tbody><tr><td>C1:CATEGORY</td><td>timestamp=1588415690678, value=\xE6\x89\x8B\xE6\x9C\xBA;</td></tr><tr><td>C1:OPERATION_DATE</td><td>timestamp=1588415689773, value=2020-04-25 12:09:16</td></tr><tr><td>C1:PAYWAY</td><td>timestamp=1588415689681, value=1</td></tr><tr><td>C1:PAY_MONEY</td><td>timestamp=1588415689643, value=4070</td></tr><tr><td>C1:STATUS</td><td>timestamp=1588415689591, value=\xE5\xB7\xB2\xE6\x8F\x90\xE4\xBA\xA4</td></tr><tr><td>C1:USER_ID</td><td>timestamp=1588415689721, value=4944191</td></tr></tbody>
</table></figure>

#### 显示中文

在HBase shell中，如果在数据中出现了一些中文，默认HBase shell中显示出来的是十六进制编码。要想将这些编码显示为中文，我们需要在get命令后添加一个属性：{FORMATTER => 'toString'}

##### 查看订单的数据

```
get 'ORDER_INFO','000001', {FORMATTER => 'toString'}
```

注：

1. { key => value}，这个是Ruby语法，表示定义一个HASH结构
2. get是一个HBase Ruby方法，’ORDER_INFO’、’000001’、{FORMATTER => 'toString'}是put方法的三个参数
3. FORMATTER要使用大写
4. 在Ruby中用{}表示一个字典，类似于hashtable，FORMATTER表示key、’toString’表示值

### 更新操作

#### 需求

将订单ID为000001的状态，更改为「已付款」

#### 使用put来更新数据

同样，在HBase中，也是使用put命令来进行数据的更新，语法与之前的添加数据一模一样。

#### 更新指定的列

```
put 'ORDER_INFO', '000001', 'C1:STATUS', '已付款'
```

注意：

1. HBase中会自动维护数据的版本
2. 每当执行一次put后，都会重新生成新的时间戳

```
C1:STATUS   timestamp=1588748844082, value=已提交
C1:STATUS   timestamp=1588748952074, value=已付款
C1:STATUS   timestamp=1588748994244, value=已付款
```

### 删除操作

#### 删除状态列数据

##### 需求

将订单ID为000001的状态列删除。

##### delete命令

在HBase中，可以使用delete命令来将一个单元格的数据删除。语法格式如下：
delete '表名', 'rowkey', '列蔟:列'。
**注意：此处HBase默认会保存多个时间戳的版本数据，所以这里的delete删除的是最新版本的列数据。**

##### 删除指定的列

delete 'ORDER_INFO','000001','C1:STATUS'

#### 删除整行数据

##### 需求

将订单ID为000001的信息全部删除（删除所有的列）

##### deleteall命令

deleteall命令可以将指定rowkey对应的所有列全部删除。语法：
deleteall '表名','rowkey'

##### 删除指定的订单

deleteall 'ORDER_INFO','000001'

#### 清空表

##### 需求

将ORDER_INFO的数据全部删除

##### truncate命令

truncate命令用来清空某个表中的所有数据。语法：
truncate "表名"

##### 清空ORDER_INFO的所有数据

truncate 'ORDER_INFO'

### 导入测试数据集

#### 需求

在资料的 数据集/ ORDER_INFO.txt 中，有一份这样的HBase数据集，我们需要将这些指令放到HBase中执行，将数据导入到HBase中。

可以看到这些都是一堆的put语句。那么如何才能将这些语句全部执行呢？

![image.png](https://image.hyly.net/i/2025/09/28/b8c61121b8c30fcc482d809273d2e01b-0.webp)

#### 执行command文件

##### 上传command文件

将该数据集文件上传到指定的目录中

##### 执行

使用以下命令执行：
hbase shell /export/software/ORDER_INFO.txt
即可。

### 计数操作

#### 需求

查看HBase中的ORDER_INFO表，一共有多少条记录。

#### count命令

count命令专门用来统计一个表中有多少条数据。语法：
count ‘表名’

**注意：这个操作是比较耗时的。在数据量大的这个命令可能会运行很久。**

#### 获取订单数据

count 'ORDER_INFO'

### 大量数据的计数统计

当HBase中数据量大时，可以使用HBase中提供的MapReduce程序来进行计数统计。语法如下：
$HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.RowCounter '表名'

#### 启动YARN集群

```
启动yarn集群
start-yarn.sh
启动history server
mr-jobhistory-daemon.sh start historyserver
```

#### 执行MR JOB

```
$HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.RowCounter 'ORDER_INFO'
```

通过观察YARN的WEB UI，我们发现HBase启动了一个名字为rowcounter_ORDER_INFO的作业。

![image.png](https://image.hyly.net/i/2025/09/28/0e8a740cc2baea2a21eb5d09ca0b0a8c-0.webp)

### 扫描操作

#### 需求一：查询订单所有数据

##### 需求

查看ORDER_INFO表中所有的数据

##### scan命令

在HBase，我们可以使用scan命令来扫描HBase中的表。语法：
scan '表名'

##### 扫描ORDER_INFO表

```
scan 'ORDER_INFO',{FORMATTER => 'toString'}
```

**注意：要避免scan一张大表！**

#### 需求二：查询订单数据（只显示3条）

```
scan 'ORDER_INFO', {LIMIT => 3, FORMATTER => 'toString'}
```

#### 需求三：查询订单状态、支付方式

##### 需求

只查询订单状态以及支付方式，并且只展示3条数据

##### 命令

```
scan 'ORDER_INFO', {LIMIT => 3, COLUMNS => ['C1:STATUS', 'C1:PAYWAY'], FORMATTER => 'toString'}
```

注意：
[‘C1:STATUS’, …]在Ruby中[]表示一个数组

#### 需求四：查询指定订单ID的数据并以中文展示

根据ROWKEY来查询对应的数据，ROWKEY为02602f66-adc7-40d4-8485-76b5632b5b53，只查询订单状态、支付方式，并以中文展示。

要查询指定ROWKEY的数据，需要使用ROWPREFIXFILTER，用法为：

```
scan '表名', {ROWPREFIXFILTER => 'rowkey'}
```

实现指令：

```
scan 'ORDER_INFO', {ROWPREFIXFILTER => '02602f66-adc7-40d4-8485-76b5632b5b53', COLUMNS => ['C1:STATUS', 'C1:PAYWAY'], FORMATTER => 'toString'}
```

### 过滤器

#### 简介

在HBase中，如果要对海量的数据来进行查询，此时基本的操作是比较无力的。此时，需要借助HBase中的高级语法——Filter来进行查询。Filter可以根据列簇、列、版本等条件来对数据进行过滤查询。因为在HBase中，主键、列、版本都是有序存储的，所以借助Filter，可以高效地完成查询。当执行Filter时，HBase会将Filter分发给各个HBase服务器节点来进行查询。

HBase中的过滤器也是基于Java开发的，只不过在Shell中，我们是使用基于JRuby的语法来实现的交互式查询。以下是HBase 2.2的JAVA API文档。
http://hbase.apache.org/2.2/devapidocs/index.html

#### HBase中的过滤器

在HBase的shell中，通过show_filters指令，可以查看到HBase中内置的一些过滤器。

```
hbase(main):028:0> show_filters
DependentColumnFilter                                                                                                                             
KeyOnlyFilter                                                                                                                                     
ColumnCountGetFilter                                                                                                                              
SingleColumnValueFilter                                                                                                                           
PrefixFilter                                                                                                                                      
SingleColumnValueExcludeFilter                                                                                                                    
FirstKeyOnlyFilter                                                                                                                                
ColumnRangeFilter                                                                                                                                 
ColumnValueFilter                                                                                                                                 
TimestampsFilter                                                                                                                                  
FamilyFilter                                                                                                                                      
QualifierFilter                                                                                                                                   
ColumnPrefixFilter                                                                                                                                
RowFilter                                                                                                                                         
MultipleColumnPrefixFilter                                                                                                                        
InclusiveStopFilter                                                                                                                               
PageFilter                                                                                                                                        
ValueFilter                                                                                                                                       
ColumnPaginationFilter
```

<figure class='table-figure'><table>
<thead>
<tr><th><strong>rowkey</strong>过滤器</th><th>RowFilter</th><th>实现行键字符串的比较和过滤</th></tr></thead>
<tbody><tr><td>&nbsp;</td><td>PrefixFilter</td><td>rowkey前缀过滤器</td></tr><tr><td>&nbsp;</td><td>KeyOnlyFilter</td><td>只对单元格的键进行过滤和显示，不显示值</td></tr><tr><td>&nbsp;</td><td>FirstKeyOnlyFilter</td><td>只扫描显示相同键的第一个单元格，其键值对会显示出来</td></tr><tr><td>&nbsp;</td><td>InclusiveStopFilter</td><td>替代ENDROW 返回终止条件行</td></tr><tr><td><strong>列过滤器</strong></td><td>FamilyFilter</td><td>列簇过滤器</td></tr><tr><td>&nbsp;</td><td>QualifierFilter</td><td>列标识过滤器，只显示对应列名的数据</td></tr><tr><td>&nbsp;</td><td>ColumnPrefixFilter</td><td>对列名称的前缀进行过滤</td></tr><tr><td>&nbsp;</td><td>MultipleColumnPrefixFilter</td><td>可以指定多个前缀对列名称过滤</td></tr><tr><td>&nbsp;</td><td>ColumnRangeFilter</td><td>过滤列名称的范围</td></tr><tr><td><strong>值过滤器</strong></td><td>ValueFilter</td><td>值过滤器，找到符合值条件的键值对</td></tr><tr><td>&nbsp;</td><td>SingleColumnValueFilter</td><td>在指定的列蔟和列中进行比较的值过滤器</td></tr><tr><td>&nbsp;</td><td>SingleColumnValueExcludeFilter</td><td>排除匹配成功的值</td></tr><tr><td><strong>其他过滤器</strong></td><td>ColumnPaginationFilter</td><td>对一行的所有列分页，只返回[offset,offset+limit] 范围内的列</td></tr><tr><td>&nbsp;</td><td>PageFilter</td><td>对显示结果按行进行分页显示</td></tr><tr><td>&nbsp;</td><td>TimestampsFilter</td><td>时间戳过滤，支持等值，可以设置多个时间戳</td></tr><tr><td>&nbsp;</td><td>ColumnCountGetFilter</td><td>限制每个逻辑行返回键值对的个数，在get 方法中使用</td></tr><tr><td>&nbsp;</td><td>DependentColumnFilter</td><td>允许用户指定一个参考列或引用列来过滤其他列的过滤器</td></tr></tbody>
</table></figure>

Java API官方地址：https://hbase.apache.org/devapidocs/index.html

#### 过滤器的用法

过滤器一般结合scan命令来使用。打开HBase的JAVA API文档。找到RowFilter的构造器说明，我们来看以下，HBase的过滤器该如何使用。
**scan '表名', { Filter => "过滤器(比较运算符, '比较器表达式')” }**

##### 比较运算符

<figure class='table-figure'><table>
<thead>
<tr><th><strong>比较运算符</strong></th><th><strong>描述</strong></th></tr></thead>
<tbody><tr><td>=</td><td>等于</td></tr><tr><td>&gt;</td><td>大于</td></tr><tr><td>&gt;=</td><td>大于等于</td></tr><tr><td>&#x3c;</td><td>小于</td></tr><tr><td>&#x3c;=</td><td>小于等于</td></tr><tr><td>!=</td><td>不等于</td></tr></tbody>
</table></figure>

##### 比较器

<figure class='table-figure'><table>
<thead>
<tr><th><strong>比较器</strong></th><th><strong>描述</strong></th></tr></thead>
<tbody><tr><td>BinaryComparator</td><td>匹配完整字节数组</td></tr><tr><td>BinaryPrefixComparator</td><td>匹配字节数组前缀</td></tr><tr><td>BitComparator</td><td>匹配比特位</td></tr><tr><td>NullComparator</td><td>匹配空值</td></tr><tr><td>RegexStringComparator</td><td>匹配正则表达式</td></tr><tr><td>SubstringComparator</td><td>匹配子字符串</td></tr></tbody>
</table></figure>

##### 比较器表达式

基本语法：比较器类型:比较器的值

<figure class='table-figure'><table>
<thead>
<tr><th><strong>比较器</strong></th><th><strong>表达式语言缩写</strong></th></tr></thead>
<tbody><tr><td>BinaryComparator</td><td>binary:值</td></tr><tr><td>BinaryPrefixComparator</td><td>binaryprefix:值</td></tr><tr><td>BitComparator</td><td>bit:值</td></tr><tr><td>NullComparator</td><td>null</td></tr><tr><td>RegexStringComparator</td><td>regexstring:正则表达式</td></tr><tr><td>SubstringComparator</td><td>substring:值</td></tr></tbody>
</table></figure>

#### 需求一：使用RowFilter查询指定订单ID的数据

##### 需求

只查询订单的ID为：02602f66-adc7-40d4-8485-76b5632b5b53、订单状态以及支付方式

**分析**
1.因为要订单ID就是ORDER_INFO表的rowkey，所以，我们应该使用rowkey过滤器来过滤
2.通过HBase的JAVA API，找到RowFilter构造器

![image.png](https://image.hyly.net/i/2025/09/28/1a36a1be4fb34c7db00b550f6340c047-0.webp)

通过上图，可以分析得到，RowFilter过滤器接受两个参数，

1. op——比较运算符
2. rowComparator——比较器

所以构建该Filter的时候，只需要传入两个参数即可

##### 命令

```
scan 'ORDER_INFO', {FILTER => "RowFilter(=,'binary:02602f66-adc7-40d4-8485-76b5632b5b53')"}
```

#### 需求二：查询状态为已付款的订单

##### 需求

查询状态为「已付款」的订单

**分析**
1.因为此处要指定列来进行查询，所以，我们不再使用rowkey过滤器，而是要使用列过滤器
2.我们要针对指定列和指定值进行过滤，比较适合使用SingleColumnValueFilter过滤器，查看JAVA API

![image.png](https://image.hyly.net/i/2025/09/28/85150e1b5eaf502e32e6fe0f18db7611-0.webp)

需要传入四个参数：

1. 列簇
2. 列标识（列名）
3. 比较运算符
4. 比较器

**注意：**

1. 列名STATUS的大小写一定要对！此处使用的是大写！
2. 列名写错了查不出来数据，但HBase不会报错，因为HBase是无模式的

##### 命令

```
scan 'ORDER_INFO', {FILTER => "SingleColumnValueFilter('C1', 'STATUS', =, 'binary:已付款')", FORMATTER => 'toString'}
```

#### 需求三：查询支付方式为1，且金额大于3000的订单

分析

1. 此处需要使用多个过滤器共同来实现查询，多个过滤器，可以使用AND或者OR来组合多个过滤器完成查询
2. 使用SingleColumnValueFilter实现对应列的查询

##### 命令

1.查询支付方式为1
SingleColumnValueFilter('C1', 'PAYWAY', = , 'binary:1')
2.查询金额大于3000的订单
SingleColumnValueFilter('C1', 'PAY_MONEY', > , 'binary:3000')
3.组合查询
scan 'ORDER_INFO', {FILTER => "SingleColumnValueFilter('C1', 'PAYWAY', = , 'binary:1') AND SingleColumnValueFilter('C1', 'PAY_MONEY', > , 'binary:3000')", FORMATTER => 'toString'}

**注意：**

1. HBase shell中比较默认都是字符串比较，所以如果是比较数值类型的，会出现不准确的情况
2. 例如：在字符串比较中4000是比100000大的

### INCR

#### 需求

某新闻APP应用为了统计每个新闻的每隔一段时间的访问次数，他们将这些数据保存在HBase中。
该表格数据如下所示：

<figure class='table-figure'><table>
<thead>
<tr><th>新闻ID</th><th>访问次数</th><th>时间段</th><th>ROWKEY</th></tr></thead>
<tbody><tr><td>0000000001</td><td>12</td><td>00:00-01:00</td><td>0000000001_00:00-01:00</td></tr><tr><td>0000000002</td><td>12</td><td>01:00-02:00</td><td>0000000002_01:00-02:00</td></tr></tbody>
</table></figure>

要求：原子性增加新闻的访问次数值。

#### incr操作简介

incr可以实现对某个单元格的值进行原子性计数。语法如下：
incr '表名','rowkey','列蔟:列名',累加值（默认累加1）

1. 如果某一列要实现计数功能，必须要使用incr来创建对应的列
2. 使用put创建的列是不能实现累加的

#### 导入测试数据

![image.png](https://image.hyly.net/i/2025/09/28/d213c4112402f2c2ffe3f75f01f5e419-0.webp)

该脚本创建了一个表，名为NEWS_VISIT_CNT，列蔟为C1。并使用incr创建了若干个计数器，每个rowkey为：新闻的编号_时间段。CNT为count的缩写，表示访问的次数。

```
hbase shell /export/software/NEWS_VISIT_CNT.txt 
scan 'NEWS_VISIT_CNT', {LIMIT => 5, FORMATTER => 'toString'}
```

#### 需求一：对0000000020新闻01:00 - 02:00访问计数+1

1.获取0000000020这条新闻在01:00-02:00当前的访问次数

```
get_counter 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'
```

此处，如果用get获取到的数据是这样的：

```
base(main):029:0> get 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'
COLUMN                                           CELL                                                                                                                    
 C1:CNT                                          timestamp=1599529533072, value=\x00\x00\x00\x00\x00\x00\x00\x06                                                         
1 row(s)
Took 0.0243 seconds
```

2.使用incr进行累加

```
incr 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'
```

3.再次查案新闻当前的访问次数

```
get_counter 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'
```

### 更多的操作

以下连接可以查看到所有HBase中支持的SHELL脚本。
https://learnhbase.net/2013/03/02/hbase-shell-commands/

## shell管理操作

### status

例如：显示服务器状态

```
2.4.1 :062 > status
1 active master, 0 backup masters, 3 servers, 0 dead, 1.0000 average load
Took 0.0034 seconds   
```

### whoami

显示HBase当前用户，例如：

```
2.4.1 :066 > whoami
root (auth:SIMPLE)
    groups: root
Took 0.0080 seconds
```

### list

显示当前所有的表

```
2.4.1 :067 > list
TABLE                                                                                                                              
ORDER_INFO                                                                                                                         
1 row(s)
Took 0.0266 seconds                                                                                                                
 => ["ORDER_INFO"]
```

### count

统计指定表的记录数，例如：

```
2.4.1 :070 > count 'ORDER_INFO'
66 row(s)
Took 0.0404 seconds                                                                                                                
 => 66
```

### describe

展示表结构信息

```
2.4.1 :074 > describe 'ORDER_INFO'
Table ORDER_INFO is ENABLED                                                                                                        
ORDER_INFO                                                                                                                         
COLUMN FAMILIES DESCRIPTION                                                                                                        
{NAME => 'C1', VERSIONS => '1', EVICT_BLOCKS_ON_CLOSE => 'false', NEW_VERSION_BEHAVIOR => 'false', KEEP_DELETED_CELLS => 'FALSE', CACHE_DATA_ON_WRITE =
> 'false', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', MIN_VERSIONS => '0', REPLICATION_SCOPE => '0', BLOOMFILTER => 'ROW', CACHE_INDEX_ON_WRITE =
> 'false', IN_MEMORY => 'false', CACHE_BLOOMS_ON_WRITE => 'false', PREFETCH_BLOCKS_ON_OPEN => 'false', COMPRESSION => 'NONE', BLOCKCACHE => 'true', BLO
CKSIZE => '65536'}                                                                                                                 
1 row(s)
Took 0.0265 seconds  
```

### exists

检查表是否存在，适用于表量特别多的情况

```
2.4.1 :075 > exists 'ORDER_INFO'
Table ORDER_INFO does exist                                                                                                        
Took 0.0050 seconds                                                                                                                
 => true
```

### is_enabled、is_disabled

检查表是否启用或禁用

```
2.4.1 :077 > is_enabled 'ORDER_INFO'
true                                                                                                                           
Took 0.0058 seconds                                                                                                            
 => true 
2.4.1 :078 > is_disabled 'ORDER_INFO'
false                                                                                                                          
Took 0.0085 seconds                                                                                                            
 => 1
```

### alter

该命令可以改变表和列蔟的模式，例如：

```
# 创建一个USER_INFO表，两个列蔟C1、C2
create 'USER_INFO', 'C1', 'C2'
# 新增列蔟C3
alter 'USER_INFO', 'C3'
# 删除列蔟C3
alter 'USER_INFO', 'delete' => 'C3'
```

**注意：**
'delete' => 'C3'，还是一个Map结构，只不过只有一个key，可以省略两边的{}

### disable/enable

禁用一张表/启用一张表

### drop

删除一张表，记得在删除表之前必须先禁用

### truncate

清空表的数据，禁用表-删除表-创建表

## Hbase Java编程

### 需求与数据集

某某自来水公司，需要存储大量的缴费明细数据。以下截取了缴费明细的一部分内容。

<figure class='table-figure'><table>
<thead>
<tr><th>用户id</th><th>姓名</th><th>用户地址</th><th>性别</th><th>缴费时间</th><th>表示数（本次）</th><th>表示数（上次）</th><th>用量（立方）</th><th>合计金额</th><th>查表日期</th><th>最迟缴费日期</th></tr></thead>
<tbody><tr><td>4944191</td><td>登卫红</td><td>贵州省铜仁市德江县7单元267室</td><td>男</td><td>2020-05-10</td><td>308.1</td><td>283.1</td><td>25</td><td>150</td><td>2020-04-25</td><td>2020-06-09</td></tr></tbody>
</table></figure>

因为缴费明细的数据记录非常庞大，该公司的信息部门决定使用HBase来存储这些数据。并且，他们希望能够通过Java程序来访问这些数据。

### 准备工作

#### 创建IDEA Maven项目

<figure class='table-figure'><table>
<thead>
<tr><th>groupId</th><th>cn.itcast</th></tr></thead>
<tbody><tr><td>artifactId</td><td>hbase_op</td></tr></tbody>
</table></figure>

#### 导入pom依赖

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
            <groupId>org.apache.hbase</groupId>
            <artifactId>hbase-client</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>commons-io</groupId>
            <artifactId>commons-io</artifactId>
            <version>2.6</version>
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

#### 复制HBase和Hadoop配置文件

将以下三个配置文件复制到resource目录中

1. hbase-site.xml
   从Linux中下载：sz /export/server/hbase-2.1.0/conf/hbase-site.xml
2. core-site.xml
   从Linux中下载：sz /export/server/hadoop-2.7.5/etc/hadoop/core-site.xml
3. log4j.properties

**注意：请确认配置文件中的服务器节点hostname/ip地址配置正确**

#### 创建包结构和类

1.在test目录创建 cn.itcast.hbase.admin.api_test 包结构
2.创建TableAmdinTest类

#### 创建Hbase连接以及admin管理对象

要操作Hbase也需要建立Hbase的连接。此处我们仍然使用TestNG来编写测试。使用@BeforeTest初始化HBase连接，创建admin对象、@AfterTest关闭连接。

实现步骤：
1.使用HbaseConfiguration.create()创建Hbase配置
2.使用ConnectionFactory.createConnection()创建Hbase连接
3.要创建表，需要基于Hbase连接获取admin管理对象
4.使用admin.close、connection.close关闭连接

参考代码：

```
public class TableAmdinTest {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        admin = connection.getAdmin();
    }

    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}
```

### 需求一：使用Java代码创建表

创建一个名为WATER_BILL的表，包含一个列蔟C1。

实现步骤：

1. 判断表是否存在
   1. 存在，则退出
2. 使用TableDescriptorBuilder.newBuilder构建表描述构建器
3. 使用ColumnFamilyDescriptorBuilder.newBuilder构建列蔟描述构建器
4. 构建列蔟描述，构建表描述
5. 创建表

参考代码：

```
// 创建一个名为WATER_BILL的表，包含一个列蔟C1
@Test
public void createTableTest() throws IOException {
    // 表名
    String TABLE_NAME = "WATER_BILL";
    // 列蔟名
    String COLUMN_FAMILY = "C1";

    // 1. 判断表是否存在
    if(admin.tableExists(TableName.valueOf(TABLE_NAME))) {
        return;
    }

    // 2. 构建表描述构建器
    TableDescriptorBuilder tableDescriptorBuilder = TableDescriptorBuilder.newBuilder(TableName.valueOf(TABLE_NAME));

    // 3. 构建列蔟描述构建器
    ColumnFamilyDescriptorBuilder columnFamilyDescriptorBuilder = ColumnFamilyDescriptorBuilder.newBuilder(Bytes.toBytes(COLUMN_FAMILY));

    // 4. 构建列蔟描述
    ColumnFamilyDescriptor columnFamilyDescriptor = columnFamilyDescriptorBuilder.build();

    // 5. 构建表描述
    // 添加列蔟
    tableDescriptorBuilder.setColumnFamily(columnFamilyDescriptor);
    TableDescriptor tableDescriptor = tableDescriptorBuilder.build();

    // 6. 创建表
    admin.createTable(tableDescriptor);
}
```

### 需求三：使用Java代码删除表

实现步骤：
1.判断表是否存在
2.如果存在，则禁用表
3.再删除表

参考代码：

```
// 删除表
@Test
public void dropTable() throws IOException {
    // 表名
    TableName tableName = TableName.valueOf("WATER_BILL");

    // 1. 判断表是否存在
    if(admin.tableExists(tableName)) {
        // 2. 禁用表
        admin.disableTable(tableName);
        // 3. 删除表
        admin.deleteTable(tableName);
    }
}
```

### 需求二：往表中插入一条数据

#### 创建包

1.在 test 目录中创建 cn.itcast.hbase.data.api_test 包
2.创建DataOpTest类

#### 初始化Hbase连接

在@BeforeTest中初始化HBase连接，在@AfterTest中关闭Hbase连接。

参考代码：

```
public class DataOpTest {
    private Configuration configuration;
    private Connection connection;
  
    @BeforeTest
    public void beforeTest() throws IOException {
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
    }
  
    @AfterTest
    public void afterTest() throws IOException {
        connection.close();
    }
}
```

#### 插入姓名列数据

在表中插入一个行，该行只包含一个列。

<figure class='table-figure'><table>
<thead>
<tr><th>ROWKEY</th><th>姓名（列名：NAME）</th></tr></thead>
<tbody><tr><td>4944191</td><td>登卫红</td></tr></tbody>
</table></figure>

实现步骤：
1.使用Hbase连接获取Htable
2.构建ROWKEY、列蔟名、列名
3.构建Put对象（对应put命令）
4.添加姓名列
5.使用Htable表对象执行put操作
6.关闭Htable表对象

参考代码：

```
@Test
public void addTest() throws IOException {
    // 1.使用Hbase连接获取Htable
    TableName waterBillTableName = TableName.valueOf("WATER_BILL");
    Table waterBillTable = connection.getTable(waterBillTableName);

    // 2.构建ROWKEY、列蔟名、列名
    String rowkey = "4944191";
    String cfName = "C1";
    String colName = "NAME";

    // 3.构建Put对象（对应put命令）
    Put put = new Put(Bytes.toBytes(rowkey));

    // 4.添加姓名列
    put.addColumn(Bytes.toBytes(cfName)
        , Bytes.toBytes(colName)
        , Bytes.toBytes("登卫红"));

    // 5.使用Htable表对象执行put操作
    waterBillTable.put(put);
    // 6. 关闭表
    waterBillTable.close();
}
```

#### 查看HBase中的数据

get 'WATER_BILL','4944191',{FORMATTER => 'toString'}

#### 插入其他列

<figure class='table-figure'><table>
<thead>
<tr><th><strong>列名</strong></th><th><strong>说明</strong></th><th><strong>值</strong></th></tr></thead>
<tbody><tr><td>ADDRESS</td><td>用户地址</td><td>贵州省铜仁市德江县7单元267室</td></tr><tr><td>SEX</td><td>性别</td><td>男</td></tr><tr><td>PAY_DATE</td><td>缴费时间</td><td>2020-05-10</td></tr><tr><td>NUM_CURRENT</td><td>表示数（本次）</td><td>308.1</td></tr><tr><td>NUM_PREVIOUS</td><td>表示数（上次）</td><td>283.1</td></tr><tr><td>NUM_USAGE</td><td>用量（立方）</td><td>25</td></tr><tr><td>TOTAL_MONEY</td><td>合计金额</td><td>150</td></tr><tr><td>RECORD_DATE</td><td>查表日期</td><td>2020-04-25</td></tr><tr><td>LATEST_DATE</td><td>最迟缴费日期</td><td>2020-06-09</td></tr></tbody>
</table></figure>

参考代码：

```
@Test
public void addTest() throws IOException {
    // 1.使用Hbase连接获取Htable
    TableName waterBillTableName = TableName.valueOf("WATER_BILL");
    Table waterBillTable = connection.getTable(waterBillTableName);

    // 2.构建ROWKEY、列蔟名、列名
    String rowkey = "4944191";
    String cfName = "C1";
    String colName = "NAME";
    String colADDRESS = "ADDRESS";
    String colSEX = "SEX";
    String colPAY_DATE = "PAY_DATE";
    String colNUM_CURRENT = "NUM_CURRENT";
    String colNUM_PREVIOUS = "NUM_PREVIOUS";
    String colNUM_USAGE = "NUM_USAGE";
    String colTOTAL_MONEY = "TOTAL_MONEY";
    String colRECORD_DATE = "RECORD_DATE";
    String colLATEST_DATE = "LATEST_DATE";

    // 3.构建Put对象（对应put命令）
    Put put = new Put(Bytes.toBytes(rowkey));

    // 4.添加姓名列
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colName)
            , Bytes.toBytes("登卫红"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colADDRESS)
            , Bytes.toBytes("贵州省铜仁市德江县7单元267室"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colSEX)
            , Bytes.toBytes("男"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colPAY_DATE)
            , Bytes.toBytes("2020-05-10"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colNUM_CURRENT)
            , Bytes.toBytes("308.1"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colNUM_PREVIOUS)
            , Bytes.toBytes("283.1"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colNUM_USAGE)
            , Bytes.toBytes("25"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colTOTAL_MONEY)
            , Bytes.toBytes("150"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colRECORD_DATE)
            , Bytes.toBytes("2020-04-25"));
    put.addColumn(Bytes.toBytes(cfName)
            , Bytes.toBytes(colLATEST_DATE)
            , Bytes.toBytes("2020-06-09"));

    // 5.使用Htable表对象执行put操作
    waterBillTable.put(put);

    // 6. 关闭表
    waterBillTable.close();
}
```

### 需求三：查看一条数据

查询rowkey为4944191的所有列的数据，并打印出来。

实现步骤：
1.获取HTable
2.使用rowkey构建Get对象
3.执行get请求
4.获取所有单元格
5.打印rowkey
6.迭代单元格列表
7.关闭表

参考代码：

```
@Test
public void getOneTest() throws IOException {
    // 1. 获取HTable
    TableName waterBillTableName = TableName.valueOf("WATER_BILL");
    Table waterBilltable = connection.getTable(waterBillTableName);

    // 2. 使用rowkey构建Get对象
    Get get = new Get(Bytes.toBytes("4944191"));

    // 3. 执行get请求
    Result result = waterBilltable.get(get);

    // 4. 获取所有单元格
    List<Cell> cellList = result.listCells();

    // 打印rowkey
    System.out.println("rowkey => " + Bytes.toString(result.getRow()));

    // 5. 迭代单元格列表
    for (Cell cell : cellList) {
        // 打印列蔟名
        System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
        System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));

    }

    // 6. 关闭表
    waterBilltable.close();
}
```

### 需求四：删除一条数据

删除rowkey为4944191的整条数据。

实现步骤：
1.获取HTable对象
2.根据rowkey构建delete对象
3.执行delete请求
4.关闭表

参考代码：

```
// 删除rowkey为4944191的整条数据
@Test
public void deleteOneTest() throws IOException {
    // 1. 获取HTable对象
    Table waterBillTable = connection.getTable(TableName.valueOf("WATER_BILL"));

    // 2. 根据rowkey构建delete对象
    Delete delete = new Delete(Bytes.toBytes("4944191"));

    // 3. 执行delete请求
    waterBillTable.delete(delete);

    // 4. 关闭表
    waterBillTable.close();
}
```

### 需求五：导入数据

#### 需求

在资料中，有一份10W的抄表数据文件，我们需要将这里面的数据导入到HBase中。

#### Import JOB

在HBase中，有一个Import的MapReduce作业，可以专门用来将数据文件导入到HBase中。

用法

```
hbase org.apache.hadoop.hbase.mapreduce.Import 表名 HDFS数据文件路径
```

#### 导入数据

1.将资料中数据文件上传到Linux中
2.再将文件上传到hdfs中

```
hadoop fs -mkdir -p /water_bill/output_ept_10W
hadoop fs -put part-m-00000_10w /water_bill/output_ept_10W
```

3.启动YARN集群
start-yarn.sh
4.使用以下方式来进行数据导入

```
hbase org.apache.hadoop.hbase.mapreduce.Import WATER_BILL /water_bill/output_ept_10W
```

#### 导出数据

```
hbase org.apache.hadoop.hbase.mapreduce.Export WATER_BILL /water_bill/output_ept_10W_export
```

### 需求六：查询2020年6月份所有用户的用水量

#### 需求分析

在Java API中，我们也是使用scan + filter来实现过滤查询。2020年6月份其实就是从2020年6月1日到2020年6月30日的所有抄表数据。

#### 准备工作

1.在cn.itcast.hbase.data.api_test包下创建ScanFilterTest类
2.使用@BeforeTest、@AfterTest构建HBase连接、以及关闭HBase连接

#### 实现

实现步骤：

1. 获取表
2. 构建scan请求对象
3. 构建两个过滤器
   1. 构建两个日期范围过滤器（注意此处请使用RECORD_DATE——抄表日期比较
   2. 构建过滤器列表
4. 执行scan扫描请求
5. 迭代打印result
6. 迭代单元格列表
7. 关闭ResultScanner（这玩意把转换成一个个的类似get的操作，注意要关闭释放资源）
8. 关闭表

参考代码：

```
// 查询2020年6月份所有用户的用水量数据
@Test
public void queryTest1() throws IOException {
    // 1. 获取表
    Table waterBillTable = connection.getTable(TableName.valueOf("WATER_BILL"));
    // 2. 构建scan请求对象
    Scan scan = new Scan();
    // 3. 构建两个过滤器
    // 3.1 构建日期范围过滤器（注意此处请使用RECORD_DATE——抄表日期比较
    SingleColumnValueFilter startDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
            , Bytes.toBytes("RECORD_DATE")
            , CompareOperator.GREATER_OR_EQUAL
            , Bytes.toBytes("2020-06-01"));

    SingleColumnValueFilter endDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
            , Bytes.toBytes("RECORD_DATE")
            , CompareOperator.LESS_OR_EQUAL
            , Bytes.toBytes("2020-06-30"));

    // 3.2 构建过滤器列表
    FilterList filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL
            , startDateFilter
            , endDateFilter);

    scan.setFilter(filterList);

    // 4. 执行scan扫描请求
    ResultScanner resultScan = waterBillTable.getScanner(scan);

    // 5. 迭代打印result
    for (Result result : resultScan) {
        System.out.println("rowkey -> " + Bytes.toString(result.getRow()));
        System.out.println("------");

        List<Cell> cellList = result.listCells();

        // 6. 迭代单元格列表
        for (Cell cell : cellList) {
            // 打印列蔟名
            System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
            System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));

        }
        System.out.println("------");
    }

resultScanner.close();


    // 7. 关闭表
    waterBillTable.close();
}
```

#### 解决乱码问题

因为前面我们的代码，在打印所有的列时，都是使用字符串打印的，Hbase中如果存储的是int、double，那么有可能就会乱码了。

```
System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
```

要解决的话，我们可以根据列来判断，使用哪种方式转换字节码。如下：
1.NUM_CURRENT
2.NUM_PREVIOUS
3.NUM_USAGE
4.TOTAL_MONEY
这4列使用double类型展示，其他的使用string类型展示。

参考代码：

```
String colName = Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength());
System.out.print(colName);

if(colName.equals("NUM_CURRENT")
        || colName.equals("NUM_PREVIOUS")
        || colName.equals("NUM_USAGE")
        || colName.equals("TOTAL_MONEY")) {
    System.out.println(" => " + Bytes.toDouble(cell.getValueArray(), cell.getValueOffset()));
}
else {
    System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
}
```

## HBase高可用

考虑关于HBase集群的一个问题，在当前的HBase集群中，只有一个Master，一旦Master出现故障，将会导致HBase不再可用。所以，在实际的生产环境中，是非常有必要搭建一个高可用的HBase集群的。

### HBase高可用简介

HBase的高可用配置其实就是HMaster的高可用。要搭建HBase的高可用，只需要再选择一个节点作为HMaster，在HBase的conf目录下创建文件backup-masters，然后再backup-masters添加备份Master的记录。一条记录代表一个backup master，可以在文件配置多个记录。

### 搭建HBase高可用

1. 在hbase的conf文件夹中创建 backup-masters 文件

```
cd /export/server/hbase-2.1.0/conf
touch backup-masters
```

2. 将node2.itcast.cn和node3.itcast.cn添加到该文件中

```
vim backup-masters
node2.itcast.cn
node3.itcast.cn
```

3. 将backup-masters文件分发到所有的服务器节点中

```
scp backup-masters node2.itcast.cn:$PWD
scp backup-masters node3.itcast.cn:$PWD
```

4. 重新启动hbase

```
stop-hbase.sh
start-hbase.sh
```

5.查看webui，检查Backup Masters中是否有node2.itcast.cn、node3.itcast.cn
http://node1.itcast.cn:16010/master-status

![image.png](https://image.hyly.net/i/2025/09/28/f6cc9baca151ab42ed30ca9f651afef8-0.webp)

6. 尝试杀掉node1.itcast.cn节点上的master
kill -9 HMaster进程id

7. 访问http://node2.itcast.cn:16010和http://node3.itcast.cn:16010，观察是否选举了新的Master

![image.png](https://image.hyly.net/i/2025/09/28/73f49e3461f3bff2f31661f0b20c7421-0.webp)

## HBase架构

### 系统架构

![image.png](https://image.hyly.net/i/2025/09/28/482f22e4cd9d5d8fdf504a564123102c-0.webp)

#### Client

客户端，例如：发出HBase操作的请求。例如：之前我们编写的Java API代码、以及HBase shell，都是CLient

#### Master Server

在HBase的Web UI中，可以查看到Master的位置。

![image.png](https://image.hyly.net/i/2025/09/28/bf480e88f544c69f3d22cf4d0422b277-0.webp)

1. 监控RegionServer
2. 处理RegionServer故障转移
3. 处理元数据的变更
4. 处理region的分配或移除
5. 在空闲时间进行数据的负载均衡
6. 通过Zookeeper发布自己的位置给客户端

#### Region Server

![image.png](https://image.hyly.net/i/2025/09/28/20425e8888039ba8fb365c4926c32fc3-0.webp)

1. 处理分配给它的Region
2. 负责存储HBase的实际数据
3. 刷新缓存到HDFS
4. 维护HLog
5. 执行压缩
6. 负责处理Region分片
7. RegionServer中包含了大量丰富的组件，如下：
   1. Write-Ahead logs
   2. HFile(StoreFile)
   3. Store
   4. MemStore
   5. Region

### 逻辑结构模型

![image.png](https://image.hyly.net/i/2025/09/28/17067800d1a532f2efebd96ce014d969-0.webp)

#### Region

在HBASE中，表被划分为很多「Region」，并由Region Server提供服务

![image.png](https://image.hyly.net/i/2025/09/28/12533a40d778d94b80f39f9b9ebc56ce-0.webp)

#### Store

Region按列蔟垂直划分为「Store」，存储在HDFS在文件中

#### MemStore

1. MemStore与缓存内存类似
2. 当往HBase中写入数据时，首先是写入到MemStore
3. 每个列蔟将有一个MemStore
4. 当MemStore存储快满的时候，整个数据将写入到HDFS中的HFile中

#### StoreFile

1. 每当任何数据被写入HBASE时，首先要写入MemStore
2. 当MemStore快满时，整个排序的key-value数据将被写入HDFS中的一个新的HFile中
3. 写入HFile的操作是连续的，速度非常快
4. 物理上存储的是**HFile**

#### WAL

1. WAL全称为Write Ahead Log，它最大的作用就是	故障恢复
2. WAL是HBase中提供的一种高并发、持久化的日志保存与回放机制
3. 每个业务数据的写入操作（PUT/DELETE/INCR），都会保存在WAL中
4. 一旦服务器崩溃，通过回放WAL，就可以实现恢复崩溃之前的数据
5. 物理上存储是Hadoop的**Sequence File**

## 常见问题

### Could not find or load main class org.apache.hadoop.mapreduce.v2.app.MRAppMaster

1.找到$HADOOP_HOME/etc/mapred-site.xml,增加以下配置

```
<property>
  <name>yarn.app.mapreduce.am.env</name>
  <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
</property>
<property>
  <name>mapreduce.map.env</name>
  <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
</property>
<property>
  <name>mapreduce.reduce.env</name>
  <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
</property>
```

2.将配置文件分发到各个节点
3.重新启动YARN集群

### Caused by: java.net.ConnectException: Call to node2.itcast.cn/192.168.88.101:16020 failed on connection exception: org.apache.hbase.thirdparty.io.netty.channel.ConnectTimeoutException: connection timed out: node2.itcast.cn/192.168.88.101:16020

无法连接到HBase，请检查HBase的Master是否正常启动

### Starting namenodes on [localhost] ERROR: Attempting to launch hdfs namenode as root ，ERROR: but there is no HDFS_NAMENODE_USER defined. Aborting launch.

解决办法：
是因为缺少用户定义造成的，所以分别编辑开始和关闭脚本
$ vim sbin/start-dfs.sh
$ vim sbin/stop-dfs.sh
在顶部空白处添加内容：
HDFS_DATANODE_USER=root
HADOOP_SECURE_DN_USER=hdfs
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root

### Starting resourcemanager ERROR: Attempting to launch yarn resourcemanager as root ERROR: but there is no YARN_RESOURCEMANAGER_USER defined. Aborting launch. Starting nodemanagers ERROR: Attempting to launch yarn nodemanager as root ERROR: but there is no YARN_NODEMANAGER_USER defined. Aborting launch.

vim sbin/start-yarn.sh 
vim sbin/stop-yarn.sh 

YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=yarn
YARN_NODEMANAGER_USER=root

### Exception in thread "main" java.lang.UnsatisfiedLinkError: org.apache.hadoop.io.nativeio.NativeIO$POSIX.stat

解决方案：
将 hadoop.dll 放到c:/windows/system32文件夹中，重启IDEA，重新运行程序

## 重要工作机制

### 读数据流程

从zookeeper找到meta表的region的位置，然后读取meta表中的数据。而meta中又存储了用户表的region信息

```
ZK：/hbase/meta-region-server，该节点保存了meta表的region server数据
```

根据namespace、表名和rowkey根据meta表中的数据找到对应的region信息

```
hbase(main):014:0> scan "hbase:meta", { FILTER => "PrefixFilter('ORDER_DTL')"}
ORDER_DTL,,1599542264340.30b90c560200da7819da10dc27d8a6ca. column=info:state, timestamp=1599542721810, value=OPEN
ORDER_DTL,,1599542264340.30b90c560200da7819da10dc27d8a6ca.  column=info:regioninfo, timestamp=1599542721810, value={ENCODED => 30b90c560200da7819da10dc27d8a6ca, NAME => 'ORDER_DTL,,1599542264340.30b90c560200da7819da10dc27d8a6ca.', STARTKEY => '', ENDKEY => '\x01'}
ORDER_DTL,,1599542264340.30b90c560200da7819da10dc27d8a6ca. column=info:server, timestamp=1599542721810, value=node3.itcast.cn:16020
```

找到对应的regionserver，查找对应的region

![image.png](https://image.hyly.net/i/2025/09/28/65a0a0191fca7240206f177ce2586a7c-0.webp)

从MemStore找数据，再去BlockCache中找，如果没有，再到StoreFile上读
可以把MemStore理解为一级缓存，BlockCache为二级缓存，但注意scan的时候BlockCache意义不大，因为scan是顺序扫描

![image.png](https://image.hyly.net/i/2025/09/28/34421e8598929aff44af3d5ba7813e83-0.webp)

### 数据存储流程

1. HBase V2.x以前版本
   1. 写内存（MemStore）
   2. 二阶段StoreFiles合并
2. V2.x
   1. In-memory compaction（带合并的写内存）
   2. 二阶段StoreFiles合并

HBase的数据存储过程是分为几个阶段的。写入的过程与HBase的LSM结构对应。

1. 为了提高HBase的写入速度，数据都是先写入到MemStore（内存）结构中，V2.0 MemStore也会进行Compaction
2. MemStore写到一定程度（默认128M），由后台程序将MemStore的内容flush刷写到HDFS中的StoreFile
3. 数据量较大时，会产生很多的StoreFile。这样对高效读取不利，HBase会将这些小的StoreFile合并，一般3-10个文件合并成一个更大的StoreFile

#### 写入MemStore

![image.png](https://image.hyly.net/i/2025/09/28/3608c6414ba0e475ea4256919132d06d-0.webp)

1. Client访问zookeeper，从ZK中找到meta表的region位置
2. 读取meta表中的数据，根据namespace、表名、rowkey获取对应的Region信息
3. 通过刚刚获取的地址访问对应的RegionServer，拿到对应的表存储的RegionServer
4. 去表所在的RegionServer进行数据的添加
5. 查找对应的region，在region中寻找列族，先向MemStore中写入数据

#### MemStore溢写合并

![image.png](https://image.hyly.net/i/2025/09/28/35195b8fb0557497699034f4dd27899d-0.webp)

##### 说明

1. 当MemStore写入的值变多，触发溢写操作（flush），进行文件的溢写，成为一个StoreFile
2. 当溢写的文件过多时，会触发文件的合并（Compact）操作，合并有两种方式（major，minor）

##### 触发条件

一旦MemStore达到128M时，则触发Flush溢出（Region级别）

```
<property>
<name>hbase.hregion.memstore.flush.size</name>
<value>134217728</value>
<source>hbase-default.xml</source>
</property>
```

MemStore的存活时间超过1小时（默认），触发Flush溢写（RegionServer级别）

```
<property>
<name>hbase.regionserver.optionalcacheflushinterval</name>
<value>3600000</value>
<source>hbase-default.xml</source>
</property>
```

#### 模拟数据查看MemStore使用情况

![image.png](https://image.hyly.net/i/2025/09/28/c4a33ace002279dc4cefe464de7f5f17-0.webp)

**注意：此处小数是无法显示的，只显示整数位的MB。**

1. 在资料/测试程序中有一个GenWaterBill代码文件，将它导入到之前创建的Java操作HBase中，然后运行。
2. 打开HBase WebUI > Table Details > 「WATER_BILL」
3. 打开Region所在的Region Server

![image.png](https://image.hyly.net/i/2025/09/28/e33340d6cb31490f42ae04643d5a4f83-0.webp)

点击Memory查看内存占用情况

![image.png](https://image.hyly.net/i/2025/09/28/9bdf071a188dc6eae6a311e7847111f5-0.webp)

#### In-memory合并

##### In-memory compaction介绍

In-memory合并是HBase 2.0之后添加的。它与默认的MemStore的区别：实现了在内存中进行compaction（合并）。

在CompactingMemStore中，数据是以段（Segment）为单位存储数据的。MemStore包含了多个segment。

1. 当数据写入时，首先写入到的是Active segment中（也就是当前可以写入的segment段）
2. 在2.0之前，如果MemStore中的数据量达到指定的阈值时，就会将数据flush到磁盘中的一个StoreFile
3. 2.0的In-memory compaction，active segment满了后，将数据移动到pipeline中。这个过程跟以前不一样，以前是flush到磁盘，而这次是将Active segment的数据，移到称为pipeline的内存当中。一个pipeline中可以有多个segment。而In-memory compaction会将pipeline的多个segment合并为更大的、更紧凑的segment，这就是compaction
4. HBase会尽量延长CompactingMemStore的生命周期，以达到减少总的IO开销。当需要把CompactingMemStore flush到磁盘时，pipeline中所有的segment会被移动到一个snapshot中，然后进行合并后写入到HFile

![image.png](https://image.hyly.net/i/2025/09/28/d78fc141b1cc1e8afa11917485aa8af0-0.webp)

##### compaction策略

但Active segment flush到pipeline中后，后台会触发一个任务来合并pipeline中的数据。合并任务会扫描pipeline中所有的segment，将segment的索引合并为一个索引。有三种合并策略：

1. basic（基础型）
   1. Basic compaction策略不清理多余的数据版本，无需对cell的内存进行考核
   2. basic适用于所有大量写模式
2. eager（饥渴型）
   1. eager compaction会过滤重复的数据，清理多余的版本，这会带来额外的开销
   2. eager模式主要针对数据大量过期淘汰的场景，例如：购物车、消息队列等
3. adaptive（适应型）
   1. adaptive compaction根据数据的重复情况来决定是否使用eager策略
   2. 该策略会找出cell个数最多的一个，然后计算一个比例，如果比例超出阈值，则使用eager策略，否则使用basic策略

##### 配置

1.可以通过hbase-site.xml来配置默认In Memory Compaction方式

```
<property>
    <name>hbase.hregion.compacting.memstore.type</name> 
    <value><none|basic|eager|adaptive></value>
</property>
```

2.在创建表的时候指定

```
create "test_memory_compaction", {NAME => 'C1', IN_MEMORY_COMPACTION => "BASIC"}
```

![image.png](https://image.hyly.net/i/2025/09/28/a58bde2d800ab6b01ffdacc0745724aa-0.webp)

#### StoreFile合并

1. 当MemStore超过阀值的时候，就要flush到HDFS上生成一个StoreFile。因此随着不断写入，HFile的数量将会越来越多，根据前面所述，StoreFile数量过多会降低读性能
2. 为了避免对读性能的影响，需要对这些StoreFile进行compact操作，把多个HFile合并成一个HFile
3. compact操作需要对HBase的数据进行多次的重新读写，因此这个过程会产生大量的IO。可以看到compact操作的本质就是以IO操作换取后续的读性能的提高

##### minor compaction

###### 说明

1. Minor Compaction操作只用来做部分文件的合并操作，包括minVersion=0并且设置ttl的过期版本清理，不做任何删除数据、多版本数据的清理工作
2. 小范围合并，默认是3-10个文件进行合并，不会删除其他版本的数据
3. Minor Compaction则只会选择数个StoreFile文件compact为一个StoreFile
4. Minor Compaction的过程一般较快，而且IO相对较低

###### 触发条件

1. 在打开Region或者MemStore时会自动检测是否需要进行Compact（包括Minor、Major）
2. minFilesToCompact由hbase.hstore.compaction.min控制，默认值为3
3. 即Store下面的StoreFile数量减去正在compaction的数量 >=3时，需要做compaction

http://node1.itcast.cn:16010/conf

```
<property>
<name>hbase.hstore.compaction.min</name>
<value>3</value>
<final>false</final>
<source>hbase-default.xml</source>
</property>
```

##### major compaction

###### 说明

1. Major Compaction操作是对Region下的Store下的所有StoreFile执行合并操作，最终的结果是整理合并出一个文件
2. 一般手动触发，会删除其他版本的数据（不同时间戳的）

###### 触发条件

1. 如果无需进行Minor compaction，HBase会继续判断是否需要执行Major Compaction
2. 如果所有的StoreFile中，最老（时间戳最小）的那个StoreFile的时间间隔大于Major Compaction的时间间隔（hbase.hregion.majorcompaction——默认7天）

```
<property>
<name>hbase.hregion.majorcompaction</name>
<value>604800000</value>
<source>hbase-default.xml</source>
</property>
```

604800000毫秒 = 604800秒 = 168小时 = 7天

### Region管理

#### region分配

1. 任何时刻，一个region只能分配给一个region server
2. Master记录了当前有哪些可用的region server，以及当前哪些region分配给了哪些region server，哪些region还没有分配。当需要分配的新的region，并且有一个region server上有可用空间时，master就给这个region server发送一个装载请求，把region分配给这个region server。region server得到请求后，就开始对此region提供服务。

#### region server上线

1. Master使用ZooKeeper来跟踪region server状态
2. 当某个region server启动时
   1. 首先在zookeeper上的server目录下建立代表自己的znode
   2. 由于Master订阅了server目录上的变更消息，当server目录下的文件出现新增或删除操作时，master可以得到来自zookeeper的实时通知
   3. 一旦region server上线，master能马上得到消息。

#### region server下线

1. 当region server下线时，它和zookeeper的会话断开，ZooKeeper而自动释放代表这台server的文件上的独占锁
2. Master就可以确定
   1. region server和zookeeper之间的网络断开了
   2. region server挂了
3. 无论哪种情况，region server都无法继续为它的region提供服务了，此时master会删除server目录下代表这台region server的znode数据，并将这台region server的region分配给其它还活着的节点

#### Region分裂

1. 当region中的数据逐渐变大之后，达到某一个阈值，会进行裂变
   1. 一个region等分为两个region，并分配到不同的RegionServer
   2. 原本的Region会下线，新Split出来的两个Region会被HMaster分配到相应的HRegionServer上，使得原先1个Region的压力得以分流到2个Region上。

```
<-- Region最大文件大小为10G -->
<property>
<name>hbase.hregion.max.filesize</name>
<value>10737418240</value>
<final>false</final>
<source>hbase-default.xml</source>
</property>
```

1. HBase只是增加数据，所有的更新和删除操作，都是在Compact阶段做的
2. 用户写操作只需要进入到内存即可立即返回，从而保证I/O高性能读写

##### 自动分区

之前，我们在建表的时候，没有涉及过任何关于Region的设置，由HBase来自动进行分区。也就是Region达到一定大小就会自动进行分区。最小的分裂大小和table的某个region server的region 个数有关，当store file的大小大于如下公式得出的值的时候就会split，公式如下:

```
Min (R^2 * “hbase.hregion.memstore.flush.size”, “hbase.hregion.max.filesize”) R为同一个table中在同一个region server中region的个数。
```

1. 如果初始时R=1,那么Min(128MB,10GB)=128MB,也就是说在第一个flush的时候就会触发分裂操作
2. 当R=2的时候Min(22128MB,10GB)=512MB ,当某个store file大小达到512MB的时候，就会触发分裂
3. 如此类推，当R=9的时候，store file 达到10GB的时候就会分裂，也就是说当R>=9的时候，store file 达到10GB的时候就会分裂
4. split 点都位于region中row key的中间点

##### 手动分区

在创建表的时候，就可以指定表分为多少个Region。默认一开始的时候系统会只向一个RegionServer写数据，系统不指定startRow和endRow，可以在运行的时候提前Split，提高并发写入。

### Master工作机制

#### Master上线

Master启动进行以下步骤:
1.从zookeeper上获取唯一一个代表active master的锁，用来阻止其它master成为master
2.一般hbase集群中总是有一个master在提供服务，还有一个以上的‘master’在等待时机抢占它的位置。
3.扫描zookeeper上的server父节点，获得当前可用的region server列表
4.和每个region server通信，获得当前已分配的region和region server的对应关系
5.扫描.META.region的集合，计算得到当前还未分配的region，将他们放入待分配region列表

#### Master下线

1. 由于master只维护表和region的元数据，而不参与表数据IO的过程，master下线仅导致所有元数据的修改被冻结
   1. 无法创建删除表
   2. 无法修改表的schema
   3. 无法进行region的负载均衡
   4. 无法处理region 上下线
   5. 无法进行region的合并
   6. 唯一例外的是region的split可以正常进行，因为只有region server参与
   7. **表的数据读写还可以正常进行**
2. 因此master下线短时间内对整个hbase集群没有影响。
3. 从上线过程可以看到，master保存的信息全是可以冗余信息（都可以从系统其它地方收集到或者计算出来）

## HBase批量装载——Bulk load

### 简介

很多时候，我们需要将外部的数据导入到HBase集群中，例如：将一些历史的数据导入到HBase做备份。我们之前已经学习了HBase的Java API，通过put方式可以将数据写入到HBase中，我们也学习过通过MapReduce编写代码将HDFS中的数据导入到HBase。但这些方式都是基于HBase的原生API方式进行操作的。这些方式有一个共同点，就是需要与HBase连接，然后进行操作。HBase服务器要维护、管理这些连接，以及接受来自客户端的操作，会给HBase的存储、计算、网络资源造成较大消耗。此时，在需要将海量数据写入到HBase时，通过Bulk load（大容量加载）的方式，会变得更高效。可以这么说，进行大量数据操作，Bulk load是必不可少的。

我们知道，HBase的数据最终是需要持久化到HDFS。HDFS是一个文件系统，那么数据可定是以一定的格式存储到里面的。例如：Hive我们可以以ORC、Parquet等方式存储。而HBase也有自己的数据格式，那就是HFile。Bulk Load就是直接将数据写入到StoreFile（HFile）中，从而绕开与HBase的交互，HFile生成后，直接一次性建立与HBase的关联即可。使用BulkLoad，绕过了Write to WAL，Write to MemStore及Flush to disk的过程

更多可以参考官方对Bulk load的描述：https://hbase.apache.org/book.html#arch.bulk.load

### Bulk load MapReduce程序开发

Bulk load的流程主要分为两步：
1.通过MapReduce准备好数据文件（Store Files）
2.加载数据文件到HBase

### 银行转账记录海量冷数据存储案例

银行每天都产生大量的转账记录，超过一定时期的数据，需要定期进行备份存储。本案例，在MySQL中有大量转账记录数据，需要将这些数据保存到HBase中。因为数据量非常庞大，所以采用的是Bulk Load方式来加载数据。

1. 项目组为了方便数据备份，每天都会将对应的转账记录导出为CSV文本文件，并上传到HDFS。我们需要做的就将HDFS上的文件导入到HBase中。
2. 因为我们只需要将数据读取出来，然后生成对应的Store File文件。所以，我们编写的MapReduce程序，只有Mapper，而没有Reducer。

#### 数据集

<figure class='table-figure'><table>
<thead>
<tr><th>id</th><th>ID</th></tr></thead>
<tbody><tr><td>code</td><td>流水单号</td></tr><tr><td>rec_account</td><td>收款账户</td></tr><tr><td>rec_bank_name</td><td>收款银行</td></tr><tr><td>rec_name</td><td>收款人姓名</td></tr><tr><td>pay_account</td><td>付款账户</td></tr><tr><td>pay_name</td><td>付款人姓名</td></tr><tr><td>pay_comments</td><td>转账附言</td></tr><tr><td>pay_channel</td><td>转账渠道</td></tr><tr><td>pay_way</td><td>转账方式</td></tr><tr><td>status</td><td>转账状态</td></tr><tr><td>timestamp</td><td>转账时间</td></tr><tr><td>money</td><td>转账金额</td></tr></tbody>
</table></figure>

#### 项目准备工作

##### HBase中创建银行转账记录表

```
create_namespace "ITCAST_BANK"
# disable "TRANSFER_RECORD"
# drop "TRANSFER_RECORD"
create "ITCAST_BANK:TRANSFER_RECORD", { NAME => "C1", COMPRESSION => "GZ"}, { NUMREGIONS => 6, SPLITALGO => "HexStringSplit"}
```

##### 创建项目

<figure class='table-figure'><table>
<thead>
<tr><th>groupid</th><th>cn.itcast</th></tr></thead>
<tbody><tr><td>artifactid</td><td>bankrecord_bulkload</td></tr></tbody>
</table></figure>

##### 导入POM依赖

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
        <groupId>org.apache.hbase</groupId>
        <artifactId>hbase-client</artifactId>
        <version>2.1.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hbase</groupId>
        <artifactId>hbase-mapreduce</artifactId>
        <version>2.1.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-mapreduce-client-jobclient</artifactId>
        <version>2.7.5</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-common</artifactId>
        <version>2.7.5</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-mapreduce-client-core</artifactId>
        <version>2.7.5</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-auth</artifactId>
        <version>2.7.5</version>
    </dependency>
    <dependency>
        <groupId>org.apache.hadoop</groupId>
        <artifactId>hadoop-hdfs</artifactId>
        <version>2.7.5</version>
    </dependency>
    <dependency>
        <groupId>commons-io</groupId>
        <artifactId>commons-io</artifactId>
        <version>2.6</version>
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

##### 创建包结构

<figure class='table-figure'><table>
<thead>
<tr><th>包</th><th>说明</th></tr></thead>
<tbody><tr><td>cn.itcast.bank_record.bulkload.mr</td><td>MapReduce相关代码</td></tr><tr><td>cn.itcast.bank_record.entity</td><td>实体类</td></tr></tbody>
</table></figure>

##### 导入配置文件

将 core-site.xml、hbase-site.xml、log4j.properties三个配置文件拷贝到resources目录中。

##### 确保Windows环境变量配置正确

1.HADOOP_HOME

![image.png](https://image.hyly.net/i/2025/09/28/7798b3e83c33979efd3ead990d1dab2e-0.webp)

在资料包里面，有一个hadoop_windows客户端文件夹，该文件夹中有一个压缩包，从压缩包中很多windows版本的客户端，找一个2.7.4版本，解压到指定目录即可。

2.HADOOP_USER_NAME

![image.png](https://image.hyly.net/i/2025/09/28/774ac2f3b807c122921a739eb5508019-0.webp)

#### 编写实体类

实现步骤：
1.创建实体类TransferRecord
2.添加一个parse静态方法，用来将逗号分隔的字段，解析为实体类
使用以下数据测试解析是否成功

```
7e59c946-b1c6-4b04-a60a-f69c7a9ef0d6,SU8sXYiQgJi8,6225681772493291,杭州银行,丁杰,4896117668090896,卑文彬,老婆，节日快乐,电脑客户端,电子银行转账,转账完成,2020-5-13 21:06:92,11659.0
```

参考代码：

```
public class TransferRecord {
    private String id;
    private String code;
    private String rec_account;
    private String rec_bank_name;
    private String rec_name;
    private String pay_account;
    private String pay_name;
    private String pay_comments;
    private String pay_channel;
    private String pay_way;
    private String status;
    private String timestamp;
    private String money;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getRec_account() {
        return rec_account;
    }

    public void setRec_account(String rec_account) {
        this.rec_account = rec_account;
    }

    public String getRec_bank_name() {
        return rec_bank_name;
    }

    public void setRec_bank_name(String rec_bank_name) {
        this.rec_bank_name = rec_bank_name;
    }

    public String getRec_name() {
        return rec_name;
    }

    public void setRec_name(String rec_name) {
        this.rec_name = rec_name;
    }

    public String getPay_account() {
        return pay_account;
    }

    public void setPay_account(String pay_account) {
        this.pay_account = pay_account;
    }

    public String getPay_name() {
        return pay_name;
    }

    public void setPay_name(String pay_name) {
        this.pay_name = pay_name;
    }

    public String getPay_comments() {
        return pay_comments;
    }

    public void setPay_comments(String pay_comments) {
        this.pay_comments = pay_comments;
    }

    public String getPay_channel() {
        return pay_channel;
    }

    public void setPay_channel(String pay_channel) {
        this.pay_channel = pay_channel;
    }

    public String getPay_way() {
        return pay_way;
    }

    public void setPay_way(String pay_way) {
        this.pay_way = pay_way;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getMoney() {
        return money;
    }

    public void setMoney(String money) {
        this.money = money;
    }

    @Override
    public String toString() {
        return "TransferRecord{" +
                "id='" + id + '\'' +
                ", code='" + code + '\'' +
                ", rec_account='" + rec_account + '\'' +
                ", rec_bank_name='" + rec_bank_name + '\'' +
                ", rec_name='" + rec_name + '\'' +
                ", pay_account='" + pay_account + '\'' +
                ", pay_name='" + pay_name + '\'' +
                ", pay_comments='" + pay_comments + '\'' +
                ", pay_channel='" + pay_channel + '\'' +
                ", pay_way='" + pay_way + '\'' +
                ", status='" + status + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", money='" + money + '\'' +
                '}';
    }

    public static TransferRecord parse(String line) {
        TransferRecord transferRecord = new TransferRecord();
        String[] fields = line.split(",");

        transferRecord.setId(fields[0]);
        transferRecord.setCode(fields[1]);
        transferRecord.setRec_account(fields[2]);
        transferRecord.setRec_bank_name(fields[3]);
        transferRecord.setRec_name(fields[4]);
        transferRecord.setPay_account(fields[5]);
        transferRecord.setPay_name(fields[6]);
        transferRecord.setPay_comments(fields[7]);
        transferRecord.setPay_channel(fields[8]);
        transferRecord.setPay_way(fields[9]);
        transferRecord.setStatus(fields[10]);
        transferRecord.setTimestamp(fields[11]);
        transferRecord.setMoney(fields[12]);

        return transferRecord;
    }

    public static void main(String[] args) {
        String str = "7e59c946-b1c6-4b04-a60a-f69c7a9ef0d6,SU8sXYiQgJi8,6225681772493291,杭州银行,丁杰,4896117668090896,卑文彬,老婆，节日快乐,电脑客户端,电子银行转账,转账完成,2020-5-13 21:06:92,11659.0";
        TransferRecord tr = parse(str);

        System.out.println(tr);
    }
}
```

#### 构建读取数据的Mapper

HBase提供了两个类来专门对MapReduce支持：
1.ImmutableBytesWritable：对应rowkey
2.MapReduceExtendedCell：对应 列 → 值（键值对）

实现步骤：

1. 创建一个BankRecordMapper的类继承Mapper类，Mapper的泛型为
   1. 输入key：LongWritable
   2. 输入value：Text
   3. 输出key：ImmutableBytesWritable
   4. 输出value：MapReduceExtendedCell
2. 将Mapper获取到Text文本行，转换为TransferRecord实体类
3. 从实体类中获取ID，并转换为rowkey
4. 使用KeyValue类构建单元格，每个需要写入到表中的字段都需要构建出来单元格
5. 使用context.write将输出输出
   1. 构建输出key：new ImmutableBytesWrite(rowkey)
   2. 构建输出的value：new MapReduceExtendedCell(keyvalue对象)

参考代码：

```
import cn.itcast.bank_record.entity.TransferRecord;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.util.MapReduceExtendedCell;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class BankRecordMapper extends Mapper<LongWritable, Text, ImmutableBytesWritable, MapReduceExtendedCell> {
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // HBase需要有rowkey，列名 => 值
        TransferRecord transferRecord = TransferRecord.parse(value.toString());
        String rowkey = transferRecord.getId();

        // 列蔟
        byte[] cf = Bytes.toBytes("C1");
        byte[] colId = Bytes.toBytes("id");
        byte[] colCode = Bytes.toBytes("code");
        byte[] colRec_account = Bytes.toBytes("rec_account");
        byte[] colRec_bank_name = Bytes.toBytes("rec_bank_name");
        byte[] colRec_name = Bytes.toBytes("rec_name");
        byte[] colPay_account = Bytes.toBytes("pay_account");
        byte[] colPay_name = Bytes.toBytes("pay_name");
        byte[] colPay_comments = Bytes.toBytes("pay_comments");
        byte[] colPay_channel = Bytes.toBytes("pay_channel");
        byte[] colPay_way = Bytes.toBytes("pay_way");
        byte[] colStatus = Bytes.toBytes("status");
        byte[] colTimestamp = Bytes.toBytes("timestamp");
        byte[] colMoney = Bytes.toBytes("money");

        KeyValue idKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getId()));
        KeyValue codeKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getCode()));
        KeyValue rec_accountKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getRec_account()));
        KeyValue rec_bank_nameKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getRec_bank_name()));
        KeyValue rec_nameKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getRec_name()));
        KeyValue pay_accountKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getPay_account()));
        KeyValue pay_nameKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getPay_name()));
        KeyValue pay_commentsKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getPay_comments()));
        KeyValue pay_channelKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getPay_channel()));
        KeyValue pay_wayKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getPay_way()));
        KeyValue statusKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getStatus()));
        KeyValue timestampKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getTimestamp()));
        KeyValue moneyKeyValue = new KeyValue(Bytes.toBytes(rowkey), cf, colId, Bytes.toBytes(transferRecord.getMoney()));

        ImmutableBytesWritable rowkeyWritable = new ImmutableBytesWritable(Bytes.toBytes(rowkey));
        context.write(rowkeyWritable, new MapReduceExtendedCell(idKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(codeKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(rec_accountKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(rec_bank_nameKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(rec_nameKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(pay_accountKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(pay_nameKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(pay_commentsKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(pay_channelKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(pay_wayKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(statusKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(timestampKeyValue));
        context.write(rowkeyWritable, new MapReduceExtendedCell(moneyKeyValue));
    }
}
```

#### 编写驱动类

分析：
MapReduce执行时，需要读取HBase表的region相关信息，故需要获取HBase的表

实现步骤：

1. 使用HBaseConfiguration.create()加载配置文件
2. 创建HBase连接
3. 获取HTable
4. 构建MapReduce JOB
   1. 使用Job.getInstance构建一个Job对象
   2. 调用setJarByClass设置要执行JAR包的class
   3. 调用setInputFormatClass为TextInputFormat.class
   4. 设置MapperClass
   5. 设置输出键Output Key Class
   6. 设置输出值Output Value Class
   7. 设置输入输出到HDFS的路径，输入路径/bank/input，输出路径/bank/output
      1. FileInputFormat.setInputPaths
      2. FileOutputFormat.setOutputPath
   8. 使用connection.getRegionLocator获取HBase Region的分布情况
   9. 使用HFileOutputFormat2.configureIncrementalLoad配置HFile输出
5. 调用job.waitForCompletion执行MapReduce程序

```
public class BulkloadDriver {
    public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException {
        // 加载配置文件
        Configuration configuration = HBaseConfiguration.create();

        // 配置JOB
        Job instance = Job.getInstance(configuration);
        instance.setJarByClass(BulkloadDriver.class);
        instance.setMapperClass(BankRecordMapper.class);

        // 配置输入
        instance.setInputFormatClass(TextInputFormat.class);
        FileInputFormat.setInputPaths(instance, new Path("hdfs://node1.itcast.cn:8020/bank/input"));

        // 配置输出
        FileOutputFormat.setOutputPath(instance, new Path("hdfs://node1.itcast.cn:8020/bank/output"));
        instance.setOutputKeyClass(ImmutableBytesWritable.class);
        instance.setOutputValueClass(MapReduceExtendedCell.class);

        // 配置HFileoutputFormat2
        Connection connection = ConnectionFactory.createConnection(configuration);
        Table table = connection.getTable(TableName.valueOf("ITCAST_BANK:TRANSFER_RECORD"));
        // 获取表的Region检索对象
        RegionLocator regionLocator = connection.getRegionLocator(TableName.valueOf("ITCAST_BANK:TRANSFER_RECORD"));
        HFileOutputFormat2.configureIncrementalLoad(instance, table, regionLocator);

        // 执行job
        if (instance.waitForCompletion(true)) {
            System.out.println("任务执行成功！");
        }
        else {
            System.out.println("任务执行失败！");
            System.exit(1);
        }
    }
}
```

#### 上传数据到文件到HDFS

将资料中的数据集 bank_record.csv 上传到HDFS的 /bank/input 目录。该文件中包含50W条的转账记录数据。

```
hadoop fs -mkdir -p /bank/input
hadoop fs -put bank_record.csv /bank/input
```

然后，执行MapReduce程序。

#### 加载数据文件到HBase

```
hbase org.apache.hadoop.hbase.tool.LoadIncrementalHFiles /bank/output ITCAST_BANK:TRANSFER_RECORD
```

#### MapReduce程序排错

编写MapReduce程序排错，有些是比较难找到问题的：

```
Exception in thread "main" java.lang.RuntimeException: java.lang.InstantiationException
	at org.apache.hadoop.util.ReflectionUtils.newInstance(ReflectionUtils.java:134)
	at org.apache.hadoop.mapreduce.JobSubmitter.writeNewSplits(JobSubmitter.java:299)
	at org.apache.hadoop.mapreduce.JobSubmitter.writeSplits(JobSubmitter.java:318)
	at org.apache.hadoop.mapreduce.JobSubmitter.submitJobInternal(JobSubmitter.java:196)
	at org.apache.hadoop.mapreduce.Job$10.run(Job.java:1290)
	at org.apache.hadoop.mapreduce.Job$10.run(Job.java:1287)
	at java.security.AccessController.doPrivileged(Native Method)
	at javax.security.auth.Subject.doAs(Subject.java:422)
	at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1754)
	at org.apache.hadoop.mapreduce.Job.submit(Job.java:1287)
	at org.apache.hadoop.mapreduce.Job.waitForCompletion(Job.java:1308)
	at cn.itcast.bank_record.bulkload.mr1.BulkloadDriver.main(BulkloadDriver.java:53)
Caused by: java.lang.InstantiationException
	at sun.reflect.InstantiationExceptionConstructorAccessorImpl.newInstance(InstantiationExceptionConstructorAccessorImpl.java:48)
	at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
	at org.apache.hadoop.util.ReflectionUtils.newInstance(ReflectionUtils.java:132)
	... 11 more
```

上述问题，大家通过异常能找到问题吗？

1.见过该错误的同学，可能能看出来，但如果将来有一些问题，我们压根没见过，我们就可以尝试关联源代码来去找问题。
上述例子，我们通过关联Hadoop的源代码，就可以看出来是在：299行，在通过反射创建InputFormatClass对象时执行失败，我们看到这个就得去检查InputFormatClass的设置了。

![image.png](https://image.hyly.net/i/2025/09/28/46a66d88dd0159af0e64aa2555f3f8da-0.webp)

## HBase的协处理器（Coprocessor）

http://hbase.apache.org/book.html#cp

### 起源

1. Hbase 作为列族数据库最经常被人诟病的特性包括：
   1. 无法轻易建立“二级索引”
   2. 难以执 行求和、计数、排序等操作
      比如，在旧版本的(&#x3c;0.92)Hbase 中，统计数据表的总行数，需要使用 Counter 方法，执行一次 MapReduce Job 才能得到。虽然 HBase 在数据存储层中集成了 MapReduce，能够有效用于数据表的分布式计算。然而在很多情况下，做一些简单的相加或者聚合计算的时候， 如果直接将计算过程放置在 server 端，能够减少通讯开销，从而获 得很好的性能提升
2. 于是， HBase 在 0.92 之后引入了协处理器(coprocessors)，实现一些激动人心的新特性：能够轻易建立二次索引、复杂过滤器(谓词下推)以及访问控制等。

### 协处理器有两种： observer 和 endpoint

#### observer协处理器

1. Observer 类似于传统数据库中的触发器，当发生某些事件的时候这类协处理器会被 Server 端调用。Observer Coprocessor 就是一些散布在 HBase Server 端代码中的 hook 钩子， 在固定的事件发生时被调用。比如： put 操作之前有钩子函数 prePut，该函数在 put 操作
2. 执行前会被 Region Server 调用；在 put 操作之后则有 postPut 钩子函数
   1. 以 Hbase2.0.0 版本为例，它提供了三种观察者接口：
      1. RegionObserver：提供客户端的数据操纵事件钩子： Get、 Put、 Delete、 Scan 等
      2. WALObserver：提供 WAL 相关操作钩子。
      3. MasterObserver：提供 DDL-类型的操作钩子。如创建、删除、修改数据表等。
      4. 到 0.96 版本又新增一个 RegionServerObserver

下图是以 RegionObserver 为例子讲解 Observer 这种协处理器的原理：

![image.png](https://image.hyly.net/i/2025/09/28/94f1afab76832a0e3a3223b97efc6198-0.webp)

1.客户端发起get请求
2.该请求被分派给合适的RegionServer和Region
3.coprocessorHost拦截该请求，然后在该表上登记的每个RegionObserer上调用preGet()
4.如果没有被preGet拦截，该请求继续送到Region，然后进行处理
5.Region产生的结果再次被coprocessorHost拦截，调用posGet()处理
6.加入没有postGet()拦截该响应，最终结果被返回给客户端

#### endpoint协处理器

1. Endpoint 协处理器类似传统数据库中的存储过程，客户端可以调用这些 Endpoint 协处理器执行一段 Server 端代码，并将 Server 端代码的结果返回给客户端进一步处理，最常见的用法就是进行聚集操作
2. 如果没有协处理器，当用户需要找出一张表中的最大数据，即max 聚合操作，就必须进行全表扫描，在客户端代码内遍历扫描结果，并执行求最大值的操作。这样的方法无法利用底层集群的并发能力，而将所有计算都集中到 Client 端统一执 行，势必效率低下。
3. 利用 Coprocessor，用户可以将求最大值的代码部署到 HBase Server 端，HBase 将利用底层 cluster 的多个节点并发执行求最大值的操作。即在每个 Region 范围内 执行求最大值的代码，将每个 Region 的最大值在 Region Server 端计算出，仅仅将该 max 值返回给客户端。在客户端进一步将多个 Region 的最大值进一步处理而找到其中的最大值。这样整体的执行效率就会提高很多

下图是 EndPoint 的工作原理：

![image.png](https://image.hyly.net/i/2025/09/28/f429010904410a0738813acc8125be73-0.webp)

#### 总结

1. Observer 允许集群在正常的客户端操作过程中可以有不同的行为表现
2. Endpoint 允许扩展集群的能力，对客户端应用开放新的运算命令
3. observer 类似于 RDBMS 中的触发器，主要在服务端工作
4. endpoint 类似于 RDBMS 中的存储过程，主要在 服务器端、client 端工作
5. observer 可以实现权限管理、优先级设置、监控、 ddl 控制、 二级索引等功能
6. endpoint 可以实现 min、 max、 avg、 sum、 distinct、 group by 等功能

### 协处理器加载方式

协处理器的加载方式有两种：

1. 静态加载方式（ Static Load）
2. 动态加载方式 （ Dynamic Load）
   静态加载的协处理器称之为 System Coprocessor，动态加载的协处理器称 之为 Table Coprocessor。

#### 静态加载

1. 通过修改 hbase-site.xml 这个文件来实现
2. 启动全局 aggregation，能过操纵所有的表上的数据。只需要添加如下代码：

```
<property>
<name>hbase.coprocessor.user.region.classes</name>
<value>org.apache.hadoop.hbase.coprocessor.AggregateImplementation</value>
</property>
```

为所有 table 加载了一个 cp class，可以用” ,”分割加载多个 class

#### 动态加载

启用表 aggregation，只对特定的表生效
通过 HBase Shell 来实现，disable 指定表

```
hbase> disable 'mytable'
```

添加 aggregation

```
hbase> alter 'mytable', METHOD => 'table_att','coprocessor'=>
'|org.apache.Hadoop.hbase.coprocessor.AggregateImplementation||'
```

重启启用表

```
hbase> enable 'mytable'
```

#### 协处理器卸载

只需三步：

```
disable ‘test’
alter ‘test’, METHOD => ‘table_att_unset’, NAME => ‘coprocessor$1’
enable ‘test’
```

## HBase事务

HBase 支持特定场景下的 ACID，即当对同一行进行 Put 操作时保证完全的 ACID。可以简单理解为针对一行的操作，是有事务性保障的。HBase也没有混合读写事务。也就是说，我们无法将读操作、写操作放入到一个事务中。

## HBase数据结构

在讲解HBase的LSM合并树之前，我们需要来了解一些常用的数据结构知识。

### 跳表

![image.png](https://image.hyly.net/i/2025/09/28/7f31c1c6d34b98a210f541a9874d4cee-0.webp)

上图是一个有序链表，我们要检索一个数据就挨个遍历。如果想要再提升查询效率，可以变种为以下结构：

![image.png](https://image.hyly.net/i/2025/09/28/40834c6930c64bc301bc94502bb69e10-0.webp)

现在，我们要查询11，可以跳着来查询，从而加快查询速度。

### 常见树结构（扩展了解）

#### 二叉搜索树（Binary Search Tree）

##### 什么是二叉搜索树？

二叉搜索树也叫二叉查找树。它是一种比较特殊的二叉树。

![image.png](https://image.hyly.net/i/2025/09/28/4131b44071902440d64bbf38c43affb0-0.webp)

##### 树的高度、深度、层数

**深度**
节点的深度是根节点到这个节点所经历的边的个数，深度是从上往下数的
**高度**
节点的高度是该节点到叶子节点的最长路径（边数），高度是从下往上数的
**层数**
根节点为第一层，往下依次递增

上图：
节点12的深度为0，高度为4，在第1层
节点15的深度为2，高度为2，在第3层

##### 二叉搜索树的特点

树中的每个节点，它的左子树中所有关键字值小于该节点关键字值，右子树中所有关键字值大于该节点关键字值

##### 二叉搜索树的查询方式

首先和根节点进行比较，如果等于根节点，则返回
如果小于根节点，则在根节点的左子树进行查找
如果大于根节点，则在根节点的右子树进行查找

##### 二叉搜索树的缺点

因为二叉搜索树是一种二叉树，每个节点只能有两个子节点，但有较多节点时，整棵树的高度会比较大，树的高度越大，搜索的性能开销也就越大

#### 平衡二叉树（Balance Binary Tree）

##### 简介

平衡二叉树也称为AVL数
它是一颗空数，或者它的任意节点左右两个子树的高度差绝对值**不超过1**
平衡二叉树很好地解决了二叉查找树退化成链表的问题

![image.png](https://image.hyly.net/i/2025/09/28/fd87c5af56da9a4a776150438d19d590-0.webp)

上图：
1.两棵树都是二叉查找树
2.左边的不是平衡二叉树
节点6的子节点：节点2的高度为：2，节点7的高度为：0，| 2 – 0 | = 2 > 1）
3.右边的是平衡二叉树
节点6的子节点：节点3的高度为：1，节点7的高度为：0，| 1 – 0 | = 1 = 1 ）

##### 平衡二叉树的特点

AVL树是高度平衡的（严格平衡），频繁的插入和删除，会引起频繁的rebalance，导致效率下降，它比较使用与插入/删除较少，查找较多的场景

#### 红黑树

##### 简介

红黑树是一种含有红黑节点并能自平衡的二叉搜索树，它满足以下性质：

1. 每个节点要么是黑色，要么是红色
2. 根节点是黑色
3. 每个叶子节点（NIL）是黑色
4. 每个红色结点的两个子结点一定都是黑色
5. 任意一结点到每个叶子结点的路径都包含数量相同的黑结点

![image.png](https://image.hyly.net/i/2025/09/28/42c2d038a4a2fe10e43466452e0507a9-0.webp)

##### 红黑树的特点

和AVL树不一样，红黑树是一种弱平衡的二叉树，它的插入/删除效率更高，所以对于插入、删除较多的情况下，就用红黑树，而且查找效率也不低。例如：Java中的TreeMap就是基于红黑树实现的。

#### B树

##### 什么是B树

1. B树是一种平衡多路搜索树
2. 与二叉搜索树不同的是，B树的节点可以有多个子节点，不限于最多两个节点
3. 它的子节点可以是几个或者是几千个

![image.png](https://image.hyly.net/i/2025/09/28/4fafc5a99664733e2a04d08836784b89-0.webp)

##### B树的特点

1. 所有节点关键字是按递增次序排列，并遵循左小右大原则
2. B-树有个最大的特点是有多个查找路径，而不像二叉搜索树，只有两路查找路径。
3. 所有的叶子节点在同一层
4. **逐层查找，找到节点后返回**

##### B-树的查找方式

1. 从根节点的关键字开始比较，例如：上图为13，判断大于还是小于
2. 继续往下查找，因为节点可能会有多个节点，所以需要判断属于哪个区间
3. 不断往下查找，直到找到为止或者没有找到返回Null

#### B+树结构

##### B+树简介

B+树是B树的升级版。B+树常用在文件系统和数据库中，B+树通过对每个节点存储数据的个数进行扩展，可以让连续的数据进行快速访问，有效减少查询时间，减少IO操作。它能够保持数据稳定有序，其插入与修改拥有较稳定的对数时间复杂度
例如：Linux的Ext3文件系统、Oracle、MySQL、SQLServer都会使用到B+树。

![image.png](https://image.hyly.net/i/2025/09/28/5a6fe66d57ed4319841267f9776265ef-0.webp)

1. B+ 树是一种树数据结构，是一个n叉树
2. 每个节点通常有多个孩子
3. 一颗B+树包含根节点、内部节点和叶子节点
4. **只有叶子节点包含数据（所有数据都是在叶子节点中出现）**

##### B+树的特点

1. 所有关键字都出现在叶子结点的链表中（稠密索引），且链表中的关键字恰好是有序的
   如果执行的是：select * from user order by id，要全表扫描数据，那么B树就比较费劲了，但B+树就容易了，只要遍历最后的链表就可以了。
2. 只会在叶子节点上搜索到数据
3. 非叶子结点相当于是叶子结点的索引（稀疏索引），叶子结点相当于是存储
4. 数据库的B+树高度大概在 2-4 层，也就是说查询到某个数据最多需要2到4次IO，相当于0.02到0.04s

##### 稠密索引和稀疏索引

1. 稠密索引文件中的每个搜索码值都对应一个索引值
2. 稀疏索引文件只为索引码的某些值建立索引项

稠密索引：

![image.png](https://image.hyly.net/i/2025/09/28/41cb3c217117a0b4d9ec2a0299ed2f2c-0.webp)

稀疏索引：

![image.png](https://image.hyly.net/i/2025/09/28/42354b3317b580707c2a6f2422115ba9-0.webp)

### LSM树数据结构

#### 简介

传统关系型数据库，一般都选择使用B+树作为索引结构，而在大数据场景下，HBase、Kudu这些存储引擎选择的是LSM树。LSM树，即日志结构合并树(Log-Structured Merge-Tree)。

1. LSM树主要目标是快速建立索引
2. B+树是建立索引的通用技术，但如果并发写入压力较大时，B+树需要大量的磁盘随机IO，而严重影响索引创建的速度，在一些写入操作非常频繁的应用场景中，就不太适合了
3. LSM树通过磁盘的顺序写，来实现最好的写性能

#### LSM树设计思想

![image.png](https://image.hyly.net/i/2025/09/28/568a18ff75370ef4da105082727bd5d5-0.webp)

1. LSM	的主要思想是划分不同等级的结构，换句话来理解，就是LSM中不止一个数据结构，而是存在多种结构
2. 一个结构在内存、其他结构在磁盘（HBase存储结构中，有内存——MemStore、也有磁盘——StoreFile）
3. 内存的结构可以是B树、红黑树、跳表等结构（HBase中是跳表），磁盘中的树就是一颗B+树
4. C0层保存了最近写入的数据，数据都是有序的，而且可以随机更新、随机查询
5. C1到CK层的数据都是存在磁盘中，每一层中key都是有序存储的

#### LSM的数据写入操作

1. 首先将数据写入到WAL（Write Ahead log），写日志是顺序写，效率相对较高（PUT、DELETE都是顺序写）
2. 数据项写入到内存中的C0结构中
3. 只有内存中的C0结构超过一定阈值的时候，将内存中的C0、和C1进行合并。这个过程就是Compaction（合并）
4. 合并后的新的C1顺序写磁盘，替换之前的C1
5. 但C1层达到一定的大小，会继续和下层合并，合并后旧的文件都可以删除，只保留最新的
6. 整个写入的过程只用到了内存结构，Compaction由后台异步完成，不阻塞写入

#### LSM的数据查询操作

1. 先在内存中查C0层
2. 如果C0层中不存在数据，则查询C1层
3. 不断逐层查询，最早的数据在CK层
4. C0层因为是在内存中的结构中查询，所以效率较高。因为数据都是分布在不同的层结构中，所以一次查询，可能需要多次跨层次结构查询，所以读取的速度会慢一些。
5. 根据以上，LSM树结构的程序适合于写密集、少量查询的场景

### 布隆过滤器

#### 简介

客户端：这个key存在吗？
服务器：不存在/不知道

质上，布隆过滤器是一种数据结构，是一种比较巧妙的概率型数据结构。它的特点是高效地插入和查询。但我们要检查一个key是否在某个结构中存在时，通过使用布隆过滤器，我们可以快速了解到「这个key一定不存在或者可能存在」。相比于以前学习过的List、Set、Map这些数据结构，它更加高效、占用的空间也越少，但是它返回的结果是概率性的，是不确切的。

#### 应用场景

##### 缓存穿透

1. 为了提高访问效率，我们会将一些数据放在Redis缓存中。当进行数据查询时，可以先从缓存中获取数据，无需读取数据库。这样可以有效地提升性能。
2. 在数据查询时，首先要判断缓存中是否有数据，如果有数据，就直接从缓存中获取数据。
3. 但如果没有数据，就需要从数据库中获取数据，然后放入缓存。如果大量访问都无法命中缓存，会造成数据库要扛较大压力，从而导致数据库崩溃。而使用布隆过滤器，当访问不存在的缓存时，可以迅速返回避免缓存或者DB crash。

##### 判断某个数据是否在海量数据中存在

HBase中存储着非常海量数据，要判断某个ROWKEYS、或者某个列是否存在，使用布隆过滤器，可以快速获取某个数据是否存在。但有一定的误判率。但如果某个key不存在，一定是准确的。

#### HashMap的问题

1. 要判断某个元素是否存在其实用HashMap效率是非常高的。HashMap通过把值映射为HashMap的Key，这种方式可以实现O(1)常数级时间复杂度。
2. 但是，如果存储的数据量非常大的时候（例如：上亿的数据），HashMap将会耗费非常大的内存大小。而且也根本无法一次性将海量的数据读进内存。

#### 理解布隆过滤器

![image.png](https://image.hyly.net/i/2025/09/28/f43d838cb9f03c4be2aaf53b507abad6-0.webp)

1. 布隆过滤器是一个bit数组或者称为一个bit二进制向量
2. 这个数组中的元素存的要么是0、要么是1
3. k个hash函数都是彼此独立的，并将每个hash函数计算后的结果对数组的长度m取模，并将对一个的bit设置为1（蓝色单元格）
4. 我们将每个key都按照这种方式设置单元格，就是「布隆过滤器」

#### 根据布隆过滤器查询元素

1. 假设输入一个key，我们使用之前的k个hash函数求哈希，得到k个值
2. 判断这k个值是否都为蓝色，如果有一个不是蓝色，那么这个key一定不存在
3. 如果都有蓝色，那么key是可能存在（布隆过滤器会存在误判）
4. 因为如果输入对象很多，而集合比较小的情况，会导致集合中大多位置都会被描蓝，那么检查某个key时候为蓝色时，刚好某个位置正好被设置为蓝色了，此时，会错误认为该key在集合中

### StoreFiles（HFile）结构

StoreFile是HBase存储数据的文件格式。

#### HFile的逻辑结构

##### HFile逻辑结构图

![image.png](https://image.hyly.net/i/2025/09/28/b0e4d5ab569db3b9d7ea9f73b70a3132-0.webp)

##### 逻辑结构说明

4大部分

1. Scanned block section
   1. 扫描StoreFile时，所有的Data Block（数据块）都将会被读取
   2. Leaf Index（LSM + C1树索引）、Bloom block（布隆过滤器）都会被读取
2. Non-scanned block section
   1. 扫描StoreFile时，不会被读取
   2. 包含MetaBlock和Intermediate Level Data Index Blocks
3. Opening-time data section
   1. 在RegionServer启动时，需要将数据加载到内存中，包括数据块索引、元数据索引、布隆过滤器、文件信息。
4. Trailer
   1. 记录了HFile的基本信息
   2. 各个部分的偏移值和寻址信息

#### StoreFile物理结构

StoreFile是以Hfile的形式存储在HDFS上的。Hfile的格式为下图：

![image.png](https://image.hyly.net/i/2025/09/28/6b3f6921b9cf2d64edf46a18d0861efc-0.webp)

1. HFile文件是不定长的，长度固定的只有其中的两块：Trailer和FileInfo。正如图中所示的，Trailer中有指针指向其他数 据块的起始点。
2. File Info中记录了文件的一些Meta信息，例如：AVG_KEY_LEN, AVG_VALUE_LEN, LAST_KEY, COMPARATOR, MAX_SEQ_ID_KEY等
3. Data Index和Meta Index块记录了每个Data块和Meta块的起始点。
4. Data Block是HBase I/O的基本单元，为了提高效率，HRegionServer中有基于LRU的Block Cache机制。每个Data块的大小可以在创建一个Table的时候通过参数指定，大号的Block有利于顺序Scan，小号Block利于随机查询。 每个Data块除了开头的Magic以外就是一个个KeyValue对拼接而成, Magic内容就是一些随机数字，目的是防止数据损坏。
5. HFile里面的每个KeyValue对就是一个简单的byte数组。但是这个byte数组里面包含了很多项，并且有固定的结构。我们来看看里面的具体结构：

![image.png](https://image.hyly.net/i/2025/09/28/27272f23c5c6fe735febef55d7e9306c-0.webp)

1.开始是两个固定长度的数值，分别表示Key的长度和Value的长度
2.紧接着是Key，开始是固定长度的数值，表示RowKey的长度
3.紧接着是 RowKey，然后是固定长度的数值，表示Family的长度
4.然后是Family，接着是Qualifier
5.然后是两个固定长度的数值，表示Time Stamp和Key Type（Put/Delete）——每一种操作都会生成一个Key-Value。Value部分没有这么复杂的结构，就是纯粹的二进制数据了。

![image.png](https://image.hyly.net/i/2025/09/28/b94244906d4bbfc959b60854e0ca4821-0.webp)

1. Data Block段
   保存表中的数据，这部分可以被压缩
2. Meta Block段 (可选的)
   保存用户自定义的kv对，可以被压缩。
3. File Info段
   Hfile的元信息，不被压缩，用户也可以在这一部分添加自己的元信息。
4. Data Block Index段
   Data Block的索引。每条索引的key是被索引的block的第一条记录的key。
5. Meta Block Index段 (可选的)
   Meta Block的索引。
6. Trailer
   这一段是定长的。保存了每一段的偏移量，读取一个HFile时，会首先 读取Trailer，Trailer保存了每个段的起始位置(段的Magic Number用来做安全check)，然后，DataBlock Index会被读取到内存中，这样，当检索某个key时，不需要扫描整个HFile，而只需从内存中找到key所在的block，通过一次磁盘io将整个 block读取到内存中，再找到需要的key。DataBlock Index采用LRU机制淘汰

## HBase调优

### 通用优化

#### NameNode的元数据备份使用SSD

![image.png](https://image.hyly.net/i/2025/09/28/71e03d90123ff14974b5f5657d7dbef5-0.webp)

#### 定时备份NameNode上的元数据

每小时或者每天备份，如果数据极其重要，可以5~10分钟备份一次。备份可以通过定时任务复制元数据目录即可。

#### 为NameNode指定多个元数据目录

1. 使用dfs.name.dir或者dfs.namenode.name.dir指定。一个指定本地磁盘，一个指定网络磁盘。这样可以提供元数据的冗余和健壮性，以免发生故障。
2. 设置dfs.namenode.name.dir.restore为true，允许尝试恢复之前失败的dfs.namenode.name.dir目录，在创建checkpoint时做此尝试，如果设置了多个磁盘，建议允许。

#### NameNode节点配置为RAID1（镜像盘）结构

![image.png](https://image.hyly.net/i/2025/09/28/2b81ea44096e6fc21c6b740ee026f04e-0.webp)

#### 补充：什么是Raid0、Raid0+1、Raid1、Raid5

![image.png](https://image.hyly.net/i/2025/09/28/a47f33dcd243b16820363f75a4127058-0.webp)

Standalone
最普遍的单磁盘储存方式。

Cluster
集群储存是通过将数据分布到集群中各节点的存储方式,提供单一的使用接口与界面,使用户可以方便地对所有数据进行统一使用与管理。

Hot swap
用户可以再不关闭系统,不切断电源的情况下取出和更换硬盘,提高系统的恢复能力、拓展性和灵活性。

Raid0
Raid0是所有raid中存储性能最强的阵列形式。其工作原理就是在多个磁盘上分散存取连续的数据,这样,当需要存取数据是多个磁盘可以并排执行,每个磁盘执行属于它自己的那部分数据请求,显著提高磁盘整体存取性能。但是不具备容错能力,适用于低成本、低可靠性的台式系统。

Raid1
又称镜像盘,把一个磁盘的数据镜像到另一个磁盘上,采用镜像容错来提高可靠性,具有raid中最高的数据冗余能力。存数据时会将数据同时写入镜像盘内,读取数据则只从工作盘读出。发生故障时,系统将从镜像盘读取数据,然后再恢复工作盘正确数据。这种阵列方式可靠性极高,但是其容量会减去一半。广泛用于数据要求极严的应用场合,如商业金融、档案管理等领域。只允许一颗硬盘出故障。

Raid0+1
将Raid0和Raid1技术结合在一起,兼顾两者的优势。在数据得到保障的同时,还能提供较强的存储性能。不过至少要求4个或以上的硬盘，但也只允许一个磁盘出错。是一种三高技术。

Raid5
Raid5可以看成是Raid0+1的低成本方案。采用循环偶校验独立存取的阵列方式。将数据和相对应的奇偶校验信息分布存储到组成RAID5的各个磁盘上。当其中一个磁盘数据发生损坏后,利用剩下的磁盘和相应的奇偶校验信息 重新恢复/生成丢失的数据而不影响数据的可用性。至少需要3个或以上的硬盘。适用于大数据量的操作。成本稍高、储存性强、可靠性强的阵列方式。
RAID还有其他方式，请自行查阅。

#### 保持NameNode日志目录有足够的空间，有助于帮助发现问题

#### Hadoop是IO密集型框架，所以尽量提升存储的速度和吞吐量

### Linux优化

#### 开启文件系统的预读缓存可以提高读取速度

$ sudo blockdev --setra 32768 /dev/sda
（尖叫提示：ra是readahead的缩写）

#### 最大限度使用物理内存

$ sudo sysctl -w vm.swappiness=0

1. swappiness，Linux内核参数，控制换出运行时内存的相对权重
2. swappiness参数值可设置范围在0到100之间，低参数值会让内核尽量少用交换，更高参数值会使内核更多的去使用交换空间
3. 默认值为60（当剩余物理内存低于40%（40=100-60）时，开始使用交换空间）
4. 对于大多数操作系统，设置为100可能会影响整体性能，而设置为更低值（甚至为0）则可能减少响应延迟

#### 调整ulimit上限，默认值为比较小的数字

$ ulimit -n 查看允许最大进程数
$ ulimit -u 查看允许打开最大文件数

修改：

```
$ sudo vi /etc/security/limits.conf 修改打开文件数限制
末尾添加：
*                soft    nofile          1024000
*                hard    nofile          1024000
Hive             -       nofile          1024000
hive             -       nproc           1024000 
$ sudo vi /etc/security/limits.d/20-nproc.conf 修改用户打开进程数限制
修改为：
#*          soft    nproc     4096
#root       soft    nproc     unlimited
*          soft    nproc     40960
root       soft    nproc     unlimited
```

#### 开启集群的时间同步NTP

#### 更新系统补丁

更新补丁前，请先测试新版本补丁对集群节点的兼容性

### HDFS优化（hdfs-site.xml）

#### 保证RPC调用会有较多的线程数

属性：dfs.namenode.handler.count
解释：该属性是NameNode服务默认线程数，的默认值是10，根据机器的可用内存可以调整为50~100

属性：dfs.datanode.handler.count
解释：该属性默认值为10，是DataNode的处理线程数，如果HDFS客户端程序读写请求比较多，可以调高到1520，设置的值越大，内存消耗越多，不要调整的过高，一般业务中，510即可。

#### 副本数的调整

属性：dfs.replication
解释：如果数据量巨大，且不是非常之重要，可以调整为2~3，如果数据非常之重要，可以调整为3~5。

#### 文件块大小的调整

属性：dfs.blocksize
解释：块大小定义，该属性应该根据存储的大量的单个文件大小来设置，如果大量的单个文件都小于100M，建议设置成64M块大小，对于大于100M或者达到GB的这种情况，建议设置成256M，一般设置范围波动在64M~256M之间。

### HBase优化

#### 优化DataNode允许的最大文件打开数

属性：dfs.datanode.max.transfer.threads
文件：hdfs-site.xml
解释：HBase一般都会同一时间操作大量的文件，根据集群的数量和规模以及数据动作，设置为4096或者更高。默认值：4096

#### 优化延迟高的数据操作的等待时间

属性：dfs.image.transfer.timeout
文件：hdfs-site.xml
解释：如果对于某一次数据操作来讲，延迟非常高，socket需要等待更长的时间，建议把该值设置为更大的值（默认60000毫秒），以确保socket不会被timeout掉。

#### 优化数据的写入效率

属性：
mapreduce.map.output.compress
mapreduce.map.output.compress.codec
文件：mapred-site.xml
解释：开启这两个数据可以大大提高文件的写入效率，减少写入时间。第一个属性值修改为true，第二个属性值修改为：org.apache.hadoop.io.compress.GzipCodec

#### 优化DataNode存储

属性：dfs.datanode.failed.volumes.tolerated
文件：hdfs-site.xml
解释：默认为0，意思是当DataNode中有一个磁盘出现故障，则会认为该DataNode shutdown了。如果修改为1，则一个磁盘出现故障时，数据会被复制到其他正常的DataNode上。

#### 设置RPC监听数量

属性：hbase.regionserver.handler.count
文件：hbase-site.xml
解释：默认值为30，用于指定RPC监听的数量，可以根据客户端的请求数进行调整，读写请求较多时，增加此值。

#### 优化HStore文件大小

属性：hbase.hregion.max.filesize
文件：hbase-site.xml
解释：默认值10737418240（10GB），如果需要运行HBase的MR任务，可以减小此值，因为一个region对应一个map任务，如果单个region过大，会导致map任务执行时间过长。该值的意思就是，如果HFile的大小达到这个数值，则这个region会被切分为两个Hfile。

#### 优化hbase客户端缓存

属性：hbase.client.write.buffer
文件：hbase-site.xml
解释：用于指定HBase客户端缓存，增大该值可以减少RPC调用次数，但是会消耗更多内存，反之则反之。一般我们需要设定一定的缓存大小，以达到减少RPC次数的目的。

#### 指定scan.next扫描HBase所获取的行数

属性：hbase.client.scanner.caching
文件：hbase-site.xml
解释：用于指定scan.next方法获取的默认行数，值越大，消耗内存越大。

### 内存优化

HBase操作过程中需要大量的内存开销，毕竟Table是可以缓存在内存中的，一般会分配整个可用内存的70%给HBase的Java堆。但是不建议分配非常大的堆内存，因为GC过程持续太久会导致RegionServer处于长期不可用状态，一般16~48G内存就可以了，如果因为框架占用内存过高导致系统内存不足，框架一样会被系统服务拖死。

#### JVM优化

涉及文件：hbase-env.sh

#### 并行GC

参数：-XX:+UseParallelGC
解释：开启并行GC

#### 同时处理垃圾回收的线程数

参数：-XX:ParallelGCThreads=cpu_core – 1
解释：该属性设置了同时处理垃圾回收的线程数。

#### 禁用手动GC

参数：-XX:DisableExplicitGC
解释：防止开发人员手动调用GC

### Zookeeper优化

#### 优化Zookeeper会话超时时间

参数：zookeeper.session.timeout
文件：hbase-site.xml
解释：In hbase-site.xml, set zookeeper.session.timeout to 30 seconds or less to bound failure detection (20-30 seconds is a good start).该值会直接关系到master发现服务器宕机的最大周期，默认值为30秒，如果该值过小，会在HBase在写入大量数据发生而GC时，导致RegionServer短暂的不可用，从而没有向ZK发送心跳包，最终导致认为从节点shutdown。一般20台左右的集群需要配置5台zookeeper。

## 常见问题处理

### Could not locate Hadoop executable: xxxx\bin\winutils.exe

1.配置以下环境变量
HADOOP_HOME=&#x3c;your local hadoop-ver folder>

![image.png](https://image.hyly.net/i/2025/09/28/1524ff27060e1fc4214def230afdf1dd-0.webp)

在PATH环境变量中添加：%HADOOP_HOME%\bin

2.将资料中的winutils-master\hadoop-3.2.1\bin中的所有内容复制到HADOOP_HOME\bin目录中

![image.png](https://image.hyly.net/i/2025/09/28/7f33027190f17b311f4b3c47ebe10067-0.webp)

3.重启IDEA，重新运行MapReduce程序

参考：https://github.com/cdarlint/winutils