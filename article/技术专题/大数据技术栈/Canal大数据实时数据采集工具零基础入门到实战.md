---
category: [大数据技术栈]
tag: [Sqoop,大数据,实时,采集]
postType: post
status: publish
---

## 需求

在现代的系统开发中, 为了提高搜索效率 , 以及搜索的精准度, 会大量的使用redis , memcache等nosql系统的数据库 , 以及solr , elasticsearch 类似的全文检索服务; 那么这个时候, 就又有一个问题需要我们来考虑, 就是数据同步的问题, 如何将实时变化的数据库中的数据同步到solr的索引库中或者redis中呢 ?

![image.png](https://image.hyly.net/i/2025/09/28/1831f9dfb234f926ef96dccd9e005359-0.webp)

## 数据同步方案

### 方案一: 业务代码中同步

在增加、修改、删除之后，执行操作solr索引库的逻辑代码。

![image.png](https://image.hyly.net/i/2025/09/28/528657e12808ad1100e228e66c1edc35-0.webp)

优点 : 操作简便

缺点 :

1) 业务耦合度高
2) 执行效率变低

### 方案二: 定时任务同步

在执行完增加、修改、删除，操作数据库中的数据变更之后 ，通过定时任务定时的将数据库的数据同步到solr的索引库中。
定时任务技术 ： SpringTask ， Quartz
优点：同步solr索引库操作与业务代码完全解耦。
缺点：数据的实时性并不高。

### 方案三: 通过MQ实现同步

在执行完增加、修改、删除之后， 往MQ中发送一条消息 ；同步程序作为MQ中的消费者，从消息队列中获取消息，然后执行同步solr索引库的逻辑。

![image.png](https://image.hyly.net/i/2025/09/28/4f770d36d2fe085f4ecff31d2c51397b-0.webp)

![image.png](https://image.hyly.net/i/2025/09/28/8f491a083c61afa97f0a42a59352b714-0.webp)

优点：业务代码解耦， 并且可以做到准实时
缺点：需要在业务代码中加入发送消息到MQ中的代码 ， API耦合

### 方案四: 通过Canal实现实时同步

通过Canal来解析数据库的日志信息， 来检测数据库中表结构的数据变化，从而更新solr索引库。
优点：业务代码完全解耦，API完全解耦，可以做到准实时。
缺点：无

## Canal介绍

阿里巴巴 mysql 数据库 binlog 的增量订阅 & 消费组件。
名称： canal [kə'næl]
译意： 水道 / 管道 / 沟渠
语言： 纯 java 开发
定位： 基于数据库增量日志解析，提供增量数据订阅 & 消费，目前主要支持了 mysql
关键词： mysql binlog parser / real-time / queue&topic

### Canal下载

官网: https://github.com/alibaba/canal
这里我们选择了Canal的1.0.24版本.

![image.png](https://image.hyly.net/i/2025/09/28/b21bca71e017991d32fdcffee38e7005-0.webp)

canal.deployer-1.0.24.tar.gz : 这个是canal Server的部署包
canal.example-1.0.24.tar.gz : 这个是样例
Source code(zip) : 是canal的源码包

## Canal工作原理

### mysql主从同步实现

**原理:**

![image.png](https://image.hyly.net/i/2025/09/28/a243e33f7e3de004f3f875257541d807-0.webp)

从上层来看，主从复制分成三步：

1. master 将改变记录到二进制日志 (binary log) 中（这些记录叫做二进制日志事件， binary log events ，可以通过 show binlog events 进行查看）；
2. slave 将 master 的 binary log events 拷贝到它的中继日志 (relay log);
3. slave 重做中继日志中的事件将改变反映它自己的数据。

### Canal内部原理

原理图:

![image.png](https://image.hyly.net/i/2025/09/28/77986688ea02721955a82ccc6b53d392-0.webp)

原理相对比较简单：

1. canal 模拟 mysql slave 的交互协议，伪装自己为 mysql slave ，向 mysql master 发送 dump 协议。
2. mysql master 收到 dump 请求，开始推送 binary log 给 slave( 也就是 canal) 。
3. canal 解析 binary log 对象 ( 原始为 byte 流 ) 。

### Canal内部结构

![image.png](https://image.hyly.net/i/2025/09/28/e11e91b2b8981d37c7d01e1ed77b9a34-0.webp)

说明：
1)Server : 代表一个canal运行实例，对应于一个jvm
2)Instance : 对应于一个数据队列 （1个server对应1..n个instance)

![image.png](https://image.hyly.net/i/2025/09/28/896e6a2453484c3aa123271b6a05b6b6-0.webp)

instance下的子模块：
eventParser : (数据源接入，模拟slave协议和master进行交互，协议解析)
eventSink   : (Parser和Store链接器，进行数据过滤，加工，分发的工作)
eventStore  : (数据存储)
metaManager : (增量订阅&消费信息管理器)

## Canal环境准备

### Mysql数据库root远程访问

grant all privileges on *.* to 'root' @'%' identified by '2143';
flush privileges;

### Mysql配置

canal 的原理是基于 mysql binlog 技术，所以这里一定需要开启 mysql 的 binlog 写入功能，建议配置 binlog 模式为 row。
查看方式：
SHOW VARIABLES LIKE 'binlog_format' ;

![image.png](https://image.hyly.net/i/2025/09/28/e4dabebe9ee2bfd9f22c6fd60494d5ea-0.webp)

修改配置：

![image.png](https://image.hyly.net/i/2025/09/28/494be8101f75992aba638ae48f20bc52-0.webp)

修改以下配置项：
[mysqld]
log-bin=mysql-bin 	#添加这一行就 ok
binlog_format=ROW    #选择 row 模式
server_id=1 		    #配置mysql replaction需要定义，不能与canal的slaveId重复

![image.png](https://image.hyly.net/i/2025/09/28/ddebef64e36bbbcbee28c03234d7f88d-0.webp)

注 :  修改完成之后 ,  需要重启 Mysql 服务

![image.png](https://image.hyly.net/i/2025/09/28/83e910e3cd27634003b25ebd71d62cd0-0.webp)

```
知识小贴士 :
1)Row
	日志中会记录成每一行数据被修改的形式，然后在 slave 端再对相同的数据进行修改。
	优点：在 row 模式下，bin-log 中可以不记录执行的 SQL 语句的上下文相关的信息，仅仅只需要记录那一条记录被修改了，修改成什么样了。所以 row 的日志内容会非常清楚的记录下每一行数据修改的细节，非常容易理解。而且不会出现某些特定情况下的存储过程或 function ，以及 trigger 的调用和触发无法被正确复制的问题。
2)Statement
每一条会修改数据的 SQL 都会记录到 master 的 bin-log 中。slave 在复制的时候 SQL 进程会解析成和原来 master 端执行过的相同的 SQL 再次执行。
优点：在 statement 模式下，首先就是解决了 row 模式的缺点，不需要记录每一行数据的变化，减少了 bin-log 日志量，节省 I/O 以及存储资源，提高性能。因为他只需要记录在 master 上所执行的语句的细节，以及执行语句时候的上下文的信息。
缺点：在 statement 模式下，由于他是记录的执行语句，所以，为了让这些语句在 slave 端也能正确执行，那么他还必须记录每条语句在执行的时候的一些相关信息，也就是上下文信息，以保证所有语句在 slave 端杯执行的时候能够得到和在 master 端执行时候相同的结果。另外就是，由于 MySQL 现在发展比较快，很多的新功能不断的加入，使 MySQL 的复制遇到了不小的挑战，自然复制的时候涉及到越复杂的内容，bug 也就越容易出现。在 statement 中，目前已经发现的就有不少情况会造成 MySQL 的复制出现问题，主要是修改数据的时候使用了某些特定的函数或者功能的时候会出现，比如：sleep() 函数在有些版本中就不能被正确复制，在存储过程中使用了 last_insert_id() 函数，可能会使 slave 和 master 上得到不一致的 id 等等。由于 row 是基于每一行来记录的变化，所以不会出现类似的问题。
```

### Mysql创建用户授权

canal 的原理是模拟自己为 mysql slave ，所以这里一定需要做为 mysql slave 的相关权限。 创建一个主从同步的账户，并且赋予权限：
CREATE USER canal@'localhost' IDENTIFIED BY 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'localhost';
FLUSH PRIVILEGES;

![image.png](https://image.hyly.net/i/2025/09/28/6c960c276a46ad18785942e81d6701f5-0.webp)

## Canal部署安装

### 上传解压

![image.png](https://image.hyly.net/i/2025/09/28/b4e0d2a9d29b603cfdf986c6afe643ae-0.webp)

解压后的目录如下：

![image.png](https://image.hyly.net/i/2025/09/28/78aa9b6c8cbebefc57f654fddd9f981a-0.webp)

目录介绍：
bin  : 存储的是可执行脚本
conf ：存放canal的配置文件
lib	  ：存放canal的lib目录
logs ：存放的是日志文件

### 配置

编辑canal/conf/example/instance.properties :

```
#################################################
### mysql serverId
canal.instance.mysql.slaveId = 1234

#position info，需要改成自己的数据库信息
canal.instance.master.address = 127.0.0.1:3306
canal.instance.master.journal.name =
canal.instance.master.position =
canal.instance.master.timestamp =

#canal.instance.standby.address =
#canal.instance.standby.journal.name =
#canal.instance.standby.position =
#canal.instance.standby.timestamp =

#username/password，需要改成自己的数据库信息
canal.instance.dbUsername = canal
canal.instance.dbPassword = canal
canal.instance.defaultDatabaseName =canaldb
canal.instance.connectionCharset = UTF-8

#table regex
canal.instance.filter.regex = canaldb\\..*
#################################################
```

选项含义:
1)canal.instance.mysql.slaveId : mysql集群配置中的serverId概念，需要保证和当前mysql集群中id唯一;
2)canal.instance.master.address: mysql主库链接地址;
3)canal.instance.dbUsername : mysql数据库帐号;
4)canal.instance.dbPassword : mysql数据库密码;
5)canal.instance.defaultDatabaseName : mysql链接时默认数据库;
6)canal.instance.connectionCharset : mysql 数据解析编码;
7)canal.instance.filter.regex : mysql 数据解析关注的表，Perl正则表达式.

### 启动/停止

![image.png](https://image.hyly.net/i/2025/09/28/e9f406e4be01a78cbd619c2ca52760fc-0.webp)

1)startup.sh : 启动脚本
2)stop.sh : 停止脚本

## 数据拉取测试

### 官方源码导入

![image.png](https://image.hyly.net/i/2025/09/28/8bd64a12a85aa60abf27e8547cf3f52e-0.webp)

在源码目录中,有一个工程 example , 这个工程中存放的就是一些样例工程.

### 测试类修改

可以通过其中的一个SimpleCanalClientTest类进行测试.

![image.png](https://image.hyly.net/i/2025/09/28/def7dcbef803dc3566e5be85d0cf9832-0.webp)

需要修改CanalServer的IP地址, 及端口号.

### 数据变更测试

#### 创建表

```
创建tb_book表:
CREATE TABLE `tb_book` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` VARCHAR(100) NOT NULL COMMENT '书名',
  `author` VARCHAR(100) DEFAULT NULL COMMENT '作者',
  `publishtime` DATETIME DEFAULT NULL COMMENT '发行日期',
  `price` DOUBLE(10,2) DEFAULT NULL COMMENT '价格',
  `publishgroup` VARCHAR(100) DEFAULT NULL COMMENT '发版社',
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4
```

#### 插入数据

```
执行SQL : 
INSERT INTO tb_book(NAME , author , publishtime , price , publishgroup) VALUES('白帽子讲安全协议','吴瀚请',NOW(),99.00,'电子工业出版社');
INSERT INTO tb_book(NAME , author , publishtime , price , publishgroup) VALUES('白帽子讲安全协议2','吴瀚请',NOW(),99.00,'电子工业出版社');
```

Canal数据监测结果 :

![image.png](https://image.hyly.net/i/2025/09/28/50cb671d7d19ec9b1daa33b08ac7cb2f-0.webp)

#### 更新数据

执行SQL语句:
UPDATE tb_book SET NAME = '白帽子讲安全协议第二版' WHERE id = 2;
Canal数据监测结果:

![image.png](https://image.hyly.net/i/2025/09/28/0f528c17aeee839fcc401d8d4576ffcd-0.webp)

#### 删除数据

执行SQL :
DELETE FROM tb_book WHERE id = 1;
Canal数据监测结果:

![image.png](https://image.hyly.net/i/2025/09/28/2bfab049c366c0c207ebeb859b7a1c40-0.webp)

## 数据同步实现

### 需求描述

将数据库数据的变化, 通过canal解析binlog日志, 实时更新到solr的索引库中.

### Solr环境的搭建

略

### 同步程序

#### 引入依赖

```
<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.client</artifactId>
    <version>1.0.24</version>
</dependency>
<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.protocol</artifactId>
    <version>1.0.24</version>
</dependency>
<dependency>
    <groupId>commons-lang</groupId>
    <artifactId>commons-lang</artifactId>
    <version>2.6</version>
</dependency>
<dependency>
    <groupId>org.codehaus.jackson</groupId>
    <artifactId>jackson-mapper-asl</artifactId>
    <version>1.8.9</version>
</dependency>
<dependency>
    <groupId>org.apache.solr</groupId>
    <artifactId>solr-solrj</artifactId>
    <version>4.10.3</version>
</dependency>
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.9</version>
    <scope>test</scope>
</dependency>
```

#### 定义POJO

```
public class Book {
    private Integer id;
    private String name;
    private String author;
    private Date publishtime;
    private Double price;
    private String publishgroup;
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getAuthor() {
        return author;
    }
    public void setAuthor(String author) {
        this.author = author;
    }
    public Date getPublishtime() {
        return publishtime;
    }
    public void setPublishtime(Date publishtime) {
        this.publishtime = publishtime;
    }
    public Double getPrice() {
        return price;
    }
    public void setPrice(Double price) {
        this.price = price;
    }
    public String getPublishgroup() {
        return publishgroup;
    }
    public void setPublishgroup(String publishgroup) {
        this.publishgroup = publishgroup;
    }
}
```

#### 定义solr的域与pojo属性的映射关系

```
@Field
private Integer id;

@Field("book_name")
private String name;

@Field("book_author")
private String author;

@Field("book_publishtime")
private Date publishtime;

@Field("book_price")
private Double price;

@Field("book_publishgroup")
private String publishgroup;
```

#### 同步程序编写

```
public class CanalPullData {
    private static Logger logger = LoggerFactory.getLogger(CanalPullData.class);

    public static void main(String[] args) throws Exception {
        String destination = "example";
        String hostname = "192.168.142.152";
        Integer port = 11111;

        CanalConnector connector = CanalConnectors.newSingleConnector(
                new InetSocketAddress(hostname, port), destination, "", "");

        connector.connect();
        connector.subscribe();

        logger.info("Canal Server[" + hostname + " : " + port + "] 连接成功");

        Integer batchSize = 5*1024;
        while (true){
            Message message = connector.getWithoutAck(batchSize);
            long messageId = message.getId();
            int size = message.getEntries().size();

            if(messageId == -1 || size == 0){
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                connector.ack(messageId);
            }else{
                logger.info("binlog分析开始");
                List<InnerBinlogEntry> entryList = CanalDataParser.convertToInnerBinlogEntry(message);
                syncDataToSolr(entryList);
                logger.info("检测到修改的Entry数量[size="+entryList.size()+"]");
            }
        }
    }

    private static void syncDataToSolr(List<InnerBinlogEntry> entryList) throws Exception {
        SolrServer solrServer = new HttpSolrServer("http://192.168.142.152:8080/solr");

        if(entryList != null){
            for (InnerBinlogEntry innerBinlogEntry : entryList) {
                Book book = new Book();
                if(innerBinlogEntry.getEventType() == CanalEntry.EventType.INSERT || innerBinlogEntry.getEventType() == CanalEntry.EventType.UPDATE){

                    List<Map<String, BinlogValue>> mapList = innerBinlogEntry.getRows();
                    if(mapList != null){
                        for (Map<String, BinlogValue> valueMap : mapList) {
                            BinlogValue idValue = valueMap.get("id");
                            BinlogValue nameValue = valueMap.get("name");
                            BinlogValue authorValue = valueMap.get("author");
                            BinlogValue publishtimeValue = valueMap.get("publishtime");
                            BinlogValue priceValue = valueMap.get("price");
                            BinlogValue publishgroupValue = valueMap.get("publishgroup");

                            book.setId(Integer.parseInt(idValue.getValue()));
                            book.setName(nameValue.getValue());
                            book.setAuthor(authorValue.getValue());
                            book.setPublishtime(DateUtils.parseDate(publishtimeValue.getValue()));
                            book.setPublishgroup(publishgroupValue.getValue());
                            book.setPrice(Double.parseDouble(priceValue.getValue()));

                            //添加/更新数据到solr索引库
                            logger.info("---------> 添加/更新solr索引库 : " + book);
                            solrServer.addBean(book);
                            solrServer.commit();
                        }
                    }
                }else if(innerBinlogEntry.getEventType() == CanalEntry.EventType.DELETE){
                    List<Map<String, BinlogValue>> rows = innerBinlogEntry.getRows();
                    if(rows != null){
                        for (Map<String, BinlogValue> row : rows) {
                            BinlogValue idValue = row.get("id");
                            String id = idValue.getBeforeValue();

                            //根据ID删除solr索引库的数据
                            logger.info("---------> 删除solr索引库 : " + id);
                            solrServer.deleteById(id);
                            solrServer.commit();
                        }
                    }
                }
            }
        }
    }
}
```

#### 工具类

CanalDataParser	: 用来转换解析从CanalServer中获取的Message对象.

```
public class CanalDataParser {
   protected static final String DATE_FORMAT  = "yyyy-MM-dd HH:mm:ss";
   protected static final String yyyyMMddHHmmss = "yyyyMMddHHmmss";
   protected static final String yyyyMMdd        = "yyyyMMdd";
   protected static final String SEP        = SystemUtils.LINE_SEPARATOR;
   protected static String  context_format     = null;
   protected static String  row_format         = null;
   protected static String  transaction_format = null;
   protected static String row_log = null;
   
   private static Logger logger = LoggerFactory.getLogger(CanalDataParser.class);
   
   static {
        context_format = SEP + "****************************************************" + SEP;
        context_format += "* Batch Id: [{}] ,count : [{}] , memsize : [{}] , Time : {}" + SEP;
        context_format += "* Start : [{}] " + SEP;
        context_format += "* End : [{}] " + SEP;
        context_format += "****************************************************" + SEP;
        row_format = SEP
                     + "----------------> binlog[{}:{}],name[{},{}], eventType:{} , executeTime : {} , delay : {}ms"
                     + SEP;
        transaction_format = SEP + "================> binlog[{}:{}] , executeTime : {} , delay : {}ms" + SEP;
        row_log = "schema[{}], table[{}]";
    }

   public static List<InnerBinlogEntry> convertToInnerBinlogEntry(Message message) {
      List<InnerBinlogEntry> innerBinlogEntryList = new ArrayList<InnerBinlogEntry>();
      if(message == null) {
         logger.info("接收到空的 message; 忽略");
         return innerBinlogEntryList;
      }
  
      long batchId = message.getId();
        int size = message.getEntries().size();
        if (batchId == -1 || size == 0) {
           logger.info("接收到空的message[size=" + size + "]; 忽略");
           return innerBinlogEntryList;
        }

        printLog(message, batchId, size);
        List<Entry> entrys = message.getEntries();
        //输出日志
        for (Entry entry : entrys) {
           long executeTime = entry.getHeader().getExecuteTime();
            long delayTime = new Date().getTime() - executeTime;
     
            if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN || entry.getEntryType() == EntryType.TRANSACTIONEND) {
                if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN) {
                    TransactionBegin begin = null;
                    try {
                        begin = TransactionBegin.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务头信息，执行的线程id，事务耗时
                    logger.info("BEGIN ----> Thread id: {}",  begin.getThreadId());
                    logger.info(transaction_format, new Object[] {entry.getHeader().getLogfileName(),
                                String.valueOf(entry.getHeader().getLogfileOffset()), String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });

                } else if (entry.getEntryType() == EntryType.TRANSACTIONEND) {
                    TransactionEnd end = null;
                    try {
                        end = TransactionEnd.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务提交信息，事务id
                    logger.info("END ----> transaction id: {}", end.getTransactionId());
                    logger.info(transaction_format,
                        new Object[] {entry.getHeader().getLogfileName(),  String.valueOf(entry.getHeader().getLogfileOffset()),
                                String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });
                }
                continue;
            }
            //解析结果
            if (entry.getEntryType() == EntryType.ROWDATA) {
                RowChange rowChage = null;
                try {
                    rowChage = RowChange.parseFrom(entry.getStoreValue());
                } catch (Exception e) {
                    throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                }
                EventType eventType = rowChage.getEventType();

                logger.info(row_format, new Object[] { entry.getHeader().getLogfileName(),
                            String.valueOf(entry.getHeader().getLogfileOffset()), entry.getHeader().getSchemaName(),
                            entry.getHeader().getTableName(), eventType, String.valueOf(entry.getHeader().getExecuteTime()), String.valueOf(delayTime) });
                //组装数据结果
                if (eventType == EventType.INSERT || eventType == EventType.DELETE || eventType == EventType.UPDATE) {
                   String schemaName = entry.getHeader().getSchemaName();
                   String tableName = entry.getHeader().getTableName();
                   List<Map<String, BinlogValue>> rows = parseEntry(entry);

                   InnerBinlogEntry innerBinlogEntry = new InnerBinlogEntry();
                   innerBinlogEntry.setEntry(entry);
                   innerBinlogEntry.setEventType(eventType);
                   innerBinlogEntry.setSchemaName(schemaName);
                   innerBinlogEntry.setTableName(tableName.toLowerCase());
                   innerBinlogEntry.setRows(rows);

                   innerBinlogEntryList.add(innerBinlogEntry);
                } else {
                   logger.info(" 存在 INSERT INSERT UPDATE 操作之外的SQL [" + eventType.toString() + "]");
                }
                continue;
            }
        }
      return innerBinlogEntryList;
   }

   private static List<Map<String, BinlogValue>> parseEntry(Entry entry) {
      List<Map<String, BinlogValue>> rows = new ArrayList<Map<String, BinlogValue>>();
      try {
         String schemaName = entry.getHeader().getSchemaName();
           String tableName = entry.getHeader().getTableName();
         RowChange rowChage = RowChange.parseFrom(entry.getStoreValue());
         EventType eventType = rowChage.getEventType();

         // 处理每个Entry中的每行数据
         for (RowData rowData : rowChage.getRowDatasList()) {
            StringBuilder rowlog = new StringBuilder("rowlog schema[" + schemaName + "], table[" + tableName + "], event[" + eventType.toString() + "]");
      
            Map<String, BinlogValue> row = new HashMap<String, BinlogValue>();
            List<Column> beforeColumns = rowData.getBeforeColumnsList();
            List<Column> afterColumns = rowData.getAfterColumnsList();
            beforeColumns = rowData.getBeforeColumnsList();
             if (eventType == EventType.DELETE) {//delete
                for(Column column : beforeColumns) {
                   BinlogValue binlogValue = new BinlogValue();
                   binlogValue.setValue(column.getValue());
                   binlogValue.setBeforeValue(column.getValue());
                   row.put(column.getName(), binlogValue);
                }
             } else if(eventType == EventType.UPDATE) {//update
                for(Column column : beforeColumns) {
                   BinlogValue binlogValue = new BinlogValue();
                   binlogValue.setBeforeValue(column.getValue());
                   row.put(column.getName(), binlogValue);
                }
                for(Column column : afterColumns) {
                   BinlogValue binlogValue = row.get(column.getName());
                   if(binlogValue == null) {
                      binlogValue = new BinlogValue();
                   }
                   binlogValue.setValue(column.getValue());
                   row.put(column.getName(), binlogValue);
                }
             } else { // insert
                for(Column column : afterColumns) {
                   BinlogValue binlogValue = new BinlogValue();
                   binlogValue.setValue(column.getValue());
                   binlogValue.setBeforeValue(column.getValue());
                   row.put(column.getName(), binlogValue);
                }
             } 
             rows.add(row);
             String rowjson = JacksonUtil.obj2str(row);
       
             logger.info("############################ Data Parse Result ###########################");
             logger.info(rowlog + " , " + rowjson);
             logger.info("############################ Data Parse Result ###########################");
             logger.info("");
         }
      } catch (InvalidProtocolBufferException e) {
         throw new RuntimeException("parseEntry has an error , data:" + entry.toString(), e);
      }
        return rows;
   }

   private static void printLog(Message message, long batchId, int size) {
        long memsize = 0;
        for (Entry entry : message.getEntries()) {
            memsize += entry.getHeader().getEventLength();
        }

        String startPosition = null;
        String endPosition = null;
        if (!CollectionUtils.isEmpty(message.getEntries())) {
            startPosition = buildPositionForDump(message.getEntries().get(0));
            endPosition = buildPositionForDump(message.getEntries().get(message.getEntries().size() - 1));
        }

        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        logger.info(context_format, new Object[] {batchId, size, memsize, format.format(new Date()), startPosition, endPosition });
    }

   private static String buildPositionForDump(Entry entry) {
        long time = entry.getHeader().getExecuteTime();
        Date date = new Date(time);
        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        return entry.getHeader().getLogfileName() + ":" + entry.getHeader().getLogfileOffset() + ":" + entry.getHeader().getExecuteTime() + "(" + format.format(date) + ")";
    }
}
```

InnerBinlogEntry	: 用于封装解析后的数据对象 , 包含操作的是哪个数据库,那张表,操作类型,及本次操作的结果集.

```
public class InnerBinlogEntry {
   /**
    * canal原生的Entry
    */
   private Entry entry;
   /**
    * 该Entry归属于的表名
    */
   private String tableName;
   /**
    * 该Entry归属数据库名
    */
   private String schemaName;
   /**
    * 该Entry本次的操作类型，对应canal原生的枚举；EventType.INSERT; EventType.UPDATE; EventType.DELETE;
    */
   private EventType eventType;
   private List<Map<String, BinlogValue>> rows = new ArrayList<Map<String, BinlogValue>>();
  
   public Entry getEntry() {
      return entry;
   }
   public void setEntry(Entry entry) {
      this.entry = entry;
   }
   public String getTableName() {
      return tableName;
   }
   public void setTableName(String tableName) {
      this.tableName = tableName;
   }
   public EventType getEventType() {
      return eventType;
   }
   public void setEventType(EventType eventType) {
      this.eventType = eventType;
   }
   public String getSchemaName() {
      return schemaName;
   }
   public void setSchemaName(String schemaName) {
      this.schemaName = schemaName;
   }
   public List<Map<String, BinlogValue>> getRows() {
      return rows;
   }
   public void setRows(List<Map<String, BinlogValue>> rows) {
      this.rows = rows;
   }
}
```

BinlogValue       : binlog分析的每行每列的value值

```
public class BinlogValue implements Serializable {

   private static final long serialVersionUID = -6350345408773943086L;
   
   private String value;
   private String beforeValue;
   /**
    * binlog分析的每行每列的value值；<br>
    * 新增数据： value：为现有值；<br>
    * 修改数据：value为修改后的值；<br>
    * 删除数据：value是删除前的值； 这个比较特殊主要是为了删除数据时方便获取删除前的值<br>
    */
   public String getValue() {
      return value;
   }
   public void setValue(String value) {
      this.value = value;
   }
   /**
    * binlog分析的每行每列的beforeValue值；<br>
    * 新增数据：beforeValue为现有值；<br>
    * 修改数据：beforeValue是修改前的值；<br>
    * 删除数据：beforeValue为删除前的值； <br>
    *
    */
   public String getBeforeValue() {
      return beforeValue;
   }
   public void setBeforeValue(String beforeValue) {
      this.beforeValue = beforeValue;
   }
}
```

DateUtils	: 时间处理工具类

```
public class DateUtils {
   
   private static final String FORMAT_PATTERN = "yyyy-MM-dd HH:mm:ss";
   
   private static SimpleDateFormat sdf = new SimpleDateFormat(FORMAT_PATTERN);
   
   public static Date parseDate(String datetime) throws ParseException{
      if(datetime != null && !"".equals(datetime)){
         return sdf.parse(datetime);
      }
      return null;
   }
   
   public static String formatDate(Date datetime) throws ParseException{
      if(datetime != null ){
         return sdf.format(datetime);
      }
      return null;
   }
   
   public static Long formatStringDateToLong(String datetime) throws ParseException{
      if(datetime != null && !"".equals(datetime)){
         Date d =  sdf.parse(datetime);
         return d.getTime();
      }
      return null;
   }
   
   public static Long formatDateToLong(Date datetime) throws ParseException{
      if(datetime != null){
         return datetime.getTime();
      }
      return null;
   }
}
```

JacksonUtil       : json处理工具类

```
public class JacksonUtil {
    private static ObjectMapper mapper = new ObjectMapper();

    public static String obj2str(Object obj) {
        String json = null;
        try {
            json = mapper.writeValueAsString(obj);
        } catch (JsonGenerationException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return json;
    }

    public static <T> T str2obj(String content, Class<T> valueType) {
        try {
            return mapper.readValue(content, valueType);
        } catch (JsonParseException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

#### 测试结果

![image.png](https://image.hyly.net/i/2025/09/28/7ff489bd7fa06d55ee5630db6b0f5b78-0.webp)

更新数据库中表结构数据的变化, 可以实时的更新solr的索引库.

## 配置文件详解

**canal.properties  (系统根配置文件)**

<figure class='table-figure'><table>
<thead>
<tr><th>参数名字</th><th>参数说明</th><th>默认值</th></tr></thead>
<tbody><tr><td>canal.id</td><td>每个canal server实例的唯一标识，暂无实际意义</td><td>1</td></tr><tr><td>canal.ip</td><td>canal server绑定的本地IP信息，如果不配置，默认选择一个本机IP进行启动服务</td><td>无</td></tr><tr><td>canal.port</td><td>canal server提供socket服务的端口</td><td>11111</td></tr><tr><td>canal.zkServers</td><td>canal server链接zookeeper集群的链接信息&#x3c;br/&gt;例子：10.20.144.22:2181,10.20.144.51:2181</td><td>无</td></tr><tr><td>canal.zookeeper.flush.period</td><td>canal持久化数据到zookeeper上的更新频率，单位毫秒</td><td>1000</td></tr><tr><td>canal.instance.memory.batch.mode</td><td>canal内存store中数据缓存模式&#x3c;br/&gt;1. ITEMSIZE :根据buffer.size进行限制，只限制记录的数量&#x3c;br/&gt;2. MEMSIZE :根据buffer.size  * buffer.memunit的大小，限制缓存记录的大小</td><td>MEMSIZE</td></tr><tr><td>canal.instance.memory.buffer.size</td><td>canal内存store中可缓存buffer记录数，需要为2的指数</td><td>16384</td></tr><tr><td>canal.instance.memory.buffer.memunit</td><td>内存记录的单位大小，默认1KB，和buffer.size组合决定最终的内存使用大小</td><td>1024</td></tr><tr><td>canal.instance.transactionn.size</td><td>最大事务完整解析的长度支持&#x3c;br/&gt;超过该长度后，一个事务可能会被拆分成多次提交到canal store中，无法保证事务的完整可见性</td><td>1024</td></tr><tr><td>canal.instance.fallbackIntervalInSeconds</td><td>canal发生mysql切换时，在新的mysql库上查找binlog时需要往前查找的时间，单位秒&#x3c;br/&gt;说明：mysql主备库可能存在解析延迟或者时钟不统一，需要回退一段时间，保证数据不丢</td><td>60</td></tr><tr><td>canal.instance.detecting.enable</td><td>是否开启心跳检查</td><td>false</td></tr><tr><td>canal.instance.detecting.sql</td><td>心跳检查sql</td><td>insert into retl.xdual values(1,now()) on duplicate key update x=now()</td></tr><tr><td>canal.instance.detecting.interval.time</td><td>心跳检查频率，单位秒</td><td>3</td></tr><tr><td>canal.instance.detecting.retry.threshold</td><td>心跳检查失败重试次数</td><td>3</td></tr><tr><td>canal.instance.detecting.heartbeatHaEnable</td><td>心跳检查失败后，是否开启自动mysql自动切换&#x3c;br/&gt;说明：比如心跳检查失败超过阀值后，如果该配置为true，canal就会自动链到mysql备库获取binlog数据</td><td>false</td></tr><tr><td>canal.instance.network.receiveBufferSize</td><td>网络链接参数，SocketOptions.SO_RCVBUF</td><td>16384</td></tr><tr><td>canal.instance.network.sendBufferSize</td><td>网络链接参数，SocketOptions.SO_SNDBUF</td><td>16384</td></tr><tr><td>canal.instance.network.soTimeout</td><td>网络链接参数，SocketOptions.SO_TIMEOUT</td><td>30</td></tr><tr><td>canal.instance.filter.druid.ddl</td><td>是否使用druid处理所有的ddl解析来获取库和表名</td><td>true</td></tr><tr><td>canal.instance.filter.query.dcl</td><td>是否忽略dcl语句</td><td>false</td></tr><tr><td>canal.instance.filter.query.dml</td><td>是否忽略dml语句&#x3c;br/&gt;(mysql5.6之后，在row模式下每条DML语句也会记录SQL到binlog中,可参考<a href='#sysvar_binlog_rows_query_log_events'>MySQL文档</a>)</td><td>false</td></tr><tr><td>canal.instance.filter.query.ddl</td><td>是否忽略ddl语句</td><td>false</td></tr><tr><td>canal.instance.filter.table.error</td><td>是否忽略binlog表结构获取失败的异常(主要解决回溯binlog时,对应表已被删除或者表结构和binlog不一致的情况)</td><td>false</td></tr><tr><td>canal.instance.filter.rows</td><td>是否dml的数据变更事件(主要针对用户只订阅ddl/dcl的操作)</td><td>false</td></tr><tr><td>canal.instance.filter.transaction.entry</td><td>是否忽略事务头和尾,比如针对写入kakfa的消息时，不需要写入TransactionBegin/Transactionend事件</td><td>false</td></tr><tr><td>canal.instance.binlog.format</td><td>支持的binlog format格式列表&#x3c;br/&gt;(otter会有支持format格式限制)</td><td>ROW,STATEMENT,MIXED</td></tr><tr><td>canal.instance.binlog.image</td><td>支持的binlog image格式列表&#x3c;br/&gt;(otter会有支持format格式限制)</td><td>FULL,MINIMAL,NOBLOB</td></tr><tr><td>canal.instance.get.ddl.isolation</td><td>ddl语句是否单独一个batch返回(比如下游dml/ddl如果做batch内无序并发处理,会导致结构不一致)</td><td>false</td></tr><tr><td>canal.instance.parser.parallel</td><td>是否开启binlog并行解析模式(串行解析资源占用少,但性能有瓶颈, 并行解析可以提升近2.5倍+)</td><td>true</td></tr><tr><td>canal.instance.parser.parallelBufferSize</td><td>binlog并行解析的异步ringbuffer队列&#x3c;br/&gt;(必须为2的指数)</td><td>256</td></tr><tr><td>canal.instance.tsdb.enable</td><td>是否开启tablemeta的tsdb能力</td><td>true</td></tr><tr><td>canal.instance.tsdb.dir</td><td>主要针对h2-tsdb.xml时对应h2文件的存放目录,默认为conf/xx/h2.mv.db</td><td>${canal.file.data.dir:../conf}/${canal.instance.destination:}</td></tr><tr><td>canal.instance.tsdb.url</td><td>jdbc url的配置(h2的地址为默认值，如果是mysql需要自行定义)</td><td>jdbc:h2:${canal.instance.tsdb.dir}/h2;CACHE_SIZE=1000;MODE=MYSQL;</td></tr><tr><td>canal.instance.tsdb.dbUsername</td><td>jdbc url的配置(h2的地址为默认值，如果是mysql需要自行定义)</td><td>canal</td></tr><tr><td>canal.instance.tsdb.dbPassword</td><td>jdbc url的配置(h2的地址为默认值，如果是mysql需要自行定义)</td><td>canal</td></tr><tr><td>canal.instance.rds.accesskey</td><td>aliyun账号的ak信息 (如果不需要在本地binlog超过18小时被清理后自动下载oss上的binlog，可以忽略该值)</td><td>无</td></tr><tr><td>canal.instance.rds.secretkey</td><td>aliyun账号的sk信息(如果不需要在本地binlog超过18小时被清理后自动下载oss上的binlog，可以忽略该值)</td><td>无</td></tr></tbody>
</table></figure>

**instance.properties  (instance级别的配置文件，每个instance一份)**

<figure class='table-figure'><table>
<thead>
<tr><th>参数名字</th><th>参数说明</th><th>默认值</th></tr></thead>
<tbody><tr><td>canal.instance.mysql.slaveId</td><td>mysql集群配置中的serverId概念，需要保证和当前mysql集群中id唯一&#x3c;br/&gt;(v1.1.x版本之后canal会自动生成，不需要手工指定)</td><td>无</td></tr><tr><td>canal.instance.master.address</td><td>mysql主库链接地址</td><td>127.0.0.1:3306</td></tr><tr><td>canal.instance.master.journal.name</td><td>mysql主库链接时起始的binlog文件</td><td>无</td></tr><tr><td>canal.instance.master.position</td><td>mysql主库链接时起始的binlog偏移量</td><td>无</td></tr><tr><td>canal.instance.master.timestamp</td><td>mysql主库链接时起始的binlog的时间戳</td><td>无</td></tr><tr><td>canal.instance.gtidon</td><td>是否启用mysql gtid的订阅模式</td><td>false</td></tr><tr><td>canal.instance.master.gtid</td><td>mysql主库链接时对应的gtid位点</td><td>无</td></tr><tr><td>canal.instance.dbUsername</td><td>mysql数据库帐号</td><td>canal</td></tr><tr><td>canal.instance.dbPassword</td><td>mysql数据库密码</td><td>canal</td></tr><tr><td>canal.instance.defaultDatabaseName</td><td>mysql链接时默认schema</td><td>&nbsp;</td></tr><tr><td>canal.instance.connectionCharset</td><td>mysql数据解析编码</td><td>UTF-8</td></tr><tr><td>canal.instance.filter.regex</td><td>mysql数据解析关注的表，Perl正则表达式.多个正则之间以逗号(,)分隔，转义符需要双斜杠(\)&#x3c;br/&gt;常见例子：1.所有表：.*   or  .<em>\..</em>&#x3c;br/&gt;2.  canal schema下所有表： canal\..<em>&#x3c;br/&gt;3.  canal下的以canal打头的表：canal\.canal.</em>&#x3c;br/&gt;4.  canal schema下的一张表：canal.test15.多个规则组合使用：canal\..*,mysql.test1,mysql.test2 (逗号分隔)</td><td>.<em>\..</em></td></tr><tr><td>canal.instance.filter.black.regex</td><td>mysql数据解析表的黑名单，表达式规则见白名单的规则</td><td>无</td></tr><tr><td>canal.instance.rds.instanceId</td><td>aliyun rds对应的实例id信息(如果不需要在本地binlog超过18小时被清理后自动下载oss上的binlog，可以忽略该值)</td><td>无</td></tr></tbody>
</table></figure>
