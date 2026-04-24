---
category: [大数据技术栈]
tag: [Hbase,大数据,OLAP,陌陌海量数据案例]
postType: post
status: publish
---

## 案例介绍

![image.png](https://image.hyly.net/i/2025/09/28/8c4defcc1e2c22faaf390a862c5b24a8-0.webp)

在陌陌中，每天都有数千万的用户聊天消息需要存储。而且，这些消息都是需要进行大量地保存，而读取会少很多。想想：我们在使用微信的时候，大多数时候，我们都是在发消息，而不是每时每刻查询历史消息。要存储这样海量的数据，HBase就非常适合了，HBase本身也非常适合存储这种写多读少的应用场景。本案例，将结合陌陌聊天业务背景，以HBase来存储海量的数据。

通过本案例，我们能学习到以下知识点：

1. HBase表的设计
   1. 涵盖HBase表预分区
   2. ROWKEY设计
2. HBase调优
3. 使用Apache Phoenix SQL查询引擎
4. 基于HBase的分页查询
5. 数据查询接口开发

## 打招呼消息数据集介绍

<figure class='table-figure'><table>
<thead>
<tr><th>字段名</th><th>说明</th></tr></thead>
<tbody><tr><td>msg_time</td><td>消息时间</td></tr><tr><td>sender_nickyname</td><td>发件人昵称</td></tr><tr><td>sender_account</td><td>发件人账号</td></tr><tr><td>sender_sex</td><td>发件人性别</td></tr><tr><td>sender_ip</td><td>发件人IP</td></tr><tr><td>sender_os</td><td>发件人系统</td></tr><tr><td>sender_phone_type</td><td>发件人手机型号</td></tr><tr><td>sender_network</td><td>发件人网络制式</td></tr><tr><td>sender_gps</td><td>发件人GPS</td></tr><tr><td>receiver_nickyname</td><td>收件人昵称</td></tr><tr><td>receiver_ip</td><td>收件人IP</td></tr><tr><td>receiver_account</td><td>收件人账号</td></tr><tr><td>receiver_os</td><td>收件人系统</td></tr><tr><td>receiver_phone_type</td><td>收件人手机型号</td></tr><tr><td>receiver_network</td><td>收件人网络制式</td></tr><tr><td>receiver_gps</td><td>收件人GPS</td></tr><tr><td>receiver_sex</td><td>收件人性别</td></tr><tr><td>msg_type</td><td>消息类型</td></tr><tr><td>distance</td><td>双方距离</td></tr><tr><td>message</td><td>消息</td></tr></tbody>
</table></figure>

## 准备工作

### 创建IDEA Maven项目

<figure class='table-figure'><table>
<thead>
<tr><th>groupId</th><th>cn.itcast</th></tr></thead>
<tbody><tr><td>artifactId</td><td>momo_chat_app</td></tr></tbody>
</table></figure>

### 在项目中创建存放hbase shell脚本目录

在项目下创建名为 hbase_shell 的目录，再创建一个 readme.md 文件，如下图：

readme.md中写入如下：

```
# 陌陌海量消息存储说明文档
### 1. 项目结构说明
* hbase_shell：用于存放hbase shell操作脚本
* momo_chat_app：Java API数据接口
```

### 创建脚本文件

在hbase_shell下创建名为 create_ns_table.rb 文件，用于编写Hbase相关脚本，并使用VSCode打开项目文件夹。

![image.png](https://image.hyly.net/i/2025/09/28/0554b4b2be771d95b5fd525415109854-0.webp)

## 陌陌消息HBase表结构设计

### 名称空间

#### 说明

1. 在一个项目中，需要使用HBase保存多张表，这些表会按照业务域来划分
2. 为了方便管理，不同的业务域以名称空间（namespace)来划分，这样管理起来会更加容易
3. 类似于Hive中的数据库，不同的数据库下可以放不同类型的表
4. HBase默认的名称空间是「default」，默认情况下，创建表时表都将创建在 default 名称空间下
5. HBase中还有一个命名空间「hbase」，用于存放系统的内建表（namespace、meta）

#### 语法

##### 创建命名空间

create_namespace 'MOMO_CHAT'

##### 查看命名空间列表

list_namespace

##### 查看命名空间

describe_namespace 'MOMO_CHAT'

##### 命名空间创建表

在命令MOMO_CHAT命名空间下创建名为：MSG的表，该表包含一个名为C1的列蔟。
注意：带有命名空间的表，使用冒号将命名空间和表名连接到一起。

create 'MOMO_CHAT:MSG','C1'

##### 删除命名空间

删除命名空间，命名空间中必须没有表，如果命名空间中有表，是无法删除的
drop_namespace 'MOMO_CHAT'

### 列蔟设计

1. HBase列蔟的数量应该越少越好
   1. 两个及以上的列蔟HBase性能并不是很好
   2. 一个列蔟所存储的数据达到flush的阈值时，表中所有列蔟将同时进行flush操作
   3. 这将带来不必要的I/O开销，列蔟越多，对性能影响越大
2. 本次项目中我们只设计一个列蔟：C1

### 版本设计

#### 说明

1. 此处，我们需要保存的历史聊天记录是不会更新的，一旦数据保存到HBase中，就不会再更新
2. 无需考虑版本问题
3. 本次项目中只保留一个版本即可，这样可以节省大量空间
4. HBase默认创建表的版本为1，故此处保持默认即可

#### 查看表

通过以下输出可以看到：

1. 版本是相对于列蔟而言
2. 默认列蔟的版本数为1

```
hbase(main):015:0> describe "MOMO_CHAT:MSG"
Table MOMO_CHAT:MSG is ENABLED                                                                                                                                                                                       
MOMO_CHAT:MSG                                                                                                                                                                                                        
COLUMN FAMILIES DESCRIPTION                                                                                                                                                                                          
{NAME => 'C1', VERSIONS => '1', EVICT_BLOCKS_ON_CLOSE => 'false', NEW_VERSION_BEHAVIOR => 'false', KEEP_DELETED_CELLS => 'FALSE', CACHE_DATA_ON_WRITE => 'false', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', MIN_VERSIONS => '0', REPLI
CATION_SCOPE => '0', BLOOMFILTER => 'ROW', CACHE_INDEX_ON_WRITE => 'false', IN_MEMORY => 'false', CACHE_BLOOMS_ON_WRITE => 'false', PREFETCH_BLOCKS_ON_OPEN => 'false', COMPRESSION => 'NONE', BLOCKCACHE => 'true', BLOCKSIZE => '65536'}   

1 row(s)
```

### 数据压缩

#### 压缩算法

在HBase可以使用多种压缩编码，包括LZO、SNAPPY、GZIP。只在硬盘压缩，内存中或者网络传输中没有压缩。

<figure class='table-figure'><table>
<thead>
<tr><th><strong>压缩算法</strong></th><th><strong>压缩后占比</strong></th><th><strong>压缩</strong></th><th><strong>解压缩</strong></th></tr></thead>
<tbody><tr><td>GZIP</td><td>13.4%</td><td>21 MB/s</td><td>118 MB/s</td></tr><tr><td>LZO</td><td>20.5%</td><td>135 MB/s</td><td>410 MB/s</td></tr><tr><td>Zippy/Snappy</td><td>22.2%</td><td>172 MB/s</td><td>409 MB/s</td></tr></tbody>
</table></figure>

1. GZIP的压缩率最高，但是其实CPU密集型的，对CPU的消耗比其他算法要多，压缩和解压速度也慢；
2. LZO的压缩率居中，比GZIP要低一些，但是压缩和解压速度明显要比GZIP快很多，其中解压速度快的更多；
3. Zippy/Snappy的压缩率最低，而压缩和解压速度要稍微比LZO要快一些
4. **本案例采用GZ算法，这样可以确保的压缩比最大化，更加节省空间**

#### 查看表数据压缩方式

通过以下输出可以看出，HBase创建表默认是没有指定压缩算法的

```
hbase(main):015:0> describe "MOMO_CHAT:MSG"
Table MOMO_CHAT:MSG is ENABLED                                                                                                                                                                                       
MOMO_CHAT:MSG                                                                                                                                                                                                        
COLUMN FAMILIES DESCRIPTION                                                                                                                                                                                          
{NAME => 'C1', VERSIONS => '1', EVICT_BLOCKS_ON_CLOSE => 'false', NEW_VERSION_BEHAVIOR => 'false', KEEP_DELETED_CELLS => 'FALSE', CACHE_DATA_ON_WRITE => 'false', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', MIN_VERSIONS => '0', REPLI
CATION_SCOPE => '0', BLOOMFILTER => 'ROW', CACHE_INDEX_ON_WRITE => 'false', IN_MEMORY => 'false', CACHE_BLOOMS_ON_WRITE => 'false', PREFETCH_BLOCKS_ON_OPEN => 'false', COMPRESSION => 'NONE', BLOCKCACHE => 'true', BLOCKSIZE => '65536'}   

1 row(s)
```

#### 设置数据压缩

本案例中，我们使用GZ压缩算法，语法如下：

1. 创建新的表，并指定数据压缩算法
   create "MOMO_CHAT:MSG", {NAME => "C1", COMPRESSION => "GZ"}
2. 修改已有的表，并指定数据压缩算法
   alter "MOMO_CHAT:MSG", {NAME => "C1", COMPRESSION => "GZ"}

### ROWKEY设计原则

#### HBase官方的设计原则

##### 避免使用递增行键/时序数据

如果ROWKEY设计的都是按照顺序递增（例如：时间戳），这样会有很多的数据写入时，负载都在一台机器上。我们尽量应当将写入大压力均衡到各个RegionServer

##### 避免ROWKEY和列的长度过大

1. 在HBase中，要访问一个Cell（单元格），需要有ROWKEY、列蔟、列名，如果ROWKEY、列名太大，就会占用较大内存空间。所以ROWKEY和列的长度应该尽量短小
2. ROWKEY的最大长度是64KB，建议越短越好

##### 使用long等类型比String类型更省空间

long类型为8个字节，8个字节可以保存非常大的无符号整数，例如：18446744073709551615。如果是字符串，是按照一个字节一个字符方式保存，需要快3倍的字节数存储。

##### ROWKEY唯一性

1. 设计ROWKEY时，必须保证RowKey的唯一性
2. 由于在HBase中数据存储是Key-Value形式，若向HBase中同一张表插入相同RowKey的数据，则原先存在的数据会被新的数据覆盖。

#### 避免数据热点

1. 热点是指大量的客户端（client）直接访问集群的一个或者几个节点（可能是读、也可能是写）
2. 大量地访问量可能会使得某个服务器节点超出承受能力，导致整个RegionServer的性能下降，其他的Region也会受影响

##### 预分区

默认情况，一个HBase的表只有一个Region，被托管在一个RegionServer中

![image.png](https://image.hyly.net/i/2025/09/28/36da88b5426a785969f3911f9a4bca66-0.webp)

1. 每个Region有两个重要的属性：Start Key、End Key，表示这个Region维护的ROWKEY范围
2. 如果只有一个Region，那么Start Key、End Key都是空的，没有边界。所有的数据都会放在这个Region中，但当数据越来越大时，会将Region分裂，取一个Mid Key来分裂成两个Region
3. 预分区个数 = 节点的倍数。默认Region的大小为10G，假设我们预估1年下来的大小为10T，则10000G / 10G = 1000个Region，所以，我们可以预设为1000个Region，这样，1000个Region将均衡地分布在各个节点上

##### ROWKEY避免热点设计

1. 反转策略
   1. 如果设计出的ROWKEY在数据分布上不均匀，但ROWKEY尾部的数据却呈现出了良好的随机性，可以考虑将ROWKEY的翻转，或者直接将尾部的bytes提前到ROWKEY的开头。
   2. 反转策略可以使ROWKEY随机分布，但是牺牲了ROWKEY的有序性
   3. 缺点：利于Get操作，但不利于Scan操作，因为数据在原ROWKEY上的自然顺序已经被打乱
2. 加盐策略
   1. Salting（加盐）的原理是在原ROWKEY的前面添加固定长度的随机数，也就是给ROWKEY分配一个随机前缀使它和之间的ROWKEY的开头不同
   2. 随机数能保障数据在所有Regions间的负载均衡
   3. 缺点：因为添加的是随机数，基于原ROWKEY查询时无法知道随机数是什么，那样在查询的时候就需要去各个可能的Regions中查找，加盐对比读取是无力的
3. 哈希策略
   1. 基于 ROWKEY的完整或部分数据进行 Hash，而后将Hashing后的值完整替换或部分替换原ROWKEY的前缀部分
   2. 这里说的 hash 包含 MD5、sha1、sha256 或 sha512 等算法
   3. 缺点：Hashing 也不利于 Scan，因为打乱了原RowKey的自然顺序

#### 陌陌打招呼数据预分区

##### 预分区

在HBase中，可以通过指定start key、end key来进行分区，还可以直接指定Region的数量，指定分区的策略。
1.指定 start key、end key来分区

```
hbase> create 'ns1:t1', 'f1', SPLITS => ['10', '20', '30', '40']
hbase> create 't1', 'f1', SPLITS => ['10', '20', '30', '40']
hbase> create 't1', 'f1', SPLITS_FILE => 'splits.txt', OWNER => 'johndoe'
```

2.指定分区数量、分区策略

```
hbase> create 't1', 'f1', {NUMREGIONS => 15, SPLITALGO => 'HexStringSplit'}
```

分区策略

1. HexStringSplit: ROWKEY是十六进制的字符串作为前缀的
2. DecimalStringSplit: ROWKEY是10进制数字字符串作为前缀的
3. UniformSplit: ROWKEY前缀完全随机

Region的数量可以按照数据量来预估。本次案例，因为受限于虚拟机，所以我们设计为6个Region。因为ROWKEY我们是使用多个字段拼接，而且前缀不是完全随机的，所以需要使用HexStringSplit。

##### ROWKEY设计

1. 为了确保数据均匀分布在每个Region，需要以MD5Hash作为前缀
2. ROWKEY = MD5Hash_发件人账号_收件人账号_时间戳

![image.png](https://image.hyly.net/i/2025/09/28/33128e65054986e8c2e140ef6e7c210d-0.webp)

##### 业务分区脚本

```
create 'MOMO_CHAT:MSG', {NAME => "C1", COMPRESSION => "GZ"}, { NUMREGIONS => 6, SPLITALGO => 'HexStringSplit'}
```

执行完命令后，我们发现该表已经分为6个分区。这样将来数据就可以均匀地分布到不同的分区中了
**注意：勾选ShowDetailName&Start/EndKey，点击Recorder**

![image.png](https://image.hyly.net/i/2025/09/28/7911a2919e85fda9a79cb06ecf91aa66-0.webp)

HDFS中，也有对应的6个文件夹。
URL：/hbase/data/MOMO_CHAT/MSG

![image.png](https://image.hyly.net/i/2025/09/28/75823c01d64f9cecf1231e1a25b9e7a1-0.webp)

### 项目初始化

#### 导入POM依赖

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
    <!-- HBase客户端 -->
    <dependency>
        <groupId>org.apache.hbase</groupId>
        <artifactId>hbase-client</artifactId>
        <version>2.1.0</version>
    </dependency>
    <!-- Xml操作相关 -->
    <dependency>
        <groupId>com.github.cloudecho</groupId>
        <artifactId>xmlbean</artifactId>
        <version>1.5.5</version>
    </dependency>
    <!-- 操作Office库 -->
    <dependency>
        <groupId>org.apache.poi</groupId>
        <artifactId>poi</artifactId>
        <version>4.0.1</version>
    </dependency>
    <!-- 操作Office库 -->
    <dependency>
        <groupId>org.apache.poi</groupId>
        <artifactId>poi-ooxml</artifactId>
        <version>4.0.1</version>
    </dependency>
    <!-- 操作Office库 -->
    <dependency>
        <groupId>org.apache.poi</groupId>
        <artifactId>poi-ooxml-schemas</artifactId>
        <version>4.0.1</version>
    </dependency>
    <!-- 操作JSON -->
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>fastjson</artifactId>
        <version>1.2.62</version>
    </dependency>
    <!-- phoenix core -->
    <dependency>
        <groupId>org.apache.phoenix</groupId>
        <artifactId>phoenix-core</artifactId>
        <version>5.0.0-HBase-2.0</version>
    </dependency>
    <!-- phoenix 客户端 -->
    <dependency>
        <groupId>org.apache.phoenix</groupId>
        <artifactId>phoenix-queryserver-client</artifactId>
        <version>5.0.0-HBase-2.0</version>
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

#### 拷贝配置文件

将配套资料中的以下几个文件拷贝到resources目录。

1. core-site.xml
2. hbase-site.xml
3. log4j.properties

#### 创建包结构

<figure class='table-figure'><table>
<thead>
<tr><th>cn.itcast.momo_chat.service</th><th>用于存放数据服务接口相关代码，例如：查询的API代码</th></tr></thead>
<tbody><tr><td>cn.itcast.momo_chat.service.impl</td><td>用于存放数据服务接口实现类相关代码，例如：查询的API代码</td></tr><tr><td>cn.itcast.momo_chat.tool</td><td>工具类</td></tr><tr><td>cn.itcast.momo_chat.entity</td><td>存放实体类</td></tr></tbody>
</table></figure>

#### 导入ExcelReader工具类

在资料包中有一个ExcelReader.java文件，ExcelReader工具类可以读取Excel中的数据称为HashMap这样，方便我们快速生成数据。

ExcelReader工具类主要有两个方法：
1.readXlsx——用于将指定路径的Excel文件中的工作簿读取为Map结构
2.randomColumn——随机生成某一列中的数据。

**将****E****xcelReader添加到** **cn.itcast.momo_chat.tool包中** **。**

#### 创建实体类

在cn.itcast.momo_chat.entity包中创建一个名为Msg的实体类，使用Java代码描述陌陌消息。

<figure class='table-figure'><table>
<thead>
<tr><th><strong>字段名</strong></th><th><strong>说明</strong></th></tr></thead>
<tbody><tr><td>msg_time</td><td>消息时间</td></tr><tr><td>sender_nickyname</td><td>发件人昵称</td></tr><tr><td>sender_account</td><td>发件人账号</td></tr><tr><td>sender_sex</td><td>发件人性别</td></tr><tr><td>sender_ip</td><td>发件人IP</td></tr><tr><td>sender_os</td><td>发件人系统</td></tr><tr><td>sender_phone_type</td><td>发件人手机型号</td></tr><tr><td>sender_network</td><td>发件人网络制式</td></tr><tr><td>sender_gps</td><td>发件人GPS</td></tr><tr><td>receiver_nickyname</td><td>收件人昵称</td></tr><tr><td>receiver_ip</td><td>收件人IP</td></tr><tr><td>receiver_account</td><td>收件人账号</td></tr><tr><td>receiver_os</td><td>收件人系统</td></tr><tr><td>receiver_phone_type</td><td>收件人手机型号</td></tr><tr><td>receiver_network</td><td>收件人网络制式</td></tr><tr><td>receiver_gps</td><td>收件人GPS</td></tr><tr><td>receiver_sex</td><td>收件人性别</td></tr><tr><td>msg_type</td><td>消息类型</td></tr><tr><td>distance</td><td>双方距离</td></tr><tr><td>message</td><td>消息</td></tr></tbody>
</table></figure>

操作步骤：
1.使用列编辑，快速复制讲义中上述的表格字段给实体类添加成员变量
2.使用IDEA快捷键 Alt + Insert 键快速生成 getter/setter 方法，并重写toString方法
参考代码：

```
public class Msg {
    private String msg_time;
    private String sender_nickyname;
    private String sender_account;
    private String sender_sex;
    private String sender_ip;
    private String sender_os;
    private String sender_phone_type;
    private String sender_network;
    private String sender_gps;
    private String receiver_nickyname;
    private String receiver_ip;
    private String receiver_account;
    private String receiver_os;
    private String receiver_phone_type;
    private String receiver_network;
    private String receiver_gps;
    private String receiver_sex;
    private String msg_type;
    private String distance;
    private String message;

    public String getMsg_time() {
        return msg_time;
    }

    public void setMsg_time(String msg_time) {
        this.msg_time = msg_time;
    }

    public String getSender_nickyname() {
        return sender_nickyname;
    }

    public void setSender_nickyname(String sender_nickyname) {
        this.sender_nickyname = sender_nickyname;
    }

    public String getSender_account() {
        return sender_account;
    }

    public void setSender_account(String sender_account) {
        this.sender_account = sender_account;
    }

    public String getSender_sex() {
        return sender_sex;
    }

    public void setSender_sex(String sender_sex) {
        this.sender_sex = sender_sex;
    }

    public String getSender_ip() {
        return sender_ip;
    }

    public void setSender_ip(String sender_ip) {
        this.sender_ip = sender_ip;
    }

    public String getSender_os() {
        return sender_os;
    }

    public void setSender_os(String sender_os) {
        this.sender_os = sender_os;
    }

    public String getSender_phone_type() {
        return sender_phone_type;
    }

    public void setSender_phone_type(String sender_phone_type) {
        this.sender_phone_type = sender_phone_type;
    }

    public String getSender_network() {
        return sender_network;
    }

    public void setSender_network(String sender_network) {
        this.sender_network = sender_network;
    }

    public String getSender_gps() {
        return sender_gps;
    }

    public void setSender_gps(String sender_gps) {
        this.sender_gps = sender_gps;
    }

    public String getReceiver_nickyname() {
        return receiver_nickyname;
    }

    public void setReceiver_nickyname(String receiver_nickyname) {
        this.receiver_nickyname = receiver_nickyname;
    }

    public String getReceiver_ip() {
        return receiver_ip;
    }

    public void setReceiver_ip(String receiver_ip) {
        this.receiver_ip = receiver_ip;
    }

    public String getReceiver_account() {
        return receiver_account;
    }

    public void setReceiver_account(String receiver_account) {
        this.receiver_account = receiver_account;
    }

    public String getReceiver_os() {
        return receiver_os;
    }

    public void setReceiver_os(String receiver_os) {
        this.receiver_os = receiver_os;
    }

    public String getReceiver_phone_type() {
        return receiver_phone_type;
    }

    public void setReceiver_phone_type(String receiver_phone_type) {
        this.receiver_phone_type = receiver_phone_type;
    }

    public String getReceiver_network() {
        return receiver_network;
    }

    public void setReceiver_network(String receiver_network) {
        this.receiver_network = receiver_network;
    }

    public String getReceiver_gps() {
        return receiver_gps;
    }

    public void setReceiver_gps(String receiver_gps) {
        this.receiver_gps = receiver_gps;
    }

    public String getReceiver_sex() {
        return receiver_sex;
    }

    public void setReceiver_sex(String receiver_sex) {
        this.receiver_sex = receiver_sex;
    }

    public String getMsg_type() {
        return msg_type;
    }

    public void setMsg_type(String msg_type) {
        this.msg_type = msg_type;
    }

    public String getDistance() {
        return distance;
    }

    public void setDistance(String distance) {
        this.distance = distance;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @Override
    public String toString() {
        return JSON.toJSONString(this);
    }
}
```

### 编写数据生成器

#### 测试工具类ExcelReader读取测试数据集

1.在cn.itcast.momo_chat.tool包中创建一个名为MoMoMsgGen类
2.在main方法中，读取资料中的测试数据集.xlsx

```
Map<String, List<String>> resultMap = ExcelReader.readXlsx("D:\\课程研发\\39.HBaseV8.0\\4.资料\\数据集\\测试数据集.xlsx", "陌陌数据");
```

#### 随机生成一条数据

编写getOneMsg方法，调用ExcelReader工具类，随机生成一条陌陌消息数据
实现步骤：
1.构建Msg实体类对象
2.调用ExcelReader中的randomColumn随机生成一个列的数据
3.注意时间使用系统当前时间

```
private static Msg getOneMsg(Map<String, List<String>> resultMap) {
    Msg msg = new Msg();
    long timestamp = new Date().getTime();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    msg.setMsg_time(sdf.format(timestamp));
    msg.setSender_nickyname(ExcelReader.randomColumn(resultMap, "sender_nickyname"));
    msg.setSender_account(ExcelReader.randomColumn(resultMap, "sender_account"));
    msg.setSender_sex(ExcelReader.randomColumn(resultMap, "sender_sex"));
    msg.setSender_ip(ExcelReader.randomColumn(resultMap, "sender_ip"));
    msg.setSender_os(ExcelReader.randomColumn(resultMap, "sender_os"));
    msg.setSender_phone_type(ExcelReader.randomColumn(resultMap, "sender_phone_type"));
    msg.setSender_network(ExcelReader.randomColumn(resultMap, "sender_network"));
    msg.setSender_gps(ExcelReader.randomColumn(resultMap, "sender_gps"));
    msg.setReceiver_nickyname(ExcelReader.randomColumn(resultMap, "receiver_nickyname"));
    msg.setReceiver_ip(ExcelReader.randomColumn(resultMap, "receiver_ip"));
    msg.setReceiver_account(ExcelReader.randomColumn(resultMap, "receiver_account"));
    msg.setReceiver_os(ExcelReader.randomColumn(resultMap, "receiver_os"));
    msg.setReceiver_phone_type(ExcelReader.randomColumn(resultMap, "receiver_phone_type"));
    msg.setReceiver_network(ExcelReader.randomColumn(resultMap, "receiver_network"));
    msg.setReceiver_gps(ExcelReader.randomColumn(resultMap, "receiver_gps"));
    msg.setReceiver_sex(ExcelReader.randomColumn(resultMap, "receiver_sex"));
    msg.setMsg_type(ExcelReader.randomColumn(resultMap, "msg_type"));
    msg.setDistance(ExcelReader.randomColumn(resultMap, "distance"));
    msg.setMessage(ExcelReader.randomColumn(resultMap, "message"));

    return msg;
}
```

#### 构建ROWKEY

前面我们分析得到：
ROWKEY = MD5Hash_发件人账号_收件人账号_消息时间戳
1.其中MD5Hash的计算方式为：发送人账号 + “_” + 收件人账号 + “_” + 消息时间戳
2.使用MD5Hash.getMD5AsHex方法生成MD5值
3.取MD5值的前8位，避免过长
最后把发件人账号、收件人账号、消息时间戳和MD5拼接起来

实现步骤：
1.创建getRowkey方法，接收Msg实体对象，并根据该实体对象生成byte[]的rowkey
2.使用StringBuilder将发件人账号、收件人账号、消息时间戳使用下划线（_）拼接起来
3.使用Bytes.toBytes将拼接出来的字符串转换为byte[]数组
4.使用MD5Hash.getMD5AsHex生成MD5值，并取其前8位
5.再将MD5值和之前拼接好的发件人账号、收件人账号、消息时间戳，再使用下划线拼接，转换为Bytes数组

参考代码：

```
private static byte[] getRowkey(Msg msg) throws ParseException {
    // 3. 构建ROWKEY
    // 发件人ID1反转
    StringBuilder stringBuilder = new StringBuilder(msg.getSender_account());
    stringBuilder.append("_");
    stringBuilder.append(msg.getReceiver_account());
    stringBuilder.append("_");
    // 转换为时间戳
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    stringBuilder.append(sdf.parse(msg.getMsg_time()).getTime());

    byte[] orginkey = Bytes.toBytes(stringBuilder.toString());
    // 为了避免ROWKEY过长，取前八位
    String md5AsHex = MD5Hash.getMD5AsHex(orginkey).substring(0, 8);

    return Bytes.toBytes(md5AsHex + "_" + stringBuilder.toString());
}
```

#### 数据写入HBase

实现步骤：
1.获取Hbase连接
2.获取HBase表MOMO_CHAT:MSG
3.初始化操作Hbase所需的变量（列蔟、列名）
4.构建put请求
5.挨个添加陌陌消息的所有列
6.发起put请求

##### 构建Hbase连接

1.获取Hbase连接

```
Configuration configuration = HBaseConfiguration.create();
Connection connection = ConnectionFactory.createConnection(configuration);
```

2.获取HBase表

```
String TABLE_NAME = "MOMO_CHAT:MSG";
Table momoChatlTable = connection.getTable(TableName.valueOf(TABLE_NAME));
```

3.初始化操作Hbase所需的变量（列蔟、列名）

```
String cf_name = "C1";
String col_msg_time = "msg_time";
String col_sender_nickyname = "sender_nickyname";
String col_sender_account = "sender_account";
String col_sender_sex = "sender_sex";
String col_sender_ip = "sender_ip";
String col_sender_os = "sender_os";
String col_sender_phone_type = "sender_phone_type";
String col_sender_network = "sender_network";
String col_sender_gps = "sender_gps";
String col_receiver_nickyname = "receiver_nickyname";
String col_receiver_ip = "receiver_ip";
String col_receiver_account = "receiver_account";
String col_receiver_os = "receiver_os";
String col_receiver_phone_type = "receiver_phone_type";
String col_receiver_network = "receiver_network";
String col_receiver_gps = "receiver_gps";
String col_receiver_sex = "receiver_sex";
String col_msg_type = "msg_type";
String col_distance = "distance";
String col_message = "message";
```

##### 发起put请求添加数据

1.构建put请求
2.挨个添加陌陌消息的所有列
3.发起put请求

参考代码：

```
Msg msg = getOneMsg(resultMap);
Put put = new Put(getRowkey(msg));

put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_msg_time), Bytes.toBytes(msg.getMsg_time()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_nickyname), Bytes.toBytes(msg.getSender_nickyname()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_account), Bytes.toBytes(msg.getSender_account()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_sex), Bytes.toBytes(msg.getSender_sex()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_ip), Bytes.toBytes(msg.getSender_ip()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_os), Bytes.toBytes(msg.getSender_os()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_phone_type), Bytes.toBytes(msg.getSender_phone_type()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_network), Bytes.toBytes(msg.getSender_network()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_gps), Bytes.toBytes(msg.getSender_gps()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_nickyname), Bytes.toBytes(msg.getReceiver_nickyname()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_ip), Bytes.toBytes(msg.getReceiver_ip()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_account), Bytes.toBytes(msg.getReceiver_account()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_os), Bytes.toBytes(msg.getReceiver_os()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_phone_type), Bytes.toBytes(msg.getReceiver_phone_type()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_network), Bytes.toBytes(msg.getReceiver_network()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_gps), Bytes.toBytes(msg.getReceiver_gps()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_sex), Bytes.toBytes(msg.getReceiver_sex()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_msg_type), Bytes.toBytes(msg.getMsg_type()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_distance), Bytes.toBytes(msg.getDistance()));
put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_message), Bytes.toBytes(msg.getMessage()));

// 5. 执行put请求
momoChatlTable.put(put);
```

#### 生成10W条数据

1.使用一个while循环，生成10W条数据
2.注意遍历的时候打印下数据生成的进度

完整代码：

```
/**
 * 陌陌数据生成器
 */
public class Gen {

    public static void main(String[] args) throws Exception {
        Map<String, List<String>> resultMap = ExcelReader.readXlsx("D:\\课程研发\\39.HBaseV8.0\\4.资料\\数据集\\测试数据集.xlsx", "陌陌数据");

        // 1. 获取HBase连接
        Configuration configuration = HBaseConfiguration.create();

        Connection connection = ConnectionFactory.createConnection(configuration);

        // 2. 获取HTable
        String TABLE_NAME = "MOMO_CHAT:MSG";
        Table momoChatlTable = connection.getTable(TableName.valueOf(TABLE_NAME));

        String cf_name = "C1";
        String col_msg_time = "msg_time";
        String col_sender_nickyname = "sender_nickyname";
        String col_sender_account = "sender_account";
        String col_sender_sex = "sender_sex";
        String col_sender_ip = "sender_ip";
        String col_sender_os = "sender_os";
        String col_sender_phone_type = "sender_phone_type";
        String col_sender_network = "sender_network";
        String col_sender_gps = "sender_gps";
        String col_receiver_nickyname = "receiver_nickyname";
        String col_receiver_ip = "receiver_ip";
        String col_receiver_account = "receiver_account";
        String col_receiver_os = "receiver_os";
        String col_receiver_phone_type = "receiver_phone_type";
        String col_receiver_network = "receiver_network";
        String col_receiver_gps = "receiver_gps";
        String col_receiver_sex = "receiver_sex";
        String col_msg_type = "msg_type";
        String col_distance = "distance";
        String col_message = "message";

        int i = 0;
        int max = 100000;
        while(i < max) {
            Msg msg = getOneMsg(resultMap);
            Put put = new Put(getRowkey(msg));

            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_msg_time), Bytes.toBytes(msg.getMsg_time()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_nickyname), Bytes.toBytes(msg.getSender_nickyname()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_account), Bytes.toBytes(msg.getSender_account()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_sex), Bytes.toBytes(msg.getSender_sex()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_ip), Bytes.toBytes(msg.getSender_ip()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_os), Bytes.toBytes(msg.getSender_os()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_phone_type), Bytes.toBytes(msg.getSender_phone_type()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_network), Bytes.toBytes(msg.getSender_network()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_sender_gps), Bytes.toBytes(msg.getSender_gps()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_nickyname), Bytes.toBytes(msg.getReceiver_nickyname()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_ip), Bytes.toBytes(msg.getReceiver_ip()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_account), Bytes.toBytes(msg.getReceiver_account()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_os), Bytes.toBytes(msg.getReceiver_os()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_phone_type), Bytes.toBytes(msg.getReceiver_phone_type()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_network), Bytes.toBytes(msg.getReceiver_network()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_gps), Bytes.toBytes(msg.getReceiver_gps()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_receiver_sex), Bytes.toBytes(msg.getReceiver_sex()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_msg_type), Bytes.toBytes(msg.getMsg_type()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_distance), Bytes.toBytes(msg.getDistance()));
            put.addColumn(Bytes.toBytes(cf_name), Bytes.toBytes(col_message), Bytes.toBytes(msg.getMessage()));

            // 5. 执行put请求
            momoChatlTable.put(put);
            System.out.println(i + " / " + max);
            ++i;
        }

        // 6. 关闭连接
        momoChatlTable.close();
        momoChatlTable.close();

    }

    private static byte[] getRowkey(Msg msg) throws ParseException {
        // 3. 构建ROWKEY
        // 发件人ID1反转
        StringBuilder stringBuilder = new StringBuilder(msg.getSender_account());
        stringBuilder.append("_");
        stringBuilder.append(msg.getReceiver_account());
        stringBuilder.append("_");
        // 转换为时间戳
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        stringBuilder.append(sdf.parse(msg.getMsg_time()).getTime());

        byte[] orginkey = Bytes.toBytes(stringBuilder.toString());
        // 为了避免ROWKEY过长，取前八位
        String md5AsHex = MD5Hash.getMD5AsHex(orginkey).substring(0, 8);

        return Bytes.toBytes(md5AsHex + "_" + stringBuilder.toString());
    }

    private static Msg getOneMsg(Map<String, List<String>> resultMap) {
        Msg msg = new Msg();
        long timestamp = new Date().getTime();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        msg.setMsg_time(sdf.format(timestamp));
        msg.setSender_nickyname(ExcelReader.randomColumn(resultMap, "sender_nickyname"));
        msg.setSender_account(ExcelReader.randomColumn(resultMap, "sender_account"));
        msg.setSender_sex(ExcelReader.randomColumn(resultMap, "sender_sex"));
        msg.setSender_ip(ExcelReader.randomColumn(resultMap, "sender_ip"));
        msg.setSender_os(ExcelReader.randomColumn(resultMap, "sender_os"));
        msg.setSender_phone_type(ExcelReader.randomColumn(resultMap, "sender_phone_type"));
        msg.setSender_network(ExcelReader.randomColumn(resultMap, "sender_network"));
        msg.setSender_gps(ExcelReader.randomColumn(resultMap, "sender_gps"));
        msg.setReceiver_nickyname(ExcelReader.randomColumn(resultMap, "receiver_nickyname"));
        msg.setReceiver_ip(ExcelReader.randomColumn(resultMap, "receiver_ip"));
        msg.setReceiver_account(ExcelReader.randomColumn(resultMap, "receiver_account"));
        msg.setReceiver_os(ExcelReader.randomColumn(resultMap, "receiver_os"));
        msg.setReceiver_phone_type(ExcelReader.randomColumn(resultMap, "receiver_phone_type"));
        msg.setReceiver_network(ExcelReader.randomColumn(resultMap, "receiver_network"));
        msg.setReceiver_gps(ExcelReader.randomColumn(resultMap, "receiver_gps"));
        msg.setReceiver_sex(ExcelReader.randomColumn(resultMap, "receiver_sex"));
        msg.setMsg_type(ExcelReader.randomColumn(resultMap, "msg_type"));
        msg.setDistance(ExcelReader.randomColumn(resultMap, "distance"));
        msg.setMessage(ExcelReader.randomColumn(resultMap, "message"));

        return msg;
    }
}
```

### 编写数据服务查询数据

#### 需求

数据存储到HBase之后，用户可能会在某一时间按照日期来查询聊天记录。例如：用户点击某一个日期，那就需要将当天用户和另外一个用户的打招呼聊天记录查询出来。也就是需要按照以下几个字段来进行查询。

1. 日期
2. 发件人
3. 收件人

#### 创建接口与实现类

1.在cn.itcast.momo_chat.service 包下创建ChatMessageService接口，该接口有一个方法为：

```
List<Msg> getMessage(String date, String sender, String receiver) throws Exception
void close();
```

getMessage表示从Hbase中的消息记录根据日期、发送者账号、接受者账号查询数据，并返回一个List集合
close表示关闭打开的相关资源
2.在cn.itcast.momo_chat.service.impl包下创建HBaseNativeChatMessageService实现类，并实现getMessage方法

参考代码：
ChatMessageService接口

```
/**
 * 陌陌消息服务
 */
public interface ChatMessageService {
    List<Msg> getMessage(String date, String sender, String receiver) throws Exception;
    void close();
}
```

HbaseNativeChatMessageService实现类

```
/**
 * 使用HBase原生API实现数据服务
 */
public class HbaseNativeChatMessageService implements ChatMessageService {
    @Override
    public List<Msg> getMessage(String date, String sender, String receiver) throws Exception {
        return null;
    }
@Override
public void close() {
  
}
}
```

#### 构建实现类所需对象并初始化

要使用该对象操作Hbase，我们需要提前准备以下内容：
1.Hbase连接
2.日期格式化器
添加几个字段，并在构造器中初始化它们。

构造器实现：
1.构建HBase Connection
2.构建日期格式化器

参考代码：

```
// Hbase连接
private Connection connection;
// 日期格式化器
private SimpleDateFormat simpleDateFormat;
```

#### 实现close方法

在close方法中关闭连接池、表、连接。

```
@Override
public void close() {
    try {
        connection.close();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

#### 实现getMessage方法

要根据日期、发件人、收件人查询消息，我们需要使用scan+filter来进行扫描。我们需要使用多个Filter组合起来进行查询。
实现步骤：
1.构建scan对象
2.构建用于查询时间的范围，例如：2020-10-05 00:00:00 – 2020-10-05 23:59:59
3.构建查询日期的两个Filter，大于等于、小于等于，此处过滤单个列使用SingleColumnValueFilter即可。
4.构建发件人Filter
5.构建收件人Filter
6.使用FilterList组合所有Filter
7.设置scan对象filter
8.获取HTable对象，并调用getScanner执行
9.获取迭代器，迭代每一行，同时迭代每一个单元格

参考实现：
1.构建scan对象

```
Scan scan = new Scan();
```

2.构建用于查询时间的范围，例如：2020-10-05 00:00:00 – 2020-10-05 23:59:59

```
// 构建查询时间范围
String startDate = date + " 00:00:00";
String endDate = date + " 23:59:59";
```

3.构建查询日期的两个Filter，大于等于、小于等于，此处过滤单个列使用SingleColumnValueFilter即可。

```
// 构建日期查询
SingleColumnValueFilter startDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
        , Bytes.toBytes("msg_time")
        , CompareOperator.GREATER_OR_EQUAL
        , new BinaryComparator(Bytes.toBytes(startDate + "")));

SingleColumnValueFilter endDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
        , Bytes.toBytes("msg_time")
        , CompareOperator.LESS_OR_EQUAL
        , new BinaryComparator(Bytes.toBytes(endDate + "")));
```

4.构建发件人Filter

```
SingleColumnValueFilter senderFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
        , Bytes.toBytes("sender_account")
        , CompareOperator.EQUAL
        , new BinaryComparator(Bytes.toBytes(sender)));
```

5.构建收件人Filter

```
SingleColumnValueFilter receiverFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
                , Bytes.toBytes("receiver_account")
                , CompareOperator.EQUAL
                , new BinaryComparator(Bytes.toBytes(receiver)));
```

6.使用FilterList组合所有Filter

```
Filter filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL
        , startDateFilter
        , endDateFilter
        , senderFilter
        , receiverFilter);
```

7.设置scan对象filter
8.获取HTable对象，并调用getScanner执行

```
scan.setFilter(filterList);
ResultScanner scanner = tableMsg.getScanner(scan);
```

9.获取迭代器，迭代每一行，同时迭代每一个单元格

```
Iterator<Result> iter = scanner.iterator();
List<Msg> msgList = new ArrayList<>();

while(iter.hasNext()) {
    Result result = iter.next();
    Msg msg = new Msg();
    // 遍历所有列
    while(result.advance()) {
        Cell cell = result.current();
        String columnName = Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength());

        if(columnName.equalsIgnoreCase("msg_time")){
            msg.setMsg_time(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_nickyname")){
            msg.setSender_nickyname(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_account")){
            msg.setSender_account(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_sex")){
            msg.setSender_sex(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_ip")){
            msg.setSender_ip(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_os")){
            msg.setSender_os(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_phone_type")){
            msg.setSender_phone_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_network")){
            msg.setSender_network(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("sender_gps")){
            msg.setSender_gps(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_nickyname")){
            msg.setReceiver_nickyname(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_ip")){
            msg.setReceiver_ip(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_account")){
            msg.setReceiver_account(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_os")){
            msg.setReceiver_os(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_phone_type")){
            msg.setReceiver_phone_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_network")){
            msg.setReceiver_network(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_gps")){
            msg.setReceiver_gps(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("receiver_sex")){
            msg.setReceiver_sex(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("msg_type")){
            msg.setMsg_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("distance")){
            msg.setDistance(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }
        if(columnName.equalsIgnoreCase("message")){
            msg.setMessage(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
        }

        msgList.add(msg);
    }
}
```

#### 测试

调用查询方法，检查是否能够根据指定的条件查询出数据

参考代码：

```
public static void main(String[] args) throws Exception{
    HBaseNativeChatMessageService hbaseNativeChatMessageService = new HBaseNativeChatMessageService ();
    List<Msg> message = hbaseNativeChatMessageService.getMessage("2020-08-24", "13504113666", "18182767005");

    for (Msg msg : message) {
        System.out.println(msg);
    }

    hbaseNativeChatMessageService.close();
}
```

#### 完整代码

```
/**
 * 使用HBase原生API实现数据服务
 */
public class HBaseNativeChatMessageService implements ChatMessageService {
    private Connection connection;
    private SimpleDateFormat sdf;
    private ExecutorService executorServiceMsg;
    private Table tableMsg;

    public HBaseNativeChatMessageService() {
        try {
            Configuration cfg = HBaseConfiguration.create();
            connection = ConnectionFactory.createConnection(cfg);
            sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            executorServiceMsg = Executors.newFixedThreadPool(5);
            tableMsg = connection.getTable(TableName.valueOf("MOMO_CHAT:MSG"), executorServiceMsg);
        } catch (IOException e) {
            System.out.println("**获取HBase连接失败**");
            throw new RuntimeException(e);
        }
    }

    /**
     * 根据日期、发件人、收件人查询消息
     * @param date
     * @param sender
     * @param receiver
     * @return
     */
    @Override
    public List<Msg> getMessage(String date, String sender, String receiver) throws Exception {
        if(connection == null) throw new RuntimeException("未初始化HBase连接！");

        // 构建scan对象
        Scan scan = new Scan();
        // 构建Start ROWKEY
        String startDate = date + " 00:00:00";
        String endDate = date + " 23:59:59";

        // 构建Filter
        // 构建日期查询
        SingleColumnValueFilter startDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
                , Bytes.toBytes("msg_time")
                , CompareOperator.GREATER_OR_EQUAL
                , new BinaryComparator(Bytes.toBytes(startDate + "")));

        SingleColumnValueFilter endDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
                , Bytes.toBytes("msg_time")
                , CompareOperator.LESS_OR_EQUAL
                , new BinaryComparator(Bytes.toBytes(endDate + "")));

        SingleColumnValueFilter senderFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
                , Bytes.toBytes("sender_account")
                , CompareOperator.EQUAL
                , new BinaryComparator(Bytes.toBytes(sender)));

        SingleColumnValueFilter receiverFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
                , Bytes.toBytes("receiver_account")
                , CompareOperator.EQUAL
                , new BinaryComparator(Bytes.toBytes(receiver)));


        Filter filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL
                , startDateFilter
                , endDateFilter
                , senderFilter
                , receiverFilter);
        scan.setFilter(filterList);
        ResultScanner scanner = tableMsg.getScanner(scan);
        Iterator<Result> iter = scanner.iterator();
        List<Msg> msgList = new ArrayList<>();

        while(iter.hasNext()) {
            Result result = iter.next();
            Msg msg = new Msg();
            // 遍历所有列
            while(result.advance()) {
                Cell cell = result.current();
                String columnName = Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength());

                if(columnName.equalsIgnoreCase("msg_time")){
                    msg.setMsg_time(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_nickyname")){
                    msg.setSender_nickyname(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_account")){
                    msg.setSender_account(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_sex")){
                    msg.setSender_sex(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_ip")){
                    msg.setSender_ip(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_os")){
                    msg.setSender_os(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_phone_type")){
                    msg.setSender_phone_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_network")){
                    msg.setSender_network(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("sender_gps")){
                    msg.setSender_gps(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_nickyname")){
                    msg.setReceiver_nickyname(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_ip")){
                    msg.setReceiver_ip(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_account")){
                    msg.setReceiver_account(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_os")){
                    msg.setReceiver_os(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_phone_type")){
                    msg.setReceiver_phone_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_network")){
                    msg.setReceiver_network(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_gps")){
                    msg.setReceiver_gps(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("receiver_sex")){
                    msg.setReceiver_sex(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("msg_type")){
                    msg.setMsg_type(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("distance")){
                    msg.setDistance(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }
                if(columnName.equalsIgnoreCase("message")){
                    msg.setMessage(Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
                }

                msgList.add(msg);
            }
        }

        return msgList;
    }

    public void close() {
        try {
            connection.close();
            tableMsg.close();
            executorServiceMsg.shutdown();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws Exception{
        HBaseNativeChatMessageService hbaseNativeChatMessageService = new HBaseNativeChatMessageService();
        List<Msg> message = hbaseNativeChatMessageService.getMessage("2020-08-24", "13504113666", "18182767005");

        for (Msg msg : message) {
            System.out.println(msg);
        }

        hbaseNativeChatMessageService.close();
    }
}
```

## 性能问题

1. Hbase默认只支持对行键的索引，那么如果要针对其它的列来进行查询，就只能全表扫描
2. 上述的查询是使用scan + filter组合来进行查询的，但查询地效率不高，因为要进行顺序全表扫描而没有其他索引。如果数据量较大，只能在客户端（client）来进行处理，如果要传输到Client大量的数据，然后交由客户端处理
   1. 网络传输压力很大
   2. 客户端的压力很大
3. 如果表存储的数据量很大时，效率会非常低下，此时需要使用二级索引
4. 也就是除了ROWKEY的索引外，还需要人为添加其他的方便查询的索引

如果每次需要我们开发二级索引来查询数据，这样使用起来很麻烦。再者，查询数据都是HBase Java API，使用起来不是很方便。为了让其他开发人员更容易使用该接口。如果有一种SQL引擎，通过SQL语句来查询数据会更加方便。

此时，使用Apache Phoenix就可以解决我们上述问题。

![image.png](https://image.hyly.net/i/2025/09/28/53749b7fedb03d47a465eb829f5fd770-0.webp)

## Apache Phoenix

### Phoenix介绍

Phoenix官方网址：http://phoenix.apache.org/

#### 简介

![image.png](https://image.hyly.net/i/2025/09/28/5a1d0bedcbe6f32c499eb0b47db2e71d-0.webp)

Phoenix官网：「We put the SQL back in NoSQL」

Apache Phoenix让Hadoop中支持低延迟OLTP和业务操作分析。

1. 提供标准的SQL以及完备的ACID事务支持
2. 通过利用HBase作为存储，让NoSQL数据库具备通过有模式的方式读取数据，我们可以使用SQL语句来操作HBase，例如：创建表、以及插入数据、修改数据、删除数据等。
3. Phoenix通过协处理器在服务器端执行操作，最小化客户机/服务器数据传输

Apache Phoenix可以很好地与其他的Hadoop组件整合在一起，例如：Spark、Hive、Flume以及MapReduce。

#### 使用Phoenix是否会影响HBase性能

![image.png](https://image.hyly.net/i/2025/09/28/36177119f801fac1fdf534f34b4ab54a-0.webp)

1. Phoenix不会影响HBase性能，反而会提升HBase性能
2. Phoenix将SQL查询编译为本机HBase扫描
3. 确定scan的key的最佳startKey和endKey
4. 编排scan的并行执行
5. 将WHERE子句中的谓词推送到服务器端
6. 通过协处理器执行聚合查询
7. 用于提高非行键列查询性能的二级索引
8. 统计数据收集，以改进并行化，并指导优化之间的选择
9. 跳过扫描筛选器以优化IN、LIKE和OR查询
10. 行键加盐保证分配均匀，负载均衡

#### 哪些公司在使用Phoenix

![image.png](https://image.hyly.net/i/2025/09/28/93759016f3a76be6b9472e1f17a39edd-0.webp)

#### 官方性能测试

##### Phoenix对标Hive（基于HDFS和HBase）

![image.png](https://image.hyly.net/i/2025/09/28/1760b1e3e647eb8c3568028d50d4e4fa-0.webp)

##### Phoenix对标Impala

![image.png](https://image.hyly.net/i/2025/09/28/1738ac04bc0c40ee9926c21a037231df-0.webp)

##### 关于上述官网两张性能测试的说明

上述两张图是从Phoenix官网拿下来的，这容易引起一个歧义。就是：有了HBase + Phoenix，那是不是意味着，我们将来做数仓（OLAP）就可以不用Hadoop + Hive了？

千万不要这么以为，HBase + Phoenix是否适合做OLAP取决于HBase的定位。Phoenix只是在HBase之上构建了SQL查询引擎（注意：我称为SQL查询引擎，并不是像MapReduce、Spark这种大规模数据计算引擎）。HBase的定位是在高性能随机读写，Phoenix可以使用SQL快插查询HBase中的数据，但数据操作底层是必须符合HBase的存储结构，例如：必须要有ROWKEY、必须要有列蔟。因为有这样的一些限制，绝大多数公司不会选择HBase + Phoenix来作为数据仓库的开发。而是用来快速进行海量数据的随机读写。这方面，HBase + Phoenix有很大的优势。

### 安装Phoenix

#### 下载

大家可以从官网上下载与HBase版本对应的Phoenix版本。对应到HBase 2.1，应该使用版本「5.0.0-HBase-2.0」。
http://phoenix.apache.org/download.html
也可以使用资料包中的安装包。

#### 安装

1.上传安装包到Linux系统，并解压

```
cd /export/software
tar -xvzf apache-phoenix-5.0.0-HBase-2.0-bin.tar.gz -C ../server/
```

2.将phoenix的所有jar包添加到所有HBase RegionServer和Master的复制到HBase的lib目录

```
#  拷贝jar包到hbase lib目录 
cp /export/server/apache-phoenix-5.0.0-HBase-2.0-bin/phoenix-*.jar /export/server/hbase-2.1.0/lib/
#  进入到hbase lib  目录
cd /export/server/hbase-2.1.0/lib/
# 分发jar包到每个HBase 节点
scp phoenix-*.jar node2.itcast.cn:$PWD
scp phoenix-*.jar node3.itcast.cn:$PWD
```

3.修改配置文件

```
cd /export/server/hbase-2.1.0/conf/
vim hbase-site.xml
------
# 1. 将以下配置添加到 hbase-site.xml 后边
<!-- 支持HBase命名空间映射 -->
<property>
    <name>phoenix.schema.isNamespaceMappingEnabled</name>
    <value>true</value>
</property>
<!-- 支持索引预写日志编码 -->
<property>
  <name>hbase.regionserver.wal.codec</name>
  <value>org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec</value>
</property>
# 2. 将hbase-site.xml分发到每个节点
scp hbase-site.xml node2.itcast.cn:$PWD
scp hbase-site.xml node3.itcast.cn:$PWD
```

4.将配置后的hbase-site.xml拷贝到phoenix的bin目录

```
cp /export/server/hbase-2.1.0/conf/hbase-site.xml /export/server/apache-phoenix-5.0.0-HBase-2.0-bin/bin/
```

5.重新启动HBase

```
stop-hbase.sh
start-hbase.sh
```

6.启动Phoenix客户端，连接Phoenix Server
注意：第一次启动Phoenix连接HBase会稍微慢一点。

```
cd /export/server/apache-phoenix-5.0.0-HBase-2.0-bin/
bin/sqlline.py node1.itcast.cn:2181
# 输入!table查看Phoenix中的表
!table
```

7.查看HBase的Web UI，可以看到Phoenix在default命名空间下创建了一些表，而且该系统表加载了大量的协处理器。

![image.png](https://image.hyly.net/i/2025/09/28/129695fe4e719ab9a318627b46b49fcb-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/abe41da581e93340747488ff8fff796e-0.webp)

### 快速入门

#### 需求

本次的小DEMO，我们沿用之前的订单数据集。我们将使用Phoenix来创建表，并进行数据增删改查操作。

![image.png](https://image.hyly.net/i/2025/09/28/143e3219e008c0a2cd9adcc2a8138032-0.webp)

<figure class='table-figure'><table>
<thead>
<tr><th>列名</th><th>说明</th></tr></thead>
<tbody><tr><td>id</td><td>订单ID</td></tr><tr><td>status</td><td>订单状态</td></tr><tr><td>money</td><td>支付金额</td></tr><tr><td>pay_way</td><td>支付方式ID</td></tr><tr><td>user_id</td><td>用户ID</td></tr><tr><td>operation_time</td><td>操作时间</td></tr><tr><td>category</td><td>商品分类</td></tr></tbody>
</table></figure>

#### 创建表语法

在Phoenix中，我们可以使用类似于MySQL DDL的方式快速创建表。例如：

```
CREATE TABLE IF NOT EXISTS 表名 (
   ROWKEY名称 数据类型 PRIMARY KEY
	列蔟名.列名1 数据类型 NOT NULL,
	列蔟名.列名2 数据类型 NOT NULL,
	列蔟名.列名3 数据类型);
```

readme.md中写入如下：

```
# 陌陌海量消息存储说明文档
### 1. 项目结构说明
* hbase_shell：用于存放hbase shell操作脚本
* momo_chat_app：Java API数据接口
* phoenix：phoenix SQL脚本
```

订单明细建表语句：

```
create table if not exists ORDER_DTL(
    ID varchar primary key,
    C1.STATUS varchar,
    C1.MONEY float,
    C1.PAY_WAY integer,
    C1.USER_ID varchar,
    C1.OPERATION_TIME varchar,
    C1.CATEGORY varchar
);
```

通过HBase的Web UI，我们可以看到Phoenix帮助我们自动在HBase中创建了一张名为 ORDER_DTL 的表格，可以看到里面添加了很多的协处理器。

```
'ORDER_DTL', {TABLE_ATTRIBUTES => {coprocessor$1 => '|org.apache.phoenix.coprocessor.ScanRegionObserver|805306366|', coprocessor$2 => '|org.apache.phoenix.coprocessor.UngroupedAggregateRegionObserver|805306366|', coprocessor$3 => '|org.apache.phoenix.coprocessor.GroupedAggregateRegionObserver|805306366|', coprocessor$4 => '|org.apache.phoenix.coprocessor.ServerCachingEndpointImpl|805306366|', coprocessor$5 => '|org.apache.phoenix.hbase.index.Indexer|805306366|index.builder=org.apache.phoenix.index.PhoenixIndexBuilder,org.apache.hadoop.hbase.index.codec.class=org.apache.phoenix.index.PhoenixIndexCodec'}}, {NAME => '0', VERSIONS => '1', EVICT_BLOCKS_ON_CLOSE => 'false', NEW_VERSION_BEHAVIOR => 'false', KEEP_DELETED_CELLS => 'FALSE', CACHE_DATA_ON_WRITE => 'false', DATA_BLOCK_ENCODING => 'FAST_DIFF', TTL => 'FOREVER', MIN_VERSIONS => '0', REPLICATION_SCOPE => '0', BLOOMFILTER => 'NONE', CACHE_INDEX_ON_WRITE => 'false', IN_MEMORY => 'false', CACHE_BLOOMS_ON_WRITE => 'false', PREFETCH_BLOCKS_ON_OPEN => 'false', COMPRESSION => 'NONE', BLOCKCACHE => 'true', BLOCKSIZE => '65536'}
```

同时，我们也看到这个表格默认只有一个Region，也就是没有分区的。

![image.png](https://image.hyly.net/i/2025/09/28/60638d2f98650719e16d876ea6e74bab-0.webp)

**常见问题：**
1.The table does not have a primary key

```
0: jdbc:phoenix:node1.itcast.cn:2181> create table if not exists ORDER_DTL(
. . . . . . . . . . . . . . . . . . >     C1.ID varchar,
. . . . . . . . . . . . . . . . . . >     C1.STATUS varchar,
. . . . . . . . . . . . . . . . . . >     C1.MONEY double,
. . . . . . . . . . . . . . . . . . >     C1.PAY_WAY integer,
. . . . . . . . . . . . . . . . . . >     C1.USER_ID varchar,
. . . . . . . . . . . . . . . . . . >     C1.OPERATION_TIME varchar,
. . . . . . . . . . . . . . . . . . >     C1.CATEGORY varchar
. . . . . . . . . . . . . . . . . . > );
Error: ERROR 509 (42888): The table does not have a primary key. tableName=ORDER_DTL (state=42888,code=509)
java.sql.SQLException: ERROR 509 (42888): The table does not have a primary key. tableName=ORDER_DTL
        at org.apache.phoenix.exception.SQLExceptionCode$Factory$1.newException(SQLExceptionCode.java:494)
        at org.apache.phoenix.exception.SQLExceptionInfo.buildException(SQLExceptionInfo.java:150)
        at org.apache.phoenix.schema.MetaDataClient.createTableInternal(MetaDataClient.java:2440)
        at org.apache.phoenix.schema.MetaDataClient.createTable(MetaDataClient.java:1114)
        at org.apache.phoenix.compile.CreateTableCompiler$1.execute(CreateTableCompiler.java:192)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:408)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:391)
        at org.apache.phoenix.call.CallRunner.run(CallRunner.java:53)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:390)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:378)
        at org.apache.phoenix.jdbc.PhoenixStatement.execute(PhoenixStatement.java:1825)
        at sqlline.Commands.execute(Commands.java:822)
        at sqlline.Commands.sql(Commands.java:732)
        at sqlline.SqlLine.dispatch(SqlLine.java:813)
        at sqlline.SqlLine.begin(SqlLine.java:686)
        at sqlline.SqlLine.start(SqlLine.java:398)
        at sqlline.SqlLine.main(SqlLine.java:291)
```

原因：
表没有主键，创建表时必须要指定主键，因为HBase数据存储必须要有rowkey
解决办法：
在id后面加一个primary key

2.Error: ERROR 1003 (42J01): Primary key columns must not have a family name

```
Error: ERROR 1003 (42J01): Primary key columns must not have a family name. columnName=C1.ID (state=42J01,code=1003)
java.sql.SQLException: ERROR 1003 (42J01): Primary key columns must not have a family name. columnName=C1.ID
        at org.apache.phoenix.exception.SQLExceptionCode$Factory$1.newException(SQLExceptionCode.java:494)
        at org.apache.phoenix.exception.SQLExceptionInfo.buildException(SQLExceptionInfo.java:150)
        at org.apache.phoenix.schema.MetaDataClient.newColumn(MetaDataClient.java:1028)
        at org.apache.phoenix.schema.MetaDataClient.createTableInternal(MetaDataClient.java:2396)
        at org.apache.phoenix.schema.MetaDataClient.createTable(MetaDataClient.java:1114)
        at org.apache.phoenix.compile.CreateTableCompiler$1.execute(CreateTableCompiler.java:192)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:408)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:391)
        at org.apache.phoenix.call.CallRunner.run(CallRunner.java:53)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:390)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:378)
        at org.apache.phoenix.jdbc.PhoenixStatement.execute(PhoenixStatement.java:1825)
        at sqlline.Commands.execute(Commands.java:822)
        at sqlline.Commands.sql(Commands.java:732)
        at sqlline.SqlLine.dispatch(SqlLine.java:813)
        at sqlline.SqlLine.begin(SqlLine.java:686)
        at sqlline.SqlLine.start(SqlLine.java:398)
        at sqlline.SqlLine.main(SqlLine.java:291)
0: jdbc:phoenix:node1.itcast.cn:2181> 
Error:  (state=,code=0)
java.sql.SQLFeatureNotSupportedException
        at org.apache.phoenix.jdbc.PhoenixStatement.cancel(PhoenixStatement.java:1691)
        at sqlline.DispatchCallback.forceKillSqlQuery(DispatchCallback.java:83)
        at sqlline.SqlLine.begin(SqlLine.java:700)
        at sqlline.SqlLine.start(SqlLine.java:398)
        at sqlline.SqlLine.main(SqlLine.java:291)
```

问题原因：
给Primary Key指定了主键
解决办法：
移除primary key上的列蔟

### 查看表的信息

```
!desc ORDER_DTL
```

**注意：
一定要加上 !**

#### 删除表语法

```
drop table if exists ORDER_DTL;
```

#### 大小写问题

在HBase中，如果在列蔟、列名没有添加双引号。Phoenix会自动转换为大写。
例如：

```
create table if not exists ORDER_DTL(
    id varchar primary key,
    C1.status varchar,
    C1.money double,
    C1.pay_way integer,
    C1.user_id varchar,
    C1.operation_time varchar,
    C1.category varchar
);
```

![image.png](https://image.hyly.net/i/2025/09/28/fc56ce24593abea38123b204414ac09f-0.webp)

如果要将列的名字改为小写，需要使用双引号，如下：

![image.png](https://image.hyly.net/i/2025/09/28/6843eb690e19b04ae66bb00ae7597b50-0.webp)

注意：
一旦加了小写，后面都得任何应用该列的地方都得使用双引号，否则将报以下错误：

```
Error: ERROR 504 (42703): Undefined column. columnName=ORDER_DTL.ID
```

#### 插入数据

在Phoenix中，插入并不是使用insert来实现的。而是 「upsert 」命令。它的功能为insert + update，与HBase中的put相对应。如果不存在则插入，否则更新。列表是可选的，如果不存在，值将按模式中声明的顺序映射到列。这些值必须计算为常量。

```
upsert into 表名(列蔟列名, xxxx, ) VALUES(XXX, XXX, XXX)
```

插入一条数据：

<figure class='table-figure'><table>
<thead>
<tr><th>订单ID</th><th>订单状态</th><th>支付金额</th><th>支付方式ID</th><th>用户ID</th><th>操作时间</th><th>商品分类</th></tr></thead>
<tbody><tr><td>ID</td><td>STATUS</td><td>PAY_MONEY</td><td>PAYWAY</td><td>USER_ID</td><td>OPERATION_DATE</td><td>CATEGORY</td></tr><tr><td>000001</td><td>已提交</td><td>4070</td><td>1</td><td>4944191</td><td>2020-04-25 12:09:16</td><td>手机;</td></tr></tbody>
</table></figure>

参考代码：

```
UPSERT INTO ORDER_DTL VALUES('000001', '已提交', 4070, 1, '4944191', '2020-04-25 12:09:16', '手机;');
```

#### 查询数据

与标准SQL一样，Phoenix也是使用select语句来实现数据的查询。

##### 查询所有数据

```
SELECT * FROM ORDER_DTL;
```

##### 更新数据

在Phoenix中，更新数据也是使用UPSERT。语法格式如下：
UPSERT INTO 表名(列名, …) VALUES(对应的值, …);

需求：
将ID为'000001'的订单状态修改为已付款。

```
UPSERT INTO ORDER_DTL("id", C1."status") VALUES ('000001', '已付款');
```

##### 根据ID查询数据

```
SELECT * FROM ORDER_DTL WHERE "id" = '000001';
```

#### 根据ID删除数据

```
DELETE FROM ORDER_DTL WHERE "id" = '000001';
```

#### 导入测试数据

为了方便我们做更多的查询，将以下SQL语句复制到Phoenix客户端中执行。

```
UPSERT INTO "ORDER_DTL" VALUES('000002','已提交',4070,1,'4944191','2020-04-25 12:09:16','手机;');
UPSERT INTO "ORDER_DTL" VALUES('000003','已完成',4350,1,'1625615','2020-04-25 12:09:37','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('000004','已提交',6370,3,'3919700','2020-04-25 12:09:39','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('000005','已付款',6370,3,'3919700','2020-04-25 12:09:44','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('000006','已提交',9380,1,'2993700','2020-04-25 12:09:41','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000007','已付款',9380,1,'2993700','2020-04-25 12:09:46','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000008','已完成',6400,2,'5037058','2020-04-25 12:10:13','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('000009','已付款',280,1,'3018827','2020-04-25 12:09:53','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('000010','已完成',5600,1,'6489579','2020-04-25 12:08:55','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('000011','已付款',5600,1,'6489579','2020-04-25 12:09:00','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('000012','已提交',8340,2,'2948003','2020-04-25 12:09:26','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('000013','已付款',8340,2,'2948003','2020-04-25 12:09:30','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('000014','已提交',7060,2,'2092774','2020-04-25 12:09:38','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('000015','已提交',640,3,'7152356','2020-04-25 12:09:49','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000016','已付款',9410,3,'7152356','2020-04-25 12:10:01','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000017','已提交',9390,3,'8237476','2020-04-25 12:10:08','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('000018','已提交',7490,2,'7813118','2020-04-25 12:09:05','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('000019','已付款',7490,2,'7813118','2020-04-25 12:09:06','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('000020','已付款',5360,2,'5301038','2020-04-25 12:08:50','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000021','已提交',5360,2,'5301038','2020-04-25 12:08:53','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000022','已取消',5360,2,'5301038','2020-04-25 12:08:58','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('000023','已付款',6490,0,'3141181','2020-04-25 12:09:22','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('000024','已付款',3820,1,'9054826','2020-04-25 12:10:04','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('000025','已提交',4650,2,'5837271','2020-04-25 12:08:52','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('000026','已付款',4650,2,'5837271','2020-04-25 12:08:57','机票;文娱;');
```

#### 分页查询

使用limit和offset可以快速进行分页。
limit表示每页多少条记录，offset表示从第几条记录开始查起。

```
-- 第一页
select * from ORDER_DTL limit 10 offset 0;
-- 第二页
-- offset从10开始
select * from ORDER_DTL limit 10 offset 10;
-- 第三页
select * from ORDER_DTL limit 10 offset 20;
```

![image.png](https://image.hyly.net/i/2025/09/28/ef930c6a5420231db4a4b8f2be2f0f4b-0.webp)

#### 更多语法

http://phoenix.apache.org/language/index.html#delete

![image.png](https://image.hyly.net/i/2025/09/28/fe9462c85fe7e882a6f94ad82a6f38b4-0.webp)

### 预分区表

默认创建表的方式，则HBase顺序写入可能会受到RegionServer热点的影响。对行键进行加盐可以解决热点问题。在HBase中，可以使用两种方式：
1.ROWKEY预分区
2.加盐指定数量分区

#### ROWKEY预分区

按照用户ID来分区，一共4个分区。并指定数据的压缩格式为GZ。

```
drop table if exists ORDER_DTL;
create table if not exists ORDER_DTL(
    "id" varchar primary key,
    C1."status" varchar,
    C1."money" float,
    C1."pay_way" integer,
    C1."user_id" varchar,
    C1."operation_time" varchar,
    C1."category" varchar
) 
CONPRESSION='GZ'
SPLIT ON ('3','5','7');
```

![image.png](https://image.hyly.net/i/2025/09/28/19306539f53120a6b1d2be218ef9210c-0.webp)

我们尝试往表中插入一些数据，然后去HBase中查看数据的分布情况。

```
UPSERT INTO "ORDER_DTL" VALUES('02602f66-adc7-40d4-8485-76b5632b5b53','已提交',4070,1,'4944191','2020-04-25 12:09:16','手机;');
UPSERT INTO "ORDER_DTL" VALUES('0968a418-f2bc-49b4-b9a9-2157cf214cfd','已完成',4350,1,'1625615','2020-04-25 12:09:37','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('0e01edba-5e55-425e-837a-7efb91c56630','已提交',6370,3,'3919700','2020-04-25 12:09:39','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('0e01edba-5e55-425e-837a-7efb91c56630','已付款',6370,3,'3919700','2020-04-25 12:09:44','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('0f46d542-34cb-4ef4-b7fe-6dcfa5f14751','已提交',9380,1,'2993700','2020-04-25 12:09:41','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('0f46d542-34cb-4ef4-b7fe-6dcfa5f14751','已付款',9380,1,'2993700','2020-04-25 12:09:46','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('1fb7c50f-9e26-4aa8-a140-a03d0de78729','已完成',6400,2,'5037058','2020-04-25 12:10:13','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('23275016-996b-420c-8edc-3e3b41de1aee','已付款',280,1,'3018827','2020-04-25 12:09:53','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('2375a7cf-c206-4ac0-8de4-863e7ffae27b','已完成',5600,1,'6489579','2020-04-25 12:08:55','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('2375a7cf-c206-4ac0-8de4-863e7ffae27b','已付款',5600,1,'6489579','2020-04-25 12:09:00','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('269fe10c-740b-4fdb-ad25-7939094073de','已提交',8340,2,'2948003','2020-04-25 12:09:26','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('269fe10c-740b-4fdb-ad25-7939094073de','已付款',8340,2,'2948003','2020-04-25 12:09:30','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('2849fa34-6513-44d6-8f66-97bccb3a31a1','已提交',7060,2,'2092774','2020-04-25 12:09:38','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('28b7e793-6d14-455b-91b3-0bd8b23b610c','已提交',640,3,'7152356','2020-04-25 12:09:49','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('28b7e793-6d14-455b-91b3-0bd8b23b610c','已付款',9410,3,'7152356','2020-04-25 12:10:01','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('2909b28a-5085-4f1d-b01e-a34fbaf6ce37','已提交',9390,3,'8237476','2020-04-25 12:10:08','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('2a01dfe5-f5dc-4140-b31b-a6ee27a6e51e','已提交',7490,2,'7813118','2020-04-25 12:09:05','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('2a01dfe5-f5dc-4140-b31b-a6ee27a6e51e','已付款',7490,2,'7813118','2020-04-25 12:09:06','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('2b86ab90-3180-4940-b624-c936a1e7568d','已付款',5360,2,'5301038','2020-04-25 12:08:50','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('2b86ab90-3180-4940-b624-c936a1e7568d','已提交',5360,2,'5301038','2020-04-25 12:08:53','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('2b86ab90-3180-4940-b624-c936a1e7568d','已取消',5360,2,'5301038','2020-04-25 12:08:58','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('2e19fbe8-7970-4d62-8e8f-d364afc2dd41','已付款',6490,0,'3141181','2020-04-25 12:09:22','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('2fc28d36-dca0-49e8-bad0-42d0602bdb40','已付款',3820,1,'9054826','2020-04-25 12:10:04','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('31477850-8b15-4f1b-9ec3-939f7dc47241','已提交',4650,2,'5837271','2020-04-25 12:08:52','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('31477850-8b15-4f1b-9ec3-939f7dc47241','已付款',4650,2,'5837271','2020-04-25 12:08:57','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('39319322-2d80-41e7-a862-8b8858e63316','已提交',5000,1,'5686435','2020-04-25 12:08:51','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('39319322-2d80-41e7-a862-8b8858e63316','已完成',5000,1,'5686435','2020-04-25 12:08:56','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('3d2254bd-c25a-404f-8e42-2faa4929a629','已提交',5000,3,'1274270','2020-04-25 12:08:41','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('3d2254bd-c25a-404f-8e42-2faa4929a629','已付款',5000,3,'1274270','2020-04-25 12:08:42','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('3d2254bd-c25a-404f-8e42-2faa4929a629','已完成',5000,1,'1274270','2020-04-25 12:08:43','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('42f7fe21-55a3-416f-9535-baa222cc0098','已完成',3600,2,'2661641','2020-04-25 12:09:58','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('44231dbb-9e58-4f1a-8c83-be1aa814be83','已提交',3950,1,'3855371','2020-04-25 12:08:39','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('44231dbb-9e58-4f1a-8c83-be1aa814be83','已付款',3950,1,'3855371','2020-04-25 12:08:40','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('526e33d2-a095-4e19-b759-0017b13666ca','已完成',3280,0,'5553283','2020-04-25 12:09:01','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('5a6932f4-b4a4-4a1a-b082-2475d13f9240','已提交',50,2,'1764961','2020-04-25 12:10:07','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('5fc0093c-59a3-417b-a9ff-104b9789b530','已提交',6310,2,'1292805','2020-04-25 12:09:36','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('605c6dd8-123b-4088-a047-e9f377fcd866','已完成',8980,2,'6202324','2020-04-25 12:09:54','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('613cfd50-55c7-44d2-bb67-995f72c488ea','已完成',6830,3,'6977236','2020-04-25 12:10:06','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('62246ac1-3dcb-4f2c-8943-800c9216c29f','已提交',8610,1,'5264116','2020-04-25 12:09:14','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('62246ac1-3dcb-4f2c-8943-800c9216c29f','已付款',8610,1,'5264116','2020-04-25 12:09:18','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('625c7fef-de87-428a-b581-a63c71059b14','已提交',5970,0,'8051757','2020-04-25 12:09:07','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('625c7fef-de87-428a-b581-a63c71059b14','已付款',5970,0,'8051757','2020-04-25 12:09:19','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('6d43c490-58ab-4e23-b399-dda862e06481','已提交',4570,0,'5514248','2020-04-25 12:09:34','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('70fa0ae0-6c02-4cfa-91a9-6ad929fe6b1b','已付款',4100,1,'8598963','2020-04-25 12:09:08','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('7170ce71-1fc0-4b6e-a339-67f525536dcd','已完成',9740,1,'4816392','2020-04-25 12:09:51','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('7170ce71-1fc0-4b6e-a339-67f525536dcd','已提交',9740,1,'4816392','2020-04-25 12:10:03','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('71961b06-290b-457d-bbe0-86acb013b0e3','已付款',6550,3,'2393699','2020-04-25 12:08:47','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('71961b06-290b-457d-bbe0-86acb013b0e3','已付款',6550,3,'2393699','2020-04-25 12:08:48','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('71961b06-290b-457d-bbe0-86acb013b0e3','已完成',6550,3,'2393699','2020-04-25 12:08:49','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('72dc148e-ce64-432d-b99f-61c389cb82cd','已提交',4090,1,'2536942','2020-04-25 12:10:12','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('72dc148e-ce64-432d-b99f-61c389cb82cd','已付款',4090,1,'2536942','2020-04-25 12:10:14','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('7c0c1668-b783-413f-afc4-678a5a6d1033','已完成',3850,3,'6803936','2020-04-25 12:09:20','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('7fa02f7a-10df-4247-9935-94c8b7d4dbc0','已提交',1060,0,'6119810','2020-04-25 12:09:21','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('820c5e83-f2e0-42d4-b5f0-83802c75addc','已付款',9270,2,'5818454','2020-04-25 12:10:09','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('83ed55ec-a439-44e0-8fe0-acb7703fb691','已完成',8380,2,'6804703','2020-04-25 12:09:52','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('85287268-f139-4d59-8087-23fa6454de9d','已提交',9750,1,'4382852','2020-04-25 12:09:43','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('85287268-f139-4d59-8087-23fa6454de9d','已付款',9750,1,'4382852','2020-04-25 12:09:48','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('85287268-f139-4d59-8087-23fa6454de9d','已取消',9750,1,'4382852','2020-04-25 12:10:00','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('8d32669e-327a-4802-89f4-2e91303aee59','已提交',9390,1,'4182962','2020-04-25 12:09:57','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('8dadc2e4-63f1-490f-9182-793be64fed76','已付款',9350,1,'5937549','2020-04-25 12:09:02','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('94ad8ee0-8898-442c-8cb1-083a4b609616','已提交',4370,0,'4666456','2020-04-25 12:09:13','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('994cbb44-f0ee-45ff-a4f4-76c87bc2b972','已付款',3190,3,'3200759','2020-04-25 12:09:25','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('9bf92519-6eb3-449a-853b-0e19f6005887','已提交',1100,0,'3457528','2020-04-25 12:10:11','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('9ff3032c-8679-4247-9e6f-4caf2dc93aff','已提交',850,0,'8835231','2020-04-25 12:09:40','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('9ff3032c-8679-4247-9e6f-4caf2dc93aff','已付款',850,0,'8835231','2020-04-25 12:09:45','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('a467ba42-f91e-48a0-865e-1703aaa45e0e','已提交',8040,0,'8206022','2020-04-25 12:09:50','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('a467ba42-f91e-48a0-865e-1703aaa45e0e','已付款',8040,0,'8206022','2020-04-25 12:10:02','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('a5302f47-96d9-41b4-a14c-c7a508f59282','已付款',8570,2,'5319315','2020-04-25 12:08:44','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('a5b57bec-6235-45f4-bd7e-6deb5cd1e008','已提交',5700,3,'6486444','2020-04-25 12:09:27','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('a5b57bec-6235-45f4-bd7e-6deb5cd1e008','已付款',5700,3,'6486444','2020-04-25 12:09:31','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('ae5c3363-cf8f-48a9-9676-701a7b0a7ca5','已付款',7460,1,'2379296','2020-04-25 12:09:23','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('b1fb2399-7cf2-4af5-960a-a4d77f4803b8','已提交',2690,3,'6686018','2020-04-25 12:09:55','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('b21c7dbd-dabd-4610-94b9-d7039866a8eb','已提交',6310,2,'1552851','2020-04-25 12:09:15','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('b4bfd4b7-51f5-480e-9e23-8b1579e36248','已提交',4000,1,'3260372','2020-04-25 12:09:35','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('b63983cc-2b59-4992-84c6-9810526d0282','已提交',7370,3,'3107867','2020-04-25 12:08:45','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('b63983cc-2b59-4992-84c6-9810526d0282','已付款',7370,3,'3107867','2020-04-25 12:08:46','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('bf60b752-1ccc-43bf-9bc3-b2aeccacc0ed','已提交',720,2,'5034117','2020-04-25 12:09:03','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('c808addc-8b8b-4d89-99b1-db2ed52e61b4','已提交',3630,1,'6435854','2020-04-25 12:09:10','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('cc9dbd20-cf9f-4097-ae8b-4e73db1e4ba1','已付款',5000,0,'2007322','2020-04-25 12:08:38','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('ccceaf57-a5ab-44df-834a-e7b32c63efc1','已提交',2660,2,'7928516','2020-04-25 12:09:42','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('ccceaf57-a5ab-44df-834a-e7b32c63efc1','已付款',2660,2,'7928516','2020-04-25 12:09:47','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('ccceaf57-a5ab-44df-834a-e7b32c63efc1','已完成',2660,2,'7928516','2020-04-25 12:09:59','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('d7be5c39-e07c-40e8-bf09-4922fbc6335c','已付款',8750,2,'1250995','2020-04-25 12:09:09','食品;家用电器;');
UPSERT INTO "ORDER_DTL" VALUES('dfe16df7-4a46-4b6f-9c6d-083ec215218e','已完成',410,0,'1923817','2020-04-25 12:09:56','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('e1241ad4-c9c1-4c17-93b9-ef2c26e7f2b2','已付款',6760,0,'2457464','2020-04-25 12:08:54','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('e1241ad4-c9c1-4c17-93b9-ef2c26e7f2b2','已提交',6760,0,'2457464','2020-04-25 12:08:59','数码;女装;');
UPSERT INTO "ORDER_DTL" VALUES('e180a9f2-9f80-4b6d-99c8-452d6c037fc7','已付款',8120,2,'7645270','2020-04-25 12:09:28','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('e180a9f2-9f80-4b6d-99c8-452d6c037fc7','已完成',8120,2,'7645270','2020-04-25 12:09:32','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('e4418843-9ac0-47a7-bfd8-d61c4d296933','已付款',8170,2,'7695668','2020-04-25 12:09:11','家用电器;;电脑;');
UPSERT INTO "ORDER_DTL" VALUES('e8b3bb37-1019-4492-93c7-305177271a71','已完成',2560,2,'4405460','2020-04-25 12:10:05','男装;男鞋;');
UPSERT INTO "ORDER_DTL" VALUES('eb1a1a22-953a-42f1-b594-f5dfc8fb6262','已完成',2370,2,'8233485','2020-04-25 12:09:24','机票;文娱;');
UPSERT INTO "ORDER_DTL" VALUES('ecfd18f5-45f2-4dcd-9c47-f2ad9b216bd0','已付款',8070,3,'6387107','2020-04-25 12:09:04','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('ecfd18f5-45f2-4dcd-9c47-f2ad9b216bd0','已完成',8070,3,'6387107','2020-04-25 12:09:17','酒店;旅游;');
UPSERT INTO "ORDER_DTL" VALUES('f1226752-7be3-4702-a496-3ddba56f66ec','已付款',4410,3,'1981968','2020-04-25 12:10:10','维修;手机;');
UPSERT INTO "ORDER_DTL" VALUES('f642b16b-eade-4169-9eeb-4d5f294ec594','已提交',4010,1,'6463215','2020-04-25 12:09:29','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('f642b16b-eade-4169-9eeb-4d5f294ec594','已付款',4010,1,'6463215','2020-04-25 12:09:33','男鞋;汽车;');
UPSERT INTO "ORDER_DTL" VALUES('f8f3ca6f-2f5c-44fd-9755-1792de183845','已付款',5950,3,'4060214','2020-04-25 12:09:12','机票;文娱;');
```

我们发现数据分布在每一个Region中。

![image.png](https://image.hyly.net/i/2025/09/28/23dbf08b35fd5f17b48de475f364ad70-0.webp)

#### 加盐指定数量分区

```
drop table if exists ORDER_DTL;
create table if not exists ORDER_DTL(
    "id" varchar primary key,
    C1."status" varchar,
    C1."money" float,
    C1."pay_way" integer,
    C1."user_id" varchar,
    C1."operation_time" varchar,
    C1."category" varchar
) 
CONPRESSION='GZ', SALT_BUCKETS=10;
```

我们在HBase的Web UI中可以查看到生成了10个Region

![image.png](https://image.hyly.net/i/2025/09/28/f3530f17541a68099ce2769ae2edce17-0.webp)

插入数据后，发现数据分部在每一个Region中。

![image.png](https://image.hyly.net/i/2025/09/28/6e0f0c9e04e29770b51f9470254b9068-0.webp)

查看HBase中的表，我们发现Phoenix在每个ID前，都添加了一个Hash值，用来将分布分布到不同的Region中。

```
hbase(main):018:0> scan "ORDER_DTL", {LIMIT => 1}
ROW                                                          COLUMN+CELL                                                                                                                                                       
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x00\x00\x00\x00, timestamp=1589268724801, value=x                                                                                                      
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x0B, timestamp=1589268724801, value=\xE5\xB7\xB2\xE4\xBB\x98\xE6\xAC\xBE                                                                           
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x0C, timestamp=1589268724801, value=\xC6\x12\x90\x01                                                                                               
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x0D, timestamp=1589268724801, value=\x80\x00\x00\x01                                                                                               
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x0E, timestamp=1589268724801, value=2993700                                                                                                        
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x0F, timestamp=1589268724801, value=2020-04-25 12:09:46                                                                                            
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751                    column=C1:\x80\x10, timestamp=1589268724801, value=\xE7\xBB\xB4\xE4\xBF\xAE;\xE6\x89\x8B\xE6\x9C\xBA;                                                             
1 row(s)
```

**注意：
CONPRESSION和SALT_BUCKETS之间需要使用逗号分隔，否则会出现语法错误**

## 基于Phoenix消息数据查询

### 建立视图

#### 应用场景

因为我们之前已经创建了 MOMO_CHAT:MSG 表，而且数据添加的方式都是以PUT方式原生API来添加的。故此时，我们不再需要再使用Phoenix创建新的表，而是使用Phoenix中的视图，通过视图来建立与HBase表之间的映射，从而实现数据快速查询。

#### 视图介绍

我们可以在现有的HBase或Phoenix表上创建一个视图。表、列蔟和列名必须与现有元数据完全匹配，否则会出现异常。当创建视图后，就可以使用SQL查询视图，和操作Table一样。

语法示例：

```
-- 映射HBase中的表
CREATE VIEW "my_hbase_table"
    ( k VARCHAR primary key, "v" UNSIGNED_LONG) default_column_family='a';

-- 映射Phoenix中的表
CREATE VIEW my_view ( new_col SMALLINT )
    AS SELECT * FROM my_table WHERE k = 100;

-- 映射到一个SQL查询
CREATE VIEW my_view_on_view
    AS SELECT * FROM my_view WHERE new_col > 70;
```

#### 建立MOMO_CHAT:MSG的视图

考虑以下几个问题：

1. 视图如何映射到HBase的表？
   1. 视图的名字必须是：命名空间.表名
2. 视图中的列如何映射到HBase的列蔟和列？
   1. 列名必须是：列蔟.列名
3. 视图中的类如何映射到HBase的ROWKEY？
   1. 指定某个列为primary key，自动映射ROWKEY

参考创建语句：

```
-- 创建MOMO_CHAT:MSG视图
create view if not exists "MOMO_CHAT". "MSG" (
    "pk" varchar primary key, -- 指定ROWKEY映射到主键
    "C1"."msg_time" varchar,
    "C1"."sender_nickyname" varchar,
    "C1"."sender_account" varchar,
    "C1"."sender_sex" varchar,
    "C1"."sender_ip" varchar,
    "C1"."sender_os" varchar,
    "C1"."sender_phone_type" varchar,
    "C1"."sender_network" varchar,
    "C1"."sender_gps" varchar,
    "C1"."receiver_nickyname" varchar,
    "C1"."receiver_ip" varchar,
    "C1"."receiver_account" varchar,
    "C1"."receiver_os" varchar,
    "C1"."receiver_phone_type" varchar,
    "C1"."receiver_network" varchar,
    "C1"."receiver_gps" varchar,
    "C1"."receiver_sex" varchar,
    "C1"."msg_type" varchar,
    "C1"."distance" varchar,
    "C1"."message" varchar
);
```

#### 尝试查询一条数据

```
SELECT * FROM "MOMO_CHAT"."MSG" LIMIT 1;
```

![image.png](https://image.hyly.net/i/2025/09/28/0491b8df82db4ff17040e75a84318d61-0.webp)

如果发现数据能够正常展示，说明视图映射已经成功。

**注意：
因为列名中有小写，需要用引号将字段名包含起来**

### 开发基于SQL查询数据接口

#### 使用SQL语句查询数据

##### 需求

根据日期、发送人账号、接收人账号查询历史消息

##### 编写SQL语句

```
-- 查询对应日期的数据（只展示出来5条）
SELECT * FROM "MOMO_CHAT"."MSG" T 
WHERE substr("msg_time", 0, 10) = '2020-08-29'
    AND T."sender_account" = '13504113666'
    AND T."receiver_account" = '18182767005' LIMIT 100;
```

##### 编写Java代码

1. 编写PhoenixChatMessageService实现ChatMessageService接口
2. 在构造器中创建JDBC连接
   1. JDBC驱动为：PhoenixDriver.class.getName()
   2. JDBC连接URL为：jdbc:phoenix:node1.itcast.cn:2181
3. 基于JDBC实现getMessage查询
4. 在close方法中

```
public class PhoenixChatMessageService implements ChatMessageService {
    private Connection connection;

    public PhoenixChatMessageService() {
        try {
            Class.forName(PhoenixDriver.class.getName());
            connection = DriverManager.getConnection("jdbc:phoenix:node1.itcast.cn:2181");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("加载Phoenix驱动失败!");
        } catch (SQLException e) {
            throw new RuntimeException("获取Phoenix JDBC连接失败!");
        }
    }

    @Override
    public List<Msg> getMessage(String date, String sender, String receiver) throws Exception {
        PreparedStatement ps = connection.prepareStatement(
                "SELECT * FROM MOMO_CHAT.MSG T WHERE substr(\"msg_time\", 0, 10) = ? "
                        + "AND T.\"sender_account\" = ? "
                        + "AND T.\"receiver_account\" = ? ");

        ps.setString(1, date);
        ps.setString(2, sender);
        ps.setString(3, receiver);

        ResultSet rs = ps.executeQuery();
        List<Msg> msgList = new ArrayList<>();

        while(rs.next()) {
            Msg msg = new Msg();
            msg.setMsg_time(rs.getString("msg_time"));
            msg.setSender_nickyname(rs.getString("sender_nickyname"));
            msg.setSender_account(rs.getString("sender_account"));
            msg.setSender_sex(rs.getString("sender_sex"));
            msg.setSender_ip(rs.getString("sender_ip"));
            msg.setSender_os(rs.getString("sender_os"));
            msg.setSender_phone_type(rs.getString("sender_phone_type"));
            msg.setSender_network(rs.getString("sender_network"));
            msg.setSender_gps(rs.getString("sender_gps"));
            msg.setReceiver_nickyname(rs.getString("receiver_nickyname"));
            msg.setReceiver_ip(rs.getString("receiver_ip"));
            msg.setReceiver_account(rs.getString("receiver_account"));
            msg.setReceiver_os(rs.getString("receiver_os"));
            msg.setReceiver_phone_type(rs.getString("receiver_phone_type"));
            msg.setReceiver_network(rs.getString("receiver_network"));
            msg.setReceiver_gps(rs.getString("receiver_gps"));
            msg.setReceiver_sex(rs.getString("receiver_sex"));
            msg.setMsg_type(rs.getString("msg_type"));
            msg.setDistance(rs.getString("distance"));

            msgList.add(msg);
        }

        return msgList;
    }

    @Override
    public void close() {
        try {
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws Exception {
        ChatMessageService chatMessageService = new PhoenixChatMessageService();
        List<Msg> message = chatMessageService.getMessage("2020-08-24", "13504113666", "18182767005");

        for (Msg msg : message) {
            System.out.println(msg);
        }

        chatMessageService.close();
    }
}
```

### 二级索引

上面的查询，因为没有建立索引，组合条件查询效率较低，而通过使用Phoenix，我们可以非常方便地创建二级索引。Phoenix中的索引，其实底层还是表现为HBase中的表结构。这些索引表专门用来加快查询速度。

![image.png](https://image.hyly.net/i/2025/09/28/795c266cc7debdedcad8dbc431a3e99a-0.webp)

#### 索引分类

1.全局索引
2.本地索引
3.覆盖索引
4.函数索引

##### 全局索引

1. 全局索引适用于读多写少业务
2. 全局索引绝大多数负载都发生在写入时，当构建了全局索引时，Phoenix会拦截写入(DELETE、UPSERT值和UPSERT SELECT)上的数据表更新，构建索引更新，同时更新所有相关的索引表，开销较大
3. 读取时，Phoenix将选择最快能够查询出数据的索引表。默认情况下，除非使用Hint，如果SELECT查询中引用了其他非索引列，该索引是不会生效的
4. 全局索引一般和覆盖索引搭配使用，读的效率很高，但写入效率会受影响

创建语法：

```
CREATE INDEX 索引名称 ON 表名 (列名1, 列名2, 列名3...)
```

##### 本地索引

1. 本地索引适合写操作频繁，读相对少的业务
2. 当使用SQL查询数据时，Phoenix会自动选择是否使用本地索引查询数据
3. 在本地索引中，索引数据和业务表数据存储在同一个服务器上，避免写入期间的其他网络开销
4. 在Phoenix 4.8.0之前，本地索引保存在一个单独的表中，在Phoenix 4.8.1中，本地索引的数据是保存在一个影子列蔟中
5. 本地索引查询即使SELECT引用了非索引中的字段，也会自动应用索引的

**注意：创建表的时候指定了SALT_BUCKETS，是不支持本地索引的。**

![image.png](https://image.hyly.net/i/2025/09/28/e605bc7cabc5f178dc8149b19f08e46e-0.webp)

创建语法：

```
CREATE local INDEX 索引名称 ON 表名 (列名1, 列名2, 列名3...)
```

##### 覆盖索引

Phoenix提供了覆盖的索引，可以不需要在找到索引条目后返回到主表。Phoenix可以将关心的数据捆绑在索引行中，从而节省了读取时间的开销。

例如，以下语法将在v1和v2列上创建索引，并在索引中包括v3列，也就是通过v1、v2就可以直接把数据查询出来。

```
CREATE INDEX my_index ON my_table (v1,v2) INCLUDE(v3)
```

##### 函数索引

函数索引(4.3和更高版本)可以支持在列上创建索引，还可以基于任意表达式上创建索引。然后，当查询使用该表达式时，可以使用索引来检索结果，而不是数据表。例如，可以在UPPER(FIRST_NAME||‘ ’||LAST_NAME)上创建一个索引，这样将来搜索两个名字拼接在一起时，索引依然可以生效。

```
-- 创建索引
CREATE INDEX UPPER_NAME_IDX ON EMP (UPPER(FIRST_NAME||' '||LAST_NAME))
-- 以下查询会走索引
SELECT EMP_ID FROM EMP WHERE UPPER(FIRST_NAME||' '||LAST_NAME)='JOHN DOE'
```

#### 索引示例一：创建全局索引 + 覆盖索引

##### 需求

我们需要根据用户ID来查询订单的ID以及对应的支付金额。例如：查询已付款的订单ID和支付金额
此时，就可以在USER_ID列上创建索引，来加快查询

##### 创建索引

```
create index GBL_IDX_ORDER_DTL on ORDER_DTL(C1."user_id") INCLUDE("id", C1."money");
```

可以在HBase shell中看到，Phoenix自动帮助我们创建了一张GBL_IDX_ORDER_DTL的表。这种表就是一张索引表。它的数据如下：

```
hbase(main):005:0> scan "GBL_IDX_ORDER_DTL", { LIMIT  => 1}
ROW                                     COLUMN+CELL                                                                                            
 1250995\x00d7be5c39-e07c-40e8-bf09-492 column=C1:\x00\x00\x00\x00, timestamp=1589350330650, value=x                                           
 2fbc6335c                                                                                                                                     
 1250995\x00d7be5c39-e07c-40e8-bf09-492 column=C1:\x80\x0B, timestamp=1589350330650, value=\xC6\x08\xB8\x01                                    
 2fbc6335c                                                                                                                                     
1 row(s)
Took 0.1253 seconds  
```

这张表的ROWKEY为：用户ID + \x00 + 原始表ROWKEY，列蔟对应的就是include中指定的两个字段。

##### 查询数据

```
select "user_id", "id", "money" from ORDER_DTL where "user_id" = '8237476';
```

##### 查看执行计划

```
explain select "user_id", "id", "money" from ORDER_DTL where "user_id" = '8237476';
```

![image.png](https://image.hyly.net/i/2025/09/28/f0b9888c8310b410baec34bb9467c1e4-0.webp)

我们发现，PLAN中能看到SCAN的是GBL_IDX_ORDER_DTL，说明Phoenix是直接通过查询索引表获取到数据。

##### 删除索引

使用drop index 索引名 ON 表名

```
drop index IDX_ORDER_DTL_DATE on ORDER_DTL;
```

##### 查看索引

```
!table
```

![image.png](https://image.hyly.net/i/2025/09/28/ce316f620cf3cd6e4f62fdf18b2a0e52-0.webp)

##### 测试查询所有列是否会使用索引

```
explain select * from ORDER_DTL where "user_id" = '8237476';

```

![image.png](https://image.hyly.net/i/2025/09/28/1d5aa3a4bda351237abbf4698c8d2109-0.webp)

通过查询结果发现，PLAN中是执行的FULL SCAN，说明索引并没有生效，进行的全表扫描。

##### 使用Hint强制使用索引

```
explain select /*+ INDEX(ORDER_DTL GBL_IDX_ORDER_DTL) */ * from ORDER_DTL where USER_ID = '8237476';
```

![image.png](https://image.hyly.net/i/2025/09/28/38371a50fe53db4f34320ef02d00cb6c-0.webp)

通过执行计划，我们可以观察到查看全局索引，找到ROWKEY，然后执行全表的JOIN，其实就是把对应ROWKEY去查询ORDER_DTL表。

#### 索引示例二：创建本地索引

##### 需求

在程序中，我们可能会根据订单ID、订单状态、支付金额、支付方式、用户ID来查询订单。所以，我们需要在这些列上来查询订单。

针对这种场景，我们可以使用本地索引来提高查询效率。

##### 创建本地索引

```
create local index LOCAL_IDX_ORDER_DTL on ORDER_DTL("id", "status", "money", "pay_way", "user_id") ;
```

通过查看WebUI，我们并没有发现创建名为：LOCAL_IDX_ORDER_DTL 的表。那索引数据是存储在哪儿呢？我们可以通过HBase shell

```
hbase(main):031:0> scan "ORDER_DTL", {LIMIT => 1}
ROW                                     COLUMN+CELL                                                                                              
 \x00\x00\x0402602f66-adc7-40d4-8485-76 column=L#0:\x00\x00\x00\x00, timestamp=1589350314539, value=\x00\x00\x00\x00                             
 b5632b5b53\x00\xE5\xB7\xB2\xE6\x8F\x90                                                                                                          
 \xE4\xBA\xA4\x00\xC2)G\x00\xC1\x02\x00                                                                                                          
 4944191                                                                                                                                         
1 row(s)
Took 0.0155 seconds    
```

可以看到Phoenix对数据进行处理，原有的数据发生了变化。建立了本地二级索引表，不能再使用Hbase的Java API查询，只能通过JDBC来查询。

##### 查看数据

```
explain select * from ORDER_DTL WHERE "status" = '已提交';
explain select * from ORDER_DTL WHERE "status" = '已提交' AND "pay_way" = 1;
```

![image.png](https://image.hyly.net/i/2025/09/28/5117b403e9dcb94f34ec67eb9592e128-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/294c71f51cbe2295704b70fcb7220e6c-0.webp)

通过观察上面的两个执行计划发现，两个查询都是通过RANGE SCAN来实现的。说明本地索引生效。

##### 删除本地索引

```
drop index LOCAL_IDX_ORDER_DTL on ORDER_DTL;
```

重新执行一次扫描，你会发现数据变魔术般的恢复出来了。

```
hbase(main):007:0> scan "ORDER_DTL", {LIMIT => 1}
ROW                                              COLUMN+CELL                                                                                                                       
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x00\x00\x00\x00, timestamp=1599542260011, value=x                                                                      
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x0B, timestamp=1599542260011, value=\xE5\xB7\xB2\xE4\xBB\x98\xE6\xAC\xBE                                           
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x0C, timestamp=1599542260011, value=\xC6\x12\x90\x01                                                               
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x0D, timestamp=1599542260011, value=\x80\x00\x00\x01                                                               
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x0E, timestamp=1599542260011, value=2993700                                                                        
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x0F, timestamp=1599542260011, value=2020-04-25 12:09:46                                                            
 \x000f46d542-34cb-4ef4-b7fe-6dcfa5f14751        column=C1:\x80\x10, timestamp=1599542260011, value=\xE7\xBB\xB4\xE4\xBF\xAE;\xE6\x89\x8B\xE6\x9C\xBA;                             
1 row(s)
Took 0.0266 seconds
```

#### 使用Phoenix建立二级索引高效查询

##### 创建本地函数索引

```
CREATE LOCAL INDEX LOCAL_IDX_MOMO_MSG ON MOMO_CHAT.MSG(substr("msg_time", 0, 10), "sender_account", "receiver_account");
```

##### 执行数据查询

```
SELECT * FROM "MOMO_CHAT"."MSG" T 
WHERE substr("msg_time", 0, 10) = '2020-08-29'
    AND T."sender_account" = '13504113666'
    AND T."receiver_account" = '18182767005' LIMIT 100;
```

![image.png](https://image.hyly.net/i/2025/09/28/81ea8404656a9d8b8ab8f1f111d4b58c-0.webp)

可以看到，查询速度非常快，0.1秒就查询出来了数据。

#### 再次测试Java接口

## 常见问题

### Regions In Transition

![image.png](https://image.hyly.net/i/2025/09/28/e64687f632dac6e921155079bf80a70a-0.webp)

错误信息如下：

```
2020-05-09 12:14:22,760 WARN  [RS_OPEN_REGION-regionserver/node1:16020-2] handler.AssignRegionHandler: Failed to open region TestTable,00000000000000000006900000,1588444012555.8a72d1ccdadd3b14284a24ec01918023., will report to master
java.io.IOException: Missing table descriptor for TestTable,00000000000000000006900000,1588444012555.8a72d1ccdadd3b14284a24ec01918023.
        at org.apache.hadoop.hbase.regionserver.handler.AssignRegionHandler.process(AssignRegionHandler.java:129)
        at org.apache.hadoop.hbase.executor.EventHandler.run(EventHandler.java:104)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
        at java.lang.Thread.run(Thread.java:748)
```

#### 问题解析

在执行Region Split时，因为系统中断或者HDFS中的Region文件已经被删除。

Region的状态由master跟踪，包括以下状态：

<figure class='table-figure'><table>
<thead>
<tr><th>State</th><th>Description</th></tr></thead>
<tbody><tr><td>Offline</td><td>Region is offline</td></tr><tr><td>Pending Open</td><td>A request to open the region was sent to the server</td></tr><tr><td>Opening</td><td>The server has started opening the region</td></tr><tr><td>Open</td><td>The region is open and is fully operational</td></tr><tr><td>Pending Close</td><td>A request to close the region has been sent to the server</td></tr><tr><td>Closing</td><td>The server has started closing the region</td></tr><tr><td>Closed</td><td>The region is closed</td></tr><tr><td>Splitting</td><td>The server started splitting the region</td></tr><tr><td>Split</td><td>The region has been split by the server</td></tr></tbody>
</table></figure>

Region在这些状态之间的迁移（transition）可以由master引发，也可以由region server引发。

#### 解决方案

1. 使用 hbase hbck 找到哪些Region出现Error
2. 使用以下命令将失效的Region删除
   deleteall "hbase:meta","TestTable,00000000000000000005850000,1588444012555.89e1c07384a56c77761e490ae3f34a8d."
3. 重启hbase即可

### Phoenix: Table is read only

```
Error: ERROR 505 (42000): Table is read only. (state=42000,code=505)
org.apache.phoenix.schema.ReadOnlyTableException: ERROR 505 (42000): Table is read only.
        at org.apache.phoenix.query.ConnectionQueryServicesImpl.ensureTableCreated(ConnectionQueryServicesImpl.java:1126)
        at org.apache.phoenix.query.ConnectionQueryServicesImpl.createTable(ConnectionQueryServicesImpl.java:1501)
        at org.apache.phoenix.schema.MetaDataClient.createTableInternal(MetaDataClient.java:2721)
        at org.apache.phoenix.schema.MetaDataClient.createTable(MetaDataClient.java:1114)
        at org.apache.phoenix.compile.CreateTableCompiler$1.execute(CreateTableCompiler.java:192)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:408)
        at org.apache.phoenix.jdbc.PhoenixStatement$2.call(PhoenixStatement.java:391)
        at org.apache.phoenix.call.CallRunner.run(CallRunner.java:53)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:390)
        at org.apache.phoenix.jdbc.PhoenixStatement.executeMutation(PhoenixStatement.java:378)
        at org.apache.phoenix.jdbc.PhoenixStatement.execute(PhoenixStatement.java:1825)
        at sqlline.Commands.execute(Commands.java:822)
        at sqlline.Commands.sql(Commands.java:732)
        at sqlline.SqlLine.dispatch(SqlLine.java:813)
        at sqlline.SqlLine.begin(SqlLine.java:686)
        at sqlline.SqlLine.start(SqlLine.java:398)
        at sqlline.SqlLine.main(SqlLine.java:291)
```