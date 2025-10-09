---
category: [大数据技术栈]
tag: [Hadoop,大数据,OLAP,数据库]
postType: post
status: publish
---

## Hadoop特性优点

1. 扩容能力（scalability）。Hadoop是在可用的计算机集群间分配数据并完成计算任务的，这些集群可方便灵活的方式扩展到数以千计的节点。
2. 成本低（economical）。Hadoop集群允许通过部署普通廉价的机器组成集群来处理大数据，以至于成本很低。看重的是集群整理能力。
3. 效率高（efficiency）。通过并发数据，Hadoop可以在节点之间动态并行的移动数据，使得速度非常快。
4. 可靠性（reliability）能自动维护数据的多份复制，并且在任务失败后能自动地重新部署（redeploy）计算任务。所以Hadoop的按位存储和处理数据的能力值得人们信赖。

## Hadoop集群简介

![image.png](https://image.hyly.net/i/2025/10/09/e942c3246d139a93b281f5588b742461-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/175b49073e8172d4f955f13d35714667-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/e308c49a838d42f8f5e511e77b718b2b-0.webp)

## HDFS工作流程与机制

![image.png](https://image.hyly.net/i/2025/10/09/d1140f70d7c9038f72c82704c0cb2f97-0.webp)

### 主角色：NameNode

1. NameNode是Hadoop分布式文件系统的核心，架构中的主角色。
2. **NameNode维护和管理文件系统元数据**，包括名称空间目录树结构、文件和块位置信息、访问权限等信息。
3. 基于此，**NameNode成为了访问HDFS的唯一入口**。
4. NameNode内部通过**内存和磁盘文件**两种方式管理元数据。
5. 其中磁盘上的元数据文件包括Fsimage内存元数据镜像文件和edits log（Journal）编辑日志。

#### NameNode职责

1. NameNode仅**存储HDFS的元数据**：文件系统中所有文件的目录树，并跟踪整个集群中的文件，不存储实际数据。
2. NameNode知道HDFS中**任何给定文件的块列表及其位置**。使用此信息NameNode知道如何从块中构建文件。
3. **NameNode不持久化存储每个文件中各个块所在的DataNode的位置信息，这些信息会在系统启动时从DataNode重建。**
4. NameNode是Hadoop集群中的**单点故障**。
5. NameNode所在机器通常会配置有**大量内存（RAM）**。

### 从角色：DataNode

1. DataNode是Hadoop HDFS中的从角色，负责具体的数据块存储。
2. DataNode的数量决定了HDFS集群的整理数据存储能力。通过和NameNode配合维护着数据块。

#### DataNode职责

1. DataNode负责最终数据块block的存储。是集群的从角色，也称为Slave。
2. **DataNode启动时，会将自己注册到NameNode并汇报自己负责持有的块列表。**
3. **当某个DataNode关闭时，不会影响数据的可用性。NameNode将安排由其他DataNode管理的块进行副本复制。（高可用）**
4. DataNode所在机器通常配置有大量的硬盘空间，因为实际数据存储在DataNode中。

### 主角色辅助角色：SecondaryNameNode

1. **SecondaryNameNode充当NameNode的辅助节点，但不能替代NameNode。（单机故障的来源）**
2. 主要是帮助主角色进行元数据文件的合并动作。可以通俗的理解为主角色的“秘书”。

### HDFS写数据流程

1. HDFS客户端创建对象实例DistributedFileSystem，该对象中封装了与HDFS文件系统操作的相关方法。
2. 调用DistributedFileSystem对象的create()方法，通过RPC请求NameNode创建文件。NameNode执行各种检查判断：目标文件是否存在、父目录是否存在、客户端是否具有创建该文件的权限。检查通过，NameNode就会为本次请求记下一条记录，返回FSDataOutputStream输出流对象给客户端用于写数据。
3. 客户端通过FSDataOutputStream输出流开始写入数据。
4. 客户端写入数据时，将数据分成一个个数据包（packet 默认64K），内部组件DataStreamer请求NameNode挑选出适合存储数据副本的一组DataNode地址，默认是3副本策略。DataStreamer将数据包流式传输到pipeline的第一个DataNode，该DataNode存储数据包并将它发送到pipepline的第二个DataNode，同样，第二个DataNode存储数据包并且发送给第三个（也是最后一个）DataNode。
5. 传输的反方向上，会通过ACK机制校验数据包传输是否成功。
6. 客户端完成数据写入后，在FSDataOutputStream输出流上调用close（）方法关闭。
7. DistributedFileSystem联系NameNode告知其文件写入完成，等待NameNode确认。因为NameNode已经知道文件由哪些块组成（DataStream请求分配数据块），因此仅需等待最小复制块即可成功返回。最小复制是由参数dfs.namenode.replication.min指定，默认值是1。

![image.png](https://image.hyly.net/i/2025/10/09/9e8d716f43902c723d02de9a85ccdc46-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/ee375362edf238a003c1ee7347403717-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/99d7b9086e038846b00b27fe83d6b8b8-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/c0a9391f1f908d91ce6c6796ec73e6a1-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/8bc09d9c1ebbdb1d766dd6a4ed1181fa-0.webp)

## MapReduce阶段划分与进程组成

![image.png](https://image.hyly.net/i/2025/10/09/16814a1bd417c42909af1700ad847504-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/2ff817119e2600bd8db52f6ad6a11dc2-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/29ac70727e071c93fea6920d328c9ee6-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/470072aaf102b1b730cd17d33dcff685-0.webp)

### MapReduce整体执行流程图

![image.png](https://image.hyly.net/i/2025/10/09/ac60d45eabf0c3bf5c6d1bc59cb90d50-0.webp)

### Map阶段执行过程

1. 把输入目录下文件按照一定的标准逐个进行**逻辑切片**，形成切片规划。默认Split size=Block size(128M)，每一个切片由一个MapTask处理。（getSplits）。
2. 对切片中的数据按照一定的规则读取解析返回&#x3c;key，value>对。默认是**按行读取数据**。key是每一行的起始位置偏移量，value是本行的文本内容。（TextInputFormat）。
3. 调用Mapper类中的map方法处理数据。每读取解析出来的一个&#x3c;key，value>，调用一次map方法。
4. 按照一定的规则对map输出的键值对进行分区partition。默认不分区，因为只有一个reducetask。分区的数量就是reducetask运行的数量。
5. map输出数据写入**内存缓冲区**，达到比例溢出到磁盘上，溢出spill的时候根据key进行排序sort。默认根据key字典序排序。
6. 对所有溢出文件进行最终的merge合并，成为一个文件。

### Reduce阶段执行过程

1. ReduceTask会**主动**从MapTask复制拉取属于需要自己处理的数据。
2. 把拉取来的数据，全部进行合并merge，即把分散的数据合并成一个大的数据。再对合并后的数据排序。
3. 对排序后的键值对调用reduce方法。键相等的键值对调用一次reduce方法。最后把这些输出的键值对写入到HDFS文件中。

### Shuffle机制

![image.png](https://image.hyly.net/i/2025/10/09/59ff6473e7b8b2610e2f50b32fb670b2-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/d96843cee8f9dae624c4f371c9346170-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/bf9479ea47c26bfffb6f53a4ece3e5f9-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/a1966cefe6edfa2bf1fe30d49d263ca8-0.webp)

## YARN架构

![image.png](https://image.hyly.net/i/2025/10/09/2b38a74476df7512299a275ba2c7fe9b-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/0f233b52560f3296c291b9485f37de81-0.webp)

### 程序提交YARN集群交互流程

![image.png](https://image.hyly.net/i/2025/10/09/22c4324f4d81b52ee4bfafc0c8cf49d1-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/b3b1c86c15485694789166db5f265892-0.webp)

**MR提交YARN交互流程**

1. 用户通过客户端向YARN中ResourceManager提交应用程序（比如Hadoop jar提交MR程序）。
2. ResourceManager为该应用程序分配第一个Container（容器），并与对应的NodeManager通信，要求它在这个Container中启动这个应用程序的ApplicationMaster。
3. ApplicationMaster启动成功之后，首先向ResourceManager注册并保持通信，这样用户可以直接通过ResourceManage查看应用程序的运行状态（处理了百分之几）。
4. AM为本次程序内部的各个Task任务向RM申请资源，并监控它的运行状态。
5. 一旦ApplicationMaster申请到资源后，便与对应的NodeManager通信，要求它启动任务。
6. NodeManager为任务设置好运行环境后，将任务启动命令写到一个脚本中，并通过运行该脚本启动任务。
7. 各个任务通过某个RPC协议向ApplicationMaster汇报自己的状态和进度，以让ApplicationMaster随时掌握 各个任务的运行状态，从而可以在任务失败时重新启动任务。在应用程序运行过程中，用户可随时通过RPC向ApplicationMaster查询应用程序的当前运行状态。
8. 应用程序运行完成后，

### scheduler资源调度器和调度策略

![image.png](https://image.hyly.net/i/2025/10/09/5e1e469e6cb3d436b0a1a33836c55b03-0.webp)

#### 先进先出调度器（FIFO Scheduler）

![image.png](https://image.hyly.net/i/2025/10/09/c6b2e65bbfae4646d6b7fc3fc127e116-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/e8618cf81cb198623fa25f25960b3d35-0.webp)

#### 容量调度器（Capacity Scheduler）

![image.png](https://image.hyly.net/i/2025/10/09/396281bf4e9ed44aa00e575c561eedda-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/e1d0255de299bb86a907c4b5eb5a8e85-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/a3d61e5d601c9e478bad51afd5f3b236-0.webp)

#### 公平调度器（Fair Scheduler）

![image.png](https://image.hyly.net/i/2025/10/09/1f22312d3340d01e15ed76858020a985-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/62285f1893978d93d6ae4fb103d078f2-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/35525f9a329a93c70a9e6f94b8c7abf1-0.webp)

![image.png](https://image.hyly.net/i/2025/10/09/4a60ff40a6abe7102974fc603512ed64-0.webp)