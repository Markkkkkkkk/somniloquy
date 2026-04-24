---
category: [Java技术栈]
tag: [kafka,零基础,入门到实战]
postType: post
status: publish
---

## 消息队列简介

### 为什么叫Kafka

Kafka的架构师jay kreps非常喜欢franz kafka（弗兰兹·卡夫卡）,并且觉得kafka这个名字很酷，因此取了个和消息传递系统完全不相干的名称kafka，该名字并没有特别的含义。

「也就是说，你特别喜欢尼古拉斯赵四，将来你做一个项目，也可以把项目的名字取名为：尼古拉斯赵四，然后这个项目就火了」

### 消息队列的应用场景

#### 异步处理

电商网站中，新的用户注册时，需要将用户的信息保存到数据库中，同时还需要额外发送注册的邮件通知、以及短信注册码给用户。但因为发送邮件、发送注册短信需要连接外部的服务器，需要额外等待一段时间，此时，就可以使用消息队列来进行异步处理，从而实现快速响应。

![img](https://image.hyly.net/i/2025/09/24/9f88eee223f3ab0fbab5991007a0d4ba-0.webp)

#### 系统解耦

![img](https://image.hyly.net/i/2025/09/24/dfdf326af952c61e318d2f6684b570a3-0.webp)

#### 流量削峰

![img](https://image.hyly.net/i/2025/09/24/f74febe1263658fa60543561f1e06119-0.webp)

#### 日志处理（大数据领域常见）

大型电商网站（淘宝、京东、国美、苏宁...）、App（抖音、美团、滴滴等）等需要分析用户行为，要根据用户的访问行为来发现用户的喜好以及活跃情况，需要在页面上收集大量的用户访问信息。

![img](https://image.hyly.net/i/2025/09/24/6fe23d8584e1ebf9daaf5ba5c6c61594-0.webp)

### 生产者、消费者模型

我们之前学习过Java的服务器开发，Java服务器端开发的交互模型是这样的：

![img](https://image.hyly.net/i/2025/09/24/015e6c448791e13db743549d9c21eab5-0.webp)

我们之前也学习过使用Java JDBC来访问操作MySQL数据库，它的交互模型是这样的：

![img](https://image.hyly.net/i/2025/09/24/a50bc1818a260726f98c9fa4346253cf-0.webp)

它也是一种请求响应模型，只不过它不再是基于http协议，而是基于MySQL数据库的通信协议。

而如果我们基于消息队列来编程，此时的交互模式成为：生产者、消费者模型。

![img](https://image.hyly.net/i/2025/09/24/48a98d7a91b17b4330c784274f047afb-0.webp)

### 消息队列的两种模式

#### 点对点模式

![img](https://image.hyly.net/i/2025/09/24/6346d6123543ec0169f54ffd76ae384d-0.webp)

消息发送者生产消息发送到消息队列中，然后消息接收者从消息队列中取出并且消费消息。消息被消费以后，消息队列中不再有存储，所以消息接收者不可能消费到已经被消费的消息。

**点对点模式特点：**

1. 每个消息只有一个接收者（Consumer）(即一旦被消费，消息就不再在消息队列中)。
2. 发送者和接收者间没有依赖性，发送者发送消息之后，不管有没有接收者在运行，都不会影响到发送者下次发送消息；
3. 接收者在成功接收消息之后需向队列应答成功，以便消息队列删除当前接收的消息；

#### 发布订阅模式

![img](https://image.hyly.net/i/2025/09/24/23c8ec355d9fb7bf79a882116de23549-0.webp)

**发布/订阅模式特点：**

1. 每个消息可以有多个订阅者；
2. 发布者和订阅者之间有时间上的依赖性。针对某个主题（Topic）的订阅者，它必须创建一个订阅者之后，才能消费发布者的消息；
3. 为了消费消息，订阅者需要提前订阅该角色主题，并保持在线运行；

## Kafka简介

### 什么是Kafka

![img](https://image.hyly.net/i/2025/09/24/7db36f6ef2a1f3e8931325a9a4c78b47-0.webp)

Kafka是由Apache软件基金会开发的一个开源流平台，由Scala和Java编写。Kafka的Apache官网是这样介绍Kakfa的。

> Apache Kafka是一个分布式流平台。一个分布式的流平台应该包含3点关键的能力：
> 发布和订阅流数据流，类似于消息队列或者是企业消息传递系统
> 以容错的持久化方式存储数据流
> 处理数据流

英文原版

> **Publish and subscribe** to streams of records, similar to a message queue or enterprise messaging system.
> **Store** streams of records in a fault-tolerant durable way.
> **Process** streams of records as they occur.

更多参考：[http://kafka.apache.org/documentation/#introduction](#introduction)

### Kafka应用场景

我们通常将Apache Kafka用在两类程序：

1. 建立实时数据管道，以可靠地在系统或应用程序之间获取数据
2. 构建实时流应用程序，以转换或响应数据流

![img](https://image.hyly.net/i/2025/09/24/f7e2ac300030c3dd53e12a67ffbf67d3-0.webp)

上图，我们可以看到：

1. Producers：可以有很多的应用程序，将消息数据放入到Kafka集群中。
2. Consumers：可以有很多的应用程序，将消息数据从Kafka集群中拉取出来。
3. Connectors：Kafka的连接器可以将数据库中的数据导入到Kafka，也可以将Kafka的数据导出到

数据库中。

1. Stream Processors：流处理器可以Kafka中拉取数据，也可以将数据写入到Kafka中。

### Kafka在大数据中的应用场景

![img](https://image.hyly.net/i/2025/09/24/88421f26cf8e064be5e52fe653ad3fa3-0.webp)

### Kafka诞生背景

kafka的诞生，是为了解决linkedin的数据管道问题，起初linkedin采用了ActiveMQ来进行数据交换，大约是在2010年前后，那时的ActiveMQ还远远无法满足linkedin对数据传递系统的要求，经常由于各种缺陷而导致消息阻塞或者服务无法正常访问，为了能够解决这个问题，linkedin决定研发自己的消息传递系统，当时linkedin的首席架构师jay kreps便开始组织团队进行消息传递系统的研发。

> Linkedin还是挺牛逼的
> Kafka比ActiveMQ牛逼得多

### Kafka的优势

前面我们了解到，消息队列中间件有很多，为什么我们要选择Kafka？

| **特性**          | **ActiveMQ** | **RabbitMQ**           | **Kafka**            | **RocketMQ**   |
| ----------------- | ------------ | ---------------------- | -------------------- | -------------- |
| 所属社区/公司     | Apache       | Mozilla Public License | Apache               | Apache/Ali     |
| 成熟度            | 成熟         | 成熟                   | 成熟                 | 比较成熟       |
| 生产者-消费者模式 | 支持         | 支持                   | 支持                 | 支持           |
| 发布-订阅         | 支持         | 支持                   | 支持                 | 支持           |
| REQUEST-REPLY     | 支持         | 支持                   | -                    | 支持           |
| API完备性         | 高           | 高                     | 高                   | 低（静态配置） |
| 多语言支持        | 支持JAVA优先 | 语言无关               | 支持，JAVA优先       | 支持           |
| 单机呑吐量        | 万级（最差） | 万级                   | **十万级**           | 十万级（最高） |
| 消息延迟          | -            | 微秒级                 | **毫秒级**           | -              |
| 可用性            | 高（主从）   | 高（主从）             | **非常高（分布式）** | 高             |
| 消息丢失          | -            | 低                     | **理论上不会丢失**   | -              |
| 消息重复          | -            | 可控制                 | 理论上会有重复       | -              |
| 事务              | 支持         | 不支持                 | 支持                 | 支持           |
| 文档的完备性      | 高           | 高                     | 高                   | 中             |
| 提供快速入门      | 有           | 有                     | 有                   | 无             |
| 首次部署难度      | -            | 低                     | 中                   | 高             |

在大数据技术领域，一些重要的组件、框架都支持Apache Kafka，不论成成熟度、社区、性能、可靠性，Kafka都是非常有竞争力的一款产品。

### Kafka生态圈介绍

Apache Kafka这么多年的发展，目前也有一个较庞大的生态圈。

Kafka生态圈官网地址：https://cwiki.apache.org/confluence/display/KAFKA/Ecosystem

![img](https://image.hyly.net/i/2025/09/24/d17cf6d0154024c1bd19d9ac6ae4e990-0.webp)

## Kafka环境搭建

### 搭建Kafka集群

1、将Kafka的安装包上传到虚拟机，并解压

```
cd /export/software/
tar -xvzf kafka_2.12-2.4.1.tgz -C ../server/
cd /export/server/kafka_2.12-2.4.1/
```

2、修改 server.properties

```
cd /export/server/kafka_2.12-2.4.1/config
vim server.properties
## 指定broker的id
broker.id=0
## 指定Kafka数据的位置
log.dirs=/export/server/kafka_2.12-2.4.1/data
## 配置zk的三个节点
zookeeper.connect=node1.itcast.cn:2181,node2.itcast.cn:2181,node3.itcast.cn:2181
```

3、将安装好的kafka复制到另外两台服务器

```
cd /export/server
scp -r kafka_2.12-2.4.1/ node2.itcast.cn:$PWD
scp -r kafka_2.12-2.4.1/ node3.itcast.cn:$PWD

修改另外两个节点的broker.id分别为1和2
---------node2.itcast.cn--------------
cd /export/server/kafka_2.12-2.4.1/config
vim erver.properties
broker.id=1
--------node3.itcast.cn--------------
cd /export/server/kafka_2.12-2.4.1/config
vim server.properties
broker.id=2
```

4、配置KAFKA_HOME环境变量

```
vim /etc/profile
export KAFKA_HOME=/export/server/kafka_2.12-2.4.1
export PATH=:$PATH:${KAFKA_HOME}

分发到各个节点
scp /etc/profile node2.itcast.cn:$PWD
scp /etc/profile node3.itcast.cn:$PWD
每个节点加载环境变量
source /etc/profile
```

5、启动服务器

```
## 启动ZooKeeper
nohup bin/zookeeper-server-start.sh config/zookeeper.properties &
## 启动Kafka
cd /export/server/kafka_2.12-2.4.1
nohup bin/kafka-server-start.sh config/server.properties &
## 测试Kafka集群是否启动成功
bin/kafka-topics.sh --bootstrap-server node1.itcast.cn:9092 --list
```

### 目录结构分析

| **目录名称** | **说明**                                                     |
| ------------ | ------------------------------------------------------------ |
| bin          | Kafka的所有执行脚本都在这里。例如：启动Kafka服务器、创建Topic、生产者、消费者程序等等 |
| config       | Kafka的所有配置文件                                          |
| libs         | 运行Kafka所需要的所有JAR包                                   |
| logs         | Kafka的所有日志文件，如果Kafka出现一些问题，需要到该目录中去查看异常信息 |
| site-docs    | Kafka的网站帮助文件                                          |

### Kafka一键启动/关闭脚本

为了方便将来进行一键启动、关闭Kafka，我们可以编写一个shell脚本来操作。将来只要执行一次该脚本就可以快速启动/关闭Kafka。

1、在节点1中创建 /export/onekey 目录。

```
cd /export/onekey
```

2、准备slave配置文件，用于保存要启动哪几个节点上的kafka

```
node1.itcast.cn
node2.itcast.cn
node3.itcast.cn
```

3、编写start-kafka.sh脚本

```
vim start-kafka.sh
cat /export/onekey/slave | while read line
do
{
 echo $line
 ssh $line "source /etc/profile;export JMX_PORT=9988;nohup ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties >/dev/nul* 2>&1 & "
}&
wait
done
```

4、编写stop-kafka.sh脚本

```
vim stop-kafka.sh
cat /export/onekey/slave | while read line
do
{
 echo $line
 ssh $line "source /etc/profile;jps |grep Kafka |cut -d' ' -f1 |xargs kill -s 9"
}&
wait
done
```

5、给start-kafka.sh、stop-kafka.sh配置执行权限

```
chmod u+x start-kafka.sh
chmod u+x stop-kafka.sh
```

6、执行一键启动、一键关闭

```
./start-kafka.sh
./stop-kafka.sh
```

## Kafka基础操作

![img](https://image.hyly.net/i/2025/09/24/81e2b226c130414363474ee836ccc6bc-0.webp)

### 创建topic

创建一个topic（主题）。Kafka中所有的消息都是保存在主题中，要生产消息到Kafka，首先必须要有一个确定的主题。

```
## 创建名为test的主题
bin/kafka-topics.sh --create --bootstrap-server node1.itcast.cn:9092 --topic test
## 查看目前Kafka中的主题
bin/kafka-topics.sh --list --bootstrap-server node1.itcast.cn:9092
```

### 生产消息到Kafka

使用Kafka内置的测试程序，生产一些消息到Kafka的test主题中。

```
bin/kafka-console-producer.sh --broker-list node1.itcast.cn:9092 --topic test
```

### 从Kafka消费消息

使用下面的命令来消费 test 主题中的消息。

```
bin/kafka-console-consumer.sh --bootstrap-server node1.itcast.cn:9092 --topic test --from-beginning
```

### 使用Kafka Tools操作Kafka

#### 连接Kafka集群

安装Kafka Tools后启动Kafka

![img](https://image.hyly.net/i/2025/09/24/cdf16b6b0f532291089ce8e3df2d81ae-0.webp)

![img](https://image.hyly.net/i/2025/09/24/4482106b32547e811cba7b8b87ca3ffc-0.webp)

![img](https://image.hyly.net/i/2025/09/24/4aceb1944d416add5322e5daf4356359-0.webp)

#### 创建topic

![img](https://image.hyly.net/i/2025/09/24/d0b4465231d584a7e6a379129b79597c-0.webp)

![img](https://image.hyly.net/i/2025/09/24/29a960e5f9731a867528466ad5be83fb-0.webp)

![img](https://image.hyly.net/i/2025/09/24/f288b99f825ad468a9be65b631f38bf4-0.webp)

## Kafka基准测试

### 基于1个分区1个副本的基准测试

测试步骤：

1. 启动Kafka集群
2. 创建一个1个分区1个副本的topic: benchmark
3. 同时运行生产者、消费者基准测试程序
4. 观察结果

#### 创建topic

```
bin/kafka-topics.sh --zookeeper node1.itcast.cn:2181 --create --topic benchmark --partitions 1 --replication-factor 1
```

#### 生产消息基准测试

在生产环境中，推荐使用生产5000W消息，这样会性能数据会更准确些。为了方便测试，课程上演示测试500W的消息作为基准测试。

```
bin/kafka-producer-perf-test.sh --topic benchmark --num-records 5000000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=1
```

> bin/kafka-producer-perf-test.sh
> --topic topic的名字
> --num-records	总共指定生产数据量（默认5000W）
> --throughput	指定吞吐量——限流（-1不指定）
> --record-size   record数据大小（字节）
> --producer-props bootstrap.servers=192.168.1.20:9092,192.168.1.21:9092,192.168.1.22:9092 acks=1 指定Kafka集群地址，ACK模式

测试结果：

| **吞吐量**   | **93092.533979 records/sec每秒9.3W条记录** |
| ------------ | ------------------------------------------ |
| 吞吐速率     | (88.78 MB/sec)每秒约89MB数据               |
| 平均延迟时间 | 346.62 ms avg latency                      |
| 最大延迟时间 | 1003.00 ms max latency                     |

#### 消费消息基准测试

```
bin/kafka-consumer-perf-test.sh --broker-list node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 --topic benchmark --fetch-size 1048576 --messages 5000000
```

> bin/kafka-consumer-perf-test.sh
> --broker-list 指定kafka集群地址
> --topic 指定topic的名称
> --fetch-size 每次拉取的数据大小
> --messages 总共要消费的消息个数

| **data.consumed.in.MB共计消费的数据** | **4768.3716MB**        |
| ------------------------------------- | ---------------------- |
| MB.sec每秒消费的数量                  | 445.6006每秒445MB      |
| data.consumed.in.nMsg共计消费的数量   | 5000000                |
| nMsg.sec每秒的数量                    | 467246.0518每秒46.7W条 |

### 基于3个分区1个副本的基准测试

被测虚拟机：

| [**node1.itcast.cn**](https://node1.itcast.cn) | [**node2.itcast.cn**](https://node2.itcast.cn) | [**node3.itcast.cn**](https://node3.itcast.cn) |
| ---------------------------------------------- | ---------------------------------------------- | ---------------------------------------------- |
| inter i5 8^th ^8G内存                          | inter i5 8^th ^4G内存                          | inter i5 8^th ^4G内存                          |

#### 创建topic

```
bin/kafka-topics.sh --zookeeper node1.itcast.cn:2181 --create --topic benchmark --partitions 3 --replication-factor 1
```

#### 生产消息基准测试

```
bin/kafka-producer-perf-test.sh --topic benchmark --num-records 5000000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=1
```

测试结果：

| **指标**     | **3分区1个副本**         | **单分区单副本**                       |
| ------------ | ------------------------ | -------------------------------------- |
| 吞吐量       | 68755.930199 records/sec | 93092.533979 records/sec每秒9.3W条记录 |
| 吞吐速率     | 65.57 MB/sec             | (88.78 MB/sec)每秒约89MB数据           |
| 平均延迟时间 | 469.37 ms avg latency    | 346.62 ms avg latency                  |
| 最大延迟时间 | 2274.00 ms max latency   | 1003.00 ms max latency                 |

在虚拟机上，因为都是共享笔记本上的CPU、内存、网络，所以分区越多，反而效率越低。但如果是真实的服务器，分区多效率是会有明显提升的。

#### 消费消息基准测试

```
bin/kafka-consumer-perf-test.sh --broker-list node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 --topic benchmark --fetch-size 1048576 --messages 5000000
```

| **指标**                            | **单分区3个副本**    | **单分区单副本**     |
| ----------------------------------- | -------------------- | -------------------- |
| data.consumed.in.MB共计消费的数据   | 4768.3716MB          | 4768.3716MB          |
| MB.sec每秒消费的数量                | 265.8844MB           | 445.6006每秒445MB    |
| data.consumed.in.nMsg共计消费的数量 | 5000000              | 5000000              |
| nMsg.sec每秒的数量                  | 278800.0446每秒27.8W | 467246.0518每秒46.7W |

还是一样，因为虚拟机的原因，多个分区反而消费的效率也有所下降。

### 基于1个分区3个副本的基准测试

#### 创建topic

```
bin/kafka-topics.sh --zookeeper node1.itcast.cn:2181 --create --topic benchmark --partitions 1 --replication-factor 3
```

#### 生产消息基准测试

```
bin/kafka-producer-perf-test.sh --topic benchmark --num-records 5000000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=1
```

测试结果：

| **指标**     | **单分区3个副本**        | **单分区单副本**                       |
| ------------ | ------------------------ | -------------------------------------- |
| 吞吐量       | 29899.477955 records/sec | 93092.533979 records/sec每秒9.3W条记录 |
| 吞吐速率     | 28.51 MB/sec             | (88.78 MB/sec)每秒约89MB数据           |
| 平均延迟时间 | 1088.43 ms avg latency   | 346.62 ms avg latency                  |
| 最大延迟时间 | 2416.00 ms max latency   | 1003.00 ms max latency                 |

同样的配置，副本越多速度越慢。

#### 消费消息基准测试

```
bin/kafka-consumer-perf-test.sh --broker-list node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 --topic benchmark --fetch-size 1048576 --messages 5000000
```

| **指标**                            | **单分区3个副本**    | **单分区单副本**     |
| ----------------------------------- | -------------------- | -------------------- |
| data.consumed.in.MB共计消费的数据   | 4768.3716MB          | 4768.3716MB          |
| MB.sec每秒消费的数量                | 265.8844MB每秒265MB  | 445.6006每秒445MB    |
| data.consumed.in.nMsg共计消费的数量 | 5000000              | 5000000              |
| nMsg.sec每秒的数量                  | 278800.0446每秒27.8W | 467246.0518每秒46.7W |

## Java编程操作Kafka

### 同步生产消息到Kafka中

#### 需求

接下来，我们将编写Java程序，将1-100的数字消息写入到Kafka中。

#### 准备工作

##### 导入Maven Kafka POM依赖

```
<repositories><!-- 代码库 -->
    <repository>
        <id>central</id>
        <url>http://maven.aliyun.com/nexus/content/groups/public//</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
            <checksumPolicy>fail</checksumPolicy>
        </snapshots>
    </repository>
</repositories>

<dependencies>
    <!-- kafka客户端工具 -->
    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-clients</artifactId>
        <version>2.4.1</version>
    </dependency>

    <!-- 工具类 -->
    <dependency>
        <groupId>org.apache.commons</groupId>
        <artifactId>commons-io</artifactId>
        <version>1.3.2</version>
    </dependency>

    <!-- SLF桥接LOG4J日志 -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-log4j12</artifactId>
        <version>1.7.6</version>
    </dependency>

    <!-- SLOG4J日志 -->
    <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>1.2.16</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.7.0</version>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```

##### 导入log4j.properties

将log4j.properties配置文件放入到resources文件夹中

```
log4j.rootLogger=INFO,stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender 
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout 
log4j.appender.stdout.layout.ConversionPattern=%5p - %m%n
```

##### 创建包和类

创建包cn.itcast.kafka，并创建KafkaProducerTest类。

##### 代码开发

可以参考以下方式来编写第一个Kafka示例程序

参考以下文档：http://kafka.apache.org/24/javadoc/index.html?org/apache/kafka/clients/producer/KafkaProducer.html

1、创建用于连接Kafka的Properties配置

```
Properties props = new Properties();
props.put("bootstrap.servers", "192.168.88.100:9092");
props.put("acks", "all");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
```

2、创建一个生产者对象KafkaProducer

3、调用send发送1-100消息到指定Topic test，并获取返回值Future，该对象封装了返回值

4、再调用一个Future.get()方法等待响应

5、关闭生产者

参考代码：

```
public class KafkaProducerTest {
    public static void main(String[] args) {
        // 1. 创建用于连接Kafka的Properties配置
        Properties props = new Properties();
        props.put("bootstrap.servers", "192.168.88.100:9092");
        props.put("acks", "all");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        // 2. 创建一个生产者对象KafkaProducer
        KafkaProducer<String, String> producer = new KafkaProducer<String, String>(props);

        // 3. 调用send发送1-100消息到指定Topic test
        for(int i = 0; i < 100; ++i) {
            try {
                // 获取返回值Future，该对象封装了返回值
                Future<RecordMetadata> future = producer.send(new ProducerRecord<String, String>("test", null, i + ""));
                // 调用一个Future.get()方法等待响应
                future.get();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }

        // 5. 关闭生产者
        producer.close();
    }
}
```

### 从Kafka的topic中消费消息

#### 需求

从 test topic中，将消息都消费，并将记录的offset、key、value打印出来

#### 准备工作

在cn.itcast.kafka包下创建KafkaConsumerTest类

#### 开发步骤

1、创建Kafka消费者配置

```
Properties props = new Properties();
props.setProperty("bootstrap.servers", "node1.itcast.cn:9092");
props.setProperty("group.id", "test");
props.setProperty("enable.auto.commit", "true");
props.setProperty("auto.commit.interval.ms", "1000");
props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
```

2、创建Kafka消费者

3、订阅要消费的主题

4、使用一个while循环，不断从Kafka的topic中拉取消息

5、将将记录（record）的offset、key、value都打印出来

#### 参考代码

```
public class KafkaProducerTest {
    public static void main(String[] args) {
        // 1. 创建用于连接Kafka的Properties配置
        Properties props = new Properties();
        props.put("bootstrap.servers", "node1.itcast.cn:9092");
        props.put("acks", "all");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        // 2. 创建一个生产者对象KafkaProducer
        KafkaProducer<String, String> producer = new KafkaProducer<String, String>(props);

        // 3. 调用send发送1-100消息到指定Topic test
        for(int i = 0; i < 100; ++i) {
            try {
                // 获取返回值Future，该对象封装了返回值
                Future<RecordMetadata> future = producer.send(new ProducerRecord<String, String>("test", null, i + ""));
                // 调用一个Future.get()方法等待响应
                future.get();
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }

        // 5. 关闭生产者
        producer.close();
    }
}
```

参考官网API文档：

http://kafka.apache.org/24/javadoc/index.html?org/apache/kafka/clients/consumer/KafkaConsumer.html

### 异步使用带有回调函数方法生产消息

如果我们想获取生产者消息是否成功，或者成功生产消息到Kafka中后，执行一些其他动作。此时，可以很方便地使用带有回调函数来发送消息。

需求：

1. 在发送消息出现异常时，能够及时打印出异常信息
2. 在发送消息成功时，打印Kafka的topic名字、分区id、offset

```
public class KafkaProducerTest {
    public static void main(String[] args) {
        // 1. 创建用于连接Kafka的Properties配置
        Properties props = new Properties();
        props.put("bootstrap.servers", "node1.itcast.cn:9092");
        props.put("acks", "all");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        // 2. 创建一个生产者对象KafkaProducer
        KafkaProducer<String, String> producer = new KafkaProducer<String, String>(props);

        // 3. 调用send发送1-100消息到指定Topic test
        for(int i = 0; i < 100; ++i) {
            // 一、同步方式
            // 获取返回值Future，该对象封装了返回值
            // Future<RecordMetadata> future = producer.send(new ProducerRecord<String, String>("test", null, i + ""));
            // 调用一个Future.get()方法等待响应
            // future.get();

            // 二、带回调函数异步方式
            producer.send(new ProducerRecord<String, String>("test", null, i + ""), new Callback() {
                @Override
                public void onCompletion(RecordMetadata metadata, Exception exception) {
                    if(exception != null) {
                        System.out.println("发送消息出现异常");
                    }
                    else {
                        String topic = metadata.topic();
                        int partition = metadata.partition();
                        long offset = metadata.offset();

                        System.out.println("发送消息到Kafka中的名字为" + topic + "的主题，第" + partition + "分区，第" + offset + "条数据成功!");
                    }
                }
            });
        }

        // 5. 关闭生产者
        producer.close();
    }
}
```

## Kafka架构

![img](https://image.hyly.net/i/2025/09/24/35e95361523300fd8420185e6c7c489d-0.webp)

### Kafka重要概念

#### broker

![img](https://image.hyly.net/i/2025/09/24/e47fdf0a3d67d1a955ece193be121a5b-0.webp)

1. 一个Kafka的集群通常由多个broker组成，这样才能实现负载均衡、以及容错
2. broker是 **无状态（Sateless）** 的，它们是通过ZooKeeper来维护集群状态
3. 一个Kafka的broker每秒可以处理数十万次读写，每个broker都可以处理TB消息而不影响性能

#### zookeeper

![img](https://image.hyly.net/i/2025/09/24/2fa3ae5b1769de1b0a3190b6428be776-0.webp)

1. ZK用来管理和协调broker，并且存储了Kafka的元数据（例如：有多少topic、partition、consumer）
2. ZK服务主要用于通知生产者和消费者Kafka集群中有新的broker加入、或者Kafka集群中出现故障的broker。

PS：Kafka正在逐步想办法将ZooKeeper剥离，维护两套集群成本较高，社区提出KIP-500就是要替换掉ZooKeeper的依赖。“Kafka on Kafka”——Kafka自己来管理自己的元数据

#### producer（生产者）

生产者负责将数据推送给broker的topic

#### consumer（消费者）

消费者负责从broker的topic中拉取数据，并自己进行处理

#### consumer group（消费者组）

![img](https://image.hyly.net/i/2025/09/24/ce37469047fb30f44113b2da92cca7ce-0.webp)

1. consumer group是kafka提供的可扩展且具有容错性的消费者机制
2. 一个消费者组可以包含多个消费者
3. 一个消费者组有一个唯一的ID（group Id）
4. 组内的消费者一起消费主题的所有分区数据

#### 分区（Partitions）

![img](https://image.hyly.net/i/2025/09/24/c7934d60d9014085284455fff5235ccb-0.webp)

在Kafka集群中，主题被分为多个分区

#### 副本（Replicas）

![img](https://image.hyly.net/i/2025/09/24/1305b9a859fdeb0fd20ce63b63c44935-0.webp)

1. 副本可以确保某个服务器出现故障时，确保数据依然可用
2. 在Kafka中，一般都会设计副本的个数＞1

#### 主题（Topic）

![img](https://image.hyly.net/i/2025/09/24/5ed8f4cff87c6b4488b89ceb3ecc133a-0.webp)

1. 主题是一个逻辑概念，用于生产者发布数据，消费者拉取数据
2. Kafka中的主题必须要有标识符，而且是唯一的，Kafka中可以有任意数量的主题，没有数量上的限制
3. 在主题中的消息是有结构的，一般一个主题包含某一类消息
4. 一旦生产者发送消息到主题中，这些消息就不能被更新（更改）

#### 偏移量（offset）

![img](https://image.hyly.net/i/2025/09/24/0fa06ec095c4263a4b32a6f98a42de09-0.webp)

1. offset记录着下一条将要发送给Consumer的消息的序号
2. 默认K**afka将**o**ffset存储在**Z**ooKeeper**中
3. 在一个分区中，消息是有顺序的方式存储着，每个在分区的消费都是有一个递增的id。这个就是偏移量offset
4. 偏移量在分区中才是有意义的。在分区之间，offset是没有任何意义的

### 消费者组

Kafka支持有多个消费者同时消费一个主题中的数据。我们接下来，给大家演示，启动两个消费者共同来消费 test 主题的数据。

1、首先，修改生产者程序，让生产者每3秒生产1-100个数字。

```
// 3. 发送1-100数字到Kafka的test主题中
while(true) {
    for (int i = 1; i <= 100; ++i) {
        // 注意：send方法是一个异步方法，它会将要发送的数据放入到一个buffer中，然后立即返回
        // 这样可以让消息发送变得更高效
        producer.send(new ProducerRecord<>("test", i + ""));
    }
    Thread.sleep(3000);
}
```

2、接下来，同时运行两个消费者。

![img](https://image.hyly.net/i/2025/09/24/6125ac0c8f4ed2664d7e6ac647e9599e-0.webp)

3、同时运行两个消费者，我们发现，只有一个消费者程序能够拉取到消息。想要让两个消费者同时消费消息，必须要给test主题，添加一个分区。

```
## 设置 test topic为2个分区
bin/kafka-topics.sh --zookeeper 192.168.88.100:2181 -alter --partitions 2 --topic test
```

4、重新运行生产者、两个消费者程序，我们就可以看到两个消费者都可以消费Kafka Topic的数据了

## Kafka生产者幂等性与事务

### 幂等性

#### 简介

拿http举例来说，一次或多次请求，得到地响应是一致的（网络超时等问题除外），换句话说，就是执行多次操作与执行一次操作的影响是一样的。

![img](https://image.hyly.net/i/2025/09/24/b0cabcdea21333f3f2c28cbe062111dc-0.webp)

如果，某个系统是不具备幂等性的，如果用户重复提交了某个表格，就可能会造成不良影响。例如：用户在浏览器上点击了多次提交订单按钮，会在后台生成多个一模一样的订单。

#### Kafka生产者幂等性

![img](https://image.hyly.net/i/2025/09/24/343e770e8e460dc06e11e254d4f5fd6e-0.webp)

在生产者生产消息时，如果出现retry时，有可能会一条消息被发送了多次，如果Kafka不具备幂等性的，就有可能会在partition中保存多条一模一样的消息。

#### 配置幂等性

```
props.put("enable.idempotence",true);
```

#### 幂等性原理

为了实现生产者的幂等性，Kafka引入了 Producer ID（PID）和 Sequence Number的概念。

1. PID：每个Producer在初始化时，都会分配一个唯一的PID，这个PID对用户来说，是透明的。
2. Sequence Number：针对每个生产者（对应PID）发送到指定主题分区的消息都对应一个从0开始递增的Sequence Number。

![img](https://image.hyly.net/i/2025/09/24/223824ab4a1d5e036192c23f5196cc74-0.webp)

### Kafka事务

#### 简介

Kafka事务是2017年Kafka 0.11.0.0引入的新特性。类似于数据库的事务。Kafka事务指的是生产者生产消息以及消费者提交offset的操作可以在一个原子操作中，要么都成功，要么都失败。尤其是在生产者、消费者并存时，事务的保障尤其重要。（consumer-transform-producer模式）

![img](https://image.hyly.net/i/2025/09/24/f68e9a244dd189e1722b5353e82217a5-0.webp)

![img](https://image.hyly.net/i/2025/09/24/dd7b357638ef79a3ba7bbc392e36f57f-0.webp)

![img](https://image.hyly.net/i/2025/09/24/b41d4f2958feef28f09db8a65b7e4e46-0.webp)

Kafka的事务只能保证在生产和消费数据的时候出现问题时，不提交offset。而不能保证在提交offset时出问题的事务。所以强事务性可以通过MySQL事务来解决，把offset写入MySQL中。

#### 事务操作API

Producer接口中定义了以下5个事务相关方法：

1. initTransactions（初始化事务）：要使用Kafka事务，必须先进行初始化操作
2. beginTransaction（开始事务）：启动一个Kafka事务
3. sendOffsetsToTransaction（提交偏移量）：批量地将分区对应的offset发送到事务中，方便后续一块提交
4. commitTransaction（提交事务）：提交事务
5. abortTransaction（放弃事务）：取消事务

### 【理解】Kafka事务编程

#### 事务相关属性配置

##### 生产者

```
// 配置事务的id，开启了事务会默认开启幂等性
props.put("transactional.id", "first-transactional");
```

##### 消费者

```
// 1. 消费者需要设置隔离级别
props.put("isolation.level","read_committed");
//  2. 关闭自动提交
 props.put("enable.auto.commit", "false");
```

#### Kafka事务编程

##### 需求

在Kafka的topic 「ods_user」中有一些用户数据，数据格式如下：

```
姓名,性别,出生日期
张三,1,1980-10-09
李四,0,1985-11-01
```

我们需要编写程序，将用户的性别转换为男、女（1-男，0-女），转换后将数据写入到topic 「dwd_user」中。要求使用事务保障，要么消费了数据同时写入数据到 topic，提交offset。要么全部失败。

##### 启动生产者控制台程序模拟数据

```
## 创建名为ods_user和dwd_user的主题
bin/kafka-topics.sh --create --bootstrap-server node1.itcast.cn:9092 --topic ods_user
bin/kafka-topics.sh --create --bootstrap-server node1.itcast.cn:9092 --topic dwd_user
## 生产数据到 ods_user
bin/kafka-console-producer.sh --broker-list node1.itcast.cn:9092 --topic ods_user
## 从dwd_user消费数据
bin/kafka-console-consumer.sh --bootstrap-server node1.itcast.cn:9092 --topic dwd_user --from-beginning  --isolation-level read_committed
```

##### 编写创建消费者代码

编写一个方法 createConsumer，该方法中返回一个消费者，订阅「ods_user」主题。注意：需要配置事务隔离级别、关闭自动提交。

实现步骤：

1、创建Kafka消费者配置

```
 Properties props = new Properties();
 props.setProperty("bootstrap.servers", "node1.itcast.cn:9092");
 props.setProperty("group.id", "ods_user");
 props.put("isolation.level","read_committed");
 props.setProperty("enable.auto.commit", "false");
 props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
```

2、创建消费者，并订阅 ods_user 主题

```
   // 1. 创建消费者
    public static Consumer<String, String> createConsumer() {
        // 1. 创建Kafka消费者配置
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "node1.itcast.cn:9092");
        props.setProperty("group.id", "ods_user");
        props.put("isolation.level","read_committed");
        props.setProperty("enable.auto.commit", "false");
        props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        // 2. 创建Kafka消费者
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);

        // 3. 订阅要消费的主题
        consumer.subscribe(Arrays.asList("ods_user"));
        
        return consumer;
}
```

##### 编写创建生产者代码

编写一个方法 createProducer，返回一个生产者对象。注意：需要配置事务的id，开启了事务会默认开启幂等性。

2、创建生产者配置

```
Properties props = new Properties();
props.put("bootstrap.servers", "node1.itcast.cn:9092");
props.put("transactional.id", "dwd_user");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
```

3、创建生产者对象

```
public static Producer<String, String> createProduceer() {
        // 1. 创建生产者配置
        Properties props = new Properties();
        props.put("bootstrap.servers", "node1.itcast.cn:9092");
        props.put("transactional.id", "dwd_user");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        // 2. 创建生产者
        Producer<String, String> producer = new KafkaProducer<>(props);
        return producer;
    }
```

##### 编写代码消费并生产数据

实现步骤：

1. 调用之前实现的方法，创建消费者、生产者对象
2. 生产者调用initTransactions初始化事务
3. 编写一个while死循环，在while循环中不断拉取数据，进行处理后，再写入到指定的topic
	1. 生产者开启事务
	2. 消费者拉取消息
	3. 遍历拉取到的消息，并进行预处理（将1转换为男，0转换为女）
	4. 生产消息到dwd_user topic中
	5. 提交偏移量到事务中
	6. 提交事务
	7. 捕获异常，如果出现异常，则取消事务

```
public static void main(String[] args) {
        Consumer<String, String> consumer = createConsumer();
        Producer<String, String> producer = createProducer();
        // 初始化事务
        producer.initTransactions();

        while(true) {
            try {
                // 1. 开启事务
                producer.beginTransaction();
                // 2. 定义Map结构，用于保存分区对应的offset
                Map<TopicPartition, OffsetAndMetadata> offsetCommits = new HashMap<>();
                // 2. 拉取消息
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofSeconds(2));
                for (ConsumerRecord<String, String> record : records) {
                    // 3. 保存偏移量
                    offsetCommits.put(new TopicPartition(record.topic(), record.partition()),
                            new OffsetAndMetadata(record.offset() + 1));
                    // 4. 进行转换处理
                    String[] fields = record.value().split(",");
                    fields[1] = fields[1].equalsIgnoreCase("1") ? "男":"女";
                    String message = fields[0] + "," + fields[1] + "," + fields[2];
                    // 5. 生产消息到dwd_user
                    producer.send(new ProducerRecord<>("dwd_user", message));
                }
                // 6. 提交偏移量到事务
                producer.sendOffsetsToTransaction(offsetCommits, "ods_user");
                // 7. 提交事务
                producer.commitTransaction();
            } catch (Exception e) {
                // 8. 放弃事务
                producer.abortTransaction();
            }
        }
    }
```

##### 测试

往之前启动的console-producer中写入消息进行测试，同时检查console-consumer是否能够接收到消息：

![img](https://image.hyly.net/i/2025/09/24/1e9d1c779851eb82d9c8834d9d047b4f-0.webp)

逐个测试一下消息：

```
张三,1,1980-10-09
李四,0,1985-11-01
```

##### 模拟异常测试事务

```
// 3. 保存偏移量
offsetCommits.put(new TopicPartition(record.topic(), record.partition()),
        new OffsetAndMetadata(record.offset() + 1));
// 4. 进行转换处理
String[] fields = record.value().split(",");
fields[1] = fields[1].equalsIgnoreCase("1") ? "男":"女";
String message = fields[0] + "," + fields[1] + "," + fields[2];

// 模拟异常
int i = 1/0;

// 5. 生产消息到dwd_user
producer.send(new ProducerRecord<>("dwd_user", message));
```

启动程序一次，抛出异常。

再启动程序一次，还是抛出异常。

直到我们处理该异常为止。

我们发现，可以消费到消息，但如果中间出现异常的话，offset是不会被提交的，除非消费、生产消息都成功，才会提交事务。

## Kafka分区和副本机制

### 生产者分区写入策略

生产者写入消息到topic，Kafka将依据不同的策略将数据分配到不同的分区中

#### 轮询分区策略

![img](https://image.hyly.net/i/2025/09/24/edc5bffc66bc1cade870bc20c280f08b-0.webp)

默认的策略，也是使用最多的策略，可以最大限度保证所有消息平均分配到一个分区

如果在生产消息时，key为null，则使用轮询算法均衡地分配分区

#### 随机分区策略（不用）

随机策略，每次都随机地将消息分配到每个分区。在较早的版本，默认的分区策略就是随机策略，也是为了将消息均衡地写入到每个分区。但后续轮询策略表现更佳，所以基本上很少会使用随机策略。

![img](https://image.hyly.net/i/2025/09/24/3c128fe13a3f7d638d3e99171543a05f-0.webp)

#### 按key分区分配策略

![img](https://image.hyly.net/i/2025/09/24/6c8c50cbf48d320229d9ebb84f1f0c71-0.webp)

按key分配策略，有可能会出现「数据倾斜」，例如：某个key包含了大量的数据，因为key值一样，所有所有的数据将都分配到一个分区中，造成该分区的消息数量远大于其他的分区。

##### 乱序问题

轮询策略、随机策略都会导致一个问题，生产到Kafka中的数据是乱序存储的。而按key分区可以一定程度上实现数据有序存储——也就是局部有序，但这又可能会导致数据倾斜，所以在实际生产环境中要结合实际情况来做取舍。

![img](https://image.hyly.net/i/2025/09/24/cbcf9c4bebb6843a8cee37d49f510ad0-0.webp)

#### 自定义分区策略

![img](https://image.hyly.net/i/2025/09/24/3750dff25ec2b6e248ae5098ee02fcaf-0.webp)

实现步骤：

1、创建自定义分区器

```
public class KeyWithRandomPartitioner implements Partitioner {

    private Random r;

    @Override
    public void configure(Map<String, ?> configs) {
        r = new Random();
    }

    @Override
    public int partition(String topic, Object key, byte[] keyBytes, Object value, byte[] valueBytes, Cluster cluster) {
        // cluster.partitionCountForTopic 表示获取指定topic的分区数量
        return r.nextInt(1000) % cluster.partitionCountForTopic(topic);
    }

    @Override
    public void close() {
    }
}
```

2、在Kafka生产者配置中，自定使用自定义分区器的类名

```
props.put(ProducerConfig.PARTITIONER_CLASS_CONFIG, KeyWithRandomPartitioner.class.getName());
```

### 消费者组Rebalance机制

#### Rebalance再均衡

Kafka中的Rebalance称之为再均衡，是Kafka中确保Consumer group下所有的consumer如何达成一致，分配订阅的topic的每个分区的机制。

Rebalance触发的时机有：

消费者组中consumer的个数发生变化。例如：有新的consumer加入到消费者组，或者是某个consumer停止了。

![img](https://image.hyly.net/i/2025/09/24/b1e5538eb0e5c38ab4a025c8093c94b5-0.webp)

订阅的topic个数发生变化。消费者可以订阅多个主题，假设当前的消费者组订阅了三个主题，但有一个主题突然被删除了，此时也需要发生再均衡。

![img](https://image.hyly.net/i/2025/09/24/f8cca7c502759ec39832d9d1ecfb5fbe-0.webp)

订阅的topic分区数发生变化。

![img](https://image.hyly.net/i/2025/09/24/3db2b32dbdbc45d318c4ac36d8df0d60-0.webp)

#### Rebalance的不良影响

1. 发生Rebalance时，consumer group下的所有consumer都会协调在一起共同参与，Kafka使用分配策略尽可能达到最公平的分配
2. Rebalance过程会对consumer group产生非常严重的影响，Rebalance的过程中所有的消费者都将停止工作，直到Rebalance完成

### 消费者分区分配策略

#### Range范围分配策略

Range范围分配策略是Kafka默认的分配策略，它可以确保每个消费者消费的分区数量是均衡的。

注意：Rangle范围分配策略是针对每个Topic的。

**配置**

配置消费者的partition.assignment.strategy为org.apache.kafka.clients.consumer.RangeAssignor。

**算法公式**

n = 分区数量 / 消费者数量

m = 分区数量 % 消费者数量

前m个消费者消费n+1个

剩余消费者消费n个

![img](https://image.hyly.net/i/2025/09/24/22083047c959a7efb09a46b656bd1bdc-0.webp)

![img](https://image.hyly.net/i/2025/09/24/fc51ae20d9227f9f2afc0baf8a8ce55c-0.webp)

#### RoundRobin轮询策略

RoundRobinAssignor轮询策略是将消费组内所有消费者以及消费者所订阅的所有topic的partition按照字典序排序（topic和分区的hashcode进行排序），然后通过轮询方式逐个将分区以此分配给每个消费者。

**配置**

配置消费者的partition.assignment.strategy为org.apache.kafka.clients.consumer.RoundRobinAssignor。

![img](https://image.hyly.net/i/2025/09/24/45c6f72777aa029881708e9585229e0b-0.webp)

#### Stricky粘性分配策略

从Kafka 0.11.x开始，引入此类分配策略。主要目的：

1. 分区分配尽可能均匀
2. 在发生rebalance的时候，分区的分配尽可能与上一次分配保持相同

没有发生rebalance时，Striky粘性分配策略和RoundRobin分配策略类似。

![img](https://image.hyly.net/i/2025/09/24/37bfe226b4cb5874abe58c3d6dc233bb-0.webp)

上面如果consumer2崩溃了，此时需要进行rebalance。如果是Range分配和轮询分配都会重新进行分配，例如：

![img](https://image.hyly.net/i/2025/09/24/027a10489a0c9ef7bad5ce26980422b5-0.webp)

通过上图，我们发现，consumer0和consumer1原来消费的分区大多发生了改变。接下来我们再来看下粘性分配策略。

![img](https://image.hyly.net/i/2025/09/24/f662293b2b750fe2e50a2a2106124005-0.webp)

我们发现，Striky粘性分配策略，保留rebalance之前的分配结果。这样，只是将原先consumer2负责的两个分区再均匀分配给consumer0、consumer1。这样可以明显减少系统资源的浪费，例如：之前consumer0、consumer1之前正在消费某几个分区，但由于rebalance发生，导致consumer0、consumer1需要重新消费之前正在处理的分区，导致不必要的系统开销。（例如：某个事务正在进行就必须要取消了）

### 副本机制

副本的目的就是冗余备份，当某个Broker上的分区数据丢失时，依然可以保障数据可用。因为在其他的Broker上的副本是可用的。

#### producer的ACKs参数

对副本关系较大的就是，producer配置的acks参数了,acks参数表示当生产者生产消息的时候，写入到副本的要求严格程度。它决定了生产者如何在性能和可靠性之间做取舍。

配置：

```
Properties props = new Properties();
props.put("bootstrap.servers", "node1.itcast.cn:9092");
props.put("acks", "all");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
```

##### acks配置为0

![img](https://image.hyly.net/i/2025/09/24/dccc0462416a13ec8dd95494a6271fe4-0.webp)

ACK为0，基准测试：

```
bin/kafka-producer-perf-test.sh --topic benchmark --num-records 5000000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=0
```

测试结果：

| **指标**     | **单分区单副本（ack=0）**                | **单分区单副本(ack=1)**                |
| ------------ | ---------------------------------------- | -------------------------------------- |
| 吞吐量       | 165875.991109 records/sec每秒16.5W条记录 | 93092.533979 records/sec每秒9.3W条记录 |
| 吞吐速率     | 158.19 MB/sec每秒约160MB数据             | 88.78 MB/sec每秒约89MB数据             |
| 平均延迟时间 | 192.43 ms avg latency                    | 346.62 ms avg latency                  |
| 最大延迟时间 | 670.00 ms max latency                    | 1003.00 ms max latency                 |

##### acks配置为1

![img](https://image.hyly.net/i/2025/09/24/b451d3e05bdabb67e2f3bca587a5adfc-0.webp)

当生产者的ACK配置为1时，生产者会等待leader副本确认接收后，才会发送下一条数据，性能中等。

##### acks配置为-1或者all

![img](https://image.hyly.net/i/2025/09/24/10345b11635f169dea32682de1e81970-0.webp)

```
bin/kafka-producer-perf-test.sh --topic benchmark --num-records 5000000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=all
```

| **指标**     | **单分区单副本（ack=0）**      | **单分区单副本(ack=1)**      | **单分区单副本(ack=-1/all)**  |
| ------------ | ------------------------------ | ---------------------------- | ----------------------------- |
| 吞吐量       | 165875.991109/s每秒16.5W条记录 | 93092.533979/s每秒9.3W条记录 | 73586.766156 /s每秒7.3W调记录 |
| 吞吐速率     | 158.19 MB/sec                  | 88.78 MB/sec                 | 70.18 MB                      |
| 平均延迟时间 | 192.43 ms                      | 346.62 ms                    | 438.77 ms                     |
| 最大延迟时间 | 670.00 ms                      | 1003.00 ms                   | 1884.00 ms                    |

## 高级（High Level）API与低级（Low Level）API

### 高级API

```
/**
 * 消费者程序：从test主题中消费数据
 */
public class _2ConsumerTest {
    public static void main(String[] args) {
        // 1. 创建Kafka消费者配置
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "192.168.88.100:9092");
        props.setProperty("group.id", "test");
        props.setProperty("enable.auto.commit", "true");
        props.setProperty("auto.commit.interval.ms", "1000");
        props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        // 2. 创建Kafka消费者
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);

        // 3. 订阅要消费的主题
        consumer.subscribe(Arrays.asList("test"));

        // 4. 使用一个while循环，不断从Kafka的topic中拉取消息
        while (true) {
            // 定义100毫秒超时
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
            for (ConsumerRecord<String, String> record : records)
                System.out.printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value());
        }
    }
}
```

1. 上面是之前编写的代码，消费Kafka的消息很容易实现，写起来比较简单
2. 不需要执行去管理offset，直接通过ZK管理；也不需要管理分区、副本，由Kafka统一管理
3. 消费者会自动根据上一次在ZK中保存的offset去接着获取数据
4. 在ZK中，不同的消费者组（group）同一个topic记录不同的offset，这样不同程序读取同一个topic，不会受offset的影响

**高级API的缺点**

1. 不能控制offset，例如：想从指定的位置读取
2. 不能细化控制分区、副本、ZK等

### 低级API

通过使用低级API，我们可以自己来控制offset，想从哪儿读，就可以从哪儿读。而且，可以自己控制连接分区，对分区自定义负载均衡。而且，之前offset是自动保存在ZK中，使用低级API，我们可以将offset不一定要使用ZK存储，我们可以自己来存储offset。例如：存储在文件、MySQL、或者内存中。但是低级API，比较复杂，需要执行控制offset，连接到哪个分区，并找到分区的leader。

#### 手动消费分区数据

之前的代码，我们让Kafka根据消费组中的消费者动态地为topic分配要消费的分区。但在某些时候，我们需要指定要消费的分区，例如：

1. 如果某个程序将某个指定分区的数据保存到外部存储中，例如：Redis、MySQL，那么保存数据的时候，只需要消费该指定的分区数据即可。
2. 如果某个程序是高可用的，在程序出现故障时将自动重启(例如：后面我们将学习的Flink、Spark程序)。这种情况下，程序将从指定的分区重新开始消费数据。

如何进行手动消费分区中的数据呢？

1、不再使用之前的 subscribe 方法订阅主题，而使用 「assign」方法指定想要消费的消息

```
     String topic = "test";
     TopicPartition partition0 = new TopicPartition(topic, 0);
     TopicPartition partition1 = new TopicPartition(topic, 1);
     consumer.assign(Arrays.asList(partition0, partition1));
```

2、一旦指定了分区，就可以就像前面的示例一样，在循环中调用「poll」方法消费消息

**注意**

1. 当手动管理消费分区时，即使GroupID是一样的，Kafka的组协调器都将不再起作用
2. 如果消费者失败，也将不再自动进行分区重新分配

## 监控工具Kafka-eagle介绍

![img](https://image.hyly.net/i/2025/09/24/34d7416c70d6fe8d095e951a34df9c49-0.webp)

### Kafka-Eagle简介

在开发工作中，当业务前提不复杂时，可以使用Kafka命令来进行一些集群的管理工作。但如果业务变得复杂，例如：我们需要增加group、topic分区，此时，我们再使用命令行就感觉很不方便，此时，如果使用一个可视化的工具帮助我们完成日常的管理工作，将会大大提高对于Kafka集群管理的效率，而且我们使用工具来监控消费者在Kafka中消费情况。

早期，要监控Kafka集群我们可以使用Kafka Monitor以及Kafka Manager，但随着我们对监控的功能要求、性能要求的提高，这些工具已经无法满足。

Kafka Eagle是一款结合了目前大数据Kafka监控工具的特点，重新研发的一块开源免费的Kafka集群优秀的监控工具。它可以非常方便的监控生产环境中的offset、lag变化、partition分布、owner等。

官网地址：https://www.kafka-eagle.org/

### 安装Kafka-Eagle

#### 开启Kafka JMX端口

##### JMX接口

JMX(Java Management Extensions)是一个为应用程序植入管理功能的框架。JMX是一套标准的代理和服务，实际上，用户可以在任何Java应用程序中使用这些代理和服务实现管理。很多的一些软件都提供了JMX接口，来实现一些管理、监控功能。

##### 开启Kafka JMX

在启动Kafka的脚本前，添加：

```
cd ${KAFKA_HOME}
export JMX_PORT=9988
nohup bin/kafka-server-start.sh config/server.properties &
```

#### 安装Kafka-Eagle

1、安装JDK，并配置好JAVA_HOME。

2、将kafka_eagle上传，并解压到 /export/server 目录中。

```
cd cd /export/software/
tar -xvzf kafka-eagle-bin-1.4.6.tar.gz -C ../server/
cd /export/server/kafka-eagle-bin-1.4.6/ 
tar -xvzf kafka-eagle-web-1.4.6-bin.tar.gz
cd /export/server/kafka-eagle-bin-1.4.6/kafka-eagle-web-1.4.6
```

3、配置 kafka_eagle 环境变量。

```
vim /etc/profile
export KE_HOME=/export/server/kafka-eagle-bin-1.4.6/kafka-eagle-web-1.4.6
export PATH=$PATH:$KE_HOME/bin
source /etc/profile
```

4、配置 kafka_eagle。使用vi打开conf目录下的system-config.properties

```
vim conf/system-config.properties
## 修改第4行，配置kafka集群别名
kafka.eagle.zk.cluster.alias=cluster1
## 修改第5行，配置ZK集群地址
cluster1.zk.list=node1.itcast.cn:2181,node2.itcast.cn:2181,node3.itcast.cn:2181
## 注释第6行
#cluster2.zk.list=xdn10:2181,xdn11:2181,xdn12:2181

## 修改第32行，打开图标统计
kafka.eagle.metrics.charts=true
kafka.eagle.metrics.retain=30

## 注释第69行，取消sqlite数据库连接配置
#kafka.eagle.driver=org.sqlite.JDBC
#kafka.eagle.url=jdbc:sqlite:/hadoop/kafka-eagle/db/ke.db
#kafka.eagle.username=root
#kafka.eagle.password=www.kafka-eagle.org

## 修改第77行，开启mys
kafka.eagle.driver=com.mysql.jdbc.Driver
kafka.eagle.url=jdbc:mysql://node1.itcast.cn:3306/ke?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
kafka.eagle.username=root
kafka.eagle.password=123456
```

5、配置JAVA_HOME

```
cd /export/server/kafka-eagle-bin-1.4.6/kafka-eagle-web-1.4.6/bin
vim ke.sh
## 在第24行添加JAVA_HOME环境配置
export JAVA_HOME=/export/server/jdk1.8.0_241
```

6、修改Kafka eagle可执行权限

```
cd /export/server/kafka-eagle-bin-1.4.6/kafka-eagle-web-1.4.6/bin
chmod +x ke.sh
```

7、启动 kafka_eagle

```
./ke.sh start
```

8、访问Kafka eagle，默认用户为admin，密码为：123456

```
http://node1.itcast.cn:8048/ke
```

![img](https://image.hyly.net/i/2025/09/24/aae8a5e62935c4b48f9e644ed1ae69ed-0.webp)

![img](https://image.hyly.net/i/2025/09/24/110495b4c6f8a708eca36e0d1ea83c7b-0.webp)

### Kafka度量指标

#### topic list

点击Topic下的List菜单，就可以展示当前Kafka集群中的所有topic。

![img](https://image.hyly.net/i/2025/09/24/ed7b5c1ce1d1fe4f46de3236d45c6ad9-0.webp)

![img](https://image.hyly.net/i/2025/09/24/675161611f6f66d8ef899e298e11d137-0.webp)

| **指标**            | **意义**                     |
| ------------------- | ---------------------------- |
| Brokers Spread      | broker使用率                 |
| Brokers Skew        | 分区是否倾斜                 |
| Brokers Leader Skew | leader partition是否存在倾斜 |

#### 生产者消息总计

![img](https://image.hyly.net/i/2025/09/24/164c5ca895f1475c46356008229c7412-0.webp)

## Kafka原理

### 分区的leader与follower

#### Leader和Follower

在Kafka中，每个topic都可以配置多个分区以及多个副本。每个分区都有一个leader以及0个或者多个follower，在创建topic时，Kafka会将每个分区的leader均匀地分配在每个broker上。我们正常使用kafka是感觉不到leader、follower的存在的。但其实，所有的读写操作都是由leader处理，而所有的follower都复制leader的日志数据文件，如果leader出现故障时，follower就会被选举为leader **。** 所以，可以这样说：

1. **Kafka中的leader负责处理读写操作，而follower只负责副本数据的同步**
2. **如果leader出现故障，其他follower会被重新选举为leader**
3. **follower像一个consumer一样，拉取leader对应分区的数据，并保存到日志数据文件中**

![img](https://image.hyly.net/i/2025/09/24/1206fdce75983631a6f06d5b9ef8c37f-0.webp)

![img](https://image.hyly.net/i/2025/09/24/4705fe7db9468e594855f312ce492cc7-0.webp)

#### 查看某个partition的leader

使用Kafka-eagle查看某个topic的partition的leader在哪个服务器中。为了方便观察，我们创建一个名为test的3个分区、3个副本的topic。

![img](https://image.hyly.net/i/2025/09/24/dd7ca099bcff52f26b26131a965976ba-0.webp)

1、点击「Topic」菜单下的「List」

![img](https://image.hyly.net/i/2025/09/24/3307e69e6ed985abadc9aa0ee25452cb-0.webp)

2、任意点击选择一个Topic

![img](https://image.hyly.net/i/2025/09/24/5456f7b06c9aee1da1ea2cb1ce7c44fb-0.webp)

#### AR、ISR、OSR

在实际环境中，leader有可能会出现一些故障，所以Kafka一定会选举出新的leader。在讲解leader选举之前，我们先要明确几个概念。Kafka中，把follower可以按照不同状态分为三类——AR、ISR、OSR。

1. 分区的所有副本称为 「AR」（Assigned Replicas——已分配的副本）
2. 所有与leader副本保持一定程度同步的副本（包括 leader 副本在内）组成 「ISR」（In-Sync Replicas——在同步中的副本）
3. 由于follower副本同步滞后过多的副本（不包括 leader 副本）组成 「OSR」（Out-of-Sync Replias）
4. AR = ISR + OSR
5. 正常情况下，所有的follower副本都应该与leader副本保持同步，即AR = ISR，OSR集合为空。

![img](https://image.hyly.net/i/2025/09/24/684d1df444837211bced24352b702d81-0.webp)

#### 查看分区的ISR

1、使用Kafka Eagle查看某个Topic的partition的ISR有哪几个节点。

![img](https://image.hyly.net/i/2025/09/24/11e8154d353658effe07f66db2e13635-0.webp)

2、尝试关闭id为0的broker（杀掉该broker的进程），参看topic的ISR情况。

![img](https://image.hyly.net/i/2025/09/24/b7a021fab482e56d148a9113850e2bc7-0.webp)

#### Leader选举

leader对于消息的写入以及读取是非常关键的，此时有两个疑问：

1. Kafka如何确定某个partition是leader、哪个partition是follower呢？
2. 某个leader崩溃了，如何快速确定另外一个leader呢？因为Kafka的吞吐量很高、延迟很低，所以选举leader必须非常快

##### 如果leader崩溃，Kafka会如何？

使用Kafka Eagle找到某个partition的leader，再找到leader所在的broker。在Linux中强制杀掉该Kafka的进程，然后观察leader的情况。

![img](https://image.hyly.net/i/2025/09/24/a3da9fe7ed2674a438c99d1d438dbe0c-0.webp)

通过观察，我们发现，leader在崩溃后，Kafka又从其他的follower中快速选举出来了leader。

##### Controller介绍

1. Kafka启动时，会在所有的broker中选择一个controller
2. 前面leader和follower是针对partition，而controller是针对broker的
3. 创建topic、或者添加分区、修改副本数量之类的管理任务都是由controller完成的
4. Kafka分区leader的选举，也是由controller决定的

##### Controller的选举

1. 在Kafka集群启动的时候，每个broker都会尝试去ZooKeeper上注册成为Controller（ZK临时节点）
2. 但只有一个竞争成功，其他的broker会注册该节点的监视器
3. 一点该临时节点状态发生变化，就可以进行相应的处理
4. Controller也是高可用的，一旦某个broker崩溃，其他的broker会重新注册为Controller

##### 找到当前Kafka集群的controller

1. 点击Kafka Tools的「Tools」菜单，找到「ZooKeeper Brower...」
2. 点击左侧树形结构的controller节点，就可以查看到哪个broker是controller了。

![img](https://image.hyly.net/i/2025/09/24/3d46fd90711f144de7ca5645852e64e9-0.webp)

##### 测试controller选举

通过kafka tools找到controller所在的broker对应的kafka进程，杀掉该进程，重新打开ZooKeeper brower，观察kafka是否能够选举出来新的Controller。

![img](https://image.hyly.net/i/2025/09/24/9c14084524f5a3e1913c6573bb90d98c-0.webp)

##### Controller选举partition leader

1. 所有Partition的leader选举都由controller决定
2. controller会将leader的改变直接通过RPC的方式通知需为此作出响应的Broker
3. controller读取到当前分区的ISR，只要有一个Replica还幸存，就选择其中一个作为leader否则，则任意选这个一个Replica作为leader
4. 如果该partition的所有Replica都已经宕机，则新的leader为-1

为什么不能通过ZK的方式来选举partition的leader？

1. Kafka集群如果业务很多的情况下，会有很多的partition
2. 假设某个broker宕机，就会出现很多的partiton都需要重新选举leader
3. 如果使用zookeeper选举leader，会给zookeeper带来巨大的压力。所以，kafka中leader的选举不能使用ZK来实现

#### leader负载均衡

##### Preferred Replica

1. Kafka中引入了一个叫做「preferred-replica」的概念，意思就是：优先的Replica
2. 在ISR列表中，第一个replica就是preferred-replica
3. 第一个分区存放的broker，肯定就是preferred-replica
4. 执行以下脚本可以将preferred-replica设置为leader，均匀分配每个分区的leader。

```
./kafka-leader-election.sh --bootstrap-server node1.itcast.cn:9092 --topic 主题 --partition=1 --election-type preferred
```

##### 确保leader在broker中负载均衡

杀掉test主题的某个broker，这样kafka会重新分配leader。等到Kafka重新分配leader之后，再次启动kafka进程。此时：观察test主题各个分区leader的分配情况。

![img](https://image.hyly.net/i/2025/09/24/35231846274db7353a6b666101e8a386-0.webp)

此时，会造成leader分配是不均匀的，所以可以执行以下脚本来重新分配leader:

```
bin/kafka-leader-election.sh --bootstrap-server node1.itcast.cn:9092 --topic test --partition=2 --election-type preferred
```

> --partition：指定需要重新分配leader的partition编号

![img](https://image.hyly.net/i/2025/09/24/19c8854bbd4255beb0954b7db520cf7b-0.webp)

### Kafka生产、消费数据工作流程

#### Kafka数据写入流程

![img](https://image.hyly.net/i/2025/09/24/2c90fcf54e6463fad522f449cdc0788b-0.webp)

生产者先从 zookeeper 的 "/brokers/topics/主题名/partitions/分区名/state"节点找到该 partition 的leader

![img](https://image.hyly.net/i/2025/09/24/f9a47a50b6a21a7537c021a71d8e7200-0.webp)

生产者在ZK中找到该ID找到对应的broker

![img](https://image.hyly.net/i/2025/09/24/c4bf47cb5d120b819af4abfa0dd37b1f-0.webp)

broker进程上的leader将消息写入到本地log中

follower从leader上拉取消息，写入到本地log，并向leader发送ACK

leader接收到所有的ISR中的Replica的ACK后，并向生产者返回ACK。

#### Kafka数据消费流程

##### 两种消费模式

![img](https://image.hyly.net/i/2025/09/24/67fd489932efc201b6e221483abac07f-0.webp)

1. kafka采用拉取模型，由消费者自己记录消费状态，每个消费者互相独立地顺序拉取每个分区的消息
2. 消费者可以按照任意的顺序消费消息。比如，消费者可以重置到旧的偏移量，重新处理之前已经消费过的消息；或者直接跳到最近的位置，从当前的时刻开始消费。

##### Kafka消费数据流程

![img](https://image.hyly.net/i/2025/09/24/89852acc9cf701f1f0b2872b7cd6aa47-0.webp)

1. 每个consumer都可以根据分配策略（默认RangeAssignor），获得要消费的分区
2. 获取到consumer对应的offset（默认从ZK中获取上一次消费的offset）
3. 找到该分区的leader，拉取数据
4. 消费者提交offset

### Kafka的数据存储形式

![img](https://image.hyly.net/i/2025/09/24/566a37c8a2c23734d565f03642eee985-0.webp)

1. 一个topic由多个分区组成
2. 一个分区（partition）由多个segment（段）组成
3. 一个segment（段）由多个文件组成（log、index、timeindex）

#### 存储日志

接下来，我们来看一下Kafka中的数据到底是如何在磁盘中存储的。

1. Kafka中的数据是保存在 /export/server/kafka_2.12-2.4.1/data中
2. 消息是保存在以：「主题名-分区ID」的文件夹中的
3. 数据文件夹中包含以下内容：

![img](https://image.hyly.net/i/2025/09/24/5801ba83db829ead8e11638740de5c09-0.webp)

这些分别对应：

| **文件名**                     | **说明**                                                     |
| ------------------------------ | ------------------------------------------------------------ |
| 00000000000000000000.index     | 索引文件，根据offset查找数据就是通过该索引文件来操作的       |
| 00000000000000000000.log       | 日志数据文件                                                 |
| 00000000000000000000.timeindex | 时间索引                                                     |
| leader-epoch-checkpoint        | 持久化每个partition leader对应的LEO（log end offset、日志文件中下一条待写入消息的offset） |

1. 每个日志文件的文件名为起始偏移量，因为每个分区的起始偏移量是0，所以，分区的日志文件都以0000000000000000000.log开始
2. 默认的每个日志文件最大为「log.segment.bytes =1024**1024**1024」1G
3. 为了简化根据offset查找消息，Kafka日志文件名设计为开始的偏移量

![img](https://image.hyly.net/i/2025/09/24/22c84619c9382ef8da05ff4baf212b6b-0.webp)

##### 观察测试

为了方便测试观察，新创建一个topic：「test_10m」，该topic每个日志数据文件最大为10M

```
bin/kafka-topics.sh --create --zookeeper node1.itcast.cn --topic test_10m --replication-factor 2 --partitions 3 --config segment.bytes=10485760
```

使用之前的生产者程序往「test_10m」主题中生产数据，可以观察到如下：

![img](https://image.hyly.net/i/2025/09/24/643a2c3f319caaea12c3db2600cbf953-0.webp)

![img](https://image.hyly.net/i/2025/09/24/7f1578510d9950c232fdad76569a3e47-0.webp)

##### 写入消息

新的消息总是写入到最后的一个日志文件中

该文件如果到达指定的大小（默认为：1GB）时，将滚动到一个新的文件中

![img](https://image.hyly.net/i/2025/09/24/902acd8ed2aee569543fc8d15149adc6-0.webp)

##### 读取消息

![img](https://image.hyly.net/i/2025/09/24/34294e90ac46564f2bba3c02df447453-0.webp)

根据「offset」首先需要找到存储数据的 segment 段（注意：offset指定分区的全局偏移量）

然后根据这个「全局分区offset」找到相对于文件的「segment段offset」

![img](https://image.hyly.net/i/2025/09/24/cacf124f60c867f1ccc810c00748f245-0.webp)

![img](https://image.hyly.net/i/2025/09/24/3c23cd8bc6899515070612a6826a3a65-0.webp)

最后再根据 「segment段offset」读取消息

为了提高查询效率，每个文件都会维护对应的范围内存，查找的时候就是使用简单的二分查找

##### 删除消息

在Kafka中，消息是会被**定期清理**的。一次删除一个segment段的日志文件

Kafka的日志管理器，会根据Kafka的配置，来决定哪些文件可以被删除

### 消息不丢失机制

#### broker数据不丢失

生产者通过分区的leader写入数据后，所有在ISR中follower都会从leader中复制数据，这样，可以确保即使leader崩溃了，其他的follower的数据仍然是可用的

#### 生产者数据不丢失

生产者连接leader写入数据时，可以通过ACK机制来确保数据已经成功写入。ACK机制有三个可选配置

1. 配置ACK响应要求为 -1 时 —— 表示所有的节点都收到数据(leader和follower都接

收到数据）

1. 配置ACK响应要求为 1 时 —— 表示leader收到数据
2. 配置ACK影响要求为 0 时 —— 生产者只负责发送数据，不关心数据是否丢失（这种情

况可能会产生数据丢失，但性能是最好的）

生产者可以采用同步和异步两种方式发送数据

1. 同步：发送一批数据给kafka后，等待kafka返回结果
2. 异步：发送一批数据给kafka，只是提供一个回调函数。

说明：如果broker迟迟不给ack，而buﬀer又满了，开发者可以设置是否直接清空buﬀer中的数据。

#### 消费者数据不丢失

在消费者消费数据的时候，只要每个消费者记录好oﬀset值即可，就能保证数据不丢失。

![img](https://image.hyly.net/i/2025/09/24/ce1c5f95b1ef8cf67f26667688149915-0.webp)

broker通过leader选主策略保证数据不丢失，生产者通过ACK机制保证数据不丢失，生产者和消费者也可以通过MySQL事务来保证offset正确消息不丢失。

#### 消息重复消费

![img](https://image.hyly.net/i/2025/09/24/9e01a85cefdc54d6708789ec7d0e4f82-0.webp)

![img](https://image.hyly.net/i/2025/09/24/407e52ff3e9ba6a0ca1c68e70034d377-0.webp)

通过MySQL事务记录好offset来保证消息不重复消费。

### 数据积压

Kafka消费者消费数据的速度是非常快的，但如果由于处理Kafka消息时，由于有一些外部IO、或者是产生网络拥堵，就会造成Kafka中的数据积压（或称为数据堆积）。如果数据一直积压，会导致数据出来的实时性受到较大影响。

#### 使用Kafka-Eagle查看数据积压情况

![img](https://image.hyly.net/i/2025/09/24/ab6223d3579c2c08ec834db72218baeb-0.webp)

![img](https://image.hyly.net/i/2025/09/24/46cae0ed253f9ef62eb4fd5be9cbcb29-0.webp)

![img](https://image.hyly.net/i/2025/09/24/579082a1128cfeef3b8628e9cc40e958-0.webp)

![img](https://image.hyly.net/i/2025/09/24/32e7a23193fe5b086e0bbb30916e7254-0.webp)

#### 解决数据积压问题

当Kafka出现数据积压问题时，首先要找到数据积压的原因。以下是在企业中出现数据积压的几个类场景。

##### 数据写入MySQL失败

**问题描述**

某日运维人员找到开发人员，说某个topic的一个分区发生数据积压，这个topic非常重要，而且开始有用户投诉。运维非常紧张，赶紧重启了这台机器。重启之后，还是无济于事。

**问题分析**

消费这个topic的代码比较简单，主要就是消费topic数据，然后进行判断在进行数据库操作。运维通过kafka-eagle找到积压的topic，发现该topic的某个分区积压了几十万条的消息。

最后，通过查看日志发现，由于数据写入到MySQL中报错，导致消费分区的offset一自没有提交，所以数据积压严重。

##### 因为网络延迟消费失败

**问题描述**

基于Kafka开发的系统平稳运行了两个月，突然某天发现某个topic中的消息出现数据积压，大概有几万条消息没有被消费。

**问题分析**

通过查看应用程序日志发现，有大量的消费超时失败。后查明原因，因为当天网络抖动，通过查看Kafka的消费者超时配置为50ms，随后，将消费的时间修改为500ms后问题解决。

## Kafka中数据清理（Log Deletion）

Kafka的消息存储在磁盘中，为了控制磁盘占用空间，Kafka需要不断地对过去的一些消息进行清理工作。Kafka的每个分区都有很多的日志文件，这样也是为了方便进行日志的清理。在Kafka中，提供两种日志清理方式：

1. 日志删除（Log Deletion）：按照指定的策略直接删除不符合条件的日志。
2. 日志压缩（Log Compaction）：按照消息的key进行整合，有相同key的但有不同value值，只保留最后一个版本。

在Kafka的broker或topic配置中：

| **配置项**         | **配置值**     | **说明**             |
| ------------------ | -------------- | -------------------- |
| log.cleaner.enable | true（默认）   | 开启自动清理日志功能 |
| log.cleanup.policy | delete（默认） | 删除日志             |
| log.cleanup.policy | compaction     | 压缩日志             |
| log.cleanup.policy | delete,compact | 同时支持删除、压缩   |

### 日志删除

日志删除是以段（segment日志）为单位来进行定期清理的。

#### 定时日志删除任务

![img](https://image.hyly.net/i/2025/09/24/a987c074c559ad807717d6fd33e417bb-0.webp)

Kafka日志管理器中会有一个专门的日志删除任务来定期检测和删除不符合保留条件的日志分段文件，这个周期可以通过broker端参数log.retention.check.interval.ms来配置，默认值为300,000，即5分钟。当前日志分段的保留策略有3种：

##### 基于时间的保留策略

以下三种配置可以指定如果Kafka中的消息超过指定的阈值，就会将日志进行自动清理：

1. log.retention.hours
2. log.retention.minutes
3. log.retention.ms

其中，优先级为log.retention.ms > log.retention.minutes > log.retention.hours。默认情况，在broker中，配置如下：

log.retention.hours=168

也就是，默认日志的保留时间为168小时，相当于保留7天。

**删除日志分段时:**

1. 从日志文件对象中所维护日志分段的跳跃表中移除待删除的日志分段，以保证没有线程对这些日志分段进行读取操作
2. 将日志分段文件添加上“.deleted”的后缀（也包括日志分段对应的索引文件）
3. Kafka的后台定时任务会定期删除这些“.deleted”为后缀的文件，这个任务的延迟执行时间可以通过file.delete.delay.ms参数来设置，默认值为60000，即1分钟。

###### 设置topic 5秒删除一次

1、为了方便观察，设置段文件的大小为1M。

![img](https://image.hyly.net/i/2025/09/24/0447ebad802e069641ad12c523aee346-0.webp)

key: segment.bytes

value: 1048576

![img](https://image.hyly.net/i/2025/09/24/d4a5b007a9281785a36928793d511ca8-0.webp)

2、设置topic的删除策略

key: retention.ms

value: 5000

![img](https://image.hyly.net/i/2025/09/24/92c8b99b3fabdae56267e8d8cf48522a-0.webp)

尝试往topic中添加一些数据，等待一会，观察日志的删除情况。我们发现，日志会定期被标记为删除，然后被删除。

##### 基于日志大小的保留策略

日志删除任务会检查当前日志的大小是否超过设定的阈值来寻找可删除的日志分段的文件集合。可以通过broker端参数 log.retention.bytes 来配置，默认值为-1，表示无穷大。如果超过该大小，会自动将超出部分删除。

**注意:**

log.retention.bytes 配置的是日志文件的总大小，而不是单个的日志分段的大小，一个日志文件包含多个日志分段。

##### 基于日志起始偏移量保留策略

每个segment日志都有它的起始偏移量，如果起始偏移量小于 logStartOffset，那么这些日志文件将会标记为删除。

### 日志压缩（Log Compaction）

Log Compaction是默认的日志删除之外的清理过时数据的方式。它会将相同的key对应的数据只保留一个版本。

![img](https://image.hyly.net/i/2025/09/24/ebacb0623a1077e6c9e73668368426b4-0.webp)

1. Log Compaction执行后，offset将不再连续，但依然可以查询Segment
2. Log Compaction执行前后，日志分段中的每条消息偏移量保持不变。Log Compaction会生成一个新的Segment文件
3. Log Compaction是针对key的，在使用的时候注意每个消息的key不为空
4. 基于Log Compaction可以保留key的最新更新，可以基于Log Compaction来恢复消费者的最新状态

## Kafka配额限速机制（Quotas）

生产者和消费者以极高的速度生产/消费大量数据或产生请求，从而占用broker上的全部资源，造成网络IO饱和。有了配额（Quotas）就可以避免这些问题。Kafka支持配额管理，从而可以对Producer和Consumer的produce&fetch操作进行流量限制，防止个别业务压爆服务器。

### 限制producer端速率

为所有client id设置默认值，以下为所有producer程序设置其TPS不超过1MB/s，即1048576‬/s，命令如下：

```
bin/kafka-configs.sh --zookeeper node1.itcast.cn:2181 --alter --add-config 'producer_byte_rate=1048576' --entity-type clients --entity-default
```

运行基准测试，观察生产消息的速率

```
bin/kafka-producer-perf-test.sh --topic test --num-records 500000 --throughput -1 --record-size 1000 --producer-props bootstrap.servers=node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 acks=1
```

结果：

50000 records sent, 1108.156028 records/sec (1.06 MB/sec)

### 限制consumer端速率

对consumer限速与producer类似，只不过参数名不一样。

为指定的topic进行限速，以下为所有consumer程序设置topic速率不超过1MB/s，即1048576/s。命令如下：

```
bin/kafka-configs.sh --zookeeper node1.itcast.cn:2181 --alter --add-config 'consumer_byte_rate=1048576' --entity-type clients --entity-default
```

运行基准测试：

```
bin/kafka-consumer-perf-test.sh --broker-list node1.itcast.cn:9092,node2.itcast.cn:9092,node3.itcast.cn:9092 --topic test --fetch-size 1048576 --messages 500000
```

结果为：

MB.sec：1.0743

### 取消Kafka的Quota配置

使用以下命令，删除Kafka的Quota配置

```
bin/kafka-configs.sh --zookeeper node1.itcast.cn:2181 --alter --delete-config 'producer_byte_rate' --entity-type clients --entity-default
bin/kafka-configs.sh --zookeeper node1.itcast.cn:2181 --alter --delete-config 'consumer_byte_rate' --entity-type clients --entity-default
```