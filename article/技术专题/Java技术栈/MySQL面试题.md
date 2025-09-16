---
category: [Java技术栈]
tag: [mysql,面试]
postType: post
status: publish
---

## MVCC多版本并发控制

### 什么是MVCC?

MVCC，全称Multi-Version Concurrency Control，即多版本并发控制。MVCC是一种并发控制的方法，一般在数据库管理系统中，实现对数据库的并发访问，在编程语言中实现事务内存。

多版本控制: 指的是一种提高并发的技术。最早的数据库系统，只有读读之间可以并发，读写，写读，写写都要阻塞。引入多版本之后，只有写写之间相互阻塞，其他三种操作都可以并行，这样大幅度提高了InnoDB的并发度。在内部实现中，与Postgres在数据行上实现多版本不同，InnoDB是在undolog中实现的，通过undolog可以找回数据的历史版本。找回的数据历史版本可以提供给用户读(按照隔离级别的定义，有些读请求只能看到比较老的数据版本)，也可以在回滚的时候覆盖数据页上的数据。在InnoDB内部中，会记录一个全局的活跃读写事务数组，其主要用来判断事务的可见性。
MVCC是一种多版本并发控制机制。

MVCC在MySQL InnoDB中的实现主要是为了提高数据库并发性能，用更好的方式去处理读-写冲突，做到即使有读写冲突时，也能做到不加锁，非阻塞并发读。

### 什么是当前读和快照读？

在学习MVCC多版本并发控制之前，我们必须先了解一下，什么是MySQL InnoDB下的当前读和快照读?

####  当前读

像select lock in share mode(共享锁), select for update ; update, insert ,delete(排他锁)这些操作都是一种当前读，为什么叫当前读？就是它读取的是记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加锁

#### 快照读

像不加锁的select操作就是快照读，即不加锁的非阻塞读；快照读的前提是隔离级别不是串行级别，串行级别下的快照读会退化成当前读；之所以出现快照读的情况，是基于提高并发性能的考虑，快照读的实现是基于多版本并发控制，即MVCC,可以认为MVCC是行锁的一个变种，但它在很多情况下，避免了加锁操作，降低了开销；既然是基于多版本，即快照读可能读到的并不一定是数据的最新版本，而有可能是之前的历史版本

说白了MVCC就是为了实现读-写冲突不加锁，而这个读指的就是快照读, 而非当前读，当前读实际上是一种加锁的操作，是悲观锁的实现。

### 当前读，快照读和MVCC的关系

准确的说，MVCC多版本并发控制指的是 “维持一个数据的多个版本，使得读写操作没有冲突” 这么一个概念。仅仅是一个理想概念。

而在MySQL中，实现这么一个MVCC理想概念，我们就需要MySQL提供具体的功能去实现它，而快照读就是MySQL为我们实现MVCC理想模型的其中一个具体非阻塞读功能。而相对而言，当前读就是悲观锁的具体功能实现。

要说的再细致一些，快照读本身也是一个抽象概念，再深入研究。MVCC模型在MySQL中的具体实现则是由 3个隐式字段，undo日志 ，Read View 等去完成的，具体可以看下面的MVCC实现原理。

### MVCC能解决什么问题，好处是？

数据库并发场景有三种，分别为：

1. 读-读：不存在任何问题，也不需要并发控制。
2. 读-写：有线程安全问题，可能会造成事务隔离性问题，可能遇到脏读，幻读，不可重复读。
3. 写-写：有线程安全问题，可能会存在更新丢失问题，比如第一类更新丢失，第二类更新丢失。

**备注：**第1类丢失更新：事务A撤销时，把已经提交的事务B的更新数据覆盖了；第2类丢失更新：事务A覆盖事务B已经提交的数据，造成事务B所做的操作丢失。

**MVCC带来的好处是？**

多版本并发控制（MVCC）是一种用来解决读-写冲突的无锁并发控制，也就是为事务分配单向增长的时间戳，为每个修改保存一个版本，版本与事务时间戳关联，读操作只读该事务开始前的数据库的快照。 所以MVCC可以为数据库解决以下问题：

1. 在并发读写数据库时，可以做到在读操作时不用阻塞写操作，写操作也不用阻塞读操作，提高了数据库并发读写的性能
2. 同时还可以解决脏读，幻读，不可重复读等事务隔离问题，但不能解决更新丢失问题

小结一下咯，总之，MVCC就是因为大牛们，不满意只让数据库采用悲观锁这样性能不佳的形式去解决读-写冲突问题，而提出的解决方案，所以在数据库中，因为有了MVCC，所以我们可以形成两个组合：

1. MVCC + 悲观锁：MVCC解决读写冲突，悲观锁解决写写冲突
2. MVCC + 乐观锁：MVCC解决读写冲突，乐观锁解决写写冲突

这种组合的方式就可以最大程度的提高数据库并发性能，并解决读写冲突，和写写冲突导致的问题。

### MVCC的实现原理

MVCC的目的就是多版本并发控制，在数据库中的实现，就是为了解决读写冲突，它的实现原理主要是依赖记录中的 3个隐式字段，undo日志 ，Read View 来实现的。所以我们先来看看这个三个point的概念。

#### 隐式字段

每行记录除了我们自定义的字段外，还有数据库隐式定义的DB_TRX_ID,DB_ROLL_PTR,DB_ROW_ID等字段。

1. DB_TRX_ID：6byte，最近修改(修改/插入)事务ID：记录创建这条记录/最后一次修改该记录的事务ID。
2. DB_ROLL_PTR：7byte，回滚指针，指向这条记录的上一个版本（存储于rollback segment里）。
3. DB_ROW_ID：6byte，隐含的自增ID（隐藏主键），如果数据表没有主键，InnoDB会自动以DB_ROW_ID产生一个聚簇索引。
4. 实际还有一个删除flag隐藏字段, 既记录被更新或删除并不代表真的删除，而是删除flag变了。

![image-20220315134705549](https://image.hyly.net/i/2025/09/12/6c2386b92c71d5712c2f096271c5a5c4-0.webp)

如上图，DB_ROW_ID是数据库默认为该行记录生成的唯一隐式主键，DB_TRX_ID是当前操作该记录的事务ID,而DB_ROLL_PTR是一个回滚指针，用于配合undo日志，指向上一个旧版本。

#### undo日志

undo log主要分为两种：

1. insert undo log：代表事务在insert新记录时产生的undo log, 只在事务回滚时需要，并且在事务提交后可以被立即丢弃。
2. update undo log：事务在进行update或delete时产生的undo log; 不仅在事务回滚时需要，在快照读时也需要；所以不能随便删除，只有在快速读或事务回滚不涉及该日志时，对应的日志才会被purge线程统一清除。

**purge:**

1. 从前面的分析可以看出，为了实现InnoDB的MVCC机制，更新或者删除操作都只是设置一下老记录的deleted_bit，并不真正将过时的记录删除。
2. 为了节省磁盘空间，InnoDB有专门的purge线程来清理deleted_bit为true的记录。为了不影响MVCC的正常工作，purge线程自己也维护了一个read view（这个read view相当于系统中最老活跃事务的read view）;如果某个记录的deleted_bit为true，并且DB_TRX_ID相对于purge线程的read view可见，那么这条记录一定是可以被安全清除的。

对MVCC有帮助的实质是update undo log ，undo log实际上就是存在rollback segment中旧记录链，它的执行流程如下：

1. 比如一个有个事务插入persion表插入了一条新记录，记录如下，name为Jerry, age为24岁，隐式主键是1，事务ID和回滚指针，我们假设为NULL。

   ![image-20220315135243316](https://image.hyly.net/i/2025/09/12/861f9024872e3d4d18d51d6ae5747638-0.webp)

2. 现在来了一个事务1对该记录的name做出了修改，改为Tom。

   1. 在事务1修改该行(记录)数据时，数据库会先对该行加排他锁。
   2. 然后把该行数据拷贝到undo log中，作为旧记录，既在undo log中有当前行的拷贝副本。
   3. 拷贝完毕后，修改该行name为Tom，并且修改隐藏字段的事务ID为当前事务1的ID, 我们默认从1开始，之后递增，回滚指针指向拷贝到undo log的副本记录，既表示我的上一个版本就是它。
   4. 事务提交后，释放锁。

   ![image-20220315135456500](https://image.hyly.net/i/2025/09/12/22cad25fcfb14804cabf4a5c41164b1b-0.webp)

3. 又来了个事务2修改person表的同一个记录，将age修改为30岁。

   1. 在事务2修改该行数据时，数据库也先为该行加锁。
   2. 然后把该行数据拷贝到undo log中，作为旧记录，发现该行记录已经有undo log了，那么最新的旧数据作为链表的表头，插在该行记录的undo log最前面。
   3. 修改该行age为30岁，并且修改隐藏字段的事务ID为当前事务2的ID, 那就是2，回滚指针指向刚刚拷贝到undo log的副本记录。
   4. 事务提交，释放锁。

   ![image-20220315135554855](https://image.hyly.net/i/2025/09/12/567aa1c5998dd957aa37c59d3153994b-0.webp)

   从上面，我们就可以看出，不同事务或者相同事务的对同一记录的修改，会导致该记录的undo log成为一条记录版本线性表，既链表，undo log的链首就是最新的旧记录，链尾就是最早的旧记录（当然就像之前说的该undo log的节点可能是会purge线程清除掉，向图中的第一条insert undo log，其实在事务提交之后可能就被删除丢失了，不过这里为了演示，所以还放在这里)

#### Read View(读视图)

什么是Read View？说白了Read View就是事务进行快照读操作的时候生产的读视图(Read View)，在该事务执行的快照读的那一刻，会生成数据库系统当前的一个快照，记录并维护系统当前活跃事务的ID(当每个事务开启时，都会被分配一个ID, 这个ID是递增的，所以最新的事务，ID值越大)

所以我们知道 Read View主要是用来做可见性判断的, 即当我们某个事务执行快照读的时候，对该记录创建一个Read View读视图，把它比作条件用来判断当前事务能够看到哪个版本的数据，既可能是当前最新的数据，也有可能是该行记录的undo log里面的某个版本的数据。

Read View遵循一个可见性算法，主要是将要被修改的数据的最新记录中的DB_TRX_ID（即当前事务ID）取出来，与系统当前其他活跃事务的ID去对比（由Read View维护），如果DB_TRX_ID跟Read View的属性做了某些比较，不符合可见性，那就通过DB_ROLL_PTR回滚指针去取出Undo Log中的DB_TRX_ID再比较，即遍历链表的DB_TRX_ID（从链首到链尾，即从最近的一次修改查起），直到找到满足特定条件的DB_TRX_ID, 那么这个DB_TRX_ID所在的旧记录就是当前事务能看见的最新老版本。

在展示之前，我先简化一下Read View，我们可以把Read View简单的理解成有三个全局属性：

1. trx_list（名字我随便取的）：一个数值列表，用来维护Read View生成时刻系统正活跃的事务ID。
2. up_limit_id：记录trx_list列表中事务ID最小的ID。
3. low_limit_id：ReadView生成时刻系统尚未分配的下一个事务ID，也就是目前已出现过的事务ID的最大值+1。

首先比较DB_TRX_ID < up_limit_id, 如果小于，则当前事务能看到DB_TRX_ID 所在的记录，如果大于等于进入下一个判断。

接下来判断 DB_TRX_ID 大于等于 low_limit_id , 如果大于等于则代表DB_TRX_ID 所在的记录在Read View生成后才出现的，那对当前事务肯定不可见，如果小于则进入下一个判断。

判断DB_TRX_ID 是否在活跃事务之中，trx_list.contains(DB_TRX_ID)，如果在，则代表我Read View生成时刻，你这个事务还在活跃，还没有Commit，你修改的数据，我当前事务也是看不见的；如果不在，则说明，你这个事务在Read View生成之前就已经Commit了，你修改的结果，我当前事务是能看见的。

### 整体流程

我们在了解了隐式字段，undo log， 以及Read View的概念之后，就可以来看看MVCC实现的整体流程是怎么样了

整体的流程是怎么样的呢？我们可以模拟一下：

1. 当事务2对某行数据执行了快照读，数据库为该行数据生成一个Read View读视图，假设当前事务ID为2，此时还有事务1和事务3在活跃中，事务4在事务2快照读前一刻提交更新了，所以Read View记录了系统当前活跃事务1，3的ID，维护在一个列表上，假设我们称为trx_list。

   <table><tr><td>事务1</td><td>事务2</td><td>事务3</td><td>事务4</td></tr><tr><td>事务开始</td><td>事务开始</td><td>事务开始</td><td>事务开始</td></tr><tr><td>…</td><td>…</td><td>…</td><td>修改且已提交</td></tr><tr><td>进行中</td><td>快照读</td><td>进行中</td><td></td></tr><tr><td>…</td><td>…</td><td>…</td><td></td></tr></table>

2. Read View不仅仅会通过一个列表trx_list来维护事务2执行快照读那刻系统正活跃的事务ID，还会有两个属性up_limit_id（记录trx_list列表中事务ID最小的ID），low_limit_id(记录trx_list列表中事务ID最大的ID，也有人说快照读那刻系统尚未分配的下一个事务ID也就是目前已出现过的事务ID的最大值+1，我更倾向于后者 >>>资料传送门 | 呵呵一笑百媚生的回答) ；所以在这里例子中up_limit_id就是1，low_limit_id就是4 + 1 = 5，trx_list集合的值是1,3，Read View如下图：

   ![img](https://image.hyly.net/i/2025/09/12/e7904e28ecce1d904e955c211ade9c26-0.webp)

3. 我们的例子中，只有事务4修改过该行记录，并在事务2执行快照读前，就提交了事务，所以当前该行当前数据的undo log如下图所示；我们的事务2在快照读该行记录的时候，就会拿该行记录的DB_TRX_ID去跟up_limit_id,low_limit_id和活跃事务ID列表(trx_list)进行比较，判断当前事务2能看到该记录的版本是哪个。

   ![image-20220315140132595](https://image.hyly.net/i/2025/09/12/83e2162d62678cb7d02504f13659cfe7-0.webp)

4. 所以先拿该记录DB_TRX_ID字段记录的事务ID 4去跟Read View的的up_limit_id比较，看4是否小于up_limit_id(1)，所以不符合条件，继续判断 4 是否大于等于 low_limit_id(5)，也不符合条件，最后判断4是否处于trx_list中的活跃事务, 最后发现事务ID为4的事务不在当前活跃事务列表中, 符合可见性条件，所以事务4修改后提交的最新结果对事务2快照读时是可见的，所以事务2能读到的最新数据记录是事务4所提交的版本，而事务4提交的版本也是全局角度上最新的版本。

   ![image-20220315140207982](https://image.hyly.net/i/2025/09/12/32d5e7915db007f68c07b23b11e0d540-0.webp)

5. 也正是Read View生成时机的不同，从而造成RC,RR级别下快照读的结果的不同

## 描述一下数据库事务隔离级别？

### 事务管理（ACID）

1. **原子性（Atomicity）：**原子性是指事务是一个不可分割的工作单位，事务中的操作要么都发生，要么都不发生。undo log（MVCC）
2. **一致性（Consistency）:** 事务前后数据的完整性必须保持一致。最核心和最本质的要求。
3. **隔离性（Isolation）：**事务的隔离性是多个用户并发访问数据库时，数据库为每一个用户开启的事务，不能被其他事务的操作数据所干扰，多个并发事务之间要相互隔离。锁，mvcc（多版本并发控制）
4. **持久性（Durability）：**持久性是指一个事务一旦被提交，它对数据库中数据的改变就是永久性的，接下来即使数据库发生故障也不应该对其有任何影响。redo log

数据库的事务隔离级别有四种，分别是读未提交、**读已提交、可重复读、**序列化，不同的隔离级别下会产生脏读、幻读、不可重复读等相关问题，因此在选择隔离级别的时候要根据应用场景来决定，使用合适的隔离级别。

各种隔离级别和数据库异常情况对应情况如下：

<table><tr><td>隔离级别</td><td>脏读</td><td>不可重复读</td><td>幻读</td></tr><tr><td>READ- UNCOMMITTED(读取未提交)</td><td>√</td><td>√</td><td>√</td></tr><tr><td>READ-COMMITTED(读取已提交)</td><td>×</td><td>√</td><td>√</td></tr><tr><td>REPEATABLE- READ(可重复读)</td><td>×</td><td>×</td><td>√</td></tr><tr><td>SERIALIZABLE(可串行化)</td><td>×</td><td>×</td><td>×</td></tr></table>

SQL 标准定义了四个隔离级别：

1. READ-UNCOMMITTED(读取未提交)： 事务的修改，即使没有提交，对其他事务也都是可见的。事务能够读取未提交的数据，这种情况称为脏读。
2. READ-COMMITTED(读取已提交)： 事务读取已提交的数据，大多数数据库的默认隔离级别。当一个事务在执行过程中，数据被另外一个事务修改，造成本次事务前后读取的信息不一样，这种情况称为不可重复读。
3. REPEATABLE-READ(可重复读)： 这个级别是MySQL的默认隔离级别，它解决了脏读的问题，同时也保证了同一个事务多次读取同样的记录是一致的，但这个级别还是会出现幻读的情况。幻读是指当一个事务A读取某一个范围的数据时，另一个事务B在这个范围插入行，A事务再次读取这个范围的数据时，会产生幻读。
4. SERIALIZABLE(可串行化)： 最高的隔离级别，完全服从ACID的隔离级别。所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，该级别可以防止脏读、不可重复读以及幻读。

事务隔离机制的实现基于锁机制和并发调度。其中并发调度使用的是MVVC（多版本并发控制），通过保存修改的旧版本信息来支持并发一致性读和回滚等特性。

因为隔离级别越低，事务请求的锁越少，所以大部分数据库系统的隔离级别都是READ-COMMITTED(读取提交内容):，但是你要知道的是InnoDB 存储引擎默认使用 **REPEATABLE-READ（可重读）**并不会有任何性能损失。

## mysql幻读怎么解决的

事务A按照一定条件进行数据读取，期间事务B插入了相同搜索条件的新数据，事务A再次按照原先条件进行读取时，发现了事务B新插入的数据称之为幻读。

```sql
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB ;

INSERT into user VALUES (1,'1',20),(5,'5',20),(15,'15',30),(20,'20',30);
```

假设有如下业务场景：

| 时间 | 事务1                                                        | 事务2                                       |
| ---- | ------------------------------------------------------------ | ------------------------------------------- |
|      | begin；                                                      |                                             |
| T1   | select * from user where age = 20;2个结果                    |                                             |
| T2   |                                                              | insert into user values(25,'25',20);commit; |
| T3   | select * from user where age =20;2个结果                     |                                             |
| T4   | update user set name='00' where age =20;此时看到影响的行数为3 |                                             |
| T5   | select * from user where age =20;三个结果                    |                                             |

执行流程如下：

1、T1时刻读取年龄为20 的数据，事务1拿到了2条记录

2、T2时刻另一个事务插入一条新的记录，年龄也是20 

3、T3时刻，事务1再次读取年龄为20的数据，发现还是2条记录，事务2插入的数据并没有影响到事务1的事务读取

4、T4时刻，事务1修改年龄为20的数据，发现结果变成了三条，修改了三条数据

5、T5时刻，事务1再次读取年龄为20的数据，发现结果有三条，第三条数据就是事务2插入的数据，此时就产生了幻读情况

此时大家需要思考一个问题，在当下场景里，为什么没有解决幻读问题？

其实通过前面的分析，大家应该知道了快照读和当前读，一般情况下select * from ....where ...是快照读，不会加锁，而 for update,lock in share mode,update,delete都属于当前读，**如果事务中都是用快照读，那么不会产生幻读的问题，但是快照读和当前读一起使用的时候就会产生幻读**。

如果都是当前读的话，如何解决幻读问题呢？

```sql
truncate table user;
INSERT into user VALUES (1,'1',20),(5,'5',20),(15,'15',30),(20,'20',30);
```

| 时间 | 事务1                                        | 事务2                                                |
| ---- | -------------------------------------------- | ---------------------------------------------------- |
|      | begin;                                       |                                                      |
| T1   | select * from user where age =20 for update; |                                                      |
| T2   |                                              | insert into user values(25,'25',20);此时会阻塞等待锁 |
| T3   | select * from user where age =20 for update; |                                                      |

此时，可以看到事务2被阻塞了，需要等待事务1提交事务之后才能完成，其实本质上来说采用的是间隙锁的机制解决幻读问题。

## sql join原理

MySQL是只支持一种Join算法Nested-Loop Join(嵌套循环连接)，并不支持哈希连接和合并连接，不过在mysql中包含了多种变种，能够帮助MySQL提高join执行的效率。

### Simple Nested-Loop Join

![img](https://image.hyly.net/i/2025/09/12/2d602b3fa5d63e2f52b10f4361672e22-0.webp)

这个算法相对来说就是很简单了，从驱动表中取出R1匹配S表所有列，然后R2，R3,直到将R表中的所有数据匹配完，然后合并数据，可以看到这种算法要对S表进行RN次访问，虽然简单，但是相对来说开销还是太大了。

### Index Nested-Loop Join

![img](https://image.hyly.net/i/2025/09/12/05befc0be00865efc25df9372839e342-0.webp)

索引嵌套联系由于非驱动表上有索引，所以比较的时候不再需要一条条记录进行比较，而可以通过索引来减少比较，从而加速查询。这也就是平时我们在做关联查询的时候必须要求关联字段有索引的一个主要原因。

这种算法在链接查询的时候，驱动表会根据关联字段的索引进行查找，当在索引上找到了符合的值，再回表进行查询，也就是只有当匹配到索引以后才会进行回表。至于驱动表的选择，MySQL优化器一般情况下是会选择记录数少的作为驱动表，但是当SQL特别复杂的时候不排除会出现错误选择。

在索引嵌套链接的方式下，如果非驱动表的关联键是主键的话，这样来说性能就会非常的高，如果不是主键的话，关联起来如果返回的行数很多的话，效率就会特别的低，因为要多次的回表操作。先关联索引，然后根据二级索引的主键ID进行回表的操作。这样来说的话性能相对就会很差。

### Block Nested-Loop Join

![](https://image.hyly.net/i/2025/09/16/fc056a6b33b466e3f61bb4033c6cf6e9-0.webp)

在有索引的情况下，MySQL会尝试去使用Index Nested-Loop Join算法，在有些情况下，可能Join的列就是没有索引，那么这时MySQL的选择绝对不会是最先介绍的Simple Nested-Loop Join算法，而是会优先使用Block Nested-Loop Join的算法。

Block Nested-Loop Join对比Simple Nested-Loop Join多了一个中间处理的过程，也就是join buffer，使用join buffer将驱动表的查询JOIN相关列都给缓冲到了JOIN BUFFER当中，然后批量与非驱动表进行比较，这也来实现的话，可以将多次比较合并到一次，降低了非驱动表的访问频率。也就是只需要访问一次S表。这样来说的话，就不会出现多次访问非驱动表的情况了，也只有这种情况下才会访问join buffer。

在MySQL当中，我们可以通过参数join_buffer_size来设置join buffer的值，然后再进行操作。默认情况下join_buffer_size=256K，在查找的时候MySQL会将所有的需要的列缓存到join buffer当中，包括select的列，而不是仅仅只缓存关联列。在一个有N个JOIN关联的SQL当中会在执行时候分配N-1个join buffer。

## 说明一下数据库索引原理、底层索引数据结构

![image-20220315221431137](https://image.hyly.net/i/2025/09/12/47587d317f8e8e80dcf5341371b1bf2a-0.webp)

### 为什么要有索引？

1. 在数据库中，索引就像 **书的目录**，可以大幅提高查询速度。
2. 如果没有索引，MySQL 查询数据时必须 **全表扫描**（从第一行到最后一行逐一比较）。
3. 有了索引后，可以通过 **更高效的数据结构** 来快速定位到目标行，减少 I/O 开销。

### MySQL 索引的底层实现

在 MySQL 中，**索引的存储方式取决于存储引擎**。常见的有 InnoDB 和 MyISAM：

#### InnoDB 引擎（最常用）

1. **默认索引结构：B+Tree**
2. **聚簇索引（Clustered Index）**
	1. 表数据存储在 **主键索引的 B+Tree 叶子节点** 中。
	2. 主键索引的叶子节点既存储主键值，也存储整行数据。
3. **二级索引（Secondary Index）**
	1. 叶子节点只存储索引列和对应的主键值。
	2. 查询时若需要非索引字段，需要先通过二级索引找到主键，再回表到聚簇索引获取完整数据（称为 **回表**）。

#### MyISAM 引擎

1. **索引和数据分开存储**。
2. 索引结构是 **B+Tree**，叶子节点存储的是数据记录的物理地址。
3. 通过索引找到数据地址，再去数据文件取数据。
4. 没有聚簇索引的概念。

### 常见索引的数据结构

####  B+Tree（默认）

1. 特点：
	1. 所有数据都存在 **叶子节点**，叶子节点之间用链表连接，便于范围查询。
	2. 树的高度低，磁盘 I/O 次数少。
2. 查询效率稳定，O(log n)。
3. 适用于 **范围查询、大量等值查询**。

#### Hash 索引

1. 基于 **哈希表** 实现，查询效率 O(1)。
2. 缺点：
	1. 只支持 **等值查询**，不支持范围查询。
	2. 哈希冲突时需要链表处理，性能可能下降。
3. MySQL 中 **Memory 引擎** 支持 Hash 索引，InnoDB 内部也用哈希做自适应优化。

#### Full-Text（全文索引）

1. 主要用于大文本字段（如 `TEXT`、`VARCHAR`）。
2. 使用倒排索引（Inverted Index），适合模糊匹配、关键词搜索。

####  R-Tree（空间索引）

1. 主要用于 **GIS 空间数据**（地理位置、范围查询）。
2. 适用于二维、三维空间数据的范围查找。

### 索引原理总结

1. **逻辑上**：索引就是加速数据查找的“目录”。
2. **物理上**：InnoDB 默认采用 **B+Tree 索引**，二级索引需要回表查询。
3. **数据结构**：
	1. B+Tree（最常用，支持范围查询）
	2. Hash（适合等值查询）
	3. Full-Text（全文搜索）
	4. R-Tree（空间数据）

## 索引失效的情况？

### 使用了 `select *`

影响不大，但容易导致读取过多无关字段，有时会触发回表，降低索引效率。建议只查询需要的列。

###  在索引列上使用函数或计算

```
SELECT * FROM user WHERE YEAR(birth_date) = 1990;
```

因为对 `birth_date` 做了函数处理，索引失效。
 解决：改写为

```
SELECT * FROM user 
WHERE birth_date >= '1990-01-01' AND birth_date < '1991-01-01';
```

### 在索引列上做隐式类型转换

```
-- name 是 VARCHAR 类型
SELECT * FROM user WHERE name = 123;
```

MySQL 会隐式转换成字符串，索引失效。
 解决：保持类型一致。

### 4. 在索引列上使用模糊匹配 `%` 开头

```
SELECT * FROM user WHERE name LIKE '%abc';
```

`%` 在前无法利用 B+Tree 索引。
 解决：`LIKE 'abc%'` 可以走索引。若必须 `%abc%`，可考虑 **全文索引**。

### 使用 `OR` 连接不同列的条件

```
SELECT * FROM user WHERE name = 'Tom' OR age = 20;
```

不同字段上的 `OR` 条件可能导致索引失效。
解决：可拆成 `UNION`，或建立复合索引。

### 联合索引不满足“最左前缀原则”

```
CREATE INDEX idx_name_age (name, age);

SELECT * FROM user WHERE age = 20; -- ❌ 不能用索引
SELECT * FROM user WHERE name = 'Tom' AND age = 20; -- ✅ 能用索引
```

必须从最左边开始匹配，跳过前导列会导致失效。

### 索引列参与不等号或范围查询后，右边的列失效

```
CREATE INDEX idx_name_age (name, age);

SELECT * FROM user WHERE name = 'Tom' AND age > 20;
```

`name` 可以用索引，但 `age` 之后的范围查询会导致复合索引的后续列失效。

### 使用 `NOT`、`!=`、`<>`、`IS NULL/IS NOT NULL`

```
SELECT * FROM user WHERE age != 20;
```

一般不能走索引，因为 MySQL 难以利用 B+Tree 范围。
 `IS NULL` 在 InnoDB 中可走索引，但效率未必高。

### 使用 `IN` / `NOT IN` 过多

```
SELECT * FROM user WHERE id IN (1,2,3,...,10000);
```

小集合可以走索引，大集合可能退化成全表扫描。
大集合建议使用 `JOIN` 或临时表。

### 表数据过少或查询返回行过多

如果 MySQL 评估发现 **全表扫描更快**，即使有索引也不会用。
可通过 `EXPLAIN` 检查执行计划。

## mysql如何做分库分表的？

### 为什么要分库分表？

1. **单表查询/写入性能下降**：B+Tree 索引太大，页分裂严重。
2. **单机存储/IO 瓶颈**：磁盘、内存放不下。
3. **高并发瓶颈**：单库 QPS 无法支撑。

------

### 分库分表的类型

####  **垂直拆分（Vertical Sharding）**

1. **垂直分库**：按照业务模块拆分数据库
	 例：用户库、订单库、商品库
2. **垂直分表**：把一个大表的不同字段拆开
	 例：`user_base_info`（常用字段），`user_ext_info`（不常用字段）

优点：业务清晰、单表字段少、缓存友好
缺点：跨库 JOIN 复杂，需要分布式事务

------

####  **水平拆分（Horizontal Sharding）**

1. **水平分库**：相同结构的数据，按规则拆到不同库
2. **水平分表**：相同结构的数据，按规则拆到不同表

常见规则：

1. **哈希取模**：`user_id % N`
	1. 均匀分布，查询需要知道分片规则
	2. 缺点：扩容时需要迁移大量数据
2. **范围分片**：按时间、ID 范围
	1. 例：订单表 `2023_orders`，`2024_orders`
	2. 缺点：容易数据热点
3. **一致性哈希**（带虚拟节点）
	1. 扩容时数据迁移量少，分布更均匀

------

### MySQL 分库分表的实现方式

#### 客户端分片（Sharding at Application Layer）

1. 应用程序自己维护路由规则（比如 `user_id % 4` → DB2）
2. 查询时直接去对应库表

优点：简单，性能高（无中间层）
缺点：逻辑都写在代码里，耦合严重，难以维护

------

####  中间件分片

常见中间件：

1. **MyCat**：开源中间件，支持读写分离、分库分表
2. **ShardingSphere**（Apache）：功能更强，支持分布式事务、数据治理
3. **Vitess**：YouTube 开源，适合超大规模
4. **Citus（PostgreSQL 方案）**：分布式数据库

优点：应用层无感知，透明分片
缺点：中间件性能瓶颈、复杂度高

------

#### 数据库自带分片/分区

- MySQL **分区表**：`PARTITION BY RANGE/HASH/LIST`
- 适合中等规模数据，但分区表还在一个实例里，不等于真正的分库分表。

------

#### 分库分表后的挑战

1. **跨分片查询**
	1. 不能直接 `JOIN`，需要在应用层组装结果
	2. 统计类查询（COUNT/SUM）需要分库汇总
2. **分布式事务**
	1. MySQL 单机事务 → 分布式事务（2PC、TCC、XA，性能下降）
	2. 一般通过业务补偿（最终一致性）解决
3. **全局 ID 生成**
	1. 原来的自增 ID 不再唯一
	2. 常用方案：雪花算法（Snowflake）、Leaf、Redis/Zookeeper 分布式 ID
4. **迁移和扩容**
	1. 哈希分片扩容需要大量迁移数据
	2. 一致性哈希/分布式存储可以减少迁移量

## 数据存储引擎有哪些？

<table><thead><tr><th>功 能</th><th>MYISAM</th><th>Memory</th><th>InnoDB</th><th>Archive</th></tr></thead><tbody><tr><td>存储限制</td><td>256TB</td><td>RAM</td><td>64TB</td><td>None</td></tr><tr><td>支持事物</td><td>No</td><td>No</td><td>Yes</td><td>No</td></tr><tr><td>支持全文索引</td><td>Yes</td><td>No</td><td>No</td><td>No</td></tr><tr><td>支持数索引</td><td>Yes</td><td>Yes</td><td>Yes</td><td>No</td></tr><tr><td>支持哈希索引</td><td>No</td><td>Yes</td><td>No</td><td>No</td></tr><tr><td>支持数据缓存</td><td>No</td><td>N/A</td><td>Yes</td><td>No</td></tr><tr><td>支持外键</td><td>No</td><td>No</td><td>Yes</td><td>No</td></tr></tbody></table>

大家可以通过show engines的方式查看对应的数据库支持的存储引擎。

## 描述一下InnoDB和MyISAM的区别？

<table><thead><tr><th>区别</th><th>Innodb</th><th>MyISAM</th></tr></thead><tbody><tr><td>事务</td><td>支持</td><td>不支持</td></tr><tr><td>外键</td><td>支持</td><td>不支持</td></tr><tr><td>索引</td><td>即支持聚簇索引又支持非聚簇索引</td><td>只支持非聚簇索引</td></tr><tr><td>行锁</td><td>支持</td><td>不支持</td></tr><tr><td>表锁</td><td>支持</td><td>支持</td></tr><tr><td>存储文件</td><td>frm，ibd</td><td>frm,myi,myd</td></tr><tr><td>具体行数</td><td>每次必须要全表扫描统计行数</td><td>通过变量保存行数</td></tr></tbody></table>

如何选择？

1. 是否需要支持事务，如果需要选择innodb，如果不需要选择myisam
2. 如果表的大部分请求都是读请求，可以考虑myisam，如果既有读也有写，使用innodb
3. 现在mysql的默认存储引擎已经变成了Innodb,推荐使用innodb

## 描述一下聚簇索引和非聚簇索引的区别？

innodb存储引擎在进行数据插入的时候必须要绑定到一个索引列上，默认是主键，如果没有主键，会选择唯一键，如果没有唯一键，那么会选择生成6字节的rowid，跟数据绑定在一起的索引我们称之为聚簇索引，没有跟数据绑定在一起的索引我们称之为非聚簇索引。

innodb存储引擎中既有聚簇索引也有非聚簇索引，而myisam存储引擎中只有非聚簇索引。

<table><thead><tr><th>对比项</th><th>聚簇索引</th><th>非聚簇索引</th></tr></thead><tbody><tr><td>存储位置</td><td>索引和数据存储在一起</td><td>索引和数据分开存储</td></tr><tr><td>数量限制</td><td>每表只能有一个</td><td>每表可有多个</td></tr><tr><td>叶子节点存储</td><td>数据本身</td><td>数据地址或主键值</td></tr><tr><td>查询效率</td><td>更快（直接找到数据）</td><td>可能需要“回表”，稍慢</td></tr><tr><td>插入/更新效率</td><td>较慢（可能需要移动数据）</td><td>较快（只调整索引结构）</td></tr><tr><td>MySQL InnoDB 默认</td><td>主键为聚簇索引</td><td>其他索引为非聚簇索引</td></tr></tbody></table>

## 描述一下mysql主从复制的机制的原理？mysql主从复制主要有几种模式？

### MySQL 主从复制的原理

MySQL 主从复制（Replication）的核心思想是：
 **主库把数据变更操作记录下来，然后同步给从库执行，从而保证主从数据一致。**

### 具体流程（以异步复制为例）：

1. **主库（Master）**
	1. 把所有更改数据的操作（`INSERT / UPDATE / DELETE`）写入 **binlog（二进制日志）**。
2. **从库（Slave）I/O 线程**
	1. 连接主库，读取主库的 binlog 内容，并写入到从库的 **relay log（中继日志）**。
3. **从库（Slave）SQL 线程**
	1. 读取 relay log，并重放其中的 SQL 事件，在从库执行一遍，最终数据和主库保持一致。

关键点：

1. 主从复制是 **逻辑复制**（传输 binlog 事件，而不是物理文件）。
2. 默认是 **异步**的，即主库写完就返回，不等从库。

### MySQL 主从复制的主要模式

MySQL 复制有三种主要模式：

####  异步复制（Asynchronous Replication，默认）

1. **机制**：主库写完 binlog 就返回客户端，不管从库是否接收/执行完成。
2. **优点**：性能最好，主库响应快。
3. **缺点**：存在数据延迟，甚至主库宕机时数据丢失风险。

#### 半同步复制（Semi-synchronous Replication）

1. **机制**：主库写完 binlog 后，至少要 **等待一个从库确认收到 relay log**，才返回客户端。
2. **优点**：保证数据至少落到一个从库，减少数据丢失风险。
3. **缺点**：性能比异步稍慢，如果从库延迟大，主库响应也会受影响。

#### 组复制 / 强同步复制（Group Replication / Galera Cluster）

1. **机制**：写入必须在 **多数节点确认** 后才算成功，类似分布式共识协议。
2. **优点**：数据一致性最好，适合高可用场景（比如 MySQL InnoDB Cluster）。
3. **缺点**：写入延迟高，性能开销大，架构复杂。

### 复制模式选择

1. **高性能，允许一定延迟** → **异步复制**（常用于读写分离）。
2. **希望保证数据安全，但还能接受一定延迟** → **半同步复制**。
3. **强一致性，要求高可用集群** → **组复制 / Galera Cluster**。

**一句话总结**：
 MySQL 主从复制靠 **binlog → relay log → 重放**实现，模式分为 **异步 / 半同步 / 强同步**，性能和一致性是权衡关系。

## 如何优化sql，查询计划的结果中看哪些些关键数据？

### SQL 优化常见手段

1. **避免全表扫描**：尽量走索引。
2. **尽量使用覆盖索引**（避免回表）。
3. **减少 SELECT \*，只查必要列**。
4. **避免函数操作字段**（会导致索引失效）。
5. **大表 JOIN 时小表驱动大表**（优化 join 顺序）。
6. **分页优化**：`LIMIT 100000,10` → 改成子查询 ID 或延迟关联。
7. **分区/分表**：数据量太大时。

------

### `EXPLAIN` 结果里关键指标

运行：

```
EXPLAIN SELECT ...;
```

会返回一张表，重点看以下字段：

<figure class='table-figure'><table>
<thead>
<tr><th>字段</th><th>含义</th><th>关键点</th></tr></thead>
<tbody><tr><td><strong>id</strong></td><td>查询执行顺序 ID</td><td>数字越大优先级越高；同 ID 表示同级；子查询会有不同 ID</td></tr><tr><td><strong>select_type</strong></td><td>查询类型</td><td>SIMPLE（简单查询），PRIMARY（主查询），SUBQUERY（子查询）</td></tr><tr><td><strong>table</strong></td><td>当前扫描的表</td><td>哪个表在被访问</td></tr><tr><td><strong>type</strong></td><td>连接类型（重要）</td><td><strong>性能由好到差</strong>：system &gt; const &gt; eq_ref &gt; ref &gt; range &gt; index &gt; ALL</td></tr><tr><td><strong>possible_keys</strong></td><td>可能用到的索引</td><td>MySQL 认为可用的索引</td></tr><tr><td><strong>key</strong></td><td>实际用到的索引</td><td>如果是 <code>NULL</code> 就没用到索引</td></tr><tr><td><strong>key_len</strong></td><td>使用的索引长度</td><td>越长表示利用的索引列越多</td></tr><tr><td><strong>rows</strong></td><td>预估扫描的行数</td><td>数字越小越好，rows 太大说明索引没用上</td></tr><tr><td><strong>filtered</strong></td><td>行过滤比例 (%)</td><td>表示剩下的行占比，低说明过滤多</td></tr><tr><td><strong>Extra</strong></td><td>额外信息</td><td>包含很多优化线索（见下表）</td></tr></tbody>
</table></figure>
#### `Extra` 常见值及含义

1. **Using index**：覆盖索引，性能好（不用回表）。
2. **Using where**：条件过滤了行。
3. **Using filesort**：需要额外排序（可能性能差）。
4. **Using temporary**：用到临时表（通常 GROUP BY / ORDER BY 导致）。
5. **Range checked for each record**：没有用好索引，MySQL 每条记录都要做索引检查。

### 优化时关注的关键点

1. **type 列**
	1. 理想值：`const` / `eq_ref` / `ref` / `range`
	2. 不好：`index`（全索引扫描），`ALL`（全表扫描）
2. **rows**
	1. 预估扫描行数，越少越好。
	2. 如果 `rows=1000000`，说明索引没生效。
3. **key**
	1. 如果是 `NULL`，说明没用上索引。
4. **Extra**
	1. 出现 `Using filesort`、`Using temporary` → 要考虑加索引、优化 SQL。

**举个例子：**

```
EXPLAIN SELECT * FROM orders WHERE customer_id=123 ORDER BY create_time DESC;
```

可能结果：

<figure class='table-figure'><table>
<thead>
<tr><th>id</th><th>select_type</th><th>table</th><th>type</th><th>key</th><th>rows</th><th>Extra</th></tr></thead>
<tbody><tr><td>1</td><td>SIMPLE</td><td>orders</td><td>ref</td><td>idx_custid</td><td>1000</td><td>Using filesort</td></tr></tbody>
</table></figure>

| id   | select_type | table  | type | key        | rows | Extra          |
| ---- | ----------- | ------ | ---- | ---------- | ---- | -------------- |
| 1    | SIMPLE      | orders | ref  | idx_custid | 1000 | Using filesort |

分析：

- type=ref（OK，用了索引）
- rows=1000（还好）
- Extra=Using filesort（说明 create_time 没在索引里）

优化：建联合索引 `(customer_id, create_time)`，避免 filesort。

## 描述一下mysql的乐观锁和悲观锁，锁的种类？

### 悲观锁（Pessimistic Lock）

**概念**：

1. 悲观锁假设 **每次操作数据都会发生冲突**，所以对数据操作前 **先加锁**，保证其他事务不能修改。
2. 常见于高并发、写多读少的场景。

**MySQL 实现方式**：

<figure class='table-figure'><table>
<thead>
<tr><th>类型</th><th>SQL 示例</th><th>说明</th></tr></thead>
<tbody><tr><td><strong>行锁（共享/排他）</strong></td><td><code>SELECT * FROM user WHERE id=1 FOR UPDATE;</code></td><td>对查询到的行加排他锁（X Lock），其他事务不能修改。</td></tr><tr><td><strong>共享锁</strong></td><td><code>SELECT * FROM user WHERE id=1 LOCK IN SHARE MODE;</code></td><td>读锁，允许其他事务读，但不允许修改。</td></tr></tbody>
</table></figure>

**特点**：

- 会阻塞其他事务，保证数据一致性。
- 常用 **InnoDB** 引擎支持行锁和表锁。
- 开销大，可能造成死锁。

### 乐观锁（Optimistic Lock）

**概念**：

1. 乐观锁假设 **数据冲突很少发生**，不加锁，而是在提交更新时检查数据是否被修改。
2. 常见于写少读多的场景。

**实现方式**：

1. **版本号（Version）机制**

	```
	-- 假设表有 version 字段
	UPDATE user
	SET balance = balance - 100, version = version + 1
	WHERE id = 1 AND version = 3;
	```

	1. 如果 `version=3`，说明数据未被其他事务修改，可以成功更新
	2. 如果 version 不匹配 → 更新失败，需要重试

2. **时间戳机制**

	1. 通过记录每条记录的 `last_update_time`，更新时检查是否被修改
	2. 与版本号类似

**特点**：

1. 不加锁，性能好，适合高并发
2. 不能防止脏读，但可防止更新丢失
3. 常用于 **Web 应用缓存 + 数据库更新**

### MySQL 锁的种类

#### 按粒度分类

<figure class='table-figure'><table>
<thead>
<tr><th>锁类型</th><th>粒度</th><th>说明</th></tr></thead>
<tbody><tr><td><strong>表锁（Table Lock）</strong></td><td>表</td><td>整张表加锁，操作简单，但并发低</td></tr><tr><td><strong>行锁（Row Lock）</strong></td><td>行</td><td>最小粒度，InnoDB 支持，可提高并发</td></tr><tr><td><strong>页锁（Page Lock）</strong></td><td>页</td><td>MyISAM 支持，将一页记录加锁，介于表锁和行锁之间</td></tr></tbody>
</table></figure>

#### 按操作分类

<figure class='table-figure'><table>
<thead>
<tr><th>锁类型</th><th>说明</th></tr></thead>
<tbody><tr><td><strong>共享锁（S Lock / 读锁）</strong></td><td>多事务可以同时读取，但不能修改</td></tr><tr><td><strong>排他锁（X Lock / 写锁）</strong></td><td>事务独占数据，其他事务不能读或写</td></tr><tr><td><strong>意向锁（IS/IX）</strong></td><td>InnoDB 用于行锁前，先在表上加意向锁，方便判断冲突</td></tr><tr><td><strong>自增锁（AUTO-INC Lock）</strong></td><td>仅对自增列，保证插入操作不冲突</td></tr></tbody>
</table></figure>

#### InnoDB 锁机制特点

1. **行锁优先**，支持 **记录锁 + 间隙锁 + 临键锁**
2. **间隙锁（Gap Lock）**：间隙锁是加在 两条记录之间的空隙上的锁，锁住的是范围，而不是具体行。防止幻读。
3. **临键锁（Next-Key Lock）** = 记录锁 + 间隙锁，锁定范围内的 现有记录 + 记录之间的间隙。

#### 总结对比

<figure class='table-figure'><table>
<thead>
<tr><th>特性</th><th>悲观锁</th><th>乐观锁</th></tr></thead>
<tbody><tr><td>假设</td><td>数据冲突频繁</td><td>数据冲突少</td></tr><tr><td>加锁方式</td><td>先加锁</td><td>提交时检查</td></tr><tr><td>性能</td><td>开销大</td><td>高并发友好</td></tr><tr><td>常用场景</td><td>写多、高并发事务</td><td>读多、更新少</td></tr><tr><td>MySQL 实现</td><td><code>SELECT ... FOR UPDATE / LOCK IN SHARE MODE</code></td><td>版本号、时间戳</td></tr></tbody>
</table></figure>

## mysql原子性和持久性是怎么保证的？

原子性通过undolog来实现，持久性通过redo log来实现，详细可以看[MVCC多版本并发控制](#MVCC多版本并发控制)



