---
category: [大数据技术栈]
tag: [Flink,实时,离线,计算]
postType: post
status: publish
---

## Flink安装部署与快速入门

### Flink概述

#### Flink组件栈

![image.png](https://image.hyly.net/i/2025/09/28/e59908cd4e77b753cd516ed34cbbc30e-0.webp)

各层详细介绍：

1. 物理部署层：Flink 支持本地运行、能在独立集群或者在被 YARN 管理的集群上运行， 也能部署在云上，该层主要涉及Flink的部署模式，目前Flink支持多种部署模式：本地、集群(Standalone、YARN)、云(GCE/EC2)、Kubenetes。Flink能够通过该层能够支持不同平台的部署，用户可以根据需要选择使用对应的部署模式。
2. Runtime核心层：Runtime层提供了支持Flink计算的全部核心实现，为上层API层提供基础服务，该层主要负责对上层不同接口提供基础服务，也是Flink分布式计算框架的核心实现层，支持分布式Stream作业的执行、JobGraph到ExecutionGraph的映射转换、任务调度等。将DataSteam和DataSet转成统一的可执行的Task Operator，达到在流式引擎下同时处理批量计算和流式计算的目的。
3. API&Libraries层：Flink 首先支持了 Scala 和 Java 的 API，Python 也正在测试中。DataStream、DataSet、Table、SQL API，作为分布式数据处理框架，Flink同时提供了支撑计算和批计算的接口，两者都提供给用户丰富的数据处理高级API，例如Map、FlatMap操作等，也提供比较低级的Process Function API，用户可以直接操作状态和时间等底层数据。
4. 扩展库：Flink 还包括用于复杂事件处理的CEP，机器学习库FlinkML，图处理库Gelly等。Table 是一种接口化的 SQL 支持，也就是 API 支持(DSL)，而不是文本化的SQL 解析和执行。

#### Flink基石

Flink之所以能这么流行，离不开它最重要的四个基石：Checkpoint、State、Time、Window。

![image.png](https://image.hyly.net/i/2025/09/28/85a8c5c3044c7fd8424d559d405eeb33-0.webp)

1. **Checkpoint**
   这是Flink最重要的一个特性。
   Flink基于Chandy-Lamport算法实现了一个分布式的一致性的快照，从而提供了一致性的语义。
   Chandy-Lamport算法实际上在1985年的时候已经被提出来，但并没有被很广泛的应用，而Flink则把这个算法发扬光大了。
   Spark最近在实现Continue streaming，Continue streaming的目的是为了降低处理的延时，其也需要提供这种一致性的语义，最终也采用了Chandy-Lamport这个算法，说明Chandy-Lamport算法在业界得到了一定的肯定。
   https://zhuanlan.zhihu.com/p/53482103
2. **State**
   提供了一致性的语义之后，Flink为了让用户在编程时能够更轻松、更容易地去管理状态，还提供了一套非常简单明了的State API，包括里面的有ValueState、ListState、MapState，近期添加了BroadcastState，使用State API能够自动享受到这种一致性的语义。
3. **Time**
   除此之外，Flink还实现了Watermark的机制，能够支持基于事件的时间的处理，能够容忍迟到/乱序的数据。
4. **Window**
   另外流计算中一般在对流数据进行操作之前都会先进行开窗，即基于一个什么样的窗口上做这个计算。Flink提供了开箱即用的各种窗口，比如滑动窗口、滚动窗口、会话窗口以及非常灵活的自定义的窗口。

#### Flink用武之地

![image.png](https://image.hyly.net/i/2025/09/28/6564053cd20e46dbc37c233341bd7dec-0.webp)

##### Event-driven Applications【事件驱动】

事件驱动型应用是一类具有状态的应用，它从一个或多个事件流提取数据，并根据到来的事件触发计算、状态更新或其他外部动作。
事件驱动型应用是在计算存储分离的传统应用基础上进化而来。
在传统架构中，应用需要读写远程事务型数据库。
相反，事件驱动型应用是基于状态化流处理来完成。在该设计中，数据和计算不会分离，应用只需访问本地(内存或磁盘)即可获取数据。
系统容错性的实现依赖于定期向远程持久化存储写入 checkpoint。下图描述了传统应用和事件驱动型应用架构的区别。

![image.png](https://image.hyly.net/i/2025/09/28/65dfb27da0fec006ec1e4e2e288a012a-0.webp)

从某种程度上来说，所有的实时的数据处理或者是流式数据处理都应该是属于Data Driven，流计算本质上是Data Driven 计算。应用较多的如风控系统，当风控系统需要处理各种各样复杂的规则时，Data Driven 就会把处理的规则和逻辑写入到Datastream 的API 或者是ProcessFunction 的API 中，然后将逻辑抽象到整个Flink 引擎，当外面的数据流或者是事件进入就会触发相应的规则，这就是Data Driven 的原理。在触发某些规则后，Data Driven 会进行处理或者是进行预警，这些预警会发到下游产生业务通知，这是Data Driven 的应用场景，Data Driven 在应用上更多应用于复杂事件的处理。

典型实例：

1. 欺诈检测(Fraud detection)
2. 异常检测(Anomaly detection)
3. 基于规则的告警(Rule-based alerting)
4. 业务流程监控(Business process monitoring)
5. Web应用程序(社交网络)

![image.png](https://image.hyly.net/i/2025/09/28/31efb31716d5aedd58533504db971505-0.webp)

##### Data Analytics Applications【数据分析】

数据分析任务需要从原始数据中提取有价值的信息和指标。
如下图所示，Apache Flink 同时支持流式及批量分析应用。

![image.png](https://image.hyly.net/i/2025/09/28/00757e7bb4dfc11675fe0d00cd07ee21-0.webp)

Data Analytics Applications包含Batch analytics(批处理分析)和Streaming analytics(流处理分析)
Batch analytics可以理解为周期性查询：Batch Analytics 就是传统意义上使用类似于Map Reduce、Hive、Spark Batch 等，对作业进行分析、处理、生成离线报表。比如Flink应用凌晨从Recorded Events中读取昨天的数据，然后做周期查询运算，最后将数据写入Database或者HDFS，或者直接将数据生成报表供公司上层领导决策使用。
Streaming analytics可以理解为连续性查询：比如实时展示双十一天猫销售GMV(Gross Merchandise Volume成交总额)，用户下单数据需要实时写入消息队列，Flink 应用源源不断读取数据做实时计算，然后不断的将数据更新至Database或者K-VStore，最后做大屏实时展示。

典型实例

1. 电信网络质量监控
2. 移动应用中的产品更新及实验评估分析
3. 消费者技术中的实时数据即席分析
4. 大规模图分析

##### Data Pipeline Applications【数据管道】

什么是数据管道？
提取-转换-加载(ETL)是一种在存储系统之间进行数据转换和迁移的常用方法。
ETL 作业通常会周期性地触发，将数据从事务型数据库拷贝到分析型数据库或数据仓库。
数据管道和 ETL 作业的用途相似，都可以转换、丰富数据，并将其从某个存储系统移动到另一个。
但数据管道是以持续流模式运行，而非周期性触发。
因此数据管道支持从一个不断生成数据的源头读取记录，并将它们以低延迟移动到终点。
例如：数据管道可以用来监控文件系统目录中的新文件，并将其数据写入事件日志；另一个应用可能会将事件流物化到数据库或增量构建和优化查询索引。
和周期性 ETL 作业相比，持续数据管道可以明显降低将数据移动到目的端的延迟。
此外，由于它能够持续消费和发送数据，因此用途更广，支持用例更多。
下图描述了周期性ETL作业和持续数据管道的差异。

![image.png](https://image.hyly.net/i/2025/09/28/996f6189a5b9c3d778a4c2e31885c7f7-0.webp)

Periodic ETL：比如每天凌晨周期性的启动一个Flink ETL Job，读取传统数据库中的数据，然后做ETL，最后写入数据库和文件系统。
Data Pipeline：比如启动一个Flink 实时应用，数据源(比如数据库、Kafka)中的数据不断的通过Flink Data Pipeline流入或者追加到数据仓库(数据库或者文件系统)，或者Kafka消息队列。
Data Pipeline 的核心场景类似于数据搬运并在搬运的过程中进行部分数据清洗或者处理，而整个业务架构图的左边是Periodic ETL，它提供了流式ETL 或者实时ETL，能够订阅消息队列的消息并进行处理，清洗完成后实时写入到下游的Database或File system 中。

典型实例

1. 电子商务中的持续 ETL(实时数仓)
   当下游要构建实时数仓时，上游则可能需要实时的Stream ETL。这个过程会进行实时清洗或扩展数据，清洗完成后写入到下游的实时数仓的整个链路中，可保证数据查询的时效性，形成实时数据采集、实时数据处理以及下游的实时Query。
2. 电子商务中的实时查询索引构建(搜索引擎推荐)
   搜索引擎这块以淘宝为例，当卖家上线新商品时，后台会实时产生消息流，该消息流经过Flink 系统时会进行数据的处理、扩展。然后将处理及扩展后的数据生成实时索引，写入到搜索引擎中。这样当淘宝卖家上线新商品时，能在秒级或者分钟级实现搜索引擎的搜索。

#### 扩展阅读：Flink发展现状

##### Flink在全球

Flink近年来逐步被人们所熟知,不仅是因为Flink提供同时支持高吞吐/低延迟和Exactly-Once语义的实时计算能力,同时Flink还提供了基于流式计算引擎处理批量数据的计算能力,真正意义上实现批流统一
同时随着阿里对Blink的开源,极大地增强了Flink对批计算领域的支持.众多优秀的特性,使得Flink成为开源大数据处理框架中的一颗新星,随着国内社区的不断推动,越来越多的公司开始选择使用Flink作为实时数据处理技术,在不久的将来,Flink也将会成为企业内部主流的数据处理框架,最终成为下一代大数据处理的标准.

#### 扩展阅读：为什么选择Flink？

![image.png](https://image.hyly.net/i/2025/09/28/febb392e89d3ebc759c7a822bda81373-0.webp)

**主要原因**

1.**Flink 具备统一的框架处理有界和无界两种数据流的能力**
2.**部署灵活，Flink 底层支持多种资源调度器**，包括Yarn、Kubernetes 等。Flink 自身带的Standalone 的调度器，在部署上也十分灵活。
3.**极高的可伸缩性**，可伸缩性对于分布式系统十分重要，阿里巴巴双11大屏采用Flink 处理海量数据，使用过程中测得Flink 峰值可达17 亿条/秒。
4.**极致的流式处理性能**。Flink 相对于Storm 最大的特点是将状态语义完全抽象到框架中，支持本地状态读取，避免了大量网络IO，可以极大提升状态存取的性能。

**其他更多的原因:**

1. **同时支持高吞吐、低延迟、高性能**
   Flink 是目前开源社区中唯一一套集高吞吐、低延迟、高性能三者于一身的分布式流式数据处理框架。
   Spark 只能兼顾高吞吐和高性能特性，无法做到低延迟保障,因为Spark是用批处理来做流处理
   Storm 只能支持低延时和高性能特性，无法满足高吞吐的要求
   下图显示了 Apache Flink 与 Apache Storm 在完成流数据清洗的分布式任务的性能对比。

![image.png](https://image.hyly.net/i/2025/09/28/c3418201b5737384f748b8ebd21d5d57-0.webp)

2. **支持事件时间(Event Time)概念**
   在流式计算领域中，窗口计算的地位举足轻重，但目前大多数框架窗口计算采用的都是系统时间(Process Time)，也就是事件传输到计算框架处理时，系统主机的当前时间。
   Flink 能够支持基于事件时间(Event Time)语义进行窗口计算
   这种基于事件驱动的机制使得事件即使乱序到达甚至延迟到达，流系统也能够计算出精确的结果，保持了事件原本产生时的时序性，尽可能避免网络传输或硬件系统的影响。

![image.png](https://image.hyly.net/i/2025/09/28/4e3169b908206d7a67d0faea8b4939e0-0.webp)

3.**支持有状态计算**
Flink1.4开始支持有状态计算
所谓状态就是在流式计算过程中将算子的中间结果保存在内存或者文件系统中，等下一个事件进入算子后可以从之前的状态中获取中间结果，计算当前的结果，从而无须每次都基于全部的原始数据来统计结果，极大的提升了系统性能，状态化意味着应用可以维护随着时间推移已经产生的数据聚合

![image.png](https://image.hyly.net/i/2025/09/28/7716934ae6e34538d6f7bf66b33c188e-0.webp)

4.**支持高度灵活的窗口(Window)操作**
Flink 将窗口划分为基于 Time 、Count 、Session、以及Data-Driven等类型的窗口操作，窗口可以用灵活的触发条件定制化来达到对复杂的流传输模式的支持，用户可以定义不同的窗口触发机制来满足不同的需求

5.**基于轻量级分布式快照(Snapshot/Checkpoints)的容错机制**
Flink 能够分布运行在上千个节点上，通过基于分布式快照技术的Checkpoints，将执行过程中的状态信息进行持久化存储，一旦任务出现异常停止，Flink 能够从 Checkpoints 中进行任务的自动恢复，以确保数据处理过程中的一致性
Flink 的容错能力是轻量级的，允许系统保持高并发，同时在相同时间内提供强一致性保证。

![image.png](https://image.hyly.net/i/2025/09/28/6d5d1e4f5a7f21e7c29be1c1d2ee6d3b-0.webp)

6.**基于 JVM 实现的独立的内存管理**
Flink 实现了自身管理内存的机制，通过使用散列，索引，缓存和排序有效地进行内存管理，通过序列化/反序列化机制将所有的数据对象转换成二进制在内存中存储，降低数据存储大小的同时，更加有效的利用空间。使其独立于 Java 的默认垃圾收集器，尽可能减少 JVM GC 对系统的影响。

7.**SavePoints 保存点**
对于 7 * 24 小时运行的流式应用，数据源源不断的流入，在一段时间内应用的终止有可能导致数据的丢失或者计算结果的不准确。
比如集群版本的升级，停机运维操作等。
值得一提的是，Flink 通过SavePoints 技术将任务执行的快照保存在存储介质上，当任务重启的时候，可以从事先保存的 SavePoints 恢复原有的计算状态，使得任务继续按照停机之前的状态运行。
Flink 保存点提供了一个状态化的版本机制，使得能以无丢失状态和最短停机时间的方式更新应用或者回退历史数据。

![image.png](https://image.hyly.net/i/2025/09/28/a07a8f3cb780238d4e89b91d53cb9ea6-0.webp)

8.灵活的部署方式，支持大规模集群
Flink 被设计成能用上千个点在大规模集群上运行
除了支持独立集群部署外，Flink 还支持 YARN 和Mesos 方式部署。

9.Flink 的程序内在是并行和分布式的
数据流可以被分区成 stream partitions，
operators 被划分为operator subtasks;
这些 subtasks 在不同的机器或容器中分不同的线程独立运行；
operator subtasks 的数量就是operator的并行计算数，不同的 operator 阶段可能有不同的并行数；
如下图所示，source operator 的并行数为 2，但最后的 sink operator 为1；

![image.png](https://image.hyly.net/i/2025/09/28/fa9ef478598486bfa266d262a79116d4-0.webp)

10.丰富的库
Flink 拥有丰富的库来进行机器学习，图形处理，关系数据处理等。

#### 扩展阅读：大数据框架发展史

![image.png](https://image.hyly.net/i/2025/09/28/b64668a63a3ab3ae4f8ed9700d286fcf-0.webp)

这几年大数据的飞速发展，出现了很多热门的开源社区，其中著名的有 **Hadoop、Storm** ，以及后来的 **Spark** ，他们都有着各自专注的应用场景。Spark 掀开了内存计算的先河，也以内存为赌注，赢得了内存计算的飞速发展。Spark 的火热或多或少的掩盖了其他分布式计算的系统身影。就像  **Flink** ，也就在这个时候默默的发展着。

在国外一些社区，有很多人将大数据的计算引擎分成了 4 代，当然，也有很多人不会认同。我们先姑且这么认为和讨论。

1. 第1代——Hadoop MapReduce
   首先第一代的计算引擎，无疑就是 Hadoop 承载的 MapReduce。它将计算分为两个阶段，分别为 Map 和 Reduce。对于上层应用来说，就不得不想方设法去拆分算法，甚至于不得不在上层应用实现多个 Job 的串联，以完成一个完整的算法，例如迭代计算。
   1. 批处理
   2. Mapper、Reducer
2. 第2代——DAG框架（Tez） + MapReduce
   由于这样的弊端，催生了支持 DAG 框架的产生。因此，支持 DAG 的框架被划分为第二代计算引擎。如 Tez 以及更上层的 Oozie。这里我们不去细究各种 DAG 实现之间的区别，不过对于当时的 Tez 和 Oozie 来说，大多还是批处理的任务。
   1. 批处理
   2. 1个Tez = MR(1) + MR(2) + ... + MR(n)
   3. 相比MR效率有所提升

![image.png](https://image.hyly.net/i/2025/09/28/4874379a197f842cfdcb7c55479cae8e-0.webp)

3. 第3代——Spark
   接下来就是以 Spark 为代表的第三代的计算引擎。第三代计算引擎的特点主要是 Job 内部的 DAG 支持（不跨越 Job），以及强调的实时计算。在这里，很多人也会认为第三代计算引擎也能够很好的运行批处理的 Job。
   1. 批处理、流处理、SQL高层API支持
   2. 自带DAG
   3. 内存迭代计算、性能较之前大幅提升
4. 第4代——Flink
   随着第三代计算引擎的出现，促进了上层应用快速发展，例如各种迭代计算的性能以及对流计算和 SQL 等的支持。Flink 的诞生就被归在了第四代。这应该主要表现在 Flink 对流计算的支持，以及更一步的实时性上面。当然 Flink 也可以支持 Batch 的任务，以及 DAG 的运算。
   1. 批处理、流处理、SQL高层API支持
   2. 自带DAG
   3. 流式计算性能更高、可靠性更高

#### 扩展阅读：流处理 VS 批处理

1. 数据的时效性
   日常工作中，我们一般会先把数据存储在表，然后对表的数据进行加工、分析。既然先存储在表中，那就会涉及到时效性概念。
   如果我们处理以年，月为单位的级别的数据处理，进行统计分析，个性化推荐，那么数据的的最新日期离当前有几个甚至上月都没有问题。但是如果我们处理的是以天为级别，或者一小时甚至更小粒度的数据处理，那么就要求数据的时效性更高了。比如：
   1. 对网站的实时监控
   2. 对异常日志的监控
      这些场景需要工作人员立即响应，这样的场景下，传统的统一收集数据，再存到数据库中，再取出来进行分析就无法满足高时效性的需求了。
2. 流式计算和批量计算![image.png](https://image.hyly.net/i/2025/09/28/0de34f229256735fbe08d29547a3eda3-0.webp)1. Batch Analytics，右边是 Streaming Analytics。批量计算: 统一收集数据->存储到DB->对数据进行批量处理，就是传统意义上使用类似于 Map Reduce、Hive、Spark Batch 等，对作业进行分析、处理、生成离线报表
   2. Streaming Analytics 流式计算，顾名思义，就是对数据流进行处理，如使用流式分析引擎如 Storm，Flink 实时处理分析数据，应用较多的场景如实时大屏、实时报表。

它们的主要区别是：

1. 与批量计算那样慢慢积累数据不同，流式计算立刻计算，数据持续流动，计算完之后就丢弃。
2. 批量计算是维护一张表，对表进行实施各种计算逻辑。流式计算相反，是必须先定义好计算逻辑，提交到流式计算系统，这个计算作业逻辑在整个运行期间是不可更改的。
3. 计算结果上，批量计算对全部数据进行计算后传输结果，流式计算是每次小批量计算后，结果可以立刻实时化展现。

#### 扩展阅读：流批统一

在大数据处理领域，批处理任务与流处理任务一般被认为是两种不同的任务，一个大数据框架一般会被设计为只能处理其中一种任务：
MapReduce只支持批处理任务；
Storm只支持流处理任务；
Spark Streaming采用micro-batch架构，本质上还是基于Spark批处理对流式数据进行处理
Flink通过灵活的执行引擎，能够同时支持批处理任务与流处理任务

![image.png](https://image.hyly.net/i/2025/09/28/2082b3c86a2d204ce85897a79cb78be0-0.webp)

在执行引擎这一层，流处理系统与批处理系统最大不同在于节点间的数据传输方式：

1. 对于一个流处理系统，其节点间数据传输的标准模型是：当一条数据被处理完成后，序列化到缓存中，然后立刻通过网络传输到下一个节点，由下一个节点继续处理
2. 对于一个批处理系统，其节点间数据传输的标准模型是：当一条数据被处理完成后，序列化到缓存中，并不会立刻通过网络传输到下一个节点，当缓存写满，就持久化到本地硬盘上，当所有数据都被处理完成后，才开始将处理后的数据通过网络传输到下一个节点

这两种数据传输模式是两个极端，对应的是流处理系统对低延迟的要求和批处理系统对高吞吐量的要求

Flink的执行引擎采用了一种十分灵活的方式，同时支持了这两种数据传输模型：

Flink以固定的缓存块为单位进行网络数据传输，用户可以通过设置缓存块超时值指定缓存块的传输时机。

如果缓存块的超时值为0，则Flink的数据传输方式类似上文所提到流处理系统的标准模型，此时系统可以获得最低的处理延迟

如果缓存块的超时值为无限大/-1，则Flink的数据传输方式类似上文所提到批处理系统的标准模型，此时系统可以获得最高的吞吐量

同时缓存块的超时值也可以设置为0到无限大之间的任意值。缓存块的超时阈值越小，则Flink流处理执行引擎的数据处理延迟越低，但吞吐量也会降低，反之亦然。通过调整缓存块的超时阈值，用户可根据需求灵活地权衡系统延迟和吞吐量

默认情况下，流中的元素并不会一个一个的在网络中传输，而是缓存起来伺机一起发送(默认为32KB，通过taskmanager.memory.segment-size设置),这样可以避免导致频繁的网络传输,提高吞吐量，但如果数据源输入不够快的话会导致后续的数据处理延迟，所以可以使用env.setBufferTimeout(默认100ms)，来为缓存填入设置一个最大等待时间。等待时间到了之后，即使缓存还未填满，缓存中的数据也会自动发送。

ltimeoutMillis > 0 表示最长等待 timeoutMillis 时间，就会flush

ltimeoutMillis = 0 表示每条数据都会触发 flush，直接将数据发送到下游，相当于没有Buffer了(避免设置为0，可能导致性能下降)

ltimeoutMillis = -1 表示只有等到 buffer满了或 CheckPoint的时候，才会flush。相当于取消了 timeout 策略

总结:

**Flink以缓存块为单位进行网络数据传输,用户可以设置缓存块超时时间和缓存块大小来控制缓冲块传输时机,从而控制Flink的延迟性和吞吐量**

### Flink安装部署

Flink支持多种安装模式

1. Local—本地单机模式，学习测试时使用
2. Standalone—独立集群模式，Flink自带集群，开发测试环境使用
3. StandaloneHA—独立集群高可用模式，Flink自带集群，开发测试环境使用
4. On Yarn—计算资源统一由Hadoop YARN管理，生产环境使用

#### Local本地模式

##### 原理

![image.png](https://image.hyly.net/i/2025/09/28/4186bfd007c09c3cdc63f090d904a32c-0.webp)

1. Flink程序由JobClient进行提交
2. JobClient将作业提交给JobManager
3. JobManager负责协调资源分配和作业执行。资源分配完成后，任务将提交给相应的TaskManager
4. TaskManager启动一个线程以开始执行。TaskManager会向JobManager报告状态更改,如开始执行，正在进行或已完成。
5. 作业执行完成后，结果将发送回客户端(JobClient)

##### 操作

1. 下载安装包   [https://archive.apache.org/dist/flink/](https://archive.apache.org/dist/flink/)
2. 上传flink-1.12.0-bin-scala_2.12.tgz到node1的指定目录
3. 解压
   ```shell
   tar -zxvf flink-1.12.0-bin-scala_2.12.tgz 
   ```
4. 如果出现权限问题，需要修改权限
   ```
      chown -R root:root /export/server/flink-1.12.0
   ```
5. 改名或创建软链接
   ```
   mv flink-1.12.0 flink
   ln -s /export/server/flink-1.12.0 /export/server/flink
   ```

##### 测试

1. 准备文件/root/words.txt

   ```
   vim /root/words.txt
   
   hello me you her
   hello me you
   hello me
   hello
   ```
2. 启动Flink本地“集群”

   ```
    /export/server/flink/bin/start-cluster.sh
   ```
3. 使用jps可以查看到下面两个进程

   ```
    - TaskManagerRunner
    - StandaloneSessionClusterEntrypoint
   ```
4. 访问Flink的Web UI   [http://node1:8081/#/overview](http://node1:8081/#/overview)  ![image.png](https://image.hyly.net/i/2025/09/28/149803bbbe548165113bb0dad1a7119e-0.webp)slot在Flink里面可以认为是资源组，Flink是通过将任务分成子任务并且将这些子任务分配到slot来并行执行程序。
5. 执行官方示例

   ```
   /export/server/flink/bin/flink run /export/server/flink/examples/batch/WordCount.jar --input /root/words.txt --output /root/out
   ```
6. 停止Flink

   ```powershell
   /export/server/flink/bin/stop-cluster.sh
   #启动shell交互式窗口(目前所有Scala 2.12版本的安装包暂时都不支持 Scala Shell)
   /export/server/flink/bin/start-scala-shell.sh local
   #执行如下命令
   benv.readTextFile("/root/words.txt").flatMap(_.split(" ")).map((_,1)).groupBy(0).sum(1).print()
   #退出shell
   quit
   ```

#### Standalone独立集群模式

##### 原理

![image.png](https://image.hyly.net/i/2025/09/28/f16e421e7088d0a2b36e16fb05a218b1-0.webp)

1. client客户端提交任务给JobManager
2. JobManager负责申请任务运行所需要的资源并管理任务和资源，
3. JobManager分发任务给TaskManager执行
4. TaskManager定期向JobManager汇报状态

##### 操作

1. 集群规划

   1. 服务器: node1(Master + Slave): JobManager + TaskManager
   2. 服务器: node2(Slave): TaskManager
   3. 服务器: node3(Slave): TaskManager
2. 修改flink-conf.yaml

   ```
   vim /export/server/flink/conf/flink-conf.yaml
   
   jobmanager.rpc.address: node1
   taskmanager.numberOfTaskSlots: 2
   web.submit.enable: true
   
   #历史服务器
   jobmanager.archive.fs.dir: hdfs://node1:8020/flink/completed-jobs/
   historyserver.web.address: node1
   historyserver.web.port: 8082
   historyserver.archive.fs.dir: hdfs://node1:8020/flink/completed-jobs/
   ```
3. 修改masters

   ```
   vim /export/server/flink/conf/masters
   
   node1:8081
   ```
4. 修改slaves

   ```
   vim /export/server/flink/conf/workers
   
   node1
   node2
   node3
   ```
5. 添加HADOOP_CONF_DIR环境变量

   ```
   vim /etc/profile
   
   export HADOOP_CONF_DIR=/export/server/hadoop/etc/hadoop
   ```
6. 分发

   ```
    scp -r /export/server/flink node2:/export/server/flink
    scp -r /export/server/flink node3:/export/server/flink
    scp  /etc/profile node2:/etc/profile
    scp  /etc/profile node3:/etc/profile
    或
   for i in {2..3}; do scp -r flink node$i:$PWD; done
   ```
7. source

   ```
   source /etc/profile
   ```

##### 测试

1. 启动集群，在node1上执行如下命令

   ```
    /export/server/flink/bin/start-cluster.sh
    或者单独启动
   /export/server/flink/bin/jobmanager.sh ((start|start-foreground) cluster)|stop|stop-all
   /export/server/flink/bin/taskmanager.sh start|start-foreground|stop|stop-all
   ```
2. 启动历史服务器

   ```
   /export/server/flink/bin/historyserver.sh start
   ```
3. 访问Flink UI界面或使用jps查看

[http://node1:8081/#/overview](http://node1:8081/#/overview)

[http://node1:8082/#/overview](http://node1:8082/#/overview)

TaskManager界面：可以查看到当前Flink集群中有多少个TaskManager，每个TaskManager的slots、内存、CPU Core是多少

![image.png](https://image.hyly.net/i/2025/09/28/4f4fa0492ad07e3b6535052adac30838-0.webp)

4. 执行官方测试案例
   ```
   /export/server/flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar --input hdfs://node1:8020/wordcount/input/words.txt --output hdfs://node1:8020/wordcount/output/result.txt  --parallelism 2
   ```

![image.png](https://image.hyly.net/i/2025/09/28/39955ebceea9f969038673d8f8f94189-0.webp)

5. 查看历史日志

[http://node1:50070/explorer.html#/flink/completed-jobs](http://node1:50070/explorer.html#/flink/completed-jobs)

[http://node1:8082/#/overview](http://node1:8082/#/overview)

6. 停止Flink集群
   ```
   /export/server/flink/bin/stop-cluster.sh
   ```

#### Standalone-HA高可用集群模式

##### 原理

![image.png](https://image.hyly.net/i/2025/09/28/680123555661bd4c27aa690bbd7cab0c-0.webp)

从之前的架构中我们可以很明显的发现 JobManager 有明显的单点问题(SPOF，single point of failure)。JobManager 肩负着任务调度以及资源分配，一旦 JobManager 出现意外，其后果可想而知。

在 Zookeeper 的帮助下，一个 Standalone的Flink集群会同时有多个活着的 JobManager，其中只有一个处于工作状态，其他处于 Standby 状态。当工作中的 JobManager 失去连接后(如宕机或 Crash)，Zookeeper 会从 Standby 中选一个新的 JobManager 来接管 Flink 集群。

##### 操作

1. 集群规划

   1. 服务器: node1(Master + Slave): JobManager + TaskManager
   2. 服务器: node2(Master + Slave): JobManager + TaskManager
   3. 服务器: node3(Slave): TaskManager
2. 启动ZooKeeper

   ```
   zkServer.sh status
   zkServer.sh stop
   zkServer.sh start
   ```
3. 启动HDFS

   ```
   /export/serves/hadoop/sbin/start-dfs.sh
   ```
4. 停止Flink集群

   ```
   /export/server/flink/bin/stop-cluster.sh
   ```
5. 修改flink-conf.yaml

   ```
   vim /export/server/flink/conf/flink-conf.yaml
   ```

增加如下内容G

```
state.backend: filesystem
state.backend.fs.checkpointdir: hdfs://node1:8020/flink-checkpoints
high-availability: zookeeper
high-availability.storageDir: hdfs://node1:8020/flink/ha/
high-availability.zookeeper.quorum: node1:2181,node2:2181,node3:2181
```

配置解释

```
#开启HA，使用文件系统作为快照存储
state.backend: filesystem

#启用检查点，可以将快照保存到HDFS
state.backend.fs.checkpointdir: hdfs://node1:8020/flink-checkpoints

#使用zookeeper搭建高可用
high-availability: zookeeper

## 存储JobManager的元数据到HDFS
high-availability.storageDir: hdfs://node1:8020/flink/ha/

## 配置ZK集群地址
high-availability.zookeeper.quorum: node1:2181,node2:2181,node3:2181
```

6. 修改masters

   ```
   vim /export/server/flink/conf/masters
   
   node1:8081
   node2:8081
   ```
7. 同步

   ```
   scp -r /export/server/flink/conf/flink-conf.yaml node2:/export/server/flink/conf/
   scp -r /export/server/flink/conf/flink-conf.yaml node3:/export/server/flink/conf/
   scp -r /export/server/flink/conf/masters node2:/export/server/flink/conf/
   scp -r /export/server/flink/conf/masters node3:/export/server/flink/conf/
   ```
8. 修改node2上的flink-conf.yaml

   ```
   vim /export/server/flink/conf/flink-conf.yaml
   jobmanager.rpc.address: node2
   ```
9. 重新启动Flink集群,node1上执行

   ```
   /export/server/flink/bin/stop-cluster.sh
   /export/server/flink/bin/start-cluster.sh
   ```

![image.png](https://image.hyly.net/i/2025/09/28/40ab2bdd78d04b7ef5a4706a59bdd807-0.webp)

10. 使用jps命令查看，发现没有Flink相关进程被启动
11. 查看日志

cat /export/server/flink/log/flink-root-standalonesession-0-node1.log

发现如下错误

![image.png](https://image.hyly.net/i/2025/09/28/52fc9c422c81c2aa3fab6b12d4c64798-0.webp)

因为在Flink1.8版本后,Flink官方提供的安装包里没有整合HDFS的jar

12. 下载jar包并在Flink的lib目录下放入该jar包并分发使Flink能够支持对Hadoop的操作

    下载地址   [https://flink.apache.org/downloads.html](https://flink.apache.org/downloads.html)   ![image.png](https://image.hyly.net/i/2025/09/28/ee8ee7fb1c07031766d78d0ebdc3fdd0-0.webp)

放入lib目录

cd /export/server/flink/lib

![image.png](https://image.hyly.net/i/2025/09/28/7296d70ffb4e9513a668c1ae76911814-0.webp)

分发

for i in {2..3}; do scp -r flink-shaded-hadoop-2-uber-2.7.5-10.0.jar node$i:$PWD; done

13. 重新启动Flink集群,node1上执行

```
/export/server/flink/bin/start-cluster.sh
```

14. 使用jps命令查看,发现三台机器已经ok

##### 测试

1. 访问WebUI

[http://node1:8081/#/job-manager/config](http://node1:8081/#/job-manager/config)

[http://node2:8081/#/job-manager/config](http://node2:8081/#/job-manager/config)

2. 执行wc

```
/export/server/flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar
```

3. kill掉其中一个master
4. 重新执行wc,还是可以正常执行

```
/export/server/flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar
```

5. 停止集群
   ```
   /export/server/flink/bin/stop-cluster.sh
   ```

#### Flink On Yarn模式

##### 原理

###### 为什么使用Flink On Yarn?

在实际开发中，使用Flink时，更多的使用方式是Flink On Yarn模式，原因如下：

1. Yarn的资源可以按需使用，提高集群的资源利用率
2. Yarn的任务有优先级，根据优先级运行作业
3. 基于Yarn调度系统，能够自动化地处理各个角色的 Failover(容错)
   1. JobManager 进程和 TaskManager 进程都由 Yarn NodeManager 监控
   2. 如果 JobManager 进程异常退出，则 Yarn ResourceManager 会重新调度 JobManager 到其他机器
   3. 如果 TaskManager 进程异常退出，JobManager 会收到消息并重新向 YarnResourceManager 申请资源，重新启动 TaskManager

###### Flink如何和Yarn进行交互?

![image.png](https://image.hyly.net/i/2025/09/28/458fcf204cb7e2c2a7476da40d835210-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/0e66450f25a03ce414a057482c0c580f-0.webp)

1. Client上传jar包和配置文件到HDFS集群上
2. Client向Yarn ResourceManager提交任务并申请资源
3. ResourceManager分配Container资源并启动ApplicationMaster,然后AppMaster加载Flink的Jar包和配置构建环境,启动JobManager

JobManager和ApplicationMaster运行在同一个container上。

一旦他们被成功启动，AppMaster就知道JobManager的地址(AM它自己所在的机器)。

它就会为TaskManager生成一个新的Flink配置文件(他们就可以连接到JobManager)。

这个配置文件也被上传到HDFS上。

此外，AppMaster容器也提供了Flink的web服务接口。

YARN所分配的所有端口都是临时端口，这允许用户并行执行多个Flink

4. ApplicationMaster向ResourceManager申请工作资源,NodeManager加载Flink的Jar包和配置构建环境并启动TaskManager
5. TaskManager启动后向JobManager发送心跳包，并等待JobManager向其分配任务

###### 两种方式

####### Session模式

![image.png](https://image.hyly.net/i/2025/09/28/b482b6a09a10ebceeac0cecaca7654bc-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/cb34fdac3e340cef09014e4614a9a12c-0.webp)

特点：需要事先申请资源，启动JobManager和TaskManger
优点：不需要每次递交作业申请资源，而是使用已经申请好的资源，从而提高执行效率
缺点：作业执行完成以后，资源不会被释放，因此一直会占用系统资源
应用场景：适合作业递交比较频繁的场景，小作业比较多的场景

####### Per-Job模式

![image.png](https://image.hyly.net/i/2025/09/28/78ec74bff872bec9257a181e83aadae2-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/15b5e459387ef136b3ac96811655365d-0.webp)

特点：每次递交作业都需要申请一次资源
优点：作业运行完成，资源会立刻被释放，不会一直占用系统资源
缺点：每次递交作业都需要申请资源，会影响执行效率，因为申请资源需要消耗时间
应用场景：适合作业比较少的场景、大作业的场景

##### 操作

1. 关闭yarn的内存检查
   ```
   vim /export/server/hadoop/etc/hadoop/yarn-site.xml
   ## 添加：
   <!-- 关闭yarn内存检查 -->
   <property>
   <name>yarn.nodemanager.pmem-check-enabled</name>
       <value>false</value>
   </property>
   <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
   </property>
   ```

说明:

是否启动一个线程检查每个任务正使用的虚拟内存量，如果任务超出分配值，则直接将其杀掉，默认是true。

在这里面我们需要关闭，因为对于flink使用yarn模式下，很容易内存超标，这个时候yarn会自动杀掉job

2. 同步

   ```
   scp -r /export/server/hadoop/etc/hadoop/yarn-site.xml node2:/export/server/hadoop/etc/hadoop/yarn-site.xml
   scp -r /export/server/hadoop/etc/hadoop/yarn-site.xml node3:/export/server/hadoop/etc/hadoop/yarn-site.xml
   ```
3. 重启yarn

   ```
   /export/server/hadoop/sbin/stop-yarn.sh
   /export/server/hadoop/sbin/start-yarn.sh
   ```

##### 测试

###### Session模式

yarn-session.sh(开辟资源) + flink run(提交任务)

1. 在yarn上启动一个Flink会话，node1上执行以下命令

   ```
   /export/server/flink/bin/yarn-session.sh -n 2 -tm 800 -s 1 -d
   
   ## 说明:
   ## 申请2个CPU、1600M内存
   ## -n 表示申请2个容器，这里指的就是多少个taskmanager
   ## -tm 表示每个TaskManager的内存大小
   ## -s 表示每个TaskManager的slots数量
   ## -d 表示以后台程序方式运行
   注意:
   该警告不用管
   WARN  org.apache.hadoop.hdfs.DFSClient  - Caught exception 
   java.lang.InterruptedException
   ```
2. 查看UI界面   [http://node1:8088/cluster](http://node1:8088/cluster)

![image.png](https://image.hyly.net/i/2025/09/28/8af0f605bdf0651da7c1ff4240951126-0.webp)

3. 使用flink run提交任务：

   ```
    /export/server/flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar
    运行完之后可以继续运行其他的小任务
    /export/server/flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar
   ```
4. 通过上方的ApplicationMaster可以进入Flink的管理界面

![image.png](https://image.hyly.net/i/2025/09/28/1c591baf888d5f17c06ee109c46228f8-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/1c5a277d1f336f30149e1e60f6731c9d-0.webp)

5. 关闭yarn-session：
   ```
   yarn application -kill application_1599402747874_0001
   rm -rf /tmp/.yarn-properties-root
   ```

![image.png](https://image.hyly.net/i/2025/09/28/5f7041e110d0613b840e0d4e5c353b24-0.webp)

###### Per-Job分离模式

1. 直接提交job

   ```
   /export/server/flink/bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 /export/server/flink/examples/batch/WordCount.jar
   ## -m  jobmanager的地址
   ## -yjm 1024 指定jobmanager的内存信息
   ## -ytm 1024 指定taskmanager的内存信息
   ```
2. 查看UI界面  [http://node1:8088/cluster](http://node1:8088/cluster)

![image.png](https://image.hyly.net/i/2025/09/28/a86e889d6801ba0b3b19d7807b059bf9-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/e360ee802253261b2345f0d290c71f5b-0.webp)

3. 注意：

在之前版本中如果使用的是flink on yarn方式，想切换回standalone模式的话，如果报错需要删除：

```
【/tmp/.yarn-properties-root】
rm -rf /tmp/.yarn-properties-root
```

因为默认查找当前yarn集群中已有的yarn-session信息中的jobmanager

##### 参数总结

```
[root@node1 bin]## /export/server/flink/bin/flink --help
./flink <ACTION> [OPTIONS] [ARGUMENTS]

The following actions are available:

Action "run" compiles and runs a program.

  Syntax: run [OPTIONS] <jar-file> <arguments>
  "run" action options:
     -c,--class <classname>               Class with the program entry point
                                          ("main()" method). Only needed if the
                                          JAR file does not specify the class in
                                          its manifest.
     -C,--classpath <url>                 Adds a URL to each user code
                                          classloader  on all nodes in the
                                          cluster. The paths must specify a
                                          protocol (e.g. file://) and be
                                          accessible on all nodes (e.g. by means
                                          of a NFS share). You can use this
                                          option multiple times for specifying
                                          more than one URL. The protocol must
                                          be supported by the {@link
                                          java.net.URLClassLoader}.
     -d,--detached                        If present, runs the job in detached
                                          mode
     -n,--allowNonRestoredState           Allow to skip savepoint state that
                                          cannot be restored. You need to allow
                                          this if you removed an operator from
                                          your program that was part of the
                                          program when the savepoint was
                                          triggered.
     -p,--parallelism <parallelism>       The parallelism with which to run the
                                          program. Optional flag to override the
                                          default value specified in the
                                          configuration.
     -py,--python <pythonFile>            Python script with the program entry
                                          point. The dependent resources can be
                                          configured with the `--pyFiles`
                                          option.
     -pyarch,--pyArchives <arg>           Add python archive files for job. The
                                          archive files will be extracted to the
                                          working directory of python UDF
                                          worker. Currently only zip-format is
                                          supported. For each archive file, a
                                          target directory be specified. If the
                                          target directory name is specified,
                                          the archive file will be extracted to
                                          a name can directory with the
                                          specified name. Otherwise, the archive
                                          file will be extracted to a directory
                                          with the same name of the archive
                                          file. The files uploaded via this
                                          option are accessible via relative
                                          path. '#' could be used as the
                                          separator of the archive file path and
                                          the target directory name. Comma (',')
                                          could be used as the separator to
                                          specify multiple archive files. This
                                          option can be used to upload the
                                          virtual environment, the data files
                                          used in Python UDF (e.g.: --pyArchives
                                          file:///tmp/py37.zip,file:///tmp/data.
                                          zip#data --pyExecutable
                                          py37.zip/py37/bin/python). The data
                                          files could be accessed in Python UDF,
                                          e.g.: f = open('data/data.txt', 'r').
     -pyexec,--pyExecutable <arg>         Specify the path of the python
                                          interpreter used to execute the python
                                          UDF worker (e.g.: --pyExecutable
                                          /usr/local/bin/python3). The python
                                          UDF worker depends on Python 3.5+,
                                          Apache Beam (version == 2.23.0), Pip
                                          (version >= 7.1.0) and SetupTools
                                          (version >= 37.0.0). Please ensure
                                          that the specified environment meets
                                          the above requirements.
     -pyfs,--pyFiles <pythonFiles>        Attach custom python files for job.
                                          These files will be added to the
                                          PYTHONPATH of both the local client
                                          and the remote python UDF worker. The
                                          standard python resource file suffixes
                                          such as .py/.egg/.zip or directory are
                                          all supported. Comma (',') could be
                                          used as the separator to specify
                                          multiple files (e.g.: --pyFiles
                                          file:///tmp/myresource.zip,hdfs:///$na
                                          menode_address/myresource2.zip).
     -pym,--pyModule <pythonModule>       Python module with the program entry
                                          point. This option must be used in
                                          conjunction with `--pyFiles`.
     -pyreq,--pyRequirements <arg>        Specify a requirements.txt file which
                                          defines the third-party dependencies.
                                          These dependencies will be installed
                                          and added to the PYTHONPATH of the
                                          python UDF worker. A directory which
                                          contains the installation packages of
                                          these dependencies could be specified
                                          optionally. Use '#' as the separator
                                          if the optional parameter exists
                                          (e.g.: --pyRequirements
                                          file:///tmp/requirements.txt#file:///t
                                          mp/cached_dir).
     -s,--fromSavepoint <savepointPath>   Path to a savepoint to restore the job
                                          from (for example
                                          hdfs:///flink/savepoint-1537).
     -sae,--shutdownOnAttachedExit        If the job is submitted in attached
                                          mode, perform a best-effort cluster
                                          shutdown when the CLI is terminated
                                          abruptly, e.g., in response to a user
                                          interrupt, such as typing Ctrl + C.
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".

  Options for yarn-cluster mode:
     -d,--detached                        If present, runs the job in detached
                                          mode
     -m,--jobmanager <arg>                Set to yarn-cluster to use YARN
                                          execution mode.
     -yat,--yarnapplicationType <arg>     Set a custom application type for the
                                          application on YARN
     -yD <property=value>                 use value for given property
     -yd,--yarndetached                   If present, runs the job in detached
                                          mode (deprecated; use non-YARN
                                          specific option instead)
     -yh,--yarnhelp                       Help for the Yarn session CLI.
     -yid,--yarnapplicationId <arg>       Attach to running YARN session
     -yj,--yarnjar <arg>                  Path to Flink jar file
     -yjm,--yarnjobManagerMemory <arg>    Memory for JobManager Container with
                                          optional unit (default: MB)
     -ynl,--yarnnodeLabel <arg>           Specify YARN node label for the YARN
                                          application
     -ynm,--yarnname <arg>                Set a custom name for the application
                                          on YARN
     -yq,--yarnquery                      Display available YARN resources
                                          (memory, cores)
     -yqu,--yarnqueue <arg>               Specify YARN queue.
     -ys,--yarnslots <arg>                Number of slots per TaskManager
     -yt,--yarnship <arg>                 Ship files in the specified directory
                                          (t for transfer)
     -ytm,--yarntaskManagerMemory <arg>   Memory per TaskManager Container with
                                          optional unit (default: MB)
     -yz,--yarnzookeeperNamespace <arg>   Namespace to create the Zookeeper
                                          sub-paths for high availability mode
     -z,--zookeeperNamespace <arg>        Namespace to create the Zookeeper
                                          sub-paths for high availability mode

  Options for default mode:
     -D <property=value>             Allows specifying multiple generic
                                     configuration options. The available
                                     options can be found at
                                     https://ci.apache.org/projects/flink/flink-
                                     docs-stable/ops/config.html
     -m,--jobmanager <arg>           Address of the JobManager to which to
                                     connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration. Attention: This
                                     option is respected only if the
                                     high-availability configuration is NONE.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode



Action "run-application" runs an application in Application Mode.

  Syntax: run-application [OPTIONS] <jar-file> <arguments>
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".



Action "info" shows the optimized execution plan of the program (JSON).

  Syntax: info [OPTIONS] <jar-file> <arguments>
  "info" action options:
     -c,--class <classname>           Class with the program entry point
                                      ("main()" method). Only needed if the JAR
                                      file does not specify the class in its
                                      manifest.
     -p,--parallelism <parallelism>   The parallelism with which to run the
                                      program. Optional flag to override the
                                      default value specified in the
                                      configuration.


Action "list" lists running and scheduled programs.

  Syntax: list [OPTIONS]
  "list" action options:
     -a,--all         Show all programs and their JobIDs
     -r,--running     Show only running programs and their JobIDs
     -s,--scheduled   Show only scheduled programs and their JobIDs
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".

  Options for yarn-cluster mode:
     -m,--jobmanager <arg>            Set to yarn-cluster to use YARN execution
                                      mode.
     -yid,--yarnapplicationId <arg>   Attach to running YARN session
     -z,--zookeeperNamespace <arg>    Namespace to create the Zookeeper
                                      sub-paths for high availability mode

  Options for default mode:
     -D <property=value>             Allows specifying multiple generic
                                     configuration options. The available
                                     options can be found at
                                     https://ci.apache.org/projects/flink/flink-
                                     docs-stable/ops/config.html
     -m,--jobmanager <arg>           Address of the JobManager to which to
                                     connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration. Attention: This
                                     option is respected only if the
                                     high-availability configuration is NONE.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode



Action "stop" stops a running program with a savepoint (streaming jobs only).

  Syntax: stop [OPTIONS] <Job ID>
  "stop" action options:
     -d,--drain                           Send MAX_WATERMARK before taking the
                                          savepoint and stopping the pipelne.
     -p,--savepointPath <savepointPath>   Path to the savepoint (for example
                                          hdfs:///flink/savepoint-1537). If no
                                          directory is specified, the configured
                                          default will be used
                                          ("state.savepoints.dir").
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".

  Options for yarn-cluster mode:
     -m,--jobmanager <arg>            Set to yarn-cluster to use YARN execution
                                      mode.
     -yid,--yarnapplicationId <arg>   Attach to running YARN session
     -z,--zookeeperNamespace <arg>    Namespace to create the Zookeeper
                                      sub-paths for high availability mode

  Options for default mode:
     -D <property=value>             Allows specifying multiple generic
                                     configuration options. The available
                                     options can be found at
                                     https://ci.apache.org/projects/flink/flink-
                                     docs-stable/ops/config.html
     -m,--jobmanager <arg>           Address of the JobManager to which to
                                     connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration. Attention: This
                                     option is respected only if the
                                     high-availability configuration is NONE.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode



Action "cancel" cancels a running program.

  Syntax: cancel [OPTIONS] <Job ID>
  "cancel" action options:
     -s,--withSavepoint <targetDirectory>   **DEPRECATION WARNING**: Cancelling
                                            a job with savepoint is deprecated.
                                            Use "stop" instead.
                                            Trigger savepoint and cancel job.
                                            The target directory is optional. If
                                            no directory is specified, the
                                            configured default directory
                                            (state.savepoints.dir) is used.
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".

  Options for yarn-cluster mode:
     -m,--jobmanager <arg>            Set to yarn-cluster to use YARN execution
                                      mode.
     -yid,--yarnapplicationId <arg>   Attach to running YARN session
     -z,--zookeeperNamespace <arg>    Namespace to create the Zookeeper
                                      sub-paths for high availability mode

  Options for default mode:
     -D <property=value>             Allows specifying multiple generic
                                     configuration options. The available
                                     options can be found at
                                     https://ci.apache.org/projects/flink/flink-
                                     docs-stable/ops/config.html
     -m,--jobmanager <arg>           Address of the JobManager to which to
                                     connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration. Attention: This
                                     option is respected only if the
                                     high-availability configuration is NONE.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode



Action "savepoint" triggers savepoints for a running job or disposes existing ones.

  Syntax: savepoint [OPTIONS] <Job ID> [<target directory>]
  "savepoint" action options:
     -d,--dispose <arg>       Path of savepoint to dispose.
     -j,--jarfile <jarfile>   Flink program JAR file.
  Options for Generic CLI mode:
     -D <property=value>   Allows specifying multiple generic configuration
                           options. The available options can be found at
                           https://ci.apache.org/projects/flink/flink-docs-stabl
                           e/ops/config.html
     -e,--executor <arg>   DEPRECATED: Please use the -t option instead which is
                           also available with the "Application Mode".
                           The name of the executor to be used for executing the
                           given job, which is equivalent to the
                           "execution.target" config option. The currently
                           available executors are: "remote", "local",
                           "kubernetes-session", "yarn-per-job", "yarn-session".
     -t,--target <arg>     The deployment target for the given application,
                           which is equivalent to the "execution.target" config
                           option. For the "run" action the currently available
                           targets are: "remote", "local", "kubernetes-session",
                           "yarn-per-job", "yarn-session". For the
                           "run-application" action the currently available
                           targets are: "kubernetes-application",
                           "yarn-application".

  Options for yarn-cluster mode:
     -m,--jobmanager <arg>            Set to yarn-cluster to use YARN execution
                                      mode.
     -yid,--yarnapplicationId <arg>   Attach to running YARN session
     -z,--zookeeperNamespace <arg>    Namespace to create the Zookeeper
                                      sub-paths for high availability mode

  Options for default mode:
     -D <property=value>             Allows specifying multiple generic
                                     configuration options. The available
                                     options can be found at
                                     https://ci.apache.org/projects/flink/flink-
                                     docs-stable/ops/config.html
     -m,--jobmanager <arg>           Address of the JobManager to which to
                                     connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration. Attention: This
                                     option is respected only if the
                                     high-availability configuration is NONE.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode
```

### Flink入门案例

#### 前置说明

##### API

Flink提供了多个层次的API供开发者使用，越往上抽象程度越高，使用起来越方便；越往下越底层，使用起来难度越大

![image.png](https://image.hyly.net/i/2025/09/28/c40cba66fbf0f9ef7cd492136256502a-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/41c470dc8f71c743e399f2d22bd45138-0.webp)

注意：在Flink1.12时支持流批一体，DataSetAPI已经不推荐使用了，所以课程中除了个别案例使用DataSet外，后续其他案例都会优先使用DataStream流式API，既支持无界数据处理/流处理，也支持有界数据处理/批处理！当然Table&SQL-API会单独学习

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/batch/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/batch/)

[https://developer.aliyun.com/article/780123?spm=a2c6h.12873581.0.0.1e3e46ccbYFFrC](https://developer.aliyun.com/article/780123?spm=a2c6h.12873581.0.0.1e3e46ccbYFFrC)

![image.png](https://image.hyly.net/i/2025/09/28/38818ed62cac1125693292fac4bca809-0.webp)

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html)

![image.png](https://image.hyly.net/i/2025/09/28/584405643e281a63b665ba77201f77df-0.webp)

##### 编程模型

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html)

1. **编程模型：**Flink 应用程序结构主要包含三部分,Source/Transformation/Sink,如下图所示：

![image.png](https://image.hyly.net/i/2025/09/28/ac314183d85295f92405508eee0cfdb6-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/adfab7c794f4549c8fbe7733b0b20094-0.webp)

#### 准备工程

##### pom文件

```java
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>cn.itcast</groupId>
    <artifactId>flink_study_42</artifactId>
    <version>1.0-SNAPSHOT</version>

    <!-- 指定仓库位置，依次为aliyun、apache和cloudera仓库 -->
    <repositories>
        <repository>
            <id>aliyun</id>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
        </repository>
        <repository>
            <id>apache</id>
            <url>https://repository.apache.org/content/repositories/snapshots/</url>
        </repository>
        <repository>
            <id>cloudera</id>
            <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
        </repository>
    </repositories>

    <properties>
        <encoding>UTF-8</encoding>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <java.version>1.8</java.version>
        <scala.version>2.12</scala.version>
        <flink.version>1.12.0</flink.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-clients_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-scala_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-java</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-streaming-scala_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-streaming-java_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-api-scala-bridge_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-api-java-bridge_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <!-- flink执行计划,这是1.9版本之前的-->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-planner_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <!-- blink执行计划,1.11+默认的-->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-planner-blink_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-table-common</artifactId>
            <version>${flink.version}</version>
        </dependency>

        <!--<dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-cep_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>-->

        <!-- flink连接器-->
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-connector-kafka_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-sql-connector-kafka_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-connector-jdbc_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-csv</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-json</artifactId>
            <version>${flink.version}</version>
        </dependency>

        <!-- <dependency>
           <groupId>org.apache.flink</groupId>
           <artifactId>flink-connector-filesystem_2.12</artifactId>
           <version>${flink.version}</version>
       </dependency>-->
        <!--<dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-jdbc_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>-->
        <!--<dependency>
              <groupId>org.apache.flink</groupId>
              <artifactId>flink-parquet_2.12</artifactId>
              <version>${flink.version}</version>
         </dependency>-->
        <!--<dependency>
            <groupId>org.apache.avro</groupId>
            <artifactId>avro</artifactId>
            <version>1.9.2</version>
        </dependency>
        <dependency>
            <groupId>org.apache.parquet</groupId>
            <artifactId>parquet-avro</artifactId>
            <version>1.10.0</version>
        </dependency>-->


        <dependency>
            <groupId>org.apache.bahir</groupId>
            <artifactId>flink-connector-redis_2.11</artifactId>
            <version>1.0</version>
            <exclusions>
                <exclusion>
                    <artifactId>flink-streaming-java_2.11</artifactId>
                    <groupId>org.apache.flink</groupId>
                </exclusion>
                <exclusion>
                    <artifactId>flink-runtime_2.11</artifactId>
                    <groupId>org.apache.flink</groupId>
                </exclusion>
                <exclusion>
                    <artifactId>flink-core</artifactId>
                    <groupId>org.apache.flink</groupId>
                </exclusion>
                <exclusion>
                    <artifactId>flink-java</artifactId>
                    <groupId>org.apache.flink</groupId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-connector-hive_2.12</artifactId>
            <version>${flink.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hive</groupId>
            <artifactId>hive-metastore</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hive</groupId>
            <artifactId>hive-exec</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>org.apache.flink</groupId>
            <artifactId>flink-shaded-hadoop-2-uber</artifactId>
            <version>2.7.5-10.0</version>
        </dependency>

        <dependency>
            <groupId>org.apache.hbase</groupId>
            <artifactId>hbase-client</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>5.1.38</version>
            <!--<version>8.0.20</version>-->
        </dependency>

        <!-- 高性能异步组件：Vertx-->
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-core</artifactId>
            <version>3.9.0</version>
        </dependency>
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-jdbc-client</artifactId>
            <version>3.9.0</version>
        </dependency>
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-redis-client</artifactId>
            <version>3.9.0</version>
        </dependency>

        <!-- 日志 -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
            <version>1.7.7</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
            <version>1.2.17</version>
            <scope>runtime</scope>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.44</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.2</version>
            <scope>provided</scope>
        </dependency>

        <!-- 参考：https://blog.csdn.net/f641385712/article/details/84109098-->
        <!--<dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-collections4</artifactId>
            <version>4.4</version>
        </dependency>-->
        <!--<dependency>
            <groupId>org.apache.thrift</groupId>
            <artifactId>libfb303</artifactId>
            <version>0.9.3</version>
            <type>pom</type>
            <scope>provided</scope>
         </dependency>-->
        <!--<dependency>
           <groupId>com.google.guava</groupId>
           <artifactId>guava</artifactId>
           <version>28.2-jre</version>
       </dependency>-->

    </dependencies>

    <build>
        <sourceDirectory>src/main/java</sourceDirectory>
        <plugins>
            <!-- 编译插件 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.5.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <!--<encoding>${project.build.sourceEncoding}</encoding>-->
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.18.1</version>
                <configuration>
                    <useFile>false</useFile>
                    <disableXmlReport>true</disableXmlReport>
                    <includes>
                        <include>**/*Test.*</include>
                        <include>**/*Suite.*</include>
                    </includes>
                </configuration>
            </plugin>
            <!-- 打包插件(会包含所有依赖) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>2.3</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <filters>
                                <filter>
                                    <artifact>*:*</artifact>
                                    <excludes>
                                        <!--
                                        zip -d learn_spark.jar META-INF/*.RSA META-INF/*.DSA META-INF/*.SF -->
                                        <exclude>META-INF/*.SF</exclude>
                                        <exclude>META-INF/*.DSA</exclude>
                                        <exclude>META-INF/*.RSA</exclude>
                                    </excludes>
                                </filter>
                            </filters>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <!-- 设置jar包的入口类(可选) -->
                                    <mainClass></mainClass>
                                </transformer>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

##### log4j.properties

log4j.properties

```
log4j.rootLogger=WARN, console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{HH:mm:ss,SSS} %-5p %-60c %x - %m%n
```

#### Flink初体验

##### 需求

使用Flink实现WordCount

##### 编码步骤

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html)

![image.png](https://image.hyly.net/i/2025/09/28/8c5bbea7e07665ba6b2bc0bd626b273f-0.webp)

1.准备环境-env
2.准备数据-source
3.处理数据-transformation
4.输出结果-sink
5.触发执行-execute

其中创建环境可以使用如下3种方式:

```
getExecutionEnvironment() //推荐使用
createLocalEnvironment()
createRemoteEnvironment(String host, int port, String... jarFiles)
```

![image.png](https://image.hyly.net/i/2025/09/28/79b3c1d5e7ec4dccd7e4e46918ad8569-0.webp)

##### 代码实现

###### 基于DataSet

```java
package cn.itcast.hello;

import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.operators.Order;
import org.apache.flink.api.java.DataSet;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.api.java.operators.UnsortedGrouping;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 * 需求:使用Flink完成WordCount-DataSet
 * 编码步骤
 * 1.准备环境-env
 * 2.准备数据-source
 * 3.处理数据-transformation
 * 4.输出结果-sink
 * 5.触发执行-execute//如果有print,DataSet不需要调用execute,DataStream需要调用execute
 */
public class WordCount1 {
    public static void main(String[] args) throws Exception {
        //老版本的批处理API如下,但已经不推荐使用了
        //1.准备环境-env
        ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
        //2.准备数据-source
        DataSet<String> lineDS = env.fromElements("itcast hadoop spark","itcast hadoop spark","itcast hadoop","itcast");
        //3.处理数据-transformation
        //3.1每一行数据按照空格切分成一个个的单词组成一个集合
        /*
        public interface FlatMapFunction<T, O> extends Function, Serializable {
            void flatMap(T value, Collector<O> out) throws Exception;
        }
         */
        DataSet<String> wordsDS = lineDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        //3.2对集合中的每个单词记为1
        /*
        public interface MapFunction<T, O> extends Function, Serializable {
            O map(T value) throws Exception;
        }
         */
        DataSet<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(new MapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });

        //3.3对数据按照单词(key)进行分组
        //0表示按照tuple中的索引为0的字段,也就是key(单词)进行分组
        UnsortedGrouping<Tuple2<String, Integer>> groupedDS = wordAndOnesDS.groupBy(0);

        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        //1表示按照tuple中的索引为1的字段也就是按照数量进行聚合累加!
        DataSet<Tuple2<String, Integer>> aggResult = groupedDS.sum(1);

        //3.5排序
        DataSet<Tuple2<String, Integer>> result = aggResult.sortPartition(1, Order.DESCENDING).setParallelism(1);

        //4.输出结果-sink
        result.print();

        //5.触发执行-execute//如果有print,DataSet不需要调用execute,DataStream需要调用execute
        //env.execute();//'execute()', 'count()', 'collect()', or 'print()'.
    }
}
```

###### 基于DataStream

```
package cn.itcast.hello;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 * 需求:使用Flink完成WordCount-DataStream
 * 编码步骤
 * 1.准备环境-env
 * 2.准备数据-source
 * 3.处理数据-transformation
 * 4.输出结果-sink
 * 5.触发执行-execute
 */
public class WordCount2 {
    public static void main(String[] args) throws Exception {
        //新版本的流批统一API,既支持流处理也支持批处理
        //1.准备环境-env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //env.setRuntimeMode(RuntimeExecutionMode.STREAMING);
        //env.setRuntimeMode(RuntimeExecutionMode.BATCH);

        //2.准备数据-source
        DataStream<String> linesDS = env.fromElements("itcast hadoop spark","itcast hadoop spark","itcast hadoop","itcast");

        //3.处理数据-transformation
        //3.1每一行数据按照空格切分成一个个的单词组成一个集合
        /*
        public interface FlatMapFunction<T, O> extends Function, Serializable {
            void flatMap(T value, Collector<O> out) throws Exception;
        }
         */
        DataStream<String> wordsDS = linesDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        //3.2对集合中的每个单词记为1
        /*
        public interface MapFunction<T, O> extends Function, Serializable {
            O map(T value) throws Exception;
        }
         */
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(new MapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });

        //3.3对数据按照单词(key)进行分组
        //0表示按照tuple中的索引为0的字段,也就是key(单词)进行分组
        //KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOnesDS.keyBy(0);
KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);


        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        //1表示按照tuple中的索引为1的字段也就是按照数量进行聚合累加!
        DataStream<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.输出结果-sink
        result.print();

        //5.触发执行-execute
        env.execute();//DataStream需要调用execute
    }
}
```

###### Lambda版

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/java_lambdas.html#java-lambda-expressions](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/java_lambdas.html#java-lambda-expressions)

```
package cn.itcast.hello;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.typeinfo.TypeHint;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

import java.util.Arrays;

/**
 * Author itcast
 * Desc
 * 需求:使用Flink完成WordCount-DataStream--使用lambda表达式
 * 编码步骤
 * 1.准备环境-env
 * 2.准备数据-source
 * 3.处理数据-transformation
 * 4.输出结果-sink
 * 5.触发执行-execute
 */
public class WordCount3_Lambda {
    public static void main(String[] args) throws Exception {
        //1.准备环境-env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //env.setRuntimeMode(RuntimeExecutionMode.STREAMING);
        //env.setRuntimeMode(RuntimeExecutionMode.BATCH);

        //2.准备数据-source
        DataStream<String> linesDS = env.fromElements("itcast hadoop spark", "itcast hadoop spark", "itcast hadoop", "itcast");
        //3.处理数据-transformation
        //3.1每一行数据按照空格切分成一个个的单词组成一个集合
        /*
        public interface FlatMapFunction<T, O> extends Function, Serializable {
            void flatMap(T value, Collector<O> out) throws Exception;
        }
         */
        //lambda表达式的语法:
        // (参数)->{方法体/函数体}
        //lambda表达式就是一个函数,函数的本质就是对象
        DataStream<String> wordsDS = linesDS.flatMap(
                (String value, Collector<String> out) -> Arrays.stream(value.split(" ")).forEach(out::collect)
        ).returns(Types.STRING);

        //3.2对集合中的每个单词记为1
        /*
        public interface MapFunction<T, O> extends Function, Serializable {
            O map(T value) throws Exception;
        }
         */
        /*DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(
                (String value) -> Tuple2.of(value, 1)
        ).returns(Types.TUPLE(Types.STRING, Types.INT));*/
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(
                (String value) -> Tuple2.of(value, 1)
                , TypeInformation.of(new TypeHint<Tuple2<String, Integer>>() {})
        );

        //3.3对数据按照单词(key)进行分组
        //0表示按照tuple中的索引为0的字段,也就是key(单词)进行分组
        //KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOnesDS.keyBy(0);
        //KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy((KeySelector<Tuple2<String, Integer>, String>) t -> t.f0);
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);

        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        //1表示按照tuple中的索引为1的字段也就是按照数量进行聚合累加!
        DataStream<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.输出结果-sink
        result.print();

        //5.触发执行-execute
        env.execute();
    }
}
```

###### 在Yarn上运行

注意
写入HDFS如果存在权限问题:
进行如下设置:
hadoop fs -chmod -R 777  /
并在代码中添加:
System.setProperty("HADOOP_USER_NAME", "root")

1. 修改代码

```
package cn.itcast.hello;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

import java.util.Arrays;

/**
 * Author itcast
 * Desc
 * 需求:使用Flink完成WordCount-DataStream--使用lambda表达式--修改代码使适合在Yarn上运行
 * 编码步骤
 * 1.准备环境-env
 * 2.准备数据-source
 * 3.处理数据-transformation
 * 4.输出结果-sink
 * 5.触发执行-execute//批处理不需要调用!流处理需要
 */
public class WordCount4_Yarn {
    public static void main(String[] args) throws Exception {
        //获取参数
        ParameterTool params = ParameterTool.fromArgs(args);
        String output = null;
        if (params.has("output")) {
            output = params.get("output");
        } else {
            output = "hdfs://node1:8020/wordcount/output_" + System.currentTimeMillis();
        }

        //1.准备环境-env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //env.setRuntimeMode(RuntimeExecutionMode.STREAMING);
        //env.setRuntimeMode(RuntimeExecutionMode.BATCH);

        //2.准备数据-source
        DataStream<String> linesDS = env.fromElements("itcast hadoop spark", "itcast hadoop spark", "itcast hadoop", "itcast");
        //3.处理数据-transformation
        DataStream<Tuple2<String, Integer>> result = linesDS
                .flatMap(
                        (String value, Collector<String> out) -> Arrays.stream(value.split(" ")).forEach(out::collect)
                ).returns(Types.STRING)
                .map(
                        (String value) -> Tuple2.of(value, 1)
                ).returns(Types.TUPLE(Types.STRING, Types.INT))
                //.keyBy(0);
                .keyBy((KeySelector<Tuple2<String, Integer>, String>) t -> t.f0)
                .sum(1);

        //4.输出结果-sink
        result.print();

        //如果执行报hdfs权限相关错误,可以执行 hadoop fs -chmod -R 777  /
        System.setProperty("HADOOP_USER_NAME", "root");//设置用户名
        //result.writeAsText("hdfs://node1:8020/wordcount/output_"+System.currentTimeMillis()).setParallelism(1);
        result.writeAsText(output).setParallelism(1);

        //5.触发执行-execute
        env.execute();
    }
}
```

2. 打包

![image.png](https://image.hyly.net/i/2025/09/28/8ccac02eb0203bdf1d52be12b1f219d0-0.webp)

3. 改名

![image.png](https://image.hyly.net/i/2025/09/28/44048c2f09de853df68cb02fa043d92d-0.webp)

4. 上传

![image.png](https://image.hyly.net/i/2025/09/28/ade60d4e20eb1e39706868dccd9014fc-0.webp)

5. 提交执行

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_execution_mode.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_execution_mode.html)

![image.png](https://image.hyly.net/i/2025/09/28/c73a444fee2a60e324f9e97d1f7af089-0.webp)

```
/export/server/flink/bin/flink run -Dexecution.runtime-mode=BATCH -m yarn-cluster -yjm 1024 -ytm 1024 -c cn.itcast.hello.WordCount4_Yarn /root/wc.jar --output hdfs://node1:8020/wordcount/output_xx
```

6. 在Web页面可以观察到提交的程序：

[http://node1:8088/cluster](http://node1:8088/cluster)

[http://node1:50070/explorer.html#/](#/)

或者在Standalone模式下使用web界面提交

### Flink原理初探

#### Flink角色分工

在实际生产中，Flink 都是以集群在运行，在运行的过程中包含了两类进程。

1. **JobManager：**它扮演的是集群管理者的角色，负责调度任务、协调 checkpoints、协调故障恢复、收集 Job 的状态信息，并管理 Flink 集群中的从节点 TaskManager。
2. **TaskManager：** 实际负责执行计算的 Worker，在其上执行 Flink Job 的一组 Task；TaskManager 还是所在节点的管理员，它负责把该节点上的服务器信息比如内存、磁盘、任务运行情况等向 JobManager 汇报。
3. **Client：** 用户在提交编写好的 Flink 工程时，会先创建一个客户端再进行提交，这个客户端就是 Client![image.png](https://image.hyly.net/i/2025/09/28/efac0ce1cebee424d51b51246f8e9de9-0.webp)![image.png](https://image.hyly.net/i/2025/09/28/b6406d14b24a83f33b849f37f58a0bd6-0.webp)

#### Flink执行流程

[https://blog.csdn.net/sxiaobei/article/details/80861070](https://blog.csdn.net/sxiaobei/article/details/80861070)

[https://blog.csdn.net/super_wj0820/article/details/90726768](https://blog.csdn.net/super_wj0820/article/details/90726768)

[https://ci.apache.org/projects/flink/flink-docs-release-1.11/ops/deployment/yarn_setup.html](https://ci.apache.org/projects/flink/flink-docs-release-1.11/ops/deployment/yarn_setup.html)

##### Standalone版

![image.png](https://image.hyly.net/i/2025/09/28/415870d80e40d103c0e323ff73df8739-0.webp)

##### On Yarn版

![image.png](https://image.hyly.net/i/2025/09/28/d86e3c28dc2f9faf2cf7657d60e69ac4-0.webp)

1. Client向HDFS上传Flink的Jar包和配置
2. Client向Yarn ResourceManager提交任务并申请资源
3. ResourceManager分配Container资源并启动ApplicationMaster,然后AppMaster加载Flink的Jar包和配置构建环境,启动JobManager
4. ApplicationMaster向ResourceManager申请工作资源,NodeManager加载Flink的Jar包和配置构建环境并启动TaskManager
5. TaskManager启动后向JobManager发送心跳包，并等待JobManager向其分配任务

#### Flink Streaming Dataflow

官网关于Flink的词汇表

[https://ci.apache.org/projects/flink/flink-docs-release-1.11/concepts/glossary.html#glossary](https://ci.apache.org/projects/flink/flink-docs-release-1.11/concepts/glossary.html#glossary)

##### Dataflow、Operator、Partition、SubTask、Parallelism

1.Dataflow:Flink程序在执行的时候会被映射成一个数据流模型

2.Operator:数据流模型中的每一个操作被称作Operator,Operator分为:Source/Transform/Sink

3.Partition:数据流模型是分布式的和并行的,执行中会形成1~n个分区

4.Subtask:多个分区任务可以并行,每一个都是独立运行在一个线程中的,也就是一个Subtask子任务

5.Parallelism:并行度,就是可以同时真正执行的子任务数/分区数

![image.png](https://image.hyly.net/i/2025/09/28/47f68d14dcc634f5ccb6e08b1578283b-0.webp)

##### Operator传递模式

数据在两个operator(算子)之间传递的时候有两种模式：

1. **One to One模式：** 两个operator用此模式传递的时候，会保持数据的分区数和数据的排序；如上图中的Source1到Map1，它就保留的Source的分区特性，以及分区元素处理的有序性。--类似于Spark中的窄依赖
2. **Redistributing 模式：** 这种模式会改变数据的分区数；每个一个operator subtask会根据选择transformation把数据发送到不同的目标subtasks,比如keyBy()会通过hashcode重新分区,broadcast()和rebalance()方法会随机重新分区。--类似于Spark中的宽依赖

##### Operator Chain

![image.png](https://image.hyly.net/i/2025/09/28/0b13ad5ae626cd53101dceb40d191b07-0.webp)

客户端在提交任务的时候会对Operator进行优化操作，能进行合并的Operator会被合并为一个Operator，

合并后的Operator称为Operator chain，实际上就是一个执行链，每个执行链会在TaskManager上一个独立的线程中执行--就是SubTask。

##### TaskSlot And Slot Sharing

**任务槽(TaskSlot)**

![image.png](https://image.hyly.net/i/2025/09/28/e82b697917638490a53a80ac8d58b5b8-0.webp)

每个TaskManager是一个JVM的进程, 为了控制一个TaskManager(worker)能接收多少个task，Flink通过Task Slot来进行控制。TaskSlot数量是用来限制一个TaskManager工作进程中可以同时运行多少个工作线程，TaskSlot 是一个 TaskManager 中的最小资源分配单位，一个 TaskManager 中有多少个 TaskSlot 就意味着能支持多少并发的Task处理。

Flink将进程的内存进行了划分到多个slot中，内存被划分到不同的slot之后可以获得如下好处:

1. TaskManager最多能同时并发执行的子任务数是可以通过TaskSolt数量来控制的
2. TaskSolt有独占的内存空间，这样在一个TaskManager中可以运行多个不同的作业，作业之间不受影响。

**槽共享(Slot Sharing)**

![image.png](https://image.hyly.net/i/2025/09/28/835ca307b979355d30b0280f75c8bf01-0.webp)

Flink允许子任务共享插槽，即使它们是不同任务(阶段)的子任务(subTask)，只要它们来自同一个作业。

比如图左下角中的map和keyBy和sink 在一个 TaskSlot 里执行以达到资源共享的目的。

允许插槽共享有两个主要好处：

1. 资源分配更加公平，如果有比较空闲的slot可以将更多的任务分配给它。
2. 有了任务槽共享，可以提高资源的利用率。

注意:

slot是静态的概念，是指taskmanager具有的并发执行能力

parallelism是动态的概念，是指程序运行时实际使用的并发能力

#### Flink运行时组件

![image.png](https://image.hyly.net/i/2025/09/28/81a085daeace5dd30792e7347f3b8473-0.webp)

Flink运行时架构主要包括四个不同的组件，它们会在运行流处理应用程序时协同工作：

1. 作业管理器（JobManager）：分配任务、调度checkpoint做快照
2. 任务管理器（TaskManager）：主要干活的
3. 资源管理器（ResourceManager）：管理分配资源
4. 分发器（Dispatcher）：方便递交任务的接口，WebUI

因为Flink是用Java和Scala实现的，所以所有组件都会运行在Java虚拟机上。每个组件的职责如下：

1. 作业管理器（JobManager）
   1. 控制一个应用程序执行的主进程，也就是说，每个应用程序都会被一个不同的JobManager 所控制执行。
   2. JobManager 会先接收到要执行的应用程序，这个应用程序会包括：作业图（JobGraph）、逻辑数据流图（logical dataflow graph）和打包了所有的类、库和其它资源的JAR包。
   3. JobManager 会把JobGraph转换成一个物理层面的数据流图，这个图被叫做“执行图”（ExecutionGraph），包含了所有可以并发执行的任务。
   4. JobManager 会向资源管理器（ResourceManager）请求执行任务必要的资源，也就是任务管理器（TaskManager）上的插槽（slot）。一旦它获取到了足够的资源，就会将执行图分发到真正运行它们的TaskManager上。而在运行过程中，JobManager会负责所有需要中央协调的操作，比如说检查点（checkpoints）的协调。
2. 任务管理器（TaskManager）
   1. Flink中的工作进程。通常在Flink中会有多个TaskManager运行，每一个TaskManager都包含了一定数量的插槽（slots）。插槽的数量限制了TaskManager能够执行的任务数量。
   2. 启动之后，TaskManager会向资源管理器注册它的插槽；收到资源管理器的指令后，TaskManager就会将一个或者多个插槽提供给JobManager调用。JobManager就可以向插槽分配任务（tasks）来执行了。
   3. 在执行过程中，一个TaskManager可以跟其它运行同一应用程序的TaskManager交换数据。
3. 资源管理器（ResourceManager）
   1. 主要负责管理任务管理器（TaskManager）的插槽（slot），TaskManger 插槽是Flink中定义的处理资源单元。
   2. Flink为不同的环境和资源管理工具提供了不同资源管理器，比如YARN、Mesos、K8s，以及standalone部署。
   3. 当JobManager申请插槽资源时，ResourceManager会将有空闲插槽的TaskManager分配给JobManager。如果ResourceManager没有足够的插槽来满足JobManager的请求，它还可以向资源提供平台发起会话，以提供启动TaskManager进程的容器。
4. 分发器（Dispatcher）
   1. 可以跨作业运行，它为应用提交提供了REST接口。
   2. 当一个应用被提交执行时，分发器就会启动并将应用移交给一个JobManager。
   3. Dispatcher也会启动一个Web UI，用来方便地展示和监控作业执行的信息。
   4. Dispatcher在架构中可能并不是必需的，这取决于应用提交运行的方式。

#### Flink执行图（ExecutionGraph）

由Flink程序直接映射成的数据流图是 **StreamGraph** ，也被称为逻辑流图，因为它们表示的是计算逻辑的高级视图。为了执行一个流处理程序，Flink需要将逻辑流图转换为物理数据流图（也叫执行图），详细说明程序的执行方式。

Flink 中的执行图可以分成四层： **StreamGraph -> JobGraph -> ExecutionGraph -> 物理执行图** 。

![image.png](https://image.hyly.net/i/2025/09/28/5be37082d85fb038a4afbb8d86a72dd9-0.webp)

**原理介绍**

1. Flink执行executor会自动根据程序代码生成DAG数据流图
2. Flink 中的执行图可以分成四层：StreamGraph -> JobGraph -> ExecutionGraph -> 物理执行图。
   1. **StreamGraph** ：是根据用户通过 Stream API 编写的代码生成的最初的图。表示程序的拓扑结构。
   2. **JobGraph** ：StreamGraph经过优化后生成了 JobGraph，提交给 JobManager 的数据结构。主要的优化为，将多个符合条件的节点 chain 在一起作为一个节点，这样可以减少数据在节点之间流动所需要的序列化/反序列化/传输消耗。
   3. **ExecutionGraph** ：JobManager 根据 JobGraph 生成ExecutionGraph。ExecutionGraph是JobGraph的并行化版本，是调度层最核心的数据结构。
   4. **物理执行图** ：JobManager 根据 ExecutionGraph 对 Job 进行调度后，在各个TaskManager 上部署 Task 后形成的“图”，并不是一个具体的数据结构。

**简单理解：**

**StreamGraph：** 最初的程序执行逻辑流程，也就是算子之间的前后顺序--在Client上生成
**JobGraph：** 将OneToOne的Operator合并为OperatorChain--在Client上生成
**ExecutionGraph：** 将JobGraph根据代码中设置的并行度和请求的资源进行并行化规划!--在JobManager上生成
**物理执行图：** 将ExecutionGraph的并行计划,落实到具体的TaskManager上，将具体的SubTask落实到具体的TaskSlot内进行运行。

## Flink-流批一体API

### 流处理相关概念

#### 数据的时效性

日常工作中，我们一般会先把数据存储在表，然后对表的数据进行加工、分析。既然先存储在表中，那就会涉及到时效性概念。

如果我们处理以年，月为单位的级别的数据处理，进行统计分析，个性化推荐，那么数据的的最新日期离当前有几个甚至上月都没有问题。但是如果我们处理的是以天为级别，或者一小时甚至更小粒度的数据处理，那么就要求数据的时效性更高了。比如：对网站的实时监控、对异常日志的监控，这些场景需要工作人员立即响应，这样的场景下，传统的统一收集数据，再存到数据库中，再取出来进行分析就无法满足高时效性的需求了。

#### 流处理和批处理

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/learn-flink/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/learn-flink/)

![image.png](https://image.hyly.net/i/2025/09/28/ed54232909fd180fdb5db74482f2f47c-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/81cead884994cce6e057d2badd9abd4f-0.webp)

1. Batch Analytics，右边是 Streaming Analytics。批量计算: 统一收集数据->存储到DB->对数据进行批量处理，就是传统意义上使用类似于 Map Reduce、Hive、Spark Batch 等，对作业进行分析、处理、生成离线报表
2. Streaming Analytics 流式计算，顾名思义，就是对数据流进行处理，如使用流式分析引擎如 Storm，Flink 实时处理分析数据，应用较多的场景如实时大屏、实时报表。

![image.png](https://image.hyly.net/i/2025/09/28/7dfa43a86845e31f3cf579128cf78d19-0.webp)

#### 流批一体API

**DataStream API 支持批执行模式**

Flink 的核心 API 最初是针对特定的场景设计的，尽管 Table API / SQL 针对流处理和批处理已经实现了统一的 API，但当用户使用较底层的 API 时，仍然需要在批处理（DataSet API）和流处理（DataStream API）这两种不同的 API 之间进行选择。鉴于批处理是流处理的一种特例，将这两种 API 合并成统一的 API，有一些非常明显的好处，比如：

1. 可复用性：作业可以在流和批这两种执行模式之间自由地切换，而无需重写任何代码。因此，用户可以复用同一个作业，来处理实时数据和历史数据。
2. 维护简单：统一的 API 意味着流和批可以共用同一组 connector，维护同一套代码，并能够轻松地实现流批混合执行，例如 backfilling 之类的场景。

考虑到这些优点，社区已朝着流批统一的 DataStream API 迈出了第一步：支持高效的批处理（FLIP-134）。从长远来看，这意味着 DataSet API 将被弃用（FLIP-131），其功能将被包含在 DataStream API 和 Table API / SQL 中。

**API**

Flink提供了多个层次的API供开发者使用，越往上抽象程度越高，使用起来越方便；越往下越底层，使用起来难度越大

![image.png](https://image.hyly.net/i/2025/09/28/94be3b05d89f6aa0ef8dd3ac9a9e6d5a-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/36ae272b9b17b4670d56911cee5e082b-0.webp)

注意：在Flink1.12时支持流批一体，DataSetAPI已经不推荐使用了，所以课程中除了个别案例使用DataSet外，后续其他案例都会优先使用DataStream流式API，既支持无界数据处理/流处理，也支持有界数据处理/批处理！当然Table&SQL-API会单独学习

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/batch/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/batch/)

[https://developer.aliyun.com/article/780123?spm=a2c6h.12873581.0.0.1e3e46ccbYFFrC](https://developer.aliyun.com/article/780123?spm=a2c6h.12873581.0.0.1e3e46ccbYFFrC)

![image.png](https://image.hyly.net/i/2025/09/28/33e098a51798af0d8ebe7c8c9e9eb5fe-0.webp)

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/datastream_api.html)

![image.png](https://image.hyly.net/i/2025/09/28/6a7e1cc59e3fcd1ba7854a901290d61f-0.webp)

**编程模型**

Flink 应用程序结构主要包含三部分,Source/Transformation/Sink,如下图所示：

![image.png](https://image.hyly.net/i/2025/09/28/760d276be284af49980cff47f2e826ff-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/f62f3fb05b8514eaf431bba92de1e72d-0.webp)

### Source

![image.png](https://image.hyly.net/i/2025/09/28/214cc82890ded2d1ee449e18fe34571c-0.webp)

#### 预定义Source

##### 基于集合的Source

**API**

一般用于学习测试时编造数据时使用

1. env.fromElements(可变参数);
2. env.fromColletion(各种集合);
3. env.generateSequence(开始,结束);
4. env.fromSequence(开始,结束);

**代码演示:**

```java
package cn.itcast.source;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.util.Arrays;

/**
 * Author itcast
 * Desc
 * 把本地的普通的Java集合/Scala集合变为分布式的Flink的DataStream集合!
 * 一般用于学习测试时编造数据时使用
 * 1.env.fromElements(可变参数);
 * 2.env.fromColletion(各种集合);
 * 3.env.generateSequence(开始,结束);
 * 4.env.fromSequence(开始,结束);
 */
public class SourceDemo01 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.source
        // * 1.env.fromElements(可变参数);
        DataStream<String> ds1 = env.fromElements("hadoop", "spark", "flink");
        // * 2.env.fromColletion(各种集合);
        DataStream<String> ds2 = env.fromCollection(Arrays.asList("hadoop", "spark", "flink"));
        // * 3.env.generateSequence(开始,结束);
        DataStream<Long> ds3 = env.generateSequence(1, 10);
        //* 4.env.fromSequence(开始,结束);
        DataStream<Long> ds4 = env.fromSequence(1, 10);
        //3.Transformation
        //4.sink
        ds1.print();
        ds2.print();
        ds3.print();
        ds4.print();
        //5.execute
        env.execute();
    }
}
```

##### 基于文件的Source

**API**

一般用于学习测试

env.readTextFile(本地/HDFS文件/文件夹);//压缩文件也可以

**代码演示:**

```java
package cn.itcast.source;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 * 1.env.readTextFile(本地/HDFS文件/文件夹);//压缩文件也可以
 */
public class SourceDemo02 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.source
        // * 1.env.readTextFile(本地文件/HDFS文件);//压缩文件也可以
        DataStream<String> ds1 = env.readTextFile("data/input/words.txt");
        DataStream<String> ds2 = env.readTextFile("data/input/dir");
        DataStream<String> ds3 = env.readTextFile("hdfs://node1:8020//wordcount/input/words.txt");
        DataStream<String> ds4 = env.readTextFile("data/input/wordcount.txt.gz");
        //3.Transformation
        //4.sink
        ds1.print();
        ds2.print();
        ds3.print();
        ds4.print();
        //5.execute
        env.execute();
    }
}
```

##### 基于Socket的Source

一般用于学习测试

**需求:**

1. 在node1上使用nc -lk 9999 向指定端口发送数据

nc是netcat的简称，原本是用来设置路由器,我们可以利用它向某个端口发送数据

如果没有该命令可以下安装

yum install -y nc

2. 使用Flink编写流处理应用程序实时统计单词数量

代码实现:

```java
package cn.itcast.source;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 * SocketSource
 */
public class SourceDemo03 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.处理数据-transformation
        //3.1每一行数据按照空格切分成一个个的单词组成一个集合
        DataStream<String> wordsDS = linesDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        //3.2对集合中的每个单词记为1
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(new MapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });

        //3.3对数据按照单词(key)进行分组
        //KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOnesDS.keyBy(0);
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);
        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        DataStream<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.输出结果-sink
        result.print();

        //5.触发执行-execute
        env.execute();
    }
}
```

#### 自定义Source

##### 随机生成数据

**API**

一般用于学习测试,模拟生成一些数据

Flink还提供了数据源接口,我们实现该接口就可以实现自定义数据源，不同的接口有不同的功能，分类如下：

SourceFunction:非并行数据源(并行度只能=1)

RichSourceFunction:多功能非并行数据源(并行度只能=1)

ParallelSourceFunction:并行数据源(并行度能够>=1)

RichParallelSourceFunction:多功能并行数据源(并行度能够>=1)--后续学习的Kafka数据源使用的就是该接口

**需求**

每隔1秒随机生成一条订单信息(订单ID、用户ID、订单金额、时间戳)

要求:

1. 随机生成订单ID(UUID)
2. 随机生成用户ID(0-2)
3. 随机生成订单金额(0-100)
4. 时间戳为当前系统时间

**代码实现**

```java
package cn.itcast.source;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction;

import java.util.Random;
import java.util.UUID;

/**
 * Author itcast
 * Desc
 *需求
 * 每隔1秒随机生成一条订单信息(订单ID、用户ID、订单金额、时间戳)
 * 要求:
 * - 随机生成订单ID(UUID)
 * - 随机生成用户ID(0-2)
 * - 随机生成订单金额(0-100)
 * - 时间戳为当前系统时间
 *
 * API
 * 一般用于学习测试,模拟生成一些数据
 * Flink还提供了数据源接口,我们实现该接口就可以实现自定义数据源，不同的接口有不同的功能，分类如下：
 * SourceFunction:非并行数据源(并行度只能=1)
 * RichSourceFunction:多功能非并行数据源(并行度只能=1)
 * ParallelSourceFunction:并行数据源(并行度能够>=1)
 * RichParallelSourceFunction:多功能并行数据源(并行度能够>=1)--后续学习的Kafka数据源使用的就是该接口
 */
public class SourceDemo04_Customer {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.Source
        DataStream<Order> orderDS = env
                .addSource(new MyOrderSource())
                .setParallelism(2);

        //3.Transformation

        //4.Sink
        orderDS.print();
        //5.execute
        env.execute();
    }
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Order {
        private String id;
        private Integer userId;
        private Integer money;
        private Long createTime;
    }
    public static class MyOrderSource extends RichParallelSourceFunction<Order> {
        private Boolean flag = true;
        @Override
        public void run(SourceContext<Order> ctx) throws Exception {
            Random random = new Random();
            while (flag){
                Thread.sleep(1000);
                String id = UUID.randomUUID().toString();
                int userId = random.nextInt(3);
                int money = random.nextInt(101);
                long createTime = System.currentTimeMillis();
                ctx.collect(new Order(id,userId,money,createTime));
            }
        }
        //取消任务/执行cancle命令的时候执行
        @Override
        public void cancel() {
            flag = false;
        }
    }
}
```

##### MySQL

**需求:**

实际开发中,经常会实时接收一些数据,要和MySQL中存储的一些规则进行匹配,那么这时候就可以使用Flink自定义数据源从MySQL中读取数据

那么现在先完成一个简单的需求:

从MySQL中实时加载数据

要求MySQL中的数据有变化,也能被实时加载出来

**准备数据**

```sql
CREATE TABLE `t_student` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) DEFAULT NULL,
    `age` int(11) DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

INSERT INTO `t_student` VALUES ('1', 'jack', '18');
INSERT INTO `t_student` VALUES ('2', 'tom', '19');
INSERT INTO `t_student` VALUES ('3', 'rose', '20');
INSERT INTO `t_student` VALUES ('4', 'tom', '19');
INSERT INTO `t_student` VALUES ('5', 'jack', '18');
INSERT INTO `t_student` VALUES ('6', 'rose', '20');
```

**代码实现:**

```jav
package cn.itcast.source;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 * 需求:
 * 实际开发中,经常会实时接收一些数据,要和MySQL中存储的一些规则进行匹配,那么这时候就可以使用Flink自定义数据源从MySQL中读取数据
 * 那么现在先完成一个简单的需求:
 * 从MySQL中实时加载数据
 * 要求MySQL中的数据有变化,也能被实时加载出来
 */
public class SourceDemo05_Customer_MySQL {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStream<Student> studentDS = env.addSource(new MySQLSource()).setParallelism(1);

        //3.Transformation
        //4.Sink
        studentDS.print();

        //5.execute
        env.execute();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Student {
        private Integer id;
        private String name;
        private Integer age;
    }

    public static class MySQLSource extends RichParallelSourceFunction<Student> {
        private Connection conn = null;
        private PreparedStatement ps = null;

        @Override
        public void open(Configuration parameters) throws Exception {
            //加载驱动,开启连接
            //Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bigdata", "root", "root");
            String sql = "select id,name,age from t_student";
            ps = conn.prepareStatement(sql);
        }

        private boolean flag = true;

        @Override
        public void run(SourceContext<Student> ctx) throws Exception {
            while (flag) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    int age = rs.getInt("age");
                    ctx.collect(new Student(id, name, age));
                }
                TimeUnit.SECONDS.sleep(5);
            }
        }
        @Override
        public void cancel() {
            flag = false;
        }
        @Override
        public void close() throws Exception {
            if (conn != null) conn.close();
            if (ps != null) ps.close();
        }
    }
}
```

### Transformation

#### 官网API列表

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/)

![image.png](https://image.hyly.net/i/2025/09/28/d8b55ebf16b24ed3bd860fdfc325e9e6-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/ccf5b5acbcd128bbbd8f1f0df25e85b4-0.webp)

整体来说，流式数据上的操作可以分为四类。

1. 第一类是对于单条记录的操作，比如筛除掉不符合要求的记录（Filter 操作），或者将每条记录都做一个转换（Map 操作）
2. 第二类是对多条记录的操作。比如说统计一个小时内的订单总成交量，就需要将一个小时内的所有订单记录的成交量加到一起。为了支持这种类型的操作，就得通过 Window 将需要的记录关联到一起进行处理
3. 第三类是对多个流进行操作并转换为单个流。例如，多个流可以通过 Union、Join 或 Connect 等操作合到一起。这些操作合并的逻辑不同，但是它们最终都会产生了一个新的统一的流，从而可以进行一些跨流的操作。
4. 最后， DataStream 还支持与合并对称的拆分操作，即把一个流按一定规则拆分为多个流（Split 操作），每个流是之前流的一个子集，这样我们就可以对不同的流作不同的处理。

#### 基本操作-略

##### map

**API**

map:将函数作用在集合中的每一个元素上,并返回作用后的结果

![image.png](https://image.hyly.net/i/2025/09/28/a0dffc92b348d0c0ab8bbe6afaba93ae-0.webp)

##### flatMap

**API**

flatMap:将集合中的每个元素变成一个或多个元素,并返回扁平化之后的结果

![image.png](https://image.hyly.net/i/2025/09/28/33c66e829aabac12c8f46e9f0bb74695-0.webp)

##### keyBy

按照指定的key来对流中的数据进行分组，前面入门案例中已经演示过

注意:

流处理中没有groupBy,而是keyBy

![image.png](https://image.hyly.net/i/2025/09/28/42dc7239ae62d50dff588fb9bd724c4b-0.webp)

##### filter

**API**

filter:按照指定的条件对集合中的元素进行过滤,过滤出返回true/符合条件的元素

![image.png](https://image.hyly.net/i/2025/09/28/c34d252910267c53b67b60dc216a704d-0.webp)

##### sum

**API**

sum:按照指定的字段对集合中的元素进行求和

##### reduce

**API**

reduce:对集合中的元素进行聚合

![image.png](https://image.hyly.net/i/2025/09/28/bae04ab86ef121403da7852f88a91af6-0.webp)

##### 代码演示

**需求:**

对流数据中的单词进行统计，排除敏感词heihei

**代码演示**

```java
package cn.itcast.transformation;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FilterFunction;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.functions.ReduceFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 */
public class TransformationDemo01 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.处理数据-transformation
        DataStream<String> wordsDS = linesDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        DataStream<String> filtedDS = wordsDS.filter(new FilterFunction<String>() {
            @Override
            public boolean filter(String value) throws Exception {
                return !value.equals("heihei");
            }
        });
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = filtedDS.map(new MapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });
        //KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOnesDS.keyBy(0);
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);

        DataStream<Tuple2<String, Integer>> result1 = groupedDS.sum(1);
        DataStream<Tuple2<String, Integer>> result2 = groupedDS.reduce(new ReduceFunction<Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> reduce(Tuple2<String, Integer> value1, Tuple2<String, Integer> value2) throws Exception {
                return Tuple2.of(value1.f0, value1.f1 + value1.f1);
            }
        });

        //4.输出结果-sink
        result1.print("result1");
        result2.print("result2");

        //5.触发执行-execute
        env.execute();
    }
}
```

#### 合并-拆分

##### union和connect

**API**

**union：**

union算子可以合并多个同类型的数据流，并生成同类型的数据流，即可以将多个DataStream[T]合并为一个新的DataStream[T]。数据将按照先进先出（First In First Out）的模式合并，且不去重。

![image.png](https://image.hyly.net/i/2025/09/28/5c315000f874a28fb5417b13d79db0d2-0.webp)

**connect：**

connect提供了和union类似的功能，用来连接两个数据流，它与union的区别在于：

connect只能连接两个数据流，union可以连接多个数据流。

connect所连接的两个数据流的数据类型可以不一致，union所连接的两个数据流的数据类型必须一致。

两个DataStream经过connect之后被转化为ConnectedStreams，ConnectedStreams会对两个流的数据应用不同的处理方法，且双流之间可以共享状态。

![image.png](https://image.hyly.net/i/2025/09/28/9bf58e105d0701f1bc27693fe3297eb1-0.webp)

**需求**

将两个String类型的流进行union

将一个String类型和一个Long类型的流进行connect

**代码实现**

```java
package cn.itcast.transformation;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.streaming.api.datastream.ConnectedStreams;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.co.CoMapFunction;

/**
 * Author itcast
 * Desc
 */
public class TransformationDemo02 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);

        //2.Source
        DataStream<String> ds1 = env.fromElements("hadoop", "spark", "flink");
        DataStream<String> ds2 = env.fromElements("hadoop", "spark", "flink");
        DataStream<Long> ds3 = env.fromElements(1L, 2L, 3L);

        //3.Transformation
        DataStream<String> result1 = ds1.union(ds2);//合并但不去重 https://blog.csdn.net/valada/article/details/104367378
        ConnectedStreams<String, Long> tempResult = ds1.connect(ds3);
        //interface CoMapFunction<IN1, IN2, OUT>
        DataStream<String> result2 = tempResult.map(new CoMapFunction<String, Long, String>() {
            @Override
            public String map1(String value) throws Exception {
                return "String->String:" + value;
            }

            @Override
            public String map2(Long value) throws Exception {
                return "Long->String:" + value.toString();
            }
        });

        //4.Sink
        result1.print();
        result2.print();

        //5.execute
        env.execute();
    }
}
```

##### split、select和Side Outputs

**API**

Split就是将一个流分成多个流

Select就是获取分流后对应的数据

注意：split函数已过期并移除

Side Outputs：可以使用process方法对流中数据进行处理，并针对不同的处理结果将数据收集到不同的OutputTag中

**需求:**

对流中的数据按照奇数和偶数进行分流，并获取分流后的数据

**代码实现:**

```java
package cn.itcast.transformation;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.ProcessFunction;
import org.apache.flink.util.Collector;
import org.apache.flink.util.OutputTag;

/**
 * Author itcast
 * Desc
 */
public class TransformationDemo03 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);

        //2.Source
        DataStreamSource<Integer> ds = env.fromElements(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        //3.Transformation
        /*SplitStream<Integer> splitResult = ds.split(new OutputSelector<Integer>() {
            @Override
            public Iterable<String> select(Integer value) {
                //value是进来的数字
                if (value % 2 == 0) {
                    //偶数
                    ArrayList<String> list = new ArrayList<>();
                    list.add("偶数");
                    return list;
                } else {
                    //奇数
                    ArrayList<String> list = new ArrayList<>();
                    list.add("奇数");
                    return list;
                }
            }
        });
        DataStream<Integer> evenResult = splitResult.select("偶数");
        DataStream<Integer> oddResult = splitResult.select("奇数");*/

        //定义两个输出标签
        OutputTag<Integer> tag_even = new OutputTag<Integer>("偶数", TypeInformation.of(Integer.class));
        OutputTag<Integer> tag_odd = new OutputTag<Integer>("奇数"){};
        //对ds中的数据进行处理
        SingleOutputStreamOperator<Integer> tagResult = ds.process(new ProcessFunction<Integer, Integer>() {
            @Override
            public void processElement(Integer value, Context ctx, Collector<Integer> out) throws Exception {
                if (value % 2 == 0) {
                    //偶数
                    ctx.output(tag_even, value);
                } else {
                    //奇数
                    ctx.output(tag_odd, value);
                }
            }
        });

        //取出标记好的数据
        DataStream<Integer> evenResult = tagResult.getSideOutput(tag_even);
        DataStream<Integer> oddResult = tagResult.getSideOutput(tag_odd);

        //4.Sink
        evenResult.print("偶数");
        oddResult.print("奇数");

        //5.execute
        env.execute();
    }
}
```

#### 分区

##### rebalance重平衡分区

**API**

类似于Spark中的repartition,但是功能更强大,可以直接解决数据倾斜

Flink也有数据倾斜的时候，比如当前有数据量大概10亿条数据需要处理，在处理过程中可能会发生如图所示的状况，出现了数据倾斜，其他3台机器执行完毕也要等待机器1执行完毕后才算整体将任务完成；

![image.png](https://image.hyly.net/i/2025/09/28/e42664a55f88f1fd687d5b4045b05bfe-0.webp)

所以在实际的工作中，出现这种情况比较好的解决方案就是rebalance(内部使用round robin方法将数据均匀打散)

![image.png](https://image.hyly.net/i/2025/09/28/2eba09fa7fe1f9c4d1ff1d1e1a2522b4-0.webp)

**代码演示:**

```java
package cn.itcast.transformation;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FilterFunction;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 */
public class TransformationDemo04 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC).setParallelism(3);

        //2.source
        DataStream<Long> longDS = env.fromSequence(0, 100);

        //3.Transformation
        //下面的操作相当于将数据随机分配一下,有可能出现数据倾斜
        DataStream<Long> filterDS = longDS.filter(new FilterFunction<Long>() {
            @Override
            public boolean filter(Long num) throws Exception {
                return num > 10;
            }
        });

        //接下来使用map操作,将数据转为(分区编号/子任务编号, 数据)
        //Rich表示多功能的,比MapFunction要多一些API可以供我们使用
        DataStream<Tuple2<Integer, Integer>> result1 = filterDS
                .map(new RichMapFunction<Long, Tuple2<Integer, Integer>>() {
                    @Override
                    public Tuple2<Integer, Integer> map(Long value) throws Exception {
                        //获取分区编号/子任务编号
                        int id = getRuntimeContext().getIndexOfThisSubtask();
                        return Tuple2.of(id, 1);
                    }
                }).keyBy(t -> t.f0).sum(1);

        DataStream<Tuple2<Integer, Integer>> result2 = filterDS.rebalance()
                .map(new RichMapFunction<Long, Tuple2<Integer, Integer>>() {
                    @Override
                    public Tuple2<Integer, Integer> map(Long value) throws Exception {
                        //获取分区编号/子任务编号
                        int id = getRuntimeContext().getIndexOfThisSubtask();
                        return Tuple2.of(id, 1);
                    }
                }).keyBy(t -> t.f0).sum(1);

        //4.sink
        //result1.print();//有可能出现数据倾斜
        result2.print();//在输出前进行了rebalance重分区平衡,解决了数据倾斜

        //5.execute
        env.execute();
    }
}
```

##### 其他分区

**API**

![image.png](https://image.hyly.net/i/2025/09/28/9e54d4cd74e3e5bb7dd2b3ebec6afee1-0.webp)

说明:

recale分区。基于上下游Operator的并行度，将记录以循环的方式输出到下游Operator的每个实例。

举例:

上游并行度是2，下游是4，则上游一个并行度以循环的方式将记录输出到下游的两个并行度上;上游另一个并行度以循环的方式将记录输出到下游另两个并行度上。若上游并行度是4，下游并行度是2，则上游两个并行度将记录输出到下游一个并行度上；上游另两个并行度将记录输出到下游另一个并行度上。

**需求:**

对流中的元素使用各种分区,并输出

**代码实现**

```java
package cn.itcast.transformation;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.Partitioner;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 */
public class TransformationDemo05 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);

        //2.Source
        DataStream<String> linesDS = env.readTextFile("data/input/words.txt");
        SingleOutputStreamOperator<Tuple2<String, Integer>> tupleDS = linesDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });

        //3.Transformation
        DataStream<Tuple2<String, Integer>> result1 = tupleDS.global();
        DataStream<Tuple2<String, Integer>> result2 = tupleDS.broadcast();
        DataStream<Tuple2<String, Integer>> result3 = tupleDS.forward();
        DataStream<Tuple2<String, Integer>> result4 = tupleDS.shuffle();
        DataStream<Tuple2<String, Integer>> result5 = tupleDS.rebalance();
        DataStream<Tuple2<String, Integer>> result6 = tupleDS.rescale();
        DataStream<Tuple2<String, Integer>> result7 = tupleDS.partitionCustom(new Partitioner<String>() {
            @Override
            public int partition(String key, int numPartitions) {
                return key.equals("hello") ? 0 : 1;
            }
        }, t -> t.f0);

        //4.sink
        //result1.print();
        //result2.print();
        //result3.print();
        //result4.print();
        //result5.print();
        //result6.print();
        result7.print();

        //5.execute
        env.execute();
    }
}
```

### Sink

![image.png](https://image.hyly.net/i/2025/09/28/56dff5e5b68d7e0ce2fdc04a767d365c-0.webp)

#### 预定义Sink

##### 基于控制台和文件的Sink

**API**

1.ds.print 直接输出到控制台

2.ds.printToErr() 直接输出到控制台,用红色

3.ds.writeAsText("本地/HDFS的path",WriteMode.OVERWRITE).setParallelism(1)

**注意:**

在输出到path的时候,可以在前面设置并行度,如果

并行度>1,则path为目录

并行度=1,则path为文件名

**代码演示:**

```java
package cn.itcast.sink;

import org.apache.flink.core.fs.FileSystem;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 * 1.ds.print 直接输出到控制台
 * 2.ds.printToErr() 直接输出到控制台,用红色
 * 3.ds.collect 将分布式数据收集为本地集合
 * 4.ds.setParallelism(1).writeAsText("本地/HDFS的path",WriteMode.OVERWRITE)
 */
public class SinkDemo01 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        //2.source
        //DataStream<String> ds = env.fromElements("hadoop", "flink");
        DataStream<String> ds = env.readTextFile("data/input/words.txt");

        //3.transformation
        //4.sink
        ds.print();
        ds.printToErr();
        ds.writeAsText("data/output/test", FileSystem.WriteMode.OVERWRITE).setParallelism(2);
        //注意:
        //Parallelism=1为文件
        //Parallelism>1为文件夹

        //5.execute
        env.execute();
    }
}
```

#### 自定义Sink

##### MySQL

**需求:**

将Flink集合中的数据通过自定义Sink保存到MySQL

**代码实现:**

```java
package cn.itcast.sink;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.RichSinkFunction;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

/**
 * Author itcast
 * Desc
 * 使用自定义sink将数据保存到MySQL
 */
public class SinkDemo02_MySQL {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStream<Student> studentDS = env.fromElements(new Student(null, "tonyma", 18));
        //3.Transformation
        //4.Sink
        studentDS.addSink(new MySQLSink());

        //5.execute
        env.execute();
    }
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Student {
        private Integer id;
        private String name;
        private Integer age;
    }

    public static class MySQLSink extends RichSinkFunction<Student> {
        private Connection conn = null;
        private PreparedStatement ps = null;

        @Override
        public void open(Configuration parameters) throws Exception {
            //加载驱动,开启连接
            //Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bigdata", "root", "root");
            String sql = "INSERT INTO `t_student` (`id`, `name`, `age`) VALUES (null, ?, ?)";
            ps = conn.prepareStatement(sql);
        }

        @Override
        public void invoke(Student value, Context context) throws Exception {
            //给ps中的?设置具体值
            ps.setString(1,value.getName());
            ps.setInt(2,value.getAge());
            //执行sql
            ps.executeUpdate();
        }

        @Override
        public void close() throws Exception {
            if (conn != null) conn.close();
            if (ps != null) ps.close();
        }
    }
}
```

### Connectors

#### JDBC

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/jdbc.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/jdbc.html)

```
package cn.itcast.connectors;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.connector.jdbc.JdbcConnectionOptions;
import org.apache.flink.connector.jdbc.JdbcSink;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 */
public class ConnectorsDemo_JDBC {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        env.fromElements(new Student(null, "tonyma", 18))
                //3.Transformation
                //4.Sink
                .addSink(JdbcSink.sink(
                        "INSERT INTO `t_student` (`id`, `name`, `age`) VALUES (null, ?, ?)",
                        (ps, s) -> {
                            ps.setString(1, s.getName());
                            ps.setInt(2, s.getAge());
                        },
                        new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                                .withUrl("jdbc:mysql://localhost:3306/bigdata")
                                .withUsername("root")
                                .withPassword("root")
                                .withDriverName("com.mysql.jdbc.Driver")
                                .build()));
        //5.execute
        env.execute();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Student {
        private Integer id;
        private String name;
        private Integer age;
    }
}
```

#### Kafka

##### pom依赖

Flink 里已经提供了一些绑定的 Connector，例如 kafka source 和 sink，Es sink 等。读写 kafka、es、rabbitMQ 时可以直接使用相应 connector 的 api 即可，虽然该部分是 Flink 项目源代码里的一部分，但是真正意义上不算作 Flink 引擎相关逻辑，并且该部分没有打包在二进制的发布包里面。所以在提交 Job 时候需要注意， job 代码 jar 包中一定要将相应的 connetor 相关类打包进去，否则在提交作业时就会失败，提示找不到相应的类，或初始化某些类异常。

[https://ci.apache.org/projects/flink/flink-docs-stable/dev/connectors/kafka.html](https://ci.apache.org/projects/flink/flink-docs-stable/dev/connectors/kafka.html)

![image.png](https://image.hyly.net/i/2025/09/28/9fc7b2935aab84dd275cf8230261a2e6-0.webp)

##### 参数设置

![image.png](https://image.hyly.net/i/2025/09/28/711aee2739a691a8a91ff5429ccb04aa-0.webp)

以下参数都必须/建议设置上

1.订阅的主题

2.反序列化规则

3.消费者属性-集群地址

4.消费者属性-消费者组id(如果不设置,会有默认的,但是默认的不方便管理)

5.消费者属性-offset重置规则,如earliest/latest...

6.动态分区检测(当kafka的分区数变化/增加时,Flink能够检测到!)

7.如果没有设置Checkpoint,那么可以设置自动提交offset,后续学习了Checkpoint会把offset随着做Checkpoint的时候提交到Checkpoint和默认主题中

##### 参数说明

![image.png](https://image.hyly.net/i/2025/09/28/8578c5408e44f04a7fbcf8e27d20d2af-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/b49bb550340340d78b11eb06c534b01a-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/8b5a6f6c0ff5f5455b37bd24b4afffbd-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/9ff4a25ed1a530339ad338499ce8cb87-0.webp)

实际的生产环境中可能有这样一些需求，比如：

1. 场景一：有一个 Flink 作业需要将五份数据聚合到一起，五份数据对应五个 kafka topic，随着业务增长，新增一类数据，同时新增了一个 kafka topic，如何在不重启作业的情况下作业自动感知新的 topic。
2. 场景二：作业从一个固定的 kafka topic 读数据，开始该 topic 有 10 个 partition，但随着业务的增长数据量变大，需要对 kafka partition 个数进行扩容，由 10 个扩容到 20。该情况下如何在不重启作业情况下动态感知新扩容的 partition？

针对上面的两种场景，首先需要在构建 FlinkKafkaConsumer 时的 properties 中设置 flink.partition-discovery.interval-millis 参数为非负值，表示开启动态发现的开关，以及设置的时间间隔。此时 FlinkKafkaConsumer 内部会启动一个单独的线程定期去 kafka 获取最新的 meta 信息。

1. 针对场景一，还需在构建 FlinkKafkaConsumer 时，topic 的描述可以传一个正则表达式描述的 pattern。每次获取最新 kafka meta 时获取正则匹配的最新 topic 列表。
2. 针对场景二，设置前面的动态发现参数，在定期获取 kafka 最新 meta 信息时会匹配新的 partition。为了保证数据的正确性，新发现的 partition 从最早的位置开始读取。

![image.png](https://image.hyly.net/i/2025/09/28/7a985ccf1a848d19d22ee4ec0d46d42c-0.webp)

注意:

开启 checkpoint 时 offset 是 Flink 通过状态 state 管理和恢复的，并不是从 kafka 的 offset 位置恢复。在 checkpoint 机制下，作业从最近一次checkpoint 恢复，本身是会回放部分历史数据，导致部分数据重复消费，Flink 引擎仅保证计算状态的精准一次，要想做到端到端精准一次需要依赖一些幂等的存储系统或者事务操作。

##### Kafka命令

查看当前服务器中的所有topic

```
/export/server/kafka/bin/kafka-topics.sh --list --zookeeper  node1:2181
```

创建topic

```
/export/server/kafka/bin/kafka-topics.sh --create --zookeeper node1:2181 --replication-factor 2 --partitions 3 --topic flink_kafka
```

查看某个Topic的详情

```
/export/server/kafka/bin/kafka-topics.sh --topic flink_kafka --describe --zookeeper node1:2181
```

删除topic

```
/export/server/kafka/bin/kafka-topics.sh --delete --zookeeper node1:2181 --topic flink_kafka
```

通过shell命令发送消息

```
/export/server/kafka/bin/kafka-console-producer.sh --broker-list node1:9092 --topic flink_kafka
```

通过shell消费消息

```
/export/server/kafka/bin/kafka-console-consumer.sh --bootstrap-server node1:9092 --topic flink_kafka --from-beginning
```

修改分区

```
/export/server/kafka/bin/kafka-topics.sh --alter --partitions 4 --topic flink_kafka --zookeeper node1:2181
```

##### 代码实现-Kafka Consumer

```java
package cn.itcast.connectors;

import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import org.apache.flink.util.Collector;

import java.util.Properties;

/**
 * Author itcast
 * Desc
 * 需求:使用flink-connector-kafka_2.12中的FlinkKafkaConsumer消费Kafka中的数据做WordCount
 * 需要设置如下参数:
 * 1.订阅的主题
 * 2.反序列化规则
 * 3.消费者属性-集群地址
 * 4.消费者属性-消费者组id(如果不设置,会有默认的,但是默认的不方便管理)
 * 5.消费者属性-offset重置规则,如earliest/latest...
 * 6.动态分区检测(当kafka的分区数变化/增加时,Flink能够检测到!)
 * 7.如果没有设置Checkpoint,那么可以设置自动提交offset,后续学习了Checkpoint会把offset随着做Checkpoint的时候提交到Checkpoint和默认主题中
 */
public class ConnectorsDemo_KafkaConsumer {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        Properties props  = new Properties();
        props.setProperty("bootstrap.servers", "node1:9092");
        props.setProperty("group.id", "flink");
        props.setProperty("auto.offset.reset","latest");
        props.setProperty("flink.partition-discovery.interval-millis","5000");//会开启一个后台线程每隔5s检测一下Kafka的分区情况
        props.setProperty("enable.auto.commit", "true");
        props.setProperty("auto.commit.interval.ms", "2000");
        //kafkaSource就是KafkaConsumer
        FlinkKafkaConsumer<String> kafkaSource = new FlinkKafkaConsumer<>("flink_kafka", new SimpleStringSchema(), props);
        kafkaSource.setStartFromGroupOffsets();//设置从记录的offset开始消费,如果没有记录从auto.offset.reset配置开始消费
        //kafkaSource.setStartFromEarliest();//设置直接从Earliest消费,和auto.offset.reset配置无关
        DataStreamSource<String> kafkaDS = env.addSource(kafkaSource);

        //3.Transformation
        //3.1切割并记为1
        SingleOutputStreamOperator<Tuple2<String, Integer>> wordAndOneDS = kafkaDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });
        //3.2分组
        KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOneDS.keyBy(0);
        //3.3聚合
        SingleOutputStreamOperator<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.Sink
        result.print();

        //5.execute
        env.execute();
    }
}
```

##### 代码实现-Kafka Producer

**需求:**

将Flink集合中的数据通过自定义Sink保存到Kafka

**代码实现**

```java
package cn.itcast.connectors;

import com.alibaba.fastjson.JSON;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer;

import java.util.Properties;

/**
 * Author itcast
 * Desc
 * 使用自定义sink-官方提供的flink-connector-kafka_2.12-将数据保存到Kafka
 */
public class ConnectorsDemo_KafkaProducer {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStreamSource<Student> studentDS = env.fromElements(new Student(1, "tonyma", 18));
        //3.Transformation
        //注意:目前来说我们使用Kafka使用的序列化和反序列化都是直接使用最简单的字符串,所以先将Student转为字符串
        //可以直接调用Student的toString,也可以转为JSON
        SingleOutputStreamOperator<String> jsonDS = studentDS.map(new MapFunction<Student, String>() {
            @Override
            public String map(Student value) throws Exception {
                //String str = value.toString();
                String jsonStr = JSON.toJSONString(value);
                return jsonStr;
            }
        });

        //4.Sink
        jsonDS.print();
        //根据参数创建KafkaProducer/KafkaSink
        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "node1:9092");
        FlinkKafkaProducer<String> kafkaSink = new FlinkKafkaProducer<>("flink_kafka",  new SimpleStringSchema(),  props);
        jsonDS.addSink(kafkaSink);

        //5.execute
        env.execute();

        // /export/server/kafka/bin/kafka-console-consumer.sh --bootstrap-server node1:9092 --topic flink_kafka
    }
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Student {
        private Integer id;
        private String name;
        private Integer age;
    }
}
```

#### Redis

**API**

通过flink 操作redis 其实我们可以通过传统的redis 连接池Jpoools 进行redis 的相关操作，但是flink 提供了专门操作redis 的RedisSink，使用起来更方便，而且不用我们考虑性能的问题，接下来将主要介绍RedisSink 如何使用。

[https://bahir.apache.org/docs/flink/current/flink-streaming-redis/](https://bahir.apache.org/docs/flink/current/flink-streaming-redis/)

RedisSink 核心类是RedisMapper 是一个接口，使用时我们要编写自己的redis 操作类实现这个接口中的三个方法，如下所示

1. getCommandDescription() ：设置使用的redis 数据结构类型，和key 的名称，通过RedisCommand 设置数据结构类型
2. String getKeyFromData(T data)：设置value 中的键值对key的值
3. String getValueFromData(T data); 设置value 中的键值对value的值

使用RedisCommand设置数据结构类型时和redis结构对应关系

<figure class='table-figure'><table>
<thead>
<tr><th><strong>Data</strong> <strong>Type</strong></th><th><strong>Redis</strong> <strong>Command</strong> <strong>[Sink]</strong></th></tr></thead>
<tbody><tr><td>HASH</td><td>HSET</td></tr><tr><td>LIST</td><td>RPUSH, LPUSH</td></tr><tr><td>SET</td><td>SADD</td></tr><tr><td>PUBSUB</td><td>PUBLISH</td></tr><tr><td>STRING</td><td>SET</td></tr><tr><td>HYPER_LOG_LOG</td><td>PFADD</td></tr><tr><td>SORTED_SET</td><td>ZADD</td></tr><tr><td>SORTED_SET</td><td>ZREM</td></tr></tbody>
</table></figure>

**需求**

将Flink集合中的数据通过自定义Sink保存到Redis

**代码实现**

```java
package cn.itcast.connectors;

import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.redis.RedisSink;
import org.apache.flink.streaming.connectors.redis.common.config.FlinkJedisPoolConfig;
import org.apache.flink.streaming.connectors.redis.common.mapper.RedisCommand;
import org.apache.flink.streaming.connectors.redis.common.mapper.RedisCommandDescription;
import org.apache.flink.streaming.connectors.redis.common.mapper.RedisMapper;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 * 需求:
 * 接收消息并做WordCount,
 * 最后将结果保存到Redis
 * 注意:存储到Redis的数据结构:使用hash也就是map
 * key            value
 * WordCount    (单词,数量)
 */
public class ConnectorsDemo_Redis {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //3.1切割并记为1
        SingleOutputStreamOperator<Tuple2<String, Integer>> wordAndOneDS = linesDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });
        //3.2分组
        KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOneDS.keyBy(0);
        //3.3聚合
        SingleOutputStreamOperator<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.Sink
        result.print();
        // * 最后将结果保存到Redis
        // * 注意:存储到Redis的数据结构:使用hash也就是map
        // * key            value
        // * WordCount      (单词,数量)

        //-1.创建RedisSink之前需要创建RedisConfig
        //连接单机版Redis
        FlinkJedisPoolConfig conf = new FlinkJedisPoolConfig.Builder().setHost("127.0.0.1").build();
        //连接集群版Redis
        //HashSet<InetSocketAddress> nodes = new HashSet<>(Arrays.asList(new InetSocketAddress(InetAddress.getByName("node1"), 6379),new InetSocketAddress(InetAddress.getByName("node2"), 6379),new InetSocketAddress(InetAddress.getByName("node3"), 6379)));
        //FlinkJedisClusterConfig conf2 = new FlinkJedisClusterConfig.Builder().setNodes(nodes).build();
        //连接哨兵版Redis
        //Set<String> sentinels = new HashSet<>(Arrays.asList("node1:26379", "node2:26379", "node3:26379"));
        //FlinkJedisSentinelConfig conf3 = new FlinkJedisSentinelConfig.Builder().setMasterName("mymaster").setSentinels(sentinels).build();

        //-3.创建并使用RedisSink
        result.addSink(new RedisSink<Tuple2<String, Integer>>(conf, new RedisWordCountMapper()));

        //5.execute
        env.execute();
    }

    /**
     * -2.定义一个Mapper用来指定存储到Redis中的数据结构
     */
    public static class RedisWordCountMapper implements RedisMapper<Tuple2<String, Integer>> {
        @Override
        public RedisCommandDescription getCommandDescription() {
            return new RedisCommandDescription(RedisCommand.HSET, "WordCount");
        }
        @Override
        public String getKeyFromData(Tuple2<String, Integer> data) {
            return data.f0;
        }
        @Override
        public String getValueFromData(Tuple2<String, Integer> data) {
            return data.f1.toString();
        }
    }
}
```

### 扩展阅读：其他批处理API

#### 累加器

**API**

Flink累加器：

Flink中的累加器，与Mapreduce counter的应用场景类似，可以很好地观察task在运行期间的数据变化，如在Flink job任务中的算子函数中操作累加器，在任务执行结束之后才能获得累加器的最终结果。

Flink有以下内置累加器，每个累加器都实现了Accumulator接口。

1. IntCounter
2. LongCounter
3. DoubleCounter

**编码步骤:**

1. 创建累加器

```
private IntCounter numLines = new IntCounter();
```

2. 注册累加器

```
getRuntimeContext().addAccumulator("num-lines", this.numLines);
```

3. 使用累加器

```
this.numLines.add(1);
```

4. 获取累加器的结果

```
myJobExecutionResult.getAccumulatorResult("num-lines")
```

**代码实现:**

```java
package cn.itcast.batch;

import org.apache.flink.api.common.JobExecutionResult;
import org.apache.flink.api.common.accumulators.IntCounter;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.api.java.operators.DataSource;
import org.apache.flink.api.java.operators.MapOperator;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.core.fs.FileSystem;

/**
 * Author itcast
 * Desc 演示Flink累加器,统计处理的数据条数
 */
public class OtherAPI_Accumulator {
    public static void main(String[] args) throws Exception {
        //1.env
        ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

        //2.Source
        DataSource<String> dataDS = env.fromElements("aaa", "bbb", "ccc", "ddd");

        //3.Transformation
        MapOperator<String, String> result = dataDS.map(new RichMapFunction<String, String>() {
            //-1.创建累加器
            private IntCounter elementCounter = new IntCounter();
            Integer count = 0;

            @Override
            public void open(Configuration parameters) throws Exception {
                super.open(parameters);
                //-2注册累加器
                getRuntimeContext().addAccumulator("elementCounter", elementCounter);
            }

            @Override
            public String map(String value) throws Exception {
                //-3.使用累加器
                this.elementCounter.add(1);
                count+=1;
                System.out.println("不使用累加器统计的结果:"+count);
                return value;
            }
        }).setParallelism(2);

        //4.Sink
        result.writeAsText("data/output/test", FileSystem.WriteMode.OVERWRITE);

        //5.execute
        //-4.获取加强结果
        JobExecutionResult jobResult = env.execute();
        int nums = jobResult.getAccumulatorResult("elementCounter");
        System.out.println("使用累加器统计的结果:"+nums);
    }
}
```

#### 广播变量

**API**

Flink支持广播。可以将数据广播到TaskManager上就可以供TaskManager中的SubTask/task去使用，数据存储到内存中。这样可以减少大量的shuffle操作，而不需要多次传递给集群节点；

比如在数据join阶段，不可避免的就是大量的shuffle操作，我们可以把其中一个dataSet广播出去，一直加载到taskManager的内存中，可以直接在内存中拿数据，避免了大量的shuffle，导致集群性能下降；

**图解：**

1. 可以理解广播就是一个公共的共享变量
2. 将一个数据集广播后，不同的Task都可以在节点上获取到
3. 每个节点只存一份
4. 如果不使用广播，每一个Task都会拷贝一份数据集，造成内存资源浪费

![image.png](https://image.hyly.net/i/2025/09/28/682a0126ce42dc75c789e7ed9548699c-0.webp)

**注意：**

广播变量是要把dataset广播到内存中，所以广播的数据量不能太大，否则会出现OOM

广播变量的值不可修改，这样才能确保每个节点获取到的值都是一致的

**编码步骤:**

1. 广播数据    .withBroadcastSet(DataSet, "name");
2. 获取广播的数据

```
Collection<> broadcastSet = 	getRuntimeContext().getBroadcastVariable("name");
```

3. 使用广播数据

**需求:**

将studentDS(学号,姓名)集合广播出去(广播到各个TaskManager内存中)

然后使用scoreDS(学号,学科,成绩)和广播数据(学号,姓名)进行关联,得到这样格式的数据:(姓名,学科,成绩)

**代码实现:**

```java
package cn.itcast.batch;

import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.api.java.operators.DataSource;
import org.apache.flink.api.java.operators.MapOperator;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.tuple.Tuple3;
import org.apache.flink.configuration.Configuration;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Author itcast
 * Desc 演示Flink广播变量
 * 编程步骤：
 * 1：广播数据
 * .withBroadcastSet(DataSet, "name");
 * 2：获取广播的数据
 * Collection<> broadcastSet =     getRuntimeContext().getBroadcastVariable("name");
 * 3:使用广播数据
 * <p>
 * 需求:
 * 将studentDS(学号,姓名)集合广播出去(广播到各个TaskManager内存中)
 * 然后使用scoreDS(学号,学科,成绩)和广播数据(学号,姓名)进行关联,得到这样格式的数据:(姓名,学科,成绩)
 */
public class OtherAPI_Broadcast {
    public static void main(String[] args) throws Exception {
        //1.env
        ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

        //2.Source
        //学生数据集(学号,姓名)
        DataSource<Tuple2<Integer, String>> studentDS = env.fromCollection(
                Arrays.asList(Tuple2.of(1, "张三"), Tuple2.of(2, "李四"), Tuple2.of(3, "王五"))
        );

        //成绩数据集(学号,学科,成绩)
        DataSource<Tuple3<Integer, String, Integer>> scoreDS = env.fromCollection(
                Arrays.asList(Tuple3.of(1, "语文", 50), Tuple3.of(2, "数学", 70), Tuple3.of(3, "英文", 86))
        );

        //3.Transformation
        //将studentDS(学号,姓名)集合广播出去(广播到各个TaskManager内存中)
        //然后使用scoreDS(学号,学科,成绩)和广播数据(学号,姓名)进行关联,得到这样格式的数据:(姓名,学科,成绩)
        MapOperator<Tuple3<Integer, String, Integer>, Tuple3<String, String, Integer>> result = scoreDS.map(
                new RichMapFunction<Tuple3<Integer, String, Integer>, Tuple3<String, String, Integer>>() {
                    //定义一集合用来存储(学号,姓名)
                    Map<Integer, String> studentMap = new HashMap<>();

                    //open方法一般用来初始化资源，每个subtask任务只被调用一次
                    @Override
                    public void open(Configuration parameters) throws Exception {
                        //-2.获取广播数据
                        List<Tuple2<Integer, String>> studentList = getRuntimeContext().getBroadcastVariable("studentInfo");
                        for (Tuple2<Integer, String> tuple : studentList) {
                            studentMap.put(tuple.f0, tuple.f1);
                        }
                        //studentMap = studentList.stream().collect(Collectors.toMap(t -> t.f0, t -> t.f1));
                    }

                    @Override
                    public Tuple3<String, String, Integer> map(Tuple3<Integer, String, Integer> value) throws Exception {
                        //-3.使用广播数据
                        Integer stuID = value.f0;
                        String stuName = studentMap.getOrDefault(stuID, "");
                        //返回(姓名,学科,成绩)
                        return Tuple3.of(stuName, value.f1, value.f2);
                    }
                    //-1.广播数据到各个TaskManager
                }).withBroadcastSet(studentDS, "studentInfo");

        //4.Sink
        result.print();
    }
}
```

#### 分布式缓存

**API解释**

Flink提供了一个类似于Hadoop的分布式缓存，让并行运行实例的函数可以在本地访问。

这个功能可以被使用来分享外部静态的数据，例如：机器学习的逻辑回归模型等

**注意**

广播变量是将变量分发到各个TaskManager节点的内存上，分布式缓存是将文件缓存到各个TaskManager节点上；

**编码步骤:**

1. 注册一个分布式缓存文件

```
 env.registerCachedFile("hdfs:///path/file", "cachefilename")  
```

2. 访问分布式缓存文件中的数据

```
File myFile = getRuntimeContext().getDistributedCache().getFile("cachefilename"); 
```

3. 使用

**需求**

将scoreDS(学号, 学科, 成绩)中的数据和分布式缓存中的数据(学号,姓名)关联,得到这样格式的数据: (学生姓名,学科,成绩)

**代码实现:**

```java
package cn.itcast.batch;

import org.apache.commons.io.FileUtils;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.api.java.operators.DataSource;
import org.apache.flink.api.java.operators.MapOperator;
import org.apache.flink.api.java.tuple.Tuple3;
import org.apache.flink.configuration.Configuration;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Author itcast
 * Desc 演示Flink分布式缓存
 * 编码步骤:
 * 1：注册一个分布式缓存文件
 *  env.registerCachedFile("hdfs:///path/file", "cachefilename")
 * 2：访问分布式缓存文件中的数据
 *  File myFile = getRuntimeContext().getDistributedCache().getFile("cachefilename");
 * 3：使用
 *
 * 需求:
 * 将scoreDS(学号, 学科, 成绩)中的数据和分布式缓存中的数据(学号,姓名)关联,得到这样格式的数据: (学生姓名,学科,成绩)
 */
public class OtherAPI_DistributedCache {
    public static void main(String[] args) throws Exception {
        //1.env
        ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

        //2.Source
        //注意:先将本地资料中的distribute_cache_student文件上传到HDFS
        //-1.注册分布式缓存文件
        //env.registerCachedFile("hdfs://node01:8020/distribute_cache_student", "studentFile");
        env.registerCachedFile("data/input/distribute_cache_student", "studentFile");

        //成绩数据集(学号,学科,成绩)
        DataSource<Tuple3<Integer, String, Integer>> scoreDS = env.fromCollection(
                Arrays.asList(Tuple3.of(1, "语文", 50), Tuple3.of(2, "数学", 70), Tuple3.of(3, "英文", 86))
        );

        //3.Transformation
        //将scoreDS(学号, 学科, 成绩)中的数据和分布式缓存中的数据(学号,姓名)关联,得到这样格式的数据: (学生姓名,学科,成绩)
        MapOperator<Tuple3<Integer, String, Integer>, Tuple3<String, String, Integer>> result = scoreDS.map(
                new RichMapFunction<Tuple3<Integer, String, Integer>, Tuple3<String, String, Integer>>() {
                    //定义一集合用来存储(学号,姓名)
                    Map<Integer, String> studentMap = new HashMap<>();

                    @Override
                    public void open(Configuration parameters) throws Exception {
                        //-2.加载分布式缓存文件
                        File file = getRuntimeContext().getDistributedCache().getFile("studentFile");
                        List<String> studentList = FileUtils.readLines(file);
                        for (String str : studentList) {
                            String[] arr = str.split(",");
                            studentMap.put(Integer.parseInt(arr[0]), arr[1]);
                        }
                    }

                    @Override
                    public Tuple3<String, String, Integer> map(Tuple3<Integer, String, Integer> value) throws Exception {
                        //-3.使用分布式缓存文件中的数据
                        Integer stuID = value.f0;
                        String stuName = studentMap.getOrDefault(stuID, "");
                        //返回(姓名,学科,成绩)
                        return Tuple3.of(stuName, value.f1, value.f2);
                    }
                });

        //4.Sink
        result.print();
    }
}
```

## Flink-高级API

### Flink四大基石

Flink之所以能这么流行，离不开它最重要的四个基石：Checkpoint、State、Time、Window。

![image.png](https://image.hyly.net/i/2025/09/28/37d8edd8118741a274c02d40c65da20a-0.webp)

1. Checkpoint

这是Flink最重要的一个特性。

Flink基于Chandy-Lamport算法实现了一个分布式的一致性的快照，从而提供了一致性的语义。

Chandy-Lamport算法实际上在1985年的时候已经被提出来，但并没有被很广泛的应用，而Flink则把这个算法发扬光大了。

Spark最近在实现Continue streaming，Continue streaming的目的是为了降低处理的延时，其也需要提供这种一致性的语义，最终也采用了Chandy-Lamport这个算法，说明Chandy-Lamport算法在业界得到了一定的肯定。

[https://zhuanlan.zhihu.com/p/53482103](https://zhuanlan.zhihu.com/p/53482103)

2. State

提供了一致性的语义之后，Flink为了让用户在编程时能够更轻松、更容易地去管理状态，还提供了一套非常简单明了的State API，包括ValueState、ListState、MapState，BroadcastState。

3. Time

除此之外，Flink还实现了Watermark的机制，能够支持基于事件的时间的处理，能够容忍迟到/乱序的数据。

4. Window

另外流计算中一般在对流数据进行操作之前都会先进行开窗，即基于一个什么样的窗口上做这个计算。Flink提供了开箱即用的各种窗口，比如滑动窗口、滚动窗口、会话窗口以及非常灵活的自定义的窗口。

### Flink-Window操作

#### 为什么需要Window

在流处理应用中，数据是连续不断的，有时我们需要做一些聚合类的处理，例如：在过去的1分钟内有多少用户点击了我们的网页。

在这种情况下，我们必须定义一个窗口(window)，用来收集最近1分钟内的数据，并对这个窗口内的数据进行计算。

#### Window的分类

##### 按照time和count分类

time-window:时间窗口:根据时间划分窗口,如:每xx分钟统计最近xx分钟的数据

count-window:数量窗口:根据数量划分窗口,如:每xx个数据统计最近xx个数据

![image.png](https://image.hyly.net/i/2025/09/28/17087abc3dff24062bf3ebc6b22bf133-0.webp)

##### 按照slide和size分类

窗口有两个重要的属性: 窗口大小size和滑动间隔slide,根据它们的大小关系可分为:

tumbling-window:滚动窗口:size=slide,如:每隔10s统计最近10s的数据

![image.png](https://image.hyly.net/i/2025/09/28/0e9f5fb397453f453f3b31c40c8850b1-0.webp)

sliding-window:滑动窗口:size>slide,如:每隔5s统计最近10s的数据

![image.png](https://image.hyly.net/i/2025/09/28/ae289b9f35d24d51d5f551a4665aad9b-0.webp)

注意:当size&#x3c;slide的时候,如每隔15s统计最近10s的数据,那么中间5s的数据会丢失,所有开发中不用

##### 总结

按照上面窗口的分类方式进行组合,可以得出如下的窗口:

1. 基于时间的滚动窗口tumbling-time-window--用的较多
2. 基于时间的滑动窗口sliding-time-window--用的较多
3. 基于数量的滚动窗口tumbling-count-window--用的较少
4. 基于数量的滑动窗口sliding-count-window--用的较少

注意:Flink还支持一个特殊的窗口:Session会话窗口,需要设置一个会话超时时间,如30s,则表示30s内没有数据到来,则触发上个窗口的计算

#### Window的API

##### window和windowAll

![image.png](https://image.hyly.net/i/2025/09/28/4530141542c5806cec51d02f55a661a1-0.webp)

使用keyby的流,应该使用window方法

未使用keyby的流,应该调用windowAll方法

##### WindowAssigner

window/windowAll 方法接收的输入是一个 WindowAssigner， WindowAssigner 负责将每条输入的数据分发到正确的 window 中，

Flink提供了很多各种场景用的WindowAssigner：

![image.png](https://image.hyly.net/i/2025/09/28/7efdcce99dd767ed04bdc5f5baa87a97-0.webp)

如果需要自己定制数据分发策略，则可以实现一个 class，继承自 WindowAssigner。

##### evictor--了解

evictor 主要用于做一些数据的自定义操作，可以在执行用户代码之前，也可以在执行
用户代码之后，更详细的描述可以参考org.apache.flink.streaming.api.windowing.evictors.Evictor 的 evicBefore 和 evicAfter两个方法。
Flink 提供了如下三种通用的 evictor：

1. CountEvictor 保留指定数量的元素
2. TimeEvictor 设定一个阈值 interval，删除所有不再 max_ts - interval 范围内的元
   素，其中 max_ts 是窗口内时间戳的最大值。
3. DeltaEvictor 通过执行用户给定的 DeltaFunction 以及预设的 theshold，判断是否删
   除一个元素。

##### trigger--了解

trigger 用来判断一个窗口是否需要被触发，每个 WindowAssigner 都自带一个默认的trigger，

如果默认的 trigger 不能满足你的需求，则可以自定义一个类，继承自Trigger 即可，我们详细描述下 Trigger 的接口以及含义：

1. onElement() 每次往 window 增加一个元素的时候都会触发
2. onEventTime() 当 event-time timer 被触发的时候会调用
3. onProcessingTime() 当 processing-time timer 被触发的时候会调用
4. onMerge() 对两个 `rigger 的 state 进行 merge 操作
5. clear() window 销毁的时候被调用

上面的接口中前三个会返回一个 TriggerResult， TriggerResult 有如下几种可能的选择：

1. CONTINUE 不做任何事情
2. FIRE 触发 window
3. PURGE 清空整个 window 的元素并销毁窗口
4. FIRE_AND_PURGE 触发窗口，然后销毁窗口

##### API调用示例

![image.png](https://image.hyly.net/i/2025/09/28/c030a04a13188f597538477e27fa298c-0.webp)

source.keyBy(0).window(TumblingProcessingTimeWindows.of(Time.seconds(5)));

或

source.keyBy(0)..timeWindow(Time.seconds(5))

#### 案例演示-基于时间的滚动和滑动窗口

##### 需求

nc -lk 9999
有如下数据表示:
信号灯编号和通过该信号灯的车的数量
9,3
9,2
9,7
4,9
2,6
1,5
2,3
5,7
5,4
需求1:每5秒钟统计一次，最近5秒钟内，各个路口通过红绿灯汽车的数量--基于时间的滚动窗口
需求2:每5秒钟统计一次，最近10秒钟内，各个路口通过红绿灯汽车的数量--基于时间的滑动窗口

##### 代码实现

```java
package cn.itcast.window;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.SlidingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;

/**
 * Author itcast
 * Desc
 * nc -lk 9999
 * 有如下数据表示:
 * 信号灯编号和通过该信号灯的车的数量
9,3
9,2
9,7
4,9
2,6
1,5
2,3
5,7
5,4
 * 需求1:每5秒钟统计一次，最近5秒钟内，各个路口通过红绿灯汽车的数量--基于时间的滚动窗口
 * 需求2:每5秒钟统计一次，最近10秒钟内，各个路口通过红绿灯汽车的数量--基于时间的滑动窗口
 */
public class WindowDemo01_TimeWindow {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStreamSource<String> socketDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //将9,3转为CartInfo(9,3)
        SingleOutputStreamOperator<CartInfo> cartInfoDS = socketDS.map(new MapFunction<String, CartInfo>() {
            @Override
            public CartInfo map(String value) throws Exception {
                String[] arr = value.split(",");
                return new CartInfo(arr[0], Integer.parseInt(arr[1]));
            }
        });

        //分组
        //KeyedStream<CartInfo, Tuple> keyedDS = cartInfoDS.keyBy("sensorId");

        // * 需求1:每5秒钟统计一次，最近5秒钟内，各个路口/信号灯通过红绿灯汽车的数量--基于时间的滚动窗口
        //timeWindow(Time size窗口大小, Time slide滑动间隔)
        SingleOutputStreamOperator<CartInfo> result1 = cartInfoDS
                .keyBy(CartInfo::getSensorId)
                //.timeWindow(Time.seconds(5))//当size==slide,可以只写一个
                //.timeWindow(Time.seconds(5), Time.seconds(5))
                .window(TumblingProcessingTimeWindows.of(Time.seconds(5)))
                .sum("count");

        // * 需求2:每5秒钟统计一次，最近10秒钟内，各个路口/信号灯通过红绿灯汽车的数量--基于时间的滑动窗口
        SingleOutputStreamOperator<CartInfo> result2 = cartInfoDS
                .keyBy(CartInfo::getSensorId)
                //.timeWindow(Time.seconds(10), Time.seconds(5))
                .window(SlidingProcessingTimeWindows.of(Time.seconds(10), Time.seconds(5)))
                .sum("count");

        //4.Sink
/*
1,5
2,5
3,5
4,5
*/
        //result1.print();
        result2.print();

        //5.execute
        env.execute();
    }
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class CartInfo {
        private String sensorId;//信号灯id
        private Integer count;//通过该信号灯的车的数量
    }
}
```

#### 案例演示-基于数量的滚动和滑动窗口

##### 需求

需求1:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现5次进行统计--基于数量的滚动窗口
需求2:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现3次进行统计--基于数量的滑动窗口

##### 代码实现

```
package cn.itcast.window;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 * nc -lk 9999
 * 有如下数据表示:
 * 信号灯编号和通过该信号灯的车的数量
9,3
9,2
9,7
4,9
2,6
1,5
2,3
5,7
5,4
 * 需求1:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现5次进行统计--基于数量的滚动窗口
 * 需求2:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现3次进行统计--基于数量的滑动窗口
 */
public class WindowDemo02_CountWindow {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStreamSource<String> socketDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //将9,3转为CartInfo(9,3)
        SingleOutputStreamOperator<CartInfo> cartInfoDS = socketDS.map(new MapFunction<String, CartInfo>() {
            @Override
            public CartInfo map(String value) throws Exception {
                String[] arr = value.split(",");
                return new CartInfo(arr[0], Integer.parseInt(arr[1]));
            }
        });

        //分组
        //KeyedStream<CartInfo, Tuple> keyedDS = cartInfoDS.keyBy("sensorId");

        // * 需求1:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现5次进行统计--基于数量的滚动窗口
        //countWindow(long size, long slide)
        SingleOutputStreamOperator<CartInfo> result1 = cartInfoDS
                .keyBy(CartInfo::getSensorId)
                //.countWindow(5L, 5L)
                .countWindow( 5L)
                .sum("count");

        // * 需求2:统计在最近5条消息中,各自路口通过的汽车数量,相同的key每出现3次进行统计--基于数量的滑动窗口
        //countWindow(long size, long slide)
        SingleOutputStreamOperator<CartInfo> result2 = cartInfoDS
                .keyBy(CartInfo::getSensorId)
                .countWindow(5L, 3L)
                .sum("count");


        //4.Sink
        //result1.print();
        /*
1,1
1,1
1,1
1,1
2,1
1,1
         */
        result2.print();
        /*
1,1
1,1
2,1
1,1
2,1
3,1
4,1
         */

        //5.execute
        env.execute();
    }
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class CartInfo {
        private String sensorId;//信号灯id
        private Integer count;//通过该信号灯的车的数量
    }
}
```

#### 案例演示-会话窗口

##### 需求

设置会话超时时间为10s,10s内没有数据到来,则触发上个窗口的计算

##### 代码实现

```
package cn.itcast.window;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.ProcessingTimeSessionWindows;
import org.apache.flink.streaming.api.windowing.time.Time;

/**
 * Author itcast
 * Desc
 * nc -lk 9999
 * 有如下数据表示:
 * 信号灯编号和通过该信号灯的车的数量
9,3
9,2
9,7
4,9
2,6
1,5
2,3
5,7
5,4
 * 需求:设置会话超时时间为10s,10s内没有数据到来,则触发上个窗口的计算(前提是上一个窗口得有数据!)
 */
public class WindowDemo03_SessionWindow {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        DataStreamSource<String> socketDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //将9,3转为CartInfo(9,3)
        SingleOutputStreamOperator<CartInfo> cartInfoDS = socketDS.map(new MapFunction<String, CartInfo>() {
            @Override
            public CartInfo map(String value) throws Exception {
                String[] arr = value.split(",");
                return new CartInfo(arr[0], Integer.parseInt(arr[1]));
            }
        });

        //需求:设置会话超时时间为10s,10s内没有数据到来,则触发上个窗口的计算(前提是上一个窗口得有数据!)
        SingleOutputStreamOperator<CartInfo> result = cartInfoDS.keyBy(CartInfo::getSensorId)
                .window(ProcessingTimeSessionWindows.withGap(Time.seconds(10)))
                .sum("count");

        //4.Sink
        result.print();

        //5.execute
        env.execute();
    }
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class CartInfo {
        private String sensorId;//信号灯id
        private Integer count;//通过该信号灯的车的数量
    }
}
```

### Flink-Time与Watermaker

#### Time分类

在Flink的流式处理中，会涉及到时间的不同概念，如下图所示：

![image.png](https://image.hyly.net/i/2025/09/28/76f7f92257d4b63e428af059939f92ae-0.webp)

事件时间EventTime:	事件真真正正发生产生的时间
摄入时间IngestionTime:	事件到达Flink的时间
处理时间ProcessingTime:	事件真正被处理/计算的时间

问题: 上面的三个时间,我们更关注哪一个?
答案: 更关注事件时间 !
因为: 事件时间更能反映事件的本质! 只要事件时间一产生就不会变化

#### EventTime的重要性

##### 示例1

假设，你正在去往地下停车场的路上，并且打算用手机点一份外卖。选好了外卖后，你就用在线支付功能付款了，这个时候是11点59分。恰好这时，你走进了地下停车库，而这里并没有手机信号。因此外卖的在线支付并没有立刻成功，而支付系统一直在Retry重试“支付”这个操作。
当你找到自己的车并且开出地下停车场的时候，已经是12点01分了。这个时候手机重新有了信号，手机上的支付数据成功发到了外卖在线支付系统，支付完成。

在上面这个场景中你可以看到，
支付数据的事件时间是11点59分，而支付数据的处理时间是12点01分

问题:
如果要统计12之前的订单金额,那么这笔交易是否应被统计?
答案:
应该被统计,因为该数据的真真正正的产生时间为11点59分,即该数据的事件时间为11点59分,
事件时间能够真正反映/代表事件的本质! 所以一般在实际开发中会以事件时间作为计算标准

##### 示例2

一条错误日志的内容为：
2020-11:11 22:59:00 error NullPointExcep --事件时间
进入Flink的时间为2020-11:11 23:00:00    --摄入时间
到达Window的时间为2020-11:11 23:00:10 --处理时间
问题:
对于业务来说，要统计1h内的故障日志个数，哪个时间是最有意义的？
答案:
EventTime事件时间，因为bug真真正正产生的时间就是事件时间,只有事件时间才能真正反映/代表事件的本质!

##### 示例3

某 App 会记录用户的所有点击行为，并回传日志（在网络不好的情况下，先保存在本地，延后回传）。
A用户在 11:01:00 对 App 进行操作，B用户在 11:02:00 操作了 App，
但是A用户的网络不太稳定，回传日志延迟了，导致我们在服务端先接受到B用户的消息，然后再接受到A用户的消息，消息乱序了。
问题:
如果这个是一个根据用户操作先后顺序,进行抢购的业务,那么是A用户成功还是B用户成功?
答案:
应该算A成功,因为A确实比B操作的早,但是实际中考虑到实现难度,可能直接按B成功算
也就是说，实际开发中希望基于事件时间来处理数据，但因为数据可能因为网络延迟等原因，出现了乱序，按照事件时间处理起来有难度！

##### 示例4

在实际环境中，经常会出现，因为网络原因，数据有可能会延迟一会才到达Flink实时处理系统。我们先来设想一下下面这个场景:
原本应该被该窗口计算的数据因为网络延迟等原因晚到了,就有可能丢失了

![image.png](https://image.hyly.net/i/2025/09/28/a4eaef7cc4284758902a395ae6877d63-0.webp)

##### 总结

实际开发中我们希望基于事件时间来处理数据，但因为数据可能因为网络延迟等原因，出现了乱序或延迟到达，那么可能处理的结果不是我们想要的甚至出现数据丢失的情况，所以需要一种机制来解决一定程度上的数据乱序或延迟到底的问题！也就是我们接下来要学习的Watermaker水印机制/水位线机制

#### Watermaker水印机制/水位线机制

##### 什么是Watermaker？

Watermaker就是给数据再额外的加的一个时间列
也就是Watermaker是个时间戳!

##### 如何计算Watermaker？

Watermaker = 数据的事件时间  -  最大允许的延迟时间或乱序时间
注意:后面通过源码会发现,准确来说:
Watermaker = 当前窗口的最大的事件时间  -  最大允许的延迟时间或乱序时间
这样可以保证Watermaker水位线会一直上升(变大),不会下降

##### Watermaker有什么用？

之前的窗口都是按照系统时间来触发计算的,如: [10:00:00 ~ 10:00:10) 的窗口，
一但系统时间到了10:00:10就会触发计算,那么可能会导致延迟到达的数据丢失!
那么现在有了Watermaker,窗口就可以按照Watermaker来触发计算!
也就是说Watermaker是用来触发窗口计算的！

##### Watermaker如何触发窗口计算的？

窗口计算的触发条件为:
1.窗口中有数据
2.Watermaker >= 窗口的结束时间

因为前面说到
Watermaker = 当前窗口的最大的事件时间  -  最大允许的延迟时间或乱序时间
也就是说只要不断有数据来,就可以保证Watermaker水位线是会一直上升/变大的,不会下降/减小的
所以最终一定是会触发窗口计算的

注意:
上面的触发公式进行如下变形:
**Watermaker >= 窗口的结束时间**
Watermaker = 当前窗口的最大的事件时间  -  最大允许的延迟时间或乱序时间
当前窗口的最大的事件时间  -  最大允许的延迟时间或乱序时间  >= 窗口的结束时间
**当前窗口的最大的事件时间  >= 窗口的结束时间 +  最大允许的延迟时间或乱序时间**

##### 图解Watermaker

![image.png](https://image.hyly.net/i/2025/09/28/0cb94855f6579f4ddabda0f131ff5228-0.webp)

#### Watermaker案例演示

##### 需求

有订单数据,格式为: (订单ID，用户ID，时间戳/事件时间，订单金额)
要求每隔5s,计算5秒内，每个用户的订单总金额
并添加Watermaker来解决一定程度上的数据延迟和数据乱序问题。

##### API

![image.png](https://image.hyly.net/i/2025/09/28/a3b09fa513c27e8ca3af6f21f9490626-0.webp)

注意:一般我们都是直接使用Flink提供好的BoundedOutOfOrdernessTimestampExtractor

##### 代码实现-1-开发版-掌握

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/event_timestamps_watermarks.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/event_timestamps_watermarks.html)

```
package cn.itcast.watermaker;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;

import java.time.Duration;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 * 模拟实时订单数据,格式为: (订单ID，用户ID，订单金额，时间戳/事件时间)
 * 要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
 * 并添加Watermaker来解决一定程度上的数据延迟和数据乱序问题。
 */
public class WatermakerDemo01_Develop {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        //模拟实时订单数据(数据有延迟和乱序)
        DataStream<Order> orderDS = env.addSource(new SourceFunction<Order>() {
            private boolean flag = true;

            @Override
            public void run(SourceContext<Order> ctx) throws Exception {
                Random random = new Random();
                while (flag) {
                    String orderId = UUID.randomUUID().toString();
                    int userId = random.nextInt(3);
                    int money = random.nextInt(100);
                    //模拟数据延迟和乱序!
                    long eventTime = System.currentTimeMillis() - random.nextInt(5) * 1000;
                    ctx.collect(new Order(orderId, userId, money, eventTime));

                    TimeUnit.SECONDS.sleep(1);
                }
            }

            @Override
            public void cancel() {
                flag = false;
            }
        });

        //3.Transformation
        //-告诉Flink要基于事件时间来计算!
        //env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);//新版本默认就是EventTime
        //-告诉Flnk数据中的哪一列是事件时间,因为Watermaker = 当前最大的事件时间 - 最大允许的延迟时间或乱序时间
        /*DataStream<Order> watermakerDS = orderDS.assignTimestampsAndWatermarks(
                new BoundedOutOfOrdernessTimestampExtractor<Order>(Time.seconds(3)) {//最大允许的延迟时间或乱序时间
                    @Override
                    public long extractTimestamp(Order element) {
                        return element.eventTime;
                        //指定事件时间是哪一列,Flink底层会自动计算:
                        //Watermaker = 当前最大的事件时间 - 最大允许的延迟时间或乱序时间
                    }
        });*/
        DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy.<Order>forBoundedOutOfOrderness(Duration.ofSeconds(3))
                                .withTimestampAssigner((event, timestamp) -> event.getEventTime())
                );

        //代码走到这里,就已经被添加上Watermaker了!接下来就可以进行窗口计算了
        //要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
        DataStream<Order> result = watermakerDS
                .keyBy(Order::getUserId)
                //.timeWindow(Time.seconds(5), Time.seconds(5))
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                .sum("money");


        //4.Sink
        result.print();

        //5.execute
        env.execute();
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Order {
        private String orderId;
        private Integer userId;
        private Integer money;
        private Long eventTime;
    }
}
```

##### 代码实现-2-验证版-了解

```
package cn.itcast.watermaker;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.lang3.time.FastDateFormat;
import org.apache.flink.api.common.eventtime.*;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.functions.windowing.WindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 * 模拟实时订单数据,格式为: (订单ID，用户ID，订单金额，时间戳/事件时间)
 * 要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
 * 并添加Watermaker来解决一定程度上的数据延迟和数据乱序问题。
 */
public class WatermakerDemo02_Check {
    public static void main(String[] args) throws Exception {
        FastDateFormat df = FastDateFormat.getInstance("HH:mm:ss");

        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        //模拟实时订单数据(数据有延迟和乱序)
        DataStreamSource<Order> orderDS = env.addSource(new SourceFunction<Order>() {
            private boolean flag = true;

            @Override
            public void run(SourceContext<Order> ctx) throws Exception {
                Random random = new Random();
                while (flag) {
                    String orderId = UUID.randomUUID().toString();
                    int userId = random.nextInt(3);
                    int money = random.nextInt(100);
                    //模拟数据延迟和乱序!
                    long eventTime = System.currentTimeMillis() - random.nextInt(5) * 1000;
                    System.out.println("发送的数据为: "+userId + " : " + df.format(eventTime));
                    ctx.collect(new Order(orderId, userId, money, eventTime));
                    TimeUnit.SECONDS.sleep(1);
                }
            }

            @Override
            public void cancel() {
                flag = false;
            }
        });

        //3.Transformation
        /*DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy.<Order>forBoundedOutOfOrderness(Duration.ofSeconds(3))
                                .withTimestampAssigner((event, timestamp) -> event.getEventTime())
                );*/

        //开发中直接使用上面的即可
        //学习测试时可以自己实现
        DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        new WatermarkStrategy<Order>() {
                            @Override
                            public WatermarkGenerator<Order> createWatermarkGenerator(WatermarkGeneratorSupplier.Context context) {
                                return new WatermarkGenerator<Order>() {
                                    private int userId = 0;
                                    private long eventTime = 0L;
                                    private final long outOfOrdernessMillis = 3000;
                                    private long maxTimestamp = Long.MIN_VALUE + outOfOrdernessMillis + 1;

                                    @Override
                                    public void onEvent(Order event, long eventTimestamp, WatermarkOutput output) {
                                        userId = event.userId;
                                        eventTime = event.eventTime;
                                        maxTimestamp = Math.max(maxTimestamp, eventTimestamp);
                                    }

                                    @Override
                                    public void onPeriodicEmit(WatermarkOutput output) {
                                        //Watermaker = 当前最大事件时间 - 最大允许的延迟时间或乱序时间
                                        Watermark watermark = new Watermark(maxTimestamp - outOfOrdernessMillis - 1);
                                        System.out.println("key:" + userId + ",系统时间:" + df.format(System.currentTimeMillis()) + ",事件时间:" + df.format(eventTime) + ",水印时间:" + df.format(watermark.getTimestamp()));
                                        output.emitWatermark(watermark);
                                    }
                                };
                            }
                        }.withTimestampAssigner((event, timestamp) -> event.getEventTime())
                );


        //代码走到这里,就已经被添加上Watermaker了!接下来就可以进行窗口计算了
        //要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
       /* DataStream<Order> result = watermakerDS
                 .keyBy(Order::getUserId)
                //.timeWindow(Time.seconds(5), Time.seconds(5))
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                .sum("money");*/

        //开发中使用上面的代码进行业务计算即可
        //学习测试时可以使用下面的代码对数据进行更详细的输出,如输出窗口触发时各个窗口中的数据的事件时间,Watermaker时间
        DataStream<String> result = watermakerDS
                .keyBy(Order::getUserId)
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                //把apply中的函数应用在窗口中的数据上
                //WindowFunction<IN, OUT, KEY, W extends Window>
                .apply(new WindowFunction<Order, String, Integer, TimeWindow>() {
                    @Override
                    public void apply(Integer key, TimeWindow window, Iterable<Order> input, Collector<String> out) throws Exception {
                        //准备一个集合用来存放属于该窗口的数据的事件时间
                        List<String> eventTimeList = new ArrayList<>();
                        for (Order order : input) {
                            Long eventTime = order.eventTime;
                            eventTimeList.add(df.format(eventTime));
                        }
                        String outStr = String.format("key:%s,窗口开始结束:[%s~%s),属于该窗口的事件时间:%s",
                                key.toString(), df.format(window.getStart()), df.format(window.getEnd()), eventTimeList);
                        out.collect(outStr);
                    }
                });
        //4.Sink
        result.print();

        //5.execute
        env.execute();
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Order {
        private String orderId;
        private Integer userId;
        private Integer money;
        private Long eventTime;
    }
}
```

#### Allowed Lateness案例演示

##### 需求

有订单数据,格式为: (订单ID，用户ID，时间戳/事件时间，订单金额)
要求每隔5s,计算5秒内，每个用户的订单总金额
并添加Watermaker来解决一定程度上的数据延迟和数据乱序问题。
并使用OutputTag+allowedLateness解决数据丢失问题

##### API

![image.png](https://image.hyly.net/i/2025/09/28/09eefcef6f6b47de15da5578c36484a8-0.webp)

```
package cn.itcast.watermaker;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.OutputTag;

import java.time.Duration;
import java.util.Random;
import java.util.UUID;

/**
 * Author itcast
 * Desc
 * 模拟实时订单数据,格式为: (订单ID，用户ID，订单金额，时间戳/事件时间)
 * 要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
 * 并添加Watermaker来解决一定程度上的数据延迟和数据乱序问题。
 */
public class WatermakerDemo03_AllowedLateness {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        //模拟实时订单数据(数据有延迟和乱序)
        DataStreamSource<Order> orderDS = env.addSource(new SourceFunction<Order>() {
            private boolean flag = true;
            @Override
            public void run(SourceContext<Order> ctx) throws Exception {
                Random random = new Random();
                while (flag) {
                    String orderId = UUID.randomUUID().toString();
                    int userId = random.nextInt(3);
                    int money = random.nextInt(100);
                    //模拟数据延迟和乱序!
                    long eventTime = System.currentTimeMillis() - random.nextInt(10) * 1000;
                    ctx.collect(new Order(orderId, userId, money, eventTime));

                    //TimeUnit.SECONDS.sleep(1);
                }
            }
            @Override
            public void cancel() {
                flag = false;
            }
        });


        //3.Transformation
        DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy.<Order>forBoundedOutOfOrderness(Duration.ofSeconds(3))
                                .withTimestampAssigner((event, timestamp) -> event.getEventTime())
                );

        //代码走到这里,就已经被添加上Watermaker了!接下来就可以进行窗口计算了
        //要求每隔5s,计算5秒内(基于时间的滚动窗口)，每个用户的订单总金额
        OutputTag<Order> outputTag = new OutputTag<>("Seriouslylate", TypeInformation.of(Order.class));

        SingleOutputStreamOperator<Order> result = watermakerDS
                .keyBy(Order::getUserId)
                //.timeWindow(Time.seconds(5), Time.seconds(5))
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                .allowedLateness(Time.seconds(5))
                .sideOutputLateData(outputTag)
                .sum("money");

        DataStream<Order> result2 = result.getSideOutput(outputTag);

        //4.Sink
        result.print("正常的数据和迟到不严重的数据");
        result2.print("迟到严重的数据");

        //5.execute
        env.execute();
    }
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Order {
        private String orderId;
        private Integer userId;
        private Integer money;
        private Long eventTime;
    }
}
```

### Flink-状态管理

#### Flink中的有状态计算

注意:
Flink中已经对需要进行有状态计算的API,做了封装,底层已经维护好了状态!
例如,之前下面代码,直接使用即可,不需要像SparkStreaming那样还得自己写updateStateByKey
也就是说我们今天学习的State只需要掌握原理,实际开发中一般都是使用Flink底层维护好的状态或第三方维护好的状态(如Flink整合Kafka的offset维护底层就是使用的State,但是人家已经写好了的)

```
package cn.itcast.source;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 * SocketSource
 */
public class SourceDemo03 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);
        //2.source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.处理数据-transformation
        //3.1每一行数据按照空格切分成一个个的单词组成一个集合
        DataStream<String> wordsDS = linesDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        //3.2对集合中的每个单词记为1
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(new MapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });

        //3.3对数据按照单词(key)进行分组
        //KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOnesDS.keyBy(0);
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);
        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        DataStream<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.输出结果-sink
        result.print();

        //5.触发执行-execute
        env.execute();
    }
}
```

执行 netcat，然后在终端输入 hello world，执行程序会输出什么?
答案很明显，(hello, 1)和 (word,1)
那么问题来了，如果再次在终端输入 hello world，程序会输入什么?
答案其实也很明显，(hello, 2)和(world, 2)。
为什么 Flink 知道之前已经处理过一次 hello world，这就是 state 发挥作用了，这里是被称为 keyed state 存储了之前需要统计的数据，所以 Flink 知道 hello 和 world 分别出现过一次。

#### 无状态计算和有状态计算

##### 无状态计算

不需要考虑历史数据
相同的输入得到相同的输出就是无状态计算, 如map/flatMap/filter....

![image.png](https://image.hyly.net/i/2025/09/28/46df9c0c64359a8993f32e0fa71cf70f-0.webp)

首先举一个无状态计算的例子：消费延迟计算。

假设现在有一个消息队列，消息队列中有一个生产者持续往消费队列写入消息，多个消费者分别从消息队列中读取消息。

从图上可以看出，生产者已经写入 16 条消息，Offset 停留在 15 ；有 3 个消费者，有的消费快，而有的消费慢。消费快的已经消费了 13 条数据，消费者慢的才消费了 7、8 条数据。

如何实时统计每个消费者落后多少条数据，如图给出了输入输出的示例。可以了解到输入的时间点有一个时间戳，生产者将消息写到了某个时间点的位置，每个消费者同一时间点分别读到了什么位置。刚才也提到了生产者写入了 15 条，消费者分别读取了 10、7、12 条。那么问题来了，怎么将生产者、消费者的进度转换为右侧示意图信息呢？

consumer 0 落后了 5 条，consumer 1 落后了 8 条，consumer 2 落后了 3 条，根据 Flink 的原理，此处需进行 Map 操作。Map 首先把消息读取进来，然后分别相减，即可知道每个 consumer 分别落后了几条。Map 一直往下发，则会得出最终结果。

大家会发现，在这种模式的计算中，无论这条输入进来多少次，输出的结果都是一样的，因为单条输入中已经包含了所需的所有信息。消费落后等于生产者减去消费者。生产者的消费在单条数据中可以得到，消费者的数据也可以在单条数据中得到，所以相同输入可以得到相同输出，这就是一个无状态的计算。

##### 有状态计算

需要考虑历史数据
相同的输入得到不同的输出/不一定得到相同的输出,就是有状态计算,如:sum/reduce

![image.png](https://image.hyly.net/i/2025/09/28/cf1c5f430ce2be2ebfb18e467f704931-0.webp)

以访问日志统计量的例子进行说明，比如当前拿到一个 Nginx 访问日志，一条日志表示一个请求，记录该请求从哪里来，访问的哪个地址，需要实时统计每个地址总共被访问了多少次，也即每个 API 被调用了多少次。可以看到下面简化的输入和输出，输入第一条是在某个时间点请求 GET 了 /api/a；第二条日志记录了某个时间点 Post /api/b ;第三条是在某个时间点 GET了一个 /api/a，总共有 3 个 Nginx 日志。

从这 3 条 Nginx 日志可以看出，第一条进来输出 /api/a 被访问了一次，第二条进来输出 /api/b 被访问了一次，紧接着又进来一条访问 api/a，所以 api/a 被访问了 2 次。不同的是，两条 /api/a 的 Nginx 日志进来的数据是一样的，但输出的时候结果可能不同，第一次输出 count=1 ，第二次输出 count=2，说明相同输入可能得到不同输出。输出的结果取决于当前请求的 API 地址之前累计被访问过多少次。第一条过来累计是 0 次，count = 1，第二条过来 API 的访问已经有一次了，所以 /api/a 访问累计次数 count=2。单条数据其实仅包含当前这次访问的信息，而不包含所有的信息。要得到这个结果，还需要依赖 API 累计访问的量，即状态。

这个计算模式是将数据输入算子中，用来进行各种复杂的计算并输出数据。这个过程中算子会去访问之前存储在里面的状态。另外一方面，它还会把现在的数据对状态的影响实时更新，如果输入 200 条数据，最后输出就是 200 条结果。

#### 有状态计算的场景

![image.png](https://image.hyly.net/i/2025/09/28/1b64a315a5e737f18f07a9c6cc6c372e-0.webp)

什么场景会用到状态呢？下面列举了常见的 4 种：

1. 去重：比如上游的系统数据可能会有重复，落到下游系统时希望把重复的数据都去掉。去重需要先了解哪些数据来过，哪些数据还没有来，也就是把所有的主键都记录下来，当一条数据到来后，能够看到在主键当中是否存在。
2. 窗口计算：比如统计每分钟 Nginx 日志 API 被访问了多少次。窗口是一分钟计算一次，在窗口触发前，如 08:00 ~ 08:01 这个窗口，前59秒的数据来了需要先放入内存，即需要把这个窗口之内的数据先保留下来，等到 8:01 时一分钟后，再将整个窗口内触发的数据输出。未触发的窗口数据也是一种状态。
3. 机器学习/深度学习：如训练的模型以及当前模型的参数也是一种状态，机器学习可能每次都用有一个数据集，需要在数据集上进行学习，对模型进行一个反馈。
4. 访问历史数据：比如与昨天的数据进行对比，需要访问一些历史数据。如果每次从外部去读，对资源的消耗可能比较大，所以也希望把这些历史数据也放入状态中做对比。

#### 状态的分类

##### Managed State & Raw State

![image.png](https://image.hyly.net/i/2025/09/28/90bf78d2a6b629b17cc6f16c6a5674f2-0.webp)

从Flink是否接管角度:可以分为
ManagedState(托管状态)
RawState(原始状态)
两者的区别如下：

1. 从状态管理方式的方式来说，Managed State 由 Flink Runtime 管理，自动存储，自动恢复，在内存管理上有优化；而 Raw State 需要用户自己管理，需要自己序列化，Flink 不知道 State 中存入的数据是什么结构，只有用户自己知道，需要最终序列化为可存储的数据结构。
2. 从状态数据结构来说，Managed State 支持已知的数据结构，如 Value、List、Map 等。而 Raw State只支持字节数组 ，所有状态都要转换为二进制字节数组才可以。
3. 从推荐使用场景来说，Managed State 大多数情况下均可使用，而 Raw State 是当 Managed State 不够用时，比如需要自定义 Operator 时，才会使用 Raw State。

**在实际生产中，都只推荐使用ManagedState，后续将围绕该话题进行讨论。**

##### Keyed State & Operator State

![image.png](https://image.hyly.net/i/2025/09/28/545aaff992badf803d9efdfd2ed9bd0a-0.webp)

Managed State 分为两种，Keyed State 和 Operator State
(Raw State都是Operator State)
**Keyed State**

![image.png](https://image.hyly.net/i/2025/09/28/d78a31740bea28be498b31b57d348188-0.webp)

在Flink Stream模型中，Datastream 经过 keyBy 的操作可以变为 KeyedStream。
Keyed State是基于KeyedStream上的状态。这个状态是跟特定的key绑定的，对KeyedStream流上的每一个key，都对应一个state，如stream.keyBy(…)
KeyBy之后的State,可以理解为分区过的State，每个并行keyed Operator的每个实例的每个key都有一个Keyed State，即&#x3c;parallel-operator-instance,key>就是一个唯一的状态，由于每个key属于一个keyed Operator的并行实例，因此我们将其简单的理解为&#x3c;operator,key>

**Operator State**

![image.png](https://image.hyly.net/i/2025/09/28/67d203f2268b1d325a638803963e245b-0.webp)

这里的fromElements会调用FromElementsFunction的类，其中就使用了类型为 list state 的 operator state
Operator State又称为 non-keyed state，与Key无关的State，每一个 operator state 都仅与一个 operator 的实例绑定。
Operator State 可以用于所有算子，但一般常用于 Source

#### 存储State的数据结构/API介绍

前面说过有状态计算其实就是需要考虑历史数据
而历史数据需要搞个地方存储起来
Flink为了方便不同分类的State的存储和管理,提供了如下的API/数据结构来存储State!

![image.png](https://image.hyly.net/i/2025/09/28/bbdd7b8f7c28e4af134ff2a1670cf608-0.webp)

Keyed State 通过 RuntimeContext 访问，这需要 Operator 是一个RichFunction。

保存Keyed state的数据结构:

ValueState&#x3c;T>:即类型为T的单值状态。这个状态与对应的key绑定，是最简单的状态了。它可以通过update方法更新状态值，通过value()方法获取状态值，如求按用户id统计用户交易总额

ListState&#x3c;T>:即key上的状态值为一个列表。可以通过add方法往列表中附加值；也可以通过get()方法返回一个Iterable&#x3c;T>来遍历状态值，如统计按用户id统计用户经常登录的Ip

ReducingState&#x3c;T>:这种状态通过用户传入的reduceFunction，每次调用add方法添加值的时候，会调用reduceFunction，最后合并到一个单一的状态值

MapState&#x3c;UK, UV>:即状态值为一个map。用户通过put或putAll方法添加元素

需要注意的是，以上所述的State对象，仅仅用于与状态进行交互(更新、删除、清空等)，而真正的状态值，有可能是存在内存、磁盘、或者其他分布式存储系统中。相当于我们只是持有了这个状态的句柄

Operator State 需要自己实现 CheckpointedFunction 或 ListCheckpointed 接口。

保存Operator state的数据结构:

ListState&#x3c;T>

BroadcastState&#x3c;K,V>

举例来说，Flink中的FlinkKafkaConsumer，就使用了operator state。它会在每个connector实例中，保存该实例中消费topic的所有(partition, offset)映射

![image.png](https://image.hyly.net/i/2025/09/28/ddc689c881caad0665bdd1d13ba14267-0.webp)

#### State代码示例

##### Keyed State

下图就 word count 的 sum 所使用的StreamGroupedReduce类为例讲解了如何在代码中使用 keyed state：

![image.png](https://image.hyly.net/i/2025/09/28/fb242aa6b3b4afa171386f8c471f4758-0.webp)

**官网代码示例**

[https://ci.apache.org/projects/flink/flink-docs-stable/dev/stream/state/state.html#using-managed-keyed-state](https://ci.apache.org/projects/flink/flink-docs-stable/dev/stream/state/state.html#using-managed-keyed-state)

**需求:**

使用KeyState中的ValueState获取数据中的最大值(实际中直接使用maxBy即可)

**编码步骤**

```java
//-1.定义一个状态用来存放最大值
private transient ValueState<Long> maxValueState;
//-2.创建一个状态描述符对象
ValueStateDescriptor descriptor = new ValueStateDescriptor("maxValueState", Long.class);
//-3.根据状态描述符获取State
maxValueState = getRuntimeContext().getState(maxValueStateDescriptor);
 //-4.使用State
Long historyValue = maxValueState.value();
//判断当前值和历史值谁大
if (historyValue == null || currentValue > historyValue) 
//-5.更新状态
maxValueState.update(currentValue); 
```

**代码示例**

```java
package cn.itcast.state;

import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.common.state.ValueState;
import org.apache.flink.api.common.state.ValueStateDescriptor;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.tuple.Tuple3;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

/**
 * Author itcast
 * Desc
 * 使用KeyState中的ValueState获取流数据中的最大值(实际中直接使用maxBy即可)
 */
public class StateDemo01_KeyedState {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);//方便观察

        //2.Source
        DataStreamSource<Tuple2<String, Long>> tupleDS = env.fromElements(
                Tuple2.of("北京", 1L),
                Tuple2.of("上海", 2L),
                Tuple2.of("北京", 6L),
                Tuple2.of("上海", 8L),
                Tuple2.of("北京", 3L),
                Tuple2.of("上海", 4L)
        );

        //3.Transformation
        //使用KeyState中的ValueState获取流数据中的最大值(实际中直接使用maxBy即可)
        //实现方式1:直接使用maxBy--开发中使用该方式即可
        //min只会求出最小的那个字段,其他的字段不管
        //minBy会求出最小的那个字段和对应的其他的字段
        //max只会求出最大的那个字段,其他的字段不管
        //maxBy会求出最大的那个字段和对应的其他的字段
        SingleOutputStreamOperator<Tuple2<String, Long>> result = tupleDS.keyBy(t -> t.f0)
                .maxBy(1);

        //实现方式2:使用KeyState中的ValueState---学习测试时使用,或者后续项目中/实际开发中遇到复杂的Flink没有实现的逻辑,才用该方式!
        SingleOutputStreamOperator<Tuple3<String, Long, Long>> result2 = tupleDS.keyBy(t -> t.f0)
                .map(new RichMapFunction<Tuple2<String, Long>, Tuple3<String, Long, Long>>() {
                    //-1.定义状态用来存储最大值
                    private ValueState<Long> maxValueState = null;

                    @Override
                    public void open(Configuration parameters) throws Exception {
                        //-2.定义状态描述符:描述状态的名称和里面的数据类型
                        ValueStateDescriptor descriptor = new ValueStateDescriptor("maxValueState", Long.class);
                        //-3.根据状态描述符初始化状态
                        maxValueState = getRuntimeContext().getState(descriptor);
                    }

                    @Override
                    public Tuple3<String, Long, Long> map(Tuple2<String, Long> value) throws Exception {
                        //-4.使用State,取出State中的最大值/历史最大值
                        Long historyMaxValue = maxValueState.value();
                        Long currentValue = value.f1;
                        if (historyMaxValue == null || currentValue > historyMaxValue) {
                            //5-更新状态,把当前的作为新的最大值存到状态中
                            maxValueState.update(currentValue);
                            return Tuple3.of(value.f0, currentValue, currentValue);
                        } else {
                            return Tuple3.of(value.f0, currentValue, historyMaxValue);
                        }
                    }
                });


        //4.Sink
        //result.print();
        result2.print();

        //5.execute
        env.execute();
    }
}
```

##### Operator State

下图对 word count 示例中的FromElementsFunction类进行详解并分享如何在代码中使用 operator state：

![image.png](https://image.hyly.net/i/2025/09/28/0e7447bf2986ae4e429b594570035d6a-0.webp)

**官网代码示例**

[https://ci.apache.org/projects/flink/flink-docs-stable/dev/stream/state/state.html#using-managed-operator-state](https://ci.apache.org/projects/flink/flink-docs-stable/dev/stream/state/state.html#using-managed-operator-state)

**需求:**

使用ListState存储offset模拟Kafka的offset维护

**编码步骤:**

```java
//-1.声明一个OperatorState来记录offset
private ListState<Long> offsetState = null;
private Long offset = 0L;
//-2.创建状态描述器
ListStateDescriptor<Long> descriptor = new ListStateDescriptor<Long>("offsetState", Long.class);
//-3.根据状态描述器获取State
offsetState = context.getOperatorStateStore().getListState(descriptor);

//-4.获取State中的值
Iterator<Long> iterator = offsetState.get().iterator();
if (iterator.hasNext()) {//迭代器中有值
    offset = iterator.next();//取出的值就是offset
}
offset += 1L;
ctx.collect("subTaskId:" + getRuntimeContext().getIndexOfThisSubtask() + ",当前的offset为:" + offset);
if (offset % 5 == 0) {//每隔5条消息,模拟一个异常
//-5.保存State到Checkpoint中
offsetState.clear();//清理内存中存储的offset到Checkpoint中
//-6.将offset存入State中
offsetState.add(offset);
```

**代码示例**

```java
package cn.itcast.state;

import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.api.common.state.ListState;
import org.apache.flink.api.common.state.ListStateDescriptor;
import org.apache.flink.runtime.state.FunctionInitializationContext;
import org.apache.flink.runtime.state.FunctionSnapshotContext;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.CheckpointingMode;
import org.apache.flink.streaming.api.checkpoint.CheckpointedFunction;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.CheckpointConfig;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction;

import java.util.Iterator;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 * 需求:
 * 使用OperatorState支持的数据结构ListState存储offset信息, 模拟Kafka的offset维护,
 * 其实就是FlinkKafkaConsumer底层对应offset的维护!
 */
public class StateDemo02_OperatorState {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);
        //先直接使用下面的代码设置Checkpoint时间间隔和磁盘路径以及代码遇到异常后的重启策略,下午会学
        env.enableCheckpointing(1000);//每隔1s执行一次Checkpoint
        env.setStateBackend(new FsStateBackend("file:///D:/ckp"));
        env.getCheckpointConfig().enableExternalizedCheckpoints(CheckpointConfig.ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);
        env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);
        //固定延迟重启策略: 程序出现异常的时候，重启2次，每次延迟3秒钟重启，超过2次，程序退出
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(2, 3000));

        //2.Source
        DataStreamSource<String> sourceData = env.addSource(new MyKafkaSource());

        //3.Transformation
        //4.Sink
        sourceData.print();

        //5.execute
        env.execute();
    }

    /**
     * MyKafkaSource就是模拟的FlinkKafkaConsumer并维护offset
     */
    public static class MyKafkaSource extends RichParallelSourceFunction<String> implements CheckpointedFunction {
        //-1.声明一个OperatorState来记录offset
        private ListState<Long> offsetState = null;
        private Long offset = 0L;
        private boolean flag = true;

        @Override
        public void initializeState(FunctionInitializationContext context) throws Exception {
            //-2.创建状态描述器
            ListStateDescriptor descriptor = new ListStateDescriptor("offsetState", Long.class);
            //-3.根据状态描述器初始化状态
            offsetState = context.getOperatorStateStore().getListState(descriptor);
        }

        @Override
        public void run(SourceContext<String> ctx) throws Exception {
            //-4.获取并使用State中的值
            Iterator<Long> iterator = offsetState.get().iterator();
            if (iterator.hasNext()){
                offset = iterator.next();
            }
            while (flag){
                offset += 1;
                int id = getRuntimeContext().getIndexOfThisSubtask();
                ctx.collect("分区:"+id+"消费到的offset位置为:" + offset);//1 2 3 4 5 6
                //Thread.sleep(1000);
                TimeUnit.SECONDS.sleep(2);
                if(offset % 5 == 0){
                    System.out.println("程序遇到异常了.....");
                    throw new Exception("程序遇到异常了.....");
                }
            }
        }

        @Override
        public void cancel() {
            flag = false;
        }

        /**
         * 下面的snapshotState方法会按照固定的时间间隔将State信息存储到Checkpoint/磁盘中,也就是在磁盘做快照!
         */
        @Override
        public void snapshotState(FunctionSnapshotContext context) throws Exception {
            //-5.保存State到Checkpoint中
            offsetState.clear();//清理内存中存储的offset到Checkpoint中
            //-6.将offset存入State中
            offsetState.add(offset);
        }
    }
}
```

### Flink-容错机制

#### Checkpoint

##### State Vs Checkpoint

**State:**

维护/存储的是某一个Operator的运行的状态/历史值,是维护在内存中!
一般指一个具体的Operator的状态(operator的状态表示一些算子在运行的过程中会产生的一些历史结果,如前面的maxBy底层会维护当前的最大值,也就是会维护一个keyedOperator,这个State里面存放就是maxBy这个Operator中的最大值)
State数据默认保存在Java的堆内存中/TaskManage节点的内存中
State可以被记录，在失败的情况下数据还可以恢复

**Checkpoint:**

某一时刻,Flink中所有的Operator的当前State的全局快照,一般存在磁盘上
表示了一个Flink Job在一个特定时刻的一份全局状态快照，即包含了所有Operator的状态
可以理解为Checkpoint是把State数据定时持久化存储了
比如KafkaConsumer算子中维护的Offset状态,当任务重新恢复的时候可以从Checkpoint中获取

**注意:**

Flink中的Checkpoint底层使用了Chandy-Lamport algorithm分布式快照算法可以保证数据的在分布式环境下的一致性!

[https://zhuanlan.zhihu.com/p/53482103](https://zhuanlan.zhihu.com/p/53482103)

Chandy-Lamport algorithm算法的作者也是ZK中Paxos 一致性算法的作者

[https://www.cnblogs.com/shenguanpu/p/4048660.html](https://www.cnblogs.com/shenguanpu/p/4048660.html)

Flink中使用Chandy-Lamport algorithm分布式快照算法取得了成功,后续Spark的StructuredStreaming也借鉴了该算法

##### Checkpoint执行流程

###### 简单流程

![image.png](https://image.hyly.net/i/2025/09/28/1fc2abe63f585b1174ff58683949eb4e-0.webp)

1. Flink的JobManager创建CheckpointCoordinator
2. Coordinator向所有的SourceOperator发送Barrier栅栏(理解为执行Checkpoint的信号)
3. SourceOperator接收到Barrier之后,暂停当前的操作(暂停的时间很短,因为后续的写快照是异步的),并制作State快照, 然后将自己的快照保存到指定的介质中(如HDFS), 一切 ok之后向Coordinator汇报并将Barrier发送给下游的其他Operator
4. 其他的如TransformationOperator接收到Barrier,重复第2步,最后将Barrier发送给Sink
5. Sink接收到Barrier之后重复第2步
6. Coordinator接收到所有的Operator的执行ok的汇报结果,认为本次快照执行成功

注意:
1.在往介质(如HDFS)中写入快照数据的时候是异步的(为了提高效率)
2.分布式快照执行时的数据一致性由Chandy-Lamport algorithm分布式快照算法保证!

###### 复杂流程--课后自行阅读

下图左侧是 Checkpoint Coordinator，是整个 Checkpoint 的发起者，中间是由两个 source，一个 sink 组成的 Flink 作业，最右侧的是持久化存储，在大部分用户场景中对应 HDFS。
1.Checkpoint Coordinator 向所有 source 节点 trigger Checkpoint。

![image.png](https://image.hyly.net/i/2025/09/28/ff9c1e46d1e5faec597584d187a5b3e3-0.webp)

2.source 节点向下游广播 barrier，这个 barrier 就是实现 Chandy-Lamport 分布式快照算法的核心，下游的 task 只有收到所有 input 的 barrier 才会执行相应的 Checkpoint。

![image.png](https://image.hyly.net/i/2025/09/28/054c1d2b1d08aa8f409437386c5cbdd5-0.webp)

3.当 task 完成 state 备份后，会将备份数据的地址（state handle）通知给 Checkpoint coordinator。

![image.png](https://image.hyly.net/i/2025/09/28/1075882d6d207b01c36d21b92787d900-0.webp)

4.下游的 sink 节点收集齐上游两个 input 的 barrier 之后，会执行本地快照，(栅栏对齐)
这里还展示了 RocksDB incremental Checkpoint (增量Checkpoint)的流程，首先 RocksDB 会全量刷数据到磁盘上（红色大三角表示），然后 Flink 框架会从中选择没有上传的文件进行持久化备份（紫色小三角）。

![image.png](https://image.hyly.net/i/2025/09/28/cabba10e005101e341cad9542b524d5d-0.webp)

5.同样的，sink 节点在完成自己的 Checkpoint 之后，会将 state handle 返回通知 Coordinator。

![image.png](https://image.hyly.net/i/2025/09/28/fefdc98989ea51dbc08bc2e72ebb7ba6-0.webp)

6.最后，当 Checkpoint coordinator 收集齐所有 task 的 state handle，就认为这一次的 Checkpoint 全局完成了，向持久化存储中再备份一个 Checkpoint meta 文件。

![image.png](https://image.hyly.net/i/2025/09/28/5c7f1f575338ecc6874ca6b53f084556-0.webp)

##### State状态后端/State存储介质

注意:
前面学习了Checkpoint其实就是Flink中某一时刻,所有的Operator的全局快照,
那么快照应该要有一个地方进行存储,而这个存储的地方叫做状态后端
Flink中的State状态后端有很多种:

###### MemStateBackend[了解]

![image.png](https://image.hyly.net/i/2025/09/28/2ce2f73181cf26ea0731f5e88f71a7c3-0.webp)

第一种是内存存储，即 MemoryStateBackend，构造方法是设置最大的StateSize，选择是否做异步快照，

对于State状态存储在 TaskManager 节点也就是执行节点内存中的，因为内存有容量限制，所以单个 State maxStateSize 默认 5 M，且需要注意 maxStateSize &#x3c;= akka.framesize 默认 10 M。

对于Checkpoint 存储在 JobManager 内存中，因此总大小不超过 JobManager 的内存。

推荐使用的场景为：本地测试、几乎无状态的作业，比如 ETL、JobManager 不容易挂，或挂掉影响不大的情况。

**不推荐在生产场景使用。**

###### FsStateBackend

![image.png](https://image.hyly.net/i/2025/09/28/41450110ee8b671d9c9657cb1752f498-0.webp)

另一种就是在文件系统上的 FsStateBackend 构建方法是需要传一个文件路径和是否异步快照。

State 依然在 TaskManager 内存中，但不会像 MemoryStateBackend 是 5 M 的设置上限

Checkpoint 存储在外部文件系统（本地或 HDFS），打破了总大小 Jobmanager 内存的限制。

**推荐使用的场景为：常规使用状态的作业、例如分钟级窗口聚合或 join、需要开启HA的作业。**

如果使用HDFS，则初始化FsStateBackend时，需要传入以 “hdfs://”开头的路径(即: new FsStateBackend("hdfs:///hacluster/checkpoint"))，

如果使用本地文件，则需要传入以“file://”开头的路径(即:new FsStateBackend("file:///Data"))。

在分布式情况下，不推荐使用本地文件。因为如果某个算子在节点A上失败，在节点B上恢复，使用本地文件时，在B上无法读取节点 A上的数据，导致状态恢复失败。

###### RocksDBStateBackend

![image.png](https://image.hyly.net/i/2025/09/28/3b1919a80e9e6cf377595e5ff1842bee-0.webp)

还有一种存储为 RocksDBStateBackend ，

RocksDB 是一个 key/value 的内存存储系统，和其他的 key/value 一样，先将状态放到内存中，如果内存快满时，则写入到磁盘中，

但需要注意 RocksDB 不支持同步的 Checkpoint，构造方法中没有同步快照这个选项。

不过 RocksDB 支持增量的 Checkpoint，意味着并不需要把所有 sst 文件上传到 Checkpoint 目录，仅需要上传新生成的 sst 文件即可。它的 Checkpoint 存储在外部文件系统（本地或HDFS），

其容量限制只要单个 TaskManager 上 State 总量不超过它的内存+磁盘，单 Key最大 2G，总大小不超过配置的文件系统容量即可。

**推荐使用的场景为：超大状态的作业，例如天级窗口聚合、需要开启 HA 的作业、最好是对状态读写性能要求不高的作业。**

##### Checkpoint配置方式

###### 全局配置

```
修改flink-conf.yaml
#这里可以配置
#jobmanager(即MemoryStateBackend), 
#filesystem(即FsStateBackend), 
#rocksdb(即RocksDBStateBackend)
state.backend: filesystem 
state.checkpoints.dir: hdfs://namenode:8020/flink/checkpoints
```

###### 在代码中配置

```
//1.MemoryStateBackend--开发中不用
    env.setStateBackend(new MemoryStateBackend)
//2.FsStateBackend--开发中可以使用--适合一般状态--秒级/分钟级窗口...
    env.setStateBackend(new FsStateBackend("hdfs路径或测试时的本地路径"))
//3.RocksDBStateBackend--开发中可以使用--适合超大状态--天级窗口...
env.setStateBackend(new RocksDBStateBackend(filebackend, true))

注意:RocksDBStateBackend还需要引入依赖
    <dependency>
       <groupId>org.apache.flink</groupId>
       <artifactId>flink-statebackend-rocksdb_2.11</artifactId>
       <version>1.7.2</version>
    </dependency>
```

##### 代码演示

```
package cn.itcast.checkpoint;

import org.apache.commons.lang3.SystemUtils;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.CheckpointingMode;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.CheckpointConfig;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer;
import org.apache.flink.util.Collector;

import java.util.Properties;

/**
 * Author itcast
 * Desc 演示Checkpoint参数设置(也就是Checkpoint执行流程中的步骤0相关的参数设置)
 */
public class CheckpointDemo01 {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //===========Checkpoint参数设置====
        //===========类型1:必须参数=============
        //设置Checkpoint的时间间隔为1000ms做一次Checkpoint/其实就是每隔1000ms发一次Barrier!
        env.enableCheckpointing(1000);
        //设置State状态存储介质
        /*if(args.length > 0){
            env.setStateBackend(new FsStateBackend(args[0]));
        }else {
            env.setStateBackend(new FsStateBackend("file:///D:\\data\\ckp"));
        }*/
        if (SystemUtils.IS_OS_WINDOWS) {
            env.setStateBackend(new FsStateBackend("file:///D:\\data\\ckp"));
        } else {
            env.setStateBackend(new FsStateBackend("hdfs://node1:8020/flink-checkpoint/checkpoint"));
        }
        //===========类型2:建议参数===========
        //设置两个Checkpoint 之间最少等待时间,如设置Checkpoint之间最少是要等 500ms(为了避免每隔1000ms做一次Checkpoint的时候,前一次太慢和后一次重叠到一起去了)
        //如:高速公路上,每隔1s关口放行一辆车,但是规定了两车之前的最小车距为500m
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(500);//默认是0
        //设置如果在做Checkpoint过程中出现错误，是否让整体任务失败：true是  false不是
        //env.getCheckpointConfig().setFailOnCheckpointingErrors(false);//默认是true
        env.getCheckpointConfig().setTolerableCheckpointFailureNumber(10);//默认值为0，表示不容忍任何检查点失败
        //设置是否清理检查点,表示 Cancel 时是否需要保留当前的 Checkpoint，默认 Checkpoint会在作业被Cancel时被删除
        //ExternalizedCheckpointCleanup.DELETE_ON_CANCELLATION：true,当作业被取消时，删除外部的checkpoint(默认值)
        //ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION：false,当作业被取消时，保留外部的checkpoint
        env.getCheckpointConfig().enableExternalizedCheckpoints(CheckpointConfig.ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);

        //===========类型3:直接使用默认的即可===============
        //设置checkpoint的执行模式为EXACTLY_ONCE(默认)
        env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);
        //设置checkpoint的超时时间,如果 Checkpoint在 60s内尚未完成说明该次Checkpoint失败,则丢弃。
        env.getCheckpointConfig().setCheckpointTimeout(60000);//默认10分钟
        //设置同一时间有多少个checkpoint可以同时执行
        env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);//默认为1

        //2.Source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //3.1切割出每个单词并直接记为1
        DataStream<Tuple2<String, Integer>> wordAndOneDS = linesDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                //value就是每一行
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });
        //3.2分组
        //注意:批处理的分组是groupBy,流处理的分组是keyBy
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOneDS.keyBy(t -> t.f0);
        //3.3聚合
        DataStream<Tuple2<String, Integer>> aggResult = groupedDS.sum(1);

        DataStream<String> result = (SingleOutputStreamOperator<String>) aggResult.map(new RichMapFunction<Tuple2<String, Integer>, String>() {
            @Override
            public String map(Tuple2<String, Integer> value) throws Exception {
                return value.f0 + ":::" + value.f1;
            }
        });

        //4.sink
        result.print();

        Properties props = new Properties();
        props.setProperty("bootstrap.servers", "node1:9092");
        FlinkKafkaProducer<String> kafkaSink = new FlinkKafkaProducer<>("flink_kafka", new SimpleStringSchema(), props);
        result.addSink(kafkaSink);

        //5.execute
        env.execute();

        // /export/server/kafka/bin/kafka-console-consumer.sh --bootstrap-server node1:9092 --topic flink_kafka
    }
}
```

#### 状态恢复和重启策略

##### 自动重启策略和恢复

###### 重启策略配置方式

**配置文件中**

```
在flink-conf.yml中可以进行配置,示例如下:
restart-strategy: fixed-delay
restart-strategy.fixed-delay.attempts: 3
restart-strategy.fixed-delay.delay: 10 s
```

**代码中**

```
还可以在代码中针对该任务进行配置,示例如下:
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
3, // 重启次数
Time.of(10, TimeUnit.SECONDS) // 延迟时间间隔
 ))
```

###### 重启策略分类

####### 默认重启策略

如果配置了Checkpoint,而没有配置重启策略,那么代码中出现了非致命错误时,程序会无限重启

####### 无重启策略

```
Job直接失败，不会尝试进行重启
 设置方式1:
 restart-strategy: none
 
 设置方式2:
 无重启策略也可以在程序中设置
 val env = ExecutionEnvironment.getExecutionEnvironment()
 env.setRestartStrategy(RestartStrategies.noRestart())
```

####### 固定延迟重启策略--开发中使用

```
 设置方式1:
 重启策略可以配置flink-conf.yaml的下面配置参数来启用，作为默认的重启策略:
 例子:
 restart-strategy: fixed-delay
 restart-strategy.fixed-delay.attempts: 3
 restart-strategy.fixed-delay.delay: 10 s
 
 设置方式2:
 也可以在程序中设置:
 val env = ExecutionEnvironment.getExecutionEnvironment()
 env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
   3, // 最多重启3次数
   Time.of(10, TimeUnit.SECONDS) // 重启时间间隔
 ))
 上面的设置表示:如果job失败,重启3次, 每次间隔10
```

####### 失败率重启策略--开发偶尔使用

```
设置方式1:
 失败率重启策略可以在flink-conf.yaml中设置下面的配置参数来启用:
 例子:
 restart-strategy:failure-rate
 restart-strategy.failure-rate.max-failures-per-interval: 3
 restart-strategy.failure-rate.failure-rate-interval: 5 min
 restart-strategy.failure-rate.delay: 10 s
 
 设置方式2:
 失败率重启策略也可以在程序中设置:
 val env = ExecutionEnvironment.getExecutionEnvironment()
 env.setRestartStrategy(RestartStrategies.failureRateRestart(
   3, // 每个测量时间间隔最大失败次数
   Time.of(5, TimeUnit.MINUTES), //失败率测量的时间间隔
   Time.of(10, TimeUnit.SECONDS) // 两次连续重启的时间间隔
 ))
 上面的设置表示:如果5分钟内job失败不超过三次,自动重启, 每次间隔10s (如果5分钟内程序失败超过3次,则程序退出)
```

###### 代码演示

```
package cn.itcast.checkpoint;

import org.apache.commons.lang3.SystemUtils;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.api.common.time.Time;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.CheckpointingMode;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.CheckpointConfig;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc 演示Checkpoint+重启策略
 */
public class CheckpointDemo02_RestartStrategy {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //===========Checkpoint参数设置====
        //===========类型1:必须参数=============
        //设置Checkpoint的时间间隔为1000ms做一次Checkpoint/其实就是每隔1000ms发一次Barrier!
        env.enableCheckpointing(1000);
        //设置State状态存储介质
        /*if(args.length > 0){
            env.setStateBackend(new FsStateBackend(args[0]));
        }else {
            env.setStateBackend(new FsStateBackend("file:///D:/ckp"));
        }*/
        if(SystemUtils.IS_OS_WINDOWS){
            env.setStateBackend(new FsStateBackend("file:///D:/ckp"));
        }else{
            env.setStateBackend(new FsStateBackend("hdfs://node1:8020/flink-checkpoint/checkpoint"));
        }
        //===========类型2:建议参数===========
        //设置两个Checkpoint 之间最少等待时间,如设置Checkpoint之间最少是要等 500ms(为了避免每隔1000ms做一次Checkpoint的时候,前一次太慢和后一次重叠到一起去了)
        //如:高速公路上,每隔1s关口放行一辆车,但是规定了两车之前的最小车距为500m
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(500);//默认是0
        //设置如果在做Checkpoint过程中出现错误，是否让整体任务失败：true是  false不是
        //env.getCheckpointConfig().setFailOnCheckpointingErrors(false);//默认是true
        env.getCheckpointConfig().setTolerableCheckpointFailureNumber(10);//默认值为0，表示不容忍任何检查点失败
        //设置是否清理检查点,表示 Cancel 时是否需要保留当前的 Checkpoint，默认 Checkpoint会在作业被Cancel时被删除
        //ExternalizedCheckpointCleanup.DELETE_ON_CANCELLATION：true,当作业被取消时，删除外部的checkpoint(默认值)
        //ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION：false,当作业被取消时，保留外部的checkpoint
        env.getCheckpointConfig().enableExternalizedCheckpoints(CheckpointConfig.ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);

        //===========类型3:直接使用默认的即可===============
        //设置checkpoint的执行模式为EXACTLY_ONCE(默认)
        env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);
        //设置checkpoint的超时时间,如果 Checkpoint在 60s内尚未完成说明该次Checkpoint失败,则丢弃。
        env.getCheckpointConfig().setCheckpointTimeout(60000);//默认10分钟
        //设置同一时间有多少个checkpoint可以同时执行
        env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);//默认为1

        //=============重启策略===========
        //-1.默认策略:配置了Checkpoint而没有配置重启策略默认使用无限重启
        //-2.配置无重启策略
        //env.setRestartStrategy(RestartStrategies.noRestart());
        //-3.固定延迟重启策略--开发中使用!
        //重启3次,每次间隔10s
        /*env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
                3, //尝试重启3次
                Time.of(10, TimeUnit.SECONDS))//每次重启间隔10s
        );*/
        //-4.失败率重启--偶尔使用
        //5分钟内重启3次(第3次不包括,也就是最多重启2次),每次间隔10s
        /*env.setRestartStrategy(RestartStrategies.failureRateRestart(
                3, // 每个测量时间间隔最大失败次数
                Time.of(5, TimeUnit.MINUTES), //失败率测量的时间间隔
                Time.of(10, TimeUnit.SECONDS) // 每次重启的时间间隔
        ));*/

        //上面的能看懂就行,开发中使用下面的代码即可
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(3, Time.of(10, TimeUnit.SECONDS)));

        //2.Source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);

        //3.Transformation
        //3.1切割出每个单词并直接记为1
        SingleOutputStreamOperator<Tuple2<String, Integer>> wordAndOneDS = linesDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                //value就是每一行
                String[] words = value.split(" ");
                for (String word : words) {
                    if(word.equals("bug")){
                        System.out.println("手动模拟的bug...");
                        throw new RuntimeException("手动模拟的bug...");
                    }
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });
        //3.2分组
        //注意:批处理的分组是groupBy,流处理的分组是keyBy
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOneDS.keyBy(t -> t.f0);
        //3.3聚合
        SingleOutputStreamOperator<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.sink
        result.print();

        //5.execute
        env.execute();
    }
}
```

##### 手动重启并恢复-了解

1.把程序打包

![image.png](https://image.hyly.net/i/2025/09/28/357cd97cd0ef740dec8088f4d4f45b74-0.webp)

2.启动Flink集群(本地单机版,集群版都可以)
/export/server/flink/bin/start-cluster.sh

3.访问webUI
http://node1:8081/#/overview
http://node2:8081/#/overview

4.使用FlinkWebUI提交
cn.itcast.checkpoint.CheckpointDemo01

![image.png](https://image.hyly.net/i/2025/09/28/975695bd1d6cb67f0f23b86aa60e74fa-0.webp)

5.取消任务

![image.png](https://image.hyly.net/i/2025/09/28/c85a64ab11f659247b849d082222a113-0.webp)

6.重新启动任务并指定从哪恢复
cn.itcast.checkpoint.CheckpointDemo01
hdfs://node1:8020/flink-checkpoint/checkpoint/9e8ce00dcd557dc03a678732f1552c3a/chk-34

![image.png](https://image.hyly.net/i/2025/09/28/6cc1d6b0d5e9ee6ad5fa5d9b5bf8395b-0.webp)

7.关闭/取消任务

![image.png](https://image.hyly.net/i/2025/09/28/859954d9b562c9bbcad12a9b3255cb11-0.webp)

8.关闭集群

/export/server/flink/bin/stop-cluster.sh

#### Savepoint

##### Savepoint介绍

Savepoint:保存点,类似于以前玩游戏的时候,遇到难关了/遇到boss了,赶紧手动存个档,然后接着玩,如果失败了,赶紧从上次的存档中恢复,然后接着玩

在实际开发中,可能会遇到这样的情况:如要对集群进行停机维护/扩容...
那么这时候需要执行一次Savepoint也就是执行一次手动的Checkpoint/也就是手动的发一个barrier栅栏,那么这样的话,程序的所有状态都会被执行快照并保存,
当维护/扩容完毕之后,可以从上一次Savepoint的目录中进行恢复!

##### Savepoint VS Checkpoint

![image.png](https://image.hyly.net/i/2025/09/28/fa1d615ca074aba85923b649bcf6be5b-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/aa956f40d80b69bb8d90eba3af15d45f-0.webp)

##### Savepoint演示

```
## 启动yarn session
/export/server/flink/bin/yarn-session.sh -n 2 -tm 800 -s 1 -d

## 运行job-会自动执行Checkpoint
/export/server/flink/bin/flink run --class cn.itcast.checkpoint.CheckpointDemo01 /root/ckp.jar

## 手动创建savepoint--相当于手动做了一次Checkpoint
/export/server/flink/bin/flink savepoint 702b872ef80f08854c946a544f2ee1a5 hdfs://node1:8020/flink-checkpoint/savepoint/

## 停止job
/export/server/flink/bin/flink cancel 702b872ef80f08854c946a544f2ee1a5

## 重新启动job,手动加载savepoint数据
/export/server/flink/bin/flink run -s hdfs://node1:8020/flink-checkpoint/savepoint/savepoint-702b87-0a11b997fa70 --class cn.itcast.checkpoint.CheckpointDemo01 /root/ckp.jar 

## 停止yarn session
yarn application -kill application_1607782486484_0014
```

### 扩展：关于并行度

一个Flink程序由多个Operator组成(source、transformation和 sink)。
一个Operator由多个并行的Task(线程)来执行， 一个Operator的并行Task(线程)数目就被称为该Operator(任务)的并行度(Parallel)

**并行度可以有如下几种指定方式**

1.Operator Level（算子级别）(可以使用)
一个算子、数据源和sink的并行度可以通过调用 setParallelism()方法来指定

![image.png](https://image.hyly.net/i/2025/09/28/8d0810258aadc3604b475cfba2e341cc-0.webp)

2.Execution Environment Level（Env级别）(可以使用)
执行环境(任务)的默认并行度可以通过调用setParallelism()方法指定。为了以并行度3来执行所有的算子、数据源和data sink， 可以通过如下的方式设置执行环境的并行度：
执行环境的并行度可以通过显式设置算子的并行度而被重写

![image.png](https://image.hyly.net/i/2025/09/28/0657b9449aa6d65a165dac051ac86e1e-0.webp)

3.Client Level(客户端级别,推荐使用)(可以使用)
并行度可以在客户端将job提交到Flink时设定。
对于CLI客户端，可以通过-p参数指定并行度
./bin/flink run -p 10 WordCount-java.jar

4.System Level（系统默认级别,尽量不使用）
在系统级可以通过设置flink-conf.yaml文件中的parallelism.default属性来指定所有执行环境的默认并行度

**示例**

![image.png](https://image.hyly.net/i/2025/09/28/bfe2c483c5ed57495f5495568b666e55-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/ad09f3938770669c775743731227c4eb-0.webp)

Example1
在fink-conf.yaml中 taskmanager.numberOfTaskSlots 默认值为1，即每个Task Manager上只有一个Slot ，此处是3
Example1中，WordCount程序设置了并行度为1，意味着程序 Source、Reduce、Sink在一个Slot中，占用一个Slot
Example2
通过设置并行度为2后，将占用2个Slot
Example3
通过设置并行度为9，将占用9个Slot
Example4
通过设置并行度为9，并且设置sink的并行度为1，则Source、Reduce将占用9个Slot，但是Sink只占用1个Slot

**注意**

1.并行度的优先级：算子级别 > env级别 > Client级别 > 系统默认级别  (越靠前具体的代码并行度的优先级越高)
2.如果source不可以被并行执行，即使指定了并行度为多个，也不会生效
3.在实际生产中，我们推荐在算子级别显示指定各自的并行度，方便进行显示和精确的资源控制。
4.slot是静态的概念，是指taskmanager具有的并发执行能力; parallelism是动态的概念，是指程序运行时实际使用的并发能力

## Flink-Table与SQL

### Table API & SQL 介绍

#### 为什么需要Table API & SQL

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/)

![image.png](https://image.hyly.net/i/2025/09/28/95dde923fc6b1ff02d6fd4b25457e866-0.webp)

Flink的Table模块包括 Table API 和 SQL：
Table API 是一种类SQL的API，通过Table API，用户可以像操作表一样操作数据，非常直观和方便
SQL作为一种声明式语言，有着标准的语法和规范，用户可以不用关心底层实现即可进行数据的处理，非常易于上手
Flink Table API 和 SQL 的实现上有80%左右的代码是公用的。作为一个流批统一的计算引擎，Flink 的 Runtime 层是统一的。

**Table API & SQL的特点**
Flink之所以选择将 Table API & SQL 作为未来的核心 API，是因为其具有一些非常重要的特点：

![image.png](https://image.hyly.net/i/2025/09/28/2b049277819fea7ae43777f062b8a200-0.webp)

1. 声明式:属于设定式语言，用户只要表达清楚需求即可，不需要了解底层执行；
2. 高性能:可优化，内置多种查询优化器，这些查询优化器可为 SQL 翻译出最优执行计划；
3. 简单易学:易于理解，不同行业和领域的人都懂，学习成本较低；
4. 标准稳定:语义遵循SQL标准，非常稳定，在数据库 30 多年的历史中，SQL 本身变化较少；
5. 流批统一:可以做到API层面上流与批的统一，相同的SQL逻辑，既可流模式运行，也可批模式运行，Flink底层Runtime本身就是一个流与批统一的引擎

#### Table API& SQL发展历程

**架构升级**

自 2015 年开始，阿里巴巴开始调研开源流计算引擎，最终决定基于 Flink 打造新一代计算引擎，针对 Flink 存在的不足进行优化和改进，并且在 2019 年初将最终代码开源，也就是Blink。Blink 在原来的 Flink 基础上最显著的一个贡献就是 Flink SQL 的实现。随着版本的不断更新，API 也出现了很多不兼容的地方。

在 Flink 1.9 中，Table 模块迎来了核心架构的升级，引入了阿里巴巴Blink团队贡献的诸多功能

![image.png](https://image.hyly.net/i/2025/09/28/3271174c49bedc6b4743e15786a78d89-0.webp)

在Flink 1.9 之前，Flink API 层 一直分为DataStream API 和 DataSet API，Table API & SQL 位于 DataStream API 和 DataSet API 之上。可以看处流处理和批处理有各自独立的api (流处理DataStream，批处理DataSet)。而且有不同的执行计划解析过程，codegen过程也完全不一样，完全没有流批一体的概念，面向用户不太友好。

在Flink1.9之后新的架构中，有两个查询处理器：Flink Query Processor，也称作Old Planner和Blink Query Processor，也称作Blink Planner。为了兼容老版本Table及SQL模块，插件化实现了Planner，Flink原有的Flink Planner不变，后期版本会被移除。新增加了Blink Planner，新的代码及特性会在Blink planner模块上实现。批或者流都是通过解析为Stream Transformation来实现的，不像Flink Planner，批是基于Dataset，流是基于DataStream。

**查询处理器的选择**

查询处理器是 Planner 的具体实现，通过parser、optimizer、codegen(代码生成技术)等流程将 Table API & SQL作业转换成 Flink Runtime 可识别的 Transformation DAG，最终由 Flink Runtime 进行作业的调度和执行。

Flink Query Processor查询处理器针对流计算和批处理作业有不同的分支处理，流计算作业底层的 API 是 DataStream API， 批处理作业底层的 API 是 DataSet API

Blink Query Processor查询处理器则实现流批作业接口的统一，底层的 API 都是Transformation，这就意味着我们和Dataset完全没有关系了

Flink1.11之后Blink Query Processor查询处理器已经是默认的了

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/)

![image.png](https://image.hyly.net/i/2025/09/28/f93ffb0bbd4fc44dd3294cb6f2ad595f-0.webp)

**了解-Blink planner和Flink Planner具体区别如下：**

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html)

![image.png](https://image.hyly.net/i/2025/09/28/7ac4d1a9d8e45d74a5d86abd7d2e3704-0.webp)

#### 注意：

[https://ci.apache.org/projects/flink/flink-docs-release-1.11/dev/table/common.html](https://ci.apache.org/projects/flink/flink-docs-release-1.11/dev/table/common.html)

**API稳定性**

![image.png](https://image.hyly.net/i/2025/09/28/c3468d3954e925044be483e0b3b6fc58-0.webp)

**性能对比**

注意：目前FlinkSQL性能不如SparkSQL，未来FlinkSQL可能会越来越好
下图是Hive、Spark、Flink的SQL执行速度对比：

![image.png](https://image.hyly.net/i/2025/09/28/af142a80053faf816f14488ed8c78de4-0.webp)

### 案例准备

#### 依赖

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/)

```
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-api-scala-bridge_2.12</artifactId>
    <version>${flink.version}</version>
    <scope>provided</scope>
</dependency>
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-api-java-bridge_2.12</artifactId>
    <version>${flink.version}</version>
    <scope>provided</scope>
</dependency>
<!-- flink执行计划,这是1.9版本之前的-->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-planner_2.12</artifactId>
    <version>${flink.version}</version>
</dependency>
<!-- blink执行计划,1.11+默认的-->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-planner-blink_2.12</artifactId>
    <version>${flink.version}</version>
    <scope>provided</scope>
</dependency>
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-table-common</artifactId>
    <version>${flink.version}</version>
    <scope>provided</scope>
</dependency>
```

● flink-table-common：这个包中主要是包含 Flink Planner 和 Blink Planner一些共用的代码。
● flink-table-api-java：这部分是用户编程使用的 API，包含了大部分的 API。
● flink-table-api-scala：这里只是非常薄的一层，仅和 Table API 的 Expression 和 DSL 相关。
● 两个 Planner：flink-table-planner 和 flink-table-planner-blink。
● 两个 Bridge：flink-table-api-scala-bridge 和 flink-table-api-java-bridge，
Flink Planner 和 Blink Planner 都会依赖于具体的 JavaAPI，也会依赖于具体的 Bridge，通过 Bridge 可以将 API 操作相应的转化为Scala 的 DataStream、DataSet，或者转化为 JAVA 的 DataStream 或者Data Set

#### 程序结构

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#structure-of-table-api-and-sql-programs](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#structure-of-table-api-and-sql-programs)

![image.png](https://image.hyly.net/i/2025/09/28/5c3fba5d95583816d0cfb28f4e1f06f8-0.webp)

```java
// create a TableEnvironment for specific planner batch or streaming
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section

// create a Table
tableEnv.connect(...).createTemporaryTable("table1");
// register an output Table
tableEnv.connect(...).createTemporaryTable("outputTable");

// create a Table object from a Table API query
Table tapiResult = tableEnv.from("table1").select(...);

// create a Table object from a SQL query
Table sqlResult  = tableEnv.sqlQuery("SELECT ... FROM table1 ... ");

// emit a Table API result Table to a TableSink, same for SQL result
TableResult tableResult = tapiResult.executeInsert("outputTable");
tableResult...
```

#### API

##### 获取环境

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#create-a-tableenvironment](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#create-a-tableenvironment)

```
// **********************
// FLINK STREAMING QUERY
// **********************
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

EnvironmentSettings fsSettings = EnvironmentSettings.newInstance().useOldPlanner().inStreamingMode().build();
StreamExecutionEnvironment fsEnv = StreamExecutionEnvironment.getExecutionEnvironment();
StreamTableEnvironment fsTableEnv = StreamTableEnvironment.create(fsEnv, fsSettings);
// or TableEnvironment fsTableEnv = TableEnvironment.create(fsSettings);

// ******************
// FLINK BATCH QUERY
// ******************
import org.apache.flink.api.java.ExecutionEnvironment;
import org.apache.flink.table.api.bridge.java.BatchTableEnvironment;

ExecutionEnvironment fbEnv = ExecutionEnvironment.getExecutionEnvironment();
BatchTableEnvironment fbTableEnv = BatchTableEnvironment.create(fbEnv);

// **********************
// BLINK STREAMING QUERY
// **********************
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

StreamExecutionEnvironment bsEnv = StreamExecutionEnvironment.getExecutionEnvironment();
EnvironmentSettings bsSettings = EnvironmentSettings.newInstance().useBlinkPlanner().inStreamingMode().build();
StreamTableEnvironment bsTableEnv = StreamTableEnvironment.create(bsEnv, bsSettings);
// or TableEnvironment bsTableEnv = TableEnvironment.create(bsSettings);

// ******************
// BLINK BATCH QUERY
// ******************
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;

EnvironmentSettings bbSettings = EnvironmentSettings.newInstance().useBlinkPlanner().inBatchMode().build();
TableEnvironment bbTableEnv = TableEnvironment.create(bbSettings);
```

##### 创建表

```
// get a TableEnvironment
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section

// table is the result of a simple projection query 
Table projTable = tableEnv.from("X").select(...);

// register the Table projTable as table "projectedTable"
tableEnv.createTemporaryView("projectedTable", projTable);
```

```
tableEnvironment
  .connect(...)
  .withFormat(...)
  .withSchema(...)
  .inAppendMode()
  .createTemporaryTable("MyTable")
```

##### 查询表

**Table API**

```
// get a TableEnvironment
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section
// register Orders table
// scan registered Orders table
Table orders = tableEnv.from("Orders");// compute revenue for all customers from France
Table revenue = orders
  .filter($("cCountry")
.isEqual("FRANCE"))
  .groupBy($("cID"), $("cName")
  .select($("cID"), $("cName"), $("revenue")
.sum()
.as("revSum"));
// emit or convert Table
// execute query
```

**SQL**

```
// get a TableEnvironment
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section

// register Orders table
// compute revenue for all customers from France
Table revenue = tableEnv.sqlQuery(
    "SELECT cID, cName, SUM(revenue) AS revSum " +
    "FROM Orders " +
    "WHERE cCountry = 'FRANCE' " +
    "GROUP BY cID, cName"
  );
// emit or convert Table
// execute query
```

```
// get a TableEnvironment
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section

// register "Orders" table
// register "RevenueFrance" output table
// compute revenue for all customers from France and emit to "RevenueFrance"
tableEnv.executeSql(
    "INSERT INTO RevenueFrance " +
    "SELECT cID, cName, SUM(revenue) AS revSum " +
    "FROM Orders " +
    "WHERE cCountry = 'FRANCE' " +
    "GROUP BY cID, cName"
  );
```

##### 写出表

```
// get a TableEnvironment
TableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section
// create an output Table
final Schema schema = new Schema()
    .field("a", DataTypes.INT())
    .field("b", DataTypes.STRING())
    .field("c", DataTypes.BIGINT());
tableEnv.connect(new FileSystem().path("/path/to/file"))
    .withFormat(new Csv().fieldDelimiter('|').deriveSchema())
    .withSchema(schema)
    .createTemporaryTable("CsvSinkTable");
// compute a result Table using Table API operators and/or SQL queries
Table result = ...
// emit the result Table to the registered TableSink
result.executeInsert("CsvSinkTable");
```

##### 与DataSet/DataStream集成

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#integration-with-datastream-and-dataset-api](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/common.html#integration-with-datastream-and-dataset-api)

![image.png](https://image.hyly.net/i/2025/09/28/c0ab331a852b1668143e8ad7cf61f36f-0.webp)

**Create a View from a DataStream or DataSet**

```
// get StreamTableEnvironment
// registration of a DataSet in a BatchTableEnvironment is equivalent
StreamTableEnvironment tableEnv = ...; 

// see "Create a TableEnvironment" section
DataStream<Tuple2<Long, String>> stream = ...

// register the DataStream as View "myTable" with fields "f0", "f1"
tableEnv.createTemporaryView("myTable", stream);

// register the DataStream as View "myTable2" with fields "myLong", "myString"
tableEnv.createTemporaryView("myTable2", stream, $("myLong"), $("myString"));
```

**Convert a DataStream or DataSet into a Table**

```
// get StreamTableEnvironment// registration of a DataSet in a BatchTableEnvironment is equivalent
StreamTableEnvironment tableEnv = ...; 
// see "Create a TableEnvironment" section

DataStream<Tuple2<Long, String>> stream = ...
// Convert the DataStream into a Table with default fields "f0", "f1"

Table table1 = tableEnv.fromDataStream(stream);
// Convert the DataStream into a Table with fields "myLong", "myString"
Table table2 = tableEnv.fromDataStream(stream, $("myLong"), $("myString"));
```

**Convert a Table into a DataStream or DataSet**

**Convert a Table into a DataStream**

Append Mode: This mode can only be used if the dynamic Table is only modified by INSERT changes, i.e, it is append-only and previously emitted results are never updated.
追加模式：只有当动态表仅通过插入更改进行修改时，才能使用此模式，即，它是仅追加模式，并且以前发出的结果从不更新。
Retract Mode: This mode can always be used. It encodes INSERT and DELETE changes with a boolean flag.
撤回模式：此模式始终可用。它使用布尔标志对插入和删除更改进行编码。

```
// get StreamTableEnvironment. 
StreamTableEnvironment tableEnv = ...; // see "Create a TableEnvironment" section

// Table with two fields (String name, Integer age)
Table table = ...

// convert the Table into an append DataStream of Row by specifying the class
DataStream<Row> dsRow = tableEnv.toAppendStream(table, Row.class);

// convert the Table into an append DataStream of Tuple2<String, Integer>
 //   via a TypeInformation
TupleTypeInfo<Tuple2<String, Integer>> tupleType = new TupleTypeInfo<>(
  Types.STRING(),
  Types.INT());
DataStream<Tuple2<String, Integer>> dsTuple = 
  tableEnv.toAppendStream(table, tupleType);
// convert the Table into a retract DataStream of Row.
//   A retract stream of type X is a DataStream<Tuple2<Boolean, X>>. 
//   The boolean field indicates the type of the change. 
//   True is INSERT, false is DELETE.
DataStream<Tuple2<Boolean, Row>> retractStream = 
  tableEnv.toRetractStream(table, Row.class);
```

**Convert a Table into a DataSet**

```
// get BatchTableEnvironment
BatchTableEnvironment tableEnv = BatchTableEnvironment.create(env);

// Table with two fields (String name, Integer age)
Table table = ...

// convert the Table into a DataSet of Row by specifying a class
DataSet<Row> dsRow = tableEnv.toDataSet(table, Row.class);

// convert the Table into a DataSet of Tuple2<String, Integer> via a TypeInformationTupleTypeInfo<Tuple2<String, Integer>> tupleType = new TupleTypeInfo<>(
  Types.STRING(),
  Types.INT());
DataSet<Tuple2<String, Integer>> dsTuple = 
  tableEnv.toDataSet(table, tupleType);
```

##### TableAPI

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/tableApi.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/tableApi.html)

##### SQLAPI

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/sql/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/sql/)

#### 相关概念

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/streaming/dynamic_tables.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/streaming/dynamic_tables.html)

##### 2.4.1 Dynamic Tables & Continuous Queries

在Flink中，它把针对无界流的表称之为Dynamic Table（动态表）。它是Flink Table API和SQL的核心概念。顾名思义，它表示了Table是不断变化的。

我们可以这样来理解，当我们用Flink的API，建立一个表，其实把它理解为建立一个逻辑结构，这个逻辑结构需要映射到数据上去。Flink source源源不断的流入数据，就好比每次都往表上新增一条数据。表中有了数据，我们就可以使用SQL去查询了。要注意一下，流处理中的数据是只有新增的，所以看起来数据会源源不断地添加到表中。

动态表也是一种表，既然是表，就应该能够被查询。我们来回想一下原先我们查询表的场景。
打开编译工具，编写一条SQL语句

1. 将SQL语句放入到mysql的终端执行
2. 查看结果
3. 再编写一条SQL语句
4. 再放入到终端执行
5. 再查看结果
6. …..如此反复

而针对动态表，Flink的source端肯定是源源不断地会有数据流入，然后我们基于这个数据流建立了一张表，再编写SQL语句查询数据，进行处理。这个SQL语句一定是不断地执行的。而不是只执行一次。注意：针对流处理的SQL绝对不会像批式处理一样，执行一次拿到结果就完了。而是会不停地执行，不断地查询获取结果处理。所以，官方给这种查询方式取了一个名字，叫Continuous Query，中文翻译过来叫连续查询。而且每一次查询出来的数据也是不断变化的。

![image.png](https://image.hyly.net/i/2025/09/28/f18048bb1a8a1caa7887010ad6b4a68f-0.webp)

这是一个非常简单的示意图。该示意图描述了：我们通过建立动态表和连续查询来实现在无界流中的SQL操作。大家也可以看到，在Continuous上面有一个State，表示查询出来的结果会存储在State中，再下来Flink最终还是使用流来进行处理。

所以，我们可以理解为Flink的Table API和SQL，是一个逻辑模型，通过该逻辑模型可以让我们的数据处理变得更加简单。

![image.png](https://image.hyly.net/i/2025/09/28/0da86616c429788f1d23dde39d6b1519-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/064985a8199f4e1cd066b31b5868f442-0.webp)

##### Table to Stream Conversion

**表中的Update和Delete**

我们前面提到的表示不断地Append，表的数据是一直累加的，因为表示对接Source的，Source是不会有update的。但如果我们编写了一个SQL。这个SQL看起来是这样的：

```
SELECT user, sum(money) FROM order GROUP BY user;
```

当执行一条SQL语句之后，这条语句的结果还是一个表，因为在Flink中执行的SQL是Continuous Query，这个表的数据是不断变化的。新创建的表存在Update的情况。仔细看下下面的示例，例如：

第一条数据，张三,2000，执行这条SQL语句的结果是，张三,2000

第二条数据，李四,1500，继续执行这条SQL语句，结果是，张三,2000 | 李四,1500

第三条数据，张三,300，继续执行这条SQL语句，结果是，张三,2300 | 李四,1500

….

大家发现了吗，现在数据结果是有Update的。张三一开始是2000，但后面变成了2300。

那还有删除的情况吗？有的。看一下下面这条SQL语句：

```
SELECT t1.`user`, SUM(t1.`money`) FROM t_order t1
WHERE
NOT EXISTS (SELECT T2.`user`AS TOTAL_MONEY FROM t_order t2 WHERE T2.`user` = T1.`user` GROUP BY t2.`user` HAVING SUM(T2.`money`) > 3000)
GROUP BY t1.`user`GROUP BY t1.`user
```

第一条数据，张三,2000，执行这条SQL语句的结果是，张三,2000

第二条数据，李四,1500，继续执行这条SQL语句，结果是，张三,2000 | 李四,1500

第三条数据，张三,300，继续执行这条SQL语句，结果是，张三,2300 | 李四,1500

第四条数据，张三,800，继续执行这条SQL语句，结果是，李四,1500

惊不惊喜？意不意外？

因为张三的消费的金额已经超过了3000，所以SQL执行完后，张三是被处理掉了。从数据的角度来看，它不就是被删除了吗？

通过上面的两个示例，给大家演示了，在Flink SQL中，对接Source的表都是Append-only的，不断地增加。执行一些SQL生成的表，这个表可能是要UPDATE的、也可能是要INSERT的。

**对表的编码操作**

我们前面说到过，表是一种逻辑结构。而Flink中的核心还是Stream。所以，Table最终还是会以Stream方式来继续处理。如果是以Stream方式处理，最终Stream中的数据有可能会写入到其他的外部系统中，例如：将Stream中的数据写入到MySQL中。

我们前面也看到了，表是有可能会UPDATE和DELETE的。那么如果是输出到MySQL中，就要执行UPDATE和DELETE语句了。而DataStream我们在学习Flink的时候就学习过了，DataStream是不能更新、删除事件的。

如果对表的操作是INSERT，这很好办，直接转换输出就好，因为DataStream数据也是不断递增的。但如果一个TABLE中的数据被UPDATE了、或者被DELETE了，如果用流来表达呢？因为流不可变的特征，我们肯定要对这种能够进行UPDATE/DELETE的TABLE做特殊操作。

我们可以针对每一种操作，INSERT/UPDATE/DELETE都用一个或多个经过编码的事件来表示。

例如：针对UPDATE，我们用两个操作来表达，[DELETE] 数据+  [INSERT]数据。也就是先把之前的数据删除，然后再插入一条新的数据。针对DELETE，我们也可以对流中的数据进行编码，[DELETE]数据。

总体来说，我们通过对流数据进行编码，也可以告诉DataStream的下游，[DELETE]表示发出MySQL的DELETE操作，将数据删除。用 [INSERT]表示插入新的数据。

**将表转换为三种不同编码方式的流**

Flink中的Table API或者SQL支持三种不同的编码方式。分别是：
Append-only流
Retract流
Upsert流

分别来解释下这三种流。

**Append-only流**

跟INSERT操作对应。这种编码类型的流针对的是只会不断新增的Dynamic Table。这种方式好处理，不需要进行特殊处理，源源不断地往流中发送事件即可。

**Retract流**

这种流就和Append-only不太一样。上面的只能处理INSERT，如果表会发生DELETE或者UPDATE，Append-only编码方式的流就不合适了。Retract流有几种类型的事件类型：

ADD MESSAGE：这种消息对应的就是INSERT操作。

RETRACT MESSAGE：直译过来叫取消消息。这种消息对应的就是DELETE操作。

我们可以看到通过ADD MESSAGE和RETRACT MESSAGE可以很好的向外部系统表达删除和插入操作。那如何进行UPDATE呢？好办！RETRACT MESSAGE + ADD MESSAGE即可。先把之前的数据进行删除，然后插入一条新的。完美~

![image.png](https://image.hyly.net/i/2025/09/28/93a8949e4393b5343980b40f1c842cd2-0.webp)

**Upsert流**

前面我们看到的RETRACT编码方式的流，实现UPDATE是使用DELETE + INSERT模式的。大家想一下：在MySQL中我们更新数据的时候，肯定不会先DELETE掉一条数据，然后再插入一条数据，肯定是直接发出UPDATE语句执行更新。而Upsert编码方式的流，是能够支持Update的，这种效率更高。它同样有两种类型的消息：

UPSERT MESSAGE：这种消息可以表示要对外部系统进行Update或者INSERT操作

DELETE MESSAGE：这种消息表示DELETE操作。

Upsert流是要求必须指定Primary Key的，因为Upsert操作是要有Key的。Upsert流针对UPDATE操作用一个UPSERT MESSAGE就可以描述，所以效率会更高。

![image.png](https://image.hyly.net/i/2025/09/28/a313014007c233863ff05948ce279360-0.webp)

### 案例1

#### 需求

将DataStream注册为Table和View并进行SQL统计

#### 代码实现

```
package cn.itcast.sql;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import java.util.Arrays;

import static org.apache.flink.table.api.Expressions.$;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo01 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //EnvironmentSettings settings = EnvironmentSettings.newInstance().useBlinkPlanner().inStreamingMode().build();
        //StreamTableEnvironment tEnv = StreamTableEnvironment.create(env, settings);
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        DataStream<Order> orderA = env.fromCollection(Arrays.asList(
                new Order(1L, "beer", 3),
                new Order(1L, "diaper", 4),
                new Order(3L, "rubber", 2)));

        DataStream<Order> orderB = env.fromCollection(Arrays.asList(
                new Order(2L, "pen", 3),
                new Order(2L, "rubber", 3),
                new Order(4L, "beer", 1)));

        //3.注册表
        // convert DataStream to Table
        Table tableA = tEnv.fromDataStream(orderA, $("user"), $("product"), $("amount"));
        // register DataStream as Table
        tEnv.createTemporaryView("OrderB", orderB, $("user"), $("product"), $("amount"));

        //4.执行查询
        System.out.println(tableA);
        // union the two tables
        Table resultTable = tEnv.sqlQuery(
                "SELECT * FROM " + tableA + " WHERE amount > 2 " +
                "UNION ALL " +
                "SELECT * FROM OrderB WHERE amount < 2"
        );

        //5.输出结果
        DataStream<Order> resultDS = tEnv.toAppendStream(resultTable, Order.class);
        resultDS.print();

        env.execute();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Order {
        public Long user;
        public String product;
        public int amount;
    }
}
```

### **案例2**

#### 需求

使用SQL和Table两种方式对DataStream中的单词进行统计

#### 代码实现-SQL

```
package cn.itcast.sql;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import static org.apache.flink.table.api.Expressions.$;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo02 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        DataStream<WC> input = env.fromElements(
                new WC("Hello", 1),
                new WC("World", 1),
                new WC("Hello", 1)
        );

        //3.注册表
        tEnv.createTemporaryView("WordCount", input, $("word"), $("frequency"));

        //4.执行查询
        Table resultTable = tEnv.sqlQuery("SELECT word, SUM(frequency) as frequency FROM WordCount GROUP BY word");

        //5.输出结果
        //toAppendStream doesn't support consuming update changes which is produced by node GroupAggregate
        //DataStream<WC> resultDS = tEnv.toAppendStream(resultTable, WC.class);
        DataStream<Tuple2<Boolean, WC>> resultDS = tEnv.toRetractStream(resultTable, WC.class);

        resultDS.print();

        env.execute();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WC {
        public String word;
        public long frequency;
    }
}
```

#### 代码实现-Table

```
package cn.itcast.sql;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import static org.apache.flink.table.api.Expressions.$;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo03 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        DataStream<WC> input = env.fromElements(
                new WC("Hello", 1),
                new WC("World", 1),
                new WC("Hello", 1)
        );

        //3.注册表
        Table table = tEnv.fromDataStream(input);

        //4.执行查询
        Table resultTable = table
                .groupBy($("word"))
                .select($("word"), $("frequency").sum().as("frequency"))
                .filter($("frequency").isEqual(2));

        //5.输出结果
        DataStream<Tuple2<Boolean, WC>> resultDS = tEnv.toRetractStream(resultTable, WC.class);

        resultDS.print();

        env.execute();
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WC {
        public String word;
        public long frequency;
    }
}
```

### 案例3

#### 需求

使用Flink SQL来统计5秒内 每个用户的 订单总数、订单的最大金额、订单的最小金额
也就是每隔5秒统计最近5秒的每个用户的订单总数、订单的最大金额、订单的最小金额
上面的需求使用流处理的Window的基于时间的滚动窗口就可以搞定!
那么接下来使用FlinkTable&SQL-API来实现

#### 编码步骤

1.创建环境
2.使用自定义函数模拟实时流数据
3.设置事件时间和Watermaker
4.注册表
5.执行sql-可以使用sql风格或table风格(了解)
6.输出结果
7.触发执行

#### 代码实现-方式1

```
package cn.itcast.sql;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.types.Row;

import java.time.Duration;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import static org.apache.flink.table.api.Expressions.$;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo04 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        DataStreamSource<Order> orderDS  = env.addSource(new RichSourceFunction<Order>() {
            private Boolean isRunning = true;
            @Override
            public void run(SourceContext<Order> ctx) throws Exception {
                Random random = new Random();
                while (isRunning) {
                    Order order = new Order(UUID.randomUUID().toString(), random.nextInt(3), random.nextInt(101), System.currentTimeMillis());
                    TimeUnit.SECONDS.sleep(1);
                    ctx.collect(order);
                }
            }

            @Override
            public void cancel() {
                isRunning = false;
            }
        });

        //3.Transformation
        DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy.<Order>forBoundedOutOfOrderness(Duration.ofSeconds(2))
                                .withTimestampAssigner((event, timestamp) -> event.getCreateTime())
                );

        //4.注册表
        tEnv.createTemporaryView("t_order", watermakerDS,
                $("orderId"), $("userId"), $("money"), $("createTime").rowtime());

        //5.执行SQL
        String sql = "select " +
                "userId," +
                "count(*) as totalCount," +
                "max(money) as maxMoney," +
                "min(money) as minMoney " +
                "from t_order " +
                "group by userId," +
                "tumble(createTime, interval '5' second)";

        Table ResultTable = tEnv.sqlQuery(sql);

        //6.Sink
        //将SQL的执行结果转换成DataStream再打印出来
        //toAppendStream → 将计算后的数据append到结果DataStream中去
        //toRetractStream  → 将计算后的新的数据在DataStream原数据的基础上更新true或是删除false
        DataStream<Tuple2<Boolean, Row>> resultDS = tEnv.toRetractStream(ResultTable, Row.class);
        resultDS.print();

        env.execute();

    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Order {
        private String orderId;
        private Integer userId;
        private Integer money;
        private Long createTime;
    }
}
```

toAppendStream → 将计算后的数据append到结果DataStream中去
toRetractStream  → 将计算后的新的数据在DataStream原数据的基础上更新true或是删除false

#### 代码实现-方式2

```
package cn.itcast.sql;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.Tumble;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.types.Row;

import java.time.Duration;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import static org.apache.flink.table.api.Expressions.$;
import static org.apache.flink.table.api.Expressions.lit;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo05 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        DataStreamSource<Order> orderDS = env.addSource(new RichSourceFunction<Order>() {
            private Boolean isRunning = true;

            @Override
            public void run(SourceContext<Order> ctx) throws Exception {
                Random random = new Random();
                while (isRunning) {
                    Order order = new Order(UUID.randomUUID().toString(), random.nextInt(3), random.nextInt(101), System.currentTimeMillis());
                    TimeUnit.SECONDS.sleep(1);
                    ctx.collect(order);
                }
            }

            @Override
            public void cancel() {
                isRunning = false;
            }
        });

        //3.Transformation
        DataStream<Order> watermakerDS = orderDS
                .assignTimestampsAndWatermarks(
                        WatermarkStrategy.<Order>forBoundedOutOfOrderness(Duration.ofSeconds(2))
                                .withTimestampAssigner((event, timestamp) -> event.getCreateTime())
                );

        //4.注册表
        tEnv.createTemporaryView("t_order", watermakerDS,
                $("orderId"), $("userId"), $("money"), $("createTime").rowtime());

        //查看表约束
        tEnv.from("t_order").printSchema();

        //5.TableAPI查询
        Table ResultTable = tEnv.from("t_order")
                //.window(Tumble.over("5.second").on("createTime").as("tumbleWindow"))
                .window(Tumble.over(lit(5).second())
                        .on($("createTime"))
                        .as("tumbleWindow"))
                .groupBy($("tumbleWindow"), $("userId"))
                .select(
                        $("userId"),
                        $("userId").count().as("totalCount"),
                        $("money").max().as("maxMoney"),
                        $("money").min().as("minMoney"));


        //6.将SQL的执行结果转换成DataStream再打印出来
        DataStream<Tuple2<Boolean, Row>> resultDS = tEnv.toRetractStream(ResultTable, Row.class);
        resultDS.print();

        //7.excute
        env.execute();
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Order {
        private String orderId;
        private Integer userId;
        private Integer money;
        private Long createTime;
    }
}
```

### 案例4

#### 需求

从Kafka中消费数据并过滤出状态为success的数据再写入到Kafka

```
{"user_id": "1", "page_id":"1", "status": "success"}
{"user_id": "1", "page_id":"1", "status": "success"}
{"user_id": "1", "page_id":"1", "status": "success"}
{"user_id": "1", "page_id":"1", "status": "success"}
{"user_id": "1", "page_id":"1", "status": "fail"}
```

```
/export/server/kafka/bin/kafka-topics.sh --create --zookeeper node1:2181 --replication-factor 2 --partitions 3 --topic input_kafka

/export/server/kafka/bin/kafka-topics.sh --create --zookeeper node1:2181 --replication-factor 2 --partitions 3 --topic output_kafka

/export/server/kafka/bin/kafka-console-producer.sh --broker-list node1:9092 --topic input_kafka

/export/server/kafka/bin/kafka-console-consumer.sh --bootstrap-server node1:9092 --topic output_kafka --from-beginning
```

#### 代码实现

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/)

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/kafka.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/kafka.html)

```
package cn.itcast.sql;

import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.TableResult;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.types.Row;

/**
 * Author itcast
 * Desc
 */
public class FlinkSQL_Table_Demo06 {
    public static void main(String[] args) throws Exception {
        //1.准备环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

        //2.Source
        TableResult inputTable = tEnv.executeSql(
                "CREATE TABLE input_kafka (\n" +
                        "  `user_id` BIGINT,\n" +
                        "  `page_id` BIGINT,\n" +
                        "  `status` STRING\n" +
                        ") WITH (\n" +
                        "  'connector' = 'kafka',\n" +
                        "  'topic' = 'input_kafka',\n" +
                        "  'properties.bootstrap.servers' = 'node1:9092',\n" +
                        "  'properties.group.id' = 'testGroup',\n" +
                        "  'scan.startup.mode' = 'latest-offset',\n" +
                        "  'format' = 'json'\n" +
                        ")"
        );
        TableResult outputTable = tEnv.executeSql(
                "CREATE TABLE output_kafka (\n" +
                        "  `user_id` BIGINT,\n" +
                        "  `page_id` BIGINT,\n" +
                        "  `status` STRING\n" +
                        ") WITH (\n" +
                        "  'connector' = 'kafka',\n" +
                        "  'topic' = 'output_kafka',\n" +
                        "  'properties.bootstrap.servers' = 'node1:9092',\n" +
                        "  'format' = 'json',\n" +
                        "  'sink.partitioner' = 'round-robin'\n" +
                        ")"
        );

        String sql = "select " +
                "user_id," +
                "page_id," +
                "status " +
                "from input_kafka " +
                "where status = 'success'";

        Table ResultTable = tEnv.sqlQuery(sql);

        DataStream<Tuple2<Boolean, Row>> resultDS = tEnv.toRetractStream(ResultTable, Row.class);
        resultDS.print();

        tEnv.executeSql("insert into output_kafka select * from "+ResultTable);


        //7.excute
        env.execute();
    }


}
```

### 总结-Flink-SQL常用算子

#### SELECT

```
SELECT 用于从 DataSet/DataStream 中选择数据，用于筛选出某些列。
示例：
SELECT * FROM Table；// 取出表中的所有列
SELECT name，age FROM Table；// 取出表中 name 和 age 两列
与此同时 SELECT 语句中可以使用函数和别名，例如我们上面提到的 WordCount 中：
SELECT word, COUNT(word) FROM table GROUP BY word;
```

#### WHERE

WHERE 用于从数据集/流中过滤数据，与 SELECT 一起使用，用于根据某些条件对关系做水平分割，即选择符合条件的记录。

```
示例：
SELECT name，age FROM Table where name LIKE ‘% 小明 %’；
SELECT * FROM Table WHERE age = 20；
WHERE 是从原数据中进行过滤，那么在 WHERE 条件中，Flink SQL 同样支持 =、<、>、<>、>=、<=，以及 AND、OR 等表达式的组合，最终满足过滤条件的数据会被选择出来。并且 WHERE 可以结合 IN、NOT IN 联合使用。举个例子：
SELECT name, age
FROM Table
WHERE name IN (SELECT name FROM Table2)
```

#### DISTINCT

DISTINCT 用于从数据集/流中去重根据 SELECT 的结果进行去重。

示例：
SELECT DISTINCT name FROM Table;
对于流式查询，计算查询结果所需的 State 可能会无限增长，用户需要自己控制查询的状态范围，以防止状态过大。

#### GROUP BY

GROUP BY 是对数据进行分组操作。例如我们需要计算成绩明细表中，每个学生的总分。

示例：
SELECT name, SUM(score) as TotalScore FROM Table GROUP BY name;

#### UNION 和 UNION ALL

UNION 用于将两个结果集合并起来，要求两个结果集字段完全一致，包括字段类型、字段顺序。
不同于 UNION ALL 的是，UNION 会对结果数据去重。

示例：
SELECT * FROM T1 UNION (ALL) SELECT * FROM T2；

#### JOIN

JOIN 用于把来自两个表的数据联合起来形成结果表，Flink 支持的 JOIN 类型包括：

JOIN - INNER JOIN
LEFT JOIN - LEFT OUTER JOIN
RIGHT JOIN - RIGHT OUTER JOIN
FULL JOIN - FULL OUTER JOIN
这里的 JOIN 的语义和我们在关系型数据库中使用的 JOIN 语义一致。

示例：
JOIN(将订单表数据和商品表进行关联)
SELECT * FROM Orders INNER JOIN Product ON Orders.productId = Product.id

LEFT JOIN 与 JOIN 的区别是当右表没有与左边相 JOIN 的数据时候，右边对应的字段补 NULL 输出，RIGHT JOIN 相当于 LEFT JOIN 左右两个表交互一下位置。FULL JOIN 相当于 RIGHT JOIN 和 LEFT JOIN 之后进行 UNION ALL 操作。

示例：
SELECT * FROM Orders LEFT JOIN Product ON Orders.productId = Product.id
SELECT * FROM Orders RIGHT JOIN Product ON Orders.productId = Product.id
SELECT * FROM Orders FULL OUTER JOIN Product ON Orders.productId = Product.id

#### Group Window

根据窗口数据划分的不同，目前 Apache Flink 有如下 3 种 Bounded Window：
Tumble，滚动窗口，窗口数据有固定的大小，窗口数据无叠加；
**Hop，滑动窗口，窗口数据有固定大小，并且有固定的窗口重建频率，窗口数据有叠加；**
Session，会话窗口，窗口数据没有固定的大小，根据窗口数据活跃程度划分窗口，窗口数据无叠加。

##### Tumble Window

Tumble 滚动窗口有固定大小，窗口数据不重叠，具体语义如下：

![image.png](https://image.hyly.net/i/2025/09/28/f3335312783180f0a047598607efd5c6-0.webp)

Tumble 滚动窗口对应的语法如下：

```
SELECT 
    [gk],
    [TUMBLE_START(timeCol, size)], 
    [TUMBLE_END(timeCol, size)], 
    agg1(col1), 
    ... 
    aggn(colN)
FROM Tab1
GROUP BY [gk], TUMBLE(timeCol, size)
```

其中：

[gk] 决定了是否需要按照字段进行聚合；

TUMBLE_START 代表窗口开始时间；

TUMBLE_END 代表窗口结束时间；

timeCol 是流表中表示时间字段；

size 表示窗口的大小，如 秒、分钟、小时、天。

举个例子，假如我们要计算每个人每天的订单量，按照 user 进行聚合分组：

SELECT user, TUMBLE_START(rowtime, INTERVAL ‘1’ DAY) as wStart, SUM(amount)

FROM Orders

GROUP BY TUMBLE(rowtime, INTERVAL ‘1’ DAY), user;

##### Hop Window

Hop 滑动窗口和滚动窗口类似，窗口有固定的 size，与滚动窗口不同的是滑动窗口可以通过 slide 参数控制滑动窗口的新建频率。因此当 slide 值小于窗口 size 的值的时候多个滑动窗口会重叠，具体语义如下：

![image.png](https://image.hyly.net/i/2025/09/28/227801b930ad540461e465a84fa562ed-0.webp)

Hop 滑动窗口对应语法如下：

```
SELECT 
    [gk], 
    [HOP_START(timeCol, slide, size)] ,  
    [HOP_END(timeCol, slide, size)],
    agg1(col1), 
    ... 
    aggN(colN) 
FROM Tab1
GROUP BY [gk], HOP(timeCol, slide, size)
```

每次字段的意思和 Tumble 窗口类似：
[gk] 决定了是否需要按照字段进行聚合；
HOP_START 表示窗口开始时间；
HOP_END 表示窗口结束时间；
timeCol 表示流表中表示时间字段；
slide 表示每次窗口滑动的大小；
size 表示整个窗口的大小，如 秒、分钟、小时、天。

举例说明，我们要每过一小时计算一次过去 24 小时内每个商品的销量：
SELECT product, SUM(amount)
FROM Orders
GROUP BY product,HOP(rowtime, INTERVAL '1' HOUR, INTERVAL '1' DAY)

##### Session Window

会话时间窗口没有固定的持续时间，但它们的界限由 interval 不活动时间定义，即如果在定义的间隙期间没有出现事件，则会话窗口关闭。

![image.png](https://image.hyly.net/i/2025/09/28/255c4fa446282ca91956db903e353b3e-0.webp)

Seeeion 会话窗口对应语法如下：

```
SELECT 
    [gk], 
    SESSION_START(timeCol, gap) AS winStart,  
    SESSION_END(timeCol, gap) AS winEnd,
    agg1(col1),
     ... 
    aggn(colN)
FROM Tab1
GROUP BY [gk], SESSION(timeCol, gap)
```

[gk] 决定了是否需要按照字段进行聚合；
SESSION_START 表示窗口开始时间；
SESSION_END 表示窗口结束时间；
timeCol 表示流表中表示时间字段；
gap 表示窗口数据非活跃周期的时长。

例如，我们需要计算每个用户访问时间 12 小时内的订单量：

```
SELECT user, SESSION_START(rowtime, INTERVAL ‘12’ HOUR) AS sStart, SESSION_ROWTIME(rowtime, INTERVAL ‘12’ HOUR) AS sEnd, SUM(amount) 
FROM Orders 
GROUP BY SESSION(rowtime, INTERVAL ‘12’ HOUR), user
```

## Flink-Action综合练习

### Flink模拟双十一实时大屏统计

#### 需求

![image.png](https://image.hyly.net/i/2025/09/28/6c523f36c68d11930b05a0894e43e0f1-0.webp)

在大数据的实时处理中，实时的大屏展示已经成了一个很重要的展示项，比如最有名的双十一大屏实时销售总价展示。除了这个，还有一些其他场景的应用，比如我们在我们的后台系统实时的展示我们网站当前的pv、uv等等，其实做法都是类似的。

今天我们就做一个最简单的模拟电商统计大屏的小例子，
需求如下：
1.实时计算出当天零点截止到当前时间的销售总额
2.计算出各个分类的销售top3
3.每秒钟更新一次统计结果

#### 数据

首先我们通过自定义source 模拟订单的生成，生成了一个Tuple2,第一个元素是分类，第二个元素表示这个分类下产生的订单金额，金额我们通过随机生成.

```
/**
 * 自定义数据源实时产生订单数据Tuple2<分类, 金额>
 */
public static class MySource implements SourceFunction<Tuple2<String, Double>>{
    private boolean flag = true;
    private String[] categorys = {"女装", "男装","图书", "家电","洗护", "美妆","运动", "游戏","户外", "家具","乐器", "办公"};
    private Random random = new Random();

    @Override
    public void run(SourceContext<Tuple2<String, Double>> ctx) throws Exception {
        while (flag){
            //随机生成分类和金额
            int index = random.nextInt(categorys.length);//[0~length) ==> [0~length-1]
            String category = categorys[index];//获取的随机分类
            double price = random.nextDouble() * 100;//注意nextDouble生成的是[0~1)之间的随机数,*100之后表示[0~100)
            ctx.collect(Tuple2.of(category,price));
            Thread.sleep(20);
        }
    }

    @Override
    public void cancel() {
        flag = false;
    }
}
```

#### 编码步骤:

1. env
2. source
3. transformation
   1. 定义大小为一天的窗口,第二个参数表示中国使用的UTC+08:00时区比UTC时间早
      .keyBy(0)
      window(TumblingProcessingTimeWindows.of(Time.days(1), Time.hours(-8))
   2. 定义一个1s的触发器
      .trigger(ContinuousProcessingTimeTrigger.of(Time.seconds(1)))
   3. 聚合结果.aggregate(new PriceAggregate(), new WindowResult());
   4. 看一下聚合的结果
      CategoryPojo(category=男装, totalPrice=17225.26, dateTime=2020-10-20 08:04:12)
4. 使用上面聚合的结果,实现业务需求:
   result.keyBy("dateTime")
   //每秒钟更新一次统计结果
   .window(TumblingProcessingTimeWindows.of(Time.seconds(1)))
   //在ProcessWindowFunction中实现该复杂业务逻辑
   .process(new WindowResultProcess());
   1. 实时计算出当天零点截止到当前时间的销售总额
   2. 计算出各个分类的销售top3
   3. 每秒钟更新一次统计结果
5. execute

#### 代码实现

```
package cn.itcast.action;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.apache.flink.api.common.functions.AggregateFunction;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple1;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.functions.windowing.ProcessWindowFunction;
import org.apache.flink.streaming.api.functions.windowing.WindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.triggers.ContinuousProcessingTimeTrigger;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Author itcast
 * Desc
 * 模拟双11商品实时交易大屏统计分析
 */
public class DoubleElevenBigScreem {
    public static void main(String[] args) throws Exception{
        //编码步骤:
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);//学习测试方便观察

        //2.source
        //模拟实时订单信息
        DataStreamSource<Tuple2<String, Double>> sourceDS = env.addSource(new MySource());

        /*
        注意:需求如下：
        -1.实时计算出11月11日00:00:00零点开始截止到当前时间的销售总额
        -2.计算出各个分类的销售额top3
        -3.每1秒钟更新一次统计结果
        如果使用之前学习的简单的timeWindow(Time size窗口大小, Time slide滑动间隔)来处理,
        如xxx.timeWindow(24小时,1s),计算的是需求中的吗?
        不是!如果使用之前的做法那么是完成不了需求的,因为:
        如11月11日00:00:01计算的是11月10号[00:00:00~23:59:59s]的数据
        而我们应该要计算的是:11月11日00:00:00~11月11日00:00:01
        所以不能使用之前的简单做法!*/

        //3.transformation
        //.keyBy(0)
        SingleOutputStreamOperator<CategoryPojo> tempAggResult = sourceDS.keyBy(0)
                //3.1定义大小为一天的窗口,第二个参数表示中国使用的UTC+08:00时区比UTC时间早
                /*
                of(Time 窗口大小, Time 带时间校准的从哪开始)源码中有解释:
                如果您居住在不使用UTC±00：00时间的地方，例如使用UTC + 08：00的中国，并且您需要一个大小为一天的时间窗口，
                并且窗口从当地时间的每00:00:00开始，您可以使用of(Time.days(1)，Time.hours(-8))
                注意:该代码如果在11月11日运行就会从11月11日00:00:00开始记录直到11月11日23:59:59的1天的数据
                注意:我们这里简化了没有把之前的Watermaker那些代码拿过来,所以直接ProcessingTime
                */
                .window(TumblingProcessingTimeWindows.of(Time.days(1), Time.hours(-8)))//仅仅只定义了一个窗口大小
                //3.2定义一个1s的触发器
                .trigger(ContinuousProcessingTimeTrigger.of(Time.seconds(1)))
                //上面的3.1和3.2相当于自定义窗口的长度和触发时机
                //3.3聚合结果.aggregate(new PriceAggregate(), new WindowResult());
                //.sum(1)//以前的写法用的默认的聚合和收集
                //现在可以自定义如何对price进行聚合,并自定义聚合结果用怎样的格式进行收集
                .aggregate(new PriceAggregate(), new WindowResult());
        //3.4看一下初步聚合的结果
        tempAggResult.print("初步聚合结果");
        //CategoryPojo(category=运动, totalPrice=118.69, dateTime=2020-10-20 08:04:12)
        //上面的结果表示:当前各个分类的销售总额

        /*
        注意:需求如下：
        -1.实时计算出11月11日00:00:00零点开始截止到当前时间的销售总额
        -2.计算出各个分类的销售额top3
        -3.每1秒钟更新一次统计结果
         */
        //4.使用上面初步聚合的结果,实现业务需求,并sink
        tempAggResult.keyBy("dateTime")//按照时间分组是因为需要每1s更新截至到当前时间的销售总额
        //每秒钟更新一次统计结果
                //Time size 为1s,表示计算最近1s的数据
        .window(TumblingProcessingTimeWindows.of(Time.seconds(1)))
        //在ProcessWindowFunction中实现该复杂业务逻辑,一次性将需求1和2搞定
        //-1.实时计算出11月11日00:00:00零点开始截止到当前时间的销售总额
        //-2.计算出各个分类的销售额top3
        //-3.每1秒钟更新一次统计结果
       .process(new WindowResultProcess());//window后的process方法可以处理复杂逻辑


        //5.execute
        env.execute();
    }

    /**
     * 自定义数据源实时产生订单数据Tuple2<分类, 金额>
     */
    public static class MySource implements SourceFunction<Tuple2<String, Double>>{
        private boolean flag = true;
        private String[] categorys = {"女装", "男装","图书", "家电","洗护", "美妆","运动", "游戏","户外", "家具","乐器", "办公"};
        private Random random = new Random();

        @Override
        public void run(SourceContext<Tuple2<String, Double>> ctx) throws Exception {
            while (flag){
                //随机生成分类和金额
                int index = random.nextInt(categorys.length);//[0~length) ==> [0~length-1]
                String category = categorys[index];//获取的随机分类
                double price = random.nextDouble() * 100;//注意nextDouble生成的是[0~1)之间的随机数,*100之后表示[0~100)
                ctx.collect(Tuple2.of(category,price));
                Thread.sleep(20);
            }
        }

        @Override
        public void cancel() {
            flag = false;
        }
    }

    /**
     * 自定义价格聚合函数,其实就是对price的简单sum操作
     * AggregateFunction<IN, ACC, OUT>
     * AggregateFunction<Tuple2<String, Double>, Double, Double>
     *
     */
    private static class PriceAggregate implements AggregateFunction<Tuple2<String, Double>, Double, Double> {
        //初始化累加器为0
        @Override
        public Double createAccumulator() {
            return 0D; //D表示Double,L表示long
        }

        //把price往累加器上累加
        @Override
        public Double add(Tuple2<String, Double> value, Double accumulator) {
            return value.f1 + accumulator;
        }

        //获取累加结果
        @Override
        public Double getResult(Double accumulator) {
            return accumulator;
        }

        //各个subTask的结果合并
        @Override
        public Double merge(Double a, Double b) {
            return a + b;
        }
    }

    /**
     * 用于存储聚合的结果
     */
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class CategoryPojo {
        private String category;//分类名称
        private double totalPrice;//该分类总销售额
        private String dateTime;// 截止到当前时间的时间,本来应该是EventTime,但是我们这里简化了直接用当前系统时间即可
    }

    /**
     * 自定义WindowFunction,实现如何收集窗口结果数据
     * interface WindowFunction<IN, OUT, KEY, W extends Window>
     * interface WindowFunction<Double, CategoryPojo, Tuple的真实类型就是String就是分类, W extends Window>
     */
    private static class WindowResult implements WindowFunction<Double, CategoryPojo, Tuple, TimeWindow> {
        //定义一个时间格式化工具用来将当前时间(双十一那天订单的时间)转为String格式
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        @Override
        public void apply(Tuple tuple, TimeWindow window, Iterable<Double> input, Collector<CategoryPojo> out) throws Exception {
            String category = ((Tuple1<String>) tuple).f0;

            Double price = input.iterator().next();
            //为了后面项目铺垫,使用一下用Bigdecimal来表示精确的小数
            BigDecimal bigDecimal = new BigDecimal(price);
            //setScale设置精度保留2位小数,
            double roundPrice = bigDecimal.setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();//四舍五入

            long currentTimeMillis = System.currentTimeMillis();
            String dateTime = df.format(currentTimeMillis);

            CategoryPojo categoryPojo = new CategoryPojo(category, roundPrice, dateTime);
            out.collect(categoryPojo);
        }
    }

    /**
     * 实现ProcessWindowFunction
     * abstract class ProcessWindowFunction<IN, OUT, KEY, W extends Window>
     * abstract class ProcessWindowFunction<CategoryPojo, Object, Tuple就是String类型的dateTime, TimeWindow extends Window>
     *
     * 把各个分类的总价加起来，就是全站的总销量金额，
     * 然后我们同时使用优先级队列计算出分类销售的Top3，
     * 最后打印出结果，在实际中我们可以把这个结果数据存储到hbase或者redis中，以供前端的实时页面展示。
     */
    private static class WindowResultProcess extends ProcessWindowFunction<CategoryPojo, Object, Tuple, TimeWindow> {
        @Override
        public void process(Tuple tuple, Context context, Iterable<CategoryPojo> elements, Collector<Object> out) throws Exception {
            String dateTime = ((Tuple1<String>)tuple).f0;
            //Java中的大小顶堆可以使用优先级队列来实现
            //https://blog.csdn.net/hefenglian/article/details/81807527
            //注意:
            // 小顶堆用来计算:最大的topN
            // 大顶堆用来计算:最小的topN
            Queue<CategoryPojo> queue = new PriorityQueue<>(3,//初识容量
                    //正常的排序,就是小的在前,大的在后,也就是c1>c2的时候返回1,也就是小顶堆
                    (c1, c2) -> c1.getTotalPrice() >= c2.getTotalPrice() ? 1 : -1);

            //在这里我们要完成需求:
            // * -1.实时计算出11月11日00:00:00零点开始截止到当前时间的销售总额,其实就是把之前的初步聚合的price再累加!
            double totalPrice = 0D;
            double roundPrice = 0D;
            Iterator<CategoryPojo> iterator = elements.iterator();
            for (CategoryPojo element : elements) {
                double price = element.totalPrice;//某个分类的总销售额
                totalPrice += price;
                BigDecimal bigDecimal = new BigDecimal(totalPrice);
                roundPrice = bigDecimal.setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();//四舍五入
            // * -2.计算出各个分类的销售额top3,其实就是对各个分类的price进行排序取前3
                //注意:我们只需要top3,也就是只关注最大的前3个的顺序,剩下不管!所以不要使用全局排序,只需要做最大的前3的局部排序即可
                //那么可以使用小顶堆,把小的放顶上
                // c:80
                // b:90
                // a:100
                //那么来了一个数,和最顶上的比,如d,
                //if(d>顶上),把顶上的去掉,把d放上去,再和b,a比较并排序,保证顶上是最小的
                //if(d<=顶上),不用变
                if (queue.size() < 3) {//小顶堆size<3,说明数不够,直接放入
                    queue.add(element);
                }else{//小顶堆size=3,说明,小顶堆满了,进来一个需要比较
                    //"取出"顶上的(不是移除)
                    CategoryPojo top = queue.peek();
                    if(element.totalPrice > top.totalPrice){
                        //queue.remove(top);//移除指定的元素
                        queue.poll();//移除顶上的元素
                        queue.add(element);
                    }
                }
            }
            // * -3.每1秒钟更新一次统计结果,可以直接打印/sink,也可以收集完结果返回后再打印,
            //   但是我们这里一次性处理了需求1和2的两种结果,不好返回,所以直接输出!
            //对queue中的数据逆序
            //各个分类的销售额top3
            List<String> top3Result = queue.stream()
                    .sorted((c1, c2) -> c1.getTotalPrice() > c2.getTotalPrice() ? -1 : 1)//逆序
                    .map(c -> "(分类：" + c.getCategory() + " 销售总额：" + c.getTotalPrice() + ")")
                    .collect(Collectors.toList());
            System.out.println("时间 ： " + dateTime + "  总价 : " + roundPrice + " top3:\n" + StringUtils.join(top3Result, ",\n"));
            System.out.println("-------------");

        }
    }
}
```

#### 效果

![image.png](https://image.hyly.net/i/2025/09/28/4810a56058b296120a4e4c5774f0e6fa-0.webp)

### Flink实现订单自动好评

#### 需求

![image.png](https://image.hyly.net/i/2025/09/28/243a3d2e4e5b52558e64cca600f69be3-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/756eb335b6a917a081e1ed97142504b6-0.webp)

在电商领域会有这么一个场景，如果用户买了商品，在订单完成之后，一定时间之内没有做出评价，系统自动给与五星好评，我们今天主要使用Flink的定时器来简单实现这一功能。

#### 数据

自定义source模拟生成一些订单数据.
在这里，我们生了一个最简单的二元组Tuple3,包含用户id,订单id和订单完成时间三个字段.

```
/**
 * 自定义source实时产生订单数据Tuple3<用户id,订单id, 订单生成时间>
 */
public static class MySource implements SourceFunction<Tuple3<String, String, Long>> {
    private boolean flag = true;
    @Override
    public void run(SourceContext<Tuple3<String, String, Long>> ctx) throws Exception {
        Random random = new Random();
        while (flag) {
            String userId = random.nextInt(5) + "";
            String orderId = UUID.randomUUID().toString();
            long currentTimeMillis = System.currentTimeMillis();
            ctx.collect(Tuple3.of(userId, orderId, currentTimeMillis));
            Thread.sleep(500);
        }
    }

    @Override
    public void cancel() {
        flag = false;
    }
}
```

#### 编码步骤

1. env
2. source
3. transformation
   设置经过interval毫秒用户未对订单做出评价，自动给与好评.为了演示方便，设置5s的时间
   long interval = 5000L;
   分组后使用自定义KeyedProcessFunction完成定时判断超时订单并自动好评
   dataStream.keyBy(0).process(new TimerProcessFuntion(interval));
   1. 定义MapState类型的状态，key是订单号，value是订单完成时间
   2. 创建MapState
      MapStateDescriptor&#x3c;String, Long> mapStateDesc =
      new MapStateDescriptor&#x3c;>("mapStateDesc", String.class, Long.class);
      mapState = getRuntimeContext().getMapState(mapStateDesc);
   3. 注册定时器
      mapState.put(value.f0, value.f1);
      ctx.timerService().registerProcessingTimeTimer(value.f1 + interval);
   4. 定时器被触发时执行并输出结果
4. sink
5. execute

#### 代码实现

```
package cn.itcast.action;

import org.apache.flink.api.common.state.MapState;
import org.apache.flink.api.common.state.MapStateDescriptor;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple3;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.KeyedProcessFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.util.Collector;

import java.util.Iterator;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

/**
 * Author itcast
 * Desc
 * 在电商领域会有这么一个场景，如果用户买了商品，在订单完成之后，一定时间之内没有做出评价，系统自动给与五星好评，
 * 我们今天主要使用Flink的定时器来简单实现这一功能。
 */
public class OrderAutomaticFavorableComments {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);
        //2.source
        DataStreamSource<Tuple3<String, String, Long>> sourceDS = env.addSource(new MySource());
        //这里可以使用订单生成时间作为事件时间,代码和之前的一样
        //这里不作为重点,所以简化处理!

        //3.transformation
        //设置经过interval用户未对订单做出评价，自动给与好评.为了演示方便，设置5000ms的时间
        long interval = 5000L;
        //分组后使用自定义KeyedProcessFunction完成定时判断超时订单并自动好评
        sourceDS.keyBy(0) //实际中可以对用户id进行分组
                //KeyedProcessFunction:进到窗口的数据是分好组的
                //ProcessFunction:进到窗口的数据是不区分分组的
                .process(new TimerProcessFuntion(interval));
        //4.execute
        env.execute();
    }

    /**
     * 自定义source实时产生订单数据Tuple2<订单id, 订单生成时间>
     */
    public static class MySource implements SourceFunction<Tuple3<String, String, Long>> {
        private boolean flag = true;
        @Override
        public void run(SourceContext<Tuple3<String, String, Long>> ctx) throws Exception {
            Random random = new Random();
            while (flag) {
                String userId = random.nextInt(5) + "";
                String orderId = UUID.randomUUID().toString();
                long currentTimeMillis = System.currentTimeMillis();
                ctx.collect(Tuple3.of(userId, orderId, currentTimeMillis));
                Thread.sleep(500);
            }
        }

        @Override
        public void cancel() {
            flag = false;
        }
    }

    /**
     * 自定义处理函数用来给超时订单做自动好评!
     * 如一个订单进来:<订单id, 2020-10-10 12:00:00>
     * 那么该订单应该在12:00:00 + 5s 的时候超时!
     * 所以我们可以在订单进来的时候设置一个定时器,在订单时间 + interval的时候触发!
     * KeyedProcessFunction<K, I, O>
     * KeyedProcessFunction<Tuple就是String, Tuple3<用户id, 订单id, 订单生成时间>, Object>
     */
    public static class TimerProcessFuntion extends KeyedProcessFunction<Tuple, Tuple3<String, String, Long>, Object> {
        private long interval;

        public TimerProcessFuntion(long interval) {
            this.interval = interval;//传过来的是5000ms/5s
        }

        //3.1定义MapState类型的状态，key是订单号，value是订单完成时间
        //定义一个状态用来记录订单信息
        //MapState<订单id, 订单完成时间>
        private MapState<String, Long> mapState;

        //3.2初始化MapState
        @Override
        public void open(Configuration parameters) throws Exception {
            //创建状态描述器
            MapStateDescriptor<String, Long> mapStateDesc = new MapStateDescriptor<>("mapState", String.class, Long.class);
            //根据状态描述器初始化状态
            mapState = getRuntimeContext().getMapState(mapStateDesc);
        }


        //3.3注册定时器
        //处理每一个订单并设置定时器
        @Override
        public void processElement(Tuple3<String, String, Long> value, Context ctx, Collector<Object> out) throws Exception {
            mapState.put(value.f1, value.f2);
            //如一个订单进来:<订单id, 2020-10-10 12:00:00>
            //那么该订单应该在12:00:00 + 5s 的时候超时!
            //在订单进来的时候设置一个定时器,在订单时间 + interval的时候触发!!!
            ctx.timerService().registerProcessingTimeTimer(value.f2 + interval);
        }

        //3.4定时器被触发时执行并输出结果并sink
        @Override
        public void onTimer(long timestamp, OnTimerContext ctx, Collector<Object> out) throws Exception {
            //能够执行到这里说明订单超时了!超时了得去看看订单是否评价了(实际中应该要调用外部接口/方法查订单系统!,我们这里没有,所以模拟一下)
            //没有评价才给默认好评!并直接输出提示!
            //已经评价了,直接输出提示!
            Iterator<Map.Entry<String, Long>> iterator = mapState.iterator();
            while (iterator.hasNext()) {
                Map.Entry<String, Long> entry = iterator.next();
                String orderId = entry.getKey();
                //调用订单系统查询是否已经评价
                boolean result = isEvaluation(orderId);
                if (result) {//已评价
                    System.out.println("订单(orderid: " + orderId + ")在" + interval + "毫秒时间内已经评价，不做处理");
                } else {//未评价
                    System.out.println("订单(orderid: " + orderId + ")在" + interval + "毫秒时间内未评价，系统自动给了默认好评!");
                    //实际中还需要调用订单系统将该订单orderId设置为5星好评!
                }
                //从状态中移除已经处理过的订单,避免重复处理
                iterator.remove();
            }
        }

        //在生产环境下，可以去查询相关的订单系统.
        private boolean isEvaluation(String key) {
            return key.hashCode() % 2 == 0;//随机返回订单是否已评价
        }
    }
}
```

#### 效果

![image.png](https://image.hyly.net/i/2025/09/28/c2a1b3b5ec34d79143222d42bb11d150-0.webp)

## Flink高级特性和新特性

### BroadcastState

#### BroadcastState介绍

在开发过程中，如果遇到需要下发/广播配置、规则等低吞吐事件流到下游所有 task 时，就可以使用 Broadcast State。Broadcast State 是 Flink 1.5 引入的新特性。

下游的 task 接收这些配置、规则并保存为 BroadcastState, 将这些配置应用到另一个数据流的计算中 。

**场景举例**

1)动态更新计算规则: 如事件流需要根据最新的规则进行计算，则可将规则作为广播状态广播到下游Task中。
2)实时增加额外字段: 如事件流需要实时增加用户的基础信息，则可将用户的基础信息作为广播状态广播到下游Task中。

**API介绍**

首先创建一个Keyed 或Non-Keyed 的DataStream，
然后再创建一个BroadcastedStream，
最后通过DataStream来连接(调用connect 方法)到Broadcasted Stream 上，
这样实现将BroadcastState广播到Data Stream 下游的每个Task中。

1.如果DataStream是Keyed Stream ，则连接到Broadcasted Stream 后， 添加处理ProcessFunction 时需要使用KeyedBroadcastProcessFunction 来实现， 下面是KeyedBroadcastProcessFunction 的API，代码如下所示：

```
public abstract class KeyedBroadcastProcessFunction<KS, IN1, IN2, OUT> extends BaseBroadcastProcessFunction {
    public abstract void processElement(final IN1 value, final ReadOnlyContext ctx, final Collector<OUT> out) throws Exception;
    public abstract void processBroadcastElement(final IN2 value, final Context ctx, final Collector<OUT> out) throws Exception;
}
```

上面泛型中的各个参数的含义，说明如下：
**KS：**表示Flink 程序从最上游的Source Operator 开始构建Stream，当调用keyBy 时所依赖的Key 的类型；
**IN1：**表示非Broadcast 的Data Stream 中的数据记录的类型；
**IN2：**表示Broadcast Stream 中的数据记录的类型；
**OUT：**表示经过KeyedBroadcastProcessFunction 的processElement()和processBroadcastElement()方法处理后输出结果数据记录的类型。

2.如果Data Stream 是Non-Keyed Stream，则连接到Broadcasted Stream 后，添加处理ProcessFunction 时需要使用BroadcastProcessFunction 来实现， 下面是BroadcastProcessFunction 的API，代码如下所示：

```
public abstract class BroadcastProcessFunction<IN1, IN2, OUT> extends BaseBroadcastProcessFunction {
		public abstract void processElement(final IN1 value, final ReadOnlyContext ctx, final Collector<OUT> out) throws Exception;
		public abstract void processBroadcastElement(final IN2 value, final Context ctx, final Collector<OUT> out) throws Exception;
}
```

上面泛型中的各个参数的含义，与前面KeyedBroadcastProcessFunction 的泛型类型中的后3 个含义相同，只是没有调用keyBy 操作对原始Stream 进行分区操作，就不需要KS 泛型参数。
具体如何使用上面的BroadcastProcessFunction，接下来我们会在通过实际编程，来以使用KeyedBroadcastProcessFunction 为例进行详细说明。

**注意事项**

1) Broadcast State 是Map 类型，即K-V 类型。
2) Broadcast State 只有在广播的一侧, 即在BroadcastProcessFunction 或KeyedBroadcastProcessFunction 的processBroadcastElement 方法中可以修改。在非广播的一侧， 即在BroadcastProcessFunction 或KeyedBroadcastProcessFunction 的processElement 方法中只读。
3) Broadcast State 中元素的顺序，在各Task 中可能不同。基于顺序的处理，需要注意。
4) Broadcast State 在Checkpoint 时，每个Task 都会Checkpoint 广播状态。
5) Broadcast State 在运行时保存在内存中，目前还不能保存在RocksDB State Backend 中。

#### 需求-实现配置动态更新

![image.png](https://image.hyly.net/i/2025/09/28/6c5909c3aaae59444af0d57a8a1c0e63-0.webp)

实时过滤出配置中的用户，并在事件流中补全这批用户的基础信息。

事件流：表示用户在某个时刻浏览或点击了某个商品，格式如下。

```
{"userID": "user_3", "eventTime": "2019-08-17 12:19:47", "eventType": "browse", "productID": 1}
{"userID": "user_2", "eventTime": "2019-08-17 12:19:48", "eventType": "click", "productID": 1}
```

配置数据: 表示用户的详细信息，在Mysql中，如下。

```
DROP TABLE IF EXISTS `user_info`;
CREATE TABLE `user_info`  (
  `userID` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `userName` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `userAge` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`userID`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;
-- ----------------------------
-- Records of user_info
-- ----------------------------
INSERT INTO `user_info` VALUES ('user_1', '张三', 10);
INSERT INTO `user_info` VALUES ('user_2', '李四', 20);
INSERT INTO `user_info` VALUES ('user_3', '王五', 30);
INSERT INTO `user_info` VALUES ('user_4', '赵六', 40);
SET FOREIGN_KEY_CHECKS = 1;
```

输出结果:

```
 (user_3,2019-08-17 12:19:47,browse,1,王五,33)
(user_2,2019-08-17 12:19:48,click,1,李四,20)
```

#### 编码步骤

1. env
2. source
   1. 构建实时数据事件流-自定义随机 &#x3c;userID, eventTime, eventType, productID>
   2. 构建配置流-从MySQL   &#x3c;用户id,&#x3c;姓名,年龄>>
3. transformation
   1. 定义状态描述器

```
MapStateDescriptor<Void, Map<String, Tuple2<String, Integer>>> descriptor =
new MapStateDescriptor<>("config",Types.VOID, Types.MAP(Types.STRING, Types.TUPLE(Types.STRING, Types.INT)));
```

3.2.广播配置流

```
BroadcastStream<Map<String, Tuple2<String, Integer>>> broadcastDS = configDS.broadcast(descriptor);
```

3.3将事件流和广播流进行连接

```
BroadcastConnectedStream<Tuple4<String, String, String, Integer>, Map<String, Tuple2<String, Integer>>> connectDS =eventDS.connect(broadcastDS);
```

3.4处理连接后的流-根据配置流补全事件流中的用户的信息

4. sink
5. execute

#### 代码实现

```
package cn.itcast.action;

import org.apache.flink.api.common.state.BroadcastState;
import org.apache.flink.api.common.state.MapStateDescriptor;
import org.apache.flink.api.common.state.ReadOnlyBroadcastState;
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.tuple.Tuple4;
import org.apache.flink.api.java.tuple.Tuple6;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.BroadcastConnectedStream;
import org.apache.flink.streaming.api.datastream.BroadcastStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.co.BroadcastProcessFunction;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.util.Collector;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Author itcast
 * Desc
 * 需求:
 * 使用Flink的BroadcastState来完成
 * 事件流和配置流(需要广播为State)的关联,并实现配置的动态更新!
 */
public class BroadcastStateConfigUpdate {
    public static void main(String[] args) throws Exception{
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.source
        //-1.构建实时的自定义随机数据事件流-数据源源不断产生,量会很大
        //<userID, eventTime, eventType, productID>
        DataStreamSource<Tuple4<String, String, String, Integer>> eventDS = env.addSource(new MySource());

        //-2.构建配置流-从MySQL定期查询最新的,数据量较小
        //<用户id,<姓名,年龄>>
        DataStreamSource<Map<String, Tuple2<String, Integer>>> configDS = env.addSource(new MySQLSource());

        //3.transformation
        //-1.定义状态描述器-准备将配置流作为状态广播
        MapStateDescriptor<Void, Map<String, Tuple2<String, Integer>>> descriptor =
                new MapStateDescriptor<>("config", Types.VOID, Types.MAP(Types.STRING, Types.TUPLE(Types.STRING, Types.INT)));
        //-2.将配置流根据状态描述器广播出去,变成广播状态流
        BroadcastStream<Map<String, Tuple2<String, Integer>>> broadcastDS = configDS.broadcast(descriptor);

        //-3.将事件流和广播流进行连接
        BroadcastConnectedStream<Tuple4<String, String, String, Integer>, Map<String, Tuple2<String, Integer>>> connectDS =eventDS.connect(broadcastDS);
        //-4.处理连接后的流-根据配置流补全事件流中的用户的信息
        SingleOutputStreamOperator<Tuple6<String, String, String, Integer, String, Integer>> result = connectDS
                //BroadcastProcessFunction<IN1, IN2, OUT>
                .process(new BroadcastProcessFunction<
                //<userID, eventTime, eventType, productID> //事件流
                Tuple4<String, String, String, Integer>,
                //<用户id,<姓名,年龄>> //广播流
                Map<String, Tuple2<String, Integer>>,
                //<用户id，eventTime，eventType，productID，姓名，年龄> //需要收集的数据
                Tuple6<String, String, String, Integer, String, Integer>>() {

            //处理事件流中的元素
            @Override
            public void processElement(Tuple4<String, String, String, Integer> value, ReadOnlyContext ctx, Collector<Tuple6<String, String, String, Integer, String, Integer>> out) throws Exception {
                //取出事件流中的userId
                String userId = value.f0;
                //根据状态描述器获取广播状态
                ReadOnlyBroadcastState<Void, Map<String, Tuple2<String, Integer>>> broadcastState = ctx.getBroadcastState(descriptor);
                if (broadcastState != null) {
                    //取出广播状态中的map<用户id,<姓名,年龄>>
                    Map<String, Tuple2<String, Integer>> map = broadcastState.get(null);
                    if (map != null) {
                        //通过userId取map中的<姓名,年龄>
                        Tuple2<String, Integer> tuple2 = map.get(userId);
                        //取出tuple2中的姓名和年龄
                        String userName = tuple2.f0;
                        Integer userAge = tuple2.f1;
                        out.collect(Tuple6.of(userId, value.f1, value.f2, value.f3, userName, userAge));
                    }
                }
            }

            //处理广播流中的元素
            @Override
            public void processBroadcastElement(Map<String, Tuple2<String, Integer>> value, Context ctx, Collector<Tuple6<String, String, String, Integer, String, Integer>> out) throws Exception {
                //value就是MySQLSource中每隔一段时间获取到的最新的map数据
                //先根据状态描述器获取历史的广播状态
                BroadcastState<Void, Map<String, Tuple2<String, Integer>>> broadcastState = ctx.getBroadcastState(descriptor);
                //再清空历史状态数据
                broadcastState.clear();
                //最后将最新的广播流数据放到state中（更新状态数据）
                broadcastState.put(null, value);
            }
        });
        //4.sink
        result.print();
        //5.execute
        env.execute();
    }

    /**
     * <userID, eventTime, eventType, productID>
     */
    public static class MySource implements SourceFunction<Tuple4<String, String, String, Integer>>{
        private boolean isRunning = true;
        @Override
        public void run(SourceContext<Tuple4<String, String, String, Integer>> ctx) throws Exception {
            Random random = new Random();
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            while (isRunning){
                int id = random.nextInt(4) + 1;
                String user_id = "user_" + id;
                String eventTime = df.format(new Date());
                String eventType = "type_" + random.nextInt(3);
                int productId = random.nextInt(4);
                ctx.collect(Tuple4.of(user_id,eventTime,eventType,productId));
                Thread.sleep(500);
            }
        }

        @Override
        public void cancel() {
            isRunning = false;
        }
    }
    /**
     * <用户id,<姓名,年龄>>
     */
    public static class MySQLSource extends RichSourceFunction<Map<String, Tuple2<String, Integer>>> {
        private boolean flag = true;
        private Connection conn = null;
        private PreparedStatement ps = null;
        private ResultSet rs = null;

        @Override
        public void open(Configuration parameters) throws Exception {
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/bigdata", "root", "root");
            String sql = "select `userID`, `userName`, `userAge` from `user_info`";
            ps = conn.prepareStatement(sql);
        }
        @Override
        public void run(SourceContext<Map<String, Tuple2<String, Integer>>> ctx) throws Exception {
            while (flag){
                Map<String, Tuple2<String, Integer>> map = new HashMap<>();
                ResultSet rs = ps.executeQuery();
                while (rs.next()){
                    String userID = rs.getString("userID");
                    String userName = rs.getString("userName");
                    int userAge = rs.getInt("userAge");
                    //Map<String, Tuple2<String, Integer>>
                    map.put(userID,Tuple2.of(userName,userAge));
                }
                ctx.collect(map);
                Thread.sleep(5000);//每隔5s更新一下用户的配置信息!
            }
        }
        @Override
        public void cancel() {
            flag = false;
        }
        @Override
        public void close() throws Exception {
            if (conn != null) conn.close();
            if (ps != null) ps.close();
            if (rs != null) rs.close();
        }
    }
}
```

### 双流Join

#### 介绍

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/joining.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/joining.html)

[https://zhuanlan.zhihu.com/p/340560908](https://zhuanlan.zhihu.com/p/340560908)

[https://blog.csdn.net/andyonlines/article/details/108173259](https://blog.csdn.net/andyonlines/article/details/108173259)

![image.png](https://image.hyly.net/i/2025/09/28/37a6f4343f523416a9e9aad23b76269a-0.webp)

双流Join是Flink面试的高频问题。一般情况下说明以下几点就可以hold了：

Join大体分类只有两种：Window Join和Interval Join。

1. Window Join又可以根据Window的类型细分出3种：Tumbling Window Join、Sliding Window Join、Session Widnow Join。
   Windows类型的join都是利用window的机制，先将数据缓存在Window State中，当窗口触发计算时，执行join操作；
2. interval join也是利用state存储数据再处理，区别在于state中的数据有失效机制，依靠数据触发数据清理；

目前Stream join的结果是数据的笛卡尔积；

#### Window Join

**Tumbling Window Join**

执行翻滚窗口联接时，具有公共键和公共翻滚窗口的所有元素将作为成对组合联接，并传递给JoinFunction或FlatJoinFunction。因为它的行为类似于内部连接，所以一个流中的元素在其滚动窗口中没有来自另一个流的元素，因此不会被发射！

如图所示，我们定义了一个大小为2毫秒的翻滚窗口，结果窗口的形式为[0,1]、[2,3]、。。。。该图显示了每个窗口中所有元素的成对组合，这些元素将传递给JoinFunction。注意，在翻滚窗口[6,7]中没有发射任何东西，因为绿色流中不存在与橙色元素⑥和⑦结合的元素。

![image.png](https://image.hyly.net/i/2025/09/28/a5f5db05adf932627a6bb25462fcbb91-0.webp)

```
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
 ...
DataStream<Integer> orangeStream = ...DataStream<Integer> greenStream = ...
orangeStream.join(greenStream)
    .where(<KeySelector>)
    .equalTo(<KeySelector>)
    .window(TumblingEventTimeWindows.of(Time.milliseconds(2)))
    .apply (new JoinFunction<Integer, Integer, String> (){
        @Override
        public String join(Integer first, Integer second) {
            return first + "," + second;
        }
    });
```

**Sliding Window Join**

在执行滑动窗口联接时，具有公共键和公共滑动窗口的所有元素将作为成对组合联接，并传递给JoinFunction或FlatJoinFunction。在当前滑动窗口中，一个流的元素没有来自另一个流的元素，则不会发射！请注意，某些元素可能会连接到一个滑动窗口中，但不会连接到另一个滑动窗口中！

在本例中，我们使用大小为2毫秒的滑动窗口，并将其滑动1毫秒，从而产生滑动窗口[-1，0]，[0,1]，[1,2]，[2,3]…。x轴下方的连接元素是传递给每个滑动窗口的JoinFunction的元素。在这里，您还可以看到，例如，在窗口[2,3]中，橙色②与绿色③连接，但在窗口[1,2]中没有与任何对象连接。

![image.png](https://image.hyly.net/i/2025/09/28/03fbc8025646de648b91881520788c01-0.webp)

```
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.streaming.api.windowing.assigners.SlidingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
...
DataStream<Integer> orangeStream = ...DataStream<Integer> greenStream = ...
orangeStream.join(greenStream)
    .where(<KeySelector>)
    .equalTo(<KeySelector>)
    .window(SlidingEventTimeWindows.of(Time.milliseconds(2) /* size */, Time.milliseconds(1) /* slide */))
    .apply (new JoinFunction<Integer, Integer, String> (){
        @Override
        public String join(Integer first, Integer second) {
            return first + "," + second;
        }
    });
```

**Session Window Join**

在执行会话窗口联接时，具有相同键（当“组合”时满足会话条件）的所有元素以成对组合方式联接，并传递给JoinFunction或FlatJoinFunction。同样，这执行一个内部连接，所以如果有一个会话窗口只包含来自一个流的元素，则不会发出任何输出！

在这里，我们定义了一个会话窗口连接，其中每个会话被至少1ms的间隔分割。有三个会话，在前两个会话中，来自两个流的连接元素被传递给JoinFunction。在第三个会话中，绿色流中没有元素，所以⑧和⑨没有连接！

![image.png](https://image.hyly.net/i/2025/09/28/993e7a741fdd94e66742c5ba0329f68b-0.webp)

```
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.streaming.api.windowing.assigners.EventTimeSessionWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
 ...
DataStream<Integer> orangeStream = ...DataStream<Integer> greenStream = ...
orangeStream.join(greenStream)
    .where(<KeySelector>)
    .equalTo(<KeySelector>)
    .window(EventTimeSessionWindows.withGap(Time.milliseconds(1)))
    .apply (new JoinFunction<Integer, Integer, String> (){
        @Override
        public String join(Integer first, Integer second) {
            return first + "," + second;
        }
    });
```

#### Interval Join

前面学习的Window Join必须要在一个Window中进行JOIN，那如果没有Window如何处理呢？
interval join也是使用相同的key来join两个流（流A、流B），
并且流B中的元素中的时间戳，和流A元素的时间戳，有一个时间间隔。
b.timestamp ∈ [a.timestamp + lowerBound; a.timestamp + upperBound]
or
a.timestamp + lowerBound &#x3c;= b.timestamp &#x3c;= a.timestamp + upperBound

也就是：
流B的元素的时间戳 ≥ 流A的元素时间戳 + 下界，且，流B的元素的时间戳 ≤ 流A的元素时间戳 + 上界。

![image.png](https://image.hyly.net/i/2025/09/28/046bcc630ea2227645fde304596c7474-0.webp)

在上面的示例中，我们将两个流“orange”和“green”连接起来，其下限为-2毫秒，上限为+1毫秒。默认情况下，这些边界是包含的，但是可以应用.lowerBoundExclusive（）和.upperBoundExclusive来更改行为
orangeElem.ts + lowerBound &#x3c;= greenElem.ts &#x3c;= orangeElem.ts + upperBound

```
import org.apache.flink.api.java.functions.KeySelector;
import org.apache.flink.streaming.api.functions.co.ProcessJoinFunction;
import org.apache.flink.streaming.api.windowing.time.Time;
...
DataStream<Integer> orangeStream = ...DataStream<Integer> greenStream = ...
orangeStream
    .keyBy(<KeySelector>)
    .intervalJoin(greenStream.keyBy(<KeySelector>))
    .between(Time.milliseconds(-2), Time.milliseconds(1))
    .process (new ProcessJoinFunction<Integer, Integer, String(){

        @Override
        public void processElement(Integer left, Integer right, Context ctx, Collector<String> out) {
            out.collect(first + "," + second);
        }
    });
```

#### 代码演示

**需求**

来做个案例：
使用两个指定Source模拟数据，一个Source是订单明细，一个Source是商品数据。我们通过window join，将数据关联到一起。

**思路**

1、Window Join首先需要使用where和equalTo指定使用哪个key来进行关联，此处我们通过应用方法，基于GoodsId来关联两个流中的元素。
2、设置5秒的滚动窗口，流的元素关联都会在这个5秒的窗口中进行关联。
3、apply方法中实现将两个不同类型的元素关联并生成一个新类型的元素。

```
package cn.itcast.extend;

import com.alibaba.fastjson.JSON;
import lombok.Data;
import org.apache.flink.api.common.eventtime.*;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 */
public class JoinDemo01 {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 构建商品数据流
        DataStream<Goods> goodsDS = env.addSource(new GoodsSource11(), TypeInformation.of(Goods.class)).assignTimestampsAndWatermarks(new GoodsWatermark());
        // 构建订单明细数据流
        DataStream<OrderItem> orderItemDS = env.addSource(new OrderItemSource(), TypeInformation.of(OrderItem.class)).assignTimestampsAndWatermarks(new OrderItemWatermark());

        // 进行关联查询
        DataStream<FactOrderItem> factOrderItemDS = orderItemDS.join(goodsDS)
                // 第一个流orderItemDS
                .where(OrderItem::getGoodsId)
                // 第二流goodsDS
                .equalTo(Goods::getGoodsId)
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                .apply((OrderItem item, Goods goods) -> {
                    FactOrderItem factOrderItem = new FactOrderItem();
                    factOrderItem.setGoodsId(goods.getGoodsId());
                    factOrderItem.setGoodsName(goods.getGoodsName());
                    factOrderItem.setCount(new BigDecimal(item.getCount()));
                    factOrderItem.setTotalMoney(goods.getGoodsPrice().multiply(new BigDecimal(item.getCount())));
                    return factOrderItem;
                });

        factOrderItemDS.print();

        env.execute("滚动窗口JOIN");
    }
    //商品类
    @Data
    public static class Goods {
        private String goodsId;
        private String goodsName;
        private BigDecimal goodsPrice;

        public static List<Goods> GOODS_LIST;
        public static Random r;

        static  {
            r = new Random();
            GOODS_LIST = new ArrayList<>();
            GOODS_LIST.add(new Goods("1", "小米12", new BigDecimal(4890)));
            GOODS_LIST.add(new Goods("2", "iphone12", new BigDecimal(12000)));
            GOODS_LIST.add(new Goods("3", "MacBookPro", new BigDecimal(15000)));
            GOODS_LIST.add(new Goods("4", "Thinkpad X1", new BigDecimal(9800)));
            GOODS_LIST.add(new Goods("5", "MeiZu One", new BigDecimal(3200)));
            GOODS_LIST.add(new Goods("6", "Mate 40", new BigDecimal(6500)));
        }

        public static Goods randomGoods() {
            int rIndex = r.nextInt(GOODS_LIST.size());
            return GOODS_LIST.get(rIndex);
        }

        public Goods() {
        }

        public Goods(String goodsId, String goodsName, BigDecimal goodsPrice) {
            this.goodsId = goodsId;
            this.goodsName = goodsName;
            this.goodsPrice = goodsPrice;
        }

        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }

    //订单明细类
    @Data
    public static class OrderItem {
        private String itemId;
        private String goodsId;
        private Integer count;

        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }

    //关联结果
    @Data
    public static class FactOrderItem {
        private String goodsId;
        private String goodsName;
        private BigDecimal count;
        private BigDecimal totalMoney;
        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }
    //构建一个商品Stream源（这个好比就是维表）
    public static class GoodsSource11 extends RichSourceFunction {
        private Boolean isCancel;
        @Override
        public void open(Configuration parameters) throws Exception {
            isCancel = false;
        }
        @Override
        public void run(SourceContext sourceContext) throws Exception {
            while(!isCancel) {
                Goods.GOODS_LIST.stream().forEach(goods -> sourceContext.collect(goods));
                TimeUnit.SECONDS.sleep(1);
            }
        }
        @Override
        public void cancel() {
            isCancel = true;
        }
    }
    //构建订单明细Stream源
    public static class OrderItemSource extends RichSourceFunction {
        private Boolean isCancel;
        private Random r;
        @Override
        public void open(Configuration parameters) throws Exception {
            isCancel = false;
            r = new Random();
        }
        @Override
        public void run(SourceContext sourceContext) throws Exception {
            while(!isCancel) {
                Goods goods = Goods.randomGoods();
                OrderItem orderItem = new OrderItem();
                orderItem.setGoodsId(goods.getGoodsId());
                orderItem.setCount(r.nextInt(10) + 1);
                orderItem.setItemId(UUID.randomUUID().toString());
                sourceContext.collect(orderItem);
                orderItem.setGoodsId("111");
                sourceContext.collect(orderItem);
                TimeUnit.SECONDS.sleep(1);
            }
        }

        @Override
        public void cancel() {
            isCancel = true;
        }
    }
    //构建水印分配器（此处为了简单），直接使用系统时间了
    public static class GoodsWatermark implements WatermarkStrategy<Goods> {

        @Override
        public TimestampAssigner<Goods> createTimestampAssigner(TimestampAssignerSupplier.Context context) {
            return (element, recordTimestamp) -> System.currentTimeMillis();
        }

        @Override
        public WatermarkGenerator<Goods> createWatermarkGenerator(WatermarkGeneratorSupplier.Context context) {
            return new WatermarkGenerator<Goods>() {
                @Override
                public void onEvent(Goods event, long eventTimestamp, WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }

                @Override
                public void onPeriodicEmit(WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
            };
        }
    }

    public static class OrderItemWatermark implements WatermarkStrategy<OrderItem> {
        @Override
        public TimestampAssigner<OrderItem> createTimestampAssigner(TimestampAssignerSupplier.Context context) {
            return (element, recordTimestamp) -> System.currentTimeMillis();
        }
        @Override
        public WatermarkGenerator<OrderItem> createWatermarkGenerator(WatermarkGeneratorSupplier.Context context) {
            return new WatermarkGenerator<OrderItem>() {
                @Override
                public void onEvent(OrderItem event, long eventTimestamp, WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
                @Override
                public void onPeriodicEmit(WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
            };
        }
    }
}
```

#### 代码演示

1、通过keyBy将两个流join到一起
2、interval join需要设置流A去关联哪个时间范围的流B中的元素。此处，我设置的下界为-1、上界为0，且上界是一个开区间。表达的意思就是流A中某个元素的时间，对应上一秒的流B中的元素。

3、process中将两个key一样的元素，关联在一起，并加载到一个新的FactOrderItem对象中

```
package cn.itcast.extend;

import com.alibaba.fastjson.JSON;
import lombok.Data;
import org.apache.flink.api.common.eventtime.*;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.co.ProcessJoinFunction;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.Collector;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 */
public class JoinDemo02 {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 构建商品数据流
        DataStream<Goods> goodsDS = env.addSource(new GoodsSource11(), TypeInformation.of(Goods.class)).assignTimestampsAndWatermarks(new GoodsWatermark());
        // 构建订单明细数据流
        DataStream<OrderItem> orderItemDS = env.addSource(new OrderItemSource(), TypeInformation.of(OrderItem.class)).assignTimestampsAndWatermarks(new OrderItemWatermark());

        // 进行关联查询
        SingleOutputStreamOperator<FactOrderItem> factOrderItemDS = orderItemDS.keyBy(item -> item.getGoodsId())
                .intervalJoin(goodsDS.keyBy(goods -> goods.getGoodsId()))
                .between(Time.seconds(-1), Time.seconds(0))
                .upperBoundExclusive()
                .process(new ProcessJoinFunction<OrderItem, Goods, FactOrderItem>() {
                    @Override
                    public void processElement(OrderItem left, Goods right, Context ctx, Collector<FactOrderItem> out) throws Exception {
                        FactOrderItem factOrderItem = new FactOrderItem();
                        factOrderItem.setGoodsId(right.getGoodsId());
                        factOrderItem.setGoodsName(right.getGoodsName());
                        factOrderItem.setCount(new BigDecimal(left.getCount()));
                        factOrderItem.setTotalMoney(right.getGoodsPrice().multiply(new BigDecimal(left.getCount())));

                        out.collect(factOrderItem);
                    }
                });

        factOrderItemDS.print();

        env.execute("Interval JOIN");
    }
    //商品类
    @Data
    public static class Goods {
        private String goodsId;
        private String goodsName;
        private BigDecimal goodsPrice;

        public static List<Goods> GOODS_LIST;
        public static Random r;

        static  {
            r = new Random();
            GOODS_LIST = new ArrayList<>();
            GOODS_LIST.add(new Goods("1", "小米12", new BigDecimal(4890)));
            GOODS_LIST.add(new Goods("2", "iphone12", new BigDecimal(12000)));
            GOODS_LIST.add(new Goods("3", "MacBookPro", new BigDecimal(15000)));
            GOODS_LIST.add(new Goods("4", "Thinkpad X1", new BigDecimal(9800)));
            GOODS_LIST.add(new Goods("5", "MeiZu One", new BigDecimal(3200)));
            GOODS_LIST.add(new Goods("6", "Mate 40", new BigDecimal(6500)));
        }

        public static Goods randomGoods() {
            int rIndex = r.nextInt(GOODS_LIST.size());
            return GOODS_LIST.get(rIndex);
        }

        public Goods() {
        }

        public Goods(String goodsId, String goodsName, BigDecimal goodsPrice) {
            this.goodsId = goodsId;
            this.goodsName = goodsName;
            this.goodsPrice = goodsPrice;
        }

        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }

    //订单明细类
    @Data
    public static class OrderItem {
        private String itemId;
        private String goodsId;
        private Integer count;

        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }

    //关联结果
    @Data
    public static class FactOrderItem {
        private String goodsId;
        private String goodsName;
        private BigDecimal count;
        private BigDecimal totalMoney;
        @Override
        public String toString() {
            return JSON.toJSONString(this);
        }
    }
    //构建一个商品Stream源（这个好比就是维表）
    public static class GoodsSource11 extends RichSourceFunction {
        private Boolean isCancel;
        @Override
        public void open(Configuration parameters) throws Exception {
            isCancel = false;
        }
        @Override
        public void run(SourceContext sourceContext) throws Exception {
            while(!isCancel) {
                Goods.GOODS_LIST.stream().forEach(goods -> sourceContext.collect(goods));
                TimeUnit.SECONDS.sleep(1);
            }
        }
        @Override
        public void cancel() {
            isCancel = true;
        }
    }
    //构建订单明细Stream源
    public static class OrderItemSource extends RichSourceFunction {
        private Boolean isCancel;
        private Random r;
        @Override
        public void open(Configuration parameters) throws Exception {
            isCancel = false;
            r = new Random();
        }
        @Override
        public void run(SourceContext sourceContext) throws Exception {
            while(!isCancel) {
                Goods goods = Goods.randomGoods();
                OrderItem orderItem = new OrderItem();
                orderItem.setGoodsId(goods.getGoodsId());
                orderItem.setCount(r.nextInt(10) + 1);
                orderItem.setItemId(UUID.randomUUID().toString());
                sourceContext.collect(orderItem);
                orderItem.setGoodsId("111");
                sourceContext.collect(orderItem);
                TimeUnit.SECONDS.sleep(1);
            }
        }

        @Override
        public void cancel() {
            isCancel = true;
        }
    }
    //构建水印分配器（此处为了简单），直接使用系统时间了
    public static class GoodsWatermark implements WatermarkStrategy<Goods> {

        @Override
        public TimestampAssigner<Goods> createTimestampAssigner(TimestampAssignerSupplier.Context context) {
            return (element, recordTimestamp) -> System.currentTimeMillis();
        }

        @Override
        public WatermarkGenerator<Goods> createWatermarkGenerator(WatermarkGeneratorSupplier.Context context) {
            return new WatermarkGenerator<Goods>() {
                @Override
                public void onEvent(Goods event, long eventTimestamp, WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }

                @Override
                public void onPeriodicEmit(WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
            };
        }
    }

    public static class OrderItemWatermark implements WatermarkStrategy<OrderItem> {
        @Override
        public TimestampAssigner<OrderItem> createTimestampAssigner(TimestampAssignerSupplier.Context context) {
            return (element, recordTimestamp) -> System.currentTimeMillis();
        }
        @Override
        public WatermarkGenerator<OrderItem> createWatermarkGenerator(WatermarkGeneratorSupplier.Context context) {
            return new WatermarkGenerator<OrderItem>() {
                @Override
                public void onEvent(OrderItem event, long eventTimestamp, WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
                @Override
                public void onPeriodicEmit(WatermarkOutput output) {
                    output.emitWatermark(new Watermark(System.currentTimeMillis()));
                }
            };
        }
    }
}
```

### End-to-End Exactly-Once

Flink 在1.4.0 版本引入『exactly-once』并号称支持『End-to-End Exactly-Once』“端到端的精确一次”语义。

#### 流处理的数据处理语义

对于批处理，fault-tolerant（容错性）很容易做，失败只需要replay，就可以完美做到容错。

对于流处理，数据流本身是动态，没有所谓的开始或结束，虽然可以replay buffer的部分数据，但fault-tolerant做起来会复杂的多

流处理（有时称为事件处理）可以简单地描述为是对无界数据或事件的连续处理。流或事件处理应用程序可以或多或少地被描述为有向图，并且通常被描述为有向无环图（DAG）。在这样的图中，每个边表示数据或事件流，每个顶点表示运算符，会使用程序中定义的逻辑处理来自相邻边的数据或事件。有两种特殊类型的顶点，通常称为 sources 和 sinks。sources读取外部数据/事件到应用程序中，而 sinks 通常会收集应用程序生成的结果。下图是流式应用程序的示例。有如下特点：

分布式情况下是由多个Source(读取数据)节点、多个Operator(数据处理)节点、多个Sink(输出)节点构成

每个节点的并行数可以有差异，且每个节点都有可能发生故障

对于数据正确性最重要的一点，就是当发生故障时，是怎样容错与恢复的。

![image.png](https://image.hyly.net/i/2025/09/28/da640ecf91c5c817bce74a723bef877e-0.webp)

流处理引擎通常为应用程序提供了三种数据处理语义：最多一次、至少一次和精确一次。
如下是对这些不同处理语义的宽松定义(一致性由弱到强)：
At most noce &#x3c; At least once &#x3c; Exactly once &#x3c; End to End Exactly once

##### At-most-once-最多一次

有可能会有数据丢失
这本质上是简单的恢复方式，也就是直接从失败处的下个数据开始恢复程序，之前的失败数据处理就不管了。可以保证数据或事件最多由应用程序中的所有算子处理一次。 这意味着如果数据在被流应用程序完全处理之前发生丢失，则不会进行其他重试或者重新发送。

![image.png](https://image.hyly.net/i/2025/09/28/6846925089951ff14a17ed6d141c1d04-0.webp)

##### At-least-once-至少一次

有可能重复处理数据
应用程序中的所有算子都保证数据或事件至少被处理一次。这通常意味着如果事件在流应用程序完全处理之前丢失，则将从源头重放或重新传输事件。然而，由于事件是可以被重传的，因此一个事件有时会被处理多次(至少一次)，至于有没有重复数据，不会关心，所以这种场景需要人工干预自己处理重复数据

![image.png](https://image.hyly.net/i/2025/09/28/e933d21b7f60d50caddb6fbfa5c45e6c-0.webp)

##### Exactly-once-精确一次

Exactly-Once 是 Flink、Spark 等流处理系统的核心特性之一，这种语义会保证每一条消息只被流处理系统处理一次。即使是在各种故障的情况下，流应用程序中的所有算子都保证事件只会被『精确一次』的处理。（也有文章将 Exactly-once 翻译为：完全一次，恰好一次）

Flink实现『精确一次』的分布式快照/状态检查点方法受到 Chandy-Lamport 分布式快照算法的启发。通过这种机制，流应用程序中每个算子的所有状态都会定期做 checkpoint。如果是在系统中的任何地方发生失败，每个算子的所有状态都回滚到最新的全局一致 checkpoint 点。在回滚期间，将暂停所有处理。源也会重置为与最近 checkpoint 相对应的正确偏移量。整个流应用程序基本上是回到最近一次的一致状态，然后程序可以从该状态重新启动。

![image.png](https://image.hyly.net/i/2025/09/28/562d74fd17520471346fe43e12552ec9-0.webp)

##### End-to-End Exactly-Once-端到端的精确一次

Flink 在1.4.0 版本引入『exactly-once』并号称支持『End-to-End Exactly-Once』“端到端的精确一次”语义。
它指的是 Flink 应用从 Source 端开始到 Sink 端结束，数据必须经过的起始点和结束点。
注意：
『exactly-once』和『End-to-End Exactly-Once』的区别:

![image.png](https://image.hyly.net/i/2025/09/28/e949a753d722491b5d54f4e459447839-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/8c9904b3f1b56c02a50440b56b4f5fa4-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/466c7ffe6e5a6366c22ffd297f42e4ec-0.webp)

##### **注意：**  **精确一次**?**有效一次!**

有些人可能认为『精确一次』描述了事件处理的保证，其中流中的每个事件只被处理一次。实际上，没有引擎能够保证正好只处理一次。在面对任意故障时，不可能保证每个算子中的用户定义逻辑在每个事件中只执行一次，因为用户代码被部分执行的可能性是永远存在的。

那么，当引擎声明『精确一次』处理语义时，它们能保证什么呢？如果不能保证用户逻辑只执行一次，那么什么逻辑只执行一次？当引擎声明『精确一次』处理语义时，它们实际上是在说，它们可以保证引擎管理的状态更新只提交一次到持久的后端存储。

事件的处理可以发生多次，但是该处理的效果只在持久后端状态存储中反映一次。因此，我们认为有效地描述这些处理语义最好的术语是『有效一次』（effectively once）

##### 补充：流计算系统如何支持一致性语义

![image.png](https://image.hyly.net/i/2025/09/28/7d52eb8e52f116f07c0c4f8480553f16-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/6048e9c81ec1b1aea3cac7e43da720dc-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/7743e10f6af573d5396514cec29008bb-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/468f4163360fa8d26a1c185db44ccd39-0.webp)

#### End-to-End Exactly-Once的实现

通过前面的学习，我们了解到，Flink内部借助分布式快照Checkpoint已经实现了内部的Exactly-Once，但是Flink 自身是无法保证外部其他系统“精确一次”语义的，所以 Flink 若要实现所谓“端到端（End to End）的精确一次”的要求，那么外部系统必须支持“精确一次”语义；然后借助一些其他手段才能实现。如下：

##### Source

发生故障时需要支持重设数据的读取位置，如Kafka可以通过offset来实现（其他的没有offset系统，我们可以自己实现累加器计数）

##### Transformation

也就是Flink内部，已经通过Checkpoint保证了，如果发生故障或出错时，Flink应用重启后会从最新成功完成的checkpoint中恢复——重置应用状态并回滚状态到checkpoint中输入流的正确位置，之后再开始执行数据处理，就好像该故障或崩溃从未发生过一般。

**分布式快照机制**

我们在之前的课程中讲解过 Flink 的容错机制，Flink 提供了失败恢复的容错机制，而这个容错机制的核心就是持续创建分布式数据流的快照来实现。

![image.png](https://image.hyly.net/i/2025/09/28/acb2498da476b87d764e8a2a0a2db764-0.webp)

同 Spark 相比，Spark 仅仅是针对 Driver 的故障恢复 Checkpoint。而 Flink 的快照可以到算子级别，并且对全局数据也可以做快照。Flink 的分布式快照受到  Chandy-Lamport 分布式快照算法启发，同时进行了量身定做。

**Barrier**

Flink 分布式快照的核心元素之一是 Barrier（数据栅栏），我们也可以把 Barrier 简单地理解成一个标记，该标记是严格有序的，并且随着数据流往下流动。每个 Barrier 都带有自己的 ID，Barrier 极其轻量，并不会干扰正常的数据处理。

![image.png](https://image.hyly.net/i/2025/09/28/efead21f8cc1b1fbf988e660527d3180-0.webp)

如上图所示，假如我们有一个从左向右流动的数据流，Flink 会依次生成 snapshot 1、 snapshot 2、snapshot 3……Flink 中有一个专门的“协调者”负责收集每个 snapshot 的位置信息，这个“协调者”也是高可用的。

Barrier 会随着正常数据继续往下流动，每当遇到一个算子，算子会插入一个标识，这个标识的插入时间是上游所有的输入流都接收到 snapshot n。与此同时，当我们的 sink 算子接收到所有上游流发送的 Barrier 时，那么就表明这一批数据处理完毕，Flink 会向“协调者”发送确认消息，表明当前的 snapshot n 完成了。当所有的 sink 算子都确认这批数据成功处理后，那么本次的 snapshot 被标识为完成。

这里就会有一个问题，因为 Flink 运行在分布式环境中，一个 operator 的上游会有很多流，每个流的 barrier n 到达的时间不一致怎么办？这里 Flink 采取的措施是：快流等慢流。

![image.png](https://image.hyly.net/i/2025/09/28/f7cad78f569e002b1a8438e72621724e-0.webp)

拿上图的 barrier n 来说，其中一个流到的早，其他的流到的比较晚。当第一个 barrier n到来后，当前的 operator 会继续等待其他流的 barrier n。直到所有的barrier n 到来后，operator 才会把所有的数据向下发送。

**异步和增量**

按照上面我们介绍的机制，每次在把快照存储到我们的状态后端时，如果是同步进行就会阻塞正常任务，从而引入延迟。因此 Flink 在做快照存储时，可采用异步方式。

此外，由于 checkpoint 是一个全局状态，用户保存的状态可能非常大，多数达 G 或者 T 级别。在这种情况下，checkpoint 的创建会非常慢，而且执行时占用的资源也比较多，因此 Flink 提出了增量快照的概念。也就是说，每次都是进行的全量 checkpoint，是基于上次进行更新的。

##### Sink

需要支持幂等写入或事务写入(Flink的两阶段提交需要事务支持)

###### 幂等写入（Idempotent Writes）

幂等写操作是指：任意多次向一个系统写入数据，只对目标系统产生一次结果影响。

例如，重复向一个HashMap里插入同一个Key-Value二元对，第一次插入时这个HashMap发生变化，后续的插入操作不会改变HashMap的结果，这就是一个幂等写操作。

HBase、Redis和Cassandra这样的KV数据库一般经常用来作为Sink，用以实现端到端的Exactly-Once。

需要注意的是，并不是说一个KV数据库就百分百支持幂等写。幂等写对KV对有要求，那就是Key-Value必须是可确定性（Deterministic）计算的。假如我们设计的Key是：name + curTimestamp，每次执行数据重发时，生成的Key都不相同，会产生多次结果，整个操作不是幂等的。因此，为了追求端到端的Exactly-Once，我们设计业务逻辑时要尽量使用确定性的计算逻辑和数据模型。

###### 事务写入（Transactional Writes）

Flink借鉴了数据库中的事务处理技术，同时结合自身的Checkpoint机制来保证Sink只对外部输出产生一次影响。大致的流程如下:

Flink先将待输出的数据保存下来暂时不向外部系统提交，等到Checkpoint结束时，Flink上下游所有算子的数据都是一致的时候，Flink将之前保存的数据全部提交（Commit）到外部系统。换句话说，只有经过Checkpoint确认的数据才向外部系统写入。

如下图所示，如果使用事务写，那只把时间戳3之前的输出提交到外部系统，时间戳3以后的数据（例如时间戳5和8生成的数据）暂时保存下来，等待下次Checkpoint时一起写入到外部系统。这就避免了时间戳5这个数据产生多次结果，多次写入到外部系统。

![image.png](https://image.hyly.net/i/2025/09/28/a7e1c75b8ad7c627b01e7049428a24a7-0.webp)

在事务写的具体实现上，Flink目前提供了两种方式：
1.预写日志（Write-Ahead-Log，WAL）
2.两阶段提交（Two-Phase-Commit，2PC）
这两种方式区别主要在于：
1.WAL方式通用性更强，适合几乎所有外部系统，但也不能提供百分百端到端的Exactly-Once，因为WAL预习日志会先写内存，而内存是易失介质。
2.如果外部系统自身就支持事务（比如MySQL、Kafka），可以使用2PC方式，可以提供百分百端到端的Exactly-Once。
事务写的方式能提供端到端的Exactly-Once一致性，它的代价也是非常明显的，就是牺牲了延迟。输出数据不再是实时写入到外部系统，而是分批次地提交。目前来说，没有完美的故障恢复和Exactly-Once保障机制，对于开发者来说，需要在不同需求之间权衡。

#### Flink+Kafka的End-to-End Exactly-Once

在上一小节我们了解到Flink的 End-to-End Exactly-Once需要Checkpoint+事务的提交/回滚操作，在分布式系统中协调提交和回滚的一个常见方法就是使用两阶段提交协议。接下来我们了解下Flink的TwoPhaseCommitSinkFunction是如何支持End-to-End Exactly-Once的

##### 版本说明

Flink 1.4版本之前，支持Exactly Once语义，仅限于应用内部。
Flink 1.4版本之后，通过两阶段提交(TwoPhaseCommitSinkFunction)支持End-To-End Exactly Once，而且要求Kafka 0.11+。
利用TwoPhaseCommitSinkFunction是通用的管理方案，只要实现对应的接口，而且Sink的存储支持变乱提交，即可实现端到端的划一性语义。

![image.png](https://image.hyly.net/i/2025/09/28/9f7226d1eb81bc928895c05c0aa8472a-0.webp)

##### 两阶段提交-API

在 Flink 中的Two-Phase-Commit-2PC两阶段提交的实现方法被封装到了 TwoPhaseCommitSinkFunction 这个抽象类中，只需要实现其中的beginTransaction、preCommit、commit、abort 四个方法就可以实现“精确一次”的处理语义，如FlinkKafkaProducer就实现了该类并实现了这些方法

![image.png](https://image.hyly.net/i/2025/09/28/6ec42fa4578bd191f219474e8e669f2d-0.webp)

1.beginTransaction，在开启事务之前，我们在目标文件系统的临时目录中创建一个临时文件，后面在处理数据时将数据写入此文件；
2.preCommit，在预提交阶段，刷写（flush）文件，然后关闭文件，之后就不能写入到文件了，我们还将为属于下一个检查点的任何后续写入启动新事务；
3.commit，在提交阶段，我们将预提交的文件原子性移动到真正的目标目录中，请注意，这会增加输出数据可见性的延迟；
4.abort，在中止阶段，我们删除临时文件。

##### 两阶段提交-简单流程

![image.png](https://image.hyly.net/i/2025/09/28/7184b0dd89b7cfb2e193954f13e2d753-0.webp)

整个过程可以总结为下面四个阶段：
1.一旦 Flink 开始做 checkpoint 操作，那么就会进入 pre-commit “预提交”阶段，同时JobManager的Coordinator 会将 Barrier 注入数据流中 ；
2.当所有的 barrier 在算子中成功进行一遍传递(就是Checkpoint完成)，并完成快照后，则“预提交”阶段完成；
3.等所有的算子完成“预提交”，就会发起一个commit“提交”动作，但是任何一个“预提交”失败都会导致 Flink 回滚到最近的 checkpoint；

##### 两阶段提交-详细流程

**需求**

接下来将介绍两阶段提交协议，以及它如何在一个读写Kafka的Flink程序中实现端到端的Exactly-Once语义。Kafka经常与Flink一起使用，且Kafka在最近的0.11版本中添加了对事务的支持。这意味着现在通过Flink读写Kafaka，并提供端到端的Exactly-Once语义有了必要的支持。

![image.png](https://image.hyly.net/i/2025/09/28/dfb9066f0de73a628c89cbe2b52ece0a-0.webp)

在上图中，我们有：

1. 从Kafka读取的数据源（Flink内置的KafkaConsumer）
2. 窗口聚合
3. 将数据写回Kafka的数据输出端（Flink内置的KafkaProducer）

要使数据输出端提供Exactly-Once保证，它必须将所有数据通过一个事务提交给Kafka。提交捆绑了两个checkpoint之间的所有要写入的数据。这可确保在发生故障时能回滚写入的数据。
但是在分布式系统中，通常会有多个并发运行的写入任务的，简单的提交或回滚是不够的，因为所有组件必须在提交或回滚时“一致”才能确保一致的结果。
Flink使用两阶段提交协议及预提交阶段来解决这个问题。

**预提交-内部状态**

在checkpoint开始的时候，即两阶段提交协议的“预提交”阶段。当checkpoint开始时，Flink的JobManager会将checkpoint barrier（将数据流中的记录分为进入当前checkpoint与进入下一个checkpoint）注入数据流。

brarrier在operator之间传递。对于每一个operator，它触发operator的状态快照写入到state backend。

![image.png](https://image.hyly.net/i/2025/09/28/3d61e7152c17b8bff45367878381b787-0.webp)

数据源保存了消费Kafka的偏移量(offset)，之后将checkpoint barrier传递给下一个operator。

这种方式仅适用于operator具有『内部』状态。所谓内部状态，是指Flink state backend保存和管理的 -例如，第二个operator中window聚合算出来的sum值。当一个进程有它的内部状态的时候，除了在checkpoint之前需要将数据变更写入到state backend，不需要在预提交阶段执行任何其他操作。[Flink](https://zhoukaibo.com/tags/flink/)负责在checkpoint成功的情况下正确提交这些写入，或者在出现故障时中止这些写入。

![image.png](https://image.hyly.net/i/2025/09/28/3e2dbecd5969acf6be0143c842e30e6c-0.webp)

**预提交-外部状态**

但是，当进程具有『外部』状态时，需要作些额外的处理。外部状态通常以写入外部系统（如Kafka）的形式出现。在这种情况下，为了提供Exactly-Once保证，外部系统必须支持事务，这样才能和两阶段提交协议集成。

在该示例中的数据需要写入Kafka，因此数据输出端（Data Sink）有外部状态。在这种情况下，在预提交阶段，除了将其状态写入state backend之外，数据输出端还必须预先提交其外部事务。

![image.png](https://image.hyly.net/i/2025/09/28/4bda1a8d6ebe4e3f0781071d67d74a5a-0.webp)

当checkpoint barrier在所有operator都传递了一遍，并且触发的checkpoint回调成功完成时，预提交阶段就结束了。所有触发的状态快照都被视为该checkpoint的一部分。checkpoint是整个应用程序状态的快照，包括预先提交的外部状态。如果发生故障，我们可以回滚到上次成功完成快照的时间点。

**提交阶段**

下一步是通知所有operator，checkpoint已经成功了。这是两阶段提交协议的提交阶段，JobManager为应用程序中的每个operator发出checkpoint已完成的回调。

数据源和widnow operator没有外部状态，因此在提交阶段，这些operator不必执行任何操作。但是，数据输出端（Data Sink）拥有外部状态，此时应该提交外部事务。

![image.png](https://image.hyly.net/i/2025/09/28/31632a087d328233915e5f00494f8f28-0.webp)

**总结**

我们对上述知识点总结下：
1.一旦所有operator完成预提交，就提交一个commit。
2.如果只要有一个预提交失败，则所有其他提交都将中止，我们将回滚到上一个成功完成的checkpoint。
3.在预提交成功之后，提交的commit需要保证最终成功 – operator和外部系统都需要保障这点。如果commit失败（例如，由于间歇性网络问题），整个Flink应用程序将失败，应用程序将根据用户的重启策略重新启动，还会尝试再提交。这个过程至关重要，因为如果commit最终没有成功，将会导致数据丢失。
4.完整的实现两阶段提交协议可能有点复杂，这就是为什么Flink将它的通用逻辑提取到抽象类TwoPhaseCommitSinkFunction中的原因。

#### 代码示例

##### Flink+Kafka实现End-to-End Exactly-Once

[https://ververica.cn/developers/flink-kafka-end-to-end-exactly-once-analysis/](https://ververica.cn/developers/flink-kafka-end-to-end-exactly-once-analysis/)

```
package cn.itcast.extend;

import org.apache.commons.lang3.SystemUtils;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.common.time.Time;
import org.apache.flink.api.java.tuple.Tuple;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.CheckpointingMode;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.CheckpointConfig;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer;
import org.apache.flink.streaming.connectors.kafka.internals.KeyedSerializationSchemaWrapper;
import org.apache.flink.util.Collector;

import java.util.Properties;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 * Kafka --> Flink-->Kafka  的End-To-End-Exactly-once
 * 直接使用
 * FlinkKafkaConsumer  +  Flink的Checkpoint  +  FlinkKafkaProducer
 */
public class Kafka_Flink_Kafka_EndToEnd_ExactlyOnce {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //===========Checkpoint参数设置====
        //===========类型1:必须参数=============
        //设置Checkpoint的时间间隔为1000ms做一次Checkpoint/其实就是每隔1000ms发一次Barrier!
        env.enableCheckpointing(1000);
        //设置State状态存储介质
        if (SystemUtils.IS_OS_WINDOWS) {
            env.setStateBackend(new FsStateBackend("file:///D:/ckp"));
        } else {
            env.setStateBackend(new FsStateBackend("hdfs://node1:8020/flink-checkpoint/checkpoint"));
        }
        //===========类型2:建议参数===========
        //设置两个Checkpoint 之间最少等待时间,如设置Checkpoint之间最少是要等 500ms(为了避免每隔1000ms做一次Checkpoint的时候,前一次太慢和后一次重叠到一起去了)
        //如:高速公路上,每隔1s关口放行一辆车,但是规定了两车之前的最小车距为500m
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(500);//默认是0
        //设置如果在做Checkpoint过程中出现错误，是否让整体任务失败：true是  false不是
        //env.getCheckpointConfig().setFailOnCheckpointingErrors(false);//默认是true
        env.getCheckpointConfig().setTolerableCheckpointFailureNumber(10);//默认值为0，表示不容忍任何检查点失败
        //设置是否清理检查点,表示 Cancel 时是否需要保留当前的 Checkpoint，默认 Checkpoint会在作业被Cancel时被删除
        //ExternalizedCheckpointCleanup.DELETE_ON_CANCELLATION：true,当作业被取消时，删除外部的checkpoint(默认值)
        //ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION：false,当作业被取消时，保留外部的checkpoint
        env.getCheckpointConfig().enableExternalizedCheckpoints(CheckpointConfig.ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);

        //===========类型3:直接使用默认的即可===============
        //设置checkpoint的执行模式为EXACTLY_ONCE(默认)
        env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);
        //设置checkpoint的超时时间,如果 Checkpoint在 60s内尚未完成说明该次Checkpoint失败,则丢弃。
        env.getCheckpointConfig().setCheckpointTimeout(60000);//默认10分钟
        //设置同一时间有多少个checkpoint可以同时执行
        env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);//默认为1

        //=============重启策略===========
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(3, Time.of(10, TimeUnit.SECONDS)));

        //2.Source
        Properties props_source = new Properties();
        props_source.setProperty("bootstrap.servers", "node1:9092");
        props_source.setProperty("group.id", "flink");
        props_source.setProperty("auto.offset.reset", "latest");
        props_source.setProperty("flink.partition-discovery.interval-millis", "5000");//会开启一个后台线程每隔5s检测一下Kafka的分区情况
        //props_source.setProperty("enable.auto.commit", "true");//没有Checkpoint的时候使用自动提交偏移量到默认主题:__consumer_offsets中
        //props_source.setProperty("auto.commit.interval.ms", "2000");
        //kafkaSource就是KafkaConsumer
        FlinkKafkaConsumer<String> kafkaSource = new FlinkKafkaConsumer<>("flink_kafka", new SimpleStringSchema(), props_source);
        kafkaSource.setStartFromLatest();
        //kafkaSource.setStartFromGroupOffsets();//设置从记录的offset开始消费,如果没有记录从auto.offset.reset配置开始消费
        //kafkaSource.setStartFromEarliest();//设置直接从Earliest消费,和auto.offset.reset配置无关
        kafkaSource.setCommitOffsetsOnCheckpoints(true);//执行Checkpoint的时候提交offset到Checkpoint(Flink用),并且提交一份到默认主题:__consumer_offsets(外部其他系统想用的话也可以获取到)
        DataStreamSource<String> kafkaDS = env.addSource(kafkaSource);

        //3.Transformation
        //3.1切割出每个单词并直接记为1
        SingleOutputStreamOperator<Tuple2<String, Integer>> wordAndOneDS = kafkaDS.flatMap(new FlatMapFunction<String, Tuple2<String, Integer>>() {
            @Override
            public void flatMap(String value, Collector<Tuple2<String, Integer>> out) throws Exception {
                //value就是每一行
                String[] words = value.split(" ");
                for (String word : words) {
                    Random random = new Random();
                    int i = random.nextInt(5);
                    if (i > 3) {
                        System.out.println("出bug了...");
                        throw new RuntimeException("出bug了...");
                    }
                    out.collect(Tuple2.of(word, 1));
                }
            }
        });
        //3.2分组
        //注意:批处理的分组是groupBy,流处理的分组是keyBy
        KeyedStream<Tuple2<String, Integer>, Tuple> groupedDS = wordAndOneDS.keyBy(0);
        //3.3聚合
        SingleOutputStreamOperator<Tuple2<String, Integer>> aggResult = groupedDS.sum(1);
        //3.4将聚合结果转为自定义的字符串格式
        SingleOutputStreamOperator<String> result = (SingleOutputStreamOperator<String>) aggResult.map(new RichMapFunction<Tuple2<String, Integer>, String>() {
            @Override
            public String map(Tuple2<String, Integer> value) throws Exception {
                return value.f0 + ":::" + value.f1;
            }
        });

        //4.sink
        //result.print();
        Properties props_sink = new Properties();
        props_sink.setProperty("bootstrap.servers", "node1:9092");
        props_sink.setProperty("transaction.timeout.ms", 1000 * 5 + "");//设置事务超时时间，也可在kafka配置中设置
        /*FlinkKafkaProducer<String> kafkaSink0 = new FlinkKafkaProducer<>(
                "flink_kafka",
                new SimpleStringSchema(),
                props_sink);*/
        FlinkKafkaProducer<String> kafkaSink = new FlinkKafkaProducer<>(
                "flink_kafka2",
                new KeyedSerializationSchemaWrapper<String>(new SimpleStringSchema()),
                props_sink,
                FlinkKafkaProducer.Semantic.EXACTLY_ONCE
        );
        result.addSink(kafkaSink);

        //5.execute
        env.execute();
        //测试:
        //1.创建主题 /export/server/kafka/bin/kafka-topics.sh --zookeeper node1:2181 --create --replication-factor 2 --partitions 3 --topic flink_kafka2
        //2.开启控制台生产者 /export/server/kafka/bin/kafka-console-producer.sh --broker-list node1:9092 --topic flink_kafka
        //3.开启控制台消费者 /export/server/kafka/bin/kafka-console-consumer.sh --bootstrap-server node1:9092 --topic flink_kafka2
    }
}
```

##### Flink+MySQL实现End-to-End Exactly-Once

[https://www.jianshu.com/p/5bdd9a0d7d02](https://www.jianshu.com/p/5bdd9a0d7d02)

**需求**

1.checkpoint每10s进行一次，此时用FlinkKafkaConsumer实时消费kafka中的消息
2.消费并处理完消息后，进行一次预提交数据库的操作
3.如果预提交没有问题，10s后进行真正的插入数据库操作，如果插入成功，进行一次checkpoint，flink会自动记录消费的offset，可以将checkpoint保存的数据放到hdfs中
4.如果预提交出错，比如在5s的时候出错了，此时Flink程序就会进入不断的重启中，重启的策略可以在配置中设置，checkpoint记录的还是上一次成功消费的offset，因为本次消费的数据在checkpoint期间，消费成功，但是预提交过程中失败了
5.注意此时数据并没有真正的执行插入操作，因为预提交（preCommit）失败，提交（commit）过程也不会发生。等将异常数据处理完成之后，再重新启动这个Flink程序，它会自动从上一次成功的checkpoint中继续消费数据，以此来达到Kafka到Mysql的Exactly-Once。

**代码1**

```
package cn.itcast.extend;

import org.apache.flink.api.common.ExecutionConfig;
import org.apache.flink.api.common.typeutils.base.VoidSerializer;
import org.apache.flink.api.java.typeutils.runtime.kryo.KryoSerializer;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.flink.streaming.api.CheckpointingMode;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.TwoPhaseCommitSinkFunction;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import org.apache.flink.streaming.util.serialization.JSONKeyValueDeserializationSchema;
import org.apache.kafka.clients.CommonClientConfigs;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;


public class Kafka_Flink_MySQL_EndToEnd_ExactlyOnce {

    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);//方便测试
        env.enableCheckpointing(10000);
        env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);
        env.getCheckpointConfig().setMinPauseBetweenCheckpoints(1000);
        //env.getCheckpointConfig().enableExternalizedCheckpoints(CheckpointConfig.ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);
        env.setStateBackend(new FsStateBackend("file:///D:/ckp"));

        //2.Source
        String topic = "flink_kafka";
        Properties props = new Properties();
        props.setProperty(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG,"node1:9092");
        props.setProperty("group.id","flink");
        props.setProperty("auto.offset.reset","latest");//如果有记录偏移量从记录的位置开始消费,如果没有从最新的数据开始消费
        props.setProperty("flink.partition-discovery.interval-millis","5000");//开一个后台线程每隔5s检查Kafka的分区状态
        FlinkKafkaConsumer<ObjectNode> kafkaSource = new FlinkKafkaConsumer<>("topic_in", new JSONKeyValueDeserializationSchema(true), props);

        kafkaSource.setStartFromGroupOffsets();//从group offset记录的位置位置开始消费,如果kafka broker 端没有该group信息，会根据"auto.offset.reset"的设置来决定从哪开始消费
        kafkaSource.setCommitOffsetsOnCheckpoints(true);//Flink执行Checkpoint的时候提交偏移量(一份在Checkpoint中,一份在Kafka的默认主题中__comsumer_offsets(方便外部监控工具去看))

        DataStreamSource<ObjectNode> kafkaDS = env.addSource(kafkaSource);

        //3.transformation

        //4.Sink
        kafkaDS.addSink(new MySqlTwoPhaseCommitSink()).name("MySqlTwoPhaseCommitSink");

        //5.execute
        env.execute();
    }
}

/**
 自定义kafka to mysql，继承TwoPhaseCommitSinkFunction,实现两阶段提交。
 功能：保证kafak to mysql 的Exactly-Once
 CREATE TABLE `t_test` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `value` varchar(255) DEFAULT NULL,
   `insert_time` datetime DEFAULT NULL,
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
 */
class MySqlTwoPhaseCommitSink extends TwoPhaseCommitSinkFunction<ObjectNode, Connection, Void> {

    public MySqlTwoPhaseCommitSink() {
        super(new KryoSerializer<>(Connection.class, new ExecutionConfig()), VoidSerializer.INSTANCE);
    }

    /**
     * 执行数据入库操作
     */
    @Override
    protected void invoke(Connection connection, ObjectNode objectNode, Context context) throws Exception {
        System.err.println("start invoke.......");
        String date = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
        System.err.println("===>date:" + date + " " + objectNode);
        String value = objectNode.get("value").toString();
        String sql = "insert into `t_test` (`value`,`insert_time`) values (?,?)";
        PreparedStatement ps = connection.prepareStatement(sql);
        ps.setString(1, value);
        ps.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
        //执行insert语句
        ps.execute();
        //手动制造异常
        if(Integer.parseInt(value) == 15) System.out.println(1/0);
    }

    /**
     * 获取连接，开启手动提交事务（getConnection方法中）
     */
    @Override
    protected Connection beginTransaction() throws Exception {
        String url = "jdbc:mysql://localhost:3306/bigdata?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&useSSL=false&autoReconnect=true";
        Connection connection = DBConnectUtil.getConnection(url, "root", "root");
        System.err.println("start beginTransaction......."+connection);
        return connection;
    }

    /**
     * 预提交，这里预提交的逻辑在invoke方法中
     */
    @Override
    protected void preCommit(Connection connection) throws Exception {
        System.err.println("start preCommit......."+connection);

    }

    /**
     * 如果invoke执行正常则提交事务
     */
    @Override
    protected void commit(Connection connection) {
        System.err.println("start commit......."+connection);
        DBConnectUtil.commit(connection);

    }

    @Override
    protected void recoverAndCommit(Connection connection) {
        System.err.println("start recoverAndCommit......."+connection);

    }

    @Override
    protected void recoverAndAbort(Connection connection) {
        System.err.println("start abort recoverAndAbort......."+connection);
    }

    /**
     * 如果invoke执行异常则回滚事务，下一次的checkpoint操作也不会执行
     */
    @Override
    protected void abort(Connection connection) {
        System.err.println("start abort rollback......."+connection);
        DBConnectUtil.rollback(connection);
    }
}

class DBConnectUtil {
    /**
     * 获取连接
     */
    public static Connection getConnection(String url, String user, String password) throws SQLException {
        Connection conn = null;
        conn = DriverManager.getConnection(url, user, password);
        //设置手动提交
        conn.setAutoCommit(false);
        return conn;
    }

    /**
     * 提交事务
     */
    public static void commit(Connection conn) {
        if (conn != null) {
            try {
                conn.commit();
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                close(conn);
            }
        }
    }

    /**
     * 事务回滚
     */
    public static void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                close(conn);
            }
        }
    }

    /**
     * 关闭连接
     */
    public static void close(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```

**代码2**

```
package cn.itcast.extend;

import com.alibaba.fastjson.JSON;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

public class DataProducer {
    public static void main(String[] args) throws InterruptedException {
        Properties props = new Properties();
        props.put("bootstrap.servers", "node1:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        Producer<String, String> producer = new org.apache.kafka.clients.producer.KafkaProducer<>(props);

        try {
            for (int i = 1; i <= 20; i++) {
                DataBean data = new DataBean(String.valueOf(i));
                ProducerRecord record = new ProducerRecord<String, String>("flink_kafka", null, null, JSON.toJSONString(data));
                producer.send(record);
                System.out.println("发送数据: " + JSON.toJSONString(data));
                Thread.sleep(1000);
            }
        }catch (Exception e){
            System.out.println(e);
        }
        producer.flush();
    }
}

@Data
@NoArgsConstructor
@AllArgsConstructor
class DataBean {
    private String value;
}
```

### 异步IO

#### 介绍

##### 异步IO操作的需求

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/asyncio.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/stream/operators/asyncio.html)

Async I/O 是阿里巴巴贡献给社区的一个呼声非常高的特性，于1.2版本引入。主要目的是为了解决与外部系统交互时网络延迟成为了系统瓶颈的问题。
流计算系统中经常需要与外部系统进行交互，我们通常的做法如向数据库发送用户a的查询请求，然后等待结果返回，在这之前，我们的程序无法发送用户b的查询请求。这是一种同步访问方式，如下图所示

![image.png](https://image.hyly.net/i/2025/09/28/ec723752a04fcba352e15b739adcd961-0.webp)

1. 左图所示：通常实现方式是向数据库发送用户a的查询请求（例如在MapFunction中），然后等待结果返回，在这之前，我们无法发送用户b的查询请求，这是一种同步访问的模式，图中棕色的长条标识等待时间，可以发现网络等待时间极大的阻碍了吞吐和延迟
2. 右图所示：为了解决同步访问的问题，异步模式可以并发的处理多个请求和回复，可以连续的向数据库发送用户a、b、c、d等的请求，与此同时，哪个请求的回复先返回了就处理哪个回复，从而连续的请求之间不需要阻塞等待，这也正是Async I/O的实现原理。

##### 使用Aysnc I/O的前提条件

1. 数据库(或key/value存储系统)提供支持异步请求的client。（如java的vertx）
2. 没有异步请求客户端的话也可以将同步客户端丢到线程池中执行作为异步客户端

##### Async I/O API

Async I/O API允许用户在数据流中使用异步客户端访问外部存储，该API处理与数据流的集成，以及消息顺序性（Order），事件时间（EventTime），一致性（容错）等脏活累活，用户只专注于业务
如果目标数据库中有异步客户端，则三步即可实现异步流式转换操作（针对该数据库的异步）：

1. 实现用来分发请求的AsyncFunction，用来向数据库发送异步请求并设置回调
2. 获取操作结果的callback，并将它提交给ResultFuture
3. 将异步I/O操作应用于DataStream

![image.png](https://image.hyly.net/i/2025/09/28/018be6e5a44e03441cb7eb58d1644d4b-0.webp)

#### 案例演示

[https://blog.csdn.net/weixin_41608066/article/details/105957940](https://blog.csdn.net/weixin_41608066/article/details/105957940)

**需求：**

使用异步IO实现从MySQL中读取数据

**数据准备：**

```
DROP TABLE IF EXISTS `t_category`;
CREATE TABLE `t_category` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of t_category
-- ----------------------------
INSERT INTO `t_category` VALUES ('1', '手机');
INSERT INTO `t_category` VALUES ('2', '电脑');
INSERT INTO `t_category` VALUES ('3', '服装');
INSERT INTO `t_category` VALUES ('4', '化妆品');
INSERT INTO `t_category` VALUES ('5', '食品');
```

**代码演示**

```
package cn.itcast.extend;

import io.vertx.core.AsyncResult;
import io.vertx.core.Handler;
import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.jdbc.JDBCClient;
import io.vertx.ext.sql.SQLClient;
import io.vertx.ext.sql.SQLConnection;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.datastream.AsyncDataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.async.ResultFuture;
import org.apache.flink.streaming.api.functions.async.RichAsyncFunction;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;

import java.sql.*;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * 使用异步io的先决条件
 * 1.数据库(或key/value存储)提供支持异步请求的client。
 * 2.没有异步请求客户端的话也可以将同步客户端丢到线程池中执行作为异步客户端。
 */
public class ASyncIODemo {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        //2.Source
        //DataStreamSource[1,2,3,4,5]
        DataStreamSource<CategoryInfo> categoryDS = env.addSource(new RichSourceFunction<CategoryInfo>() {
            private Boolean flag = true;
            @Override
            public void run(SourceContext<CategoryInfo> ctx) throws Exception {
                Integer[] ids = {1, 2, 3, 4, 5};
                for (Integer id : ids) {
                    ctx.collect(new CategoryInfo(id, null));
                }
            }
            @Override
            public void cancel() {
                this.flag = false;
            }
        });
        //3.Transformation


        //方式一：Java-vertx中提供的异步client实现异步IO
        //unorderedWait无序等待
        SingleOutputStreamOperator<CategoryInfo> result1 = AsyncDataStream
                .unorderedWait(categoryDS, new ASyncIOFunction1(), 1000, TimeUnit.SECONDS, 10);

        //方式二：MySQL中同步client+线程池模拟异步IO
        //unorderedWait无序等待
        SingleOutputStreamOperator<CategoryInfo> result2 = AsyncDataStream
                .unorderedWait(categoryDS, new ASyncIOFunction2(), 1000, TimeUnit.SECONDS, 10);

        //4.Sink
        result1.print("方式一：Java-vertx中提供的异步client实现异步IO \n");
        result2.print("方式二：MySQL中同步client+线程池模拟异步IO \n");

        //5.execute
        env.execute();
    }
}

@Data
@NoArgsConstructor
@AllArgsConstructor
class CategoryInfo {
    private Integer id;
    private String name;
}

class MysqlSyncClient {
    private static transient Connection connection;
    private static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/bigdata";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    static {
        init();
    }

    private static void init() {
        try {
            Class.forName(JDBC_DRIVER);
        } catch (ClassNotFoundException e) {
            System.out.println("Driver not found!" + e.getMessage());
        }
        try {
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            System.out.println("init connection failed!" + e.getMessage());
        }
    }

    public void close() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
            System.out.println("close connection failed!" + e.getMessage());
        }
    }

    public CategoryInfo query(CategoryInfo category) {
        try {
            String sql = "select id,name from t_category where id = "+ category.getId();
            Statement statement = connection.createStatement();
            ResultSet rs = statement.executeQuery(sql);
            if (rs != null && rs.next()) {
                category.setName(rs.getString("name"));
            }
        } catch (SQLException e) {
            System.out.println("query failed!" + e.getMessage());
        }
        return category;
    }
}

/**
 * 方式一：Java-vertx中提供的异步client实现异步IO
 */
class ASyncIOFunction1 extends RichAsyncFunction<CategoryInfo, CategoryInfo> {
    private transient SQLClient mySQLClient;

    @Override
    public void open(Configuration parameters) throws Exception {
        JsonObject mySQLClientConfig = new JsonObject();
        mySQLClientConfig
                .put("driver_class", "com.mysql.jdbc.Driver")
                .put("url", "jdbc:mysql://localhost:3306/bigdata")
                .put("user", "root")
                .put("password", "root")
                .put("max_pool_size", 20);

        VertxOptions options = new VertxOptions();
        options.setEventLoopPoolSize(10);
        options.setWorkerPoolSize(20);
        Vertx vertx = Vertx.vertx(options);
        //根据上面的配置参数获取异步请求客户端
        mySQLClient = JDBCClient.createNonShared(vertx, mySQLClientConfig);
    }

    //使用异步客户端发送异步请求
    @Override
    public void asyncInvoke(CategoryInfo input, ResultFuture<CategoryInfo> resultFuture) throws Exception {
        mySQLClient.getConnection(new Handler<AsyncResult<SQLConnection>>() {
            @Override
            public void handle(AsyncResult<SQLConnection> sqlConnectionAsyncResult) {
                if (sqlConnectionAsyncResult.failed()) {
                    return;
                }
                SQLConnection connection = sqlConnectionAsyncResult.result();
                connection.query("select id,name from t_category where id = " +input.getId(), new Handler<AsyncResult<io.vertx.ext.sql.ResultSet>>() {
                    @Override
                    public void handle(AsyncResult<io.vertx.ext.sql.ResultSet> resultSetAsyncResult) {
                        if (resultSetAsyncResult.succeeded()) {
                            List<JsonObject> rows = resultSetAsyncResult.result().getRows();
                            for (JsonObject jsonObject : rows) {
                                CategoryInfo categoryInfo = new CategoryInfo(jsonObject.getInteger("id"), jsonObject.getString("name"));
                                resultFuture.complete(Collections.singletonList(categoryInfo));
                            }
                        }
                    }
                });
            }
        });
    }
    @Override
    public void close() throws Exception {
        mySQLClient.close();
    }

    @Override
    public void timeout(CategoryInfo input, ResultFuture<CategoryInfo> resultFuture) throws Exception {
        System.out.println("async call time out!");
        input.setName("未知");
        resultFuture.complete(Collections.singleton(input));
    }
}

/**
 * 方式二：同步调用+线程池模拟异步IO
 */
class ASyncIOFunction2 extends RichAsyncFunction<CategoryInfo, CategoryInfo> {
    private transient MysqlSyncClient client;
    private ExecutorService executorService;//线程池

    @Override
    public void open(Configuration parameters) throws Exception {
        super.open(parameters);
        client = new MysqlSyncClient();
        executorService = new ThreadPoolExecutor(10, 10, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
    }

    //异步发送请求
    @Override
    public void asyncInvoke(CategoryInfo input, ResultFuture<CategoryInfo> resultFuture) throws Exception {
        executorService.execute(new Runnable() {
            @Override
            public void run() {
                resultFuture.complete(Collections.singletonList((CategoryInfo) client.query(input)));
            }
        });
    }


    @Override
    public void close() throws Exception {
    }

    @Override
    public void timeout(CategoryInfo input, ResultFuture<CategoryInfo> resultFuture) throws Exception {
        System.out.println("async call time out!");
        input.setName("未知");
        resultFuture.complete(Collections.singleton(input));
    }
}
```

**异步IO读取Redis数据**

```
package cn.itcast.extend;

import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;
import io.vertx.redis.RedisClient;
import io.vertx.redis.RedisOptions;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.TimeCharacteristic;
import org.apache.flink.streaming.api.datastream.AsyncDataStream;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.async.ResultFuture;
import org.apache.flink.streaming.api.functions.async.RichAsyncFunction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

import java.util.Collections;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;
/**
使用异步IO访问redis
hset AsyncReadRedis beijing 1
hset AsyncReadRedis shanghai 2
hset AsyncReadRedis guangzhou 3
hset AsyncReadRedis shenzhen 4
hset AsyncReadRedis hangzhou 5
hset AsyncReadRedis wuhan 6
hset AsyncReadRedis chengdu 7
hset AsyncReadRedis tianjin 8
hset AsyncReadRedis chongqing 9
 
city.txt
1,beijing
2,shanghai
3,guangzhou
4,shenzhen
5,hangzhou
6,wuhan
7,chengdu
8,tianjin
9,chongqing
 */
public class AsyncIODemo_Redis {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);

        DataStreamSource<String> lines = env.readTextFile("data/input/city.txt");

        SingleOutputStreamOperator<String> result1 = AsyncDataStream.orderedWait(lines, new AsyncRedis(), 10, TimeUnit.SECONDS, 1);
        SingleOutputStreamOperator<String> result2 = AsyncDataStream.orderedWait(lines, new AsyncRedisByVertx(), 10, TimeUnit.SECONDS, 1);

        result1.print().setParallelism(1);
        result2.print().setParallelism(1);

        env.execute();
    }
}
/**
 * 使用异步的方式读取redis的数据
 */
class AsyncRedis extends RichAsyncFunction<String, String> {
    //定义redis的连接池对象
    private JedisPoolConfig config = null;

    private static String ADDR = "localhost";
    private static int PORT = 6379;
    //等待可用连接的最大时间，单位是毫秒，默认是-1，表示永不超时，如果超过等待时间，则会抛出异常
    private static int TIMEOUT = 10000;
    //定义redis的连接池实例
    private JedisPool jedisPool = null;
    //定义连接池的核心对象
    private Jedis jedis = null;
    //初始化redis的连接
    @Override
    public void open(Configuration parameters) throws Exception {
        super.open(parameters);
        //定义连接池对象属性配置
        config = new JedisPoolConfig();
        //初始化连接池对象
        jedisPool = new JedisPool(config, ADDR, PORT, TIMEOUT);
        //实例化连接对象（获取一个可用的连接）
        jedis = jedisPool.getResource();
    }

    @Override
    public void close() throws Exception {
        super.close();
        if(jedis.isConnected()){
            jedis.close();
        }
    }

    //异步调用redis
    @Override
    public void asyncInvoke(String input, ResultFuture<String> resultFuture) throws Exception {
        System.out.println("input:"+input);
        //发起一个异步请求，返回结果
        CompletableFuture.supplyAsync(new Supplier<String>() {
            @Override
            public String get() {
                String[] arrayData = input.split(",");
                String name = arrayData[1];
                String value = jedis.hget("AsyncReadRedis", name);
                System.out.println("output:"+value);
                return  value;
            }
        }).thenAccept((String dbResult)->{
            //设置请求完成时的回调，将结果返回
            resultFuture.complete(Collections.singleton(dbResult));
        });
    }

    //连接超时的时候调用的方法，一般在该方法中输出连接超时的错误日志，如果不重新该方法，连接超时后会抛出异常
    @Override
    public void timeout(String input, ResultFuture<String> resultFuture) throws Exception {
        System.out.println("redis connect timeout!");
    }
}
/**
 * 使用高性能异步组件vertx实现类似于连接池的功能，效率比连接池要高
 * 1）在java版本中可以直接使用
 * 2）如果在scala版本中使用的话，需要scala的版本是2.12+
 */
class AsyncRedisByVertx extends RichAsyncFunction<String,String> {
    //用transient关键字标记的成员变量不参与序列化过程
    private transient RedisClient redisClient;
    //获取连接池的配置对象
    private JedisPoolConfig config = null;
    //获取连接池
    JedisPool jedisPool = null;
    //获取核心对象
    Jedis jedis = null;
    //Redis服务器IP
    private static String ADDR = "localhost";
    //Redis的端口号
    private static int PORT = 6379;
    //访问密码
    private static String AUTH = "XXXXXX";
    //等待可用连接的最大时间，单位毫秒，默认值为-1，表示永不超时。如果超过等待时间，则直接抛出JedisConnectionException；
    private static int TIMEOUT = 10000;
    private static final Logger logger = LoggerFactory.getLogger(AsyncRedis.class);
    //初始化连接
    @Override
    public void open(Configuration parameters) throws Exception {
        super.open(parameters);
        config = new JedisPoolConfig();
        jedisPool = new JedisPool(config, ADDR, PORT, TIMEOUT);
        jedis = jedisPool.getResource();

        RedisOptions config = new RedisOptions();
        config.setHost(ADDR);
        config.setPort(PORT);

        VertxOptions vo = new VertxOptions();
        vo.setEventLoopPoolSize(10);
        vo.setWorkerPoolSize(20);

        Vertx vertx = Vertx.vertx(vo);

        redisClient = RedisClient.create(vertx, config);
    }

    //数据异步调用
    @Override
    public void asyncInvoke(String input, ResultFuture<String> resultFuture) throws Exception {
        System.out.println("input:"+input);
        String[] split = input.split(",");
        String name = split[1];
        // 发起一个异步请求
        redisClient.hget("AsyncReadRedis", name, res->{
            if(res.succeeded()){
                String result = res.result();
                if(result== null){
                    resultFuture.complete(null);
                    return;
                }
                else {
                    // 设置请求完成时的回调: 将结果传递给 collector
                    resultFuture.complete(Collections.singleton(result));
                }
            }else if(res.failed()) {
                resultFuture.complete(null);
                return;
            }
        });
    }
    @Override
    public void timeout(String input, ResultFuture resultFuture) throws Exception {
    }
    @Override
    public void close() throws Exception {
        super.close();
        if (redisClient != null) {
            redisClient.close(null);
        }
    }
}
```

#### 扩展阅读：原理深入

##### AsyncDataStream

AsyncDataStream是一个工具类，用于将AsyncFunction应用于DataStream，AsyncFunction发出的并发请求都是无序的，该顺序基于哪个请求先完成，为了控制结果记录的发出顺序，flink提供了两种模式，分别对应AsyncDataStream的两个静态方法，**OrderedWait和unorderedWait**

1. orderedWait（有序）：消息的发送顺序与接收到的顺序相同（包括 watermark ），也就是先进先出。
2. unorderWait（无序）：
   1. 在ProcessingTime中，完全无序，即哪个请求先返回结果就先发送（最低延迟和最低消耗）。
   2. 在EventTime中，以watermark为边界，介于两个watermark之间的消息可以乱序，但是watermark和消息之间不能乱序，这样既认为在无序中又引入了有序，这样就有了与有序一样的开销。

AsyncDataStream.(un)orderedWait 的主要工作就是创建了一个 AsyncWaitOperator。AsyncWaitOperator 是支持异步 IO 访问的算子实现，该算子会运行 AsyncFunction 并处理异步返回的结果，其内部原理如下图所示。

![image.png](https://image.hyly.net/i/2025/09/28/08271d9944d81983db05471b6c518b87-0.webp)

如图所示，AsyncWaitOperator 主要由两部分组成：

1. StreamElementQueue
2. Emitter

**StreamElementQueue** 是一个 **Promise** 队列，所谓 Promise 是一种异步抽象表示将来会有一个值（海底捞排队给你的小票），这个队列是未完成的 Promise 队列，也就是进行中的请求队列。Emitter 是一个单独的线程，负责发送消息（收到的异步回复）给下游。

图中E5表示进入该算子的第五个元素（”Element-5”）

1. 在执行过程中首先会将其包装成一个 “Promise” P5，然后将P5放入队列
2. 最后调用 AsyncFunction 的 ayncInvoke 方法，该方法会向外部服务发起一个异步的请求，并注册回调
3. 该回调会在异步请求成功返回时调用 AsyncCollector.collect 方法将返回的结果交给框架处理。
4. 实际上 AsyncCollector 是一个 Promise ，也就是 P5，在调用 collect 的时候会标记 Promise 为完成状态，并通知 Emitter 线程有完成的消息可以发送了。
5. Emitter 就会从队列中拉取完成的 Promise ，并从 Promise 中取出消息发送给下游。

##### 消息的顺序性

上文提到 Async I/O 提供了两种输出模式。其实细分有三种模式:

1. 有序
2. ProcessingTime 无序
3. EventTime 无序

Flink 使用队列来实现不同的输出模式，并抽象出一个队列的接口（StreamElementQueue），这种分层设计使得AsyncWaitOperator和Emitter不用关心消息的顺序问题。StreamElementQueue有两种具体实现，分别是 OrderedStreamElementQueue 和UnorderedStreamElementQueue。UnorderedStreamElementQueue 比较有意思，它使用了一套逻辑巧妙地实现完全无序和 EventTime 无序。

**有序**

有序比较简单，使用一个队列就能实现。所有新进入该算子的元素（包括 watermark），都会包装成 Promise 并按到达顺序放入该队列。如下图所示，尽管P4的结果先返回，但并不会发送，只有 P1 （队首）的结果返回了才会触发 Emitter 拉取队首元素进行发送。

![image.png](https://image.hyly.net/i/2025/09/28/a0f1b1a8a5756fb0849530054f90545c-0.webp)

**ProcessingTime 无序**

ProcessingTime 无序也比较简单，因为没有 watermark，不需要协调 watermark 与消息的顺序性，所以使用两个队列就能实现，一个 **uncompletedQueue **一个  **completedQueue** 。所有新进入该算子的元素，同样的包装成**Promise **并放入 **uncompletedQueue **队列，当**uncompletedQueue**队列中任意的**Promise**返回了数据，则将该**Promise **移到 **completedQueue **队列中，并通知**Emitter **消费。如下图所示：

![image.png](https://image.hyly.net/i/2025/09/28/ea6cbf12a68ad6496dc7ad4ae7de3a93-0.webp)

**EventTime 无序**

**EventTime 无序类似于有序与 ProcessingTime 无序的结合体** 。因为有 **watermark** ，需要协调 watermark与消息之间的顺序性，所以**uncompletedQueue**中存放的元素从原先的**Promise **变成了 **Promise 集合** 。

1. 如果进入算子的是消息元素，则会包装成 Promise 放入队尾的集合中
2. 如果进入算子的是 watermark，也会包装成 Promise 并放到一个独立的集合中，再将该集合加入到 uncompletedQueue 队尾，最后再创建一个空集合加到 uncompletedQueue 队尾
3. 这样，watermark 就成了消息顺序的边界。
4. 只有处在队首的集合中的 Promise 返回了数据，才能将该 Promise 移到completedQueue
5. 队列中，由 Emitter 消费发往下游。
6. 只有队首集合空了，才能处理第二个集合。

这样就保证了当且仅当某个 watermark 之前所有的消息都已经被发送了，该 watermark 才能被发送。过程如下图所示：

![image.png](https://image.hyly.net/i/2025/09/28/57e86b464e7c1f7568b7717408d6040e-0.webp)

### Streaming File Sink

#### 介绍

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/streamfile_sink.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/streamfile_sink.html)

[https://blog.csdn.net/u013220482/article/details/100901471](https://blog.csdn.net/u013220482/article/details/100901471)

##### 场景描述

StreamingFileSink是Flink1.7中推出的新特性，是为了解决如下的问题：

大数据业务场景中，经常有一种场景：外部数据发送到kafka中，flink作为中间件消费kafka数据并进行业务处理；处理完成之后的数据可能还需要写入到数据库或者文件系统中，比如写入hdfs中。

StreamingFileSink就可以用来将分区文件写入到支持 [Flink FileSystem](https://ci.apache.org/projects/flink/flink-docs-release-1.9/zh/ops/filesystems/index.html) 接口的文件系统中，支持Exactly-Once语义。

这种sink实现的Exactly-Once都是基于Flink checkpoint来实现的两阶段提交模式来保证的，主要应用在实时数仓、topic拆分、基于小时分析处理等场景下。

##### Bucket和SubTask、PartFile

**Bucket**

StreamingFileSink可向由[Flink FileSystem抽象](https://ci.apache.org/projects/flink/flink-docs-release-1.9/ops/filesystems/index.html)支持的文件系统写入分区文件（因为是流式写入，数据被视为无界）。该分区行为可配，默认按时间，具体来说每小时写入一个Bucket，该Bucket包括若干文件，内容是这一小时间隔内流中收到的所有record。

**PartFile**

每个Bukcket内部分为多个PartFile来存储输出数据，该Bucket生命周期内接收到数据的sink的每个子任务至少有一个PartFile。

而额外文件滚动由可配的滚动策略决定，默认策略是根据文件大小和打开超时（文件可以被打开的最大持续时间）以及文件最大不活动超时等决定是否滚动。

Bucket和SubTask、PartFile关系如图所示

![image.png](https://image.hyly.net/i/2025/09/28/0ff94fabd545bf8e1d461f8fde5fa12d-0.webp)

#### 案例演示

**需求**

编写Flink程序，接收socket的字符串数据，然后将接收到的数据流式方式存储到hdfs

**开发步骤**

1．初始化流计算运行环境
2．设置Checkpoint（10s）周期性启动
3．指定并行度为1
4．接入socket数据源，获取数据
5．指定文件编码格式为行编码格式
6．设置桶分配策略
7．设置文件滚动策略
8．指定文件输出配置
9．将streamingfilesink对象添加到环境
10．执行任务

**实现代码**

```
package cn.itcast.extend;

import org.apache.flink.api.common.serialization.SimpleStringEncoder;
import org.apache.flink.core.fs.Path;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.filesystem.OutputFileConfig;
import org.apache.flink.streaming.api.functions.sink.filesystem.StreamingFileSink;
import org.apache.flink.streaming.api.functions.sink.filesystem.bucketassigners.DateTimeBucketAssigner;
import org.apache.flink.streaming.api.functions.sink.filesystem.rollingpolicies.DefaultRollingPolicy;

import java.util.concurrent.TimeUnit;

public class StreamFileSinkDemo {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.enableCheckpointing(TimeUnit.SECONDS.toMillis(10));
        env.setStateBackend(new FsStateBackend("file:///D:/ckp"));

        //2.source
        DataStreamSource<String> lines = env.socketTextStream("node1", 9999);

        //3.sink
        //设置sink的前缀和后缀
        //文件的头和文件扩展名
        //prefix-xxx-.txt
        OutputFileConfig config = OutputFileConfig
                .builder()
                .withPartPrefix("prefix")
                .withPartSuffix(".txt")
                .build();

        //设置sink的路径
        String outputPath = "hdfs://node1:8020/FlinkStreamFileSink/parquet";

        //创建StreamingFileSink
        final StreamingFileSink<String> sink = StreamingFileSink
                .forRowFormat(
                        new Path(outputPath),
                        new SimpleStringEncoder<String>("UTF-8"))
                /**
                 * 设置桶分配政策
                 * DateTimeBucketAssigner --默认的桶分配政策，默认基于时间的分配器，每小时产生一个桶，格式如下yyyy-MM-dd--HH
                 * BasePathBucketAssigner ：将所有部分文件（part file）存储在基本路径中的分配器（单个全局桶）
                 */
                .withBucketAssigner(new DateTimeBucketAssigner<>())
                /**
                 * 有三种滚动政策
                 *  CheckpointRollingPolicy
                 *  DefaultRollingPolicy
                 *  OnCheckpointRollingPolicy
                 */
                .withRollingPolicy(
                        /**
                         * 滚动策略决定了写出文件的状态变化过程
                         * 1. In-progress ：当前文件正在写入中
                         * 2. Pending ：当处于 In-progress 状态的文件关闭（closed）了，就变为 Pending 状态
                         * 3. Finished ：在成功的 Checkpoint 后，Pending 状态将变为 Finished 状态
                         *
                         * 观察到的现象
                         * 1.会根据本地时间和时区，先创建桶目录
                         * 2.文件名称规则：part-<subtaskIndex>-<partFileIndex>
                         * 3.在macos中默认不显示隐藏文件，需要显示隐藏文件才能看到处于In-progress和Pending状态的文件，因为文件是按照.开头命名的
                         *
                         */
                        DefaultRollingPolicy.builder()
                                .withRolloverInterval(TimeUnit.SECONDS.toMillis(2)) //设置滚动间隔
                                .withInactivityInterval(TimeUnit.SECONDS.toMillis(1)) //设置不活动时间间隔
                                .withMaxPartSize(1024 * 1024 * 1024) // 最大尺寸
                                .build())
                .withOutputFileConfig(config)
                .build();

        lines.addSink(sink).setParallelism(1);

        env.execute();
    }
}
```

#### 扩展阅读:配置详解

##### PartFile

前面提到过，每个Bukcket内部分为多个部分文件，该Bucket内接收到数据的sink的每个子任务至少有一个PartFile。而额外文件滚动由可配的滚动策略决定。

**关于顺序性**

对于任何给定的Flink子任务，PartFile索引都严格增加（按创建顺序），但是，这些索引并不总是顺序的。当作业重新启动时，所有子任务的下一个PartFile索引将是max PartFile索引+ 1，其中max是指在所有子任务中对所有计算的索引最大值。

```
return new Path(bucketPath, outputFileConfig.getPartPrefix() + '-' + subtaskIndex + '-' + partCounter + outputFileConfig.getPartSuffix());
```

###### PartFile生命周期

输出文件的命名规则和生命周期。由上图可知，部分文件（part file）可以处于以下三种状态之一：

**In-progress ：当前文件正在写入中**

**Pending ：**当处于 In-progress 状态的文件关闭（closed）了，就变为 Pending 状态

**Finished ：**在成功的 Checkpoint 后，Pending 状态将变为 Finished 状态,处于 Finished 状态的文件不会再被修改，可以被下游系统安全地读取。

注意： 
使用 StreamingFileSink 时需要启用 Checkpoint ，每次做 Checkpoint 时写入完成。如果 Checkpoint 被禁用，部分文件（part file）将永远处于 'in-progress' 或 'pending' 状态，下游系统无法安全地读取。

###### PartFile的生成规则

在每个活跃的Bucket期间，每个Writer的子任务在任何时候都只会有一个单独的In-progress PartFile，但可有多个Peding和Finished状态文件。
一个Sink的两个Subtask的PartFile分布情况实例如下:

初始状态，两个inprogress文件正在被两个subtask分别写入

```
└── 2020-03-25--12
    ├── part-0-0.inprogress.bd053eb0-5ecf-4c85-8433-9eff486ac334
    └── part-1-0.inprogress.ea65a428-a1d0-4a0b-bbc5-7a436a75e575
```

当part-1-0因文件大小超过阈值等原因发生滚动时，变为Pending状态等待完成，但此时不会被重命名。注意此时Sink会创建一个新的PartFile即part-1-1：

```
└── 2020-03-25--12
    ├── part-0-0.inprogress.bd053eb0-5ecf-4c85-8433-9eff486ac334
    ├── part-1-0.inprogress.ea65a428-a1d0-4a0b-bbc5-7a436a75e575
    └── part-1-1.inprogress.bc279efe-b16f-47d8-b828-00ef6e2fbd11
```

待下次checkpoint成功后，part-1-0完成变为Finished状态，被重命名：

```
└── 2020-03-25--12
    ├── part-0-0.inprogress.bd053eb0-5ecf-4c85-8433-9eff486ac334
    ├── part-1-0
    └── part-1-1.inprogress.bc279efe-b16f-47d8-b828-00ef6e2fbd11
```

下一个Bucket周期到了，创建新的Bucket目录，不影响之前Bucket内的的in-progress文件，依然要等待文件RollingPolicy以及checkpoint来改变状态：

```
└── 2020-03-25--12
    ├── part-0-0.inprogress.bd053eb0-5ecf-4c85-8433-9eff486ac334
    ├── part-1-0
    └── part-1-1.inprogress.bc279efe-b16f-47d8-b828-00ef6e2fbd11
└── 2020-03-25--13
    └── part-0-2.inprogress.2b475fec-1482-4dea-9946-eb4353b475f1
```

###### PartFile命名设置

默认，PartFile命名规则如下：

```
In-progress / Pending
part--.inprogress.uid
Finished
part--
```

比如part-1-20表示1号子任务已完成的20号文件。
可以使用OutputFileConfig来改变前缀和后缀，代码示例如下：

```
OutputFileConfig config = OutputFileConfig
 .builder()
 .withPartPrefix("prefix")
 .withPartSuffix(".ext")
 .build()
  
StreamingFileSink sink = StreamingFileSink
 .forRowFormat(new Path(outputPath), new SimpleStringEncoder<String>("UTF-8"))
 .withBucketAssigner(new KeyBucketAssigner())
 .withRollingPolicy(OnCheckpointRollingPolicy.build())
 .withOutputFileConfig(config)
 .build()
```

得到的PartFile示例如下

```
└── 2019-08-25--12
    ├── prefix-0-0.ext
    ├── prefix-0-1.ext.inprogress.bd053eb0-5ecf-4c85-8433-9eff486ac334
    ├── prefix-1-0.ext
    └── prefix-1-1.ext.inprogress.bc279efe-b16f-47d8-b828-00ef6e2fbd11
```

> 枫叶云笔记的markdown写到这里无论如何也写不下去了，再写就崩溃，或者写上了保存不到云端。所以新开了一个笔记。

##### PartFile序列化编码

StreamingFileSink 支持行编码格式和批量编码格式，比如 Apache Parquet 。这两种变体可以使用以下静态方法创建：

**Row-encoded sink:**

StreamingFileSink.forRowFormat(basePath, rowEncoder)

```
//行
StreamingFileSink.forRowFormat(new Path(path), new SimpleStringEncoder<T>())
        .withBucketAssigner(new PaulAssigner<>()) //分桶策略
        .withRollingPolicy(new PaulRollingPolicy<>()) //滚动策略
        .withBucketCheckInterval(CHECK_INTERVAL) //检查周期
        .build();
```

**Bulk-encoded sink:**

StreamingFileSink.forBulkFormat(basePath, bulkWriterFactory)

```
//列 parquet
StreamingFileSink.forBulkFormat(new Path(path), ParquetAvroWriters.forReflectRecord(clazz))
        .withBucketAssigner(new PaulBucketAssigner<>())
        .withBucketCheckInterval(CHECK_INTERVAL)
        .build();
```

创建行或批量编码的 Sink 时，我们需要指定存储桶的基本路径和数据的编码
这两种写入格式除了文件格式的不同，另外一个很重要的区别就是回滚策略的不同：

1. forRowFormat行写可基于文件大小、滚动时间、不活跃时间进行滚动，
2. forBulkFormat列写方式只能基于checkpoint机制进行文件滚动，即在执行snapshotState方法时滚动文件，如果基于大小或者时间滚动文件，那么在任务失败恢复时就必须对处于in-processing状态的文件按照指定的offset进行truncate，由于列式存储是无法针对文件offset进行truncate的，因此就必须在每次checkpoint使文件滚动，其使用的滚动策略实现是OnCheckpointRollingPolicy。

forBulkFormat只能和 `OnCheckpointRollingPolicy` 结合使用，每次做 checkpoint 时滚动文件。

###### Row Encoding

此时，StreamingFileSink会以每条记录为单位进行编码和序列化。
必须配置项：

1. 输出数据的BasePath
2. 序列化每行数据写入PartFile的Encoder

使用RowFormatBuilder可选配置项：

1. 自定义RollingPolicy。默认使用DefaultRollingPolicy来滚动文件，可自定义
2. bucketCheckInterval 。默认1分钟。该值单位为毫秒，指定按时间滚动文件间隔时间

例子如下：

```
import org.apache.flink.api.common.serialization.SimpleStringEncoder
import org.apache.flink.core.fs.Path
import org.apache.flink.streaming.api.functions.sink.filesystem.StreamingFileSink

// 1. 构建DataStream
DataStream input  = ...
// 2. 构建StreamingFileSink，指定BasePath、Encoder、RollingPolicy
StreamingFileSink sink  = StreamingFileSink
    .forRowFormat(new Path(outputPath), new SimpleStringEncoder[String]("UTF-8"))
    .withRollingPolicy(
        DefaultRollingPolicy.builder()
            .withRolloverInterval(TimeUnit.MINUTES.toMillis(15))
            .withInactivityInterval(TimeUnit.MINUTES.toMillis(5))
            .withMaxPartSize(1024 * 1024 * 1024)
            .build())
    .build()
// 3. 添加Sink到InputDataSteam即可
input.addSink(sink)
```

以上例子构建了一个简单的拥有默认Bucket构建行为（继承自BucketAssigner的DateTimeBucketAssigner）的StreamingFileSink，每小时构建一个Bucket，内部使用继承自RollingPolicy的DefaultRollingPolicy，以下三种情况任一发生会滚动PartFile：

1. PartFile包含至少15分钟的数据
2. 在过去5分钟内没有接收到新数据
3. 在最后一条记录写入后，文件大小已经达到1GB

除了使用DefaultRollingPolicy，也可以自己实现RollingPolicy接口来实现自定义滚动策略。

###### Bulk Encoding

要使用批量编码，请将StreamingFileSink.forRowFormat()替换为StreamingFileSink.forBulkFormat()，注意此时必须指定一个BulkWriter.Factory而不是行模式的Encoder。BulkWriter在逻辑上定义了如何添加、fllush新记录以及如何最终确定记录的bulk以用于进一步编码。
需要注意的是，使用Bulk Encoding时，Filnk1.9版本的文件滚动就只能使用OnCheckpointRollingPolicy的策略，该策略在每次checkpoint时滚动part-file。

Flink有三个内嵌的BulkWriter：

1. ParquetAvroWriters

有一些静态方法来创建ParquetWriterFactory。

1. SequenceFileWriterFactory
2. CompressWriterFactory

Flink有内置方法可用于为Avro数据创建Parquet writer factory。
要使用ParquetBulkEncoder，需要添加以下Maven依赖：

```
<!-- streaming File Sink所需要的jar包-->
<dependency>
    <groupId>org.apache.flink</groupId>
    <artifactId>flink-parquet_2.12</artifactId>
    <version>1.12.0</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.apache.avro/avro -->
<dependency>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro</artifactId>
    <version>1.12.0</version>
</dependency>

<dependency>
    <groupId>org.apache.parquet</groupId>
    <artifactId>parquet-avro</artifactId>
    <version>1.12.0</version>
</dependency>
```

##### 桶分配策略

桶分配策略定义了将数据结构化后写入基本输出目录中的子目录，行格式和批量格式都需要使用。
具体来说，StreamingFileSink使用BucketAssigner来确定每条输入的数据应该被放入哪个Bucket，
默认情况下，DateTimeBucketAssigner 基于系统默认时区每小时创建一个桶：
格式如下：yyyy-MM-dd--HH。日期格式（即桶的大小）和时区都可以手动配置。
我们可以在格式构建器上调用 .withBucketAssigner(assigner) 来自定义 BucketAssigner。
Flink 有两个内置的 BucketAssigners ：

1. DateTimeBucketAssigner：默认基于时间的分配器
2. BasePathBucketAssigner：将所有部分文件（part file）存储在基本路径中的分配器（单个全局桶）

###### DateTimeBucketAssigner

Row格式和Bulk格式编码都使用DateTimeBucketAssigner作为默认BucketAssigner。 默认情况下，DateTimeBucketAssigner 基于系统默认时区每小时以格式yyyy-MM-dd--HH来创建一个Bucket，Bucket路径为/{basePath}/{dateTimePath}/。

1. basePath是指StreamingFileSink.forRowFormat(new Path(outputPath)时的路径
2. dateTimePath中的日期格式和时区都可在初始化DateTimeBucketAssigner时配置

```
public class DateTimeBucketAssigner<IN> implements BucketAssigner<IN, String> {
private static final long serialVersionUID = 1L;

	// 默认的时间格式字符串
	private static final String DEFAULT_FORMAT_STRING = "yyyy-MM-dd--HH";

	// 时间格式字符串
	private final String formatString;

	// 时区
	private final ZoneId zoneId;

	// DateTimeFormatter被用来通过当前系统时间和DateTimeFormat来生成时间字符串
	private transient DateTimeFormatter dateTimeFormatter;

	/**
	 * 使用默认的`yyyy-MM-dd--HH`和系统时区构建DateTimeBucketAssigner
	 */
	public DateTimeBucketAssigner() {
		this(DEFAULT_FORMAT_STRING);
	}

	/**
	 * 通过能被SimpleDateFormat解析的时间字符串和系统时区
	 * 来构建DateTimeBucketAssigner
	 */
	public DateTimeBucketAssigner(String formatString) {
		this(formatString, ZoneId.systemDefault());
	}

	/**
	 * 通过默认的`yyyy-MM-dd--HH`和指定的时区
	 * 来构建DateTimeBucketAssigner
	 */
	public DateTimeBucketAssigner(ZoneId zoneId) {
		this(DEFAULT_FORMAT_STRING, zoneId);
	}

	/**
	 * 通过能被SimpleDateFormat解析的时间字符串和指定的时区
	 * 来构建DateTimeBucketAssigner
	 */
	public DateTimeBucketAssigner(String formatString, ZoneId zoneId) {
		this.formatString = Preconditions.checkNotNull(formatString);
		this.zoneId = Preconditions.checkNotNull(zoneId);
	}

	/**
	 * 使用指定的时间格式和时区来格式化当前ProcessingTime，以获取BucketId
	 */
	@Override
	public String getBucketId(IN element, BucketAssigner.Context context) {
		if (dateTimeFormatter == null) {
			dateTimeFormatter = DateTimeFormatter.ofPattern(formatString).withZone(zoneId);
		}
		return dateTimeFormatter.format(Instant.ofEpochMilli(context.currentProcessingTime()));
	}

	@Override
	public SimpleVersionedSerializer<String> getSerializer() {
		return SimpleVersionedStringSerializer.INSTANCE;
	}

	@Override
	public String toString() {
		return "DateTimeBucketAssigner{" +
			"formatString='" + formatString + '\'' +
			", zoneId=" + zoneId +
			'}';
	}
}
```

###### BasePathBucketAssigner

将所有PartFile存储在BasePath中（此时只有单个全局Bucket）。
先看看BasePathBucketAssigner的源码，方便继续学习DateTimeBucketAssigner：

```
@PublicEvolving
public class BasePathBucketAssigner<T> implements BucketAssigner<T, String> {
	private static final long serialVersionUID = -6033643155550226022L;
	/**
	 * BucketId永远为""，即Bucket全路径为用户指定的BasePath
	 */
	@Override
	public String getBucketId(T element, BucketAssigner.Context context) {
		return "";
	}
	/**
	 * 用SimpleVersionedStringSerializer来序列化BucketId
	 */
	@Override
	public SimpleVersionedSerializer<String> getSerializer() {
		// in the future this could be optimized as it is the empty string.
		return SimpleVersionedStringSerializer.INSTANCE;
	}

	@Override
	public String toString() {
		return "BasePathBucketAssigner";
	}
}
```

##### 滚动策略

滚动策略 RollingPolicy 定义了指定的文件在何时关闭（closed）并将其变为 Pending 状态，随后变为 Finished 状态。处于 Pending 状态的文件会在下一次 Checkpoint 时变为 Finished 状态，通过设置 Checkpoint 间隔时间，可以控制部分文件（part file）对下游读取者可用的速度、大小和数量。
Flink 有两个内置的滚动策略：

1. DefaultRollingPolicy
2. OnCheckpointRollingPolicy

需要注意的是，使用Bulk Encoding时，文件滚动就只能使用OnCheckpointRollingPolicy的策略，该策略在每次checkpoint时滚动part-file。

### File Sink

#### 介绍

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/file_sink.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/connectors/file_sink.html)

![image.png](https://image.hyly.net/i/2025/09/28/cd8a6976ca4942f6941e9c2d21d0e1bc-0.webp)

新的 Data Sink API (Beta)
之前发布的 Flink 版本中[1]，已经支持了 source connector 工作在流批两种模式下，因此在 Flink 1.12 中，社区着重实现了统一的 Data Sink API（FLIP-143）。新的抽象引入了 write/commit 协议和一个更加模块化的接口。Sink 的实现者只需要定义 what 和 how：SinkWriter，用于写数据，并输出需要 commit 的内容（例如，committables）；Committer 和 GlobalCommitter，封装了如何处理 committables。框架会负责 when 和 where：即在什么时间，以及在哪些机器或进程中 commit。

![image.png](https://image.hyly.net/i/2025/09/28/456d91cc0e6a57f10f6a690771002d18-0.webp)

这种模块化的抽象允许为 BATCH 和 STREAMING 两种执行模式，实现不同的运行时策略，以达到仅使用一种 sink 实现，也可以使两种模式都可以高效执行。Flink 1.12 中，提供了统一的 FileSink connector，以替换现有的 StreamingFileSink connector （FLINK-19758）。其它的 connector 也将逐步迁移到新的接口。

Flink 1.12的 FileSink 为批处理和流式处理提供了一个统一的接收器，它将分区文件写入Flink文件系统抽象所支持的文件系统。这个文件系统连接器为批处理和流式处理提供了相同的保证，它是现有流式文件接收器的一种改进。

#### 案例演示

```
package cn.itcast.extend;

import org.apache.flink.api.common.serialization.SimpleStringEncoder;
import org.apache.flink.connector.file.sink.FileSink;
import org.apache.flink.core.fs.Path;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.datastream.DataStreamSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.filesystem.OutputFileConfig;
import org.apache.flink.streaming.api.functions.sink.filesystem.bucketassigners.DateTimeBucketAssigner;
import org.apache.flink.streaming.api.functions.sink.filesystem.rollingpolicies.DefaultRollingPolicy;

import java.util.concurrent.TimeUnit;

/**
 * Author itcast
 * Desc
 */
public class FileSinkDemo {
    public static void main(String[] args) throws Exception {
        //1.env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.enableCheckpointing(TimeUnit.SECONDS.toMillis(10));
        env.setStateBackend(new FsStateBackend("file:///D:/ckp"));

        //2.source
        DataStreamSource<String> lines = env.socketTextStream("node1", 9999);

        //3.sink
        //设置sink的前缀和后缀
        //文件的头和文件扩展名
        //prefix-xxx-.txt
        OutputFileConfig config = OutputFileConfig
                .builder()
                .withPartPrefix("prefix")
                .withPartSuffix(".txt")
                .build();

        //设置sink的路径
        String outputPath = "hdfs://node1:8020/FlinkFileSink/parquet";

        final FileSink<String> sink = FileSink
                .forRowFormat(new Path(outputPath), new SimpleStringEncoder<String>("UTF-8"))
                .withBucketAssigner(new DateTimeBucketAssigner<>())
                .withRollingPolicy(
                        DefaultRollingPolicy.builder()
                                .withRolloverInterval(TimeUnit.MINUTES.toMillis(15))
                                .withInactivityInterval(TimeUnit.MINUTES.toMillis(5))
                                .withMaxPartSize(1024 * 1024 * 1024)
                                .build())
                .withOutputFileConfig(config)
                .build();

        lines.sinkTo(sink).setParallelism(1);

        env.execute();
    }
}
```

### FlinkSQL整合Hive

#### 介绍

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/hive/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/hive/)

[https://zhuanlan.zhihu.com/p/338506408](https://zhuanlan.zhihu.com/p/338506408)

使用Hive构建数据仓库已经成为了比较普遍的一种解决方案。目前，一些比较常见的大数据处理引擎，都无一例外兼容Hive。Flink从1.9开始支持集成Hive，不过1.9版本为beta版，不推荐在生产环境中使用。在Flink1.10版本中，标志着对 Blink的整合宣告完成，对 Hive 的集成也达到了生产级别的要求。值得注意的是，不同版本的Flink对于Hive的集成有所差异，接下来将以最新的Flink1.12版本为例，实现Flink集成Hive

#### 集成Hive的基本方式

Flink 与 Hive 的集成主要体现在以下两个方面:

**持久化元数据**

Flink利用 Hive 的 MetaStore 作为持久化的 Catalog，我们可通过HiveCatalog将不同会话中的 Flink 元数据存储到 Hive Metastore 中。例如，我们可以使用HiveCatalog将其 Kafka的数据源表存储在 Hive Metastore 中，这样该表的元数据信息会被持久化到Hive的MetaStore对应的元数据库中，在后续的 SQL 查询中，我们可以重复使用它们。

**利用 Flink 来读写 Hive 的表**

Flink打通了与Hive的集成，如同使用SparkSQL或者Impala操作Hive中的数据一样，我们可以使用Flink直接读写Hive中的表。

HiveCatalog的设计提供了与 Hive 良好的兼容性，用户可以”开箱即用”的访问其已有的 Hive表。不需要修改现有的 Hive Metastore，也不需要更改表的数据位置或分区。

#### 准备工作

1.添加hadoop_classpath
vim /etc/profile
增加如下配置
export HADOOP_CLASSPATH=`hadoop classpath`
刷新配置
source /etc/profile

2.下载jar并上传至flink/lib目录

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/hive/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/hive/)

![image.png](https://image.hyly.net/i/2025/09/28/e2f61a785a65b33f68074fd88c1fd3ae-0.webp)

3.修改hive配置

```
vim /export/server/hive/conf/hive-site.xml

<property>
        <name>hive.metastore.uris</name>
        <value>thrift://node3:9083</value>
</property>
```

4.启动hive元数据服务
nohup /export/server/hive/bin/hive --service metastore &

#### SQL CLI

1.修改flinksql配置

```
vim /export/server/flink/conf/sql-client-defaults.yaml
```

增加如下配置

```
catalogs:
   - name: myhive
     type: hive
     hive-conf-dir: /export/server/hive/conf
     default-database: default
```

2.启动flink集群

```
/export/server/flink/bin/start-cluster.sh
```

3.启动flink-sql客户端

```
/export/server/flink/bin/sql-client.sh embedded
```

4.执行sql:

```
show catalogs;
use catalog myhive;
show tables;
select * from person;
```

#### 代码演示

```
package cn.itcast.extend;

import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.TableEnvironment;
import org.apache.flink.table.api.TableResult;
import org.apache.flink.table.catalog.hive.HiveCatalog;

/**
 * Author itcast
 * Desc
 */
public class HiveDemo {
    public static void main(String[] args){
        EnvironmentSettings settings = EnvironmentSettings.newInstance().useBlinkPlanner().build();
        TableEnvironment tableEnv = TableEnvironment.create(settings);

        String name            = "myhive";
        String defaultDatabase = "default";
        String hiveConfDir = "./conf";

        HiveCatalog hive = new HiveCatalog(name, defaultDatabase, hiveConfDir);
        //注册catalog
        tableEnv.registerCatalog("myhive", hive);
        //使用注册的catalog
        tableEnv.useCatalog("myhive");

        //向Hive表中写入数据
        String insertSQL = "insert into person select * from person";
        TableResult result = tableEnv.executeSql(insertSQL);

        System.out.println(result.getJobClient().get().getJobStatus());
    }
}
```

## Flink多语言开发

### Scala-Flink

#### 需求

使用Flink从Kafka接收对电商点击流日志数据并进行实时处理:
1.数据预处理:对数据进行拓宽处理,也就是将数据变为宽表,方便后续分析
2.分析实时频道热点
3.分析实时频道PV/UV

#### 准备工作

**kafka**

```
查看主题:
    /export/servers/kafka/bin/kafka-topics.sh --list --zookeeper node01:2181
创建主题:
    /export/servers/kafka/bin/kafka-topics.sh --create --zookeeper node01:2181 --replication-factor 2 --partitions 3 --topic pyg
再次查看主题:
    /export/servers/kafka/bin/kafka-topics.sh --list --zookeeper node01:2181
启动控制台消费者
    /export/servers/kafka/bin/kafka-console-consumer.sh --bootstrap-server node01:9092 --from-beginning --topic pyg
删除主题--不需要执行
    /export/servers/kafka/bin/kafka-topics.sh --delete --zookeeper node01:2181 --topic pyg
```

**导入准备骨架代码**

![image.png](https://image.hyly.net/i/2025/09/28/ed5d4e6eb58591f5a74f4dbd67a2b547-0.webp)

#### 代码实现

##### 入口类-数据解析

![image.png](https://image.hyly.net/i/2025/09/28/25f7338ebc2ac031a1a17105e645250b-0.webp)

```
package cn.itcast

import java.lang
import java.util.Properties
import java.util.concurrent.TimeUnit

import cn.itcast.bean.{ClickLog, ClickLogWide, Message}
import cn.itcast.task.{ChannelRealHotTask, ChannelRealPvUvTask, ProcessTask}
import com.alibaba.fastjson.{JSON, JSONObject}
import org.apache.flink.api.common.restartstrategy.RestartStrategies
import org.apache.flink.api.common.serialization.SimpleStringSchema
import org.apache.flink.runtime.state.filesystem.FsStateBackend
import org.apache.flink.streaming.api.environment.CheckpointConfig.ExternalizedCheckpointCleanup
import org.apache.flink.streaming.api.functions.timestamps.BoundedOutOfOrdernessTimestampExtractor
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.{CheckpointingMode, TimeCharacteristic}
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer
import org.apache.kafka.clients.CommonClientConfigs

/**
 * Author itcast
 * Desc 编写Flink实时流处理-入口程序(这都是通用模版代码,这里写一遍,明天再做抽取,以后开发都可以直接使用)
 */
object App {
  def main(args: Array[String]): Unit = {
    //注意:TODO在开发中表示该步骤未完成,后续需要补全
    //在这里仅仅为了使用不同的颜色区分步骤
    //TODO 1.准备环境StreamExecutionEnvironment
    val env: StreamExecutionEnvironment = StreamExecutionEnvironment.getExecutionEnvironment
    //TODO 2.设置环境参数(Checkpoint/重启策略/是否使用事件时间...)
    //=================建议必须设置的===================
    //设置Checkpoint-State的状态后端为FsStateBackend,本地测试时使用本地路径,集群测试时使用传入的HDFS的路径
    if(args.length<1){
      env.setStateBackend(new FsStateBackend("file:///D:/ckp"))
    }else{
      env.setStateBackend(new FsStateBackend(args(0)))//后续集群测试时传入hdfs://node01:8020/flink-checkpoint/checkpoint
    }
    //设置Checkpointing时间间隔为1000ms,意思是做 2 个 Checkpoint 的间隔为1000ms。Checkpoint 做的越频繁，恢复数据时就越简单，同时 Checkpoint 相应的也会有一些IO消耗。
    env.enableCheckpointing(1000)//(默认情况下如果不设置时间checkpoint是没有开启的)
    //设置两个Checkpoint 之间最少等待时间,如设置Checkpoint之间最少是要等 500ms(为了避免每隔1000ms做一次Checkpoint的时候,前一次太慢和后一次重叠到一起去了)
    //如:高速公路上,每隔1s关口放行一辆车,但是规定了两车之前的最小车距为500m
    env.getCheckpointConfig.setMinPauseBetweenCheckpoints(500)//默认是0
    //设置如果在做Checkpoint过程中出现错误，是否让整体任务失败：true是  false不是
    env.getCheckpointConfig.setFailOnCheckpointingErrors(false)//默认是true
    //设置是否清理检查点,表示 Cancel 时是否需要保留当前的 Checkpoint，默认 Checkpoint会在作业被Cancel时被删除
    //ExternalizedCheckpointCleanup.DELETE_ON_CANCELLATION：true,当作业被取消时，删除外部的checkpoint(默认值)
    //ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION：false,当作业被取消时，保留外部的checkpoint
    env.getCheckpointConfig.enableExternalizedCheckpoints(ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION)
    //=================建议必须设置的===================

    //=================直接使用默认的即可===============
    //设置checkpoint的执行模式为EXACTLY_ONCE(默认),注意:得需要外部支持,如Source和Sink的支持
    env.getCheckpointConfig.setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE)
    //设置checkpoint的超时时间,如果 Checkpoint在 60s内尚未完成说明该次Checkpoint失败,则丢弃。
    env.getCheckpointConfig.setCheckpointTimeout(60000)//默认10分钟
    //设置同一时间有多少个checkpoint可以同时执行
    env.getCheckpointConfig.setMaxConcurrentCheckpoints(1)//默认为1
    //=================直接使用默认的即可===============


    //======================配置重启策略==============
    //1.如果配置了Checkpoint,而没有配置重启策略,那么代码中出现了非致命错误时,程序会无限重启
    //2.配置无重启策略
    //env.setRestartStrategy(RestartStrategies.noRestart())
    //3.固定延迟重启策略--开发中使用
    //如下:如果有异常,每隔10s重启1次,最多3次
    env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
      3, // 最多重启3次数
      org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS) // 重启时间间隔
    ))
    //4.失败率重启策略--开发偶尔使用
    //如下:5分钟内,最多重启3次,每次间隔10
    /*env.setRestartStrategy(RestartStrategies.failureRateRestart(
      3, // 每个测量时间间隔最大失败次数
      Time.of(5, TimeUnit.MINUTES), //失败率测量的时间间隔
      Time.of(10, TimeUnit.SECONDS) // 两次连续重启的时间间隔
    ))*/
    //======================配置重启策略==============

    //TODO 3.Source-Kafka
    val topic: String = "pyg"
    val schema = new SimpleStringSchema()
    val props:Properties = new Properties()
    props.setProperty(CommonClientConfigs.BOOTSTRAP_SERVERS_CONFIG,"node1:9092")
    props.setProperty("group.id","flink")
    props.setProperty("auto.offset.reset","latest")//如果有记录偏移量从记录的位置开始消费,如果没有从最新的数据开始消费
    props.setProperty("flink.partition-discovery.interval-millis","5000")//动态分区检测,开一个后台线程每隔5s检查Kafka的分区状态

    val kafkaSource: FlinkKafkaConsumer[String] = new FlinkKafkaConsumer[String](topic,schema,props)
    kafkaSource.setCommitOffsetsOnCheckpoints(true)//在执行Checkpoint的时候,会提交offset(一份在Checkpoint中,一份在默认主题)

    val jsonStrDS: DataStream[String] = env.addSource(kafkaSource)
    //jsonStrDS.print()
    // {"count":1,"message":"{\"browserType\":\"火狐\",\"categoryID\":20,\"channelID\":20,\"city\":\"ZhengZhou\",\"country\":\"china\",\"entryTime\":1577898060000,\"leaveTime\":1577898060000,\"network\":\"电信\",\"produceID\":15,\"province\":\"HeBei\",\"source\":\"直接输入\",\"userID\":2}","timeStamp":1598754734031}

    //TODO 4.解析jsonStr数据为样例类Message
    val messageDS: DataStream[Message] = jsonStrDS.map(jsonStr => {
      val jsonObj: JSONObject = JSON.parseObject(jsonStr)
      val count: lang.Long = jsonObj.getLong("count")
      val timeStamp: lang.Long = jsonObj.getLong("timeStamp")
      val clickLogStr: String = jsonObj.getString("message")
      val clickLog: ClickLog = JSON.parseObject(clickLogStr, classOf[ClickLog])
      Message(clickLog, count, timeStamp)
      //不能使用下面偷懒的办法
      //val message: Message = JSON.parseObject(jsonStr,classOf[Message])
    })
    //messageDS.print()
    //Message(ClickLog(10,10,3,china,HeBei,ZhengZhou,电信,360搜索跳转,谷歌浏览器,1577876460000,1577898060000,15),1,1598754740100)

    //TODO 5.给数据添加Watermaker(或者放在第6步)
    env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime)
    env.getConfig.setAutoWatermarkInterval(200)
    val watermakerDS: DataStream[Message] = messageDS.assignTimestampsAndWatermarks(
      new BoundedOutOfOrdernessTimestampExtractor[Message](org.apache.flink.streaming.api.windowing.time.Time.seconds(5)) {
        override def extractTimestamp(element: Message): Long = element.timeStamp
      }
    )

    //TODO 6.数据预处理
    //为了方便后续的指标统计,可以对上面解析处理的日志信息Message进行预处理,如拓宽字段
    //预处理的代码可以写在这里,也可以单独抽取出一个方法来完成,也可以单独抽取一个object.方法来完成
    //把DataStream[Message]拓宽为DataStream[ClickLogWide]
    val clickLogWideDS: DataStream[ClickLogWide] = ProcessTask.process(watermakerDS)
    clickLogWideDS.print()
    //ClickLogWide(18,9,10,china,HeNan,LuoYang,移动,百度跳转,谷歌浏览器,1577887260000,1577898060000,15,1,1598758614216,chinaHeNanLuoYang,202008,20200830,2020083011,0,0,0,0)


    //TODO 7.实时指标统计分析-直接sink结果到HBase
    //实时指标统计分析-实时频道热点
    ChannelRealHotTask.process(clickLogWideDS)
    //实时指标统计分析-实时频道分时段PV/UV
    ChannelRealPvUvTask.process(clickLogWideDS)


    //TODO 8.execute
    env.execute()
  }
}
```

##### 数据预处理

![image.png](https://image.hyly.net/i/2025/09/28/2dee5cd3b47d32d59a4d7611cd3564d2-0.webp)

为了方便后续分析，我们需要对点击流日志，使用Flink进行实时预处理。在原有点击流日志的基础上添加一些字段，方便进行后续业务功能的统计开发。

以下为Kafka中消费得到的原始点击流日志字段：

<figure class='table-figure'><table>
<thead>
<tr><th>字段名</th><th>说明</th></tr></thead>
<tbody><tr><td>channelID</td><td>频道ID</td></tr><tr><td>categoryID</td><td>产品类别ID</td></tr><tr><td>produceID</td><td>产品ID</td></tr><tr><td>country</td><td>国家</td></tr><tr><td>province</td><td>省份</td></tr><tr><td>city</td><td>城市</td></tr><tr><td>network</td><td>网络方式</td></tr><tr><td>source</td><td>来源方式</td></tr><tr><td>browserType</td><td>浏览器类型</td></tr><tr><td>entryTime</td><td>进入网站时间</td></tr><tr><td>leaveTime</td><td>离开网站时间</td></tr><tr><td>userID</td><td>用户的ID</td></tr></tbody>
</table></figure>

我们需要在原有点击流日志字段基础上，再添加以下字段：

<figure class='table-figure'><table>
<thead>
<tr><th>字段名</th><th>说明</th></tr></thead>
<tbody><tr><td>count</td><td>用户访问的次数</td></tr><tr><td>timestamp</td><td>用户访问的时间</td></tr><tr><td>address</td><td>国家省份城市（拼接）</td></tr><tr><td>yearMonth</td><td>年月</td></tr><tr><td>yearMonthDay</td><td>年月日</td></tr><tr><td>yearMonthDayHour</td><td>年月日时</td></tr><tr><td>isNew</td><td>是否为访问某个频道的新用户</td></tr><tr><td>isHourNew</td><td>在某一小时内是否为某个频道的新用户</td></tr><tr><td>isDayNew</td><td>在某一天是否为某个频道的新用户</td></tr><tr><td>isMonthNew</td><td>在某一个月是否为某个频道的新用户</td></tr></tbody>
</table></figure>

我们不能直接从点击流日志中，直接计算得到上述后4个字段的值。而是需要在hbase中有一个历史记录表，来保存用户的历史访问状态才能计算得到。
该历史记录表(user_history表)结构如下：

<figure class='table-figure'><table>
<thead>
<tr><th>列名</th><th>说明</th><th>示例</th></tr></thead>
<tbody><tr><td>rowkey</td><td>用户ID:频道ID</td><td>10:220</td></tr><tr><td>userid</td><td>用户ID</td><td>10</td></tr><tr><td>channelid</td><td>频道ID</td><td>220</td></tr><tr><td>lastVisitedTime</td><td>最后访问时间（时间戳）</td><td>1553653555</td></tr></tbody>
</table></figure>

```
package cn.itcast.task

import cn.itcast.bean.{ClickLogWide, Message}
import cn.itcast.util.{HBaseUtil, TimeUtil}
import org.apache.commons.lang3.StringUtils
import org.apache.flink.streaming.api.scala.DataStream

/**
 * Author itcast
 * Desc 数据预处理模块业务任务
 */
object ProcessTask {
  //将添加了水印的原始的用户行为日志数据根据需求转为宽表ClickLogWide并返回
  //将DataStream[Message]转为DataStream[ClickLogWide]
  def process(watermakerDS: DataStream[Message]): DataStream[ClickLogWide] = {
    import org.apache.flink.api.scala._
    val clickLogWideDS: DataStream[ClickLogWide] = watermakerDS.map(message => {
      val address: String = message.clickLog.country + message.clickLog.province + message.clickLog.city
      val yearMonth: String = TimeUtil.parseTime(message.timeStamp, "yyyyMM")
      val yearMonthDay: String = TimeUtil.parseTime(message.timeStamp, "yyyyMMdd")
      val yearMonthDayHour: String = TimeUtil.parseTime(message.timeStamp, "yyyyMMddHH")

      val (isNew, isHourNew, isDayNew, isMonthNew) = getIsNew(message)

      val clickLogWide = ClickLogWide(
        message.clickLog.channelID,
        message.clickLog.categoryID,
        message.clickLog.produceID,
        message.clickLog.country,
        message.clickLog.province,
        message.clickLog.city,
        message.clickLog.network,
        message.clickLog.source,
        message.clickLog.browserType,
        message.clickLog.entryTime,
        message.clickLog.leaveTime,
        message.clickLog.userID,

        message.count, //用户访问的次数
        message.timeStamp, //用户访问的时间

        address, //国家省份城市-拼接
        yearMonth, //年月
        yearMonthDay, //年月日
        yearMonthDayHour, //年月日时

        isNew, //是否为访问某个频道的新用户——0表示否，1表示是
        isHourNew, //在某一小时内是否为某个频道的新用户——0表示否，1表示是
        isDayNew, //在某一天是否为某个频道的新用户—0表示否，1表示是
        isMonthNew //在某一个月是否为某个频道的新用户——0表示否，1表示是
      )
      clickLogWide
    })
    clickLogWideDS
  }

  /*如:某用户,2020-08-30-11,第一次访问该频道
  那么这条日志
  isNew=1
  isHourNew=1
  isDayNew=1
  isMonthNew=1
  该用户2020-08-30-11,再次访问
  那么这条日志:
  isNew=0
  isHourNew=0
  isDayNew=0
  isMonthNew=0
  该用户2020-08-30-12,再次访问
  isNew=0
  isHourNew=1
  isDayNew=0
  isMonthNew=0
  该用户2020-08-31-09,再次访问
  isNew=0
  isHourNew=1
  isDayNew=1
  isMonthNew=0*/
  def getIsNew(msg: Message):(Int,Int,Int,Int) = {
    var isNew: Int = 0 //是否为访问某个频道的新用户——0表示否，1表示是
    var isHourNew: Int = 0 //在某一小时内是否为某个频道的新用户——0表示否，1表示是
    var isDayNew: Int = 0 //在某一天是否为某个频道的新用户—0表示否，1表示是
    var isMonthNew: Int = 0//在某一个月是否为某个频道的新用户——0表示否，1表示是

    //如何判断该用户是该频道的各个isxxNew?
    //可以把上次 该用户 访问 该频道 的 访问时间 记录在外部介质中,如HBase中
    //进来一条日志,先去HBase查该用户该频道的lastVisitTime
    //没有结果--isxxNew全是1
    //有结果--把这次访问时间和lastVisitTime进行比较

    //1.定义一些HBase的常量,如表名,列族名,字段名
    val tableName = "user_history"
    val columnFamily = "info"
    val rowkey = msg.clickLog.userID + ":" + msg.clickLog.channelID
    val queryColumn = "lastVisitTime"

    //2.根据该用户的该频道去查lastVisitTime
    //注意:记得修改resources/hbase-site.xml中的主机名,还得启动HBase
    val lastVisitTime: String = HBaseUtil.getData(tableName,rowkey,columnFamily,queryColumn)

    //3.判断lastVisitTime是否有值
    if(StringUtils.isBlank(lastVisitTime)){
      //如果lastVisitTime为空,说明该用户之前没有访问过该频道,全设置为1即可
      isNew = 1
      isHourNew = 1
      isDayNew = 1
      isMonthNew = 1
    }else{
      //如果lastVisitTime不为空,说明该用户之前访问过该频道,那么isxxNew给根据情况来赋值
      //如:lastVisitTime为2020-08-30-11,当前这一次访问时间为:2020-08-30-12,那么isHourNew=1,其他的为0
      //如:lastVisitTime为2020-08-30,当前这一次访问时间为:2020-08-31,那么isDayNew=1,其他的为0
      //如:lastVisitTime为2020-08,当前这一次访问时间为:2020-09,那么isMonthNew=1,其他的为0
      isNew = 0
      isHourNew = TimeUtil.compareDate(msg.timeStamp,lastVisitTime.toLong,"yyyyMMddHH")
      isDayNew = TimeUtil.compareDate(msg.timeStamp,lastVisitTime.toLong,"yyyyMMdd")
      isMonthNew = TimeUtil.compareDate(msg.timeStamp,lastVisitTime.toLong,"yyyyMM")
    }
    //不要忘了把这一次的访问时间作为lastVisitTime存入HBase
    HBaseUtil.putData(tableName,rowkey,columnFamily,queryColumn,msg.timeStamp.toString)

    (isNew,isHourNew,isDayNew,isMonthNew)

    //注意:
    /*
    测试时先启动hbase
     /export/servers/hbase/bin/start-hbase.sh
    再登入hbase shell
     ./hbase shell
    查看hbase表
    list
    运行后会生成表,然后查看表数据
    scan "user_history",{LIMIT=>10}
     */
  }
}
```

##### 实时频道热点

频道热点，就是要统计频道被访问（点击）的数量。
分析得到以下的数据：

<figure class='table-figure'><table>
<thead>
<tr><th>频道ID</th><th>访问数量</th></tr></thead>
<tbody><tr><td>频道ID1</td><td>128</td></tr><tr><td>频道ID2</td><td>401</td></tr><tr><td>频道ID3</td><td>501</td></tr></tbody>
</table></figure>

需要将历史的点击数据进行累加

```
package cn.itcast.task

import cn.itcast.bean.ClickLogWide
import cn.itcast.util.HBaseUtil
import org.apache.commons.lang3.StringUtils
import org.apache.flink.streaming.api.functions.sink.SinkFunction
import org.apache.flink.streaming.api.scala.DataStream
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * Author itcast
 * Desc 统计频道实时热点指标任务模块
 * 需求:每隔10s统计一次各个频道的访问次数
 */
object ChannelRealHotTask {

  //定义一个样例类,用来封装频道id和访问次数
  case class ChannelRealHot(channelId: String, visited: Long)

  //根据传入的用户行为日志宽表,进行频道的访问次数统计分析,并将结果保存到HBase
  def process(clickLogWideDS: DataStream[ClickLogWide]) = {
    import org.apache.flink.api.scala._
    //1.取出我们需要的字段channelID和count,并封装为样例类
    val result: DataStream[ChannelRealHot] = clickLogWideDS
      .map(clickLogWide => {
        ChannelRealHot(clickLogWide.channelID, clickLogWide.count)
      })
      //2.分组
      .keyBy(_.channelId)
      //3.窗口
      //ize: Time, slide: Time
      //需求:每隔10s统计一次各个频道的访问次数
      .timeWindow(Time.seconds(10))
      //4.聚合
      .reduce((c1, c2) => {
        ChannelRealHot(c2.channelId, c1.visited + c2.visited)
      })
    //5.结果存入HBase
    result.addSink(new SinkFunction[ChannelRealHot] {
      override def invoke(value: ChannelRealHot, context: SinkFunction.Context): Unit = {
        //在这里调用HBaseUtil将每条结果(每个频道的访问次数),保存到HBase
        //-1.先查HBase该频道的上次的访问次数
        val tableName = "channel_realhot"
        val columnFamily = "info"
        val queryColumn = "visited"
        val rowkey = value.channelId
        val historyValueStr: String = HBaseUtil.getData(tableName, rowkey, columnFamily, queryColumn)

        var currentFinalResult = 0L

        //-2.判断并合并结果
        if (StringUtils.isBlank(historyValueStr)) {
          //如果historyValueStr为空,直接让本次的次数作为本次最终的结果并保存
          currentFinalResult = value.visited
        } else {
          //如果historyValueStr不为空,本次的次数+历史值 作为本次最终的结果并保存
          currentFinalResult = value.visited + historyValueStr.toLong
        }

        //-3.存入本次最终的结果
        HBaseUtil.putData(tableName, rowkey, columnFamily, queryColumn, currentFinalResult.toString)
      }
    })
  }
}
```

##### 实时频道PV/UV

**PV(访问量)** 即Page View，页面刷新一次算一次。

**UV(独立访客)** 即Unique Visitor，指定时间内相同的客户端只被计算一次

统计分析后得到的数据如下所示：

<figure class='table-figure'><table>
<thead>
<tr><th>频道ID</th><th>时间</th><th>PV</th><th>UV</th></tr></thead>
<tbody><tr><td>频道1</td><td>2017010116</td><td>1230</td><td>350</td></tr><tr><td>频道1</td><td>20170101</td><td>4251</td><td>530</td></tr><tr><td>频道1</td><td>201701</td><td>5512</td><td>610</td></tr></tbody>
</table></figure>

```
package cn.itcast.task

import cn.itcast.bean.ClickLogWide
import cn.itcast.util.HBaseUtil
import org.apache.flink.streaming.api.functions.sink.SinkFunction
import org.apache.flink.streaming.api.scala.DataStream
import org.apache.flink.streaming.api.windowing.time.Time

/**
 * Author itcast
 * Desc 实时频道分时段PV/UV统计,结果示例如下:
 * 频道ID  时间       PV    UV
 * 频道1 202101     5512 610
 * 频道1 20210101   4251 530
 * 频道1 2021010116 1230 350
 * 注意:
 * pv可以使用条数统计
 * uv可以借助isxxNew字段
 */
object ChannelRealPvUvTask {

  case class ChannelRealPvUv(channelId: String, monthDayHour: String, pv: Long, uv: Long)

  def process(clickLogWideDS: DataStream[ClickLogWide]) = {
    import org.apache.flink.api.scala._
    //注意:
    // 每条宽表日志都有: yearMonth,yearMonthDay,yearMonthDayHour这3个字段,
    // 根据需求我们需要把1条日志根据这3个字段,变成3条数据,方便后面统计分时段PV/UV
    // 也就是说现在要将每1条数据变为3条数据!
    //使用flatMap
    //中国北京昌平张三
    // -->
    //中国,张三
    //中国北京,张三
    //中国北京昌平,张三

    //1.数据转换
    val result: DataStream[ChannelRealPvUv] = clickLogWideDS.flatMap(clickLogWide => {
      List(
        ChannelRealPvUv(clickLogWide.channelID, clickLogWide.yearMonth, clickLogWide.count, clickLogWide.isMonthNew),
        ChannelRealPvUv(clickLogWide.channelID, clickLogWide.yearMonthDay, clickLogWide.count, clickLogWide.isDayNew),
        ChannelRealPvUv(clickLogWide.channelID, clickLogWide.yearMonthDayHour, clickLogWide.count, clickLogWide.isHourNew)
      )
    })
    //2.分组
    .keyBy("channelId", "monthDayHour")
    //3.窗口
    .timeWindow(Time.seconds(10))
    //4.聚合
   .reduce((c1, c2) => {
      ChannelRealPvUv(c2.channelId, c2.monthDayHour, c1.pv + c2.pv, c1.uv + c2.uv)
    })
    //5.结果保存到HBase
    //注意:如果课下测试的时候,HBase性能跟不上,可以直接print打印能看到结果即可,下面的sink能看懂就行!
    //result.print()
    result.addSink(new SinkFunction[ChannelRealPvUv] {

      override def invoke(value: ChannelRealPvUv, context: SinkFunction.Context): Unit = {
        //-1.查
        val tableName = "channel_pvuv"
        val columnFamily = "info"
        val queryColumn1 = "pv"
        val queryColumn2 = "uv"
        val rowkey = value.channelId + ":" + value.monthDayHour

        val map: Map[String, String] = HBaseUtil.getMapData(tableName,rowkey,columnFamily,List(queryColumn1,queryColumn2))

       /* val pvhistoryValueStr: String = map.getOrElse(queryColumn1,null)
        val uvhistoryValueStr: String = map.getOrElse(queryColumn2,null)

        //-2.合
        var currentFinalPv = 0L
        var currentFinalUv = 0L

        if(StringUtils.isBlank(pvhistoryValueStr)){
          //如果pvhistoryValueStr为空,直接将本次该频道该时段的pv 作为 该频道该时段的本次最终的结果
          currentFinalPv = value.pv
        }else{
          //如果pvhistoryValueStr不为空,将本次该频道该时段的pv + pvhistoryValueStr 作为 该频道该时段的本次最终的结果
          currentFinalPv = value.pv + pvhistoryValueStr.toLong
        }

        if(StringUtils.isBlank(uvhistoryValueStr)){
          //如果uvhistoryValueStr为空,直接将本次该频道该时段的uv 作为 该频道该时段的本次最终的结果
          currentFinalUv = value.uv
        }else{
          //如果uvhistoryValueStr不为空,将本次该频道该时段的uv + uvhistoryValueStr 作为 该频道该时段的本次最终的结果
          currentFinalUv = value.uv + uvhistoryValueStr.toLong
        }*/

        val pvhistoryValueStr: String = map.getOrElse(queryColumn1,"0")
        val uvhistoryValueStr: String = map.getOrElse(queryColumn2,"0")

        val currentFinalPv = value.pv + pvhistoryValueStr.toLong
        val currentFinalUv = value.uv + uvhistoryValueStr.toLong

        //-3.存
        HBaseUtil.putMapData(tableName,rowkey,columnFamily,
          Map(
            (queryColumn1,currentFinalPv),
            (queryColumn2,currentFinalUv)
          )
        )
      }
    })
  }
}
```

### PyFlink-略

![image.png](https://image.hyly.net/i/2025/09/28/078bc22f28c9eb0d85049d6eee566829-0.webp)

#### 环境准备

pip install apache-flink
需要在网络环境好的条件下安装,估计用时2小时左右,因为需要下载很多其他的依赖

#### 官方文档

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/python/datastream_tutorial.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/python/datastream_tutorial.html)

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/python/table_api_tutorial.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/python/table_api_tutorial.html)

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/)

#### 代码示例

```
from pyflink.common.serialization import SimpleStringEncoder
from pyflink.common.typeinfo import Types
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.datastream.connectors import StreamingFileSink


def tutorial():
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)
    ds = env.from_collection(
        collection=["hadoop spark flink","hadoop spark","hadoop"],
        type_info=Types.STRING()
    )

    ds.print()

    result = ds.flat_map(lambda line: line.split(" "), result_type=Types.STRING())\
        .map(lambda word: (word, 1),output_type=Types.ROW([Types.STRING(), Types.INT()]))\
        .key_by(lambda x: x[0],key_type_info=Types.STRING())\
        .reduce(lambda a, b: a + b)

    result.print()

    result.add_sink(StreamingFileSink
                .for_row_format('data/output/result1', SimpleStringEncoder())
                .build())

    env.execute("tutorial_job")


if __name__ == '__main__':
    tutorial()
```

```
from pyflink.dataset import ExecutionEnvironment
from pyflink.table import TableConfig, DataTypes, BatchTableEnvironment
from pyflink.table.descriptors import Schema, OldCsv, FileSystem
from pyflink.table.expressions import lit

exec_env = ExecutionEnvironment.get_execution_environment()
exec_env.set_parallelism(1)
t_config = TableConfig()
t_env = BatchTableEnvironment.create(exec_env, t_config)

t_env.connect(FileSystem().path('data/input')) \
    .with_format(OldCsv()
                 .field('word', DataTypes.STRING())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())) \
    .create_temporary_table('mySource')

t_env.connect(FileSystem().path('/tmp/output')) \
    .with_format(OldCsv()
                 .field_delimiter('\t')
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .create_temporary_table('mySink')

tab = t_env.from_path('mySource')
tab.group_by(tab.word) \
   .select(tab.word, lit(1).count) \
   .execute_insert('mySink').wait()
```

## Flink监控与优化

### Flink-Metrics监控

#### 什么是 Metrics？

[https://ci.apache.org/projects/flink/flink-docs-release-1.12/ops/metrics.html](https://ci.apache.org/projects/flink/flink-docs-release-1.12/ops/metrics.html)

##### Metrics介绍

由于集群运行后很难发现内部的实际状况，跑得慢或快，是否异常等，开发人员无法实时查看所有的 Task 日志，比如作业很大或者有很多作业的情况下，该如何处理？此时 Metrics 可以很好的帮助开发人员了解作业的当前状况。

Flink 提供的 Metrics 可以在 Flink 内部收集一些指标，通过这些指标让开发人员更好地理解作业或集群的状态。

![image.png](https://image.hyly.net/i/2025/09/28/850785c21c69c4e543f2cb32d46b374c-0.webp)

##### Metric Types

Metrics 的类型如下：

1，常用的如 Counter，写过 mapreduce 作业的开发人员就应该很熟悉 Counter，其实含义都是一样的，就是对一个计数器进行累加，即对于多条数据和多兆数据一直往上加的过程。

2，Gauge，Gauge 是最简单的 Metrics，它反映一个值。比如要看现在 Java heap 内存用了多少，就可以每次实时的暴露一个 Gauge，Gauge 当前的值就是heap使用的量。

3，Meter，Meter 是指统计吞吐量和单位时间内发生“事件”的次数。它相当于求一种速率，即事件次数除以使用的时间。

4，Histogram，Histogram 比较复杂，也并不常用，Histogram 用于统计一些数据的分布，比如说 Quantile、Mean、StdDev、Max、Min 等。

Metric 在 Flink 内部有多层结构，以 Group 的方式组织，它并不是一个扁平化的结构，Metric Group + Metric Name 是 Metrics 的唯一标识。

#### WebUI监控

在flink的UI的界面上点击任务详情，然后点击Task Metrics会弹出如下的界面，在 add metic按钮上可以添加我需要的监控指标。

1. 自定义监控指标
   1. 案例：在map算子内计算输入的总数据
   2. 设置MetricGroup为：flink_test_metric
   3. 指标变量为：mapDataNub
   4. 参考代码

```
package cn.itcast.hello;

import org.apache.flink.api.common.RuntimeExecutionMode;
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.metrics.Counter;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.KeyedStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

/**
 * Author itcast
 * Desc
 */
public class WordCount5_Metrics {
    public static void main(String[] args) throws Exception {
        //1.准备环境-env
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setRuntimeMode(RuntimeExecutionMode.AUTOMATIC);

        //2.准备数据-source
        //2.source
        DataStream<String> linesDS = env.socketTextStream("node1", 9999);
        //3.处理数据-transformation
        DataStream<String> wordsDS = linesDS.flatMap(new FlatMapFunction<String, String>() {
            @Override
            public void flatMap(String value, Collector<String> out) throws Exception {
                //value就是一行行的数据
                String[] words = value.split(" ");
                for (String word : words) {
                    out.collect(word);//将切割处理的一个个的单词收集起来并返回
                }
            }
        });
        //3.2对集合中的每个单词记为1
        DataStream<Tuple2<String, Integer>> wordAndOnesDS = wordsDS.map(new RichMapFunction<String, Tuple2<String, Integer>>() {
            Counter myCounter;
            @Override
            public void open(Configuration parameters) throws Exception {
                myCounter= getRuntimeContext().getMetricGroup().addGroup("myGroup").counter("myCounter");
            }

            @Override
            public Tuple2<String, Integer> map(String value) throws Exception {
                myCounter.inc();
                //value就是进来一个个的单词
                return Tuple2.of(value, 1);
            }
        });
        //3.3对数据按照单词(key)进行分组
        KeyedStream<Tuple2<String, Integer>, String> groupedDS = wordAndOnesDS.keyBy(t -> t.f0);
        //3.4对各个组内的数据按照数量(value)进行聚合就是求sum
        DataStream<Tuple2<String, Integer>> result = groupedDS.sum(1);

        //4.输出结果-sink
        result.print().name("mySink");

        //5.触发执行-execute
        env.execute();
    }
}
// /export/server/flink/bin/yarn-session.sh -n 2 -tm 800 -s 1 -d
// /export/server/flink/bin/flink run --class cn.itcast.hello.WordCount5_Metrics /root/metrics.jar
// 查看WebUI
```

程序启动之后就可以在任务的ui界面上查看

![image.png](https://image.hyly.net/i/2025/09/28/07b307c4732fbd97be44ed0bb19562cb-0.webp)

#### REST API监控

前面介绍了flink公共的监控指标以及如何自定义监控指标，那么实际开发flink任务我们需要及时知道这些监控指标的数据，去获取程序的健康值以及状态。这时候就需要我们通过 flink REST API ，自己编写监控程序去获取这些指标。很简单，当我们知道每个指标请求的URL,我们便可以编写程序通过http请求获取指标的监控数据。

对于 flink on yarn 模式来说，则需要知道 RM 代理的 JobManager UI 地址
格式：

http://Yarn-WebUI-host:port/proxy/application_id
如：http://node1:8088/proxy/application_1609508087977_0004/jobs

##### http请求获取监控数据

操作步骤
获取flink任务运行状态(我们可以在浏览器进行测试，输入如下的连接)

```
http://node1:8088/proxy/application_1609508087977_0004/jobs
返回的结果
{
    jobs: [{
            id: "ce793f18efab10127f0626a37ff4b4d4",
            status: "RUNNING"
        }
    ]
}
```

获取 job 详情

```
http://node1:8088/proxy/application_1609508087977_0004/jobs/925224169036ef3f03a8d7fe9605b4ef
返回的结果
{
    jid: "ce793f18efab10127f0626a37ff4b4d4",
    name: "Test",
    isStoppable: false,
    state: "RUNNING",
    start - time: 1551577191874,
    end - time: -1,
    duration: 295120489,
    now: 1551872312363,
    。。。。。。
      此处省略n行
    。。。。。。
            }, {
                id: "cbc357ccb763df2852fee8c4fc7d55f2",
                parallelism: 12,
                operator: "",
                operator_strategy: "",
                description: "Source: Custom Source -> Flat Map",
                optimizer_properties: {}
            }
        ]
    }
}
```

##### 开发者模式获取指标url

指标非常多，不需要记住每个指标的请求的URL格式？可以进入flink任务的UI界面，按住F12进入开发者模式，然后我们点击任意一个metric指标,便能立即看到每个指标的请求的URL。比如获取flink任务的背压情况：
如下图我们点击某一个task的status，按一下f12，便看到了backpressue,点开backpressue就是获取任务背压情况的连接如下：
http://node1:8088/proxy/application_1609508087977_0004/jobs/925224169036ef3f03a8d7fe9605b4ef/vertices/cbc357ccb763df2852fee8c4fc7d55f2/backpressure

![image.png](https://image.hyly.net/i/2025/09/28/89bce98317ea6dab34e80e3ed9aac09c-0.webp)

请求连接返回的json字符串如下：我们可以获取每一个分区的背压情况，如果不是OK状态便可以进行任务报警，其他的指标获取监控值都可以这样获取 简单而又便捷。

##### 代码中Flink任务运行状态

使用 flink REST API的方式，通过http请求实时获取flink任务状态，不是RUNNING状态则进行短信、电话或邮件报警，达到实时监控的效果。

```
package cn.itcast.hello;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

public class MetricsTest {
    public static void main(String[] args) {
        String result = sendGet("http://node1:8088/proxy/application_1609508087977_0004/jobs");
        System.out.println(result);
    }

    public static String sendGet(String url) {
        String result = "";
        BufferedReader in = null;
        try {
            String urlNameString = url;
            URL realUrl = new URL(urlNameString);
            URLConnection connection = realUrl.openConnection();
            // 设置通用的请求属性
            connection.setRequestProperty("accept", "*/*");
            connection.setRequestProperty("connection", "Keep-Alive");
            connection.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
            // 建立实际的连接
            connection.connect();
            in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                result += line;
            }
        } catch (Exception e) {
            System.out.println("发送GET请求出现异常！" + e);
            e.printStackTrace();
        }
        // 使用finally块来关闭输入流
        finally {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }
        return result;
    }

}
```

### Flink-性能优化

#### History Server

flink的HistoryServer主要是用来存储和查看任务的历史记录，具体信息可以看官网
https://ci.apache.org/projects/flink/flink-docs-release-1.12/deployment/advanced/historyserver.html

```
## Directory to upload completed jobs to. Add this directory to the list of
## monitored directories of the HistoryServer as well (see below).
## 将已完成的作业上传到的目录
jobmanager.archive.fs.dir: hdfs://node01:8020/completed-jobs/

## The address under which the web-based HistoryServer listens.
## 基于 Web 的 HistoryServer 的地址
historyserver.web.address: 0.0.0.0

## The port under which the web-based HistoryServer listens.
## 基于 Web 的 HistoryServer 的端口号
historyserver.web.port: 8082

## Comma separated list of directories to monitor for completed jobs.
## 以逗号分隔的目录列表，用于监视已完成的作业
historyserver.archive.fs.dir: hdfs://node01:8020/completed-jobs/

## Interval in milliseconds for refreshing the monitored directories.
## 刷新受监控目录的时间间隔（以毫秒为单位）
historyserver.archive.fs.refresh-interval: 10000
```

1. 参数释义
   1. jobmanager.archive.fs.dir：flink job运行完成后的日志存放目录
   2. historyserver.archive.fs.dir：flink history进程的hdfs监控目录
   3. historyserver.web.address：flink history进程所在的主机
   4. historyserver.web.port：flink history进程的占用端口
   5. historyserver.archive.fs.refresh-interval：刷新受监视目录的时间间隔（以毫秒为单位）。
2. 默认启动端口8082：
   1. bin/historyserver.sh (start|start-foreground|stop)

#### 序列化

**首先说一下 Java 原生的序列化方式：**

优点：好处是比较简单通用，只要对象实现了 Serializable 接口即可；
缺点：效率比较低，而且如果用户没有指定 serialVersionUID的话，很容易出现作业重新编译后，之前的数据无法反序列化出来的情况（这也是 Spark Streaming Checkpoint 的一个痛点，在业务使用中经常出现修改了代码之后，无法从 Checkpoint 恢复的问题）
对于分布式计算来讲，数据的传输效率非常重要。好的序列化框架可以通过较低的序列化时间和较低的内存占用大大提高计算效率和作业稳定性。

**在数据序列化上，Flink 和 Spark 采用了不同的方式**

Spark 对于所有数据默认采用 Java 原生序列化方式，用户也可以配置使用 Kryo；相比于 Java 原生序列化方式，无论是在序列化效率还是序列化结果的内存占用上，Kryo 则更好一些（Spark 声称一般 Kryo 会比 Java 原生节省 10x 内存占用）；Spark 文档中表示它们之所以没有把 Kryo 设置为默认序列化框架的唯一原因是因为 Kryo 需要用户自己注册需要序列化的类，并且建议用户通过配置开启 Kryo。
Flink 则是自己实现了一套高效率的序列化方法。

**复用对象**

比如如下代码：

```
stream
    .apply(new WindowFunction<WikipediaEditEvent, Tuple2<String, Long>, String, TimeWindow>() {
        @Override
        public void apply(String userName, TimeWindow timeWindow, Iterable<WikipediaEditEvent> iterable, Collector<Tuple2<String, Long>> collector) throws Exception {
            long changesCount = ...
            // A new Tuple instance is created on every execution
            collector.collect(new Tuple2<>(userName, changesCount));
        }
    }
```

可以看出，apply函数每执行一次，都会新建一个Tuple2类的实例，因此增加了对垃圾收集器的压力。解决这个问题的一种方法是反复使用相同的实例：

```
stream
        .apply(new WindowFunction<WikipediaEditEvent, Tuple2<String, Long>, String, TimeWindow>() {
    // Create an instance that we will reuse on every call
    private Tuple2<String, Long> result = new Tuple<>();
    @Override
    public void apply(String userName, TimeWindow timeWindow, Iterable<WikipediaEditEvent> iterable, Collector<Tuple2<String, Long>> collector) throws Exception {
        long changesCount = ...
        // Set fields on an existing object instead of creating a new one
        result.f0 = userName;
        // Auto-boxing!! A new Long value may be created
        result.f1 = changesCount;
        // Reuse the same Tuple2 object
        collector.collect(result);
    }
}
```

这种做法其实还间接创建了Long类的实例。
为了解决这个问题，Flink有许多所谓的value class:IntValue、LongValue、StringValue、FloatValue等。下面介绍一下如何使用它们：

```
stream
        .apply(new WindowFunction<WikipediaEditEvent, Tuple2<String, Long>, String, TimeWindow>() {
    // Create a mutable count instance
    private LongValue count = new LongValue();
    // Assign mutable count to the tuple
    private Tuple2<String, LongValue> result = new Tuple<>("", count);

    @Override
    // Notice that now we have a different return type
    public void apply(String userName, TimeWindow timeWindow, Iterable<WikipediaEditEvent> iterable, Collector<Tuple2<String, LongValue>> collector) throws Exception {
        long changesCount = ...

        // Set fields on an existing object instead of creating a new one
        result.f0 = userName;
        // Update mutable count value
        count.setValue(changesCount);

        // Reuse the same tuple and the same LongValue instance
        collector.collect(result);
    }
}
```

#### 数据倾斜

我们的flink程序中如果使用了keyBy等分组的操作，很容易就出现数据倾斜的情况，数据倾斜会导致整体计算速度变慢，有些子节点甚至接受不到数据，导致分配的资源根本没有利用上。

1. 带有窗口的操作
   1. 带有窗口的每个窗口中所有数据的分布不平均，某个窗口处理数据量太大导致速率慢
   2. 导致Source数据处理过程越来越慢
   3. 再导致所有窗口处理越来越慢
2. 不带有窗口的操作
   1. 有些子节点接受处理的数据很少，甚至得不到数据，导致分配的资源根本没有利用上
3. WebUI体现：

![image.png](https://image.hyly.net/i/2025/09/28/a1edc1d57dce6671e24016734bfa8a36-0.webp)

WebUI中Subtasks中打开每个窗口可以看到每个窗口进程的运行情况：如上图，数据分布很不均匀，导致部分窗口数据处理缓慢

**优化方式：**

1. 对key进行均匀的打散处理（hash，加盐等）
2. 自定义分区器
3. 使用Rebalabce

注意：Rebalance是在数据倾斜的情况下使用，不倾斜不要使用，否则会因为shuffle产生大量的网络开销

### Flink-内存管理

#### 问题引入

Flink本身基本是以Java语言完成的，理论上说，直接使用JVM的虚拟机的内存管理就应该更简单方便，但Flink还是单独抽象出了自己的内存管理

因为Flink是为大数据而产生的，而大数据使用会消耗大量的内存，而JVM的内存管理管理设计是兼顾平衡的，不可能单独为了大数据而修改，这对于Flink来说，非常的不灵活，而且频繁GC会导致长时间的机器暂停应用，这对于大数据的应用场景来说也是无法忍受的。

JVM在大数据环境下存在的问题:

1. Java 对象存储密度低。在HotSpot JVM中，每个对象占用的内存空间必须是8的倍数,那么一个只包含 boolean 属性的对象就要占用了16个字节内存：对象头占了8个，boolean 属性占了1个，对齐填充占了7个。而实际上我们只想让它占用1个bit。
2. 在处理大量数据尤其是几十甚至上百G的内存应用时会生成大量对象，Java GC可能会被反复触发，其中Full GC或Major GC的开销是非常大的，GC 会达到秒级甚至分钟级。
3. OOM 问题影响稳定性。OutOfMemoryError是分布式计算框架经常会遇到的问题，当JVM中所有对象大小超过分配给JVM的内存大小时，就会发生OutOfMemoryError错误，导致JVM崩溃，分布式框架的健壮性和性能都会受到影响。

#### 内存划分

![image.png](https://image.hyly.net/i/2025/09/28/0ca24272a65a541e9cf10dad3b5063fe-0.webp)

注意:Flink的内存管理是在JVM的基础之上,自己进行的管理,但是还没有逃脱的JVM,具体怎么实现,现阶段我们搞不定

1. 网络缓冲区Network Buffers：这个是在TaskManager启动的时候分配的，这是一组用于缓存网络数据的内存，每个块是32K，默认分配2048个，可以通过“taskmanager.network.numberOfBuffers”修改
2. 内存池Memory Manage pool：大量的Memory Segment块，用于运行时的算法（Sort/Join/Shufflt等），这部分启动的时候就会分配。默认情况下，占堆内存的70% 的大小。
3. 用户使用内存Remaining (Free) Heap: 这部分的内存是留给用户代码以及 TaskManager的数据使用的。

#### 堆外内存

除了JVM之上封装的内存管理,还会有个一个很大的堆外内存,用来执行一些IO操作

启动超大内存（上百GB）的JVM需要很长时间，GC停留时间也会很长（分钟级）。

使用堆外内存可以极大地减小堆内存（只需要分配Remaining Heap），使得 TaskManager 扩展到上百GB内存不是问题。

进行IO操作时，使用堆外内存(可以理解为使用操作系统内存)可以zero-copy，使用堆内JVM内存至少要复制一次(需要在操作系统和JVM直接进行拷贝)。

堆外内存在进程间是共享的。

**总结: Flink相对于Spark,堆外内存该用还是用, 堆内内存管理做了自己的封装,不受JVM的GC影响**

#### 序列化与反序列化

Flink除了对堆内内存做了封装之外,还实现了自己的序列化和反序列化机制

序列化与反序列化可以理解为编码与解码的过程。序列化以后的数据希望占用比较小的空间，而且数据能够被正确地反序列化出来。为了能正确反序列化，序列化时仅存储二进制数据本身肯定不够，需要增加一些辅助的描述信息。此处可以采用不同的策略，因而产生了很多不同的序列化方法。

Java本身自带的序列化和反序列化的功能，但是辅助信息占用空间比较大，在序列化对象时记录了过多的类信息。

Flink实现了自己的序列化框架，使用TypeInformation表示每种数据类型，所以可以只保存一份对象Schema信息，节省存储空间。又因为对象类型固定，所以可以通过偏移量存取。

TypeInformation 支持以下几种类型：
BasicTypeInfo: 任意Java 基本类型或 String 类型。
BasicArrayTypeInfo: 任意Java基本类型数组或 String 数组。
WritableTypeInfo: 任意 Hadoop Writable 接口的实现类。
TupleTypeInfo: 任意的 Flink Tuple 类型(支持Tuple1 to Tuple25)。Flink tuples 是固定长度固定类型的Java Tuple实现。
CaseClassTypeInfo: 任意的 Scala CaseClass(包括 Scala tuples)。
PojoTypeInfo: 任意的 POJO (Java or Scala)，例如，Java对象的所有成员变量，要么是 public 修饰符定义，要么有 getter/setter 方法。
GenericTypeInfo: 任意无法匹配之前几种类型的类。(除了该数据使用kyro序列化.上面的其他的都是用二进制)

![image.png](https://image.hyly.net/i/2025/09/28/f9c1528e15d6ae99e4831eda4427d5f4-0.webp)

针对前六种类型数据集，Flink皆可以自动生成对应的TypeSerializer，能非常高效地对数据集进行序列化和反序列化。对于最后一种数据类型，Flink会使用Kryo进行序列化和反序列化。每个TypeInformation中，都包含了serializer，类型会自动通过serializer进行序列化，然后用Java Unsafe接口(具有像C语言一样的操作内存空间的能力)写入MemorySegments。

![image.png](https://image.hyly.net/i/2025/09/28/b4c77e2c4e4cc5746adfdd177740a0da-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/1717fde6c4e50041c5bd4bfe727719af-0.webp)

Flink通过自己的序列化和反序列化,可以将数据进行高效的存储,不浪费内存空间

#### 操纵二进制数据

Flink中的group、sort、join 等操作可能需要访问海量数据。以sort为例。

首先，Flink 会从 MemoryManager 中申请一批 MemorySegment，用来存放排序的数据。

这些内存会分为两部分:

一个区域是用来存放所有对象完整的二进制数据。

另一个区域用来存放指向完整二进制数据的指针以及定长的序列化后的key（key+pointer）。

将实际的数据和point+key分开存放有两个目的:

第一，交换定长块（key+pointer）更高效，不用交换真实的数据也不用移动其他key和pointer。

第二，这样做是缓存友好的，因为key都是连续存储在内存中的，可以增加cache命中。 排序会先比较 key 大小，这样就可以直接用二进制的 key 比较而不需要反序列化出整个对象。访问排序后的数据，可以沿着排好序的key+pointer顺序访问，通过 pointer 找到对应的真实数据。

在交换过程中，只需要比较key就可以完成sort的过程，只有key1 == key2的情况，才需要反序列化拿出实际的对象做比较，而比较之后只需要交换对应的key而不需要交换实际的对象

![image.png](https://image.hyly.net/i/2025/09/28/c743dd0e257b01ede5fe6a02bda26e2b-0.webp)

#### 总结-面试

1. 减少full gc时间：因为所有常用数据都在Memory Manager里，这部分内存的生命周期是伴随TaskManager管理的而不会被GC回收。其他的常用数据对象都是用户定义的数据对象，这部分会快速的被GC回收
2. 减少OOM：所有的运行时的内存应用都从池化的内存中获取，而且运行时的算法可以在内存不足的时候将数据写到堆外内存
3. 节约空间：由于Flink自定序列化/反序列化的方法，所有的对象都以二进制的形式存储，降低消耗
4. 高效的二进制操作和缓存友好：二进制数据以定义好的格式存储，可以高效地比较与操作。另外，该二进制形式可以把相关的值，以及hash值，键值和指针等相邻地放进内存中。这使得数据结构可以对CPU高速缓存更友好，可以从CPU的 L1/L2/L3 缓存获得性能的提升,也就是Flink的数据存储二进制格式符合CPU缓存的标准,非常方便被CPU的L1/L2/L3各级别缓存利用,比内存还要快!

### Flink VS Spark

#### 运行角色

1. Spark Streaming 运行时的角色(standalone 模式)主要有：
   1. Master:主要负责整体集群资源的管理和应用程序调度；
   2. Worker:负责单个节点的资源管理，driver 和 executor 的启动等；
   3. Driver:用户入口程序执行的地方，即 SparkContext 执行的地方，主要是 DAG 生成、stage 划分、task 生成及调度；
   4. Executor:负责执行 task，反馈执行状态和执行结果。
2. Flink 运行时的角色(standalone 模式)主要有:
   1. Jobmanager: 协调分布式执行，他们调度任务、协调 checkpoints、协调故障恢复等。至少有一个 JobManager。高可用情况下可以启动多个 JobManager，其中一个选举为 leader，其余为 standby；
   2. Taskmanager: 负责执行具体的 tasks、缓存、交换数据流，至少有一个 TaskManager；
   3. Slot: 每个 task slot 代表 TaskManager 的一个固定部分资源，Slot 的个数代表着 taskmanager 可并行执行的 task 数。

#### 生态

![image.png](https://image.hyly.net/i/2025/09/28/a9920bcb5d64e065961c51ffaec9e871-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/18f4ca0676d69d1724c131e6d2cbc8ac-0.webp)

#### 运行模型

Spark Streaming 是微批处理，运行的时候需要指定批处理的时间，每次运行 job 时处理一个批次的数据，流程如图所示：

![image.png](https://image.hyly.net/i/2025/09/28/3d6ce747ecf1efd63aab301e309c5b3c-0.webp)

Flink 是基于事件驱动的，事件可以理解为消息。事件驱动的应用程序是一种状态应用程序，它会从一个或者多个流中注入事件，通过触发计算更新状态，或外部动作对注入的事件作出反应。

![image.png](https://image.hyly.net/i/2025/09/28/17d25867dce8e07ddd3b30f1efe77758-0.webp)

#### 编程模型对比

编程模型对比，主要是对比 flink 和 Spark Streaming 两者在代码编写上的区别。

Spark Streaming
Spark Streaming 与 kafka 的结合主要是两种模型：
基于 receiver dstream；
基于 direct dstream。

以上两种模型编程机构近似，只是在 api 和内部数据获取有些区别，新版本的已经取消了基于 receiver 这种模式，企业中通常采用基于 direct Dstream 的模式。

```
val Array(brokers, topics) = args//    创建一个批处理时间是2s的context    
val sparkConf = new SparkConf().setAppName("DirectKafkaWordCount")    
val ssc = new StreamingContext(sparkConf, Seconds(2))    
//    使用broker和topic创建DirectStream    
val topicsSet = topics.split(",").toSet    
val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)    
val messages = KafkaUtils.createDirectStream[String, String]( ssc, LocationStrategies.PreferConsistent,    ConsumerStrategies.Subscribe[String, String](topicsSet, kafkaParams))  
// Get the lines, split them into words, count the words and print    
val lines = messages.map(_.value)    
val words = lines.flatMap(_.split(" "))    
val wordCounts = words.map(x => (x, 1L)).reduceByKey(_ + _)   
wordCounts.print()     //    启动流    
ssc.start()    
ssc.awaitTermination()
```

通过以上代码我们可以 get 到：
设置批处理时间
创建数据流
编写transform
编写action
启动执行

**Flink**
接下来看 flink 与 kafka 结合是如何编写代码的。Flink 与 kafka 结合是事件驱动，大家可能对此会有疑问，消费 kafka 的数据调用 poll 的时候是批量获取数据的(可以设置批处理大小和超时时间)，这就不能叫做事件触发了。而实际上，flink 内部对 poll 出来的数据进行了整理，然后逐条 emit，形成了事件触发的机制。
下面的代码是 flink 整合 kafka 作为 data source 和 data sink：

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.getConfig().disableSysoutLogging();
env.getConfig().setRestartStrategy(RestartStrategies.fixedDelayRestart(4, 10000));
// create a checkpoint every 5 seconds
env.enableCheckpointing(5000); 
// make parameters available in the web interface
env.getConfig().setGlobalJobParameters(parameterTool); 
env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);
//  ExecutionConfig.GlobalJobParameters
env.getConfig().setGlobalJobParameters(null);    
DataStream<KafkaEvent> input = env
           .addSource(new FlinkKafkaConsumer010<>(
                   parameterTool.getRequired("input-topic"),  new KafkaEventSchema(),
                   parameterTool.getProperties())
           .assignTimestampsAndWatermarks(new CustomWatermarkExtractor()))
           .setParallelism(1).rebalance()
           .keyBy("word")
           .map(new RollingAdditionMapper()).setParallelism(0);
input.addSink(new FlinkKafkaProducer010<>(parameterTool.getRequired("output-topic"), new KafkaEventSchema(),
        parameterTool.getProperties()));
env.execute("Kafka 0.10 Example");
```

从 Flink 与 kafka 结合的代码可以 get 到：
注册数据 source
编写运行逻辑
注册数据 sink
调用 env.execute
相比于 Spark Streaming 少了设置批处理时间，还有一个显著的区别是 flink 的所有算子都是 lazy 形式的，调用 env.execute 会构建 jobgraph。client 端负责 Jobgraph 生成并提交它到集群运行；而 Spark Streaming的操作算子分 action 和 transform，其中仅有 transform 是 lazy 形式，而且 DGA 生成、stage 划分、任务调度是在 driver 端进行的，在 client 模式下 driver 运行于客户端处。

#### 任务调度原理

**Spark 任务调度**
Spark Streaming 任务如上文提到的是基于微批处理的，实际上每个批次都是一个 Spark Core 的任务。对于编码完成的 Spark Core 任务在生成到最终执行结束主要包括以下几个部分：
构建 DGA 图；
划分 stage；
生成 taskset；
调度 task。

![image.png](https://image.hyly.net/i/2025/09/28/dbce658cc06cf49736218eec6f1ec8fd-0.webp)

对于 job 的调度执行有 fifo 和 fair 两种模式，Task 是根据数据本地性调度执行的。 假设每个 Spark Streaming 任务消费的 kafka topic 有四个分区，中间有一个 transform操作（如 map）和一个 reduce 操作，如图所示：

![image.png](https://image.hyly.net/i/2025/09/28/22ddfcf2174e26a21102ec7f486e76d2-0.webp)

假设有两个 executor，其中每个 executor 三个核，那么每个批次相应的 task 运行位置是固定的吗？是否能预测？ 由于数据本地性和调度不确定性，每个批次对应 kafka 分区生成的 task 运行位置并不是固定的。

**Flink 任务调度**

对于 flink 的流任务客户端首先会生成 StreamGraph，接着生成 JobGraph，然后将 jobGraph 提交给 Jobmanager 由它完成 jobGraph 到 ExecutionGraph 的转变，最后由 jobManager 调度执行。

![image.png](https://image.hyly.net/i/2025/09/28/898a1c24482173890d272accc0b3ba47-0.webp)

如图所示有一个由 data source、MapFunction和 ReduceFunction 组成的程序，data source 和 MapFunction 的并发度都为 4，而 ReduceFunction 的并发度为 3。一个数据流由 Source-Map-Reduce 的顺序组成，在具有 2 个TaskManager、每个 TaskManager 都有 3 个 Task Slot 的集群上运行。

可以看出 flink 的拓扑生成提交执行之后，除非故障，否则拓扑部件执行位置不变，并行度由每一个算子并行度决定，类似于 storm。而 spark Streaming 是每个批次都会根据数据本地性和资源情况进行调度，无固定的执行拓扑结构。 flink 是数据在拓扑结构里流动执行，而 Spark Streaming 则是对数据缓存批次并行处理。

#### 时间机制对比

**流处理的时间**

流处理程序在时间概念上总共有三个时间概念：

**处理时间**

处理时间是指每台机器的系统时间，当流程序采用处理时间时将使用运行各个运算符实例的机器时间。处理时间是最简单的时间概念，不需要流和机器之间的协调，它能提供最好的性能和最低延迟。然而在分布式和异步环境中，处理时间不能提供消息事件的时序性保证，因为它受到消息传输延迟，消息在算子之间流动的速度等方面制约。

**事件时间**

事件时间是指事件在其设备上发生的时间，这个时间在事件进入 flink 之前已经嵌入事件，然后 flink 可以提取该时间。基于事件时间进行处理的流程序可以保证事件在处理的时候的顺序性，但是基于事件时间的应用程序必须要结合 watermark 机制。基于事件时间的处理往往有一定的滞后性，因为它需要等待后续事件和处理无序事件，对于时间敏感的应用使用的时候要慎重考虑。

**注入时间**

注入时间是事件注入到 flink 的时间。事件在 source 算子处获取 source 的当前时间作为事件注入时间，后续的基于时间的处理算子会使用该时间处理数据。
相比于事件时间，注入时间不能够处理无序事件或者滞后事件，但是应用程序无序指定如何生成 watermark。在内部注入时间程序的处理和事件时间类似，但是时间戳分配和 watermark 生成都是自动的。

![image.png](https://image.hyly.net/i/2025/09/28/08bd195cb96fb27e734c16604732d901-0.webp)

**Spark 时间机制**

Spark Streaming 只支持处理时间，Structured streaming 支持处理时间和事件时间，同时支持 watermark 机制处理滞后数据。

**Flink 时间机制**

flink 支持三种时间机制：事件时间，注入时间，处理时间，同时支持 watermark 机制处理滞后数据。

#### kafka 动态分区检测

**Spark Streaming**

对于有实时处理业务需求的企业，随着业务增长数据量也会同步增长，将导致原有的 kafka 分区数不满足数据写入所需的并发度，需要扩展 kafka 的分区或者增加 kafka 的 topic，这时就要求实时处理程序，如 SparkStreaming、flink 能检测到 kafka 新增的 topic 、分区及消费新增分区的数据。

接下来结合源码分析，Spark Streaming 和 flink 在 kafka 新增 topic 或 partition 时能否动态发现新增分区并消费处理新增分区的数据。 Spark Streaming 与 kafka 结合有两个区别比较大的版本，如图所示是官网给出的对比数据：

![image.png](https://image.hyly.net/i/2025/09/28/b020fabeed6fe981b29cf1f4126acdc2-0.webp)

其中确认的是 Spark Streaming 与 kafka 0.8 版本结合不支持动态分区检测，与 0.10 版本结合支持，接着通过源码分析。

Spark Streaming 与 kafka 0.8 版本结合

*源码分析只针对是否分区检测
入口是 DirectKafkaInputDStream 的 compute：

```
//    改行代码会计算这个job，要消费的每个kafka分区的最大偏移
override def compute(validTime: Time): Option[KafkaRDD[K, V, U, T, R]] = {
   //    构建KafkaRDD，用指定的分区数和要消费的offset范围
   val untilOffsets = clamp(latestLeaderOffsets(maxRetries))
   val rdd = KafkaRDD[K, V, U, T, R](
     // Report the record number and metadata of this batch interval to InputInfoTracker.
     context.sparkContext, kafkaParams, currentOffsets, untilOffsets, messageHandler)    
   val offsetRanges = currentOffsets.map { case (tp, fo) =>
     val uo = untilOffsets(tp)      
     OffsetRange(tp.topic, tp.partition, fo, uo.offset)
   }    
   val description = offsetRanges.filter { offsetRange =>
     // Don't display empty ranges.
     offsetRange.fromOffset != offsetRange.untilOffset
   }.map { offsetRange =>
     // Copy offsetRanges to immutable.List to prevent from being modified by the user
     s"topic: ${offsetRange.topic}\tpartition: ${offsetRange.partition}\t" +
       s"offsets: ${offsetRange.fromOffset} to ${offsetRange.untilOffset}"
   }.mkString("\n")    
   val metadata = Map("offsets" -> offsetRanges.toList,      
        StreamInputInfo.METADATA_KEY_DESCRIPTION -> description)    
   val inputInfo = StreamInputInfo(id, rdd.count, metadata)
   ssc.scheduler.inputInfoTracker.reportInfo(validTime, inputInfo)
   currentOffsets = untilOffsets.map(kv => kv._1 -> kv._2.offset)    
   Some(rdd)
}
```

第一行就是计算得到该批次生成 KafkaRDD 每个分区要消费的最大 offset。 接着看 latestLeaderOffsets(maxRetries)

```
// 可以看到的是用来指定获取最大偏移分区的列表还是只有currentOffsets，没有发现关于新增的分区的内容。
@tailrec  protected final def latestLeaderOffsets(retries: Int): Map[TopicAndPartition, LeaderOffset] = {
   val o = kc.getLatestLeaderOffsets(currentOffsets.keySet)    
   // Either.fold would confuse @tailrec, do it manually
   if (o.isLeft) {      
      val err = o.left.get.toString      
      if (retries <= 0) {        
        throw new SparkException(err)
      } else {
       logError(err)        
       Thread.sleep(kc.config.refreshLeaderBackoffMs)
       latestLeaderOffsets(retries - 1)
     }
   } else {
     o.right.get
   }
 }
```

其中 protected var currentOffsets = fromOffsets，这个仅仅是在构建 DirectKafkaInputDStream 的时候初始化，并在 compute 里面更新：

```
currentOffsets = untilOffsets.map(kv => kv._1 -> kv._2.offset)
```

中间没有检测 kafka 新增 topic 或者分区的代码，所以可以确认 Spark Streaming 与 kafka 0.8 的版本结合不支持动态分区检测。

**Spark Streaming 与 kafka 0.10 版本结合**

入口同样是 DirectKafkaInputDStream 的 compute 方法，捡主要的部分说，Compute 里第一行也是计算当前 job 生成 kafkardd 要消费的每个分区的最大 offset：

```
//    获取当前生成job，要用到的KafkaRDD每个分区最大消费偏移值
   val untilOffsets = clamp(latestOffsets())
```

具体检测 kafka 新增 topic 或者分区的代码在 latestOffsets()

```
/**   
* Returns the latest (highest) available offsets, taking new partitions into account.   
*/
protected def latestOffsets(): Map[TopicPartition, Long] = {    
   val c = consumer
   paranoidPoll(c)    // 获取所有的分区信息
   // make sure new partitions are reflected in currentOffsets
   val parts = c.assignment().asScala    
   // 做差获取新增的分区信息
   val newPartitions = parts.diff(currentOffsets.keySet)    
   // position for new partitions determined by auto.offset.reset if no commit
   // 新分区消费位置，没有记录的化是由auto.offset.reset决定
   currentOffsets = currentOffsets ++ newPartitions.map(tp => tp -> c.position(tp)).toMap    
   // don't want to consume messages, so pause
   c.pause(newPartitions.asJava)    // find latest available offsets
   c.seekToEnd(currentOffsets.keySet.asJava)
   parts.map(tp => tp -> c.position(tp)).toMap
}
```

该方法内有获取 kafka 新增分区，并将其更新到 currentOffsets 的过程，所以可以验证 Spark Streaming 与 kafka 0.10 版本结合支持动态分区检测。

**Flink**

入口类是 FlinkKafkaConsumerBase，该类是所有 flink 的 kafka 消费者的父类。

![image.png](https://image.hyly.net/i/2025/09/28/cef905440446113f3358e4364e5b10bb-0.webp)

在 FlinkKafkaConsumerBase 的 run 方法中，创建了 kafkaFetcher，实际上就是消费者：

```
this.kafkaFetcher = createFetcher(
       sourceContext,
       subscribedPartitionsToStartOffsets,
       periodicWatermarkAssigner,
       punctuatedWatermarkAssigner,
       (StreamingRuntimeContext) getRuntimeContext(),
       offsetCommitMode,
       getRuntimeContext().getMetricGroup().addGroup(KAFKA_CONSUMER_METRICS_GROUP),
       useMetrics);
```

接是创建了一个线程，该线程会定期检测 kafka 新增分区，然后将其添加到 kafkaFetcher 里。

```
if (discoveryIntervalMillis != PARTITION_DISCOVERY_DISABLED) {      
  final AtomicReference<Exception> discoveryLoopErrorRef = new AtomicReference<>();      
  this.discoveryLoopThread = new Thread(new Runnable() {        
      @Override
      public void run() {          
          try {            
          // --------------------- partition discovery loop ---------------------
           List<KafkaTopicPartition> discoveredPartitions;            
           // throughout the loop, we always eagerly check if we are still running before
           // performing the next operation, so that we can escape the loop as soon as possible
           while (running) {              
             if (LOG.isDebugEnabled()) {                
               LOG.debug("Consumer subtask {} is trying to discover new partitions ...", getRuntimeContext().getIndexOfThisSubtask());
             }              
             try {
               discoveredPartitions = partitionDiscoverer.discoverPartitions();
             } catch (AbstractPartitionDiscoverer.WakeupException | AbstractPartitionDiscoverer.ClosedException e) { 
               // the partition discoverer may have been closed or woken up before or during the discovery;
               // this would only happen if the consumer was canceled; simply escape the loop
               break;
             } 
             // no need to add the discovered partitions if we were closed during the meantime
             if (running && !discoveredPartitions.isEmpty()) {
               kafkaFetcher.addDiscoveredPartitions(discoveredPartitions);
             } 
             // do not waste any time sleeping if we're not running anymore
             if (running && discoveryIntervalMillis != 0) {                
               try {                  
                 Thread.sleep(discoveryIntervalMillis);
               } catch (InterruptedException iex) {
                 // may be interrupted if the consumer was canceled midway; simply escape the loop
                 break;
               }
             }
           }
         } catch (Exception e) {
           discoveryLoopErrorRef.set(e);
         } finally {            
           // calling cancel will also let the fetcher loop escape
           // (if not running, cancel() was already called)
           if (running) {
             cancel();
           }
         }
       }
     }, "Kafka Partition Discovery for " + getRuntimeContext().getTaskNameWithSubtasks());
}
discoveryLoopThread.start();
kafkaFetcher.runFetchLoop();
```

上面，就是 flink 动态发现 kafka 新增分区的过程。不过与 Spark 无需做任何配置不同的是，flink 动态发现 kafka 新增分区，这个功能时需要被开启的。也很简单，需要将 flink.partition-discovery.interval-millis 该属性设置为大于 0 即可。

#### 容错机制及处理语义

本节内容主要是想对比两者在故障恢复及如何保证仅一次的处理语义。这个时候适合抛出一个问题：实时处理的时候，如何保证数据仅一次处理语义？

**Spark Streaming 保证仅一次处理**

对于 Spark Streaming 任务，我们可以设置 checkpoint，然后假如发生故障并重启，我们可以从上次 checkpoint 之处恢复，但是这个行为只能使得数据不丢失，可能会重复处理，不能做到恰一次处理语义。

对于 Spark Streaming 与 kafka 结合的 direct Stream 可以自己维护 offset 到 zookeeper、kafka 或任何其它外部系统，每次提交完结果之后再提交 offset，这样故障恢复重启可以利用上次提交的 offset 恢复，保证数据不丢失。但是假如故障发生在提交结果之后、提交 offset 之前会导致数据多次处理，这个时候我们需要保证处理结果多次输出不影响正常的业务。

由此可以分析，假设要保证数据恰一次处理语义，那么结果输出和 offset 提交必须在一个事务内完成。在这里有以下两种做法：

1. repartition(1) : Spark Streaming 输出的 action 变成仅一个 partition，这样可以利用事务去做：

```
Dstream.foreachRDD(rdd=>{
   rdd.repartition(1).foreachPartition(partition=>{    
        //    开启事务
       partition.foreach(each=>{//提交数据
       })    //  提交事务
   })
 })
```

2. 将结果和 offset 一起提交: 也就是结果数据包含 offset。这样提交结果和提交 offset 就是一个操作完成，不会数据丢失，也不会重复处理。故障恢复的时候可以利用上次提交结果带的 offset。

**Flink 与 kafka 0.11 保证仅一次处理**

若要 sink 支持仅一次语义，必须以事务的方式写数据到 Kafka，这样当提交事务时两次 checkpoint 间的所有写入操作作为一个事务被提交。这确保了出现故障或崩溃时这些写入操作能够被回滚。

在一个分布式且含有多个并发执行 sink 的应用中，仅仅执行单次提交或回滚是不够的，因为所有组件都必须对这些提交或回滚达成共识，这样才能保证得到一致性的结果。Flink 使用两阶段提交协议以及预提交(pre-commit)阶段来解决这个问题。

本例中的 Flink 应用如图 11 所示包含以下组件：

一个source，从Kafka中读取数据（即KafkaConsumer）

一个时间窗口化的聚会操作

一个sink，将结果写回到Kafka（即KafkaProducer）

![image.png](https://image.hyly.net/i/2025/09/28/9884e6fdc013947744242854817fee62-0.webp)

下面详细讲解 flink 的两段提交思路：

![image.png](https://image.hyly.net/i/2025/09/28/128433adffa9c44fd37c04877b26d520-0.webp)

如图所示，Flink checkpointing 开始时便进入到 pre-commit 阶段。具体来说，一旦 checkpoint 开始，Flink 的 JobManager 向输入流中写入一个 checkpoint barrier ，将流中所有消息分割成属于本次 checkpoint 的消息以及属于下次 checkpoint 的，barrier 也会在操作算子间流转。对于每个 operator 来说，该 barrier 会触发 operator 状态后端为该 operator 状态打快照。data source 保存了 Kafka 的 offset，之后把 checkpoint barrier 传递到后续的 operator。

这种方式仅适用于 operator 仅有它的内部状态。内部状态是指 Flink state backends 保存和管理的内容（如第二个 operator 中 window 聚合算出来的 sum）。

当一个进程仅有它的内部状态的时候，除了在 checkpoint 之前将需要将数据更改写入到 state backend，不需要在预提交阶段做其他的动作。在 checkpoint 成功的时候，Flink 会正确的提交这些写入，在 checkpoint 失败的时候会终止提交，过程可见图。

![image.png](https://image.hyly.net/i/2025/09/28/2ef9ae79859ed2d54f7e2dd303bd8ce4-0.webp)

当结合外部系统的时候，外部系统必须要支持可与两阶段提交协议捆绑使用的事务。显然本例中的 sink 由于引入了 kafka sink，因此在预提交阶段 data sink 必须预提交外部事务。如下图：

![image.png](https://image.hyly.net/i/2025/09/28/7a9e3bbb93d9a4fef68a2ea397e58ef2-0.webp)

当 barrier 在所有的算子中传递一遍，并且触发的快照写入完成，预提交阶段完成。所有的触发状态快照都被视为 checkpoint 的一部分，也可以说 checkpoint 是整个应用程序的状态快照，包括预提交外部状态。出现故障可以从 checkpoint 恢复。下一步就是通知所有的操作算子 checkpoint 成功。该阶段 jobmanager 会为每个 operator 发起 checkpoint 已完成的回调逻辑。

本例中 data source 和窗口操作无外部状态，因此该阶段，这两个算子无需执行任何逻辑，但是 data sink 是有外部状态的，因此，此时我们必须提交外部事务，如下图：

以上就是 flink 实现恰一次处理的基本逻辑。

#### Back pressure背压/反压

消费者消费的速度低于生产者生产的速度，为了使应用正常，消费者会反馈给生产者来调节生产者生产的速度，以使得消费者需要多少，生产者生产多少。
*back pressure 后面一律称为背压。

**Spark Streaming 的背压**

Spark Streaming 跟 kafka 结合是存在背压机制的，目标是根据当前 job 的处理情况来调节后续批次的获取 kafka 消息的条数。为了达到这个目的，Spark Streaming 在原有的架构上加入了一个 RateController，利用的算法是 PID，需要的反馈数据是任务处理的结束时间、调度时间、处理时间、消息条数，这些数据是通过 SparkListener 体系获得，然后通过 PIDRateEsimator 的 compute 计算得到一个速率，进而可以计算得到一个 offset，然后跟限速设置最大消费条数比较得到一个最终要消费的消息最大 offset。

PIDRateEsimator 的 compute 方法如下：

```
def compute(time: Long, // in milliseconds
     numElements: Long,      
     processingDelay: Long, // in milliseconds
     schedulingDelay: Long // in milliseconds
   ): Option[Double] = {
   logTrace(s"\ntime = $time, ## records = $numElements, " +
     s"processing time = $processingDelay, scheduling delay = $schedulingDelay")    
     this.synchronized {      
       if (time > latestTime && numElements > 0 && processingDelay > 0) {        
       val delaySinceUpdate = (time - latestTime).toDouble / 1000
       val processingRate = numElements.toDouble / processingDelay * 1000
       val error = latestRate - processingRate        
       val historicalError = schedulingDelay.toDouble * processingRate / batchIntervalMillis        
       // in elements/(second ^ 2)
       val dError = (error - latestError) / delaySinceUpdate       
       val newRate = (latestRate - proportional * error -
                                   integral * historicalError -
                                   derivative * dError).max(minRate)
       logTrace(s"""  | latestRate = $latestRate, error = $error            
                      | latestError = $latestError, historicalError = $historicalError            
                      | delaySinceUpdate = $delaySinceUpdate, dError = $dError           
                 """.stripMargin)
       latestTime = time        
       if (firstRun) {
         latestRate = processingRate
         latestError = 0D
         firstRun = false
         logTrace("First run, rate estimation skipped")         
         None
       } else {
         latestRate = newRate
         latestError = error
         logTrace(s"New rate = $newRate")          
         Some(newRate)
       }
     } else {
       logTrace("Rate estimation skipped")        
       None
     }
   }
 }
```

**Flink 的背压**

与 Spark Streaming 的背压不同的是，Flink 1.5 之后实现了自己托管的 credit – based 流控机制，在应用层模拟 TCP 的流控机制，就是每一次 ResultSubPartition 向 InputChannel 发送消息的时候都会发送一个 backlog size 告诉下游准备发送多少消息，下游就会去计算有多少的 Buffer 去接收消息，算完之后如果有充足的 Buffer 就会返还给上游一个 Credit 告知他可以发送消息
jobmanager 针对每一个 task 每 50ms 触发 100 次 Thread.getStackTrace() 调用，求出阻塞的占比。过程如图 16 所示：

![image.png](https://image.hyly.net/i/2025/09/28/859d94a23c56a835d6d652a517f36e1e-0.webp)

阻塞占比在 web 上划分了三个等级：
OK: 0 &#x3c;= Ratio &#x3c;= 0.10，表示状态良好；
LOW: 0.10 &#x3c; Ratio &#x3c;= 0.5，表示有待观察；
HIGH: 0.5 &#x3c; Ratio &#x3c;= 1，表示要处理了。
例如，0.01，代表着100次中有一次阻塞在内部调用

### Flink-网络流控及反压

#### 网络流控的概念与背景

##### 为什么需要网络流控

![image.png](https://image.hyly.net/i/2025/09/28/bd280c7faba19be02ac52298a15f662d-0.webp)

首先我们可以看下这张最精简的网络流控的图，Producer 的吞吐率是 2MB/s，Consumer 是 1MB/s，这个时候我们就会发现在网络通信的时候我们的 Producer 的速度是比 Consumer 要快的，有 1MB/s 的这样的速度差，假定我们两端都有一个 Buffer，Producer 端有一个发送用的 Send Buffer，Consumer 端有一个接收用的 Receive Buffer，在网络端的吞吐率是 2MB/s，过了 5s 后我们的 Receive Buffer 可能就撑不住了，这时候会面临两种情况：

如果 Receive Buffer 是有界的，这时候新到达的数据就只能被丢弃掉了。
如果 Receive Buffer 是无界的，Receive Buffer 会持续的扩张，最终会导致 Consumer 的内存耗尽。

##### 网络流控的实现：静态限速

![image.png](https://image.hyly.net/i/2025/09/28/356825f7641d659c226f38b860ff0d19-0.webp)

为了解决这个问题，我们就需要网络流控来解决上下游速度差的问题，传统的做法可以在 Producer 端实现一个类似 Rate Limiter 这样的静态限流，Producer 的发送速率是 2MB/s，但是经过限流这一层后，往 Send Buffer 去传数据的时候就会降到 1MB/s 了，这样的话 Producer 端的发送速率跟 Consumer 端的处理速率就可以匹配起来了，就不会导致上述问题。但是这个解决方案有两点限制：

事先无法预估 Consumer 到底能承受多大的速率

Consumer 的承受能力通常会动态地波动

##### 网络流控的实现：动态反馈/自动反压

![image.png](https://image.hyly.net/i/2025/09/28/e1723cbf80ca4f613f5532d2871b0c6f-0.webp)

针对静态限速的问题我们就演进到了动态反馈（自动反压）的机制，我们需要 Consumer 能够及时的给 Producer 做一个 feedback，即告知 Producer 能够承受的速率是多少。动态反馈分为两种：
负反馈：接受速率小于发送速率时发生，告知 Producer 降低发送速率
正反馈：发送速率小于接收速率时发生，告知 Producer 可以把发送速率提上来

让我们来看几个经典案例

###### 案例一：Storm 反压实现

![image.png](https://image.hyly.net/i/2025/09/28/0dbfb0550a1c4fcade243f90fe1686f1-0.webp)

上图就是 Storm 里实现的反压机制，可以看到 Storm 在每一个 Bolt 都会有一个监测反压的线程（Backpressure Thread），这个线程一但检测到 Bolt 里的接收队列（recv queue）出现了严重阻塞就会把这个情况写到 ZooKeeper 里，ZooKeeper 会一直被 Spout 监听，监听到有反压的情况就会停止发送，通过这样的方式匹配上下游的发送接收速率。

###### 案例二：Spark Streaming 反压实现

![image.png](https://image.hyly.net/i/2025/09/28/d571f9ffb7ef80a5cf4bfd9fdfbbfe87-0.webp)

Spark Streaming 里也有做类似这样的 feedback 机制，上图 Fecher 会实时的从 Buffer、Processing 这样的节点收集一些指标然后通过 Controller 把速度接收的情况再反馈到 Receiver，实现速率的匹配。

###### 疑问：为什么 Flink（before V1.5）没有用类似的方式实现 feedback 机制？

首先在解决这个疑问之前我们需要先了解一下 Flink 的网络传输是一个什么样的架构。

![image.png](https://image.hyly.net/i/2025/09/28/d59d3a094003e479477e75e6cc72bbc9-0.webp)

这张图就体现了 Flink 在做网络传输的时候基本的数据的流向，发送端在发送网络数据前要经历自己内部的一个流程，会有一个自己的 Network Buffer，在底层用 Netty 去做通信，Netty 这一层又有属于自己的 ChannelOutbound Buffer，因为最终是要通过 Socket 做网络请求的发送，所以在 Socket 也有自己的 Send Buffer，同样在接收端也有对应的三级 Buffer。学过计算机网络的时候我们应该了解到，TCP 是自带流量控制的。
实际上 Flink （before V1.5）就是通过 TCP 的流控机制来实现 feedback 的。

###### TCP 流控机制

根据下图我们来简单的回顾一下 TCP 包的格式结构。首先，他有 Sequence number 这样一个机制给每个数据包做一个编号，还有 ACK number 这样一个机制来确保 TCP 的数据传输是可靠的，除此之外还有一个很重要的部分就是 Window Size，接收端在回复消息的时候会通过 Window Size 告诉发送端还可以发送多少数据。

![image.png](https://image.hyly.net/i/2025/09/28/b1dd068c3d97d4c4363ac3fe82c8f671-0.webp)

接下来我们来简单看一下这个过程。
TCP 流控：滑动窗口

![image.png](https://image.hyly.net/i/2025/09/28/2186f5d3f80c8a5587f9fbca76af90f5-0.webp)

TCP 的流控就是基于滑动窗口的机制，现在我们有一个 Socket 的发送端和一个 Socket 的接收端，目前我们的发送端的速率是我们接收端的 3 倍，这样会发生什么样的一个情况呢？假定初始的时候我们发送的 window 大小是 3，然后我们接收端的 window 大小是固定的，就是接收端的 Buffer 大小为 5。

![image.png](https://image.hyly.net/i/2025/09/28/5f692d36292ec225774d7980c904a940-0.webp)

首先，发送端会一次性发 3 个 packets，将 1，2，3 发送给接收端，接收端接收到后会将这 3 个 packets 放到 Buffer 里去。

![image.png](https://image.hyly.net/i/2025/09/28/c857aa0634882d9991101d5c5263342c-0.webp)

接收端一次消费 1 个 packet，这时候 1 就已经被消费了，然后我们看到接收端的滑动窗口会往前滑动一格，这时候 2，3 还在 Buffer 当中 而 4，5，6 是空出来的，所以接收端会给发送端发送 ACK = 4 ，代表发送端可以从 4 开始发送，同时会将 window 设置为 3 （Buffer 的大小 5 减去已经存下的 2 和 3），发送端接收到回应后也会将他的滑动窗口向前移动到 4，5，6。

![image.png](https://image.hyly.net/i/2025/09/28/2d80c610e53155bb8dffbee4de58d31c-0.webp)

这时候发送端将 4，5，6 发送，接收端也能成功的接收到 Buffer 中去。

![image.png](https://image.hyly.net/i/2025/09/28/dba8a10fd8b091431897f3afa1f84e3f-0.webp)

到这一阶段后，接收端就消费到 2 了，同样他的窗口也会向前滑动一个，这时候他的 Buffer 就只剩一个了，于是向发送端发送 ACK = 7、window = 1。发送端收到之后滑动窗口也向前移，但是这个时候就不能移动 3 格了，虽然发送端的速度允许发 3 个 packets 但是 window 传值已经告知只能接收一个，所以他的滑动窗口就只能往前移一格到 7 ，这样就达到了限流的效果，发送端的发送速度从 3 降到 1。

![image.png](https://image.hyly.net/i/2025/09/28/e962ca577c0773010dcd4e368673ee1c-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/9878c6372aaebd5a8c4af96969bc5945-0.webp)

我们再看一下这种情况，这时候发送端将 7 发送后，接收端接收到，但是由于接收端的消费出现问题，一直没有从 Buffer 中去取，这时候接收端向发送端发送 ACK = 8、window = 0 ，由于这个时候 window = 0，发送端是不能发送任何数据，也就会使发送端的发送速度降为 0。这个时候发送端不发送任何数据了，接收端也不进行任何的反馈了，那么如何知道消费端又开始消费了呢？

![image.png](https://image.hyly.net/i/2025/09/28/2b68e96d2e32872aabc4f8df7b33ffaf-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/33567f6bdc6b413177b74ce6a5525cee-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/f947129d05c20cef0295e10809da3d1d-0.webp)

TCP 当中有一个 ZeroWindowProbe 的机制，发送端会定期的发送 1 个字节的探测消息，这时候接收端就会把 window 的大小进行反馈。当接收端的消费恢复了之后，接收到探测消息就可以将 window 反馈给发送端端了从而恢复整个流程。TCP 就是通过这样一个滑动窗口的机制实现 feedback。

##### Flink TCP-based 反压机制（before V1.5）

示例：WindowWordCount

![image.png](https://image.hyly.net/i/2025/09/28/f4a98ccb80092d122c1801613fd3dfe8-0.webp)

大体的逻辑就是从 Socket 里去接收数据，每 5s 去进行一次 WordCount，将这个代码提交后就进入到了编译阶段。
编译阶段：生成 JobGraph

![image.png](https://image.hyly.net/i/2025/09/28/3e5228871c9be7673fd335a21b41c4f7-0.webp)

这时候还没有向集群去提交任务，在 Client 端会将 StreamGraph 生成 JobGraph，JobGraph 就是做为向集群提交的最基本的单元。在生成 JobGrap 的时候会做一些优化，将一些没有 Shuffle 机制的节点进行合并。有了 JobGraph 后就会向集群进行提交，进入运行阶段。
运行阶段：调度 ExecutionGraph

![image.png](https://image.hyly.net/i/2025/09/28/89715dae2a6eaf1fc2541b086cac418f-0.webp)

JobGraph 提交到集群后会生成 ExecutionGraph ，这时候就已经具备基本的执行任务的雏形了，把每个任务拆解成了不同的 SubTask，上图 ExecutionGraph 中的 Intermediate Result Partition 就是用于发送数据的模块，最终会将 ExecutionGraph 交给 JobManager 的调度器，将整个 ExecutionGraph 调度起来。然后我们概念化这样一张物理执行图，可以看到每个 Task 在接收数据时都会通过这样一个 InputGate 可以认为是负责接收数据的，再往前有这样一个 ResultPartition 负责发送数据，在 ResultPartition 又会去做分区跟下游的 Task 保持一致，就形成了 ResultSubPartition 和 InputChannel 的对应关系。这就是从逻辑层上来看的网络传输的通道，基于这么一个概念我们可以将反压的问题进行拆解。

问题拆解：反压传播两个阶段

![image.png](https://image.hyly.net/i/2025/09/28/5f3dab7c45c565bd1d5d70d36fd8a3b5-0.webp)

反压的传播实际上是分为两个阶段的，对应着上面的执行图，我们一共涉及 3 个 TaskManager，在每个 TaskManager 里面都有相应的 Task 在执行，还有负责接收数据的 InputGate，发送数据的 ResultPartition，这就是一个最基本的数据传输的通道。在这时候假设最下游的 Task （Sink）出现了问题，处理速度降了下来这时候是如何将这个压力反向传播回去呢？这时候就分为两种情况：
跨 TaskManager ，反压如何从 InputGate 传播到 ResultPartition
TaskManager 内，反压如何从 ResultPartition 传播到 InputGate

###### 跨 TaskManager 数据传输

![image.png](https://image.hyly.net/i/2025/09/28/83cbc0da149f7c2cdfc14f34491dda1f-0.webp)

前面提到，发送数据需要 ResultPartition，在每个 ResultPartition 里面会有分区 ResultSubPartition，中间还会有一些关于内存管理的 Buffer。

对于一个 TaskManager 来说会有一个统一的 Network BufferPool 被所有的 Task 共享，在初始化时会从 Off-heap Memory 中申请内存，申请到内存的后续内存管理就是同步 Network BufferPool 来进行的，不需要依赖 JVM GC 的机制去释放。有了 Network BufferPool 之后可以为每一个 ResultSubPartition 创建 Local BufferPool 。

如上图左边的 TaskManager 的 Record Writer 写了 &#x3c;1，2> 这个两个数据进来，因为 ResultSubPartition 初始化的时候为空，没有 Buffer 用来接收，就会向 Local BufferPool 申请内存，这时 Local BufferPool 也没有足够的内存于是将请求转到 Network BufferPool，最终将申请到的 Buffer 按原链路返还给 ResultSubPartition，&#x3c;1，2> 这个两个数据就可以被写入了。之后会将 ResultSubPartition 的 Buffer 拷贝到 Netty 的 Buffer 当中最终拷贝到 Socket 的 Buffer 将消息发送出去。然后接收端按照类似的机制去处理将消息消费掉。

接下来我们来模拟上下游处理速度不匹配的场景，发送端的速率为 2，接收端的速率为 1，看一下反压的过程是怎样的。

###### 跨 TaskManager 反压过程

![image.png](https://image.hyly.net/i/2025/09/28/8ae1efb8626dd0274a3eaba3c5108265-0.webp)

因为速度不匹配就会导致一段时间后 InputChannel 的 Buffer 被用尽，于是他会向 Local BufferPool 申请新的 Buffer ，这时候可以看到 Local BufferPool 中的一个 Buffer 就会被标记为 Used。

![image.png](https://image.hyly.net/i/2025/09/28/c1d772964bb6e9b17858ebb2e602c4ff-0.webp)

发送端还在持续以不匹配的速度发送数据，然后就会导致 InputChannel 向 Local BufferPool 申请 Buffer 的时候发现没有可用的 Buffer 了，这时候就只能向 Network BufferPool 去申请，当然每个 Local BufferPool 都有最大的可用的 Buffer，防止一个 Local BufferPool 把 Network BufferPool 耗尽。这时候看到 Network BufferPool 还是有可用的 Buffer 可以向其申请。

![image.png](https://image.hyly.net/i/2025/09/28/a2d9bdf2d548cc7a14648d87bac2e21e-0.webp)

一段时间后，发现 Network BufferPool 没有可用的 Buffer，或是 Local BufferPool 的最大可用 Buffer 到了上限无法向 Network BufferPool 申请，没有办法去读取新的数据，这时 Netty AutoRead 就会被禁掉，Netty 就不会从 Socket 的 Buffer 中读取数据了。

![image.png](https://image.hyly.net/i/2025/09/28/eda23c02393f0e4667644ed36b8c4dc2-0.webp)

显然，再过不久 Socket 的 Buffer 也被用尽，这时就会将 Window = 0 发送给发送端（前文提到的 TCP 滑动窗口的机制）。这时发送端的 Socket 就会停止发送。

![image.png](https://image.hyly.net/i/2025/09/28/16632960d3be34aba0119032681ad063-0.webp)

很快发送端的 Socket 的 Buffer 也被用尽，Netty 检测到 Socket 无法写了之后就会停止向 Socket 写数据。

![image.png](https://image.hyly.net/i/2025/09/28/f15e905a012cdb704b923496a666d4f1-0.webp)

Netty 停止写了之后，所有的数据就会阻塞在 Netty 的 Buffer 当中了，但是 Netty 的 Buffer 是无界的，可以通过 Netty 的水位机制中的 high watermark 控制他的上界。当超过了 high watermark，Netty 就会将其 channel 置为不可写，ResultSubPartition 在写之前都会检测 Netty 是否可写，发现不可写就会停止向 Netty 写数据。

![image.png](https://image.hyly.net/i/2025/09/28/35a5844a777614e1cf740cd51ff635f9-0.webp)

这时候所有的压力都来到了 ResultSubPartition，和接收端一样他会不断的向 Local BufferPool 和 Network BufferPool 申请内存。

![image.png](https://image.hyly.net/i/2025/09/28/ef97449a203fe6083f8c07f6eafc82eb-0.webp)

Local BufferPool 和 Network BufferPool 都用尽后整个 Operator 就会停止写数据，达到跨 TaskManager 的反压。

###### TaskManager 内反压过程

了解了跨 TaskManager 反压过程后再来看 TaskManager 内反压过程就更好理解了，下游的 TaskManager 反压导致本 TaskManager 的 ResultSubPartition 无法继续写入数据，于是 Record Writer 的写也被阻塞住了，因为 Operator 需要有输入才能有计算后的输出，输入跟输出都是在同一线程执行， Record Writer 阻塞了，Record Reader 也停止从 InputChannel 读数据，这时上游的 TaskManager 还在不断地发送数据，最终将这个 TaskManager 的 Buffer 耗尽。具体流程可以参考下图，这就是 TaskManager 内的反压过程。

![image.png](https://image.hyly.net/i/2025/09/28/8139b2b5c42127eff11d3d8d0c29744a-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/189e8cad49aa561c16460aa7f6849c7d-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/88e11bcfae66f8ad806a68e1ed4311a8-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/b5628eb7bbf0cede72a7e239b325795a-0.webp)

##### Flink Credit-based 反压机制（since V1.5）

###### TCP-based 反压的弊端

![image.png](https://image.hyly.net/i/2025/09/28/5dce9d12a0da2d4d0cb425bd81bdc626-0.webp)

在介绍 Credit-based 反压机制之前，先分析下 TCP 反压有哪些弊端。

在一个 TaskManager 中可能要执行多个 Task，如果多个 Task 的数据最终都要传输到下游的同一个 TaskManager 就会复用同一个 Socket 进行传输，这个时候如果单个 Task 产生反压，就会导致复用的 Socket 阻塞，其余的 Task 也无法使用传输，checkpoint barrier 也无法发出导致下游执行 checkpoint 的延迟增大。

依赖最底层的 TCP 去做流控，会导致反压传播路径太长，导致生效的延迟比较大。

###### 引入 Credit-based 反压

这个机制简单的理解起来就是在 Flink 层面实现类似 TCP 流控的反压机制来解决上述的弊端，Credit 可以类比为 TCP 的 Window 机制。
Credit-based 反压过程

![image.png](https://image.hyly.net/i/2025/09/28/42058fc63998ae3006e71c039fc1b2f1-0.webp)

如图所示在 Flink 层面实现反压机制，就是每一次 ResultSubPartition 向 InputChannel 发送消息的时候都会发送一个 backlog size 告诉下游准备发送多少消息，下游就会去计算有多少的 Buffer 去接收消息，算完之后如果有充足的 Buffer 就会返还给上游一个 Credit 告知他可以发送消息（图上两个 ResultSubPartition 和 InputChannel 之间是虚线是因为最终还是要通过 Netty 和 Socket 去通信），下面我们看一个具体示例。

![image.png](https://image.hyly.net/i/2025/09/28/e4eb8a3b8cfd1da3855538cebde9af77-0.webp)

假设我们上下游的速度不匹配，上游发送速率为 2，下游接收速率为 1，可以看到图上在 ResultSubPartition 中累积了两条消息，10 和 11， backlog 就为 2，这时就会将发送的数据 &#x3c;8,9> 和 backlog = 2 一同发送给下游。下游收到了之后就会去计算是否有 2 个 Buffer 去接收，可以看到 InputChannel 中已经不足了这时就会从 Local BufferPool 和 Network BufferPool 申请，好在这个时候 Buffer 还是可以申请到的。

![image.png](https://image.hyly.net/i/2025/09/28/6a88c7734c975114f753afb2bfedd35c-0.webp)

过了一段时间后由于上游的发送速率要大于下游的接受速率，下游的 TaskManager 的 Buffer 已经到达了申请上限，这时候下游就会向上游返回 Credit = 0，ResultSubPartition 接收到之后就不会向 Netty 去传输数据，上游 TaskManager 的 Buffer 也很快耗尽，达到反压的效果，这样在 ResultSubPartition 层就能感知到反压，不用通过 Socket 和 Netty 一层层地向上反馈，降低了反压生效的延迟。同时也不会将 Socket 去阻塞，解决了由于一个 Task 反压导致 TaskManager 和 TaskManager 之间的 Socket 阻塞的问题。

##### 总结

网络流控是为了在上下游速度不匹配的情况下，防止下游出现过载
网络流控有静态限速和动态反压两种手段
Flink 1.5 之前是基于 TCP 流控 + bounded buffer 实现反压
Flink 1.5 之后实现了自己托管的 credit – based 流控机制，在应用层模拟 TCP 的流控机制
就是每一次 ResultSubPartition 向 InputChannel 发送消息的时候都会发送一个 backlog size 告诉下游准备发送多少消息，下游就会去计算有多少的 Buffer 去接收消息，算完之后如果有充足的 Buffer 就会返还给上游一个 Credit 告知他可以发送消息

**思考**

有了动态反压，静态限速是不是完全没有作用了？

![image.png](https://image.hyly.net/i/2025/09/28/798da3e2290d3a2f004cd4980572316c-0.webp)

实际上动态反压不是万能的，我们流计算的结果最终是要输出到一个外部的存储（Storage），外部数据存储到 Sink 端的反压是不一定会触发的，这要取决于外部存储的实现，像 Kafka 这样是实现了限流限速的消息中间件可以通过协议将反压反馈给 Sink 端，但是像 ES 无法将反压进行传播反馈给 Sink 端，这种情况下为了防止外部存储在大的数据量下被打爆，我们就可以通过静态限速的方式在 Source 端去做限流。所以说动态反压并不能完全替代静态限速的，需要根据合适的场景去选择处理方案

##### 背压状态

如果您看到任务的状态为“ **正常** ”，则表明没有背压。高，另一方面意味着任务是背压力。

![image.png](https://image.hyly.net/i/2025/09/28/c9d5f6aa02a3974b479c647dd68359e6-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/f1591a823b20f2965edd998abd160231-0.webp)

##### 背压指标含义

```
为了判断是否进行反压，jobmanager会每50ms触发100次stack traces。
Web界面中显示阻塞在内部方法调用的stacktraces占所有的百分比。
例如，0.01，代表着100次中有一次阻塞在内部调用。
OK: 0 <= Ratio <= 0.10
LOW: 0.10 < Ratio <= 0.5
HIGH: 0.5 < Ratio <= 1
```

![image.png](https://image.hyly.net/i/2025/09/28/2c2b21051ab48cb378d111b694433329-0.webp)

可以使用以下配置为作业管理器配置样本数：

1. web.backpressure.refresh-interval：不推荐使用的统计信息将在此之前过期，需要刷新（默认值：60000ms）。
2. web.backpressure.num-samples：用来确定背压的样本数量（默认值：100）。
   web.backpressure.delay-between-samples：样品之间的延迟以确定背压（默认值：50 ms）