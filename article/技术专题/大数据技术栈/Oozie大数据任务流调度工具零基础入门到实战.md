---
category: [大数据技术栈]
tag: [Oozie,大数据,任务流调度]
postType: post
status: publish
---

## Apache Oozie

### Oozie概述

Oozie 是一个用来管理Hadoop生态圈job的工作流调度系统。由Cloudera公司贡献给Apache。Oozie是运行于Java servlet容器上的一个java web应用。Oozie的目的是按照DAG（有向无环图）调度一系列的Map/Reduce或者Hive等任务。Oozie 工作流由hPDL（Hadoop Process Definition Language）定义（这是一种XML流程定义语言）。适用场景包括：

需要按顺序进行一系列任务；

需要并行处理的任务；

需要定时、周期触发的任务；

可视化作业流运行过程；

运行结果或异常的通报。

![image.png](https://image.hyly.net/i/2025/09/26/2b0f93d71449478baefde8c437d0fc25-0.webp)

### Oozie的架构

![image.png](https://image.hyly.net/i/2025/09/26/3d6e4642da67844cdd99650bb9e7f5f0-0.webp)

**Oozie**  Client   ：提供命令行、java api、rest等方式，对Oozie的工作流流程的提交、启动、运行等操作；

**Oozie**  WebApp  ：即Oozie Server,本质是一个java应用。可以使用内置的web容器，也可以使用外置的web容器；

**Hadoop**  Cluster  ：底层执行Oozie编排流程的各个hadoop生态圈组件；

### Oozie基本原理

Oozie对工作流的编排，是基于workflow.xml文件来完成的。用户预先将工作流执行规则定制于workflow.xml文件中，并在job.properties配置相关的参数，然后由Oozie Server向MR提交job来启动工作流。

#### 流程节点

工作流由两种类型的节点组成，分别是：

**Control** ** Flow Nodes** ：控制工作流执行路径，包括start，end，kill，decision，fork,join。

**Action** ** Nodes** ：决定每个操作执行的任务类型，包括MapReduce、java、hive、shell等。

![image.png](https://image.hyly.net/i/2025/09/26/0e09375cbd49a33b948bc75cda0270f3-0.webp)

### Oozie工作流类型

#### WorkFlow

规则相对简单，不涉及定时、批处理的工作流。顺序执行流程节点。

Workflow有个大缺点：没有定时和条件触发功能。

![image.png](https://image.hyly.net/i/2025/09/26/c40e35020251a58c88b0c831a76f20c7-0.webp)

#### Coordinator

Coordinator将多个工作流Job组织起来，称为Coordinator Job，并指定触发时间和频率，还可以配置数据集、并发数等，类似于在工作流外部增加了一个协调器来管理这些工作流的工作流Job的运行。

![image.png](https://image.hyly.net/i/2025/09/26/82b14164af9ece3ab449e99bdbf4f427-0.webp)

#### Bundle

针对coordinator的批处理工作流。Bundle将多个Coordinator管理起来，这样我们只需要一个Bundle提交即可。

![image.png](https://image.hyly.net/i/2025/09/26/5eb7fa7661299400fde4b9be9851d5d8-0.webp)

## Apache Oozie安装

### 修改hadoop相关配置

#### 配置httpfs服务

修改hadoop的配置文件 **core-site.xml**

```
<property>
        <name>hadoop.proxyuser.root.hosts</name>
        <value>*</value>
</property>
<property>
        <name>hadoop.proxyuser.root.groups</name>
        <value>*</value>
</property>
```

**hadoop.proxyuser.root.hosts** 允许通过httpfs方式访问hdfs的主机名、域名；

**hadoop.proxyuser.root.groups**允许访问的客户端的用户组

#### 配置jobhistory服务

修改hadoop的配置文件**mapred-site.xml**

```
<property>
  <name>mapreduce.jobhistory.address</name>
  <value>node-1:10020</value>
  <description>MapReduce JobHistory Server IPC host:port</description>
</property>

<property>
  <name>mapreduce.jobhistory.webapp.address</name>
  <value>node-1:19888</value>
  <description>MapReduce JobHistory Server Web UI host:port</description>
</property>
<!-- 配置运行过的日志存放在hdfs上的存放路径 -->
<property>
    <name>mapreduce.jobhistory.done-dir</name>
    <value>/export/data/history/done</value>
</property>

<!-- 配置正在运行中的日志在hdfs上的存放路径 -->
<property>
    <name>mapreduce.jobhistory.intermediate-done-dir</name>
    <value>/export/data/history/done_intermediate</value>
</property>
```

启动history-server

mr-jobhistory-daemon.sh start historyserver

停止history-server

mr-jobhistory-daemon.sh stop historyserver

通过浏览器访问Hadoop Jobhistory的WEBUI

**http://**  **node** **-1:19888**

#### 重启Hadoop集群相关服务

### 上传oozie的安装包并解压

oozie的安装包上传到/export/softwares

**tar -zxvf oozie-4.1.0-cdh5.14.0.tar.gz**

解压hadooplibs到与oozie平行的目录

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**tar -zxvf oozie-hadooplibs-4.1.0-cdh5.14.0.tar.gz -C ../**

### 添加相关依赖

oozie的安装路径下创建libext目录

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**mkdir -p libext**

拷贝hadoop依赖包到libext

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**cp -ra hadooplibs/hadooplib-2.6.0-cdh5.14.0.oozie-4.1.0-cdh5.14.0/* libext/**

上传mysql的驱动包到libext

**mysql-connector-java-5.1.32.jar**

添加ext-2.2.zip压缩包到libext

**ext-2.2.zip**

### 修改oozie-site.xml

**cd /export/servers/oozie-4.1.0-cdh5.14.0/conf**

**vim oozie-site.xml**

oozie默认使用的是UTC的时区，需要在oozie-site.xml当中配置时区为**GMT+0800时区**

```
	<property>
        <name>oozie.service.JPAService.jdbc.driver</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
	<property>
        <name>oozie.service.JPAService.jdbc.url</name>
        <value>jdbc:mysql://node-1:3306/oozie</value>
    </property>
	<property>
		<name>oozie.service.JPAService.jdbc.username</name>
		<value>root</value>
	</property>
    <property>
        <name>oozie.service.JPAService.jdbc.password</name>
        <value>hadoop</value>
    </property>
	<property>
			<name>oozie.processing.timezone</name>
			<value>GMT+0800</value>
	</property>

	<property>
        <name>oozie.service.coord.check.maximum.frequency</name>
		<value>false</value>
    </property>   

	<property>
		<name>oozie.service.HadoopAccessorService.hadoop.configurations</name>
        <value>*=/export/servers/hadoop-2.7.5/etc/hadoop</value>
    </property>
```

### 初始化mysql相关信息

上传oozie的解压后目录的下的yarn.tar.gz到hdfs目录

**bin/oozie-setup.sh  sharelib create -fs hdfs://node**-**1:9000 -locallib oozie-sharelib-4.1.0-cdh5.14.0-yarn.tar.gz**

本质上就是将这些jar包解压到了hdfs上面的路径下面去

![image.png](https://image.hyly.net/i/2025/09/26/8db75a552947c9198332172ab3515a71-0.webp)

创建mysql数据库

**mysql -uroot -p**

**create database oozie;**

初始化创建oozie的数据库表

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie-setup.sh  db create -run -sqlfile oozie.sql**

![image.png](https://image.hyly.net/i/2025/09/26/e44e95d03bf72a761557d2c3e2f21fe6-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/6014eca6b83016fa7c38fb9f34346b38-0.webp)

### 打包项目，生成war包

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie-setup.sh  prepare-war**

![image.png](https://image.hyly.net/i/2025/09/26/ff2c48c9e814a18dd21353d19c8f9d90-0.webp)

### 配置oozie环境变量

**vim /etc/profile**

**export OOZIE_HOME=/export/servers/oozie-4.1.0-cdh5.14.0**

**export OOZIE_URL=http://node03.hadoop.com:11000/oozie**

**export PATH=$PATH:$OOZIE_HOME/bin**

**source /etc/profile**

### 启动关闭oozie服务

启动命令

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozied.sh start**

关闭命令

**bin/oozied.sh stop**

![image.png](https://image.hyly.net/i/2025/09/26/291f1c69d35c65eb9e5767115d189ea0-0.webp)

启动的时候产生的 pid文件，如果是kill方式关闭进程 则需要删除该文件重新启动，否则再次启动会报错。

### 浏览器web UI页面

[http://node-1:11000/oozie/](http://node-1:11000/oozie/)

![image.png](https://image.hyly.net/i/2025/09/26/d5a8589e84e641720626e39e4af439b1-0.webp)

### 解决oozie页面时区显示异常

页面访问的时候，发现oozie使用的还是GMT的时区，与我们现在的时区相差一定的时间，所以需要调整一个js的获取时区的方法，将其改成我们现在的时区。

![image.png](https://image.hyly.net/i/2025/09/26/1ea4f45bce655f346e637296c84d5b9b-0.webp)

修改js当中的时区问题

**cd  oozie-server/webapps/oozie**

**vim oozie-console.js**

```
function getTimeZone() {
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    return Ext.state.Manager.get("TimezoneId","GMT+0800");
}
```

重启oozie即可

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozied.sh stop**

**bin/oozied.sh start**

## Apache Oozie实战

oozie安装好了之后，需要测试oozie的功能是否完整好使，官方已经给自带带了各种测试案例，可以通过官方提供的各种案例来学习oozie的使用，后续也可以把这些案例作为模板在企业实际中使用。

先把官方提供的各种案例给解压出来

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**tar -zxvf oozie-examples.tar.gz**

创建统一的工作目录，便于集中管理oozie。企业中可任意指定路径。这里直接在oozie的安装目录下面创建工作目录

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**mkdir oozie_works**

### 优化更新hadoop相关配置

#### yarn容器资源分配属性

**yarn-site.xml** **：**

```
<!—节点最大可用内存，结合实际物理内存调整 -->
<property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>3072</value>
</property>
<!—每个容器可以申请内存资源的最小值，最大值 -->
<property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
</property>
<property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>3072</value>
</property>

<!—修改为Fair公平调度，动态调整资源，避免yarn上任务等待（多线程执行） -->
<property>
 <name>yarn.resourcemanager.scheduler.class</name>
 <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
</property>
<!—Fair调度时候是否开启抢占功能 -->
<property>
        <name>yarn.scheduler.fair.preemption</name>
        <value>true</value>
</property>
<!—超过多少开始抢占，默认0.8-->
    <property>
        <name>yarn.scheduler.fair.preemption.cluster-utilization-threshold</name>
        <value>1.0</value>
    </property>
```

#### mapreduce资源申请配置

设置mapreduce.map.memory.mb和mapreduce.reduce.memory.mb配置

否则Oozie读取的默认配置 -1, 提交给yarn的时候会抛异常*Invalid resource request, requested memory &#x3c; 0, or requested memory > max configured, requestedMemory=-1, maxMemory=8192*

**mapred-site.xml**

```
<!—单个maptask、reducetask可申请内存大小 -->
<property>
        <name>mapreduce.map.memory.mb</name>
        <value>1024</value>
</property>
<property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>1024</value>
</property>
```

#### 更新hadoop配置重启集群

重启hadoop集群

![image.png](https://image.hyly.net/i/2025/09/26/7a7d038d2c1725f9eb3c96e6416b48ec-0.webp)

重启oozie服务

### Oozie调度shell脚本

#### 准备配置模板

把shell的任务模板拷贝到oozie的工作目录当中去

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**cp -r examples/apps/shell/ oozie_works/**

准备待调度的shell脚本文件

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**vim oozie_works/shell/hello.sh**

**注意** ：这个脚本一定要是在我们oozie工作路径下的shell路径下的位置

#!/bin/bash

echo "hello world" >> /export/servers/hello_oozie.txt

#### 修改配置模板

修改job.properties

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/shell**

**vim job.properties**

```
nameNode=hdfs://node-1:8020
jobTracker=node-1:8032
queueName=default
examplesRoot=oozie_works
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/shell
EXEC=hello.sh
```

**jobTracker** ：在hadoop2当中，jobTracker这种角色已经没有了，只有resourceManager，这里给定resourceManager的IP及端口即可。

**queueName** ：提交mr任务的队列名；

**examplesRoot** ：指定oozie的工作目录；

**oozie.wf.application.path** ：指定oozie调度资源存储于hdfs的工作路径；

**EXEC** ：指定执行任务的名称。

修改workflow.xml

```
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-wf">
<start to="shell-node"/>
<action name="shell-node">
    <shell xmlns="uri:oozie:shell-action:0.2">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <configuration>
            <property>
                <name>mapred.job.queue.name</name>
                <value>${queueName}</value>
            </property>
        </configuration>
        <exec>${EXEC}</exec>
        <file>/user/root/oozie_works/shell/${EXEC}#${EXEC}</file>
        <capture-output/>
    </shell>
    <ok to="end"/>
    <error to="fail"/>
</action>
<decision name="check-output">
    <switch>
        <case to="end">
            ${wf:actionData('shell-node')['my_output'] eq 'Hello Oozie'}
        </case>
        <default to="fail-output"/>
    </switch>
</decision>
<kill name="fail">
    <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
</kill>
<kill name="fail-output">
    <message>Incorrect output, expected [Hello Oozie] but was [${wf:actionData('shell-node')['my_output']}]</message>
</kill>
<end name="end"/>
</workflow-app>
```

#### 上传调度任务到hdfs

注意：上传的hdfs目录为/user/root，因为hadoop启动的时候使用的是root用户，如果hadoop启动的是其他用户，那么就上传到/user/其他用户

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**hdfs dfs -put oozie_works/ /user/root**

#### 执行调度任务

通过oozie的命令来执行调度任务

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie job -oozie http://node**-**1:11000/oozie -config oozie_works/shell/job.properties  -run**

从监控界面可以看到任务执行成功了。

![image.png](https://image.hyly.net/i/2025/09/26/33c2996046ac7a953d8b8d679a105428-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/7ead76c5fc1ff1f88bbb554f02ed02b1-0.webp)

可以通过jobhistory来确定调度时候是由那台机器执行的。

![image.png](https://image.hyly.net/i/2025/09/26/c00f4551b7e735f643e664ca7be02bad-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/235ea0809b647e704126b1527923d887-0.webp)

### Oozie调度Hive

#### 准备配置模板

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**cp -ra examples/apps/hive2/ oozie_works/**

#### 修改配置模板

修改job.properties

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/hive2**

**vim job.properties**

```
nameNode=hdfs://node-1:8020
jobTracker=node-1:8032
queueName=default
jdbcURL=jdbc:hive2://node-1:10000/default
examplesRoot=oozie_works

oozie.use.system.libpath=true
# 配置我们文件上传到hdfs的保存路径 实际上就是在hdfs 的/user/root/oozie_works/hive2这个路径下
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/hive2
```

修改workflow.xml（实际上无修改）

```
<?xml version="1.0" encoding="UTF-8"?>
<workflow-app xmlns="uri:oozie:workflow:0.5" name="hive2-wf">
    <start to="hive2-node"/>

    <action name="hive2-node">
        <hive2 xmlns="uri:oozie:hive2-action:0.1">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
                <delete path="${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/hive2"/>
                <mkdir path="${nameNode}/user/${wf:user()}/${examplesRoot}/output-data"/>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
            <jdbc-url>${jdbcURL}</jdbc-url>
            <script>script.q</script>
            <param>INPUT=/user/${wf:user()}/${examplesRoot}/input-data/table</param>
            <param>OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/hive2</param>
        </hive2>
        <ok to="end"/>
        <error to="fail"/>
    </action>

    <kill name="fail">
        <message>Hive2 (Beeline) action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

编辑hivesql文件

**vim script.q**

```
DROP TABLE IF EXISTS test;
CREATE EXTERNAL TABLE test (a INT) STORED AS TEXTFILE LOCATION '${INPUT}';
insert into test values(10);
insert into test values(20);
insert into test values(30);
```

#### 上传调度任务到hdfs

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**hdfs dfs -put hive2/ /user/root/oozie_works/**

#### 执行调度任务

首先确保已经启动hiveServer2服务。

![image.png](https://image.hyly.net/i/2025/09/26/b15719793cd9c7838484a2c1ec2397e7-0.webp)

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie job -oozie http://node**-**1:11000/oozie -config oozie_works/hive2/job.properties  -run**

可以在yarn上看到调度执行的过程:

![image.png](https://image.hyly.net/i/2025/09/26/de91578ebd51727b0b713eec2ad38c90-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/66162d361d784e60ddbc120bdd1dbdac-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/8b2f32c95f3788fa9cdd70d7eee4208d-0.webp)

### Oozie调度MapReduce

#### 准备配置模板

准备mr程序的待处理数据。用hadoop自带的MR程序来运行wordcount。

准备数据上传到HDFS的/oozie/input路径下去

**hdfs dfs -mkdir -p /oozie/input**

**hdfs dfs -put wordcount.txt /oozie/input**

拷贝MR的任务模板

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**cp -ra examples/apps/map-reduce/ oozie_works/**

删掉MR任务模板lib目录下自带的jar包

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/map-reduce/lib**

**rm -rf oozie-examples-4.1.0-cdh5.14.0.jar**

拷贝官方自带mr程序jar包到对应目录

**cp**

**/export/servers/hadoop-2.7.5/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.5.jar**

**/export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/map-reduce/lib/**

#### 修改配置模板

修改job.properties

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/map-reduce**

**vim job.properties**

```
nameNode=hdfs://node-1:8020
jobTracker=node-1:8032
queueName=default
examplesRoot=oozie_works

oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/map-reduce/workflow.xml
outputDir=/oozie/output
inputdir=/oozie/input
```

修改workflow.xml

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/map-reduce**

**vim workflow.xml**

```
<?xml version="1.0" encoding="UTF-8"?>
<workflow-app xmlns="uri:oozie:workflow:0.5" name="map-reduce-wf">
    <start to="mr-node"/>
    <action name="mr-node">
        <map-reduce>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
                <delete path="${nameNode}/${outputDir}"/>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
				<!--  
                <property>
                    <name>mapred.mapper.class</name>
                    <value>org.apache.oozie.example.SampleMapper</value>
                </property>
                <property>
                    <name>mapred.reducer.class</name>
                    <value>org.apache.oozie.example.SampleReducer</value>
                </property>
                <property>
                    <name>mapred.map.tasks</name>
                    <value>1</value>
                </property>
                <property>
                    <name>mapred.input.dir</name>
                    <value>/user/${wf:user()}/${examplesRoot}/input-data/text</value>
                </property>
                <property>
                    <name>mapred.output.dir</name>
                    <value>/user/${wf:user()}/${examplesRoot}/output-data/${outputDir}</value>
                </property>
				-->

				   <!-- 开启使用新的API来进行配置 -->
                <property>
                    <name>mapred.mapper.new-api</name>
                    <value>true</value>
                </property>

                <property>
                    <name>mapred.reducer.new-api</name>
                    <value>true</value>
                </property>

                <!-- 指定MR的输出key的类型 -->
                <property>
                    <name>mapreduce.job.output.key.class</name>
                    <value>org.apache.hadoop.io.Text</value>
                </property>

                <!-- 指定MR的输出的value的类型-->
                <property>
                    <name>mapreduce.job.output.value.class</name>
                    <value>org.apache.hadoop.io.IntWritable</value>
                </property>

                <!-- 指定输入路径 -->
                <property>
                    <name>mapred.input.dir</name>
                    <value>${nameNode}/${inputdir}</value>
                </property>

                <!-- 指定输出路径 -->
                <property>
                    <name>mapred.output.dir</name>
                    <value>${nameNode}/${outputDir}</value>
                </property>

                <!-- 指定执行的map类 -->
                <property>
                    <name>mapreduce.job.map.class</name>
                    <value>org.apache.hadoop.examples.WordCount$TokenizerMapper</value>
                </property>

                <!-- 指定执行的reduce类 -->
                <property>
                    <name>mapreduce.job.reduce.class</name>
                    <value>org.apache.hadoop.examples.WordCount$IntSumReducer</value>
                </property>
				<!--  配置map task的个数 -->
                <property>
                    <name>mapred.map.tasks</name>
                    <value>1</value>
                </property>

            </configuration>
        </map-reduce>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Map/Reduce failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
```

#### 上传调度任务到hdfs

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**hdfs dfs -put map-reduce/ /user/root/oozie_works/**

#### 执行调度任务

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie job -oozie http://node**-**1:11000/oozie -config oozie_works/map-reduce/job.properties –run**

![image.png](https://image.hyly.net/i/2025/09/26/ff453b6bf7b492c33ef23d205be6f1ed-0.webp)

### Oozie任务串联

在实际工作当中，肯定会存在多个任务需要执行，并且存在上一个任务的输出结果作为下一个任务的输入数据这样的情况，所以我们需要在workflow.xml配置文件当中配置多个action，实现多个任务之间的相互依赖关系。

需求：首先执行一个shell脚本，执行完了之后再执行一个MR的程序，最后再执行一个hive的程序。

#### 准备工作目录

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**mkdir -p sereval-actions**

#### 准备调度文件

将之前的hive，shell， MR的执行，进行串联成到一个workflow当中。

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**cp hive2/script.q sereval-actions/**

**cp shell/hello.sh sereval-actions/**

**cp -ra map-reduce/lib sereval-actions/**

#### 修改配置模板

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/sereval-actions**

**vim workflow.xml**

```
<workflow-app xmlns="uri:oozie:workflow:0.4" name="shell-wf">
<start to="shell-node"/>
<action name="shell-node">
    <shell xmlns="uri:oozie:shell-action:0.2">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <configuration>
            <property>
                <name>mapred.job.queue.name</name>
                <value>${queueName}</value>
            </property>
        </configuration>
        <exec>${EXEC}</exec>
        <!-- <argument>my_output=Hello Oozie</argument> -->
        <file>/user/root/oozie_works/sereval-actions/${EXEC}#${EXEC}</file>

        <capture-output/>
    </shell>
    <ok to="mr-node"/>
    <error to="mr-node"/>
</action>

<action name="mr-node">
        <map-reduce>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
                <delete path="${nameNode}/${outputDir}"/>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
				<!--  
                <property>
                    <name>mapred.mapper.class</name>
                    <value>org.apache.oozie.example.SampleMapper</value>
                </property>
                <property>
                    <name>mapred.reducer.class</name>
                    <value>org.apache.oozie.example.SampleReducer</value>
                </property>
                <property>
                    <name>mapred.map.tasks</name>
                    <value>1</value>
                </property>
                <property>
                    <name>mapred.input.dir</name>
                    <value>/user/${wf:user()}/${examplesRoot}/input-data/text</value>
                </property>
                <property>
                    <name>mapred.output.dir</name>
                    <value>/user/${wf:user()}/${examplesRoot}/output-data/${outputDir}</value>
                </property>
				-->

				   <!-- 开启使用新的API来进行配置 -->
                <property>
                    <name>mapred.mapper.new-api</name>
                    <value>true</value>
                </property>

                <property>
                    <name>mapred.reducer.new-api</name>
                    <value>true</value>
                </property>

                <!-- 指定MR的输出key的类型 -->
                <property>
                    <name>mapreduce.job.output.key.class</name>
                    <value>org.apache.hadoop.io.Text</value>
                </property>

                <!-- 指定MR的输出的value的类型-->
                <property>
                    <name>mapreduce.job.output.value.class</name>
                    <value>org.apache.hadoop.io.IntWritable</value>
                </property>

                <!-- 指定输入路径 -->
                <property>
                    <name>mapred.input.dir</name>
                    <value>${nameNode}/${inputdir}</value>
                </property>

                <!-- 指定输出路径 -->
                <property>
                    <name>mapred.output.dir</name>
                    <value>${nameNode}/${outputDir}</value>
                </property>

                <!-- 指定执行的map类 -->
                <property>
                    <name>mapreduce.job.map.class</name>
                    <value>org.apache.hadoop.examples.WordCount$TokenizerMapper</value>
                </property>

                <!-- 指定执行的reduce类 -->
                <property>
                    <name>mapreduce.job.reduce.class</name>
                    <value>org.apache.hadoop.examples.WordCount$IntSumReducer</value>
                </property>
				<!--  配置map task的个数 -->
                <property>
                    <name>mapred.map.tasks</name>
                    <value>1</value>
                </property>

            </configuration>
        </map-reduce>
        <ok to="hive2-node"/>
        <error to="fail"/>
    </action>






 <action name="hive2-node">
        <hive2 xmlns="uri:oozie:hive2-action:0.1">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare>
                <delete path="${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/hive2"/>
                <mkdir path="${nameNode}/user/${wf:user()}/${examplesRoot}/output-data"/>
            </prepare>
            <configuration>
                <property>
                    <name>mapred.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
            <jdbc-url>${jdbcURL}</jdbc-url>
            <script>script.q</script>
            <param>INPUT=/user/${wf:user()}/${examplesRoot}/input-data/table</param>
            <param>OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/hive2</param>
        </hive2>
        <ok to="end"/>
        <error to="fail"/>
    </action>
<decision name="check-output">
    <switch>
        <case to="end">
            ${wf:actionData('shell-node')['my_output'] eq 'Hello Oozie'}
        </case>
        <default to="fail-output"/>
    </switch>
</decision>
<kill name="fail">
    <message>Shell action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
</kill>
<kill name="fail-output">
    <message>Incorrect output, expected [Hello Oozie] but was [${wf:actionData('shell-node')['my_output']}]</message>
</kill>
<end name="end"/>
</workflow-app>
```

job.properties配置文件

```
nameNode=hdfs://node-1:8020
jobTracker=node-1:8032
queueName=default
examplesRoot=oozie_works
EXEC=hello.sh
outputDir=/oozie/output
inputdir=/oozie/input
jdbcURL=jdbc:hive2://node-1:10000/default
oozie.use.system.libpath=true
# 配置我们文件上传到hdfs的保存路径 实际上就是在hdfs 的/user/root/oozie_works/sereval-actions这个路径下
oozie.wf.application.path=${nameNode}/user/${user.name}/${examplesRoot}/sereval-actions/workflow.xml
```

#### 上传调度任务到hdfs

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/**

**hdfs dfs -put sereval-actions/ /user/root/oozie_works/**

#### 执行调度任务

**cd /export/servers/oozie-4.1.0-cdh5.14.0/**

**bin/oozie job -oozie http://node-1:11000/oozie -config oozie_works/sereval-actions/job.properties -run**

### Oozie定时调度

在oozie当中，主要是通过Coordinator 来实现任务的定时调度，Coordinator 模块主要通过xml来进行配置即可。

Coordinator 的调度主要可以有两种实现方式

第一种：基于时间的定时任务调度：

oozie基于时间的调度主要需要指定三个参数，第一个起始时间，第二个结束时间，第三个调度频率；

第二种：基于数据的任务调度，这种是基于数据的调度，只要在有了数据才会触发调度任务。

#### 准备配置模板

第一步：拷贝定时任务的调度模板

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**cp -r examples/apps/cron oozie_works/cron-job**

第二步：拷贝我们的hello.sh脚本

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**cp shell/hello.sh  cron-job/**

#### 修改配置模板

修改job.properties

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works/cron-job**

**vim job.properties**

```
nameNode=hdfs://node-1:8020
jobTracker=node-1:8032
queueName=default
examplesRoot=oozie_works

oozie.coord.application.path=${nameNode}/user/${user.name}/${examplesRoot}/cron-job/coordinator.xml
#start：必须设置为未来时间，否则任务失败
start=2019-05-22T19:20+0800
end=2019-08-22T19:20+0800
EXEC=hello.sh
workflowAppUri=${nameNode}/user/${user.name}/${examplesRoot}/cron-job/workflow.xml
```

修改coordinator.xml

**vim coordinator.xml**

```
<!--
	oozie的frequency 可以支持很多表达式，其中可以通过定时每分，或者每小时，或者每天，或者每月进行执行，也支持可以通过与linux的crontab表达式类似的写法来进行定时任务的执行
	例如frequency 也可以写成以下方式
	frequency="10 9 * * *"  每天上午的09:10:00开始执行任务
	frequency="0 1 * * *"  每天凌晨的01:00开始执行任务
 -->
<coordinator-app name="cron-job" frequency="${coord:minutes(1)}" start="${start}" end="${end}" timezone="GMT+0800"
                 xmlns="uri:oozie:coordinator:0.4">
        <action>
        <workflow>
            <app-path>${workflowAppUri}</app-path>
            <configuration>
                <property>
                    <name>jobTracker</name>
                    <value>${jobTracker}</value>
                </property>
                <property>
                    <name>nameNode</name>
                    <value>${nameNode}</value>
                </property>
                <property>
                    <name>queueName</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
        </workflow>
    </action>
</coordinator-app>
```

修改workflow.xml

**vim workflow.xml**

```
<workflow-app xmlns="uri:oozie:workflow:0.5" name="one-op-wf">
    <start to="action1"/>
    <action name="action1">
    <shell xmlns="uri:oozie:shell-action:0.2">
        <job-tracker>${jobTracker}</job-tracker>
        <name-node>${nameNode}</name-node>
        <configuration>
            <property>
                <name>mapred.job.queue.name</name>
                <value>${queueName}</value>
            </property>
        </configuration>
        <exec>${EXEC}</exec>
        <!-- <argument>my_output=Hello Oozie</argument> -->
        <file>/user/root/oozie_works/cron-job/${EXEC}#${EXEC}</file>

        <capture-output/>
    </shell>
    <ok to="end"/>
    <error to="end"/>
</action>
    <end name="end"/>
</workflow-app>
```

#### 上传调度任务到hdfs

**cd /export/servers/oozie-4.1.0-cdh5.14.0/oozie_works**

**hdfs dfs -put cron-job/ /user/root/oozie_works/**

#### 执行调度

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozie job -oozie http://node**-**1:11000/oozie -config oozie_works/cron-job/job.properties –run**

![image.png](https://image.hyly.net/i/2025/09/26/332e45a52193a05dca0668e30e2efc3a-0.webp)

## Oozie和Hue整合

### 修改hue配置文件hue.ini

```
[liboozie]
  # The URL where the Oozie service runs on. This is required in order for
  # users to submit jobs. Empty value disables the config check.
  oozie_url=http://node-1:11000/oozie

  # Requires FQDN in oozie_url if enabled
  ### security_enabled=false

  # Location on HDFS where the workflows/coordinator are deployed when submitted.
  remote_deployement_dir=/user/root/oozie_works
```

```
[oozie]
  # Location on local FS where the examples are stored.
  # local_data_dir=/export/servers/oozie-4.1.0-cdh5.14.0/examples/apps

  # Location on local FS where the data for the examples is stored.
  # sample_data_dir=/export/servers/oozie-4.1.0-cdh5.14.0/examples/input-data

  # Location on HDFS where the oozie examples and workflows are stored.
  # Parameters are $TIME and $USER, e.g. /user/$USER/hue/workspaces/workflow-$TIME
  # remote_data_dir=/user/root/oozie_works/examples/apps

  # Maximum of Oozie workflows or coodinators to retrieve in one API call.
  oozie_jobs_count=100

  # Use Cron format for defining the frequency of a Coordinator instead of the old frequency number/unit.
  enable_cron_scheduling=true

  # Flag to enable the saved Editor queries to be dragged and dropped into a workflow.
  enable_document_action=true

  # Flag to enable Oozie backend filtering instead of doing it at the page level in Javascript. Requires Oozie 4.3+.
  enable_oozie_backend_filtering=true

  # Flag to enable the Impala action.
  enable_impala_action=true
```

```
[filebrowser]
  # Location on local filesystem where the uploaded archives are temporary stored.
  archive_upload_tempdir=/tmp

  # Show Download Button for HDFS file browser.
  show_download_button=true

  # Show Upload Button for HDFS file browser.
  show_upload_button=true

  # Flag to enable the extraction of a uploaded archive in HDFS.
  enable_extract_uploaded_archive=true
```

### 启动hue、oozie

启动hue进程

**cd /export/servers/hue-3.9.0-cdh5.14.0**

**build/env/bin/supervisor**

启动oozie进程

**cd /export/servers/oozie-4.1.0-cdh5.14.0**

**bin/oozied.sh start**

页面访问hue

[http://node-1:8888/](http://node-1:8888/)

### Hue集成Oozie

#### 使用hue配置oozie调度

hue提供了页面鼠标拖拽的方式配置oozie调度

![image.png](https://image.hyly.net/i/2025/09/26/ab53fee12aa0eeb854d1f15a0f63437d-0.webp)

#### 利用hue调度shell脚本

在HDFS上创建一个shell脚本程序文件。

![image.png](https://image.hyly.net/i/2025/09/26/a08eeb488274645d46ce035d5e89a39c-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/37ba7ff77da14db15bdd9db2c3f83d24-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/37dd0bae873d7d0cf7ddaf6ed877fc47-0.webp)

打开工作流调度页面。

![image.png](https://image.hyly.net/i/2025/09/26/0fc0869987121eeba8f3ce67e4441719-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/b4ee80cfb041a89293543ac830a64119-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/fcf155230c44b0a5b97fdaecbefa6d45-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/2a3be6969e8635d1e232262fedc2a277-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/0dc518f2c9f8ce84cdfedf515ce456bb-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/49807c9a2fbb7e867a9d701e67525e6e-0.webp)

#### 利用hue调度hive脚本

在HDFS上创建一个hive sql脚本程序文件。

![image.png](https://image.hyly.net/i/2025/09/26/bd789ce81900c6ea1e7b67768864a9ce-0.webp)

打开workflow页面，拖拽hive2图标到指定位置。

![image.png](https://image.hyly.net/i/2025/09/26/7dba0693eda124e7167ad188ecf9a00d-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/52f271291dbed655ba6e434796979647-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/fc5feec82312a6667b9fa17c21788772-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/8c77163b61e0ecb622d84d148e61674e-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/a9f61aa766bae57b0713833f88fa8677-0.webp)

#### 利用hue调度MapReduce程序

利用hue提交MapReduce程序

![image.png](https://image.hyly.net/i/2025/09/26/abd6f3b92204e11383213eda0a9dbe67-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/662e41b37bdce5aa733ba4d36a25c150-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/86917f9cc31713d6749685e7a8a83088-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/ab6f34748ee648c145b8f5d40a068607-0.webp)

#### 利用Hue配置定时调度任务

在hue中，也可以针对workflow配置定时调度任务，具体操作如下：

![image.png](https://image.hyly.net/i/2025/09/26/ce030bc8cf60bd4a2a830483acc409de-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/03939d3395498d84bc5c2392abb3e407-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/b20af4e82ab83be469e53922d7cac6c7-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/63df583d3936372b378d5bd13e82995e-0.webp)

一定要注意时区的问题，否则调度就出错了。保存之后就可以提交定时任务。

![image.png](https://image.hyly.net/i/2025/09/26/3db4f9fb9569c082b008499163363071-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/ac8900b601a573c72f7fda5a5c393ff6-0.webp)

点击进去，可以看到定时任务的详细信息。

![image.png](https://image.hyly.net/i/2025/09/26/e28611a30891a8cf1492b76173144ffe-0.webp)

![image.png](https://image.hyly.net/i/2025/09/26/f6ac9c24cc20ce8c535b54ec4d551962-0.webp)

## Oozie任务查看、杀死

查看所有普通任务

**oozie  jobs**

查看定时任务

**oozie jobs -jobtype coordinator**

杀死某个任务oozie可以通过jobid来杀死某个定时任务

**oozie job -kill [id]**

**oozie job -kill 0000085-180628150519513-oozie-root-C**