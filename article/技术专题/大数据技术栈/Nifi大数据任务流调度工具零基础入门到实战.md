---
category: [大数据技术栈]
tag: [Nifi,大数据,任务流调度]
postType: post
status: publish
---

## Nifi概念

### Nifi是什么

Apache NiFi 是一个易于使用，功能强大且可靠的系统，用于处理和分发数据。可以自动化管理系统间的数据流。它使用高度可配置的指示图来管理数据路由、转换和系统中介逻辑，支持从多种数据源动态拉取数据。NiFi原来是NSA的一个项目，目前已经代码开源，是Apache基金会的顶级项目之一。

NiFi是基于Java的，使用Maven支持包的构建管理。 NiFi基于Web方式工作，后台在服务器上进行调度。用户可以将数据处理定义为一个流程，然后进行处理，NiFi后台具有数据处理引擎、任务调度等组件。

简单的说，NiFi就是为了解决不同系统间数据自动流通问题而建立的。

虽然dataflow这个术语在各种场景都有被使用，但我们在这里使用它来表示不同系统间的自动化的可管理的信息流。自企业拥有多个系统开始，一些系统会有数据生成，一些系统要消费数据，而不同系统之间数据的流通问题就出现了。这些问题出现的相应的解决方案已经被广泛的研究和讨论，其中企业集成eip就是一个全面且易于使用的方案。

**dataflow要面临的一些挑战包括：**

- **Systems fail**

  系统调用失败，网络故障，磁盘故障，软件崩溃，人为事故。
- **Data access exceeds capacity to consume**

  数据访问超出了消耗能力。有时，给定的数据源可能会超过处理链或交付链的某些部分的处理能力，而只需要一个环节出现问题，整个流程都会受到影响。
- **Boundary conditions are mere suggestions**

  超出边界问题，总是会得到太大、太小、太快、太慢、损坏、错误或格式错误的数据。
- **What is noise one day becomes signal the next**

  现实业务或需求变更快，设计新的数据处理流程或者修改已有的流程必须要迅速。
- **Systems evolve at different rates**

  给定的系统所使用的协议或数据格式可能随时改变，而且常常跟周围其他系统无关。dataflow的存在就是为了连接这种大规模分布的，松散的，甚至根本不是设计用来一起工作的组件系统。
- **Compliance and security**

  法律，法规和政策发生变化。企业对企业协议的变化。系统到系统和系统到用户的交互必须是安全的，可信的，负责任的。
- **Continuous improvement occurs in production**

  通常不可能在测试环境中完全模拟生产环境。

多年来，数据流一直是架构中不可避免的问题之一。现在有许多活跃的、快速发展的技术，使得dataflow对想要成功的特定企业更加重要，比如soa,API，iot,bigData。此外，合规性，隐私性和安全性所需的严格程度也在不断提高。尽管不停的出现这些新概念新技术，但dataflow面临的困难和挑战依旧，其中主要的区别还是复杂的范围，需要适应需求变化的速度以及大规模边缘情况的普遍化。NiFi旨在帮助解决这些现代数据流挑战。

### NIFI核心概念

NiFi的基本设计概念与基于流程的编程fbp(Flow Based Programing)的主要思想密切相关。以下是一些主要的NiFi概念以及与FBP的关系：

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >NiFi术语</th><th style='text-align:left;' >FBP Term</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >FlowFile</td><td style='text-align:left;' >信息包Information Packet</td><td style='text-align:left;' >FlowFile表示在系统中移动的每个对象，对于每个FlowFile，NIFI都会记录它一个属性键值对和0个或多个字节内容(FlowFile有attribute和content)。</td></tr><tr><td style='text-align:left;' >FlowFile Processor</td><td style='text-align:left;' >黑盒&#x3c;br&gt;Black Box</td><td style='text-align:left;' >实际上是处理器起主要作用。在eip术语中，处理器就是不同系统间的数据路由，数据转换或者数据中介的组合。处理器可以访问给定FlowFile的属性及其内容。处理器可以对给定工作单元中的零或多个流文件进行操作，并提交该工作或回滚该工作。</td></tr><tr><td style='text-align:left;' >Connection</td><td style='text-align:left;' >缓冲区Bounded Buffer</td><td style='text-align:left;' >Connections用来连接处理器。它们充当队列并允许各种进程以不同的速率进行交互。这些队列可以动态地对进行优先级排序，并且可以在负载上设置上限，从而启用背压。</td></tr><tr><td style='text-align:left;' >Flow Controller</td><td style='text-align:left;' >调度器Scheduler</td><td style='text-align:left;' >流控制器维护流程如何连接，并管理和分配所有流程使用的线程。流控制器充当代理，促进处理器之间流文件的交换。</td></tr><tr><td style='text-align:left;' >Process Group</td><td style='text-align:left;' >分支网络subnet</td><td style='text-align:left;' >进程组里是一组特定的流程和连接，可以通过输入端口接收数据并通过输出端口发送数据，这样我们在进程组里简单地组合组件，就可以得到一个全新功能的组件(Process Group)。</td></tr></tbody>
</table></figure>

此设计模型也类似于seda（分阶段），带来了很多好处，有助于NiFi成为非常有效的、构建功能强大且可扩展的数据流的平台。其中一些好处包括：

- 有助于处理器有向图的可视化创建和管理
- 本质上是异步的，允许非常高的吞吐量和足够的自然缓冲
- 提供高并发的模型，开发人员不必担心并发的复杂性
- 促进内聚和松散耦合组件的开发，然后可以在其他环境中重复使用并方便单元测试
- 资源受限的连接(流程中可配置connections)使得背压和压力释放等关键功能非常自然和直观
- 错误处理变得像基本逻辑一样自然，而不是粗粒度的全部捕获(catch-all)
- 数据进入和退出系统的点，以及它是如何流动的，都是容易理解和跟踪的。

### NiFi架构

![image.png](https://image.hyly.net/i/2025/09/28/0c2b1bfbf6af1e0bccd0083bad800227-0.webp)

- **Web Server(网络服务器)**

  web服务器的目的是承载NiFi基于http的命令和控制API。
- **Flow Controller(流控制器)**

  是整个操作的核心，为将要运行的组件提供线程，管理调度。
- **Extensions(扩展)**

  有各种类型的NIFI扩展，这些扩展在其他文档中进行了描述。这里的关键点是NIFI扩展在JVM中操作和执行。
- **FlowFile Repository(流文件存储库)**

  对于给定一个流中正在活动的FlowFile,FlowFile Repository就是NIFI保持跟踪这个FlowFIle状态的地方。FlowFile Repository的实现是可插拔的（多种选择，可配置，甚至可以自己实现），默认实现是使用Write-Ahead Log技术(简单普及下，WAL的核心思想是：在数据写入库之前，先写入到日志.再将日志记录变更到存储器中。)写到指定磁盘目录。
- **Content Repository(内容存储库)**

  Content Repository是给定FlowFile的实际内容字节存储的地方。Content Repository的实现是可插拔的。默认方法是一种相当简单的机制，它将数据块存储在文件系统中。可以指定多个文件系统存储位置，以便获得不同的物理分区以减少任何单个卷上的争用。(所以环境最佳实践时可配置多个目录，挂载不同磁盘，提高IO)
- **Provenance Repository(源头存储库)**

  Provenance Repository是存储所有事件数据的地方。Provenance Repository的实现是可插拔的，默认实现是使用一个或多个物理磁盘卷。在每个位置内的事件数据都是被索引并可搜索的。

NiFi也能够在集群内运行。

![image.png](https://image.hyly.net/i/2025/09/28/137a01b126f8d47f298af71316583cea-0.webp)

Cluster Coordinator:	集群协调器，用来进行管理节点添加和删除的操作逻辑

Primary Node:	主节点，用来运行一些不适合在集群中运行的组件

Zookeeper Client:	zk节点

从NiFi 1.0版本开始，NIFI集群采用了Zero-Master Clustering模式。NiFi群集中的每个节点对数据执行相同的任务，但每个节点都在不同的数据集上运行。Apache ZooKeeper选择单个节点作为集群协调器，ZooKeeper自动处理故障转移。所有集群节点都会向集群协调器发送心跳报告和状态信息。集群协调器负责断开和连接节点。此外，每个集群都有一个主节点，主节点也是由ZooKeeper选举产生。我们可以通过任何节点的用户界面（UI）与NiFi群集进行交互，并且我们所做的任何更改都将复制到集群中的所有节点上。

### NIFI的性能

NIFI的设计目的是充分利用其运行的底层主机系统的能力。这种资源的最大化在CPU和磁盘方面尤其明显。

- **For IO**

  不同系统不同配置可预期的吞吐量或延迟会有很大差异，具体取决于系统的配置方式。鉴于大多数NiFi子系统都有可插拔的实现方法，所以性能取决于实现。但是，对于一些具体和广泛适用的地方，请考虑使用现成的默认实现。这些实现都是持久的，有保证的让数据流传递，并且是使用本地磁盘来实现。因此，保守点说，假设在典型服务器中的普通磁盘或RAID卷上的每秒读/写速率大约为50 MB，那么，对于大型数据流，NIFI应该能够有效地达到每秒100 MB或更多的吞吐量。这是因为预期添加到NiFi的每个物理分区和content repository都会出现线性增长。
- **For CPU**

  Flow Controller充当引擎的角色，指示特定处理器何时可以被分配线程去执行。编译处理器并在执行任务后立即释放线程。可以为Flow Controller提供一个配置值，该值指示它维护的各种线程池的可用线程。理想的线程数取决于主机系统内核数量，系统中是否正在运行其他服务，以及流程中要处理的流的性质。对于典型的IO大流量，合理的做法是让多线程可用。
- **For RAM**

  NiFi在JVM中运行，因此受限于JVM提供的内存。JVM垃圾回收（GC）成为限制实际堆总大小以及优化应用程序运行的一个非常重要的因素。NIFI作业在定期读取相同内容时可能会占用大量I/O。可以配置足够大的内存和磁盘以优化性能。

### NIFI关键特性

**流管理**

- **保证交付**

  NIFI的核心理念是，即使在非常高的规模下，也必须保证交付。这是通过有效地使用专门构建的Write-Ahead Log和content repository来实现的。它们一起被设计成具备允许非常高的事务速率、有效的负载分布、写时复制和能发挥传统磁盘读/写的优势。
- **数据缓冲 背压和压力释放**

  NIFI支持缓冲所有排队的数据，以及在这些队列达到指定限制时提供背压的能力（背压对象阈值和背压数据大小阈值），或在数据达到指定期限（其值已失效）时老化丢弃数据的能力。
- **队列优先级**

  NiFi允许设置一个或多个优先级方案，用于如何从队列中检索数据。默认情况是先进先出，但有时应该首先提取最新的数据(后进先出)、最大的数据先出或其他定制方案。
- **特殊流质量 (延迟和吞吐量)**

  可能在数据流的某些节点上数据至关重要，不容丢失，并且在 某些时刻这些数据需要在几秒钟就处理完毕传向下一节点才会有意义。对于这些 方面NIFI也可以做细粒度的配置。

**易用性**

- **可视化流程**

  数据流的处理逻辑和过程可能会非常复杂。能够可视化这些流程并以可视的方式来表达它们可以极大地帮助用户降低数据流的复杂度，并确定哪些地方需要简化。NiFi可以实现数据流的可视化建立，而且是实时的。并不是“设计、部署”，它更像泥塑。如果对数据流进行了更改，更改就会立即生效，并且这些更改是细粒度的和组件隔离的。用户不需要为了进行某些特定修改而停止整个流程或流程组。
- **流模版**

  FlowFIle往往是高度模式化的，虽然通常有许多不同的方法来解决问题，但能够共享这些最佳实践却大有帮助。流程模板允许设计人员构建和发布他们的流程设计，并让其他人从中受益和复用。
- **数据起源跟踪**

  在对象流经系统时，甚至在扇入、扇出、转换等过程，NIFI会自动记录、索引并提供可用的源数据。这些信息在支持法规遵从性、故障排除、优化以及其他方案中变得极其关键。
- **可以记录和重放的细粒度历史记录缓冲区**

  NiFi的content repository旨在充当历史数据的滚动缓冲区。数据仅在content repository老化或需要空间时才会被删除。content repository与data provenance能力相结合，为在对象的生命周期中的特定点（甚至可以跨越几代）实现可以查看内容，内容下载和重放等功能提供了非常有用的基础。

**灵活的缩放模型**

- **水平扩展 (Clustering)**

  NiFi的设计是可集群，可横向扩展的。如果配置单个节点并将其配置为每秒处理数百MB数据，那么可以相应的将集群配置为每秒处理GB级数据。但这也带来了NiFi与其获取数据的系统之间的负载平衡和故障转移的挑战。采用基于异步排队的协议（如消息服务，Kafka等）可以提供帮助解决这些问题。
- **扩展和缩小**

  NiFi还可以非常灵活地扩展和缩小。从NiFi框架的角度来看，在增加吞吐量方面，可以在配置时增加“调度”选项卡下处理器上的并发任务数。这允许更多线程同时执行，从而提供更高的吞吐量。另一方面，您可以完美地将NiFi缩小到适合在边缘设备上运行，因为硬件资源有限，所需的占用空间很小，这种情况可以使用MINIFI。

## Nifi入门

### 学习目标

1. 能够安装NiFi
2. 了解NiFi的处理器
3. 了解NiFi的其他组件
4. 能够使用NiFi进行简单场景的练习
5. 了解NiFi处理器的大致类别
6. 了解NiFi处理器的核心属性
7. 了解NiFi模版
8. 了解NiFi监控
9. 了解数据来源

### 常用术语

**FlowFile**：每条"用户数据"（即用户带进NiFi的需要进行处理和分发的数据）称为FlowFile。FlowFile由两部分组成：Attributes 和 Content。Content是用户数据本身。Attributes是与用户数据关联的键值对。

**Processor**：处理器,是NiFi组件,负责创建,发送,接收,转换,路由,拆分,合并和处理FlowFiles。它是NiFi用户可用于构建其数据流的最重要的构建块。

### 运行环境准备

Apache nifi即可运行在Windows平台，也可运行在Linux平台，需要安装jdk（nifi 1.x以上需要jdk8以上，0.x需jdk7以上）和maven（至少3.1.0以上版本）。

### 下载

NIFI下载地址：https://archive.apache.org/dist/nifi/1.9.2/

下载当前版本的NiFi二进制工程，我们这里使用比较稳定的1.9.2版本。

![image.png](https://image.hyly.net/i/2025/09/28/45968d81766c11f1d56d7ad85ec1a089-0.webp)

### 修改默认端口

同一系统启动多个服务时, 避免端口冲突, 建议修改默认端口

**配置文件位置: nifi-1.9.2/conf/nifi.properties**

```properties
# nifi端口配置, 这里修改为: 58080
......
134 # web properties #
135 nifi.web.war.directory=./lib
136 nifi.web.http.host=
137 nifi.web.http.port=58080  # 修改默认端口为: 58080
138 nifi.web.http.network.interface.default=
139 nifi.web.https.host=
140 nifi.web.https.port=
141 nifi.web.https.network.interface.default=
142 nifi.web.jetty.working.directory=./work/jetty
......
```

### 启动

#### Windows用户

对于Windows用户,进入安装NiFi的文件夹,在此文件夹中有一个名为bin的子文件夹。进入此子文件夹,然后双击run-nifi.bat文件。

这将启动NiFi并让它在前台运行。要关闭NiFi,请选择已启动的窗口,按住Ctrl+C。

#### Linux、Mac用户

对于Linux和OS X用户,使用终端窗口进入安装NiFi的目录。要在前台运行NiFi,就运行bin/nifi.sh run,直到用户按下Ctrl-C,NIFI就关闭了。

要在后台运行NiFi,请运行bin/nifi.sh start。这将启动应用程序并开始运行。要检查状态并查看NiFi当前是否正在运行,请执行bin/nifi.sh status命令。可以通过执行命令bin/nifi.sh stop关闭NiFi 。

#### 作为一个服务进行安装

目前,仅支持Linux和Mac OS X用户作为服务进行NiFi的安装。要将应用程序作为服务去安装,首先进入安装目录,然后执行命令bin/nifi.sh install,这样就以默认名称nifi安装服务了。要为服务指定自定义名称,请使用可选的第二个参数（该服务的名称）执行该命令。例如,要将NiFi作为具有dataflow名称的服务安装,请使用该命令：bin/nifi.sh install dataflow。

安装后,可以使用适当的命令启动和停止服务,例如sudo service nifi start 和sudo service nifi stop。此外,可以通过执行sudo service nifi status命令检查运行状态。

以linux版本为例, 解压并启动

```bash
### 下载目录为/opt
# 进入目录
cd /opt
# 解压文件
tar zxvf nifi-1.9.2-bin.tar.gz
# 得到目录: nifi-1.9.2, 进入bin目录并查看目录内容
cd nifi-1.9.2/bin && ls
# 结果: dump-nifi.bat  nifi-env.bat  nifi-env.sh  nifi.sh  run-nifi.bat  status-nifi.bat

# 使用 nifi.sh 进行单机运行操作, 常用参数如下:
# ./nifi.sh --help
# Usage nifi {start|stop|run|restart|status|dump|install}

### 以下是常用命令
# 启动：
./nifi.sh start
# 关闭：
./nifi.sh stop
# 重启：
./nifi.sh restart
# 状态：
./nifi.sh status
															``
```

执行启动命令后, 需要等待 1 - 5分钟 ( 根据电脑配置 ), 可以查看日志, 看到端口( 这里配置的是58080 )说明启动成功, 查看日志操作如下:

```bash
# 日志目录: nifi-1.9.2/logs
cd logs && tail -f nifi-app.log
# 看到如下日志说明启动成功( ip根据你电脑的ip而定, 可能不一样 ) 
```

![image.png](https://image.hyly.net/i/2025/09/28/d9a20ceb0873add5025ca173353b6c71-0.webp)

启动成功后访问 : ip:58080/nifi 进行查看,  访问界面如下:

![image.png](https://image.hyly.net/i/2025/09/28/148d681a0ad1578b1098a1e26335146d-0.webp)

### Nifi处理器

#### 查看处理器

1, 选择处理器组件

![image.png](https://image.hyly.net/i/2025/09/28/540c9b9231f2792f67996df0d571bcaa-0.webp)

2, 弹出窗口显示的就是所有处理器

![image.png](https://image.hyly.net/i/2025/09/28/6f1ccde01a20a789f7877f28cefedc6a-0.webp)

#### 常用处理器

**ExecuteScript** :  执行脚本处理器, 支持: clojure, ecmascript, groovy, lua, python, ruby

**QueryDatabaseTable** :  数据库查询处理器, 支持: mysql

**ConvertAvroToJSON** :  avro 数据格式转换为 json

**SplitJson** :  将JSON文件拆分为多个单独的FlowFiles, 用于由JsonPath表达式指定的数组元素。

**EvaluateJsonPath** :  根据FlowFile的内容评估一个或多个JsonPath表达式。这些表达式的结果将分配给FlowFile属性，或者写入FlowFile本身的内容，具体取决于处理器的配置。

**ReplaceText** :  文本组装与替换, 支持正则表达式

**PutHDFS** :  将FlowFile数据写入Hadoop分布式文件系统（HDFS）

**PutHiveQL** :  执行hive ddl/dml命令, 如: insert, update

**PublishKafka_2_0** :  根据配置将消息发送到kafka topic

**SelectHiveQL** :  执行hive select 语句并获取结果

**PutSQL** :  执行SQL的insert或update命令

**GetFile** :  从目录中的文件创建FlowFiles。

**PutFile** :  将FlowFile数据写入文件

**GetHDFS** :  从Hadoop分布式文件系统获取文件

**CaptureChangeMySQL** :  从MySQL数据库中检索更改数据捕获（CDC）事件。CDC事件包括INSERT，UPDATE，DELETE操作。事件作为单个流文件输出，这些文件按操作发生的时间排序。

**ExecuteStreamCommand** :  一般用于执行sh脚本

#### 配置处理器

##### 添加一个处理器

以GetFile为例:

![image.png](https://image.hyly.net/i/2025/09/28/3130276c134cfe8b4816ab6fcbea78b1-0.gif)

##### 配置处理器配置项说明

右键()要配置的处理器, 会弹出配置项菜单, 如下图:

![image.png](https://image.hyly.net/i/2025/09/28/2c09431f95841895d261eb05029277af-0.webp)

**选项说明:**

- **Configure**（配置）：此选项允许用户建立或更改处理器的配置。
- **Start**（启动或停止）：此选项允许用户启动或停止处理器; 该选项可以是Start或Stop，具体取决于处理器的当前状态。
- **Disable**（启用或禁用）：此选项允许用户启用或启用处理器; 该选项将为“启用”或“禁用”，具体取决于处理器的当前状态。
- **View data provenance**（查看数据来源）：此选项显示NiFi数据来源表，其中包含有关通过该处理器路由FlowFiles的数据来源事件的信息。
- **View status history**（查看状态历史记录）：此选项打开处理器统计信息随时间的图形表示。
- **View usage**（查看用法）：此选项将用户带到处理器的使用文档。
- **View connection → Upstream**（查看连接→上游）：此选项允许用户查看和“跳转”入处理器的上游连接。当处理器连接进出其他进程组时，这尤其有用。
- **View connection → Downstream**（查看连接→下游）：此选项允许用户查看和“跳转”到处理器外的下游连接。当处理器连接进出其他进程组时，这尤其有用。
- **Centere in view**（视图中心）：此选项将画布的视图置于给定的处理器上。
- **Change color**（更改颜色）：此选项允许用户更改处理器的颜色，这可以使大流量的可视化管理更容易。
- **Group** （添加到组）：把当前处理器添加到组
- **Create template**（创建模板）：此选项允许用户从所选处理器创建模板。
- **Copy**（复制）：此选项将所选处理器的副本放在剪贴板上，以便可以通过右键单击工作区并选择“粘贴”将其粘贴到工作区上的其他位置。复制粘贴操作也可以使用按键Ctrl-C和Ctrl-V完成。
- **Delete**（删除）：此选项允许从画布中删除处理器。

##### 配置处理器

以GetFile为例

方式1: 右键选择 -- > Configure

![image.png](https://image.hyly.net/i/2025/09/28/431e8b6a4d2c55c6ccd8a26c16f1f9a4-0.webp)

方式2: 鼠标左键双击处理器

配置窗口如下图:

![image.png](https://image.hyly.net/i/2025/09/28/3f4077ae143366ea9507f94146660869-0.webp)

配置分为4个部分: SETTING, SCHEDULING, PROPERTIES, COMMENTS, 接下来一一介绍

###### SETTING ( 设置 )

![image.png](https://image.hyly.net/i/2025/09/28/7ec015bf75e382d9d43686e2e0619c29-0.webp)

###### SCHEDULING ( 任务调度 )

![image.png](https://image.hyly.net/i/2025/09/28/3c9ac1a9989ce20eb7599a4427d49726-0.webp)

**PS: 不同的处理器, 可能略有不同**

###### PROPERTIES ( 属性 )

![image.png](https://image.hyly.net/i/2025/09/28/eac7e99ffc7dbbd4a0397235853d9489-0.webp)

PS: **不同处理属性不同**

###### COMMENTS ( 注释 )

![image.png](https://image.hyly.net/i/2025/09/28/6becc96f18c54edb2477095f080680cb-0.webp)

修改完成, 记得保存修改, 点击右下角的 "**APPLY**" 保存修改

![image.png](https://image.hyly.net/i/2025/09/28/68f9331216de73e2bd42243ed851b5ff-0.webp)

### 其他组件

#### 数据流传入点（input-port）

![image.png](https://image.hyly.net/i/2025/09/28/11ec813069b6924f3d059b2a1ef77d4b-0.webp)

虽说是数据流输入点，但是并不是整体数据流的起点。它是作为组与组之间的数据流连接的传入点与输出点。

#### 数据流输出点（output-port）

![image.png](https://image.hyly.net/i/2025/09/28/0658cbf20d745459e86f1adf1fad4f36-0.webp)

同理上面的输入点。它是作为组与组之间的数据流连接的传入点与输出点。

#### 组(process-group)

![image.png](https://image.hyly.net/i/2025/09/28/6bea9416c592462ad4863e3439a32755-0.webp)

组相当于系统中的文件夹，作用就是使数据流的各个部分看起来更工整，思路更清晰，不至于从头到尾一条线阅读起来十分不方便。

#### 远程组(remote process-group)

![image.png](https://image.hyly.net/i/2025/09/28/119dd4298931cdcaf5fb89a9b5cafd6f-0.webp)

添加远程的组。

#### 聚合(funnel)

![image.png](https://image.hyly.net/i/2025/09/28/28a68db7b2a031d8d47e87a3ec5e668d-0.webp)

用于将来自多个Connections的数据合并到一个Connection中。

#### 模版(template)

![image.png](https://image.hyly.net/i/2025/09/28/3bb72d8ba87ec4cb9cde7e972ba4a9b4-0.webp)

可以将若干组件组合在一起以形成更大的组，从该组创建数据流模版。这些模板也可以导出为XML并导入到另一个NiFi实例中，从而可以共享这些组。

#### 便签（label）

![image.png](https://image.hyly.net/i/2025/09/28/0732e903d13411e8e3c3e119b0324d3e-0.webp)

可放置在画布空白处，写上备注信息。

#### 导航(Navigate)

![image.png](https://image.hyly.net/i/2025/09/28/a179f8fb38ecae5c43d2ccfc09b77803-0.webp)

Navigate是对工作区进行预览，点击放大缩小可调整视野，蓝框区域就是工作区当前的界面，可用鼠标在这部分进行移动从而调整工作区的视野。

#### 操作区(Operate)

![image.png](https://image.hyly.net/i/2025/09/28/a609daf4184f7b4da50444ef8cfc0ae7-0.webp)

PS: **右键工作区空白处也可以弹出操作菜单**

##### 配置(Configuration)

![image.png](https://image.hyly.net/i/2025/09/28/dd3fc2df2c52f1bcf4abec27c1e8a665-0.webp)根据在当前工作区选中的组件, 进行属性配置, 可配置所有组件或组

##### 启用(enable)

![image.png](https://image.hyly.net/i/2025/09/28/e68ce49ec80c1a270ce4952054db2198-0.webp)启用组件, 不能操作组

##### 禁用(disable)

![image.png](https://image.hyly.net/i/2025/09/28/664c08ee6d028b007599b92f9bb599bc-0.webp)禁用组件, 不能操作组

##### 开始(start)

![image.png](https://image.hyly.net/i/2025/09/28/d1619809798801f1b943c8c93492f37f-0.webp)启动选择的组件或组, 不选择启动所有

##### 停止(stop)

![image.png](https://image.hyly.net/i/2025/09/28/0ce2882ffd0e36ddbb6fde5374f53d5c-0.webp)停止选择的组件或组, 不选择停止所有

##### 创建模版(create template)

![image.png](https://image.hyly.net/i/2025/09/28/995fecbed842d802e3fd67131a7b89af-0.webp)根据选择的组件或组创建模版

##### 上传模版(upload template)

![image.png](https://image.hyly.net/i/2025/09/28/ad1c3a836fa75e60333ed9dd33da0fec-0.webp)上传已保存的模版

### 应用场景：

#### 添加和配置第一个处理器：GetFile

###### 添加处理器

![image.png](https://image.hyly.net/i/2025/09/28/064163ce08f8f5d58a4e06ca58ce1bd4-0.gif)

###### 设置处理器名称

![image.png](https://image.hyly.net/i/2025/09/28/696099dd83a0efed8378b9b52219742a-0.gif)

###### 设置Properties

**设置Properties**

![image.png](https://image.hyly.net/i/2025/09/28/192e8d8c7370a3d7977249d08f561c72-0.gif)

Nifi处理器官方文档：http://nifi.apache.org/docs.html

**GetFile属性说明**

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >Name</th><th>Default Value</th><th>Allowable Values</th><th style='text-align:left;' >Description</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Input Directory（输入目录）</strong></td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >要从中提取文件的输入目录&#x3c;br/&gt;<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>File Filter(文件过滤器)</strong></td><td>[^.].*</td><td>&nbsp;</td><td style='text-align:left;' >仅选择名称与给定正则表达式匹配的文件</td></tr><tr><td style='text-align:left;' >Path Filter(路径过滤器)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >如果“递归子目录”为true，则仅扫描其路径与给定正则表达式匹配的子目录</td></tr><tr><td style='text-align:left;' ><strong>Batch Size(批量大小)</strong></td><td>10</td><td>&nbsp;</td><td style='text-align:left;' >每次迭代中提取的最大文件数</td></tr><tr><td style='text-align:left;' ><strong>Keep Source File(保留源文件)</strong></td><td>false</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >如果为true，则将文件复制到内容存储库后不会删除该文件；这会导致文件不断被拾取，对于测试目的很有用。如果没有保留原始NiFi，则需要从其提取目录中具有写权限，否则它将忽略该文件。</td></tr><tr><td style='text-align:left;' ><strong>Recurse Subdirectories(递归子目录)</strong></td><td>true</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >指示是否从子目录中提取文件</td></tr><tr><td style='text-align:left;' ><strong>Polling Interval(轮询间隔)</strong></td><td>0 sec</td><td>&nbsp;</td><td style='text-align:left;' >指示执行目录列表之前要等待多长时间</td></tr><tr><td style='text-align:left;' ><strong>Ignore Hidden Files(忽略隐藏文件)</strong></td><td>true</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >指示是否应忽略隐藏文件</td></tr><tr><td style='text-align:left;' ><strong>Minimum File Age(最小档案年龄)</strong></td><td>0 sec</td><td>&nbsp;</td><td style='text-align:left;' >档案必须被拉出的最小年龄；小于此时间（根据上次修改日期）的任何文件将被忽略</td></tr><tr><td style='text-align:left;' >Maximum File Age(最长文件年龄)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >档案必须被拉出的最大年龄；任何超过此时间（根据上次修改日期）的文件将被忽略</td></tr><tr><td style='text-align:left;' ><strong>Minimum File Size(最小档案大小)</strong></td><td>0 B</td><td>&nbsp;</td><td style='text-align:left;' >档案必须达到的最小大小</td></tr><tr><td style='text-align:left;' >Maximum File Size(最大档案大小)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >可以拉出文件的最大大小</td></tr></tbody>
</table></figure>

**创建上传文件目录**

![image.png](https://image.hyly.net/i/2025/09/28/e0b2b5493d50f9091fcad4cd0d8ef7aa-0.webp)

```shell
mkdir -p /export/tmp/source
```

#### 第二处理器PutFile和启动流程

###### 添加处理器

![image.png](https://image.hyly.net/i/2025/09/28/be1b066dc61f7a285d3d692bc3e24304-0.gif)

###### 设置处理器属性

**设置写入目录**

![image.png](https://image.hyly.net/i/2025/09/28/d73a47164971c54fb44b5c5e5f0e5dec-0.gif)

**putfile处理器属性说明**

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >Name</th><th>Default Value</th><th>Allowable Values</th><th style='text-align:left;' >Description</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Directory(目录)</strong></td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >文件应写入的目录。您可以使用表达语言，例如/ aa / bb / $ {path}。&#x3c;br/&gt;<strong>支持表达语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Conflict Resolution Strategy(解决冲突策略)</strong></td><td>fail</td><td>replace&#x3c;br/&gt;ignore&#x3c;br/&gt;fail</td><td style='text-align:left;' >指示当输出目录中已经存在同名文件时应该怎么办</td></tr><tr><td style='text-align:left;' ><strong>Create Missing Directories(创建缺失目录)</strong></td><td>true</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >如果为true，则将创建缺少的目标目录。如果为false，则流文件将受到处罚并发送失败。</td></tr><tr><td style='text-align:left;' >Maximum File Count(最大文件数)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >指定输出目录中可以存在的最大文件数</td></tr><tr><td style='text-align:left;' >Last Modified Time(上次修改时间)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >将输出文件上的lastModifiedTime设置为此属性的值。格式必须为yyyy-MM-dd&#39;T&#39;HH：mm：ssZ。您也可以使用表达式语言，例如$ {file.lastModifiedTime}。&#x3c;br/&gt;<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Permissions(权限)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >将输出文件的权限设置为此属性的值。格式必须是带有-的UNIX rwxrwxrwx（代替拒绝的权限）（例如rw-r--r--）或八进制数（例如644）。您也可以使用表达式语言，例如$ {file.permissions}。&#x3c;br/&gt;<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Owner(所有者)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >将输出文件的所有者设置为此属性的值。您也可以使用$ {file.owner}之类的表达语言。请注意，在许多操作系统上，Nifi必须以超级用户身份运行才能拥有设置文件所有者的权限。&#x3c;br/&gt;<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Group(组)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >将输出文件上的组设置为此属性的值。您也可以使用表达语言，例如$ {file.group}。&#x3c;br/&gt;<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr></tbody>
</table></figure>

**创建写入文件目录**

```shell
mkdir -p /export/tmp/target
```

###### 连接两个处理器

![image.png](https://image.hyly.net/i/2025/09/28/bd7418fb37c10f9b010706c0fb352e94-0.gif)

启动GetFile

![image.png](https://image.hyly.net/i/2025/09/28/9dd0bd1883e37d7ebcfc49c899486e2e-0.gif)

###### 新增输入文件

```shell
cd /export/tmp/source
echo "hello world" > hello-world.txt
```

观察文件是否存在:

![image.png](https://image.hyly.net/i/2025/09/28/8b9a92e4065192b6e1ccb3a181c400a8-0.webp)

观察nifi流程：

![image.png](https://image.hyly.net/i/2025/09/28/84d79984299bec170248931ccd68d771-0.webp)

继续写入：

```shell
echo "hello world" > hello-world.txt
echo "hello world" > hello-world2.txt
```

![image.png](https://image.hyly.net/i/2025/09/28/bd7e3065eb3caf07b7979a7424ddb66e-0.webp)

2.2.6 putfile自连接

![image.png](https://image.hyly.net/i/2025/09/28/8f4e71aa15e80a52c02bdf75562b781c-0.gif)

###### 启动putfile

**启动后报错**

提示有文件名重复

![image.png](https://image.hyly.net/i/2025/09/28/d1f6313e7decea61cb6b7abd7f0c4317-0.webp)

查看/export/tmp/target/目录下内容：

![image.png](https://image.hyly.net/i/2025/09/28/c09df35f7393afb7da5af0d0b4a392e4-0.webp)

写入三次文件，两个写入成功，一个写入失败。是因为报错信息中提到的，有两个文件的文件名重复了。

###### 覆盖写入

那么当我们需要对文件进行覆盖写入的时候怎么办呢？

**修改配置项Conflict Resolution Strategy**

![image.png](https://image.hyly.net/i/2025/09/28/4096c13bd060afbbf2ebe71ffc083f1b-0.gif)

**重复写入文件**

再次启动PutFile处理器后，写入文件(文件名重复)

```shell
echo "hello world again" > hello-world.txt
```

![image.png](https://image.hyly.net/i/2025/09/28/78d7e5cef38db40ef9fac8192f1ce6df-0.webp)

发现没有新的报错信息，且文件内容成功被覆盖。

###### 关闭处理器

不用的时候关闭处理器，否则会持续运行读取数据。

![image.png](https://image.hyly.net/i/2025/09/28/80140c71cc02ca810706b18921167be8-0.gif)

### 处理器的类别

为了创建有效的数据流处理流程,用户必须了解可用的处理器类型。NiFi包含许多不同的处理器。这些处理器提供了可从众多不同系统中提取数据,路由,转换,处理,拆分和聚合数据以及将数据分发到多个系统的功能。

几乎每个NiFi版本中可用的处理器数量都在增加。因此,我们不会尝试在这里介绍每一个可用的处理器,但我们将重点介绍一些最常用的处理器,按功能对它们进行分类。

#### 数据转换

- CompressContent：压缩或解压
- ConvertCharacterSet：将用于编码内容的字符集从一个字符集转换为另一个字符集
- EncryptContent：加密或解密
- ReplaceText：使用正则表达式修改文本内容
- TransformXml：应用XSLT转换XML内容
- JoltTransformJSON：应用JOLT规范来转换JSON内容

#### 路由和调解

- ControlRate：限制流程中数据流经某部分的速率
- DetectDuplicate：根据一些用户定义的标准去监视发现重复的FlowFiles。通常与HashContent一起使用
- DistributeLoad：通过只将一部分数据分发给每个用户定义的关系来实现负载平衡或数据抽样
- MonitorActivity：当用户定义的时间段过去而没有任何数据流经此节点时发送通知。（可选）在数据流恢复时发送通知。
- RouteOnAttribute：根据FlowFile包含的属性路由FlowFile。
- ScanAttribute：扫描FlowFile上用户定义的属性集,检查是否有任何属性与用户定义的字典匹配。
- RouteOnContent：根据FlowFile的内容是否与用户自定义的正则表达式匹配。如果匹配,则FlowFile将路由到已配置的关系。
- ScanContent：在流文件的内容中搜索用户定义字典中存在的术语,并根据这些术语的存在或不存在来路由。字典可以由文本条目或二进制条目组成。
- ValidateXml：以XML模式验证XML内容; 根据用户定义的XML Schema,判断FlowFile的内容是否有效,进而来路由FlowFile。1

#### 数据库访问

- ConvertJSONToSQL：将JSON文档转换为SQL INSERT或UPDATE命令,然后可以将其传递给PutSQL Processor
- ExecuteSQL：执行用户定义的SQL SELECT命令,结果为Avro格式的FlowFile
- PutSQL：通过执行FlowFile内容定义的SQL DDM语句来更新数据库
- SelectHiveQL：对Apache Hive数据库执行用户定义的HiveQL SELECT命令,结果为Avro或CSV格式的FlowFile
- PutHiveQL：通过执行FlowFile内容定义的HiveQL DDM语句来更新Hive数据库

#### 属性提取

- EvaluateJsonPath：用户提供JSONPath表达式（类似于XPath,用于XML解析/提取）,然后根据JSON内容评估这些表达式,用结果值替换FlowFile内容或将结果值提取到用户自己命名的Attribute中。
- EvaluateXPath：用户提供XPath表达式,然后根据XML内容评估这些表达式,用结果值替换FlowFile内容或将结果值提取到用户自己命名的Attribute中。
- EvaluateXQuery：用户提供XQuery查询,然后根据XML内容评估此查询,用结果值替换FlowFile内容或将结果值提取到用户自己命名的Attribute中。
- ExtractText：用户提供一个或多个正则表达式,然后根据FlowFile的文本内容对其进行评估,然后将结果值提取到用户自己命名的Attribute中。
- HashAttribute：对用户定义的现有属性列表的串联进行hash。
- HashContent：对FlowFile的内容进行hash,并将得到的hash值添加到Attribute中。
- IdentifyMimeType：评估FlowFile的内容,以确定FlowFile封装的文件类型。此处理器能够检测许多不同的MIME类型,例如图像,文字处理器文档,文本和压缩格式,仅举几例。
- UpdateAttribute：向FlowFile添加或更新任意数量的用户定义的属性。这对于添加静态的属性值以及使用表达式语言动态计算出来的属性值非常有用。该处理器还提供"高级用户界面(Advanced User Interface)",允许用户根据用户提供的规则有条件地去更新属性。

#### 系统交互

- ExecuteProcess：运行用户自定义的操作系统命令。进程的StdOut被重定向,以便StdOut的内容输出为FlowFile的内容。此处理器是源处理器(不接受数据流输入,没有上游组件) - 其输出预计会生成新的FlowFile,并且系统调用不会接收任何输入。如果要为进程提供输入,请使用ExecuteStreamCommand Processor。
- ExecuteStreamCommand：运行用户定义的操作系统命令。FlowFile的内容可选地流式传输到进程的StdIn。StdOut的内容输出为FlowFile的内容。此处理器不能用作源处理器 - 必须传入FlowFiles才能执行。

#### 数据提取

- GetFile：将文件内容从本地磁盘（或网络连接的磁盘）流式传输到NiFi,然后删除原始文件。此处理器应将文件从一个位置移动到另一个位置,而不是用于复制数据。
- GetFTP：通过FTP将远程文件的内容下载到NiFi中,然后删除原始文件。此处理器应将文件从一个位置移动到另一个位置,而不是用于复制数据。
- GetSFTP：通过SFTP将远程文件的内容下载到NiFi中,然后删除原始文件。此处理器应将文件从一个位置移动到另一个位置,而不是用于复制数据。
- GetJMSQueue：从JMS队列下载消息,并根据JMS消息的内容创建FlowFile。可选地,JMS属性也可以作为属性复制。
- GetJMSTopic：从JMS主题下载消息,并根据JMS消息的内容创建FlowFile。可选地,JMS属性也可以作为属性复制。此处理器支持持久订阅和非持久订阅。
- GetHTTP：将基于HTTP或HTTPS的远程URL的请求内容下载到NiFi中。处理器将记住ETag和Last-Modified Date,以确保不会持续摄取数据。
- ListenHTTP：启动HTTP（或HTTPS）服务器并侦听传入连接。对于任何传入的POST请求,请求的内容将作为FlowFile写出,并返回200响应。
- ListenUDP：侦听传入的UDP数据包,并为每个数据包或每个数据包创建一个FlowFile（取决于配置）,并将FlowFile发送到"success"。
- GetHDFS：监视HDFS中用户指定的目录。每当新文件进入HDFS时,它将被复制到NiFi并从HDFS中删除。此处理器应将文件从一个位置移动到另一个位置,而不是用于复制数据。如果在集群中运行,此处理器需仅在主节点上运行。要从HDFS复制数据并使其保持原状,或者从群集中的多个节点流式传输数据,请参阅ListHDFS处理器。
- ListHDFS / FetchHDFS：ListHDFS监视HDFS中用户指定的目录,并发出一个FlowFile,其中包含它遇到的每个文件的文件名。然后,它通过分布式缓存在整个NiFi集群中保持此状态。然后可以在集群中,将其发送到FetchHDFS处理器,后者获取这些文件的实际内容并发出包含从HDFS获取的内容的FlowFiles。
- GetKafka：从Apache Kafka获取消息,特别是0.8.x版本。消息可以作为每个消息的FlowFile发出,也可以使用用户指定的分隔符一起进行批处理。
- GetMongo：对MongoDB执行用户指定的查询,并将内容写入新的FlowFile。

#### 数据出口/发送数据

- PutEmail：向配置的收件人发送电子邮件。FlowFile的内容可选择作为附件发送。
- PutFile：将FlowFile的内容写入本地（或网络连接）文件系统上的目录。
- PutFTP：将FlowFile的内容复制到远程FTP服务器。
- PutSFTP：将FlowFile的内容复制到远程SFTP服务器。
- PutJMS：将FlowFile的内容作为JMS消息发送到JMS代理,可选择将Attributes添加JMS属性。
- PutSQL：将FlowFile的内容作为SQL DDL语句（INSERT,UPDATE或DELETE）执行。FlowFile的内容必须是有效的SQL语句。属性可以用作参数,FlowFile的内容可以是参数化的SQL语句,以避免SQL注入攻击。
- PutKafka：将FlowFile的内容作为消息发送到Apache Kafka,特别是0.8.x版本。FlowFile可以作为单个消息或分隔符发送,例如可以指定换行符,以便为单个FlowFile发送许多消息。
- PutMongo：将FlowFile的内容作为INSERT或UPDATE发送到Mongo。

#### 分裂和聚合

- SplitText：SplitText接收单个FlowFile,其内容为文本,并根据配置的行数将其拆分为1个或多个FlowFiles。例如,可以将处理器配置为将FlowFile拆分为多个FlowFile,每个FlowFile只有一行。
- SplitJson：允许用户将包含数组或许多子对象的JSON对象拆分为每个JSON元素的FlowFile。
- SplitXml：允许用户将XML消息拆分为多个FlowFiles,每个FlowFiles包含原始段。这通常在多个XML元素与"wrapper"元素连接在一起时使用。然后,此处理器允许将这些元素拆分为单独的XML元素。
- UnpackContent：解压缩不同类型的存档格式,例如ZIP和TAR。然后,归档中的每个文件都作为单个FlowFile传输。
- SegmentContent：根据某些已配置的数据大小将FlowFile划分为可能的许多较小的FlowFile。不对任何类型的分界符执行拆分,而是仅基于字节偏移执行拆分。这是在传输FlowFiles之前使用的,以便通过并行发送许多不同的部分来提供更低的延迟。而另一方面,MergeContent处理器可以使用碎片整理模式重新组装这些FlowFiles。
- MergeContent：此处理器负责将许多FlowFiles合并到一个FlowFile中。可以通过将其内容与可选的页眉,页脚和分界符连接在一起,或者通过指定存档格式（如ZIP或TAR）来合并FlowFiles。FlowFiles可以根据公共属性进行分箱(binned),或者如果这些流是被其他组件拆分的,则可以进行"碎片整理(defragmented)"。根据元素的数量或FlowFiles内容的总大小(每个bin的最小和最大大小是用户指定的)并且还可以配置可选的Timeout属性,即FlowFiles等待其bin变为配置的上限值最大时间。
- SplitContent：将单个FlowFile拆分为可能的许多FlowFile,类似于SegmentContent。但是,对于SplitContent,不会在任意字节边界上执行拆分,而是指定要拆分内容的字节序列。

#### HTTP

- GetHTTP：将基于HTTP或HTTPS的远程URL的内容下载到NiFi中。处理器将记住ETag和Last-Modified Date,以确保不会持续摄取数据。
- ListenHTTP：启动HTTP（或HTTPS）服务器并侦听传入连接。对于任何传入的POST请求,请求的内容将作为FlowFile写出,并返回200响应。
- InvokeHTTP：执行用户配置的HTTP请求。此处理器比GetHTTP和PostHTTP更通用,但需要更多配置。此处理器不能用作源处理器,并且需要具有传入的FlowFiles才能被触发以执行其任务。
- PostHTTP：执行HTTP POST请求,将FlowFile的内容作为消息正文发送。这通常与ListenHTTP结合使用,以便在无法使用s2s的情况下在两个不同的NiFi实例之间传输数据（例如,节点无法直接访问并且能够通过HTTP进行通信时代理）。 注意：除了现有的RAW套接字传输之外,HTTP还可用作s2s传输协议。它还支持HTTP代理。建议使用HTTP s2s,因为它更具可扩展性,并且可以使用具有更好用户身份验证和授权的输入/输出端口的方式来提供双向数据传输。
- HandleHttpRequest / HandleHttpResponse：HandleHttpRequest Processor是一个源处理器,与ListenHTTP类似,启动嵌入式HTTP（S）服务器。但是,它不会向客户端发送响应（比如200响应）。相反,流文件是以HTTP请求的主体作为其内容发送的,所有典型servlet参数、头文件等的属性作为属性。然后,HandleHttpResponse能够在FlowFile完成处理后将响应发送回客户端。这些处理器总是彼此结合使用,并允许用户在NiFi中可视化地创建Web服务。这对于将前端添加到非基于Web的协议或围绕已经由NiFi执行的某些功能（例如数据格式转换）添加简单的Web服务特别有用。

### 使用属性

每个FlowFile都拥有多个属性,这些属性将在FlowFile的生命周期中发生变化。FlowFile的概念非常强大,并提供三个主要优点。

- 首先,它允许用户在流中做出路由决策,以便满足某些条件的FlowFiles可以与其他FlowFiles进行不同地处理。这可以由RouteOnAttribute和其他类似的处理器完成的。
- 其次,利用属性配置处理器：处理器的配置依赖于数据本身。例如,PutFile能够使用Attributes来知道每个FlowFile的存储位置,而每个FlowFile的目录和文件名属性可能不同（结合表达式语言,比如每个流都有filename属性,组件中就可以这样配置文件名：${filename},就可以获取到当前FlowFIle中filename的属性值）。
- 最后,属性提供了有关数据的极有价值的上下文。在查看FlowFile的Provenance数据时非常有用,它允许用户搜索符合特定条件的Provenance数据,并且还允许用户在检查Provenance事件的详细信息时查看此上下文。通过简单地浏览该上下文,用户能够知道为什么以这样或那样的方式处理数据。

#### 共同属性

每个FlowFile都有一组属性：

- filename：可用于将数据存储到本地或远程文件系统的文件名。
- path：可用于将数据存储到本地或远程文件系统的目录的名称。
- uuid：一个通用唯一标识符,用于区分FlowFile与系统中的其他FlowFiles。
- entryDate：FlowFile进入系统的日期和时间（即已创建）。此属性的值是一个数字,表示自1970年1月1日午夜（UTC）以来的毫秒数。
- lineageStartDate：任何时候克隆,合并或拆分FlowFile,都会导致创建子FlowFile。该值表示当前FlowFile最早的祖先进入系统的日期和时间。该值是一个数字,表示自1970年1月1日午夜（UTC）以来的毫秒数。
- fileSize：此属性表示FlowFile内容占用的字节数。

需要注意的是uuid,entryDate,lineageStartDate,和fileSize属性是系统生成的,不能改变。

#### 提取属性

NiFi提供了几种不同的处理器,用于从FlowFiles中提取属性。我们在之前的处理器分类中已经提到过。这是构建自定义处理器的一个非常常见的用例,其实编写处理器是为了理解特定的数据格式,并从FlowFile的内容中提取相关信息,创建属性来保存该信息,以便可以决定如何路由或处理数据。

#### 添加用户自定义的属性

NIFI除了提供能够将特定信息从FlowFile内容提取到属性中的处理器之外,NIFI还允许用户将自定义属性添加到每个FlowFile中的特定位置。UpdateAttribute就是专为此目的而设计。用户可以通过单击属性选项卡右上角的+按钮,在配置对话框中向处理器添加新属性。然后UI会提示用户输入属性的名称,然后输入值。对于此UpdateAttribute处理的每个FlowFile,都会添加用户自定义属性。Attribute的名称将与添加的属性的名称相同。

属性的值也可以包含表达式语言。这样就允许基于其他属性修改或添加属性。例如,如果我们想要将处理文件的主机名和日期添加到文件名之前,我们可以通过添加${hostname()}-${now():format('yyyy-dd-MM')}-${filename}来实现来实现。刚开始大家可能不太理解这是什么意思，在后续的课程中我们会进行讲解。

除了添加一组自定义的属性外,UpdateAttribute还具有一个高级UI,允许用户配置一组规则,以便在何时添加属性。要访问此功能,请在配置对话框的属性选项卡中,单击Advanced对话框底部的按钮。将弹出此处理器特定的UI界面。在此UI中,用户可以配置规则引擎,实质上是指定必须匹配的规则,以便将已配置的属性添加到FlowFile。

#### 属性路由

NiFi最强大的功能之一是能够根据属性路由FlowFiles。执行此操作的主要机制是RouteOnAttribute。此处理器与UpdateAttribute一样,通过添加用户自定义的属性进行配置。通过单击处理器的配置对话框中属性选项卡右上角的+按钮,可以添加任意数量的属性。

每个FlowFile的属性将与配置的属性进行比较,以确定FlowFile是否满足指定的条件。每个属性的值应该是一个表达式语言并返回一个布尔值。下面的【表达式语言/在Property值中使用attribute】会对表达式语言进行补充。

在评估针对FlowFile的属性提供的表达式语言之后,处理器根据所选的路由策略确定如何路由FlowFile。最常见的策略是"Route to Property name"策略。选择此策略后,处理器将为配置的每个属性公开关系(可拖拽出去指向下一个处理器)。如果FlowFile的属性满足给定的表达式,则FlowFile的副本将路由到相应的Relationship。例如,如果我们有一个名为"begin-with-r"的新属性和值"$ {filename：startsWith（'r'）}"的表达式,那么任何文件名以字母'r'开头的FlowFile将是路由到那个关系。所有其他FlowFiles将被路由到"unmatched"关系。

#### 表达式语言/在Property值中使用attribute

当我们从FlowFiles的内容中提取属性并添加用户定义的属性时,除非我们有一些可以使用它们的机制,否则它们不会作为运算符进行计算。NiFi表达式语言允许我们在配置流时访问和操作FlowFile属性值。并非所有处理器属性都允许使用表达式语言,但很多处理器都可以。为了确定属性是否支持表达式语言,用户可以将鼠标悬停在处理器配置对话框的属性选项卡中的![image.png](https://image.hyly.net/i/2025/09/28/594c8979fa269f1c002ea7d19b902a24-0.webp)图标上,然后会有一个提示,显示属性的描述,默认值（如果有)以及属性是否支持表达式语言。

对于支持表达式语言的属性,可以通过在 开始标记 ${ 和结束标记 } 中添加表达式来使用它。表达式可以像属性名一样简单。例如,要引用uuid Attribute,我们可以简单地使用 ${uuid}。如果属性名称以字母以外的任何字符开头,或者包含除数字,字母,句号（.）或下划线（_）以外的字符,则需要加引号。例如,${My Attribute Name} 将无效,但${'My Attribute Name'}将引用属性My Attribute Name。

除了引用属性值之外,我们还可以对这些属性执行许多功能和比较。例如,如果我们想检查filename属性是否不分大小写（大写或小写）地包含字母'r',我们可以使用表达式来完成${filename:toLower():contains('r')}。请注意,函数由冒号分隔。我们可以将任意数量的函数链接在一起,以构建更复杂的表达式。重要的是要明白,即使我们正在调用filename:toLower(),这也不会改变filename属性的值,而只是返回给我们一个新的值。

我们也可以在一个表达式中嵌入另一个表达式。例如,如果我们想要将attr1 Attribute 的值与attr2 Attribute的值进行比较,我们可以使用以下表达式来执行此操作：

```
${attr1:equals( ${attr2} )}。
```

表达式语言包含许多不同的函数,官方文档[Expression Language Guide](https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html)。

此外,此表达式语言指南内置于应用程序中,以便用户可以轻松查看哪些功能可用,并在输入时查看其文档。设置支持表达式语言的属性的值时,如果光标位于表达式语言的开始和结束标记内,则在关键字上按 Ctrl + Space 将弹出所有可用的函数(快捷键冲突被占用会无法使用此功能),并将提供自动填充的功能。单击或使用键盘上下键指向弹出窗口中列出的某个功能会有提示,提示解释了该功能的作用,它所期望的参数以及函数的返回类型。

#### 表达式语言中的自定义属性

除了使用FlowFile属性外,还可以定义表达式语言使用的自定义属性。定义自定义属性为处理和配置数据流提供了额外的灵活性。

### 使用模板

当我们使用处理器在NiFi中设计复杂的数据流处理流程时,我们经常会发现我们将相同的处理器序列串在一起以执行某些任务。这种情况下,NiFi提供了模板概念。模板可以被认为是可重用的子流。要创建模板,请按照下列步骤操作：

- 选择要包含在模板中的组件。我们可以通过单击第一个组件,然后按住Shift键同时选择其他组件（以包括这些组件之间的连接）,或者在画布上拖动所需组件周围的框时按住Shift键选择多个组件。
- 从操作面板中选择![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACEAAAAhCAMAAABgOjJdAAAAAXNSR0IArs4c6QAAAjdQTFRFADo7ADw9AEFCAEJDAENEAENFAERFAEVGAEZHAEdIAEhJAUhJAkpLA0pLBEVGBEtMBUpLBUxNBkhJBkxNB01OCU5PCU9PC09QDFBRDVJTDlJTH19gJGNkLWtsMGpsMGxuMWtsMWxtNG1uNG5vNHBxNW5vOHBxOXN0OnBxOnJzOnN0P3V2P3Z3Qnd4Q3l6Q3p7RHh5RHl7RHp8RXl6RXp7Rnp7Rnt8SHx9SXx9TX+BTYCBUYOEVoaIWIeIWYiJXIuMXYqLXouMXoyNYI2OYI2PZJCRZ5OUaJSVaZGSbZeYcZmacZqbcZucfKKkfqKkf6Kjf6Okf6Olf6Slgqamhaiqhamqhqiph6mqh6qrh6qsh6usiKqsiKysiautiqyui6qri6ytjKytjayuj66vkK+wka2uka+wkbCxk66vmLS1mLW2mLa3mbe4obu8o72+pL6/pb/Apr/Apr/Bp7+/p8DBqMHCrsXGsMbHssfIssfJtcrLt8zMuczNuc3Ous3Ou87Pu8/Qv9DRwNHSwdHTwdLSwdLTwtPUxdXWyNfYy9nay9razNrbzdvcztrbztvcztzdz9vc0N3d0N3e0d7e09/g1N/g1eDh1+Lj2OLj2ePk2uTl2+Tl2+Xm3ufo3+jp4urr5ezt5u3u6e/v7PHy7fHy7vLz7/P08vX28/b39Pb39Pf39ff49vj59/j59/n6+Pn6+fr7+vr7+vv7+vv8+/v8+/z9/Pz9/fz9/v3+/v7+/v7///7/////HbCzOQAAAapJREFUOMtj6O6bOAkf6GHonL9qBR6wfCpD54Ktm/GADdOAKjZvwAPWE69ixx4Y2I1dxbb+jDQISG3YjFXFLhcGJghgVFy5GasKR2YuCGBTWI5dhQMTJxAAVbDK4VDhzcfLy8vPwSoqpLcGq4pNi3u7u7snlBhaFy/ahd23W3YBwY496yrcgqbs3oUnxDbvWV/l7jt5957du3fv2YU9TLds7wyWd61ta21t6lqzEZuKXc0S4iLMPMKCggKS7buRVMDCfPOeSi4OTi6Q1zm4avYgVGwpD0tJjwhLKNmwp5KbExJ2nFy1SCo2atrwsHmGSmt77a7nYGYBAyauRiQV6y3KpLim79GfY++1rCA7BwyyipZtRlJhXijGXj1TdsEqy1J4OtizGcm3603rtGTUVYyW7IkL2YM1TNfrzt6za9tWoL7IaBwqDHoy/QIDA/xb4nCpMM9Tik9KTPawjYrFpSLXDuS2DqcYXCp0ws1mzJo5N9/KJxK7ii3OGsrGxsYm2qpqZTuxp4/Na9auBoG1a7fgylEbYQBLjlpIMN/OW7YUD1gyhaG7Ez/oBgAz53K4xytsNgAAAABJRU5ErkJggg==)图标。
- 提供模板的名称和描述。
- 单击Create按钮。

一旦我们创建了一个模板,我们就可以将它用作流程中的构建块,就像处理器一样。单击并将模板图标![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC0AAAAtCAMAAAANxBKoAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpMwidZAAAB41BMVEUAPz8AP0AAQEAAQEEAQUEAQkIAQkMAQ0MAQ0QAREQAREUARUUARUYARkYARkcAR0gASEkCSUoCSksDSksDS0wES0wFTE0GTU4JT1AJT1EKUFIUVlgaXF4bXV8cXWAdXF8eXWAhX2EiX2IkYmQlYmUmYmUmY2YoZGcpY2YpZGgpZWgrZGcrZWksZWgsZmkuaGsvam0waGwxaWwza244b3M8cXU+cnc/dHhBc3dBc3hBdHhCdXlDd3tEd3tEeHxFdntFeHxHeX1IeX1Jen5Je39Ke39Le4BLfIBMe4BNfIFRf4NSgIRXg4lZhIpZhYpahIpahYlahYpch41eiI1eiI5eiY5eio9fio9fipBhi5Bii5FkjZJkjpNskphtkZdtkphvlJpvlZtwlZtxlZt0l510mJ51l511mJ51mZ95mqB8naN/nqV/n6aAn6aBoKeDoaiGoqqGo6qHo6uKpayLpq2Lpq6Mp66OqK+QqrCQqrGRqrGSrLOWrbWfs7uftLugtbyjtr6kt7+muMCmuMGmucGnucGpusKpu8Oqu8Oru8Oru8SrvMSsvMSsvcWtvcWuvsauvsevvsavvsevv8ewvsewv8ewv8ixv8ixwMixwMmywMmywcmzwcmzwcq0wsq1wsu2w8uigbdhAAABl0lEQVRIx2PoIAUwDG3V3VOnIYOJeFV31ybHI4G4PLyqJwcys3MgAKtkTQ8e1f2OXAJIgF+0uA+famdU1WIlVFTthKYar0smeTFCPcgtwM/JwSZShU91X7WrDRjY6fFLmbvYRrV14oud3lmzwWBOe6axfvqEBd3ExXz35LY0XdXY5qndxKUTkHodtYQWbOqxpSqQem2NhFZM9djTYOecyZlGhimtM2dAQD9e1T2FASE+inxafv6+IOBf1INHdXerKjCV8QnwsEMAk0o3PtWN8nzIccsr045XtQKqallqqibFJV2tmizAFMYHTGBgwKLejTcES0PDImIMhNwjw4EgLLysB28J0Tdr3vxoudSps2eBQR+B8qS/wUypbCqRpc/USmWTuokEUlUvNF3MyJIPmjl3xrROfKr7KhwsrUDAVFza3trKwq+pC4/qyd4M0OzJzwck2AQK+vGo7vfgQMn6wjkT8an2RFOdS0XVbqiqBbPxqZ4SzMbJhQBsEuV9eFR312ckJiFAQj7+2OmeOh0JzJg4zGpAIgEARx2VTtoaSV0AAAAASUVORK5CYII=)从组件工具栏拖动到我们的画布上。然后,我们可以选择要添加到画布的模板,然后单击Add按钮。

最后,我们可以使用模板管理(Template Management )对话框来管理模板。要访问此对话框,请从全局菜单( Global Menu)中选择模板。在这里,我们可以看到存在哪些模板并设置过滤条件以找到感兴趣的模板。在表的右侧是一个图标,用于将模板导出或下载为XML文件。然后可以将其提供给其他人,以便他们可以复用模板。

要将模板导入NiFi实例,请上传模板 从操作选项板中选择上载模板![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAMAAABF0y+mAAAAAXNSR0IArs4c6QAAAcVQTFRFADk6ADs8ADw9AD9AAEBBAEFCAEJDAENEAERFAEVGAEZHAEdIAEhJAElKAUVGA0dIBUhJBk1OCE5PCUhJCk9QC1BRDVFSDlJUD1NUG1xeHFlaHFtcHFxdHV5fI15fJmVmKGZnKWdoKmdoLmprOW1tOW1uPXJzQXd3UYKEVISFVYWGVoWGWYiJWoiKXIqLXYqLX4uLX4yNZZCSbZaXcpiZcpmacpqbc5ucdJyddZ2efKGifKKjfaGjf6OkgKSlhKeohaSmhaeohqeoh6ipiqusi6ytjKytjK2uj66vj66wj6+wkK+wkbCylbO0m7W2m7e4nLW2nLi5nbi5obu8pL6/pb/Apr/AqMDCqMHCssjItMrLuMzOucrLuc3Pus3Ou8zNu83OvM3OvM7Pvc/QvdDRvs3OvtDRwtLTwtPTw9PUxdTVxtXWytjZytnaz93e0d7f0t7f0+Dg4err4urr4+rr5Ozt5+3u7vP07/Lz8PP08PT19vf49vj59vn59/b39/f49/j49/j5+Pf4+Pn6+fj5+fn6+fr7+vr7+vv8+/v8+/z8+/z9/Pz9/fz9/f39/f3+/vv8/v3+/v3//v7+/v7///7/////rcDkvwAAAX9JREFUKFN102VbwlAYgOGJSza7uxtbsRsTW+xCsANRsREEFY8ynVO23+sOIejw+Xrv2t6dvUMYivgnikFI7a4xbLtaEiH2xH/aIxDCKLrCJhr9yAeuDoOvZt0sTLfkkOOXKgKDoUnnrAz5CpyB0clnYbBcQRA4TpPxFjmyxtaOjs7KtNIxF5ChywMnFY41IybOI0Nvzx7O1D9o9r6WIEPpntM1WdV9PT3dm+wvBCwLWEscRuGRKIqU8aEIBI0a8KfJShqGVYQiEIdjcDV3kUopYWjVZxCBOBqrpMkWsDY3D5s7cQfxXRtNMowSawp8AC44LbeYnZFC04mZ6VOc/BBuru7aMUxlvb70wYOUYAg80y32olit6H7xwS+UJhpQKOpE8ENB5LoKi5sbG9pKiuqtTz5yOHg/vh5NTuiWVxcmxrddXoDxG/ifHeK9dH8r9baOha6mAHt7dDqddrvN9rGVgJBDO/4tNkjp9Sv7B74OZ/KQKIoMSfoJcnL95Rd8A6D3JrjqCjOCAAAAAElFTkSuQmCC),单击搜索图标并选择本地计算机上的文件。然后单击Upload按钮。模板将显示在您的表格中,您可以将其拖动到画布上,就像您创建的任何其他模板一样。

使用模板时需要记住一些重要注意事项：

- 任何标记为敏感属性的属性（例如在处理器中配置的密码）都不会添加到模板中。每次将模板添加到画布时,都必须填充这些敏感属性。
- 如果模板中包含的组件引用Controller Service,则Controller Service也将添加到模板中。这意味着每次将模板添加到图表时,它都会创建Controller Service的副本。

### 监控NiFi

当数据在NiFi中流经您的数据流处理流程时,了解您的系统执行情况以评估您是否需要更多资源以及评估当前资源的运行状况非常重要。NiFi提供了一些监控系统的机制。

#### 状态栏

在组件工具栏下的NiFi屏幕顶部附近有一个条形,称为状态栏。它包含一些关于NiFi当前健康状况的重要统计数据。活动线程的数量可以指示NiFi当前的工作状态,排队统计数据表示当前在整个流程中排队的FlowFile数量以及这些FlowFiles的总大小。

如果NiFi实例位于群集中,我们还会在此处看到一个指示器,告诉我们群集中有多少节点以及当前连接的节点数。在这种情况下,活动线程的数量和队列大小指示当前连接的所有节点的所有总和。

#### 组件统计

画布上的每个处理器,进程组(Group)和远程进程组都提供了有关组件处理了多少数据的若干统计信息。这些统计信息提供有关在过去五分钟内处理了多少数据的信息。这是一个滚动窗口,允许我们查看处理器消耗的FlowFiles数量,以及处理器发出的FlowFiles数量。

处理器之间的连接还会显示当前排队的项目数。

查看这些指标的历史值以及（如果是群集的）不同节点相互比较也可能很有价值。我们可以右键单击组件并选择Stats菜单项查看此信息,nifi会向我们展示一个图表,该图表涵盖自NiFi启动以来的时间,或最多24小时,以较少者为准（通过更改属性文件中的配置,可以扩展或减少此处显示的时间量）

在此对话框的右上角有一个下拉列表,允许用户选择他们正在查看的指标。底部的图表允许用户选择图表的较小部分进行放大。

#### 公告

除了为每个组件提供的统计信息之外,用户还想知道流程是否出现问题。虽然我们可以监视日志中的任何内容,但在屏幕上弹出通知会更方便。如果处理器将日志级别设置为WARNING或ERROR,我们将在处理器的右上角看到"Bulletin Indicator"。此指示器看起来像一个粘滞便笺,将在事件发生后持续显示五分钟。将鼠标悬停在公告上可提供有关所发生情况的信息,以便用户无需筛选日志消息即可查找。如果是在集群中,公告还会指示是集群中的哪个节点发布了公告。我们还可以在处理器的"配置"对话框的"设置"选项卡中更改公告的日志级别。

如果框架发布了公告,我们还会在屏幕右上方突出显示公告指示符。在全局菜单中是公告板选项(Bulletin Board)。单击此选项我们将看到公告板,在那里我们可以看到NiFi实例中出现的所有公告,并可以根据组件,消息等进行过滤。

### 数据来源

NiFi对其摄取的每个数据保持非常精细的细节。当数据通过系统处理并被转换,路由,拆分,聚合和分发到其他端点时,这些信息都存储在NiFi的Provenance Repository中。为了搜索和查看此信息,我们可以从全局菜单中选择数据源(Data Provenance)。会弹出一个表格,列出我们搜索过的Provenance事件：

![image.png](https://image.hyly.net/i/2025/09/28/d880f1027bbd13c398290f07ab6763a9-0.webp)

此表列出了最近发生的1,000个Provenance事件（尽管事件发生后可能需要几秒钟才能处理信息）。在此对话框中,有一个Search按钮,允许用户搜索特定处理器发生的事件,按文件名或UUID或其他几个字段搜索特定的FlowFile。在nifi.properties文件中提供了配置这些属性中的哪些属性可编入索引或可作搜索条件的功能。此外,配置文件还允许您指定将被索引的FlowFile属性。因此,您可以指定哪些属性对您的特定数据流很重要,并使这些属性可搜索。

#### 事件详情

一旦我们执行了搜索,我们的表格将仅展示与搜索条件匹配的事件。在这里,我们可以选择细节图标![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAnpJREFUOBGtU0toE1EUPTNpkzQfNB+02JYKIh3RRexGsUFM0oVI6sIqtOiu/sBPu3GjG91VQShFMPWzdCPGYomU4EIsaoUWKqKgILYpkZI2wTSW/JPnfZO2zJhossiBzHuZd++5951zR2AE1BFiHblkqroTNvyvw8XlZbyam8OnH/MoFIvY296O7v0O7G5p+WeaUEnDXKGAkfFx3H3mRyQWg6uzEw0akcg/wmY04ILXixv9/TDodOXEnFAJ6oQN+cYYXG4GTzfbevIUy+XzckjHwFkGt4fhiIudvn2HpbNZZaq8L7vy87fvMOL3A1qtXD2+msC1R4+ha2xEJB4HaOV4EgzioCTh8vEe+f/GQ2UKdYLRiRcA6cVh0OsxcOwoEskkwtEo8iSFDEEARBH3AwGspVKld+tPVYchMuHzQgjQaAAaT6vJjIdXByGIAviw7jl3Ht9C6+dE+H1pCV9CizggdWySqjqM0vWS6TTAO6BfLLGKKz4fSCukMhmqofgG6DxLsVGKUUJFaNLroOUa8URKSFHCg8lJJImMSpASJSk2CESKNZEsSqgIdzY3o9Vu29RQoGu12u3Q0CpQAavZLO9lAiLfbrGUzaSK0NTUhDNuD0DmcGO2Wax4PTyMLUYj9OR64NZNSDTc8nkuh96uQ9hhowYUUJnC31/q8SI4O4upmRnkCnnMRyL4tfZbNoVrmSEi0LqPRuZ6X5+CqrSt+KWEV1ZwcfQeXk6/L0XRlWWjCqQhK+Kww4GxoUFIbW21EfIo3snE9Ac8nXqDr+GfKJJRu0jjXmcXTjidMJM8lVCxw78Dubt8YLg51VATYTUS5Xn1ksroGvZ1J/wDgWQb5B0ivq0AAAAASUVORK5CYII=)来查看该事件的详细信息：

![image.png](https://image.hyly.net/i/2025/09/28/b333fa21895e4640e87354ebda8e50d4-0.webp)

在这里,我们可以确切地看到该事件发生的时间,事件影响的FlowFile,事件执行的组件（处理器等）,事件花费的时间以及事件发生时NiFi数据的总体时间（总潜伏期）。

下一个选项卡提供事件发生时FlowFile上存在的所有属性的列表：

![image.png](https://image.hyly.net/i/2025/09/28/0936ce17638da38f4dae77f963cb74fb-0.webp)

在这里,我们可以看到事件发生时FlowFile上存在的所有属性,以及这些属性的先前值。我们可以知道哪些属性因此事件而发生变化以及它们如何变化。此外,在右侧角是一个复选框,允许用户仅查看那些已更改的属性。如果FlowFile只有少量属性,这可能不是特别有用,但当FlowFile有数百个属性时,它可能非常有用。

这非常重要,因为它允许用户理解FlowFile处理的确切上下文,对理解FlowFile的处理逻辑是有帮助的,特别是在使用表达式语言配置处理器时。

最后,还有Content选项卡：

![image.png](https://image.hyly.net/i/2025/09/28/d8a0b794c238d32fa75bcba545ff6ed0-0.webp)

此选项卡向我们提供有关存储FlowFile content的内容存储库位置的信息。如果事件修改了FlowFile的内容,我们将看到'input claim和'outputclaim'。如果数据格式是NiFi了可以识别的可以呈现的数据格式,我们可以选择下载或查看NiFi内部的内容。

此外,在选项卡的重播部分,有一个Replay按钮,允许用户将FlowFile重新插入到流中,并从事件发生的时间点重新处理它。这提供了一种非常强大的机制,因为我们能够实时修改流程,重新处理FlowFile,然后查看结果。如果它们不符合预期,我们可以再次修改流程,并再次重新处理FlowFile。我们能够执行流程的迭代开发,直到它完全按照预期处理数据。

#### 谱系图

除了查看Provenance事件的详细信息之外,我们还可以通过单击视图中的Lineage图标![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAVCAMAAAB1/u6nAAAAAXNSR0IArs4c6QAAAPBQTFRFAEhJAElKAEpMAEtNAExOAU1PAk1PA09QBVBRClNUC1RVDlVWD1ZXEFdZE1haE1lbFlpcF1tcGFxdIGFiIWFiImJjJmVnJ2ZoKWdpKmhqMm5vOXFyOnNzPnZ2SX1/S3+ATYCAUIKDUoSFXYyMY4+QapSVa5SVbJWWbZeXeJ6efKGifaKjhaioiauriqusmLW2nbm5oby8pL+/pb+/qcLDtcrLuc3Nus7OzNra0N3d0t7f09/f1ODg2uTk2+Xl3ebm4+vr5+7u6/Dw6/Hx8PT08fX19ff39fj49/n5+Pn5+/z8/P39/f39/v7+/v//////XtBTeQAAAJZJREFUGNNj8McKGKgt7Gtj54sp7CPHwCjvjSFswGRqxmyIIazL6enFr4MhbMkmJcNii2mlioSCkIuvH5qwu6Cjv4YQt5IzsrCbkaqyv6+4iCavIpKwqzATo6SLI4OxvxYnkrAeu70Fo743n6yJmDSSsDaPhxOrrr85D6OoFZKwLYcAD5e9v7+Xgy+KS6zV1axpGN5IAAA6838q+wMlWAAAAABJRU5ErkJggg==)来查看所涉及的FlowFile的血缘关系。

这为我们提供了一个图形表示,说明了在遍历系统时该数据发生了什么：

![image.png](https://image.hyly.net/i/2025/09/28/e8a64aeb28603cbb48f15bbeb709919c-0.webp)

在这里,我们可以右键单击任何事件,然后单击View Details菜单项以查看【事件详情】。此图形表示向我们准确显示了数据发生的事件。有一些"特殊"事件类型需要注意。如果我们看到JOIN,FORK或CLONE事件,我们可以右键单击并选择Find Parents或Expand。这允许我们查看父FlowFiles和创建的子FlowFiles的血缘关系。

左下角的滑块允许我们查看这些事件发生的时间。通过左右滑动,我们可以看到哪些事件花费了较长的时间,这样我们可以分析瓶颈,得知哪些节点需要更多资源,例如配置处理器的并发任务数。它也可能揭示其他信息,例如,大多数延迟是由JOIN事件引入的,我们在等待更多的FlowFiles连接在一起。在任何一种情况下,都能够轻松查看数据处理发生的位置是一项非常强大的功能,可帮助用户了解企业的运营方式。

### 常见问题

#### Q1 是不是组件每种连接关系(suceess和failure等)都要有所对应？

首先NIFI是基于流式处理数据，那么数据就会有移动方向，连接关系就是帮助我们路由数据的。简单的我们可以把一个组件的连接关系连向下一个组件，但有的时候我们不关心某些连接，比如说failure、original等等，我们可以通过如下图设置而不用将他们连接到别的组件。

![image.png](https://image.hyly.net/i/2025/09/28/9bed7a18285dbd549060f2b612286118-0.webp)

#### Q2 组件已经正常运行了，右上角怎么还在报错？

组件右上角的报错信息是默认存在一段时间的，报错信息都是有时间戳的，可以根据时间戳来判断报错信息是否是正在发生的。

#### Q3 为啥用Select组件查询出来的数据都是重复的？

每个组件都有几种调度触发方式，常见的有

- 每隔一段时间执行一次
- 特定时间执行一次
- 上游有数据就立刻执行

那么新手遇到的这种问题应该就是调度问题了，想做的是一次性查询，但是默认的调度执行了很多次

## Nifi深入学习

NiFi集群的部署和使用

FlowFile生成器案例

NiFi模版案例

FlowFile的深入学习和实践

NiFi表达式语言实践

NiFi监控功能的深入学习和实践

NiFi连接与关系的深入学习和实践

### 术语

**DataFlow Manager**：DataFlow Manager(DFM)是NiFi用户,具有添加,删除和修改NiFi数据流组件的权限。

**FlowFile**：FlowFile代表NiFi中的单个数据。FlowFile由两个组件组成：FlowFile属性(attribute)和FlowFile内容(content)。内容是FlowFile表示的数据。属性是提供有关数据的信息或上下文的特征,它们由键值对组成。所有FlowFiles都具有以下标准属性：

- uuid：一个通用唯一标识符,用于区分FlowFile与系统中的其他FlowFiles
- filename：在将数据存储到磁盘或外部服务时可以使用的可读文件名
- path：在将数据存储到磁盘或外部服务时可以使用的分层结构值,以便数据不存储在单个目录中

**Processor**：处理器是NiFi组件,用于监听传入数据、从外部来源提取数据、将数据发布到外部来源、路由,转换或提取FlowFiles。

**Relationship**：每个处理器都为其定义了零个或多个关系。命名这些关系以指示处理FlowFile的结果含义。处理器处理完FlowFile后,它会将FlowFile路由(传输)到其中一个关系。DFM能够将每一个关系连接到其他组件,以指定FlowFile应该在哪里进行下一步处理。

**Connection**：DFM通过将组件从NiFi工具栏的Components部分拖动到画布,然后通过Connections将组件连接在一起来创建自动的数据处理流程。每个连接由一个或多个关系组成。对于每个Connection,DFM都可以为其确定使用哪些关系。这样我们可以基于其处理结果的不同来以不同的方式路由数据。每个连接都包含一个FlowFile队列。将FlowFile传输到特定关系时,会将其添加到属于当前Connection的队列中。

**Controller Service**：控制器服务是扩展点,在用户界面中由DFM添加和配置后,将在NiFi启动时启动,并提供给其他组件(如处理器或其他控制器服务)需要的信息。常见Controller Service比如StandardSSLContextService,它提供了一次配置密钥库和/或信任库属性的能力,并在整个应用程序中重用该配置。我们的想法是,控制器服务不是在每个可能需要它的处理器中配置这些信息,而是根据需要为任何处理器提供。

**Funnel**：漏斗是一个NiFi组件,用于将来自多个Connections的数据合并到一个Connection中。

**Process Group**：当数据流变得复杂时,在更高,更抽象的层面上推断数据流是很有用的。NiFi允许将多个组件(如处理器)组合到一个过程组中。然后,DFM可以在NiFi用户界面轻松地将多个流程组连接到逻辑数据处理流程中,DFM还可以进入流程组查看和操作流程组中的组件。

**Port**：使用一个或多个进程组构建的数据流需要一种方法将进程组连接到其他数据流组件。这是通过使用Ports实现的。DFM可以向进程组添加任意数量的输入端口和输出端口,并相应地命名这些端口。

**Remote Process Group**：正如数据传输进出进程组一样,有时需要将数据从一个NiFi实例传输到另一个NIFI实例。虽然NiFi提供了许多不同的机制来将数据从一个系统传输到另一个系统,但是如果将数据传输到另一个NiFi实例,远程进程组通常是实现此目的的最简单方法。

**Bulletin**：NiFi用户界面提供了大量有关应用程序当前状态的监视和反馈。除了滚动统计信息和为每个组件提供的当前状态之外,组件还能够报告公告。每当组件报告公告时,该组件上都会显示公告图标(处理器右上角红色的图标)。系统级公告显示在页面顶部附近的状态栏上。使用鼠标悬停在该图标上将提供一个工具提示,显示公告的时间和严重性(Debug, Info, Warning, Error)以及公告的消息。也可以在全局菜单中的公告板页面中查看和过滤所有组件的公告。

**Template**：通常,DataFlow由许多可以重用的组件组成。NiFi允许DFM选择DataFlow的一部分(或整个DataFlow)并创建模板。此模板具有名称,然后可以像其他组件一样拖动到画布上。最终,可以将若干组件组合在一起以形成更大的构建块,然后从该构建块创建数据流处理流程。这些模板也可以导出为XML并导入到另一个NiFi实例中,从而可以共享这些构建块。

**flow.xml.gz**：DFM放入NiFi用户界面画布的所有内容都实时写入一个名为flow.xml.gz的文件。该文件默认位于conf目录中。在画布上进行的任何更改都会自动保存到此文件中,而无需用户单击保存按钮。此外,NiFi在更新时会自动在归档目录中创建此文件的备份副本。您可以使用这些归档文件来回滚配置,如果想要回滚,先停止NiFi,将flow.xml.gz替换为所需的备份副本,然后重新启动NiFi。在集群环境中,停止整个NiFi集群,替换其中一个节点的flow.xml.gz,删除自其他节点的flow.xml.gz,然后重新启动该节点。确认此节点启动为单节点集群后,然后启动其他节点。替换的流配置将在集群中同步。flow.xml.gz的名称和位置以及自动存档行为是可配置的。

### Linux配置优化

如果您在Linux上运行，请考虑这些最佳实践。典型的Linux默认设置不一定能够满足像NiFi这样的IO密集型应用程序的需求。对于这些最佳实践，NIFI所在的Linux发行版的实际情况可能会有所不同，可以参考下面的介绍，但是请参考特定发行版的文档。

**最大文件句柄(Maximum File Handles)**

NiFi在任何时候都可能会打开非常大量的文件句柄。通过编辑 */etc/security/limits.conf* 来增加限制，添加类似的内容

> ```text
> * hard nofile 50000
> * soft nofile 50000
> ```

**最大派生进程数(Maximum Forked Processes)**

NiFi可以配置生成大量的线程。要增加Linux允许的数量，请编辑 */etc/security/limits.conf*

> ```text
> *  hard  nproc  10000
> *  soft  nproc  10000
> ```

你的发行版Linux可能需要通过添加来编辑 */etc/security/limits.d/20-nproc.conf*

> ```text
> * soft nproc 10000
> ```

**增加可用的TCP套接字端口数(Increase the number of TCP socket ports available)**

如果你的流程会在很短的时间内设置并拆除大量socket，这一点尤为重要。

> ```text
> sudo sysctl -w net.ipv4.ip_local_port_range ="10000 65000"
> ```

**设置套接字在关闭时保持TIMED_WAIT状态的时间(Set how long sockets stay in a TIMED_WAIT state when closed)**

考虑到你希望能够快速设置和拆卸新套接字，你不希望您的套接字停留太长时间。最好多阅读一下并调整类似的东西

> ```text
> sudo sysctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait ="1"
> ```

**告诉Linux你永远不希望NiFi交换(Tell Linux you never want NiFi to swap)**

对于某些应用程序来说，swapping非常棒。对于像NiFi一样想要运行的程序并不好。要告诉Linux你想关掉swapping，你可以编辑 */etc/sysctl.conf* 来添加以下行

> ```text
> vm.swappiness = 0
> ```

对于处理各种NiFi repos的分区，请关闭诸如 `atime`之类的选项。这样做会导致吞吐量的惊人提高。编辑 `/etc/fstab`文件，对于感兴趣的分区，添加 `noatime`选项。

比如我要在根文件系统使用noatime，可以编辑/etc/fstab文件，如下：

> ```text
> /dev/mapper/centos-root /      xfs     defaults,noatime        0 0
> UUID=47f23406-2cda-4601-93b6-09030b30e2dd /boot     xfs     defaults        0 0
> /dev/mapper/centos-swap swap     swap    defaults        0 0
> ```

修改后重新挂载

> ```text
> mount -o remount /
> 或者 mount -o remount /boot
> ```

### NIFI集群

#### 为什么集群？

DFM可能会发现在单个服务器上使用一个NiFi实例不足以处理他们拥有的数据量。因此，一种解决方案是在多个NiFi服务器上运行相同的数据流。但是，这会产生管理问题，因为每次DFM想要更改或更新数据流时，他们必须在每个服务器上进行这些更改，然后逐个监视每个服务器。而集群NiFi服务器，可以增加处理能力同时，支持单接口控制，通过该接口可以更改整个集群数据流并监控数据流。集群允许DFM只进行一次更改，然后将更改的内容复制到集群的所有节点。通过单一接口，DFM还可以监视所有节点的健康状况和状态。

![image.png](https://image.hyly.net/i/2025/09/28/aff55bfade2aedd8586b7eae7139a5c1-0.webp)

#### 零主集群

NiFi采用Zero-Master Clustering范例。集群中的每个节点都对数据执行相同的任务，但每个节点都在不同的数据集上运行。其中一个节点自动被选择(通过Apache ZooKeeper)作为集群协调器。然后，集群中的所有节点都会向此节点发送心跳/状态信息，并且此节点负责断开在一段时间内未报告任何心跳状态的节点。此外，当新节点选择加入集群时，新节点必须首先连接到当前选定的集群协调器，以获取最新的流。如果集群协调器确定允许该节点加入(基于其配置的防火墙文件)，则将当前流提供给该节点，并且该节点能够加入集群，假设节点的流副本与集群协调器提供的副本匹配。如果节点的流配置版本与集群协调器的版本不同，则该节点将不会加入集群。

#### 术语

NiFi Clustering是独一无二的，有自己的术语。在设置集群之前了解以下术语非常重要：

**NiFi集群协调器(NiFi Cluster Coordinator)**：NiFi集群协调器是NiFi集群中的节点，负责管理集群中允许执行任务的节点，并为新加入的节点提供最新的数据流量。当DataFlow Manager管理集群中的数据流时，可以通过集群中任何节点的用户界面执行此操作。然后，所做的任何更改都将复制到集群中的所有节点。

**节点(Nodes)**：每个集群由一个或多个节点组成。节点执行实际的数据处理。

**主节点(Primary Node)**：每个集群都有一个主节点。在此节点上，可以运行"隔离处理器"(见下文)。ZooKeeper用于自动选择主节点。如果该节点由于任何原因断开与集群的连接，将自动选择新的主节点。用户可以通过查看用户界面的"集群管理"页面来确定当前选择哪个节点作为主节点。

![image.png](https://image.hyly.net/i/2025/09/28/f94ed214215b45df4e01b4ca6a572ab9-0.webp)

**孤立的Processor**：在NiFi集群中，相同的数据流会在所有节点上运行。但是，可能存在DFM不希望每个处理器在每个节点上运行的情况。最常见的情况是使用的处理器存在与外部服务进行通信得的情况。例如，GetSFTP处理器从远程目录中提取。如果GetSFTP处理器在集群中的每个节点上运行并同时尝试从同一个远程目录中提取，则可能存在重复读取。因此，DFM可以将主节点上的GetSFTP配置为独立运行，这意味着它仅在该节点上运行。通过适当的数据流配置，它可以提取数据并在集群中的其余节点之间对其进行负载平衡。注意，虽然存在此功能，但仅使用独立的NiFi实例来提取数据并将其输出内容分发给集群也很常见。它仅取决于可用资源以及管理员配置集群的方式。

**心跳**：节点通过"心跳"将其健康状况和状态传达给当前选定的集群协调器，这使协调器知道它们仍然处于连接状态并正常工作。默认情况下，节点每5秒发出一次心跳，如果集群协调器在40秒内没有从节点收到心跳，则由于"缺乏心跳"而断开节点。5秒设置可在_nifi.properties_文件中配置。集群协调器断开节点的原因是协调器需要确保集群中的每个节点都处于同步状态，并且如果没有定期收听到节点，协调器无法确定它是否仍与其余节点同步。如果在40秒后节点发送新的心跳，协调器将自动把请求节点重新加入集群。一旦接收到心跳，由于心跳不足导致的断开连接和重新连接信息都会报告给用户界面中的DFM。

#### 集群安装

环境基础

　　　　1、系统：CentOS 7.4

　　　　2、Java环境：JDK8

##### 使用NiFi集成的zookeeper

NiFi依赖于ZooKeeper以实现集群配置。但是，在有些环境中，部署了NiFi，而没有维护现有的ZooKeeper集合。为了避免强迫管理员维护单独的ZooKeeper实例的负担，NiFi提供了嵌入式ZooKeeper服务器的选项。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' ><strong>属性</strong></th><th style='text-align:left;' ><strong>描述</strong></th></tr></thead>
<tbody><tr><td style='text-align:left;' ><code>nifi.state.management.embedded.zookeeper.start</code></td><td style='text-align:left;' >指定此NiFi实例是否应运行嵌入式ZooKeeper服务器</td></tr><tr><td style='text-align:left;' ><code>nifi.state.management.embedded.zookeeper.properties</code></td><td style='text-align:left;' >如果 <code>nifi.state.management.embedded.zookeeper.start</code>设置为 <code>true</code>,则要提供使用的ZooKeeper属性的属性文件</td></tr></tbody>
</table></figure>

通过设置 *nifi.properties* 中的 `nifi.state.management.embedded.zookeeper.start`属性为 `true`来运行嵌入式的ZooKeeper服务器。

通常建议在3或5个节点上运行ZooKeeper。在少于3个节点上运行可在遇到故障时提供较低的耐用性。在超过5个节点上运行通常会产生不必要的网络流量。此外，在4个节点上运行ZooKeeper并不会比在3个节点上运行有优势，ZooKeeper要求大多数节点处于活动状态才能运行。

如果 `nifi.state.management.embedded.zookeeper.start`属性设置为 `true`，则 *nifi.properties* 中的 `nifi.state.management.embedded.zookeeper.properties`属性也需要设置。它用来指定要使用的ZooKeeper属性文件。这个属性文件至少需要配置ZooKeeper的服务器列表。另注意，由于ZooKeeper将侦听这些端口，因此可能需要将防火墙配置为打开这些端口。默认值为 `2181`，但可以通过_zookeeper.properties_文件中的_clientPort_属性进行配置。

使用嵌入式ZooKeeper时，/ _conf / zookeeper.properties_文件具有名为 `dataDir`的属性。默认情况下，此值为 `./state/zookeeper`。如果多个NiFi节点正在运行嵌入式ZooKeeper，则必须告知服务器它是哪一个。通过创建名为_myid_的文件 并将其放在ZooKeeper的数据目录中来实现。此文件的内容应该是不同服务器的唯一索引值。因此，对于某一个ZooKeeper服务器，我们将通过执行以下命令来完成此任务:

```text
cd $NIFI_HOME
mkdir state
mkdir state/zookeeper
echo 1 > state/zookeeper/myid
```

对于将运行ZooKeeper的下一个NiFi节点，我们可以通过执行以下命令来实现此目的:

```text
cd $NIFI_HOME
mkdir state
mkdir state/zookeeper
echo 2 > state/zookeeper/myid
```

我们采用三个节点的集群，且在一台机器上搭建，所以不同节点的端口会不同，如果搭建在三台机器上，IP不同，那么端口可以相同。

**1、上传并解压**

上传资料中提供的nifi-1.9.2-bin.tar.gz文件到服务器的/export/download目录下，并进行解压：

```shell
tar -zxvf nifi-1.9.2-bin.tar.gz
```

移动并复制，共三个副本。

```
mv nifi-1.9.2 ../soft/nifi-1.9.2-18001
cd ../soft
cp -r nifi-1.9.2-18001/ nifi-1.9.2-18002
cp -r nifi-1.9.2-18001/ nifi-1.9.2-18003
```

![image.png](https://image.hyly.net/i/2025/09/28/8512b7c6e60fe03e23c377cc12a597f8-0.webp)

**2、编辑实例中，conf/zookeeper.properties文件，不同节点改成对应内容，内容如下：**

```properties
# zk客户端连接接口：1节点12181，2节点12182，1节点12183
clientPort=12181
# 不同服务的IP和选举端口号
server.1=192.168.52.150:12888:13888
server.2=192.168.52.150:14888:15888
server.3=192.168.52.150:16888:17888
```

**3、在单个实例中新建文件夹，${NIFI_HOME}/state/zookeeper，在此文件夹中新建文件myid，且输入内容如下：**

```tex
1
```

**4、编辑节点conf/nifi.properties文件，修改内容如下：**

```properties
####################
# State Management #
####################
nifi.state.management.configuration.file=./conf/state-management.xml
nifi.state.management.provider.local=local-provider
nifi.state.management.provider.cluster=zk-provider
#  指定此NiFi实例是否应运行嵌入式ZooKeeper服务器，默认是false
nifi.state.management.embedded.zookeeper.start=true

nifi.state.management.embedded.zookeeper.properties=./conf/zookeeper.properties 

# web properties #   
nifi.web.war.directory=./lib
# HTTP主机。默认为空白
nifi.web.http.host=192.168.52.150
# HTTP端口。默认值为8080；修改为18001、18002、18003
nifi.web.http.port=18001

# cluster node properties (only configure for cluster nodes) #   
# 如果实例是群集中的节点，请将此设置为true。默认值为false
nifi.cluster.is.node=true 
# 节点的完全限定地址。默认为空白
nifi.cluster.node.address=192.168.52.150
# 节点的协议端口。默认为空白，修改为：28001、28002、28003
nifi.cluster.node.protocol.port=28001

# 指定在选择Flow作为“正确”流之前等待的时间量。如果已投票的节点数等于nifi.cluster.flow.election.max.candidates属性指定的数量，则群集将不会等待这么长时间。默认值为5 mins
nifi.cluster.flow.election.max.wait.time=1 mins 
# 指定群集中所需的节点数，以便提前选择流。这允许群集中的节点避免在开始处理之前等待很长时间，如果我们至少达到群集中的此数量的节点
nifi.cluster.flow.election.max.candidates=1

# cluster load balancing properties #  
nifi.cluster.load.balance.host=
# 修改为：16342、26342、36342
nifi.cluster.load.balance.port=16342

# zookeeper properties, used for cluster management # 
# 连接到Apache ZooKeeper所需的连接字符串。这是一个以逗号分隔的hostname：port对列表
nifi.zookeeper.connect.string=192.168.52.150:12181,192.168.52.150:12182,192.168.52.150:12183
nifi.zookeeper.connect.timeout=3 secs  
nifi.zookeeper.session.timeout=3 secs   
nifi.zookeeper.root.node=/nifi
```

　	节点2，节点3内容跟节点1相同，只是nifi.web.http.port，nifi.cluster.node.protocol.port，nifi.cluster.load.balance.port，这三个端口区分开来，避免端口重复

**5、编辑实例conf/state-management.xml文件，内容如下：**

```xml
<cluster-provider>
    <id>zk-provider</id>
    <class>
        org.apache.nifi.controller.state.providers.zookeeper.ZooKeeperStateProvider
    </class>
    <property name="Connect String">
        192.168.52.150:12181,192.168.52.150:12182,192.168.52.150:12183
    </property>
    <property name="Root Node">/nifi</property>
    <property name="Session Timeout">10 seconds</property>
    <property name="Access Control">Open</property>
</cluster-provider>
```

6、启动三个实例，浏览器输入：192.168.52.150:18001，访问即可

![image.png](https://image.hyly.net/i/2025/09/28/24b35c1849d9cde794a0f1eb3b51f336-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/3e7f10e439c211a056b52da401363d4d-0.webp)

##### 使用外部zookeeper

**1、安装启动集群Zookeeper**

**2、准备三个单机NIFI实例**

**3、实例中，conf/zookeeper.properties文件，可以不用编辑**

**4、编辑节点conf/nifi.properties文件**

```properties
####################
# State Management #                     
####################
nifi.state.management.configuration.file=./conf/state-management.xml   
nifi.state.management.provider.local=local-provider  
nifi.state.management.provider.cluster=zk-provider
#  指定此NiFi实例是否应运行嵌入式ZooKeeper服务器，默认是false  
# 连接外部的时候，设置为false
nifi.state.management.embedded.zookeeper.start=false  
nifi.state.management.embedded.zookeeper.properties=./conf/zookeeper.properties 

# web properties #   
nifi.web.war.directory=./lib  
# HTTP主机。默认为空白   
nifi.web.http.host=192.168.52.150
# HTTP端口。默认值为8080
nifi.web.http.port=18001

# cluster node properties (only configure for cluster nodes) #   
# 如果实例是群集中的节点，请将此设置为true。默认值为false
nifi.cluster.is.node=true 
# 节点的完全限定地址。默认为空白
nifi.cluster.node.address=192.168.52.150
# 节点的协议端口。默认为空白
nifi.cluster.node.protocol.port=28001

# 指定在选择Flow作为“正确”流之前等待的时间量。如果已投票的节点数等于nifi.cluster.flow.election.max.candidates属性指定的数量，则群集将不会等待这么长时间。默认值为5 mins
nifi.cluster.flow.election.max.wait.time=1 mins 
# 指定群集中所需的节点数，以便提前选择流。这允许群集中的节点避免在开始处理之前等待很长时间，如果我们至少达到群集中的此数量的节点
nifi.cluster.flow.election.max.candidates=1

# cluster load balancing properties #  
nifi.cluster.load.balance.host=
nifi.cluster.load.balance.port=16342

# zookeeper properties, used for cluster management # 
# 连接到Apache ZooKeeper所需的连接字符串。这是一个以逗号分隔的hostname：port对列表
# 连接外部的时候使用外部ZooKeeper连接地址
nifi.zookeeper.connect.string=192.168.52.150:12181,192.168.52.150:12182,192.168.52.150:12183
nifi.zookeeper.connect.timeout=3 secs  
nifi.zookeeper.session.timeout=3 secs   
nifi.zookeeper.root.node=/nifi
```

**5、编辑实例conf/state-management.xml文件，内容如下：**

```xml
<cluster-provider>   
    <id>zk-provider</id>  
    <class>
        org.apache.nifi.controller.state.providers.zookeeper.ZooKeeperStateProvider
    </class>
    <!-- 使用外部zookeeper连接地址 --> 
    <property name="Connect String">
        192.168.52.150:12181,192.168.52.150:12182,192.168.52.150:12183
    </property>   
    <property name="Root Node">/nifi</property>   
    <property name="Session Timeout">10 seconds</property>
    <property name="Access Control">Open</property>
</cluster-provider>
```

6、启动三个实例，浏览器输入：192.168.52.150:18001，访问即可

#### 故障排除

如果遇到问题并且您的集群无法按照描述运行，请调查 节点上的_nifi-app.log_和_nifi-user.log_文件。如果需要，可以通过编辑 `conf/logback.xml`文件将日志记录级别更改为DEBUG 。具体来说，设置 `level="DEBUG"`以下行(而不是 `"INFO"`):

```xml
<logger name="org.apache.nifi.web.api.config" level="INFO" additivity="false">				<appender-ref ref="USER_FILE"/>
</logger>
```

#### State管理

NiFi为处理器，报告任务，控制器服务和框架本身提供了一种机制来保持状态。例如，允许处理器在重新启动NiFi后从其停止的位置恢复。处理器可以从集群中的所有不同节点访问它的状态信息。

##### 配置状态提供程序

当组件决定存储或检索状态时，有两种实现：节点本地或集群范围。在 *nifi.properties* 文件包含有关配置项。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' ><strong>属性</strong></th><th style='text-align:left;' ><strong>描述</strong></th></tr></thead>
<tbody><tr><td style='text-align:left;' ><code>nifi.state.management.configuration.file</code></td><td style='text-align:left;' >第一个是指定外部XML文件的属性，该文件用于配置本地和/或集群范围的状态提供程序。此XML文件可能包含多个提供程序的配置</td></tr><tr><td style='text-align:left;' ><code>nifi.state.management.provider.local</code></td><td style='text-align:left;' >提供此XML文件中配置的本地State Provider标识符的属性</td></tr><tr><td style='text-align:left;' ><code>nifi.state.management.provider.cluster</code></td><td style='text-align:left;' >同样，该属性提供在此XML文件中配置的集群范围的State Provider的标识符。</td></tr></tbody>
</table></figure>

此XML文件由顶级 `state-management`元素组成，该元素具有 `local-provider`和 `cluster-provider` 元素。然后，这些元素中的每一个都包含一个 `id`元素，用于指定可在 *nifi.properties* 文件中引用的标识符， 以及一个 `class`元素，该元素指定要用于实例化State Provider的完全限定类名。最后，这些元素中的每一个可以具有零个或多个 `property`元素。每个 `property`元素都有一个属性，`name`即 `property`State Provider支持的名称。property元素的文本内容是属性的值。

![image.png](https://image.hyly.net/i/2025/09/28/5bdb35a26b8dd648797c7e452e69e9a0-0.webp)

在_state-management.xml_文件(或配置的任何文件)中配置了这些状态提供程序后，这些提供程序可通过标识符被引用。

默认情况下，本地状态提供程序配置为将 `WriteAheadLocalStateProvider`数据持久保存到 `$NIFI_HOME/state/local`目录。默认的集群状态提供程序配置为 `ZooKeeperStateProvider`。

默认的基于ZooKeeper的提供程序必须先 `Connect String`填充其属性，然后才能使用它。

`Connect String`采用逗号分隔，IP和端口号使用 `:`分割，例如 `my-zk-server1:2181,my-zk-server2:2181,my-zk-server3:2181`。如果没有为任何主机指定端口,`2181`则假定为ZooKeeper默认值 。

![image.png](https://image.hyly.net/i/2025/09/28/dcafd34aa264d74b279813c2c108f38b-0.webp)

向ZooKeeper添加数据时，Access Control有两个选项:`Open`和 `CreatorOnly`。如果该 `Access Control`属性设置为 `Open`，则允许任何人登录ZooKeeper并拥有查看，更改，删除或管理数据的完全权限。如果指定 `CreatorOnly`，则仅允许创建数据的用户读取，更改，删除或管理数据。为了使用该 `CreatorOnly`选项，NiFi必须提供某种形式的身份验证。建议使用Open。

如果NiFi配置为在独立模式下运行，则 `cluster-provider`无需在_state-management.xml_ 文件中填充该元素，如果填充它们，实际上将忽略该元素。但是，`local-provider`元素必须始终存在并填充。

此外，如果NiFi在集群中运行，则每个节点还必须配置引用 `nifi.state.management.provider.cluster`元素。否则，NiFi将无法启动。

这些都是通过外部的 *state-management.xml* 文件，而不是通过 *nifi.properties* 文件进行配置。

应注意，如果处理器和其他组件使用集群作用域保存状态，则如果实例是独立实例(不在集群中)或与集群断开连接，则将使用本地状态提供程序。这也意味着如果将独立实例迁移到集群中，则本地的状态将不再可用，因为该组件将开始使用集群状态提供程序而不是本地状态提供程序。

#### 管理节点

##### 断开节点

DFM可以手动断开节点与集群的连接。节点也可能由于其他原因而断开连接，例如由于缺乏心跳。当节点断开连接时，集群协调器将在用户界面上显示公告。在解决断开连接节点的问题之前，DFM将无法对数据流进行任何更改。DFM或管理员需要对节点的问题进行故障排除，并在对数据流进行任何新的更改之前解决该问题。但是，值得注意的是，仅仅因为节点断开连接并不意味着它不起作用。这可能由于某些原因而发生，例如，当节点由于网络问题而无法与集群协调器通信时。

要手动断开节点，请从节点的行中选择"断开连接"图标(![image.png](https://image.hyly.net/i/2025/09/28/9e3e56a7f93c58c752cad5d77d7a1f82-0.webp))。

![image.png](https://image.hyly.net/i/2025/09/28/6525528c125ae3a497a0a473efb6a57b-0.webp)

断开连接的节点可以连接(![image.png](https://image.hyly.net/i/2025/09/28/2d3e8fb983255de1548353f8a4ca8b5e-0.webp))，卸载(![image.png](https://image.hyly.net/i/2025/09/28/c39478d99cf198c91f6ef7c37d03925d-0.webp))或删除(![image.png](https://image.hyly.net/i/2025/09/28/9ef27edcf52bdbe96e43a9ddaa9ef992-0.webp))。

![image.png](https://image.hyly.net/i/2025/09/28/4488758ba9a33adcd658017504e77685-0.webp)并非所有处于"已断开连接"状态的节点都可以卸载。如果节点断开连接且无法访问，则节点无法接收卸载请求以启动卸载。此外，由于防火墙规则，可能会中断或阻止卸载。

##### 卸载节点

保留在断开连接的节点上的流文件可以通过卸载重新平衡到集群中的其他活动节点。在Cluster Management对话框中，为Disconnected节点选择"Offload"图标(![image.png](https://image.hyly.net/i/2025/09/28/a501d9c7002921831e50542c4f151607-0.webp))。这将停止所有处理器，终止所有处理器，停止在所有远程进程组上传输，并将流文件重新平衡到集群中的其他连接节点。

![image.png](https://image.hyly.net/i/2025/09/28/819f568558aa77a39245b75460c4dc04-0.webp)

由于遇到错误(内存不足，没有网络连接等)而保持"卸载"状态的节点可以通过重新启动节点上的NiFi重新连接到集群。卸载的节点可以重新连接到集群(通过选择连接或重新启动节点上的NiFi)或从集群中删除。

![image.png](https://image.hyly.net/i/2025/09/28/5f7d436dc0f962d82ccee66f5488fc6a-0.webp)

##### 删除节点

在某些情况下，DFM可能希望继续对流进行更改，即使节点未连接到集群也是如此。在这种情况下，DFM可以选择完全从集群中删除节点。在Cluster Management对话框中，为Disconnected或Offloaded节点选择"Delete"图标(![image.png](https://image.hyly.net/i/2025/09/28/42f1acdde9a6d2a96a4fe0c44bcc17e9-0.webp))。删除后，在重新启动节点之前，节点无法重新加入集群。

##### 退役节点

停用节点并将其从集群中删除的步骤如下：

1. 断开节点。
2. 断开连接完成后，卸载节点。
3. 卸载完成后，删除该节点。
4. 删除请求完成后，停止/删除主机上的NiFi服务。

NiFi CLI节点命令

作为UI的替代方案，以下NiFi CLI命令可用于检索单个节点，检索节点列表以及连接/断开/卸载/删除(connecting/disconnecting/offloading/deleting ) 节点：

- `nifi get-node`
- `nifi get-nodes`
- `nifi connect-node`
- `nifi disconnect-node`
- `nifi offload-node`
- `nifi delete-node`

#### 流动选举

cluster启动的时候，NiFi必须确定哪个节点具有流的"正确"版本信息。这是通过对每个节点具有的流进行投票来完成的。当节点尝试连接到集群时，它会将其本地流的副本flow.xml.gz提供给集群协调器。如果尚未选择流"正确"流，则将节点的流与每个其他节点的流进行比较。然后每台对和自己一样的flow进行投票。如果还没有其他节点报告相同的流，则此流将以一票投票的方式添加到可能选择的流池中。如果投票时间(nifi.cluster.flow.election.max.wait.time)到了或者某一个flow.xml.gz已经达到票数（nifi.cluster.flow.election.max.candidates），则选出一个正确的flow.xml.gz。然后，不一致的node自动挂掉，除非它自己没有flow.xml.gz；而具有兼容流的节点将继承集群的流。选举是根据"民众投票"进行的，但需要注意的是，除非所有流量都是空的，否则获胜者永远不会是"空流"。

对于加入集群失败的节点，可以通过删除flow.xml.gz文件来加入集群。

### FlowFile生成器

FlowFile生成器：GenerateFlowFile和ReplaceText处理器，用于生成数据，对调试流程很有用。

#### GenerateFlowFile解析

**描述**

该处理器使用随机数据或自定义内容创建流文件。GenerateFlowFile用于负载测试、配置和仿真。

**属性配置**

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >属性名称</th><th style='text-align:left;' >默认值</th><th style='text-align:left;' >可选值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>File Size</strong></td><td style='text-align:left;' >0B</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >将使用的文件流的大小</td></tr><tr><td style='text-align:left;' ><strong>Batch Size</strong></td><td style='text-align:left;' >1</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >每次调用时要传输出去的流文件的数量</td></tr><tr><td style='text-align:left;' ><strong>Data Format</strong></td><td style='text-align:left;' >Text</td><td style='text-align:left;' >BinaryText</td><td style='text-align:left;' >指定数据应该是文本还是二进制</td></tr><tr><td style='text-align:left;' ><strong>Unique FlowFiles</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >如果选择true，则生成的每个流文件都是惟一的。 如果选择false，此处理器将生成一个随机值，所有的流文件都是相同的内容，模仿更高的吞吐量时可以这样使用</td></tr><tr><td style='text-align:left;' >Custom Text</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >如果Data Format选择Text，且Unique FlowFiles选择为false，那么这个自定义文本将用作生成的流文件的内容，文件大小将被忽略。 如果Custom Text中使用了表达式语言，则每批生成的流文件只执行一次表达式语言的计算 支持表达式语言:true(只使用变量注册表进行计算)</td></tr><tr><td style='text-align:left;' ><strong>Character Set</strong></td><td style='text-align:left;' >UTF-8</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >指定将自定义文本的字节写入流文件时要使用的编码</td></tr></tbody>
</table></figure>

**应用场景**

该处理器多用于测试，配置生成设计人员所需要的特定数据，模拟数据来源或者压力测试、负载测试；

某些场景中可以作为配置灵活使用，比如设计人员想设计一个流程查询多个表，表名就可以做出json数组配置到Custom Text，之后再使用其他相关处理器生成含有不同表名属性的多个流文件，就可以实现一个流程查询多表。(额外延伸，也可以在变量注册表、缓存保存配置，通过不同的配置读取不同的表)

#### ReplaceText解析

**描述**

使用其他值替换匹配正则表达式的流文件部分内容，从而更新流文件的内容。

**属性配置**

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th>属性名称</th><th>默认值</th><th>可选值</th><th>描述</th></tr></thead>
<tbody><tr><td><strong>Search Value</strong></td><td>(?s)(^.*$)</td><td>&nbsp;</td><td>正则表达式，仅用于“Literal Replace”和“Regex Replace”匹配策略 支持表达式语言:true</td></tr><tr><td><strong>Replacement Value</strong></td><td>$1</td><td>&nbsp;</td><td>使用“Replacement Strategy”策略时插入的值。 支持表达式语言:true</td></tr><tr><td><strong>Character Set</strong></td><td>UTF-8</td><td>&nbsp;</td><td>字符集</td></tr><tr><td><strong>Maximum Buffer Size</strong></td><td>1 MB</td><td>&nbsp;</td><td>指定要缓冲的最大数据量(每个文件或每行，取决于计算模式)，以便应用替换。如果选择了“Entire Text”，并且流文件大于这个值，那么流文件将被路由到“failure”。在“Line-by-Line”模式下，如果一行文本比这个值大，那么FlowFile将被路由到“failure”。默认值为1 MB，主要用于“Entire Text”模式。在“Line-by-Line”模式中，建议使用8 KB或16 KB这样的值。如果将&#x3c;<strong>Replacement Strategy</strong>&gt;属性设置为一下其中之一:Append、Prepend、Always Replace，则忽略该值</td></tr><tr><td><strong>Replacement Strategy</strong></td><td>Regex Replace</td><td>Prepend&#x3c;br/&gt;Append&#x3c;br/&gt;Regex Replace&#x3c;br/&gt;Literal Replace&#x3c;br/&gt;Always Replace</td><td>在流文件的文本内容中如何替换以及替换什么内容的策略。</td></tr><tr><td><strong>Evaluation Mode</strong></td><td>Entire text</td><td>Line-by-Line&#x3c;br/&gt;Entire text</td><td>对每一行单独进行“替换策略”(Line-by-Line)；或将整个文件缓冲到内存中(Entire text)，然后对其进行“替换策略”。</td></tr></tbody>
</table></figure>

**应用场景**

使用正则表达式，来逐行或者全文本替换文件流内容，往往用于业务逻辑处理。

#### 示例

**创建GenerateFlowFile并设置大小**

![image.png](https://image.hyly.net/i/2025/09/28/7a2bd6e0327fa17be2772cd7b624c6a2-0.gif)

**配置FlowFile**

![image.png](https://image.hyly.net/i/2025/09/28/2aaf6b06d8138d9d47620b58593b5769-0.gif)

**创建ReplaceText并连接**

![image.png](https://image.hyly.net/i/2025/09/28/9710d1087babf8b1507b9998bdc105b1-0.gif)

**启动GenerateFile**

![image.png](https://image.hyly.net/i/2025/09/28/40695a1fb04bd56a6a61bfa1402135ea-0.gif)

**配置ReplaceText**

![image.png](https://image.hyly.net/i/2025/09/28/c23ac3df86a42fd6b3f2ad78202ab145-0.gif)

**创建PutFile**

停止GenerateFlowFile，然后创建PutFile。

![image.png](https://image.hyly.net/i/2025/09/28/6f9f5ff96bba605d3bc03afb8d8dcdcb-0.gif)

**停止，查看结果**

停止所有处理器，查看结果：

```shell
cd /export/tmp/target
ls
cat XXX-XXX
```

### Nifi模板

#### 导入模板

##### 导入

导入【Nifi课程\资料\template】目录下的CsvToJSON.xml模版文件。

![image.png](https://image.hyly.net/i/2025/09/28/e180a62e3cb0d2420ac051776035c9ca-0.gif)

##### 查看模板列表

![image.png](https://image.hyly.net/i/2025/09/28/dd0dbbb2eea1e498cd3c3f3ec58373ee-0.gif)

##### 创建模板引用

![image.png](https://image.hyly.net/i/2025/09/28/dfb8d7758f80ddf7b253dbc567f38c12-0.gif)

#### 组、导出模板

##### 创建组

![image.png](https://image.hyly.net/i/2025/09/28/ac473b17f0af1753aa137ce6e96ecd98-0.gif)

##### 移动处理器到组

![image.png](https://image.hyly.net/i/2025/09/28/cb69fa0e9d11796ee75f15c08452871f-0.gif)

##### 进入与退出组

![image.png](https://image.hyly.net/i/2025/09/28/332ebe510b4d512db577eab4227f2888-0.gif)

##### 创建模板

![image.png](https://image.hyly.net/i/2025/09/28/e45a894020fd40ab4d26da491aa8c907-0.gif)

##### 下载模板

![image.png](https://image.hyly.net/i/2025/09/28/9b26f93e878707d354260de473f52974-0.gif)

##### 嵌套组

![image.png](https://image.hyly.net/i/2025/09/28/c42f0128d2085dabb682ffca06f7efbd-0.gif)

### FlowFile拓扑：内容和属性

#### 理论

##### FlowFile包含两部分

1. 属性：
   - FlowFile的元数据
   - 保存了关于内容的信息，比如：什么时候创建的，从哪里来，代表什么等等
2. 内容：
   - FlowFile的实际内容。比如：使用getfile读取数据时，读取到的实际内容文本。

##### 处理器对FlowFile的操作

1. 更新，添加，或者删除FlowFile属性
2. 改变FlowFile内容

##### ExtractText

**描述**

该处理器使用正则表达式，匹配流文件中的内容，并将匹配成功的内容输出到属性中；如果正则匹配到多个结果，默认只取第一个结果；匹配成功则流文件路由matched，没有匹配则到unmatched；

**属性配置**

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >属性名称</th><th style='text-align:left;' >默认值</th><th style='text-align:left;' >可选值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Character Set</strong></td><td style='text-align:left;' >UTF-8</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >字符集</td></tr><tr><td style='text-align:left;' ><strong>Maximum Buffer Size</strong></td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >指定(每个文件)要缓冲的最大数据量，应用于正则表达式。大于指定最大值的文件部分将不会被计算匹配。</td></tr><tr><td style='text-align:left;' >Maximum Capture Group Length</td><td style='text-align:left;' >1024</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >指定给定匹配值可以拥有的最大字符数。超过最大值的字符将被截断。</td></tr><tr><td style='text-align:left;' ><strong>Enable Canonical Equivalence</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >当且仅当两个字符的&quot;正规分解(canonical decomposition)&quot;都完全相同的情况下，才认定匹配。比如用了这个标志之后，表达式&quot;a/u030A&quot;会匹配&quot;?&quot;。默认情况下，不考虑&quot;规范相等性(canonical equivalence)&quot;。</td></tr><tr><td style='text-align:left;' >**Enable Case-insensitive Matching</td><td style='text-align:left;' >false**</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >是否忽略大小写；也可以使用 (?i)标志 默认情况下，大小写不明感的匹配只适用于US-ASCII字符集。这个标志(?i)能让表达式忽略大小写进行匹配。要想对Unicode字符进行大小不明感的匹配，只要将UNICODE_CASE与这个标志(?i)合起来就行了。</td></tr><tr><td style='text-align:left;' ><strong>Permit Whitespace and Comments in Pattern</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >在这种模式下，空格将被忽略，以#开头的嵌入注释将被忽略，直到行尾。也可以通过嵌入的标志(?x)指定。</td></tr><tr><td style='text-align:left;' ><strong>Enable DOTALL Mode</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >在这种模式下，表达式&#39;.&#39;可以匹配任意字符，包括表示一行的结束符。默认情况下，表达式&#39;.&#39;不匹配行的结束符。也可以通过嵌入的标志(?s)指定。</td></tr><tr><td style='text-align:left;' ><strong>Enable Literal Parsing of the Pattern</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >表示不应赋予元字符和转义字符特殊含义。</td></tr><tr><td style='text-align:left;' >Enable Multiline Mode</td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >指示&#39;^&#39;和&#39;$&#39;应在行结束符或序列结束符之后和之前匹配，而不是只匹配整个输入的开始或结束符。也可以通过嵌入的标志(?m)指定。</td></tr><tr><td style='text-align:left;' ><strong>Enable Unicode-aware Case Folding</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >当与“启用不区分大小写的匹配”一起使用时，以与Unicode标准一致的方式匹配。也可以通过嵌入的标志(?u)指定。</td></tr><tr><td style='text-align:left;' ><strong>Enable Unicode Predefined Character Classes</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >指定与Unicode技术标准#18:Unicode正则表达式附件C:兼容性属性的一致性。也可以通过嵌入的标志(?U)指定。</td></tr><tr><td style='text-align:left;' ><strong>Enable Unix Lines Mode</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >只有&#39;/n&#39;才被认作一行的中止，并且与&#39;.&#39;，&#39;^&#39;，以及&#39;$&#39;进行匹配。也可以通过嵌入的标志(?d)指定。</td></tr><tr><td style='text-align:left;' ><strong>Include Capture Group 0</strong></td><td style='text-align:left;' >true</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >指示捕获组0应包含为属性。Capture Group 0表示正则表达式匹配的全部，通常不使用，可能有相当长的长度。</td></tr><tr><td style='text-align:left;' ><strong>Enable repeating capture group</strong></td><td style='text-align:left;' >false</td><td style='text-align:left;' >truefalse</td><td style='text-align:left;' >如果设置为true，将提取与捕获组匹配的每个字符串。否则，如果正则表达式匹配不止一次，则只提取第一个匹配。</td></tr></tbody>
</table></figure>

**应用场景**

提取content中的内容，输出到流属性当中 。

##### UpdateAttribute

**描述**

该处理器使用属性表达式语言更新流文件的属性，并且/或则基于正则表达式删除属性

**属性配置**

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th>属性名称</th><th style='text-align:center;' >默认值</th><th>可选值</th><th>描述</th></tr></thead>
<tbody><tr><td>Delete Attributes Expression</td><td style='text-align:center;' >&nbsp;</td><td>&nbsp;</td><td>删除的属性正则表达式 支持表达式语言:true</td></tr><tr><td><strong>Store State</strong></td><td style='text-align:center;' >Do not store state</td><td>Do not store stateStore state locally</td><td>选择是否存储状态。</td></tr><tr><td>Stateful Variables Initial Value</td><td style='text-align:center;' >&nbsp;</td><td>&nbsp;</td><td>如果使用<strong>Store State</strong>，则此值用于设置有状态变量的初值。只有当状态不包含变量的值时，才会在@OnScheduled方法中使用。如果是有状态运行，这是必需配置的，但是如果需要，这可以是空的。</td></tr></tbody>
</table></figure>

**应用场景**

该处理器基本用法最为常用，及增加，修改或删除流属性；

此处理器使用用户添加的属性或规则更新FlowFile的属性。有三种方法可以使用此处理器添加或修改属性。一种方法是“基本用法”; 默认更改通过处理器的每个FlowFile的匹配的属性。第二种方式是“高级用法”; 可以进行条件属性更改，只有在满足特定条件时才会影响FlowFile。可以在同一处理器中同时使用这两种方法。第三种方式是“删除属性表达式”; 允许提供正则表达式，并且将删除匹配的任何属性。

请注意，“删除属性表达式”将取代发生的任何更新。如果现有属性与“删除属性表达式”匹配，则无论是否更新，都将删除该属性。也就是说，“删除属性表达式”仅适用于输入FlowFile中存在的属性，如果属性是由此处理器添加的，则“删除属性表达式”将不会匹配到它。

#### 练习

##### 改为单点造数据

改为单点造数据，并启动GenerateFlowFile。

![image.png](https://image.hyly.net/i/2025/09/28/a77ca9d0277946809060bd857fc6351d-0.gif)

##### 负载均衡消费数据

![image.png](https://image.hyly.net/i/2025/09/28/d2bd3899a1704267577878de0d55420c-0.gif)

##### 查看队列数据

![image.png](https://image.hyly.net/i/2025/09/28/5355972bc4ec34b14e18073463ea8b84-0.gif)

##### ReplaceText为a,b,c,d

![image.png](https://image.hyly.net/i/2025/09/28/36364af1de4542a4e5af7a17454d929a-0.gif)

![image.png](https://image.hyly.net/i/2025/09/28/54e99070febbf898a75064206dc16040-0.webp)

##### 通过ExtractText将数据写入属性

设置新属性csv，通过正则表达式"(.+),(.+),(.+),(.+)"进行匹配后，将FlowFile的内容"a,b,c,d"写入名为csv的属性。

![image.png](https://image.hyly.net/i/2025/09/28/90a4912927637a9ee2ed963b8f13e7b4-0.gif)

查看输出数据属性

![image.png](https://image.hyly.net/i/2025/09/28/273af62546072a599f54a4482718c14c-0.gif)

### 使用表达式语言

#### 为什么需要NiFi表达式

FlowFile由两个主要部分组成：内容和属性。FlowFile的属性部分表示有关数据本身或元数据的信息。属性是键值对，它们代表关于数据的已知知识以及对适当地路由和处理数据有用的信息。与从本地文件系统中提取的文件的示例相同，FlowFile将具有一个名为的属性 `filename`，该属性反映了文件系统上文件的名称。另外，FlowFile将具有 `path`反映该文件所在文件系统上目录的属性。FlowFile还将具有名为的属性 `uuid`，这是此FlowFile的唯一标识符。

但是，如果用户无法使用这些属性，则将这些属性放在FlowFile上不会带来太多好处。NiFi表达式语言提供了引用这些属性，将它们与其他值进行比较以及操纵其值的功能。

#### 表达式语言介绍

当我们从FlowFiles的内容中提取属性并添加用户定义的属性时，除非我们有一些可以使用它们的机制，否则它们不会作为运算符进行计算。NiFi表达式语言允许我们在配置流时访问和操作FlowFile属性值。并非所有处理器属性都允许使用表达式语言，但很多处理器都可以。为了确定属性是否支持表达式语言，用户可以将鼠标悬停在处理器配置对话框的属性选项卡中的![image.png](https://image.hyly.net/i/2025/09/28/f7cf0e5eb0a821c2cc37f743d80e7388-0.webp)图标上，然后会有一个提示，显示属性的描述，默认值（如果有)以及属性是否支持表达式语言。

![image.png](https://image.hyly.net/i/2025/09/28/ce8e12117a3bd5e426501c49743e0b2b-0.webp)

#### NiFi表达式的结构

NiFi表达式语言始终以开始定界符开始，`${`并以结束定界符结束 `}`。在开始和结束定界符之间是表达式本身的文本。在最基本的形式中，表达式可以只包含一个属性名称。例如，`${filename}`将返回 `filename` 属性的值。

在稍微复杂一点的示例中，我们可以返回此值的操作。例如，我们可以通过调用 `toUpper`函数来返回文件名的全部大写形式 `${filename:toUpper()}`。在这种情况下，我们引用该 `filename` 属性，然后使用该 `toUpper`函数操纵该值。函数调用包含5个元素。首先，有一个函数调用定界符 `:`。第二个是函数的名称-在这种情况下为 `toUpper`。接下来是一个开放的括号（`(`），后跟函数参数。必要的参数取决于调用哪个函数。在此示例中，我们使用的 `toUpper`函数没有任何参数，因此将省略此元素。最后，右括号（`)`）表示函数调用结束。表达式语言支持许多不同的功能，以实现许多不同的目标。某些函数提供了String（文本）操作，例如该 `toUpper`函数。其他功能（例如 `equals`和 `matches`功能）提供比较功能。还存在用于操纵日期和时间以及执行数学运算的功能。

当我们对属性执行函数调用时，我们将属性称为函数的 *主题*，因为属性是函数在其上运行的实体。然后，我们可以将多个函数调用链接在一起，其中第一个函数的返回值成为第二个函数的主题，而其返回值成为第三个函数的主题，依此类推。继续我们的示例，我们可以使用表达式将多个函数链接在一起 `${filename:toUpper():equals('HELLO.TXT')}`。可以链接在一起的功能数量没有限制。

通常，我们需要将两个不同属性的值相互比较。我们能够通过使用嵌入式表达式来完成此任务。例如，我们可以检查 `filename`属性是否与 `uuid`属性：相同 `${filename:equals( ${uuid} )}`。还要注意，在 `equals`方法的左括号和嵌入的Expression 之间有一个空格。这不是必需的，并且不会影响表达式的评估方式。相反，其目的是使表达式更易于阅读。分隔符之间的表达式语言会忽略空格。因此，我们可以使用Expression `${ filename : equals(${ uuid}) }`或 `${filename:equals(${uuid})}`并且两个Expression表示同一件事。但是，我们不能使用 `${file name:equals(${uuid})}`，因为这会导致 `file`和 `name`被解释为不同的变量，而不是单个变量 `filename`。

#### 使用表达式语言修改内容

```
ReplaceText设置Replacement Value（替代值）属性的时候，使用表达式语言${csv.1}来获取属性值：

{ "field1" : "${csv.1}", "field2" : "${csv.2}", "field3" : "${csv.3}", "field4" : "${csv.4}" }

相当于

{ "field1" : "a", "field2" : "b", "field3" : "c", "field4" : "d" }
```

![image.png](https://image.hyly.net/i/2025/09/28/7157aac72eb8075655384e8dd40cd5b9-0.gif)

#### 查看替换后的内容

![image.png](https://image.hyly.net/i/2025/09/28/267edef421d10b2088ae9f60108ab5ec-0.gif)

### 监控Nifi

NiFi提供有关DataFlow的大量信息，以便监控其健康状况。状态栏提供有关整体系统运行状况的信息。处理器，进程组和远程进程组提供有关其操作的细粒度详细信息。连接和进程组提供有关其队列中数据量的信息。摘要页面以表格格式提供有关画布上所有组件的信息，还提供包括磁盘使用情况，CPU利用率以及Java堆和垃圾收集信息的系统诊断。在集群环境中，此信息可以按节点使用，也可以作为整个集群中的聚合使用。我们将在下面探讨每个监控工件。

#### 操作:启动CsvToJson

![image.png](https://image.hyly.net/i/2025/09/28/4fd4c3c023bd32013a1d24e058c216c3-0.gif)

#### 状态栏

![image.png](https://image.hyly.net/i/2025/09/28/8214e54813833a7bd224a0e87c6d6eff-0.webp)

#### 处理器面板

### NiFi提供有关画布上每个处理器的大量信息。

![image.png](https://image.hyly.net/i/2025/09/28/f115af1dd6334f8d935ea102d5d97f43-0.webp)

概述了以下元素：

- **处理器类型**：NiFi提供多种不同类型的处理器,以便执行各种任务。每种类型的处理器都旨在执行一项特定任务。处理器类型(在此示例中为PutFile)描述了此处理器执行的任务。在这种情况下,处理器将FlowFile写入磁盘 - 或者将FlowFile放入文件。
- **公告指示器**：当处理器记录某个事件已发生时,它会生成一个公告,以通过用户界面通知正在监控NiFi的人员。DFM能够通过更新处理器配置对话框的设置选项卡中的公告级别字段来配置应在用户界面中显示的公告。默认值为WARN,这意味着UI中仅显示警告和错误。除非此处理器存在公告,否则此图标不存在。当它出现时,用鼠标悬停在图标上将提供一个工具提示,说明处理器和公告级别提供的消息。如果NiFi的实例是集群的,它还将显示发布公告的节点。
- **状态指示灯**：显示处理器的当前状态。以下指标是可能的：
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAUCAMAAABYi/ZGAAAAAXNSR0IArs4c6QAAAI1QTFRFdMWbdcabdcacdsabdsacdsecd8edeMedeMeeecieecifesiffsqigMujhMymhcynjM+sjtCul9S0mtW2n9e5n9i5o9m8o9m9pNq9sN7Gsd/HvOPPveTPveTQxufWyenYzerb1O3g1+7i2e/k2vDk4/Pr6fbv7Pfx7ffy8/r29fv49/z6+v37+/38////Vz/ZoAAAAHFJREFUGNNj0MMEDCSIySliiomyiKuii4kxsfBIqqOJsXBzMvLLaqGJcXNzMAsq6KKJcXOzsQmroItxc7OyS2iiiXEy8cloo4hxMfFIaaDqZeWUUEW1l41NSAnVfQxMAvI6qG4W4ZXWRPebshr54YcOAJ7jOBLTRUSuAAAAAElFTkSuQmCC) 正在运行：处理器当前正在运行。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAATCAMAAABFjsb+AAAAAXNSR0IArs4c6QAAAEJQTFRFz3x70H180X590YGA0oKB04aF4Kio4Kqp4auq4a2s4q+u4q+v7MrK7MzL7MzM7s/O7tDP7tHR9eTk9+jo+vLy////jNllnQAAADpJREFUGFdjEMUEDCSICXJywwAXlzBEjI2JBQ4Y+SFiHCyscMAsMHTF2BmZ4YABKibEwwsHfCLEhx8ALzISkH4jlpwAAAAASUVORK5CYII=) 已停止：处理器有效并已启用但未运行。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAASCAMAAACO0hVbAAAAAXNSR0IArs4c6QAAARpQTFRFzZpMzZtOzpxPzpxQzpxRzpxSzp1Rzp1Sz51Sz55Tz55Uz55Vz59V0J9V0J9X0KBW0KBX0KBY0KFY0KFZ0aFZ0aJb0aNb0qNd0qRe0qRf1Khk1Khl1apo1app1atr1qtr1qxt16xu161u2LB02bJ42bN42rR73LiC3bmD3bmE3buH37+N4MCQ4sSX4sWZ4sab48ad5Med5Mie5Mif5Mmf5cqi5syl58+q6NCt6NGt6tOy7Ni87Nm7797F79/H8ODI8ePO8+bU8+fV9OjX9Ora9era9erb9evc9uzf9u7g9+3g+PDk+PLo+fLo+fPp+fPq+/fy+/jx+/jy+/jz/Pn0/fv4/fz5/v37/v38/v79//79//7+///+////87r9PQAAAL1JREFUGFdjiMUEDHCWTxiGmIOkfgyaWKgqs6ATmpg1Bz+7ZgSKWIAil5AAjz2KmCWDrqctn0ookpi/NKN5rLcYuw2SmDELk2msmyinUiBczEuCh8kk1kWEn80CLqbDJsClbKYtIMAt5QsVcxTiF+BR0FMXEBBgNoSIRWiwATkGsc7C/AK84h5gMTseoAIOLVcrQSDNqhMFFItUY+ICAR4wySngDhSLNpKRBwE5MCmr5ge2IyQYAYLCkcMPAQBqolmbNP7nWAAAAABJRU5ErkJggg==) 无效：处理器已启用但当前无效且无法启动。将鼠标悬停在此图标上将提供工具提示,指示处理器无效的原因。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAZCAMAAAAc9R5vAAAAAXNSR0IArs4c6QAAARFQTFRFaIeVaoiXaomYa4mXa4qYbIqZbYuZboyab4yab4ybcI2bcI2ccY+cc4+dd5OgeJOheJShepWiepaifpilgZung52phJ2phZ6qhp6qjKOvkKaxkKexkaiykqiyk6mzlau1mK23ma63ma64m7C5nbG6obS9p7nCqLrCqrvEq73Err7Grr7HtMPKu8jPvMnQvMrQvcrRvcvRvszSv8zSwM3Twc7Uws7Uw8/Vw8/WxNDWxdHWx9PYydPZ0Nre0dvf1d7h1t/i1t/j2ODj3OLm3uXo4+jr5Ons6u7w6+/x7PDy7vHy7vHz7/Lz8PP09ff49vf59/n5+fr7+vv7+vv8+/v8+/z8/f39/v7+/v7//v/+////tLK61QAAALJJREFUKM9jiMIBGGgiERwUHIFNwkZEXNQRTcLBAkioMLLxeaBJuEuZRAUIc7KqYtjhBZTRZOWwB1qEZoe3tFmUhoCtkYJ8KJrlPmLmUVqcTAw66K4KEWO3jFJnEfJEl3Dh5uU3jlLTxvCHp5Wru5xpuD/WINFnNsMaJJHKXBLG2CT8BFU8ZQ2xSDjzOEX5yhhgSuhKhkUBZfTC0CTCFa1BlK+SG5pEmF0gJFrCaBjnqAAAcI/AcBZBJa0AAAAASUVORK5CYII=) 已禁用：处理器未运行,在启用之前无法启动。此状态不表示处理器是否有效。
- **处理器名称**：这是处理器的用户定义名称。默认情况下,Processor的名称与Processor Type相同。在示例中,此值为"Copy to /review"。
- **活动任务**：此处理器当前正在执行的任务数。此数字受处理器配置对话框的计划选项卡中的并发任务设置的约束。在这里,我们可以看到处理器当前正在执行一项任务。如果NiFi实例是集群的,则此值表示当前正在集群中的所有节点上执行的任务数。
- **5分钟统计**：处理器以表格形式显示几种不同的统计数据。这些统计数据中的每一个都代表过去五分钟内完成的工作量。如果NiFi实例是集群的,则这些值表示在过去五分钟内所有节点组合完成了多少工作。这些指标是：
  - **In**：处理器从其传入Connections的队列中提取的数据量。此值表示为count size,其中count是从队列中提取的FlowFiles的数量,size是这些FlowFiles内容的总大小。在此示例中,处理器已从输入队列中提取了29个FlowFiles,总计14.16兆字节(MB)。
  - **Read/Write**：处理器从磁盘读取并写入磁盘的FlowFile内容的总大小。这提供了有关此处理器所需的I/O性能的有用信息。某些处理器可能只读取数据而不写入任何内容,而某些处理器不会读取数据但只会写入数据。其他可能既不会读取也不会写入数据,而某些处理器会读取和写入数据。在这个例子中,我们看到在过去的五分钟内,这个处理器读取了4.88 MB的FlowFile内容,并且写了4.88 MB。这是我们所期望的,因为这个处理器只是将FlowFile的内容复制到磁盘。但请注意,这与从输入队列中提取的数据量不同。这是因为它从输入队列中提取的某些文件已经存在于输出目录中,并且处理器配置为在发生这种情况时将FlowFiles路由到失败。因此,对于那些已经存在于输出目录中的文件,数据既不会被读取也不会被写入磁盘。
  - **Out**：处理器已传输到其出站连接的数据量。这不包括处理器自行删除的FlowFiles,也不包括路由到自动终止的连接的FlowFiles。与上面的"In"指标一样,此值表示为count size,其中count是已转移到出站Connections的FlowFiles的数量,size是这些FlowFiles内容的总大小。在此示例中,所有关系都配置为自动终止,因此不会报告任何FlowFiles已被转出。
  - Tasks/Time：此处理器在过去5分钟内被触发运行的次数,以及执行这些任务所花费的时间。时间格式为hour：minute：second。请注意,所花费的时间可能超过五分钟,因为许多任务可以并行执行。例如,如果处理器计划运行60个并发任务,并且每个任务都需要一秒钟才能完成,则所有60个任务可能会在一秒钟内完成。但是,在这种情况下,我们会看到时间指标显示它需要60秒,而不是1秒。或换句话说，这个时间可以被认为是"系统时间"。

#### 进程组面板

进程组提供了一种机制,用于将组件组合到一个逻辑构造中,以便以更高级别更容易理解的方式组织DataFlow。下图突出显示了构成Process Group解剖结构的不同元素：

![image.png](https://image.hyly.net/i/2025/09/28/32bd36a074f4bd812d079994fdd1ffe8-0.webp)

过程组由以下元素组成：

- **名称**：这是进程组的用户定义名称。将进程组添加到画布时,将设置此名称。稍后可以通过右键单击"进程组"并单击"配置"菜单选项来更改名称。在此示例中,进程组的名称是"Process Group ABC"。
- **公告指示器**：当进程组的子组件发布公告时,该公告也会传播到组件的父进程组。当任何组件具有活动公告时,将显示此指示符,允许用户使用鼠标将鼠标悬停在图标上以查看公告。
- **活动任务**：此进程组中组件当前正在执行的任务数。在这里,我们可以看到Process Group当前正在执行两项任务。如果NiFi实例是集群的,则此值表示当前正在集群中的所有节点上执行的任务数。
- **统计信息**：流程组提供有关过程组在过去5分钟内处理的数据量以及当前在流程组中排队的数据量的统计信息。以下元素包含流程组的"统计"部分：
  - **队列**：当前在进程组中排队的FlowFiles数。此字段表示为count(size),其中count是当前在Process Group中排队的FlowFiles的数量,size是这些FlowFiles内容的总大小。在此示例中,Process Group当前有26个FlowFiles排队,总大小为12.7兆字节(MB)。
  - **In**：在过去5分钟内通过其所有输入端口传输到Process Group的FlowFiles数。此字段表示为count / size→ports,其中count是过去5分钟内进入Process Group的FlowFiles的数量,size是这些FlowFiles内容的总大小, ports是输入端口的数量。在此示例中,8个FlowFiles已进入进程组,总大小为800 KB,并且存在两个输入端口。
  - **Read/Write**：进程组中的组件已从磁盘读取并写入磁盘的FlowFile内容的总大小。这提供了有关此Process Group所需的I / O性能的有用信息。在此示例中,我们看到在过去五分钟内,此Process Group中的组件读取了14.72 MB的FlowFile内容,并写入了14.8 MB。
  - **Out**：在过去5分钟内通过其输出端口传输出Process Group的FlowFiles数。此字段表示为ports→count(size),其中ports是输出端口的数量,count是过去5分钟内退出Process Group的FlowFiles的数量和size是FlowFiles内容的总大小。在此示例中,有三个输出端口,16个FlowFiles已退出进程组,其总大小为78.57 KB。
- **组件计数**：组件计数元素提供有关进程组中每种类型的组件数量的信息。以下提供了有关这些图标及其含义的信息：
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAArJJREFUOBFdk89LVFEUxz/v9/x4M6OVKFr+FhNrEUW1aBMUBSXV1lZRIK36B/onoqWbFi4qghYR9APaWC4CIYzKzEgryrRSZxzfzJv7Zjr3mZN24L573/nxPed8z73Go4nJGv+JVph6GUZsiWo1tG7jL1bVP3b99PfgWCYJ1yEyLYqREQelrRpmpAhChapWt4VsA0h7DuuGx+OfNWbzCtvcrAD25RyO7HRIqnIMtIlSB/A9ly8VlzvzIX0NLpcGcqTsjQqWy1Uefi7yajbiYmeCnFuqg8QArm2xgsvt+Qrnu3w6fIsH80V+BBG6+Y6MzXCvz8vFkLFPASN9HnZURcnSXJGU7E8WFAeaXFpTJjdf5+nKOlwdzDEiK+Oa3Jha5bDYm1M2z6XFpPCkxbSF6RVlshjAibYkdz8WOduZojtjMfo2z9hMnqPNHoeaEtyfKzIktumVCGXYMcGmJUQtK4OcZxEKwZVqjb2NLqPvCsyshEz9Crk1vcax1iTfihEpx8CzTYRjdKwuAD0ZvSvpV2wyKgiiGpYo9fzXKtKr2Dd99TmS/LLJeCWjVBs7+cJ6ICg64Ex7moT8ZyTjhe40s6shKUuCBEX7+EK/vmC2LnlXoopj1HizHHJqT0pKznN5IMv1g41xFUuBYuzDGpf6fca/B7QkDFIo8rpizWSkQo4LUffm1rm2P8vp9qSAFMi6hmSBkmQc7k3HZU8slLjS61IOhXURQ78F3Vs26TH+2+LFUsS5rjT9DQ4FYVXbfMdkcrHE068BQ20Og76iEJT/AeiTfjh+wuN9YPNM7oTuNeeZSJsslyOSwtPJFpvdboU1Cdbkaqlf5ap4FoISPa5NX4/LQtlgVcarb1qDY9PsRlTCkvjI/LZIHUDrNOq6vDijothhmjTJBLRSCdGFYrWedUs8fwAvqxue4UVLBwAAAABJRU5ErkJggg==) **传输端口**：当前配置为将数据传输到远程NiFi实例或从远程NiFi实例提取数据的远程进程组端口的数量。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAMAAABhEH5lAAAAAXNSR0IArs4c6QAAAchQTFRFZ4aVdJCedJGfdpKgeZWiepWie5ejfJekfZekfZikfpilfpmlfpmmf5mlf5mmf5qngJmmgJqmgJqngZqngZungpung52ohJ2ohZ6qhZ+rhp+rh5+riKCriaGsiaGtiqGtiqKti6Kui6Oui6OvjKKujKOujKSvjaSvjaSwjqWwj6axkKeykaiykqizk6mzk6m0lau0lau1lqy2l6y3l623mK23mq+5m6+5m7C5m7C6nLG6nbK7nrG7nrK7nrK8n7K8oLO8oLS9obS9o7W/o7a/pLa/pLe/prfAq7zFrb7Frr7Grr/Hr7/Hr7/IsL/IscLJs8LKtMPLtcTMtsTMtsXMt8XMt8bNuMbNucbNucfNucfOusfOusfPusjOusjPu8jPu8nPu8nQvMnPvMnQvMrQvcnPvcnQvcrQvcrRvcvRvsrQvsrRvsvRvsvSv8vRv8vSv8zSv8zTwMzSwMzTwM3Twc3Uws7Uws7Vws/Vw87Uw8/UxM/VxNDVxNDWxdDVxdDWxdHWxdHXxtHWxtHXx9LXx9LYx9PYyNLYyNPZydTZydXZy9bbzNbbzdbczdfbzdfcztfcztjcztjd0Nne0Nre0drf09vf1d3hUTlUCwAAAStJREFUGFdjCIeAsNDQ0DAIkyE8JT8tPDyprLm1uSIdIhQdpluUn5Hhoi2pZptcGwNWVWwnX1mmpOoV62/IZlcfDxKKa3VWaa+t9XHw6GwUNWmOAgqFF5cwKbYkq5vrsHr0c3iWAoXC6vVt3CXaugs6Epnj/KQbQarq+Zod2TSbo8QyvGQn8CfGA83KEJwkkWgqPTHBspW7TyIwAyiUxzdJJs6XQaGrOoqzXyI4HaixTjjTRWOqPqN8U45ts0BuHFCoxkp7Cpfx1GnOUi291lr1IONTC9m9u5V45IQE1VviQrJAQuFlASyuk9vSG6Yri9eXgVwPBFVRMrx69gYiyhYK2ckQofCCxiAXM7eA5h4no3yoUHhUdll5aXZkVFF8AkwIGIZh4BCMCA8HAKIFaXW6srCIAAAAAElFTkSuQmCC) **非传输端口**：当前连接到此进程组中的组件但当前已禁用其传输的远程进程组端口的数量。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAUCAMAAABYi/ZGAAAAAXNSR0IArs4c6QAAAI1QTFRFdMWbdcabdcacdsabdsacdsecd8edeMedeMeeecieecifesiffsqigMujhMymhcynjM+sjtCul9S0mtW2n9e5n9i5o9m8o9m9pNq9sN7Gsd/HvOPPveTPveTQxufWyenYzerb1O3g1+7i2e/k2vDk4/Pr6fbv7Pfx7ffy8/r29fv49/z6+v37+/38////Vz/ZoAAAAHFJREFUGNNj0MMEDCSIySliiomyiKuii4kxsfBIqqOJsXBzMvLLaqGJcXNzMAsq6KKJcXOzsQmroItxc7OyS2iiiXEy8cloo4hxMfFIaaDqZeWUUEW1l41NSAnVfQxMAvI6qG4W4ZXWRPebshr54YcOAJ7jOBLTRUSuAAAAAElFTkSuQmCC) **运行组件**：当前在此进程组中运行的处理器,输入端口和输出端口的数量。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAATCAMAAABFjsb+AAAAAXNSR0IArs4c6QAAAEJQTFRFz3x70H180X590YGA0oKB04aF4Kio4Kqp4auq4a2s4q+u4q+v7MrK7MzL7MzM7s/O7tDP7tHR9eTk9+jo+vLy////jNllnQAAADpJREFUGFdjEMUEDCSICXJywwAXlzBEjI2JBQ4Y+SFiHCyscMAsMHTF2BmZ4YABKibEwwsHfCLEhx8ALzISkH4jlpwAAAAASUVORK5CYII=) **已停止的组件**：当前未运行但有效且已启用的处理器,输入端口和输出端口的数量。这些组件已准备好启动。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAASCAMAAACO0hVbAAAAAXNSR0IArs4c6QAAARpQTFRFzZpMzZtOzpxPzpxQzpxRzpxSzp1Rzp1Sz51Sz55Tz55Uz55Vz59V0J9V0J9X0KBW0KBX0KBY0KFY0KFZ0aFZ0aJb0aNb0qNd0qRe0qRf1Khk1Khl1apo1app1atr1qtr1qxt16xu161u2LB02bJ42bN42rR73LiC3bmD3bmE3buH37+N4MCQ4sSX4sWZ4sab48ad5Med5Mie5Mif5Mmf5cqi5syl58+q6NCt6NGt6tOy7Ni87Nm7797F79/H8ODI8ePO8+bU8+fV9OjX9Ora9era9erb9evc9uzf9u7g9+3g+PDk+PLo+fLo+fPp+fPq+/fy+/jx+/jy+/jz/Pn0/fv4/fz5/v37/v38/v79//79//7+///+////87r9PQAAAL1JREFUGFdjiMUEDHCWTxiGmIOkfgyaWKgqs6ATmpg1Bz+7ZgSKWIAil5AAjz2KmCWDrqctn0ookpi/NKN5rLcYuw2SmDELk2msmyinUiBczEuCh8kk1kWEn80CLqbDJsClbKYtIMAt5QsVcxTiF+BR0FMXEBBgNoSIRWiwATkGsc7C/AK84h5gMTseoAIOLVcrQSDNqhMFFItUY+ICAR4wySngDhSLNpKRBwE5MCmr5ge2IyQYAYLCkcMPAQBqolmbNP7nWAAAAABJRU5ErkJggg==) **无效组件**：已启用但当前未处于有效状态的处理器,输入端口和输出端口的数量。这可能是由于配置错误或缺少关系造成的。
  - ![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAZCAMAAAAc9R5vAAAAAXNSR0IArs4c6QAAARFQTFRFaIeVaoiXaomYa4mXa4qYbIqZbYuZboyab4yab4ybcI2bcI2ccY+cc4+dd5OgeJOheJShepWiepaifpilgZung52phJ2phZ6qhp6qjKOvkKaxkKexkaiykqiyk6mzlau1mK23ma63ma64m7C5nbG6obS9p7nCqLrCqrvEq73Err7Grr7HtMPKu8jPvMnQvMrQvcrRvcvRvszSv8zSwM3Twc7Uws7Uw8/Vw8/WxNDWxdHWx9PYydPZ0Nre0dvf1d7h1t/i1t/j2ODj3OLm3uXo4+jr5Ons6u7w6+/x7PDy7vHy7vHz7/Lz8PP09ff49vf59/n5+fr7+vv7+vv8+/v8+/z8/f39/v7+/v7//v/+////tLK61QAAALJJREFUKM9jiMIBGGgiERwUHIFNwkZEXNQRTcLBAkioMLLxeaBJuEuZRAUIc7KqYtjhBZTRZOWwB1qEZoe3tFmUhoCtkYJ8KJrlPmLmUVqcTAw66K4KEWO3jFJnEfJEl3Dh5uU3jlLTxvCHp5Wru5xpuD/WINFnNsMaJJHKXBLG2CT8BFU8ZQ2xSDjzOEX5yhhgSuhKhkUBZfTC0CTCFa1BlK+SG5pEmF0gJFrCaBjnqAAAcI/AcBZBJa0AAAAASUVORK5CYII=) **已禁用组件**：当前已禁用的处理器,输入端口和输出端口的数量。这些组件可能有效,也可能无效。如果启动了进程组,则这些组件不会导致任何错误,但不会启动。
- **版本状态计数**：版本状态计数元素提供有关进程组中有多少版本化进程组的信息。有关更多信息,请参阅版本状态
- **注释**：将流程组添加到画布时,将为用户提供指定注释的选项,以便提供有关流程组的信息。稍后可以通过右键单击"进程组"并单击"配置"菜单选项来更改注释。

#### NiFi Summary(摘要)

虽然NiFi画布对于了解如何布置配置的DataFlow非常有用,但在尝试辨别系统状态时,此视图并不总是最佳的。为了帮助用户了解DataFlow在更高级别的运行方式,NiFi提供了摘要页面。此页面位于用户界面右上角的"全局菜单"中。

通过从全局菜单中选择摘要来打开摘要页面。这将打开摘要表对话框：

![image.png](https://image.hyly.net/i/2025/09/28/7386b6443c7115ca752f00985b79e4d0-0.webp)

此对话框提供有关画布上每个组件的大量信息。下面,我们在对话框中注释了不同的元素,以便更容易地讨论对话框。

![image.png](https://image.hyly.net/i/2025/09/28/eff7dccdc8d9dca744abfe29dc31ed5e-0.webp)

摘要页面主要由一个表组成,该表提供有关画布上每个组件的信息。此表上方是一组五个选项卡,可用于查看不同类型的组件。表中提供的信息与为画布上的每个组件提供的信息相同。可以通过单击列的标题对表中的每个列进行排序。

摘要页面还包含以下元素：

- **Bulletin Indicator**：与整个用户界面中的其他位置一样,当此图标存在时,将鼠标悬停在图标上将提供有关生成的公告的信息,包括消息,严重性级别,公告生成的时间以及(在集群环境中)生成公告的节点。与"摘要"表中的所有列一样,可以通过单击标题对显示公告的列进行排序,以便所有当前存在的公告显示在列表顶部。
- **Details**：单击详细信息图标将为用户提供组件的详细信息。此对话框与用户右键单击组件并选择查看配置菜单项时提供的对话框相同。
- **Go To**：单击此按钮将关闭摘要页面,并将用户直接带到NiFi画布上的组件。这可能会更改用户当前所在的进程组。如果已在新的浏览器选项卡或窗口中打开摘要页面(通过单击"Pop Out"按钮,如下所述),则此图标不可用。
- **Status History**：单击状态历史记录图标将打开一个新对话框,其中显示为此组件呈现的统计信息的历史视图。
- **Refresh**：该Refresh按钮允许用户刷新显示的信息,而无需关闭对话框并再次打开它。上次刷新信息的时间显示在Refresh按钮右侧。页面上的信息不会自动刷新。
- **Filter**：Filter元素允许用户通过键入全部或部分条件(例如处理器类型或处理器名称)来过滤摘要表的内容。可用的过滤器类型根据所选选项卡而不同。例如,如果查看处理器选项卡,则用户可以按名称或类型进行过滤。查看连接选项卡时,用户可以按源,名称或目标名称进行筛选。更改文本框的内容时,将自动应用过滤器。文本框下方是表中表中有多少条目与过滤器匹配以及表中存在多少条目的指示符。
- **Pop-Out**：监视流时,能够在单独的浏览器选项卡或窗口中打开摘要表是有帮助的。按钮旁边的Pop-Out按钮Close将导致在新的浏览器选项卡或窗口中打开整个摘要对话框(具体取决于浏览器的配置)。页面弹出后,对话框将在原始浏览器选项卡/窗口中关闭。在新选项卡/窗口中,"Pop-Out"按钮和"Go To"按钮将不再可用。
- **System Diagnostics**：系统诊断窗口提供有关系统在系统资源利用率方面的执行情况的信息。虽然这主要适用于管理员,但在此视图中提供了它,因为它确实提供了系统摘要。此对话框显示CPU利用率,磁盘空闲程度以及特定于Java的度量标准(如内存大小和利用率)以及垃圾收集信息等信息。

##### 操作

![image.png](https://image.hyly.net/i/2025/09/28/49f63a34478dbd85ebd1f85155fc137f-0.gif)

#### Status History

虽然摘要表和画布显示了与过去五分钟内组件性能相关的数字统计信息,但查看历史统计信息通常也很有用。通过右键单击组件并选择状态历史记录菜单选项或单击摘要页面中的状态历史记录( 有关详细信息,请参阅摘要页面),可以获得此信息。

存储的历史信息量可在NiFi属性中配置,但默认为24 hours。打开状态历史记录对话框时,它会提供历史统计信息的图表：

![image.png](https://image.hyly.net/i/2025/09/28/c5f69d9a60d60ac008cefc1c40fbc121-0.webp)

对话框的左侧提供有关统计信息所用组件的信息,以及绘制统计信息的文本表示。左侧提供以下信息：

- **Id**：正在显示统计信息的组件的ID。
- **Group Id**：组件所在的进程组的ID。
- **Name**：要显示统计信息的组件的名称。
- **Component-Specific Entries**：显示每种不同类型组件的信息。例如,对于处理器,将显示处理器的类型。对于Connection,将显示源和目标名称和ID。
- **Start**：图表上显示的最早时间。
- **End**：图表上显示的最新时间。
- **Min/Max/Mean**：显示最小值,最大值和平均值(算术平均值或平均值)。如果选择了任何时间范围,这些值仅基于所选时间范围。如果对此NiFi实例进行聚类,则会为整个集群以及每个单独节点显示这些值。在集群环境中,每个节点以不同的颜色显示。这也用作图形的图例,显示图形中显示的每个节点的颜色。将鼠标悬停在集群上或图例中的其中一个节点上也会使相应的节点在图形中变为粗体。

对话框的右侧提供了下表中要呈现的不同类型度量标准的下拉列表。顶部图形较大,以便提供更容易阅读的信息呈现。在该图的右下角是一个小手柄,可以拖动它来调整图形的大小。也可以拖动对话框的空白区域以移动整个对话框。

底部图表更短,并提供选择时间范围的能力。在此处选择时间范围将使顶部图形仅显示所选的时间范围,但是以更详细的方式显示。此外,这将导致重新计算左侧的最小值/最大值/平均值。通过在图形上拖动矩形创建选择后,双击所选部分将使选择在垂直方向上完全展开(即,它将选择此时间范围内的所有值)。单击底部图形而不拖动将删除选择。

##### 操作

![image.png](https://image.hyly.net/i/2025/09/28/9cf5fc66996f8f347ecde6fe14f4336c-0.gif)

#### Data Provenance(数据来源)

在监视数据流时,用户通常需要一种方法来确定特定数据对象(FlowFile)的发生情况。NiFi的Data Provenance页面提供了该信息。由于NiFi在对象流经系统时记录和索引数据来源详细信息,因此用户可以执行搜索,进行故障排除并实时评估数据流合规性和优化等内容。默认情况下,NiFi每五分钟更新一次此信息,但这是可配置的。

要访问Data Provenance页面,请从Global Menu中选择"Data Provenance"。这将打开一个对话框窗口,允许用户查看可用的最新数据源文件信息,搜索特定项目的信息,并过滤搜索结果。还可以打开其他对话框窗口以查看事件详细信息,在数据流中的任何位置重放数据,以及查看数据的沿袭或流程路径的图形表示。(这些功能将在下面详细介绍。)

启用授权后,访问Data Provenance信息需要"查询出处"全局策略以及生成事件的组件的"查看出处"组件策略。此外,访问包含FlowFile属性和内容的事件详细信息需要为生成事件的组件"查看数据"组件策略。

![image.png](https://image.hyly.net/i/2025/09/28/41df278b9ca45a6cad5ea3c1861d04e7-0.webp)

##### 种源事件

以某种方式处理FlowFile的数据流中的每个点都被视为"起源事件"。根据数据流设计,会发生各种类型的起源事件。例如,当数据进入流程时,会发生RECEIVE事件,并且当数据从流程中发出时,会发生SEND事件。可能会发生其他类型的处理事件,例如克隆数据(CLONE事件),路由(ROUTE事件),修改(CONTENT_MODIFIED或ATTRIBUTES_MODIFIED事件),拆分(FORK事件),与其他数据对象(JOIN事件)相结合,并最终从流程中删除(DROP事件)。

起源事件类型是：

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >种源事件</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >ADDINFO</td><td style='text-align:left;' >当添加其他信息(例如新链接到新URI或UUID)时,表示源项事件</td></tr><tr><td style='text-align:left;' >ATTRIBUTES_MODIFIED</td><td style='text-align:left;' >表示以某种方式修改了FlowFile的属性</td></tr><tr><td style='text-align:left;' >CLONE</td><td style='text-align:left;' >表示FlowFile与其父FlowFile完全相同</td></tr><tr><td style='text-align:left;' >CONTENT_MODIFIED</td><td style='text-align:left;' >表示以某种方式修改了FlowFile的内容</td></tr><tr><td style='text-align:left;' >CREATE</td><td style='text-align:left;' >表示FlowFile是从未从远程系统或外部进程接收的数据生成的</td></tr><tr><td style='text-align:left;' >DOWNLOAD</td><td style='text-align:left;' >表示用户或外部实体下载了FlowFile的内容</td></tr><tr><td style='text-align:left;' >DROP</td><td style='text-align:left;' >表示由于对象到期之外的某些原因导致对象生命结束的起源事件</td></tr><tr><td style='text-align:left;' >EXPIRE</td><td style='text-align:left;' >表示由于未及时处理对象而导致对象生命结束的起源事件</td></tr><tr><td style='text-align:left;' >FETCH</td><td style='text-align:left;' >指示使用某些外部资源的内容覆盖FlowFile的内容</td></tr><tr><td style='text-align:left;' >FORK</td><td style='text-align:left;' >表示一个或多个FlowFiles是从父FlowFile派生的</td></tr><tr><td style='text-align:left;' >JOIN</td><td style='text-align:left;' >表示单个FlowFile是通过将多个父FlowFiles连接在一起而派生的</td></tr><tr><td style='text-align:left;' >RECEIVE</td><td style='text-align:left;' >表示从外部进程接收数据的来源事件</td></tr><tr><td style='text-align:left;' >REPLAY</td><td style='text-align:left;' >表示重放FlowFile的originance事件</td></tr><tr><td style='text-align:left;' >ROUTE</td><td style='text-align:left;' >表示FlowFile已路由到指定的关系,并提供有关FlowFile路由到此关系的原因的信息</td></tr><tr><td style='text-align:left;' >SEND</td><td style='text-align:left;' >表示将数据发送到外部进程的originance事件</td></tr><tr><td style='text-align:left;' >UNKNOWN</td><td style='text-align:left;' >表示原产地事件的类型未知,因为尝试访问该事件的用户无权知道该类型</td></tr></tbody>
</table></figure>

##### 搜索Events

在Data Provenance页面中执行的最常见任务之一是搜索给定的FlowFile以确定它发生了什么。为此,请单击数据源页面右上角的Search按钮。这将打开一个对话框窗口,其中包含用户可以为搜索定义的参数。参数包括感兴趣的处理事件,区分FlowFile或产生事件的组件的特征,搜索的时间范围以及FlowFile的大小。

![image.png](https://image.hyly.net/i/2025/09/28/64425d36bee8a4f6fee72a2f794435d9-0.webp)

例如,要确定是否收到特定的FlowFile,请搜索"RECEIVE"的事件类型,并包含FlowFile的标识符,例如其uuid或文件名。星号(*)可用作任意数量字符的通配符。因此,要确定在2015年1月6日的任何时间是否收到了文件名中任何位置带有"ABC"的FlowFile,可以执行下图所示的搜索：

![image.png](https://image.hyly.net/i/2025/09/28/2dc8312de74558cb2ac536a99b9bd242-0.webp)

##### Event详情

在Data Provenance页面的最左侧列中View Details,每个事件都有一个图标(![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAnpJREFUOBGtU0toE1EUPTNpkzQfNB+02JYKIh3RRexGsUFM0oVI6sIqtOiu/sBPu3GjG91VQShFMPWzdCPGYomU4EIsaoUWKqKgILYpkZI2wTSW/JPnfZO2zJhossiBzHuZd++5951zR2AE1BFiHblkqroTNvyvw8XlZbyam8OnH/MoFIvY296O7v0O7G5p+WeaUEnDXKGAkfFx3H3mRyQWg6uzEw0akcg/wmY04ILXixv9/TDodOXEnFAJ6oQN+cYYXG4GTzfbevIUy+XzckjHwFkGt4fhiIudvn2HpbNZZaq8L7vy87fvMOL3A1qtXD2+msC1R4+ha2xEJB4HaOV4EgzioCTh8vEe+f/GQ2UKdYLRiRcA6cVh0OsxcOwoEskkwtEo8iSFDEEARBH3AwGspVKld+tPVYchMuHzQgjQaAAaT6vJjIdXByGIAviw7jl3Ht9C6+dE+H1pCV9CizggdWySqjqM0vWS6TTAO6BfLLGKKz4fSCukMhmqofgG6DxLsVGKUUJFaNLroOUa8URKSFHCg8lJJImMSpASJSk2CESKNZEsSqgIdzY3o9Vu29RQoGu12u3Q0CpQAavZLO9lAiLfbrGUzaSK0NTUhDNuD0DmcGO2Wax4PTyMLUYj9OR64NZNSDTc8nkuh96uQ9hhowYUUJnC31/q8SI4O4upmRnkCnnMRyL4tfZbNoVrmSEi0LqPRuZ6X5+CqrSt+KWEV1ZwcfQeXk6/L0XRlWWjCqQhK+Kww4GxoUFIbW21EfIo3snE9Ac8nXqDr+GfKJJRu0jjXmcXTjidMJM8lVCxw78Dubt8YLg51VATYTUS5Xn1ksroGvZ1J/wDgWQb5B0ivq0AAAAASUVORK5CYII=))。单击此按钮将打开一个对话框窗口,其中包含三个选项卡：详细信息,属性和内容。

![image.png](https://image.hyly.net/i/2025/09/28/f92d0c32100dd6c5109e9570a1447d8e-0.webp)

详细信息选项卡显示有关事件的各种详细信息,例如事件发生的时间,事件的类型以及生成事件的组件。显示的信息将根据事件类型而有所不同。此选项卡还显示有关已处理的FlowFile的信息。除了显示在详细信息选项卡左侧的FlowFile的UUID之外,与详细信息选项卡右侧显示的与该FlowFile相关的任何父文件或子级FlowFile的UUID也显示在该详细信息选项卡的右侧。

属性选项卡显示流程中该点上FlowFile中存在的属性。为了仅查看由于处理事件而修改的属性,用户可以选择属性选项卡右上角仅显示已修改旁边的复选框。

![image.png](https://image.hyly.net/i/2025/09/28/ac55983404e1f6f2384b55fe2a34f0be-0.webp)

##### 重播FlowFile

DFM可能需要在数据流中的某个点检查FlowFile的内容,以确保按预期处理它。如果没有正确处理,DFM可能需要调整数据流并再次重放FlowFile。查看详细信息对话框窗口的内容选项卡是DFM可以执行这些操作的位置。"内容"选项卡显示有关FlowFile内容的信息,例如其在内容存储库中的位置及其大小。此外,用户可以在此处单击Download按钮以下载流程中此时存在的FlowFile内容的副本。用户还可以单击该Replay按钮以在流程中的此时重放FlowFile。点击后Replay,FlowFile被发送到为生成此处理事件的组件提供的连接。

![image.png](https://image.hyly.net/i/2025/09/28/3c76f3ac21e8a8afff2371c52d1c763a-0.webp)

##### 查看FlowFile Lineage

查看FlowFile在数据流中采用的谱系或路径的图形表示通常很有用。要查看FlowFile的谱系,请单击![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAVCAMAAAB1/u6nAAAAAXNSR0IArs4c6QAAAPBQTFRFAEhJAElKAEpMAEtNAExOAU1PAk1PA09QBVBRClNUC1RVDlVWD1ZXEFdZE1haE1lbFlpcF1tcGFxdIGFiIWFiImJjJmVnJ2ZoKWdpKmhqMm5vOXFyOnNzPnZ2SX1/S3+ATYCAUIKDUoSFXYyMY4+QapSVa5SVbJWWbZeXeJ6efKGifaKjhaioiauriqusmLW2nbm5oby8pL+/pb+/qcLDtcrLuc3Nus7OzNra0N3d0t7f09/f1ODg2uTk2+Xl3ebm4+vr5+7u6/Dw6/Hx8PT08fX19ff39fj49/n5+Pn5+/z8/P39/f39/v7+/v//////XtBTeQAAAJZJREFUGNNj8McKGKgt7Gtj54sp7CPHwCjvjSFswGRqxmyIIazL6enFr4MhbMkmJcNii2mlioSCkIuvH5qwu6Cjv4YQt5IzsrCbkaqyv6+4iCavIpKwqzATo6SLI4OxvxYnkrAeu70Fo743n6yJmDSSsDaPhxOrrr85D6OoFZKwLYcAD5e9v7+Xgy+KS6zV1axpGN5IAAA6838q+wMlWAAAAABJRU5ErkJggg==)Data Provenance表的最右侧列中的"Show Lineage"图标。这将打开一个图形,显示FlowFile(![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAgCAMAAACvkzHFAAAAAXNSR0IArs4c6QAAAU1QTFRFBQUFBgYGBwcHCwsLDg4ODw8PEhISKCgoKioqMDAwNDQ0NjY2Nzc3OTk5Pz8/QUFCQUJCQkNDRUZGU1NTVFRUV1dXWFhYWlpaW1tbZ2dnampqa2trbm5uc3NzdnZ2d3d3hYWGhoaHiYmKjo6PkJGSkZKTk5SUlJWWl5iYmpubm5ycnp+fpKSkp6enrpiXr5uasJybsp6ds6CftKGgtaKhtaKitqOiuKemuaemubm5u6qpvLy8vayrvb29v6+uwLCvwMDAw8TFxLa1xMXGyLq6ybu6z8PC1MnJ1crJ1dXV19fX2M7N2Nna29LS29zd3N3d3N3e3tXV3t/g3+Dg4dnZ4tvb5N3c5uDg5+Hh5+jp6OLi6uvs6+bm6+zt7Ojn7ejo7unp7u/w7+vr8e3t8vP08/T19PDw9PX29vPz9/X1+fr7+vj4+vn5+/r6////c+jPwQAAAYpJREFUOMt91OdbgkAcB3DcA620yNDcmrgo22Zq03JUVjZMrWxYkt3//7LjQISD/L66393nebgJwU3SCFEWvYOmHXoLFW5O+olJM+oMZmsApZYN2GNq055ZBor4ZjuYYcwHAEvRlFSYlSWgEYqRGUaTQJSSTNuMjf1c1Ov1F9gw9sZmBp/L+Xq5vJeDjYJLNFH5ip7LpVNQOQGgy/KlN45Mw4kG31swr+CaZXdkBpBXvAkFUZFjYSqiORoM7gTjj/CGyqKClZkW3y6h7oyHN5aayoDRcDgU5le1QvOhB5hZa93DiAboPgnu0IEbIY+iIY8JLkFPN3RCZZ42N1C23mQG+5Yq/LcUc97/Hgn5lQzxha1dyvaYoLUr9lBthD0MB6YZ4Swu7dOM7RbdjZiPL1YVZldauXjH5oqwejiTpyuQvHt8Dzsm8E8MfenOJxe1yXxa9nYYSosspBRvMGUs4CJvSGNvuefyKgnt7qv/CXHSn6mKB5Dx2xJa/w2uGfFYdSRNk4TVE7mZ9P8BIm16T16xKZMAAAAASUVORK5CYII=))和已发生的各种处理事件。所选事件将以红色突出显示。它可以右键单击或任何事件双击看到事件的详细信息(参见事件的详细信息)。要查看谱系如何随时间演变,请单击窗口左下角的滑块并将其向左移动以查看数据流中较早阶段的谱系状态。

![image.png](https://image.hyly.net/i/2025/09/28/baabed275102f62daff184e2fffe8c71-0.webp)

###### 找到Parents

有时,用户可能需要跟踪从中生成另一个FlowFile的原始FlowFile。例如,当发生FORK或CLONE事件时,NiFi会跟踪生成其他FlowFiles的父FlowFile,并且可以在Lineage中找到父FlowFile。右键单击沿袭图中的事件,然后从上下文菜单中选择"查找父项"。

![image.png](https://image.hyly.net/i/2025/09/28/385b7a83197031f98dc1f2d4d18d5726-0.webp)

选择"Find parents"后,将重新绘制图形以显示父FlowFile及其谱系以及子项及其谱系。

![image.png](https://image.hyly.net/i/2025/09/28/f7831789df32fc1d81f2f4beb3d47f56-0.webp)

###### 扩展活动

与查找父FlowFile有用的方式相同,用户可能还想确定从给定FlowFile生成的子项。要执行此操作,请右键单击沿袭图中的事件,然后从上下文菜单中选择"展开"。

![image.png](https://image.hyly.net/i/2025/09/28/eb74429eabb2ab956d0a4106cd4348a5-0.webp)

选择"Expand"后,将重新绘制图形以显示子项及其谱系。

![image.png](https://image.hyly.net/i/2025/09/28/db6f78349ad71e1a6344c0aea573afb5-0.webp)

##### 操作

![image.png](https://image.hyly.net/i/2025/09/28/1d898b022a24dec554abcafa5ee2d3b3-0.gif)

### 连接与关系

将处理器和其他组件添加到画布并进行配置后,下一步是将它们彼此连接,以便让NiFi知道在处理完每个FlowFile后如何传输数据。这是通过在每个组件之间创建连接来实现的。当用户将鼠标悬停在组件的中心上时,会出现一个新的连接图标![image.png](https://image.hyly.net/i/2025/09/28/ae11ab3f3349d9782493f08cf1386f99-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/1704264177cbb9a92392f16b09112c7f-0.webp)

用户将连接图标从一个组件拖动到另一个组件当用户释放鼠标时,会出现创建连接对话框。该对话框包含两个选项卡：详细信息和设置。它们将在下面详细讨论。请注意,可以绘制在同一处理器上循环的连接。如果DFM希望处理器在失败关系时尝试重新处理FlowFiles,这将非常有用。要创建这种类型的循环连接,只需将连接图标拖离,然后再返回到同一处理器,然后释放鼠标,出现相同的创建连接对话框。

#### 细节

创建连接对话框的详细信息选项卡提供有关上下游组件的信息,包括组件名称,组件类型和组件所在的进程组：

![image.png](https://image.hyly.net/i/2025/09/28/4caf0bc09c0b230e748e99c7076474c7-0.webp)

此外,此选项卡还提供了选择此Connection中应包含哪些关系的功能。必须至少选择一个关系。如果只有一个关系可用,则会自动选择它。

![image.png](https://image.hyly.net/i/2025/09/28/56d9c0e4286eacfe5ca04b1b369583e3-0.webp)如果使用相同的关系添加多个Connections,则路由到该关系的任何FlowFile将自动clone,并且将向每个Connections发送一个副本。

#### 设置

设置选项卡提供配置连接名称,FlowFile到期,背压阈值,负载平衡策略和优先级的功能：

![image.png](https://image.hyly.net/i/2025/09/28/55c9fcf68a69c5b99362488a4cac6476-0.webp)

连接名称是可选的。如果未指定,则为Connection显示的名称将是Connection的活动关系的名称。

##### FlowFile到期

FlowFile到期是一个概念,通过该概念可以自动从流中删除无法及时处理的积压数据。在这种情况下,到期可以与优先级排序器一起使用,以确保首先处理最高优先级数据,然后可以丢弃在特定时间段(例如,一小时)内无法处理的任何内容。到期时间基于数据进入NiFi实例的时间。换句话说,如果给定连接上的文件到期时间设置为1小时,并且已经在NiFi实例中存在一小时的文件到达该连接,则该文件将过期。默认值为0 sec表示数据永不过期。当设置了0秒以外的文件到期时,连接标签上会出现一个小时钟图标,因此在查看画布上的流时,DFM可以一目了然地看到它。

![image.png](https://image.hyly.net/i/2025/09/28/17c8e15687f6068efe7d7a3665929b85-0.webp)

##### 背压

NiFi为背压提供两种配置元素。这些阈值表示允许在队列中存在多少数据。这允许系统避免数据溢出。提供的第一个选项是Back pressure object threshold(背压对象阈值)。这是在应用背压之前可以在队列中的FlowFiles的数量。第二个配置选项是Back pressure data size threshold(背压数据大小阈值)。这指定了在应用反压之前应排队的最大数据量(大小)。通过输入数字后跟数据大小(B对于字节,KB对于千字节,MB对于兆字节,GB对于千兆字节或TB对于太字节)来配置此值。

![image.png](https://image.hyly.net/i/2025/09/28/5b51d27b6647bf80ece30287c28cf97a-0.webp)默认情况下,添加的每个新连接都将具有默认的背压对象阈值10000 objects和背压数据大小阈值1 GB。可以通过修改nifi.properties文件中的相应属性来更改这些默认值：

```shell
#对象数量阈值
nifi.queue.backpressure.count=10000
#数据大小阈值
nifi.queue.backpressure.size=1 GB
```

启用背压时,连接标签上会出现小进度条,因此在查看画布上的流时,DFM可以一目了然地看到它。进度条根据队列百分比更改颜色：绿色(0-60％),黄色(61-85％)和红色(86-100％)。

![image.png](https://image.hyly.net/i/2025/09/28/a89e941a609eb34742aba4337c3cd8ef-0.webp)

将鼠标悬停在条形图上会显示确切的百分比。

![image.png](https://image.hyly.net/i/2025/09/28/d5843e8c9cb3796c5535970068d65558-0.webp)

队列完全填满后,Connection将以红色突出显示。

![image.png](https://image.hyly.net/i/2025/09/28/db9f7f139fc9a6bb6e606317566f2767-0.webp)

##### 负载均衡

###### 负载平衡策略

为了在集群中的节点之间分配流中的数据,NiFi提供以下负载平衡策略：

- **不负载平衡**：不在集群中的节点之间平衡FlowFile。这是默认值。
- **按属性划分**：根据用户指定的FlowFile属性的值确定将给定FlowFile发送到哪个节点。具有相同Attribute值的所有FlowFile将发送到集群中的同一节点。如果目标节点与集群断开连接或无法通信,则数据不会故障转移到另一个节点。数据将排队,等待节点再次可用。此外,如果节点加入或离开集群需要重新平衡数据,则应用一致性散列以避免必须重新分发所有数据。
- **循环**：FlowFiles将以循环方式分发到集群中的节点。如果节点与集群断开连接或无法与节点通信,则排队等待该节点的数据将自动重新分发到另一个节点。
- **单个节点**：所有FlowFiles将发送到集群中的单个节点。它们被发送到哪个节点是不可配置的。如果节点与集群断开连接或无法与节点通信,则排队等待该节点的数据将保持排队,直到该节点再次可用。

![image.png](https://image.hyly.net/i/2025/09/28/7f4cabe95ff451f1526d7fa416b0b558-0.webp)NiFi会在重新启动时持久保存集群中的节点。这可以防止在所有节点都已连接之前重新分配数据。如果集群已关闭且不打算重新启动节点,则用户有责任通过UI中的集群对话框从集群中删除该节点。

###### 负载平衡压缩

###### 负载平衡策略

为了在集群中的节点之间分配流中的数据,NiFi提供以下负载平衡策略：

- **不负载平衡**：不在集群中的节点之间平衡FlowFile。这是默认值。
- **按属性划分**：根据用户指定的FlowFile属性的值确定将给定FlowFile发送到哪个节点。具有相同Attribute值的所有FlowFile将发送到集群中的同一节点。如果目标节点与集群断开连接或无法通信,则数据不会故障转移到另一个节点。数据将排队,等待节点再次可用。此外,如果节点加入或离开集群需要重新平衡数据,则应用一致性散列以避免必须重新分发所有数据。
- **循环**：FlowFiles将以循环方式分发到集群中的节点。如果节点与集群断开连接或无法与节点通信,则排队等待该节点的数据将自动重新分发到另一个节点。
- **单个节点**：所有FlowFiles将发送到集群中的单个节点。它们被发送到哪个节点是不可配置的。如果节点与集群断开连接或无法与节点通信,则排队等待该节点的数据将保持排队,直到该节点再次可用。

![image.png](https://image.hyly.net/i/2025/09/28/ed9f505ae7a359aee44f099c829b8b35-0.webp)NiFi会在重新启动时持久保存集群中的节点。这可以防止在所有节点都已连接之前重新分配数据。如果集群已关闭且不打算重新启动节点,则用户有责任通过UI中的集群对话框从集群中删除该节点。

###### 负载平衡压缩

选择负载平衡策略后,用户可以配置在集群中的节点之间传输时是否应压缩数据。

![image.png](https://image.hyly.net/i/2025/09/28/9cb0269a7e6bcc0f28cb8fe6718294d8-0.webp)

可以使用以下压缩选项：

- **不压缩**：FlowFiles不会被压缩。这是默认值。
- **仅压缩属性**：将压缩FlowFile属性,但不会压缩FlowFile内容。
- **压缩属性和内容**：将压缩FlowFile属性和内容。

###### 负载平衡指示器

为连接实施负载平衡策略后,连接负载平衡图标上![img](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABcAAAAXCAYAAADgKtSgAAAAAXNSR0IArs4c6QAAAtJJREFUSA21lftPE0EQx79310Lpk/IyIq8ggiUgIgRR1BCMJpLoD/7uH2jiL5qQGIOJFdAAPtAUiEIEAvKQV+mDvrjWmTW3udOCLQnTXHe6N/vZ2dmZqZIjwRmJWgw3lc6gGFdsJ8GTqTTmV9YQWljGXiSKJMFLbDb43C4EmuvR0dwAj8t5LEI5LiyhxRWMTExjY2cPup5FNpuFqqrQ6OFIciyry72429eFG1cCUBTln03ywkenZvDy3UekMxko9PF5XKitrkTsMIH17V0J0mlDlttd7Xg02A87ncos1l/0ZnruO0bGppAl75xlDgxe60RfRysqvB6MfZ7Fs9fjsGmaYBinePMpBKfTgQc3e81sWOC/9sJ4EZykEOQolmV4MjyEtqY6ucDwVE6QwuGw2zSMTs7gYl0tWhtq5WtLtrDX4Wgcqqbi4Z3rFrBckUfhDTJHOiZmZsVdGCYSnkil8JWygqXpfA16Ai1CL/RLI4cWV9fBpzdEwvcjMUTih2I+0FQv42oY/m9UyftYIondg6g0lfA4veA85kuq8nulQTEKp2g4GpNLJFxRVEo6EiUnLlRaFKmoxDFEam5KO0dpiSiYLVPcDMNCRr7YcqoJQyTc73PD73HTvIL5pVUqoCPDpqCRK9hLraCKqtYQCS+129Hd1ixSaW1rBxNf5gybgsYjahGXKRHywpnQ296KcxU+ZGkLLv/puYWCwFzNLgrrravtFnvpOc9yvB4PDYjOl0yn8fRVkJ63WN3cpkxKi4ZlWU0/OEO4cocHetFI9WGWvI1rMvQNz4PvEY0nqbyBMrroKr8PGbqHnXBElDx3RV3XYddsuNffLR7OdbPkhbPB8sYWRsY/YOnnJv78SeQEVFUV4S03rws1lbjf34POlkYzU+rHwtmCj/yD4Jw92/sHVMEJuKn7VVJmXWqoE03q7zYryaScCDcbnka3XOhpACetOVP4bzr/HXCSg3ImAAAAAElFTkSuQmCC)将显示负载平衡指示符：

![image.png](https://image.hyly.net/i/2025/09/28/96c7892e52de16571e378efb8c33a067-0.webp)

将鼠标悬停在该图标上将显示连接的负载平衡策略和压缩配置。此状态下的图标还表示连接中的所有数据都已在集群中分布。

![image.png](https://image.hyly.net/i/2025/09/28/e002bfbe8e863f393ef24fad7ac9706e-0.webp)

当在集群中的节点之间主动传输数据时,负载平衡指示器将更改方向和颜色：

![image.png](https://image.hyly.net/i/2025/09/28/3ef5f1c0726ca4b8bcbdf12eaf822a4c-0.webp)

###### 集群连接摘要

要查看在集群节点之间分配数据的位置,请从全局菜单中选择摘要。然后选择Connections选项卡和View Connection Details：

![image.png](https://image.hyly.net/i/2025/09/28/ea935f8d8edd7a3fa48f936ac9ed1247-0.webp)

这将打开集群连接摘要对话框,该对话框显示集群中每个节点上的数据：

![image.png](https://image.hyly.net/i/2025/09/28/65464555ec9dbf6c41e22590f3d93254-0.webp)

##### 优先级

选项卡的右侧提供了对队列中数据进行优先级排序的功能，以便首先处理更高优先级的数据。优先级可以从顶部(可用的优先级排序器)拖动到底部(选择的优先级排序器)。可以选择多个优先级排序器。位于所选优先级列表顶部的优先级排序是最高优先级。如果两个FlowFiles根据此优先级排序器具有相同的值，则第二个优先级排序器将确定首先处理哪个FlowFile,依此类推。如果不再需要优先级排序器，则可以将其从选定的优先级排序器列表拖动到可用的优先级排序器列表。

可以使用以下优先顺序：

- **FirstInFirstOutPrioritizer**：给定两个FlowFiles,首先处理首先到达连接的FlowFiles。
- **NewestFlowFileFirstPrioritizer**：给定两个FlowFiles,将首先处理数据流中最新的FlowFiles。
- **OldestFlowFileFirstPrioritizer**：给定两个FlowFiles,将首先处理数据流中最旧的FlowFiles。这是在没有选择优先级的情况下使用的默认方案。
- **PriorityAttributePrioritizer**：给定两个FlowFiles,将提取名为priority的属性。将首先处理具有最低优先级值的那个。
  - 请注意，应使用UpdateAttribute处理器在FlowFiles到达具有此优先级设置的连接之前将priority属性添加到FlowFiles。
  - 如果只有一个具有该属性，它将首先出现。
  - priority属性的值可以是字母数字，其中"a"将出现在"z"之前，"1"出现在"9"之前。
  - 如果priority属性无法解析为long型数字，则将使用unicode字符串排序。例如："99"和"100"将被排序，因此带有"99"的流文件首先出现，但"A-99"和"A-100"将排序，因此带有"A-100"的流文件首先出现。

![image.png](https://image.hyly.net/i/2025/09/28/93deb5e85b2d685f1fefd0d9ab2d7924-0.webp)配置了负载平衡策略后，连接除了本地队列外，每个集群节点都有一个队列。优先排序器将独立地对每个队列中的数据进行排序。

#### 更改配置和上下文菜单选项

在两个组件之间建立连接之后，可以更改连接的配置，并且可以将连接移动到新目的地;但是，必须先停止连接任一侧的处理器，然后才能进行配置或目标更改。

![image.png](https://image.hyly.net/i/2025/09/28/6df9bf3d08baa3fb132bf991cd57323c-0.webp)

要更改连接的配置或以其他方式与连接交互,请右键单击连接以打开连接上下文菜单。

![image.png](https://image.hyly.net/i/2025/09/28/2ef163f769a6560474adfa7ea1ff42e0-0.webp)

可以使用以下选项：

- **Configure**：此选项允许用户更改连接的配置。
- **View status history**：此选项打开连接统计信息随时间的图形表示。
- **List queue**：此选项列出可能正在等待处理的FlowFiles队列。
- **Go to source**：如果画布上连接的源组件和目标组件之间有很长的距离,则此选项很有用。通过单击此选项,画布视图将跳转到连接源。
- **Go to destination**：与"转到源"选项类似,此选项将视图更改为画布上的目标组件,如果两个连接的组件之间存在较长距离,则此选项可能很有用。
- **Bring to front**：如果其他东西(例如另一个连接)与其重叠,则此选项将连接带到画布的前面。
- **Empty queue**：此选项允许DFM清除可能正在等待处理的FlowFiles队列。当DFM不关心从队列中删除数据时,此选项在测试期间特别有用。选择此选项后,用户必须确认是否要删除队列中的数据。
- **Delete**：此选项允许DFM删除两个组件之间的连接。请注意,必须先停止连接两侧的组件,并且连接必须为空才能删除。

#### 弯曲连接

要向现有连接添加弯曲点(或弯头),只需双击要弯曲点所在位置的连接即可。然后,您可以使用鼠标抓住弯曲点并拖动它,以便以所需的方式弯曲连接。您可以根据需要添加任意数量的弯曲点。您还可以使用鼠标将连接上的标签拖动并移动到任何现有折弯点。要删除折弯点,只需再次双击即可。

![image.png](https://image.hyly.net/i/2025/09/28/f593386b9cba16c4c31ecaf63a6a61dd-0.webp)

#### 操作

修改第二个处理器：ReplaceText，Replacement Value改为【a,b,c】，这样便不会被下一个ExtractText处理器所捕获。

![image.png](https://image.hyly.net/i/2025/09/28/cf2bf3a79f012852cfec887a99196a4c-0.gif)

启动处理器观察数据流向

![image.png](https://image.hyly.net/i/2025/09/28/ec76b24bae58e3a4b15df6867f95ddf7-0.gif)

将未匹配到的FlowFile发送到LogAttribute组件，观察流向

![image.png](https://image.hyly.net/i/2025/09/28/f8b05db1db904c30591220c77567f848-0.gif)

修改ReplaceText的Replacement Value改为【a,b,c,d】

![image.png](https://image.hyly.net/i/2025/09/28/e76acdb6390a597cfbb9719bd6a034db-0.gif)

## NIFI典型案例

**课程目标**

1、离线同步Mysql数据到DFS

2、Json内容转换为Hive支持的文本格式

3、实时同步Mysql数据到Hive

4、Kafka的使用

### 离线同步Mysql数据到hdfs

大数据数据仓库系统中，经常需要进行数据同步操作，可以使用nifi来进行灵活的全流程操作。

**准备工作：**

1. 启动Mysql服务(5.7版本)，在Mysql中运行 `\资料\mysql\nifi_test.sql`中的SQL语句。
2. 启动Hadoop集群(与NiFi集群在同一个可访问的局域网网段)

#### 处理器流程

QueryDatabaseTable	——>	ConvertAvroToJSON	——>	SplitJson	——>	PutHDFS

QueryDatabaseTable读取Mysql数据，ConvertAvroToJSON将数据转换为可阅读的Json格式，再通过SplitJson进行切割获得单独的对象，PutHDFS将所有对象写入HDFS中。

#### 处理器说明

##### QueryDatabaseTable

###### 描述

生成SQL选择查询，或使用提供的语句，并执行该语句以获取其指定的“最大值”列中的值大于先前看到的最大值的所有行。查询结果将转换为Avro格式。几种属性都支持表达式语言，但不允许传入连接。变量注册表可用于为包含表达式语言的任何属性提供值。如果需要利用流文件属性来执行这些查询，则可以将GenerateTableFetch和/或ExecuteSQL处理器用于此目的。使用流技术，因此支持任意大的结果集。使用标准调度方法，可以将该处理器调度为在计时器或cron表达式上运行。该处理器只能在主节点上运行。

###### 属性配置

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示所有默认值，以及属性是否支持NiFi表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Database Connection Pooling Service</strong></td><td>&nbsp;</td><td style='text-align:left;' >用于获得与数据库的连接的Controller Service。&#x3c;br&gt;DBCPConnectionPoolLookup&#x3c;br/&gt;DBCPConnectionPoo&#x3c;br/&gt;HiveConnectionPool</td></tr><tr><td style='text-align:left;' ><strong>Database Type</strong></td><td>泛型</td><td style='text-align:left;' >数据库的类型/风格，用于生成特定于数据库的代码。在许多情况下，通用类型就足够了，但是某些数据库（例如Oracle）需要自定义SQL子句。&#x3c;br&gt;Generic&#x3c;br/&gt;Oracle&#x3c;br/&gt;Oracle 12+&#x3c;br/&gt;MS SQL 2012+&#x3c;br/&gt;MS SQL 2008&#x3c;br/&gt;MySQL</td></tr><tr><td style='text-align:left;' ><strong>Table Name</strong></td><td>&nbsp;</td><td style='text-align:left;' >要查询的数据库表的名称。使用自定义查询时，此属性用于别名查询，并在FlowFile上显示为属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Columns to Return</td><td>&nbsp;</td><td style='text-align:left;' >查询中要使用的列名的逗号分隔列表。如果您的数据库需要对名称进行特殊处理（例如，引号），则每个名称都应包括这种处理。如果未提供任何列名，则将返回指定表中的所有列。注意：对于给定的表使用一致的列名很重要，这样增量提取才能正常工作。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Additional WHERE clause</td><td>&nbsp;</td><td style='text-align:left;' >构建SQL查询时要在WHERE条件中添加的自定义子句。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Custom Query</td><td>&nbsp;</td><td style='text-align:left;' >用于检索数据的自定义SQL查询。代替从其他属性构建SQL查询，此查询将包装为子查询。查询必须没有ORDER BY语句。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Maximum-value Columns</td><td>&nbsp;</td><td style='text-align:left;' >列名的逗号分隔列表。自处理器开始运行以来，处理器将跟踪返回的每一列的最大值。使用多列意味着列列表的顺序，并且期望每列的值比前一列的值增长得更慢。因此，使用多个列意味着列的层次结构，通常用于分区表。该处理器只能用于检索自上次检索以来已添加/更新的那些行。请注意，某些JDBC类型（例如位/布尔值）不利于保持最大值，因此这些类型的列不应在此属性中列出，并且会在处理期间导致错误。如果未提供任何列，则将考虑表中的所有行，这可能会对性能产生影响。注意：对于给定的表使用一致的最大值列名称很重要，这样增量提取才能正常工作。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Max Wait Time</strong></td><td>0秒</td><td style='text-align:left;' >正在运行的SQL选择查询所允许的最长时间，零表示没有限制。少于1秒的最长时间将等于零。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Fetch Size</strong></td><td>0</td><td style='text-align:left;' >一次要从结果集中获取的结果行数。这是对数据库驱动程序的提示，可能不被尊重和/或精确。如果指定的值为零，则忽略提示。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Max Rows Per Flow File</strong></td><td>0</td><td style='text-align:left;' >一个FlowFile中将包含的最大结果行数。这将使您可以将非常大的结果集分解为多个FlowFiles。如果指定的值为零，那么所有行都将在单个FlowFile中返回。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Output Batch Size</strong></td><td>0</td><td style='text-align:left;' >提交流程会话之前要排队的输出FlowFiles的数量。设置为零时，将在处理所有结果集行并且输出FlowFiles准备好转移到下游关系时提交会话。对于较大的结果集，这可能导致在处理器执行结束时传输大量的FlowFiles。如果设置了此属性，则当指定数量的FlowFiles准备好进行传输时，将提交会话，从而将FlowFiles释放到下游关系。注意：设置此属性后，将不会在FlowFiles上设置maxvalue。*和fragment.count属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Maximum Number of Fragments</strong></td><td>0</td><td style='text-align:left;' >最大片段数。如果指定的值为零，那么将返回所有片段。当此处理器提取大表时，这可以防止OutOfMemoryError。注意：设置此属性可能会导致数据丢失，因为未按顺序排列传入结果，并且片段可能会在任意边界处终止，其中结果集中不包含行。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Normalize Table/Column Names</strong></td><td>假</td><td style='text-align:left;' >是否将列名中的非Avro兼容字符更改为Avro兼容字符。例如，冒号和句号将更改为下划线，以建立有效的Avro记录。&#x3c;br&gt;真正&#x3c;br/&gt;假</td></tr><tr><td style='text-align:left;' >Transaction Isolation Level</td><td>&nbsp;</td><td style='text-align:left;' >此设置将为支持此设置的驱动程序设置数据库连接的事务隔离级别。TRANSACTION_NONE&#x3c;br/&gt;TRANSACTION_READ_COMMITTED&#x3c;br/&gt;TRANSACTION_READ_UNCOMMITTED&#x3c;br/&gt;TRANSACTION_REPEATABLE_READ&#x3c;br/&gt;TRANSACTION_SERIALIZABLE</td></tr><tr><td style='text-align:left;' ><strong>Use Avro Logical Types</strong></td><td>假</td><td style='text-align:left;' >是否对DECIMAL / NUMBER，DATE，TIME和TIMESTAMP列使用Avro逻辑类型。如果禁用，则写为字符串。如果启用，则使用逻辑类型并将其写为其基础类型，特别是DECIMAL / NUMBER为逻辑“十进制”：以具有附加精度和小数位元数据的字节形式写入，DATE为逻辑“ date-millis”：以int表示天自Unix时代（1970-01-01）起，TIME为逻辑&#39;time-millis&#39;：写为int，表示自Unix纪元以来的毫秒数； TIMESTAMP为逻辑&#39;timestamp-millis&#39;：写为长时，表示自Unix纪元以来的毫秒数。如果书面Avro记录的阅读者也知道这些逻辑类型，则可以根据阅读器的实现在更多上下文中反序列化这些值。&#x3c;br&gt;真正&#x3c;br/&gt;假</td></tr><tr><td style='text-align:left;' ><strong>Default Decimal Precision</strong></td><td>10</td><td style='text-align:left;' >当将DECIMAL / NUMBER值写入为“十进制” Avro逻辑类型时，需要表示可用位数的特定“精度”。通常，精度是由列数据类型定义或数据库引擎默认定义的。但是，某些数据库引擎可以返回未定义的精度（0）。写入那些未定义的精度数字时，将使用“默认十进制精度”。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Default Decimal Scale</strong></td><td>0</td><td style='text-align:left;' >当将DECIMAL / NUMBER值写入为“十进制” Avro逻辑类型时，需要一个特定的“标度”来表示可用的十进制数字。通常，规模是由列数据类型定义或数据库引擎默认定义的。但是，当返回未定义的精度（0）时，某些数据库引擎的比例也可能不确定。写入那些未定义的数字时，将使用“默认小数位数”。如果一个值的小数位数超过指定的小数位数，那么该值将被四舍五入，例如1.53在小数位数为0时变为2，在小数位数1时变为1.5。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr></tbody>
</table></figure>

##### ConvertAvroToJSON

###### 描述

将Binary Avro记录转换为JSON对象。该处理器提供了Avro字段到JSON字段的直接映射，因此，生成的JSON将具有与Avro文档相同的层次结构。请注意，Avro模式信息将丢失，因为这不是从二进制Avro到JSON格式的Avro的转换。输出JSON编码为UTF-8编码。如果传入的FlowFile包含多个Avro记录的流，则生成的FlowFile将包含一个JSON Array，其中包含所有Avro记录或JSON对象序列。如果传入的FlowFile不包含任何记录，则输出为空JSON对象。空/单个Avro记录FlowFile输入可以根据“包装单个记录”的要求选择包装在容器中。

###### 属性配置

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值</th><th>允许值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>JSON容器选项</strong></td><td>数组</td><td>没有数组</td><td style='text-align:left;' >确定如何显示记录流：作为单个Object序列（无）（即，将每个Object写入新行），或者作为Objects数组（array）。</td></tr><tr><td style='text-align:left;' ><strong>包装单条记录</strong></td><td>假</td><td>真正假</td><td style='text-align:left;' >确定是否将空记录或单个记录的结果输出包装在“ JSON容器选项”指定的容器数组中</td></tr><tr><td style='text-align:left;' >Avro模式</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >如果Avro记录不包含架构（仅基准），则必须在此处指定。</td></tr></tbody>
</table></figure>

##### SplitJson

###### 描述

该处理器使用JsonPath表达式指定需要的数组元素，将JSON数组分割为多个单独的流文件。每个生成的流文件都由指定数组的一个元素组成，并传输到关系“split”，原始文件传输到关系“original”。如果没有找到指定的JsonPath，或者没有对数组元素求值，则将原始文件路由到“failure”，不会生成任何文件。

该处理器需要使用人员掌握JsonPath表达式语言。

###### 属性配置

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >属性名称</th><th style='text-align:left;' >默认值</th><th style='text-align:left;' >可选值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >JsonPath Expression</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >&nbsp;</td><td style='text-align:left;' >一个JsonPath表达式，它指定用以分割的数组元素。</td></tr><tr><td style='text-align:left;' >Null Value Representation</td><td style='text-align:left;' >1</td><td style='text-align:left;' >empty string&#x3c;br&gt;the string &#39;null&#39;</td><td style='text-align:left;' >指定结果为空值时的表示形式。</td></tr></tbody>
</table></figure>

##### PutHDFS

###### 描述

将FlowFile数据写入Hadoop分布式文件系统（HDFS）

###### 属性配置

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示所有默认值，以及属性是否支持NiFi表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值&#x3c;br&gt;</th><th>允许值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >Hadoop Configuration Resources</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >由文件或逗号分隔的文件列表，其中包含Hadoop文件系统配置。否则，Hadoop将在类路径中搜索“ core-site.xml”和“ hdfs-site.xml”文件，或者将恢复为默认配置。要使用swebhdfs，请参阅PutHDFS文档的“其他详细信息”部分。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Credentials Service</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >指定应用于Kerberos身份验证的Kerberos凭据控制器服务</td></tr><tr><td style='text-align:left;' >Kerberos Principal</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >Kerberos主体作为身份验证。需要在您的nifi.properties中设置nifi.kerberos.krb5.file。<strong>支持的表达语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Keytab</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >与主体关联的Kerberos密钥表。需要在您的nifi.properties中设置nifi.kerberos.krb5.file。<strong>支持的表达语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Relogin Period</td><td>4小时</td><td>&nbsp;</td><td style='text-align:left;' >尝试重新登录kerberos之前应该经过的时间。此属性已被弃用，并且对处理没有影响。现在，重新登录会自动发生。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Additional Classpath Resources</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >以逗号分隔的文件和/或目录的路径列表，该列表将添加到类路径中，并用于加载本机库。指定目录时，该目录中所有具有的文件都将添加到类路径中，但不包括其他子目录。</td></tr><tr><td style='text-align:left;' ><strong>Directory</strong></td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >文件应写入的父HDFS目录。如果目录不存在，将创建该目录。<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Conflict Resolution Strategy</strong></td><td>失败</td><td>更换&#x3c;br&gt;忽视 &#x3c;br/&gt;失败 &#x3c;br&gt;附加</td><td style='text-align:left;' >指示当输出目录中已经存在同名文件时应该怎么办</td></tr><tr><td style='text-align:left;' >Block Size</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >写入HDFS的每个块的大小。这将覆盖Hadoop配置</td></tr><tr><td style='text-align:left;' >IO Buffer Size</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >IO期间用于缓冲文件内容的内存量。这将覆盖Hadoop配置</td></tr><tr><td style='text-align:left;' >Replication</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >HDFS复制每个文件的次数。这将覆盖Hadoop配置</td></tr><tr><td style='text-align:left;' >Permissions umask</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >用八进制数表示的umask，用于确定写入HDFS的文件的权限。这将覆盖Hadoop属性“ fs.permissions.umask-mode”。如果未定义此属性和“ fs.permissions.umask-mode”，则将使用Hadoop默认值“ 022”。</td></tr><tr><td style='text-align:left;' >Remote Owner</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >写入后，将HDFS文件的所有者更改为此值。仅当NiFi以具有HDFS超级用户特权来更改所有者的用户身份运行时才有效<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Remote Group</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >写入后，将HDFS文件的组更改为此值。仅当NiFi以具有HDFS超级用户特权来更改组的用户身份运行时才有效<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Compression codec</strong></td><td>没有</td><td>没有   默认  邮编   邮编  LZ4 LZO   贪睡   自动</td><td style='text-align:left;' >没有描述。</td></tr><tr><td style='text-align:left;' >Ignore Locality</td><td>假</td><td>真正假</td><td style='text-align:left;' >指示HDFS系统忽略位置规则，以便在群集中随机分配数据</td></tr></tbody>
</table></figure>

#### 操作

##### 创建组

![image.png](https://image.hyly.net/i/2025/09/28/015dc290e3d6514890230ee055cc702f-0.gif)

##### 创建QueryDatabaseTable

![image.png](https://image.hyly.net/i/2025/09/28/f769bb1bb29a59650961cf8e370fcdb3-0.gif)

##### 创建并配置Mysql连接池

**创建连接池**

![image.png](https://image.hyly.net/i/2025/09/28/66e2ed3ca16d4a2520fdd7b26378e2ed-0.gif)

**配置连接池**

![image.png](https://image.hyly.net/i/2025/09/28/4909c6f3ea4bb9aed7396f7dc843817c-0.webp)

```properties
Database Connection URL = jdbc:mysql://192.168.52.6:3306/nifi_test?characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true
Database Driver Class Name = com.mysql.jdbc.Driver
#此处的jar包需要提前上传到nifi服务器中
Database Driver Location(s) = /export/download/jars/mysql-connector-java-5.1.40.jar
Database User = root
Password = 123456
```

**启动连接池**

![image.png](https://image.hyly.net/i/2025/09/28/c168fb24fc4dc014d9bce6243408f4c0-0.gif)

##### 配置QueryDatabaseTable

![image.png](https://image.hyly.net/i/2025/09/28/f9ada4df299e41729f3c8f8c643afea2-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/a9500cca4558b3b86fb0606c3063fbd1-0.webp)

```properties
Custom Query = select id,name,mobile,email,son_json from user_info_nifi limit 15
```

##### 创建配置ConvertAvroToJSON

**创建配置ConvertAvroToJSON**

![image.png](https://image.hyly.net/i/2025/09/28/846da4d55ee43bda3ac6c43b3707afee-0.gif)

**连接**

![image.png](https://image.hyly.net/i/2025/09/28/a4292a38e10b3865a551ea2ef3dbb2d7-0.gif)

**负载均衡消费数据**

![image.png](https://image.hyly.net/i/2025/09/28/e3e5e830e9be1571c0892554441416b2-0.gif)

##### 创建配置SplitJson

**SplitJson配置**

![image.png](https://image.hyly.net/i/2025/09/28/809873d95159602210d3e027337429de-0.webp)

```properties
JsonPath Expression = $.*
```

**连接**

![image.png](https://image.hyly.net/i/2025/09/28/cbcf5f204b2123b573d309e001239a43-0.gif)

##### 创建配置PutHDFS

![image.png](https://image.hyly.net/i/2025/09/28/db6ce66782520f3259624566073d57d1-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/a4c5ab7882e2ccb6c69c5815babbcdb8-0.webp)

```properties
Hadoop Configuration Resources = /export/download/config/hdfs-site.xml,/export/download/config/core-site.xml
Directory = /user/hive/warehouse/nifi_test.db/user_info_nifi
Conflict Resolution Strategy = append
```

##### 运行查看效果

###### 启动QueryDatabaseTable，并查看队列中数据

![image.png](https://image.hyly.net/i/2025/09/28/a5273208024237320bce39fb801369ab-0.gif)

###### 启动ConvertAvroToJSON，并查看队列中数据

![image.png](https://image.hyly.net/i/2025/09/28/8af017995973dd1f005a131225e483c9-0.gif)

###### 启动SplitJson，并查看队列中数据

![image.png](https://image.hyly.net/i/2025/09/28/6748a56c3c5642b5cf73d8cf026af7ab-0.gif)

###### 启动PutHDFS，并查看处理器接收和输出的数据

![image.png](https://image.hyly.net/i/2025/09/28/3b7aab42bdb2ef564dfea7b85a4e9a1b-0.gif)

###### 查看HDFS数据

![image.png](https://image.hyly.net/i/2025/09/28/a67c9ce6ddcd1ae6de01bd2b45bdfc97-0.gif)

### Json内容转换为Hive支持的文本格式

在向HDFS同步数据的示例中，我们保存的文本内容是Json格式的，如图：

![image.png](https://image.hyly.net/i/2025/09/28/5e12e69e2ce2a966466afa9edd889120-0.webp)

如果数据需要被Hive的外部表所使用，那么目前的Json数据格式是不满足要求的，我们如何将Json格式数据转换为Hive所需要的文本格式呢？

#### 处理器流程

QueryDatabaseTable	——>	ConvertAvroToJSON	——>	SplitJson	——>	**EvaluateJsonPath**	——>	**ReplaceText**	——>	PutHDFS

这里的重点是，增加了EvaluateJsonPath和ReplaceText处理器，EvaluateJsonPath用来提取json中的属性，ReplaceText用来替换掉FlowFile中的内容，以使内容符合Hive外部表所支持的文本格式。

1. 将Json数据中的属性值提取出来；
2. 转换为\t分割字段；\n分割行数据的格式。

#### 处理器说明

##### EvaluateJsonPath

###### 描述

该处理器根据流文件的内容计算一个或多个JsonPath表达式。这些表达式的结果被写入到FlowFile属性，或者写入到FlowFile本身的内容中，这取决于处理器的配置。通过添加用户自定义的属性来输入jsonpath，添加的属性的名称映射到输出流中的属性名称(如果目标是flowfile-attribute;否则，属性名将被忽略)。属性的值必须是有效的JsonPath表达式。“auto-detect”的返回类型将根据配置的目标进行确定。当“Destination”被设置为“flowfile-attribute”时，将使用“scalar”的返回类型。当“Destination”被设置为“flowfile-content”时，将使用“JSON”返回类型。如果JsonPath计算为JSON数组或JSON对象，并且返回类型设置为“scalar”，则流文件将不进行修改，并将路由到失败。如果所提供的JsonPath计算为指定的值，JSON的返回类型可以返回“scalar”。如果目标是“flowfile-content”，并且JsonPath没有计算到一个已定义的路径，那么流文件将被路由到“unmatched”，无需修改其内容。如果目标是“flowfile-attribute”，而表达式不匹配任何内容，那么将使用空字符串创建属性作为值，并且FlowFile将始终被路由到“matched”。

###### 属性配置

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >属性名称</th><th style='text-align:left;' >默认值</th><th style='text-align:left;' >可选值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Destination</strong></td><td style='text-align:left;' >flowfile-content</td><td style='text-align:left;' >flowfile-contentflowfile-content</td><td style='text-align:left;' >指示是否将JsonPath计算结果写入流文件内容或流文件属性;如果使用flowfile-attribute，则必须指定属性名称属性。如果设置为flowfile-content，则只能指定一个JsonPath，并且忽略属性名。</td></tr><tr><td style='text-align:left;' ><strong>Return Type</strong></td><td style='text-align:left;' >auto-detect</td><td style='text-align:left;' >auto-detectjsonscalar</td><td style='text-align:left;' >指示JSON路径表达式的期望返回类型。选择“auto-detect”，“flowfile-content”的返回类型自动设置为“json”，“flowfile-attribute”的返回类型自动设置为“scalar”。</td></tr><tr><td style='text-align:left;' ><strong>Path Not Found Behavior</strong></td><td style='text-align:left;' >ignore</td><td style='text-align:left;' >warnignore</td><td style='text-align:left;' >指示在将Destination设置为“flowfile-attribute”时如何处理丢失的JSON路径表达式。当没有找到JSON路径表达式时，选择“warn”将生成一个警告。</td></tr><tr><td style='text-align:left;' ><strong>Null Value Representation</strong></td><td style='text-align:left;' >empty string</td><td style='text-align:left;' >empty stringempty string</td><td style='text-align:left;' >指示产生空值的JSON路径表达式的所需表示形式。</td></tr></tbody>
</table></figure>

###### 动态属性：

该处理器允许用户指定属性的名称和值。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >属性名称</th><th style='text-align:left;' >属性值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >用户自由定义的属性名称</td><td style='text-align:left;' >用户自由定义的属性值</td><td style='text-align:left;' >在该处理器生成的文件流上添加用户自定义的属性。如果使用表达式语言，则每批生成的流文件只执行一次计算 . 支持表达式语言:true(只使用变量注册表进行计算)</td></tr></tbody>
</table></figure>

###### 应用场景

通常当需要从流文件json中提取某些数据作为流属性时，使用此处理器；或者从流文件json内容中提取一部分内容作为下一个流文件内容，使用此处理器。

##### ReplaceText

###### 描述

使用其他值替换匹配正则表达式的流文件部分内容，从而更新流文件的内容。

###### 属性配置

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th>属性名称</th><th>默认值</th><th>可选值</th><th>描述</th></tr></thead>
<tbody><tr><td><strong>Search Value</strong></td><td>(?s)(^.*$)</td><td>&nbsp;</td><td>正则表达式，仅用于“Literal Replace”和“Regex Replace”匹配策略 支持表达式语言:true</td></tr><tr><td><strong>Replacement Value</strong></td><td>$1</td><td>&nbsp;</td><td>使用“Replacement Strategy”策略时插入的值。 支持表达式语言:true</td></tr><tr><td><strong>Character Set</strong></td><td>UTF-8</td><td>&nbsp;</td><td>字符集</td></tr><tr><td><strong>Maximum Buffer Size</strong></td><td>1 MB</td><td>&nbsp;</td><td>指定要缓冲的最大数据量(每个文件或每行，取决于计算模式)，以便应用替换。如果选择了“Entire Text”，并且流文件大于这个值，那么流文件将被路由到“failure”。在“Line-by-Line”模式下，如果一行文本比这个值大，那么FlowFile将被路由到“failure”。默认值为1 MB，主要用于“Entire Text”模式。在“Line-by-Line”模式中，建议使用8 KB或16 KB这样的值。如果将&#x3c;<strong>Replacement Strategy</strong>&gt;属性设置为一下其中之一:Append、Prepend、Always Replace，则忽略该值</td></tr><tr><td><strong>Replacement Strategy</strong></td><td>Regex Replace</td><td>PrependAppendRegex ReplaceLiteral ReplaceAlways Replace</td><td>在流文件的文本内容中如何替换以及替换什么内容的策略。</td></tr><tr><td><strong>Evaluation Mode</strong></td><td>Entire text</td><td>Line-by-LineEntire text</td><td>对每一行单独进行“替换策略”(Line-by-Line)；或将整个文件缓冲到内存中(Entire text)，然后对其进行“替换策略”。</td></tr></tbody>
</table></figure>

###### 应用场景

使用正则表达式，来逐行或者全文本替换文件流内容，往往用于业务逻辑处理。

#### 操作

##### EvaluateJsonPath提取Json字段值

###### 创建并连接EvaluateJsonPath

![image.png](https://image.hyly.net/i/2025/09/28/504e9ca08e2fc79729f3d67c2706a740-0.gif)

###### 将Json字段配置到attribute

![image.png](https://image.hyly.net/i/2025/09/28/8e058b2aa4a936b9bfd4ec9d7399e4bb-0.webp)

flowfile-attribute即为将变量放置在属性中；

扩展属性就是我们读取到的Json属性。

同时处理把**Invalid**警告处理掉

![image.png](https://image.hyly.net/i/2025/09/28/27241c85c9076a700be02548742caf6d-0.gif)

###### 启动查看结果

![image.png](https://image.hyly.net/i/2025/09/28/7b6e28094b3f2e39ccdf6439758ead21-0.gif)

我们可以看到，经过EvaluateJsonPath处理后，FlowFile的属性中，已经包含了Json的字段值。

![image.png](https://image.hyly.net/i/2025/09/28/32836b4d8fff10b2c30bc03d01767e79-0.webp)

##### ReplaceText变更文本内容和格式

虽然我们已经获取到了Json中的具体字段值，但是可以看到，FlowFile的内容还是Json。如何替换掉FlowFile中的内容数据呢？

###### 创建ReplaceText并连接

![image.png](https://image.hyly.net/i/2025/09/28/381a8061b307ab938fe9bf353a9e2e96-0.gif)

###### 解决Invalid

![image.png](https://image.hyly.net/i/2025/09/28/435439dbf8550ffd24648eeb0910b1f8-0.gif)

###### 配置替换FlowFile内容

![image.png](https://image.hyly.net/i/2025/09/28/9f3d3d747abc32acf32f2a2e9a2ce14a-0.webp)

##### 运行查看结果

###### 运行所有处理器，查看最后的FlowFile输出

![image.png](https://image.hyly.net/i/2025/09/28/8578653b2b621d3acaa3b31846dc218e-0.webp)

###### 查看输出的HDFS文件

![image.png](https://image.hyly.net/i/2025/09/28/6f0c72fa4753e6892d315fefc095b86b-0.webp)

我们发现，最终的HDFS文件，已经符合Hive的格式要求，抽取完成。

### 实时同步Mysql数据到Hive

#### 处理器流程

NiFi监控MySQL binlog处理调用流程如下:  CaptureChangeMySQL  ——>  RouteOnAttribute  ——>  EvaluateJsonPath  ——> ReplaceText  ——>  PutHiveQL

##### 准备工作

Mysql建库建表：

```sql
create table nifi_test.nifi_hive
(
    id       int auto_increment
        primary key,
    name     varchar(64) null,
    day_time date        null
);
```

Hive建表：

```sql
CREATE TABLE myhive.nifi_hive(id int,name string,day_time string)
STORED AS ORC
TBLPROPERTIES('transactional'='true');
```

替换Hive支持nar包：

上传文件 `NiFi\资料\nifi安装包\nifi-hive-nar-1.9.2.nar`，将其替换到NiFi服务的lib目录下，并重启NiFi集群。

#### 处理器说明

##### CaptureChangeMySQL

**描述**

从MySQL数据库检索更改数据捕获（CDC）事件。CDC事件包括INSERT，UPDATE，DELETE操作。事件将作为单独的流文件输出，并按操作发生的时间排序。

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值，属性是否支持[NiFi表达式语言](http://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html)以及属性是否被视为“敏感”，这意味着将加密其值。在敏感属性中输入值之前，请确保**nifi.properties**文件具有属性**nifi.sensitive.props.key**的条目。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值&#x3c;br&gt;</th><th>允许值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>MySQL Hosts</strong></td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >与MySQL群集中的节点相对应的主机名/端口条目的列表。条目应使用冒号（例如host1：port，host2：port等）以逗号分隔。例如mysql.myhost.com:3306。该处理器将尝试按顺序连接到列表中的主机。如果一个节点发生故障并为集群启用了故障转移，则处理器将连接到活动节点（假定在此属性中指定了其主机条目。MySQL连接的默认端口为3306。<strong>支持表达式语言：true（将为仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>MySQL Driver Class Name</strong></td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >MySQL数据库驱动程序类的类名称<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >MySQL Driver Location(s)</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >包含MySQL驱动程序JAR及其依赖项（如果有）的文件/文件夹和/或URL的逗号分隔列表。例如，“ / var / tmp / mysql-connector-java-5.1.38-bin.jar”<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Username</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >访问MySQL集群的用户名<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Password</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >访问MySQL集群的密码<strong>敏感属性：true</strong> <strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Server ID</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >连接到MySQL复制组的客户端实际上是一个简化的从属服务器（服务器），并且服务器ID值在整个复制组中必须是唯一的（即不同于任何主服务器或从属服务器使用的任何其他服务器ID）。因此，每个CaptureChangeMySQL实例在复制组中必须具有唯一的服务器ID。如果未指定服务器ID，则默认值为65535。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Database/Schema Name Pattern</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >用于将数据库（或模式，取决于RDBMS术语）与CDC事件列表进行匹配的正则表达式（regex）。正则表达式必须与存储在RDBMS中的数据库名称匹配。如果未设置该属性，则数据库名称将不会用于过滤CDC事件。注意：DDL事件（即使它们影响不同的数据库）也与会话用来执行DDL的数据库相关联。这意味着，如果与一个数据库建立了连接，但针对另一个数据库发出了DDL，则连接的数据库将是与指定模式匹配的数据库。</td></tr><tr><td style='text-align:left;' >Table Name Pattern</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >用于影响影响匹配表的CDC事件的正则表达式（regex）。正则表达式必须与存储在数据库中的表名匹配。如果未设置该属性，则不会基于表名过滤任何事件。</td></tr><tr><td style='text-align:left;' ><strong>Max Wait Time</strong></td><td>30秒</td><td>&nbsp;</td><td style='text-align:left;' >建立连接所允许的最长时间，零表示实际上没有限制。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Distributed Map Cache Client</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >标识用于保留有关处理器所需的各种表，列等的信息的分布式映射缓存客户端控制器服务。如果未指定客户端，则生成的事件将不包括列类型或名称信息。</td></tr><tr><td style='text-align:left;' ><strong>Retrieve All Records</strong></td><td>true</td><td>true&#x3c;br&gt;false</td><td style='text-align:left;' >指定是否获取所有可用的CDC事件，而与当前binlog文件名和/或位置无关。如果binlog文件名和位置值存在于处理器的状态中，则将忽略此属性的值。这允许进行4种不同的配置：1）如果Binlog数据在处理器状态下可用，则该数据用于确定开始位置，并且“检索所有记录”的值将被忽略。2）如果没有二进制日志数据处于处理器状态，则将“检索所有记录”设置为true表示从二进制日志历史记录的开头开始。3）如果没有Binlog数据处于处理器状态，并且未设置Initial Binlog文件名/位置，则Retrieve All Records设置为false意味着从Binlog历史记录的末尾开始。4）如果没有二进制日志数据处于处理器状态，并且设置了初始二进制日志文件名/位置，然后将“检索所有记录”设置为false意味着从指定的初始Binlog文件/位置开始。要重置行为，请清除处理器状态（请参阅处理器文档的“状态管理”部分）。</td></tr><tr><td style='text-align:left;' ><strong>Include Begin/Commit Events</strong></td><td>false</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >指定是否在二进制日志中发出与BEGIN或COMMIT事件相对应的事件。如果在下游流中需要BEGIN / COMMIT事件，则将其设置为true，否则将其设置为false，这将抑制这些事件的产生并提高流性能。</td></tr><tr><td style='text-align:left;' ><strong>Include DDL Events</strong></td><td>false</td><td>true&#x3c;br/&gt;false</td><td style='text-align:left;' >指定是否在二进制日志中发出与数据定义语言（DDL）事件相对应的事件，例如ALTER TABLE，TRUNCATE TABLE。如果在下游流中需要DDL事件是必需的，则将其设置为true；否则，将其设置为false，这将抑制这些事件的生成并提高流性能。</td></tr><tr><td style='text-align:left;' ><strong>State Update Interval</strong></td><td>0秒</td><td>&nbsp;</td><td style='text-align:left;' >指示使用二进制日志文件/位置值更新处理器状态的频率。零值表示仅在处理器停止或关闭时才更新状态。如果在某个时候处理器状态不包含所需的二进制日志值，则发出的最后一个流文件将包含最后观察到的值，并且可以使用“初始二进制日志文件”，“初始二进制日志位置”和“初始序列”将处理器返回到该状态。 ID属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Initial Sequence ID</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >指定一个初始序列标识符，如果该处理器的状态没有当前序列标识符，则使用该序列标识符。如果处理器的状态中存在序列标识符，则将忽略此属性。序列标识符是单调递增的整数，它记录处理器生成的流文件的顺序。它们可以与EnforceOrder处理器一起使用，以保证CDC事件的有序交付。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Initial Binlog Filename</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >指定一个初始binlog文件名，如果该处理器的State没有当前binlog文件名，则使用该文件名。如果处理器的状态中存在文件名，则忽略此属性。如果不需要先前的事件，可以将其与初始Binlog位置一起使用以“向前跳过”。请注意，支持NiFi表达式语言，但是在配置处理器时会评估此属性，因此可能不会使用FlowFile属性。支持使用表达式语言来启用变量注册表和/或环境属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Initial Binlog Position</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >如果该处理器的State没有当前的binlog文件名，则指定要使用的binlog的初始偏移量（由Initial Binlog Filename指定）。如果处理器的状态中存在文件名，则忽略此属性。如果不需要先前的事件，可以将其与初始Binlog文件名一起使用以“向前跳过”。请注意，支持NiFi表达式语言，但是在配置处理器时会评估此属性，因此可能不会使用FlowFile属性。支持使用表达式语言来启用变量注册表和/或环境属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr></tbody>
</table></figure>

**写入属性**

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' >cdc.sequence.id</td><td style='text-align:left;' >序列标识符（即严格增加的整数值），用于指定CDC事件流文件相对于其他事件流文件的顺序。</td></tr><tr><td style='text-align:left;' >cdc.event.type</td><td style='text-align:left;' >一个字符串，指示发生的CDC事件的类型，包括（但不限于）&#39;begin&#39;, &#39;insert&#39;, &#39;update&#39;, &#39;delete&#39;, &#39;ddl&#39; 和 &#39;commit&#39;。</td></tr><tr><td style='text-align:left;' >mime.type</td><td style='text-align:left;' >处理器以JSON格式输出流文件内容，并将mime.type属性设置为application / json</td></tr></tbody>
</table></figure>

##### DistributedMapCacheServer

**描述**

提供可通过套接字访问的映射（键/值）缓存。与该服务的交互通常是通过DistributedMapCacheClient服务完成的。

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值</th><th>允许值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>港口</strong></td><td>4557</td><td>&nbsp;</td><td style='text-align:left;' >侦听传入连接的端口</td></tr><tr><td style='text-align:left;' ><strong>最大缓存条目</strong></td><td>10000</td><td>&nbsp;</td><td style='text-align:left;' >缓存可以容纳的最大缓存条目数</td></tr><tr><td style='text-align:left;' ><strong>驱逐策略</strong></td><td>最少使用</td><td>最少使用最近最少使用先进先出</td><td style='text-align:left;' >确定应使用哪种策略从缓存中逐出值以为新条目腾出空间</td></tr><tr><td style='text-align:left;' >持久性目录</td><td>&nbsp;</td><td>&nbsp;</td><td style='text-align:left;' >如果指定，则缓存将保留在给定目录中；如果未指定，则高速缓存将仅在内存中</td></tr><tr><td style='text-align:left;' >SSL上下文服务</td><td>&nbsp;</td><td>StandardRestrictedSSLContextService</td><td style='text-align:left;' >如果指定，此服务将用于创建SSL上下文，以用于保护通信；如果未指定，则通信将不安全</td></tr></tbody>
</table></figure>

##### DistributedMapCacheClientService

**描述**

提供与DistributedMapCacheServer通信的功能。可以使用它来在NiFi群集中的节点之间共享地图

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>服务器主机名</strong></td><td>&nbsp;</td><td style='text-align:left;' >运行DistributedMapCacheServer服务的服务器的名称</td></tr><tr><td style='text-align:left;' ><strong>服务器端口</strong></td><td>4557</td><td style='text-align:left;' >与DistributedMapCacheServer服务通信时将使用的远程服务器上的端口</td></tr><tr><td style='text-align:left;' >SSL上下文服务</td><td>&nbsp;</td><td style='text-align:left;' >如果指定，则表示用于与远程服务器通信的SSL上下文服务。如果未指定，通讯将不会被加密&#x3c;br&gt;StandardSSLContextService&#x3c;br/&gt;StandardRestrictedSSLContextService</td></tr><tr><td style='text-align:left;' ><strong>通讯超时</strong></td><td>30秒</td><td style='text-align:left;' >指定在无法发送或接收数据时确定存在通信故障之前与远程服务器通信之前要等待多长时间</td></tr></tbody>
</table></figure>

##### RouteOnAttribute

**描述**

该处理器使用属性表达式语言，根据流文件的属性去计算然后进行路由。该处理器往往用于判断逻辑。

**属性配置**

在下面的列表中，必需属性的名称以粗体显示。任何其他属性(不是粗体)都被认为是可选的，并且指出属性默认值（如果有默认值），以及属性是否支持表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th>属性名称</th><th>默认值</th><th>可选值</th><th>描述</th></tr></thead>
<tbody><tr><td><strong>Routing Strategy</strong></td><td>Route to Property name</td><td>Route to Property nameRoute to &#39;matched&#39; if all matchRoute to &#39;matched&#39; if any matches</td><td>指定如何确定在计算表达式语言时使用哪个关系</td></tr></tbody>
</table></figure>

**动态属性**

该处理器允许用户指定属性的名称和值。

<figure class='table-figure'><table>
<thead>
<tr><th>属性名称</th><th>属性值</th><th>描述</th></tr></thead>
<tbody><tr><td>用户自由定义的属性名称 (Relationship Name)</td><td>用户自由定义的属性值 (Attribute Expression Language)</td><td>将其属性与动态属性值中指定的属性表达式语言相匹配的流文件路由到动态属性键中指定的关系. 支持表达式语言:true</td></tr></tbody>
</table></figure>

**连接关系**

<figure class='table-figure'><table>
<thead>
<tr><th>名称</th><th>描述</th></tr></thead>
<tbody><tr><td>unmatched</td><td>不匹配任何用户定义表达式的流文件将被路由到这里</td></tr></tbody>
</table></figure>

**自定义连接关系**

可以根据用户配置处理器的方式创建动态连接关系。

<figure class='table-figure'><table>
<thead>
<tr><th>Name</th><th>Description</th></tr></thead>
<tbody><tr><td>动态属性的属性名</td><td>匹配动态属性的属性表达式语言的流文件</td></tr></tbody>
</table></figure>

##### PutHiveQL

**描述**

执行HiveQL DDL / DML命令（例如，UPDATE，INSERT）。预期传入File的内容是要执行的HiveQL命令。HiveQL命令可以使用？转义参数。在这种情况下，要使用的参数必须作为FlowFile属性存在，命名约定为hiveql.args.N.type和hiveql.args.N.value，其中N是一个正整数。hiveql.args.N.type应该是指示JDBC类型的数字。FlowFile的内容应采用UTF-8格式。

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值&#x3c;br&gt;</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Hive Database Connection Pooling Service</strong>&#x3c;br/&gt;</td><td>&nbsp;</td><td style='text-align:left;' >Hive Controller Service，用于获取与Hive数据库的连接</td></tr><tr><td style='text-align:left;' ><strong>Batch Size</strong></td><td>100</td><td style='text-align:left;' >在单个事务中放入数据库的首选FlowFiles数</td></tr><tr><td style='text-align:left;' ><strong>Character Set</strong></td><td>UTF-8</td><td style='text-align:left;' >指定记录数据的字符集。</td></tr><tr><td style='text-align:left;' ><strong>Statement Delimiter</strong></td><td>;</td><td style='text-align:left;' >语句分隔符，用于在多语句脚本中分隔SQL语句</td></tr><tr><td style='text-align:left;' ><strong>Rollback On Failure</strong></td><td>false</td><td style='text-align:left;' >指定如何处理错误。默认情况下（false），如果在处理FlowFile时发生错误，则FlowFile将根据错误类型路由到“失败”或“重试”关系，处理器可以继续下一个FlowFile。相反，您可能想回滚当前已处理的FlowFile，并立即停止进一步的处理。在这种情况下，您可以通过启用此“回滚失败”属性来实现。如果启用，失败的FlowFiles将保留在输入关系中，而不会受到惩罚，并会反复处理，直到成功处理或通过其他方式将其删除为止。重要的是要设置足够的“有效期限”，以免重试次数过多。</td></tr></tbody>
</table></figure>

##### HiveConnectionPool

**描述**

为Apache Hive提供数据库连接池服务。可以从池中请求连接，使用后返回连接。

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示任何默认值，属性是否支持NiFi表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值&#x3c;br&gt;</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Database Connection URL</strong></td><td>&nbsp;</td><td style='text-align:left;' >用于连接数据库的数据库连接URL。可能包含数据库系统名称，主机，端口，数据库名称和一些参数。数据库连接URL的确切语法由Hive文档指定。例如，当连接到安全的Hive服务器时，通常将服务器主体作为连接参数包括在内。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Hive Configuration Resources</td><td>&nbsp;</td><td style='text-align:left;' >包含Hive配置（例如，hive-site.xml）的文件或文件的逗号分隔列表。否则，Hadoop将在类路径中搜索“ hive-site.xml”文件，或恢复为默认配置。请注意，例如要启用Kerberos身份验证，必须在配置文件中设置适当的属性。请参阅Hive文档以获取更多详细信息。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Database User</td><td>&nbsp;</td><td style='text-align:left;' >数据库用户名<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Password</td><td>&nbsp;</td><td style='text-align:left;' >数据库用户的密码<strong>敏感属性：true</strong> <strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Max Wait Time</strong></td><td>500毫秒</td><td style='text-align:left;' >池在失败之前将等待（如果没有可用连接时）返回连接的最大时间，或者无限期等待-1。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Max Total Connections</strong></td><td>8</td><td style='text-align:left;' >可以同时从该池分配的活动连接的最大数量，或者为无限制的最大数量。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Validation query</td><td>&nbsp;</td><td style='text-align:left;' >验证查询，用于在返回连接之前对其进行验证。当借用的连接无效时，它将被丢弃并返回新的有效连接。注意：使用验证可能会降低性能。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Credentials Service</td><td>&nbsp;</td><td style='text-align:left;' >指定应用于Kerberos身份验证的Kerberos凭据控制器服务</td></tr><tr><td style='text-align:left;' >Kerberos Principal</td><td>&nbsp;</td><td style='text-align:left;' >Kerberos主体作为身份验证。需要在您的nifi.properties中设置nifi.kerberos.krb5.file。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Keytab</td><td>&nbsp;</td><td style='text-align:left;' >与主体关联的Kerberos密钥表。需要在您的nifi.properties中设置nifi.kerberos.krb5.file。**支持表达式语言：true（仅使用变量注册表进行评估）</td></tr></tbody>
</table></figure>

#### 操作

##### 开启Mysql的binlog日志

![image.png](https://image.hyly.net/i/2025/09/28/d87427833c1d41e1696e8c4b34d3e304-0.webp)Mysql的版本号要求5.7。

###### 登陆MySQL查看日志状态

```shell
# mysql -u root -p123456
mysql> show variables like '%log_bin%';
```

![image.png](https://image.hyly.net/i/2025/09/28/6554ae8ba57d04dfb7d7a10a37f59983-0.webp)

###### 退出MySQL登陆

```shell
mysql> exit
```

###### Linux开启binlog

**编辑配置文件**

```shell
vi /etc/my.cnf
```

行尾加上

```properties
server_id = 1
log_bin = mysql-bin
binlog_format = row
```

server-id :表示单个结点的id,单个节点可以随意写，多个节点不能重复，
log-bin指定binlog日志文件的名字为mysql-bin，以及其存储路径。

**重启服务**

```shell
systemctl restart mysqld.service
```

或者

```shell
service mysqld restart
```

**重新登陆查询开启状态**

![image.png](https://image.hyly.net/i/2025/09/28/18790da65fe81ee7eae4a280031257b9-0.webp)

###### Windows开启binlog

**修改配置文件**

找到mysql配置文件**my.ini**所在目录，一般在**C:\ProgramData\MySQL\MySQL Server 5.7**。

![image.png](https://image.hyly.net/i/2025/09/28/fd5adf55f8cf90aad52e3e0f06235573-0.webp)注意目录不是C:\ **Program Files** \MySQL\MySQL Server 5.7。

```properties
server_id = 1
log_bin = mysql-bin
binlog_format = row
```

![image.png](https://image.hyly.net/i/2025/09/28/9e0c29101e150abc496b837005bf66cf-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/9d92dc08c953b61173ee8d59856bacca-0.webp)

**重启Mysql服务**

![image.png](https://image.hyly.net/i/2025/09/28/e41b400e0b3a33ac5eb7c4e3ee895ae7-0.webp)

**查询开启状态**

![image.png](https://image.hyly.net/i/2025/09/28/c728fa40c08a9f9d74611485ffeaf028-0.webp)

###### 开启Mysql远程访问权限

```sql
GRANT ALL PRIVILEGES ON . TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

##### 实时获取Mysql变更

###### 创建处理器组

组名：MySqlToHive_Timely

###### 创建CaptureChangeMySQL

CaptureChangeMySQL的配置中需要DistributedMapCacheClientService、DistributedMapCacheServer处理器，一并创建。

###### 配置DistributedMapCacheServer

![image.png](https://image.hyly.net/i/2025/09/28/c863b279ce50b19cb81eb14ab1dcd482-0.webp)

###### 配置DistributedMapCacheClientService

![image.png](https://image.hyly.net/i/2025/09/28/1225cffb429b1a4bc18659b98ba0429f-0.webp)

###### 启动Cache服务和客户端

在模拟的集群模式下，因为三台服务都在同一台主机，所以会存在端口冲突的问题，但是并不影响使用。因为只要有一个节点的缓存服务启动正常就可以使用。

![image.png](https://image.hyly.net/i/2025/09/28/64a3268101a7908066a2351e2327b2de-0.webp)

###### 配置CaptureChangeMySQL

![image.png](https://image.hyly.net/i/2025/09/28/77e97b12b891aea5b9c555f0eeb5d951-0.webp)

```properties
MySQL Hosts = 192.168.52.6:3306
MySQL Driver Class Name = com.mysql.jdbc.Driver
MySQL Driver Location(s) = /export/download/jars/mysql-connector-java-5.1.40.jar
Username = root
Password = 123456
Include Begin/Commit Events = true
Include DDL Events = true
```

###### 启动CaptureChangeMysql

**启动后报错：**

![image.png](https://image.hyly.net/i/2025/09/28/d543b501cf77c61b15e880181ed83272-0.webp)

**FlowFile数据的属性信息：**

![image.png](https://image.hyly.net/i/2025/09/28/90c5cb9864e6abebc06d43ab8dc84dcc-0.webp)

##### 根据条件路由

###### RouteOnAttribute多线程消费

根据自己的服务器硬件配置，以及数据的更新速率，进行评估后填写。

![image.png](https://image.hyly.net/i/2025/09/28/6547b679f552b7418e1f208ffd9bbfef-0.webp)

###### NiFi表达式

NiFi表达式官网：https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html

之前我们已经了解过NiFi表达式语言，这里我们仅针对equals函数进行说明。

**NiFi表达式的equals函数**

**equals**

说明：`equals`函数使用非常广泛，它确定其主题是否等于另一个String值。请注意，该 `equals`函数直接比较两个String值。注意不要将此函数与[matchs](https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html#matches)函数混淆，后者会根据正则表达式评估其主题。

学科类型：任意

参数：

- *value*：用于比较Subject的值。必须与主题类型相同。

返回类型：布尔值

示例：我们可以使用表达式 `${filename:equals('hello.txt')}`检查FlowFile的文件名是否为“ hello.txt” ，或者可以检查属性 `hello`的值是否等于属性的值 `filename`： `${hello:equals( ${filename} )}`。

###### 设置自定义属性

![image.png](https://image.hyly.net/i/2025/09/28/b8e2c3f400091f444df9ef69175d4015-0.webp)

###### 运行并查看输出

**输出的数据内容：**

```json
{
    "type": "insert",
    "timestamp": 1582484253000,
    "binlog_filename": "mysql-bin.000005",
    "binlog_position": 375,
    "database": "nifi_test",
    "table_name": "nifi_hive_streaming",
    "table_id": 108,
    "columns": [
        {
            "id": 1,
            "name": "id",
            "column_type": 4,
            "value": 7
        },
        {
            "id": 2,
            "name": "name",
            "column_type": 12,
            "value": "testName5"
        },
        {
            "id": 3,
            "name": "day_time",
            "column_type": 91,
            "value": "2020-02-24"
        }
    ]
}
```

##### 提取关键属性

EvaluateJsonPath等处理器在提取数据时，可以使用JsonPath表达式，来灵活的获取信息。

###### JsonPath表达式

**简介**

类似于XPath在xml文档中的定位，JsonPath表达式通常是用来路径检索或设置Json的。

JsonPath中的“根成员对象”始终称为$，无论是对象还是数组。

其表达式可以接受“dot–notation”和“bracket–notation”格式，例如

```
$.store.book[0].title、$[‘store’][‘book’][0][‘title’]
```

**操作符**

<figure class='table-figure'><table>
<thead>
<tr><th>符号</th><th>描述</th></tr></thead>
<tbody><tr><td>$</td><td>查询的根节点对象，用于表示一个json数据，可以是数组或对象</td></tr><tr><td>@</td><td>过滤器断言（filter predicate）处理的当前节点对象，类似于java中的this字段</td></tr><tr><td>*</td><td>通配符，可以表示一个名字或数字</td></tr><tr><td>..</td><td>可以理解为递归搜索，Deep scan. Available anywhere a name is required.</td></tr><tr><td>.&#x3c;name&gt;</td><td>表示一个子节点</td></tr><tr><td>[‘&#x3c;name&gt;’ (, ‘&#x3c;name&gt;’)]</td><td>表示一个或多个子节点，</td></tr><tr><td>[&#x3c;number&gt; (, &#x3c;number&gt;)]</td><td>表示一个或多个数组下标</td></tr><tr><td>[start:end]</td><td>数组片段，区间为[start,end),不包含end</td></tr><tr><td>[?(&#x3c;expression&gt;)]</td><td>过滤器表达式，表达式结果必须是boolean</td></tr></tbody>
</table></figure>

**函数**

可以在JsonPath表达式执行后进行调用，其输入值为表达式的结果。

<figure class='table-figure'><table>
<thead>
<tr><th>名称</th><th>描述</th><th>输出</th></tr></thead>
<tbody><tr><td>min()</td><td>获取数值类型数组的最小值</td><td>Double</td></tr><tr><td>max()</td><td>获取数值类型数组的最大值</td><td>Double</td></tr><tr><td>avg()</td><td>获取数值类型数组的平均值</td><td>Double</td></tr><tr><td>stddev()</td><td>获取数值类型数组的标准差</td><td>Double</td></tr><tr><td>length()</td><td>获取数值类型数组的长度</td><td>Integer</td></tr></tbody>
</table></figure>

**过滤器**

过滤器是用于过滤数组的逻辑表达式，一个通常的表达式形如：[?(@.age > 18)]，可以通过逻辑表达式&&或||组合多个过滤器表达式，例如[?(@.price &#x3c; 10 && @.category == ‘fiction’)]，字符串必须用单引号或双引号包围，例如[?(@.color == ‘blue’)] or [?(@.color == “blue”)]。

<figure class='table-figure'><table>
<thead>
<tr><th>操作符</th><th>描述</th></tr></thead>
<tbody><tr><td>==</td><td>等于符号，但数字1不等于字符1(note that 1 is not equal to ‘1’)</td></tr><tr><td>!=</td><td>不等于符号</td></tr><tr><td>&#x3c;</td><td>小于符号</td></tr><tr><td>&#x3c;=</td><td>小于等于符号</td></tr><tr><td>&gt;</td><td>大于符号</td></tr><tr><td>&gt;=</td><td>大于等于符号</td></tr><tr><td>=~</td><td>判断是否符合正则表达式，例如[?(@.name =~ /foo.*?/i)]</td></tr><tr><td>in</td><td>所属符号，例如[?(@.size in [‘S’, ‘M’])]</td></tr><tr><td>nin</td><td>排除符号</td></tr><tr><td>size</td><td>size of left (array or string) should match right</td></tr><tr><td>empty</td><td>判空符号</td></tr></tbody>
</table></figure>

**示例**

```json
{
    "store": {
        "book": [
            {
                "category": "reference",
                "author": "Nigel Rees",
                "title": "Sayings of the Century",
                "price": 8.95
            },
            {
                "category": "fiction",
                "author": "Evelyn Waugh",
                "title": "Sword of Honour",
                "price": 12.99
            },
            {
                "category": "fiction",
                "author": "Herman Melville",
                "title": "Moby Dick",
                "isbn": "0-553-21311-3",
                "price": 8.99
            },
            {
                "category": "fiction",
                "author": "J. R. R. Tolkien",
                "title": "The Lord of the Rings",
                "isbn": "0-395-19395-8",
                "price": 22.99
            }
        ],
        "bicycle": {
            "color": "red",
            "price": 19.95
        }
    },
    "expensive": 10
}
```

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >JsonPath (点击链接测试)</th><th style='text-align:left;' >结果</th></tr></thead>
<tbody><tr><td style='text-align:left;' >$.store.book[*].author &#x3c;br/&gt;或 &#x3c;br/&gt;$..author</td><td style='text-align:left;' >获取json中store下book下的所有author值</td></tr><tr><td style='text-align:left;' >$.store.* 显示所有叶子节点值</td><td style='text-align:left;' >所有的东西，书籍和自行车</td></tr><tr><td style='text-align:left;' >$.store..price</td><td style='text-align:left;' >获取json中store下所有price的值</td></tr><tr><td style='text-align:left;' >$..book[2]</td><td style='text-align:left;' >获取json中book数组的第3个值</td></tr><tr><td style='text-align:left;' >$..book[-2]</td><td style='text-align:left;' >倒数的第二本书</td></tr><tr><td style='text-align:left;' >$..book[0,1]&#x3c;br/&gt;或&#x3c;br/&gt;$..book[:2]</td><td style='text-align:left;' >前两本书</td></tr><tr><td style='text-align:left;' >$..book[1:2]</td><td style='text-align:left;' >从索引1（包括）到索引2（排除）的所有图书</td></tr><tr><td style='text-align:left;' >$..book[-2:]</td><td style='text-align:left;' >获取json中book数组的最后两个值</td></tr><tr><td style='text-align:left;' >$..book[2:]</td><td style='text-align:left;' >获取json中book数组的第3个到最后一个的区间值</td></tr><tr><td style='text-align:left;' >$..book[?(@.isbn)]</td><td style='text-align:left;' >获取json中book数组中包含isbn的所有值</td></tr><tr><td style='text-align:left;' >$.store.book[?(@.price&#x3c; 10)]</td><td style='text-align:left;' >获取json中book数组中price&#x3c;10的所有值</td></tr><tr><td style='text-align:left;' >$..book[?(@.price &#x3c;= $[‘expensive’])]</td><td style='text-align:left;' >获取json中book数组中price&#x3c;=expensive的所有值</td></tr><tr><td style='text-align:left;' >$..book[?(@.author =~ /.*REES/i)]</td><td style='text-align:left;' >获取json中book数组中的作者以REES结尾的所有值（REES不区分大小写）</td></tr><tr><td style='text-align:left;' >$..*</td><td style='text-align:left;' >逐层列出json中的所有值，层级由外到内</td></tr><tr><td style='text-align:left;' >$..book.length()</td><td style='text-align:left;' >获取json中book数组的长度</td></tr></tbody>
</table></figure>

###### 提取Json属性到Attribute

![image.png](https://image.hyly.net/i/2025/09/28/5fbe2b20b763123953dc8503fbf8795d-0.webp)

###### 运行并查看输出

![image.png](https://image.hyly.net/i/2025/09/28/8e27a0161f65b9d1acdc7f339c42432d-0.webp)

##### ReplaceText转换Sql

**配置ReplaceText**

![image.png](https://image.hyly.net/i/2025/09/28/91697a151e416bac74f3cb8dacbd2ece-0.webp)

```properties
Replacement Value = insert into myhive.nifi_hive (id,name,day_time) values (${id},'${name}','${day_time}')
```

**启动查看结果**

![image.png](https://image.hyly.net/i/2025/09/28/671973040099896fe38d78315c37159f-0.webp)

##### 写入Hive

###### 创建PutHiveQL

略

###### 创建配置HiveConnectionPool

![image.png](https://image.hyly.net/i/2025/09/28/f18e8f6ad5b427797882b44d3eea716c-0.webp)

```properties
Database Connection URL = jdbc:hive2://192.168.52.120:10000
Hive Configuration Resources = /export/download/config/core-site.xml,/export/download/config/hdfs-site.xml,/export/download/config/hive-site.xml
```

配置完成后，记得启用HiveConnectionPool。

###### PutHiveQL关联HiveConnectionPool

![image.png](https://image.hyly.net/i/2025/09/28/69adbdc1c2db45dc0f65f1045b79d984-0.webp)

###### 验证Hive表中是否成功写入数据

略。

### Kafka的使用

Kafka是一个由Scala和java编写的高吞吐量的分布式发布订阅消息。它拥有很高的吞吐量、稳定性和扩容能力，在OLTP和OLAP中都会经常使用。使用NiFi可以简单快速的建立起kafka的生产者和消费者，而不需要编写繁杂的代码。

#### 处理器说明

##### PublishKafka_0_10

**描述**

使用Kafka 0.10.x Producer API将FlowFile的内容作为消息发送到Apache Kafka。要发送的消息可以是单独的FlowFiles，也可以使用用户指定的定界符（例如换行符）进行定界。用于获取消息的辅助NiFi处理器是ConsumeKafka_0_10。

**属性配置**

<figure class='table-figure'><table>
<thead>
<tr><th>Name</th><th>Default Value</th><th>Description</th></tr></thead>
<tbody><tr><td><strong>Kafka Brokers</strong></td><td>localhost:9092</td><td>逗号分隔的已知Kafka Broker列表，格式为&#x3c;主机&gt;：&#x3c;端口&gt;<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td><strong>Security Protocol</strong></td><td>纯文本</td><td>与经纪人通信的协议。对应于Kafka的“ security.protocol”属性。</td></tr><tr><td>Kerberos Service Name</td><td>&nbsp;</td><td>与代理JAAS文件中配置的Kafka服务器的主要名称匹配的服务名称。可以在Kafka的JAAS配置或Kafka的配置中定义。对应于Kafka的&#39;security.protocol&#39;属性，除非选择&#x3c;Security Protocol&gt;的SASL选项之一，否则它将被忽略。 <strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td>Kerberos Credentials Service</td><td>&nbsp;</td><td>指定应用于Kerberos身份验证的Kerberos凭据控制器服务</td></tr><tr><td>Kerberos Principal</td><td>&nbsp;</td><td>将用于连接到代理的Kerberos主体。如果未设置，则应在bootstrap.conf文件中定义的JVM属性中设置JAAS配置文件。该主体将被设置为“ sasl.jaas.config” Kafka的属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td>Kerberos Keytab</td><td>&nbsp;</td><td>用于连接代理的Kerberos密钥表。如果未设置，则应在bootstrap.conf文件中定义的JVM属性中设置JAAS配置文件。该主体将被设置为“ sasl.jaas.config” Kafka的属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td>SSL Context Service</td><td>&nbsp;</td><td>指定用于与Kafka通信的SSL上下文服务。</td></tr><tr><td><strong>Topic Name</strong></td><td>&nbsp;</td><td>要发布到的Kafka主题的名称。<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td><strong>Delivery Guarantee</strong></td><td>0</td><td>指定保证消息发送到Kafka的要求。对应于Kafka的“ acks”属性：&#x3c;br&gt;Best Effort&#x3c;br&gt;Guarantee Single Node Delivery&#x3c;br&gt;Guarantee Replicated Delivery</td></tr><tr><td>Kafka Key</td><td>&nbsp;</td><td>用于消息的密钥。如果未指定，则将流文件属性&#39;kafka.key&#39;用作消息密钥（如果存在）。请注意，同时设置Kafka密钥和标界可能会导致许多具有相同密钥的Kafka消息。这不是问题，因为Kafka不会强制执行或假定消息和密钥的唯一性。尽管如此，同时设置分界符和Kafka密钥仍存在Kafka数据丢失的风险。在Kafka上进行主题压缩时，将基于此密钥对消息进行重复数据删除。<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td><strong>Key Attribute Encoding</strong></td><td>utf-8</td><td>发出的FlowFiles具有名为“ kafka.key”的属性。此属性指示应如何编码属性的值。</td></tr><tr><td>Message Demarcator</td><td>&nbsp;</td><td>指定用于在单个FlowFile中划分多个消息的字符串（解释为UTF-8）。如果未指定，则FlowFile的全部内容将用作一条消息。如果指定，则FlowFile的内容将在此定界符上分割，并且每个部分作为单独的Kafka消息发送。要输入特殊字符（例如“换行”），请根据您的操作系统使用CTRL + Enter或Shift + Enter。<strong>支持表达式语言：true（将使用流文件属性和变量注册表进行评估）</strong></td></tr><tr><td><strong>Max Request Size</strong></td><td>1兆字节</td><td>请求的最大大小（以字节为单位）。对应于Kafka的&#39;max.request.size&#39;属性，默认值为1 MB（1048576）。</td></tr><tr><td><strong>Acknowledgment Wait Time</strong></td><td>5秒</td><td>在向Kafka发送消息后，这表明我们愿意等待Kafka做出回应的时间。如果Kafka在此时间段内未确认该消息，则FlowFile将被路由为“失败”。</td></tr><tr><td><strong>Max Metadata Wait Time</strong></td><td>5秒</td><td>在整个“发送”调用失败之前，发布者将在“发送”调用期间等待获取元数据或等待缓冲区刷新的时间。对应于Kafka的&#39;max.block.ms&#39;属性<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td>Partitioner class</td><td>org..DefaultPartitioner</td><td>指定用于计算消息的分区标识的类。对应于Kafka的&#39;partitioner.class&#39;属性。&#x3c;br&gt;RoundRobinPartitioner、DefaultPartitioner</td></tr><tr><td><strong>Compression Type</strong></td><td>没有</td><td>此参数允许您为此生产者生成的所有数据指定压缩编解码器。</td></tr></tbody>
</table></figure>

##### ConsumeKafka_0_10

**描述**

消耗来自专门针对Kafka 0.10.x Consumer API构建的Apache Kafka的消息。用于发送消息的辅助NiFi处理器是PublishKafka_0_10。

**属性配置**

在下面的列表中，必需属性的名称以**粗体显示**。其他任何属性（非粗体）均视为可选。该表还指示所有默认值，以及属性是否支持NiFi表达式语言。

<figure class='table-figure'><table>
<thead>
<tr><th style='text-align:left;' >名称</th><th>默认值</th><th style='text-align:left;' >描述</th></tr></thead>
<tbody><tr><td style='text-align:left;' ><strong>Kafka Brokers</strong></td><td>localhost:9092</td><td style='text-align:left;' >逗号分隔的已知Kafka Broker列表，格式为&#x3c;主机&gt;：&#x3c;端口&gt;<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Security Protocol</strong></td><td>纯文本</td><td style='text-align:left;' >与经纪人通信的协议。对应于Kafka的“ security.protocol”属性。</td></tr><tr><td style='text-align:left;' >Kerberos Service Name</td><td>&nbsp;</td><td style='text-align:left;' >与代理JAAS文件中配置的Kafka服务器的主要名称匹配的服务名称。可以在Kafka的JAAS配置或Kafka的配置中定义。对应于Kafka的&#39;security.protocol&#39;属性，除非选择&#x3c;Security Protocol&gt;的SASL选项之一，否则它将被忽略。 <strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Credentials Service</td><td>&nbsp;</td><td style='text-align:left;' >指定应用于Kerberos身份验证的Kerberos凭据控制器服务</td></tr><tr><td style='text-align:left;' >Kerberos Principal</td><td>&nbsp;</td><td style='text-align:left;' >将用于连接到代理的Kerberos主体。如果未设置，则应在bootstrap.conf文件中定义的JVM属性中设置JAAS配置文件。该主体将被设置为“ sasl.jaas.config” Kafka的属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Kerberos Keytab</td><td>&nbsp;</td><td style='text-align:left;' >用于连接代理的Kerberos密钥表。如果未设置，则应在bootstrap.conf文件中定义的JVM属性中设置JAAS配置文件。该主体将被设置为“ sasl.jaas.config” Kafka的属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >SSL Context Service</td><td>&nbsp;</td><td style='text-align:left;' >指定用于与Kafka通信的SSL上下文服务。</td></tr><tr><td style='text-align:left;' ><strong>Topic Name(s)</strong></td><td>&nbsp;</td><td style='text-align:left;' >要从中提取的Kafka主题的名称。如果逗号分隔，则可以提供多个。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Topic Name Format</strong></td><td>names</td><td style='text-align:left;' >指定提供的主题是逗号分隔的名称列表还是单个正则表达式。&#x3c;br&gt;names、pattern</td></tr><tr><td style='text-align:left;' ><strong>Group ID</strong></td><td>&nbsp;</td><td style='text-align:left;' >组ID用于标识同一使用者组内的使用者。对应于Kafka的&#39;group.id&#39;属性。<strong>支持表达式语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' ><strong>Offset Reset</strong></td><td>latest</td><td style='text-align:left;' >当Kafka中没有初始偏移量或服务器上不再存在当前偏移量时（例如，因为该数据已被删除），使您可以管理条件。对应于Kafka的&#39;auto.offset.reset&#39;属性。&#x3c;br&gt;earliest、latest、none</td></tr><tr><td style='text-align:left;' ><strong>Key Attribute Encoding</strong></td><td>utf-8</td><td style='text-align:left;' >发出的FlowFiles具有名为“ kafka.key”的属性。此属性指示应如何编码属性的值。</td></tr><tr><td style='text-align:left;' >Message Demarcator</td><td>&nbsp;</td><td style='text-align:left;' >由于KafkaConsumer批量接收消息，因此您可以选择输出FlowFiles，其中包含给定主题和分区的单个批次中的所有Kafka消息，并且该属性允许您提供一个字符串（解释为UTF-8）以用于分界多封Kafka讯息。这是一个可选属性，如果未提供，则收到的每条Kafka消息都会在触发该消息时产生一个FlowFile。要输入特殊字符（例如“换行”），请使用CTRL + Enter或Shift + Enter，具体取决于操作系统<strong>支持的表达语言：true（仅使用变量注册表进行评估）</strong></td></tr><tr><td style='text-align:left;' >Max Poll Records</td><td>10000</td><td style='text-align:left;' >指定Kafka在一次轮询中应返回的最大记录数。</td></tr><tr><td style='text-align:left;' >Max Uncommitted Time</td><td>1 secs</td><td style='text-align:left;' >指定在必须提交偏移量之前允许通过的最长时间。该值影响补偿的提交频率。较少地提交偏移量会增加吞吐量，但是如果在提交之间重新平衡或JVM重新启动，则可能会增加潜在数据重复的窗口。此值还与最大轮询记录和消息定界符的使用有关。使用消息分界器时，未提交的消息会比未分配的消息多得多，因为跟踪内存的情况要少得多。</td></tr></tbody>
</table></figure>

#### Producer生产

##### 创建处理器

创建处理器组kafka，进入组后分别创建GenerateFlowFile和PublishKafka_0_10处理器。

##### 负载均衡生产消息

###### 连接GenerateFlowFile和PublishKafka_0_10

![image.png](https://image.hyly.net/i/2025/09/28/de1be73e27403c7f3cdeecff87fe31f6-0.webp)

###### 负载均衡并发

![image.png](https://image.hyly.net/i/2025/09/28/876598b61bb407edf34830318d9bbd98-0.webp)

##### 配置GenerateFlowFile

###### 调度配置：

每1秒生产一次数据

![image.png](https://image.hyly.net/i/2025/09/28/2f192bfecf6e966de77214b01c1a815e-0.webp)

###### 属性配置

文件大小100b；每次生成10个相同文件；每次生成的流文件内容唯一。

![image.png](https://image.hyly.net/i/2025/09/28/157c70257cb882200372d903c259dd3c-0.webp)

##### 配置PublishKafka_0_10

###### 属性配置

Brokers设置为192.168.52.100:9092,192.168.52.110:9092,192.168.52.120:9092

topic设置为nifi-topic，如果topic不存在，会自动创建；

Delivery Guarantee，对应kafka的acks机制，选择最为保险的Guarantee Replicated Delivery，相当于acks=all。

![image.png](https://image.hyly.net/i/2025/09/28/4582fc50083ea55c891daaa0307cbef3-0.webp)

###### 关系配置

![image.png](https://image.hyly.net/i/2025/09/28/18ff81819c94cd397d8ddbb2fe7d9a8d-0.webp)

##### 启动流程并监听数据

###### 启动流程

略

###### 监听kafka消费数据

在kafka所在服务器执行监听命令：

```shell
/export/servers/kafka_2.11-0.10.2.1/bin/kafka-console-consumer.sh --bootstrap-server  192.168.52.110:9092 --topic nifi-topic
```

#### Consumer消费

###### 创建处理器并连接

创建ConsumeKafka_0_10和LogAttribute处理器，并连接。

![image.png](https://image.hyly.net/i/2025/09/28/44f613ac5c2e88f5224941287960e4b1-0.webp)

###### 配置ConsumeKafka_0_10

Brokers地址要和Producer的设置一样：192.168.52.100:9092,192.168.52.110:9092,192.168.52.120:9092

Topic设置和Producer一致：nifi-topic

GroupId随意设置：nifi

Offset Reset设置为：latest，从最新的消息开始消费

![image.png](https://image.hyly.net/i/2025/09/28/266ae7e6c1023a93114f81ea2de86c63-0.webp)

###### 设置LogAttribute

**设置为自连接**

![image.png](https://image.hyly.net/i/2025/09/28/afb5d3abff161ff68c6e2302131b9596-0.webp)

###### 启动流程并查看日志

略、

###### 增加生产频率

注意：如果服务器资源有限，不要进行此操作。

GenerateFlowFile的调度频率加快：20ms

![image.png](https://image.hyly.net/i/2025/09/28/a06d5fadc930977404a77f4f9369bac5-0.webp)

观察kafka消费情况，和nifi日志打印。