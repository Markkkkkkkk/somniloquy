---
category: [Java技术栈]
tag: [java,多线程,高并发,面试]
postType: post
status: publish
---

## 线程的基础知识

### 线程和进程的区别？

程序由指令和数据组成，但这些指令要运行，数据要读写，就必须将指令加载至 CPU，数据加载至内存。在指令运行过程中还需要用到磁盘、网络等设备。进程就是用来加载指令、管理内存、管理 IO 的。

**当一个程序被运行，从磁盘加载这个程序的代码至内存，这时就开启了一个进程。**

![img](https://image.hyly.net/i/2025/09/22/e77d71d6710eb068dde829be94f2cd94-0.webp)

一个进程之内可以分为一到多个线程。

一个线程就是一个指令流，将指令流中的一条条指令以一定的顺序交给 CPU 执行

Java 中，线程作为最小调度单位，进程作为资源分配的最小单位。在 windows 中进程是不活动的，只是作为线程的容器

![img](https://image.hyly.net/i/2025/09/22/da51ceef9336912c1708ef5905df71f9-0.webp)

**二者对比**

1. 进程是正在运行程序的实例，进程中包含了线程，每个线程执行不同的任务
2. 不同的进程使用不同的内存空间，在当前进程下的所有线程可以共享内存空间
3. 线程更轻量，线程上下文切换成本一般上要比进程上下文切换低(上下文切换指的是从一个线程切换到另一个线程)

### 并行和并发有什么区别？

单核CPU

1. 单核CPU下线程实际还是串行执行的
2. 操作系统中有一个组件叫做任务调度器，将cpu的时间片（windows下时间片最小约为 15 毫秒）分给不同的程序使用，只是由于cpu在线程间（时间片很短）的切换非常快，人类感觉是同时运行的 。
3. 总结为一句话就是： 微观串行，宏观并行

一般会将这种线程轮流使用CPU的做法称为并发（concurrent）

![img](https://image.hyly.net/i/2025/09/22/c3d36dda8e219a2fb1e3995b3fa7103c-0.webp)

![img](https://image.hyly.net/i/2025/09/22/62c5e1ad803399bacc14eacc44754099-0.webp)

多核CPU

每个核（core）都可以调度运行线程，这时候线程可以是并行的。

![img](https://image.hyly.net/i/2025/09/22/b28ff1347080dfed939fd3a96897a45e-0.webp)

**并发（concurrent）是同一时间应对（dealing with）多件事情的能力**

**并行（parallel）是同一时间动手做（doing）多件事情的能力**

> 举例：
> 家庭主妇做饭、打扫卫生、给孩子喂奶，她一个人轮流交替做这多件事，这时就是并发
> 家庭主妇雇了个保姆，她们一起这些事，这时既有并发，也有并行（这时会产生竞争，例如锅只有一口，一个人用锅时，另一个人就得等待）
> 雇了3个保姆，一个专做饭、一个专打扫卫生、一个专喂奶，互不干扰，这时是并行

###  创建线程的四种方式

参考回答：

共有四种方式可以创建线程，分别是：继承Thread类、实现runnable接口、实现Callable接口、线程池创建线程

详细创建方式参考下面代码：

① **继承Thread类**

```
public class MyThread extends Thread {

    @Override
    public void run() {
        System.out.println("MyThread...run...");
    }

    
    public static void main(String[] args) {

        // 创建MyThread对象
        MyThread t1 = new MyThread() ;
        MyThread t2 = new MyThread() ;

        // 调用start方法启动线程
        t1.start();
        t2.start();

    }
    
}
```

② **实现runnable接口**

```
public class MyRunnable implements Runnable{

    @Override
    public void run() {
        System.out.println("MyRunnable...run...");
    }

    public static void main(String[] args) {

        // 创建MyRunnable对象
        MyRunnable mr = new MyRunnable() ;

        // 创建Thread对象
        Thread t1 = new Thread(mr) ;
        Thread t2 = new Thread(mr) ;

        // 调用start方法启动线程
        t1.start();
        t2.start();

    }

}
```

③ **实现Callable接口**

```
public class MyCallable implements Callable<String> {

    @Override
    public String call() throws Exception {
        System.out.println("MyCallable...call...");
        return "OK";
    }

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        // 创建MyCallable对象
        MyCallable mc = new MyCallable() ;

        // 创建F
        FutureTask<String> ft = new FutureTask<String>(mc) ;

        // 创建Thread对象
        Thread t1 = new Thread(ft) ;
        Thread t2 = new Thread(ft) ;

        // 调用start方法启动线程
        t1.start();

        // 调用ft的get方法获取执行结果
        String result = ft.get();

        // 输出
        System.out.println(result);

    }

}
```

④ **线程池创建线程**

```
public class MyExecutors implements Runnable{

    @Override
    public void run() {
        System.out.println("MyRunnable...run...");
    }

    public static void main(String[] args) {

        // 创建线程池对象
        ExecutorService threadPool = Executors.newFixedThreadPool(3);
        threadPool.submit(new MyExecutors()) ;

        // 关闭线程池
        threadPool.shutdown();

    }

}
```

###  runnable 和 callable 有什么区别

参考回答：

1. Runnable 接口run方法没有返回值；Callable接口call方法有返回值，是个泛型，和Future、FutureTask配合可以用来获取异步执行的结果
2. Callalbe接口支持返回执行结果，需要调用FutureTask.get()得到，此方法会阻塞主进程的继续往下执行，如果不调用不会阻塞。
3. Callable接口的call()方法允许抛出异常；而Runnable接口的run()方法的异常只能在内部消化，不能继续上抛

### 线程的 run()和 start()有什么区别？

start(): 用来启动线程，通过该线程调用run方法执行run方法中所定义的逻辑代码。start方法只能被调用一次。

run(): 封装了要被线程执行的代码，可以被调用多次。

###  线程包括哪些状态，状态之间是如何变化的

> 难易程度：☆☆☆
> 出现频率：☆☆☆☆

线程的状态可以参考JDK中的Thread类中的枚举State

```
public enum State {
        /**
         * 尚未启动的线程的线程状态
         */
        NEW,

        /**
         * 可运行线程的线程状态。处于可运行状态的线程正在 Java 虚拟机中执行，但它可能正在等待来自		 * 操作系统的其他资源，例如处理器。
         */
        RUNNABLE,

        /**
         * 线程阻塞等待监视器锁的线程状态。处于阻塞状态的线程正在等待监视器锁进入同步块/方法或在调          * 用Object.wait后重新进入同步块/方法。
         */
        BLOCKED,

        /**
         * 等待线程的线程状态。由于调用以下方法之一，线程处于等待状态：
		* Object.wait没有超时
         * 没有超时的Thread.join
         * LockSupport.park
         * 处于等待状态的线程正在等待另一个线程执行特定操作。
         * 例如，一个对对象调用Object.wait()的线程正在等待另一个线程对该对象调用Object.notify()			* 或Object.notifyAll() 。已调用Thread.join()的线程正在等待指定线程终止。
         */
        WAITING,

        /**
         * 具有指定等待时间的等待线程的线程状态。由于以指定的正等待时间调用以下方法之一，线程处于定          * 时等待状态：
		* Thread.sleep
		* Object.wait超时
		* Thread.join超时
		* LockSupport.parkNanos
		* LockSupport.parkUntil
         * </ul>
         */
        TIMED_WAITING,

        /**
         * 已终止线程的线程状态。线程已完成执行
         */
        TERMINATED;
    }
```

状态之间是如何变化的

![img](https://image.hyly.net/i/2025/09/22/1b5d5069985e09434aa7f6bf52ca72c0-0.webp)

分别是

1. 新建
  1. 当一个线程对象被创建，但还未调用 start 方法时处于**新建**状态
  2. 此时未与操作系统底层线程关联
2. 可运行
  1. 调用了 start 方法，就会由**新建**进入**可运行**
  2. 此时与底层线程关联，由操作系统调度执行
3. 终结
  1. 线程内代码已经执行完毕，由**可运行**进入**终结**
  2. 此时会取消与底层线程关联
4. 阻塞
  1. 当获取锁失败后，由**可运行**进入 Monitor 的阻塞队列**阻塞**，此时不占用 cpu 时间
  2. 当持锁线程释放锁时，会按照一定规则唤醒阻塞队列中的**阻塞**线程，唤醒后的线程进入**可运行**状态
5. 等待
  1. 当获取锁成功后，但由于条件不满足，调用了 wait() 方法，此时从**可运行**状态释放锁进入 Monitor 等待集合**等待**，同样不占用 cpu 时间
  2. 当其它持锁线程调用 notify() 或 notifyAll() 方法，会按照一定规则唤醒等待集合中的**等待**线程，恢复为**可运行**状态
6. 有时限等待
  1. 当获取锁成功后，但由于条件不满足，调用了 wait(long) 方法，此时从**可运行**状态释放锁进入 Monitor 等待集合进行**有时限等待**，同样不占用 cpu 时间
  2. 当其它持锁线程调用 notify() 或 notifyAll() 方法，会按照一定规则唤醒等待集合中的**有时限等待**线程，恢复为**可运行**状态，并重新去竞争锁
  3. 如果等待超时，也会从**有时限等待**状态恢复为**可运行**状态，并重新去竞争锁
  4. 还有一种情况是调用 sleep(long) 方法也会从**可运行**状态进入**有时限等待**状态，但与 Monitor 无关，不需要主动唤醒，超时时间到自然恢复为**可运行**状态

###  新建 T1、T2、T3 三个线程，如何保证它们按顺序执行？

> 难易程度：☆☆
> 出现频率：☆☆☆

在多线程中有多种方法让线程按特定顺序执行，你可以用线程类的**join**()方法在一个线程中启动另一个线程，另外一个线程完成该线程继续执行。

代码举例：

为了确保三个线程的顺序你应该先启动最后一个(T3调用T2，T2调用T1)，这样T1就会先完成而T3最后完成

```
public class JoinTest {

    public static void main(String[] args) {

        // 创建线程对象
        Thread t1 = new Thread(() -> {
            System.out.println("t1");
        }) ;

        Thread t2 = new Thread(() -> {
            try {
                t1.join();                          // 加入线程t1,只有t1线程执行完毕以后，再次执行该线程
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("t2");
        }) ;


        Thread t3 = new Thread(() -> {
            try {
                t2.join();                              // 加入线程t2,只有t2线程执行完毕以后，再次执行该线程
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("t3");
        }) ;

        // 启动线程
        t1.start();
        t2.start();
        t3.start();

    }

}
```

###  notify()和 notifyAll()有什么区别？

> 难易程度：☆☆
> 出现频率：☆☆

notifyAll：唤醒所有wait的线程

notify：只随机唤醒一个 wait 线程

```
package com.itheima.basic;

public class WaitNotify {

    static boolean flag = false;
    static Object lock = new Object();

    public static void main(String[] args) {

        Thread t1 = new Thread(() -> {
            synchronized (lock){
                while (!flag){
                    System.out.println(Thread.currentThread().getName()+"...wating...");
                    try {
                        lock.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                System.out.println(Thread.currentThread().getName()+"...flag is true");
            }
        });

        Thread t2 = new Thread(() -> {
            synchronized (lock){
                while (!flag){
                    System.out.println(Thread.currentThread().getName()+"...wating...");
                    try {
                        lock.wait();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                System.out.println(Thread.currentThread().getName()+"...flag is true");
            }
        });

        Thread t3 = new Thread(() -> {
            synchronized (lock) {
                System.out.println(Thread.currentThread().getName() + " hold lock");
                lock.notifyAll();
                flag = true;
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        t1.start();
        t2.start();
        t3.start();

    }

}
```

###  在 java 中 wait 和 sleep 方法的不同？

> 难易程度：☆☆☆
> 出现频率：☆☆☆

参考回答：

共同点

1. wait() ，wait(long) 和 sleep(long) 的效果都是让当前线程暂时放弃 CPU 的使用权，进入阻塞状态

不同点

1. 方法归属不同
  1. sleep(long) 是 Thread 的静态方法
  2. 而 wait()，wait(long) 都是 Object 的成员方法，每个对象都有
2. 醒来时机不同
  1. 执行 sleep(long) 和 wait(long) 的线程都会在等待相应毫秒后醒来
  2. wait(long) 和 wait() 还可以被 notify 唤醒，wait() 如果不唤醒就一直等下去
  3. 它们都可以被打断唤醒
3. 锁特性不同（重点）
  1. wait 方法的调用必须先获取 wait 对象的锁，而 sleep 则无此限制
  2. wait 方法执行后会释放对象锁，允许其它线程获得该对象锁（我放弃 cpu，但你们还可以用）
  3. 而 sleep 如果在 synchronized 代码块中执行，并不会释放对象锁（我放弃 cpu，你们也用不了）

代码示例：

```
public class WaitSleepCase {

    static final Object LOCK = new Object();

    public static void main(String[] args) throws InterruptedException {
        sleeping();
    }

    private static void illegalWait() throws InterruptedException {
        LOCK.wait();
    }

    private static void waiting() throws InterruptedException {
        Thread t1 = new Thread(() -> {
            synchronized (LOCK) {
                try {
                    get("t").debug("waiting...");
                    LOCK.wait(5000L);
                } catch (InterruptedException e) {
                    get("t").debug("interrupted...");
                    e.printStackTrace();
                }
            }
        }, "t1");
        t1.start();

        Thread.sleep(100);
        synchronized (LOCK) {
            main.debug("other...");
        }

    }

    private static void sleeping() throws InterruptedException {
        Thread t1 = new Thread(() -> {
            synchronized (LOCK) {
                try {
                    get("t").debug("sleeping...");
                    Thread.sleep(5000L);
                } catch (InterruptedException e) {
                    get("t").debug("interrupted...");
                    e.printStackTrace();
                }
            }
        }, "t1");
        t1.start();

        Thread.sleep(100);
        synchronized (LOCK) {
            main.debug("other...");
        }
    }
}
```

###  如何停止一个正在运行的线程？

> 难易程度：☆☆
> 出现频率：☆☆

参考回答：

有三种方式可以停止线程

- 使用退出标志，使线程正常退出，也就是当run方法完成后线程终止
- 使用stop方法强行终止（不推荐，方法已作废）
- 使用interrupt方法中断线程

代码参考如下：

① **使用退出标志，使线程正常退出**。

```
public class MyInterrupt1 extends Thread {

    volatile boolean flag = false ;     // 线程执行的退出标记

    @Override
    public void run() {
        while(!flag) {
            System.out.println("MyThread...run...");
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        // 创建MyThread对象
        MyInterrupt1 t1 = new MyInterrupt1() ;
        t1.start();

        // 主线程休眠6秒
        Thread.sleep(6000);

        // 更改标记为true
        t1.flag = true ;

    }
}
```

② **使用stop方法强行终止**

```
public class MyInterrupt2 extends Thread {

    volatile boolean flag = false ;     // 线程执行的退出标记

    @Override
    public void run() {
        while(!flag) {
            System.out.println("MyThread...run...");
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {

        // 创建MyThread对象
        MyInterrupt2 t1 = new MyInterrupt2() ;
        t1.start();

        // 主线程休眠2秒
        Thread.sleep(6000);

        // 调用stop方法
        t1.stop();

    }
}
```

③ **使用interrupt方法中断线程**。

```
package com.itheima.basic;

public class MyInterrupt3 {

    public static void main(String[] args) throws InterruptedException {

        //1.打断阻塞的线程
        /*Thread t1 = new Thread(()->{
            System.out.println("t1 正在运行...");
            try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }, "t1");
        t1.start();
        Thread.sleep(500);
        t1.interrupt();
        System.out.println(t1.isInterrupted());*/


        //2.打断正常的线程
        Thread t2 = new Thread(()->{
            while(true) {
                Thread current = Thread.currentThread();
                boolean interrupted = current.isInterrupted();
                if(interrupted) {
                    System.out.println("打断状态："+interrupted);
                    break;
                }
            }
        }, "t2");
        t2.start();
        Thread.sleep(500);
//        t2.interrupt();

    }
}
```

## 线程中并发锁

### 讲一下synchronized关键字的底层原理？

> 难易程度：☆☆☆☆☆
> 出现频率：☆☆☆

####  基本使用

如下抢票的代码，如果不加锁，就会出现超卖或者一张票卖给多个人

Synchronized【对象锁】采用互斥的方式让同一时刻至多只有一个线程能持有【对象锁】，其它线程再想获取这个【对象锁】时就会阻塞住

```
public class TicketDemo {

    static Object lock = new Object();
    int ticketNum = 10;


    public synchronized void getTicket() {
        synchronized (this) {
            if (ticketNum <= 0) {
                return;
            }
            System.out.println(Thread.currentThread().getName() + "抢到一张票,剩余:" + ticketNum);
            // 非原子性操作
            ticketNum--;
        }
    }

    public static void main(String[] args) {
        TicketDemo ticketDemo = new TicketDemo();
        for (int i = 0; i < 20; i++) {
            new Thread(() -> {
                ticketDemo.getTicket();
            }).start();
        }
    }


}
```

####  Monitor

Monitor 被翻译为监视器，是由jvm提供，c++语言实现

在代码中想要体现monitor需要借助javap命令查看clsss的字节码，比如以下代码：

```
public class SyncTest {

    static final Object lock = new Object();
    static int counter = 0;
    public static void main(String[] args) {
        synchronized (lock) {
            counter++;
        }
    }
}
```

找到这个类的class文件，在class文件目录下执行`javap -v SyncTest.class`，反编译效果如下：

![img](https://image.hyly.net/i/2025/09/22/d5aa507962e07f0cf1ebf135706c8176-0.webp)

> monitorenter    上锁开始的地方
> monitorexit        解锁的地方
> 其中被monitorenter和monitorexit包围住的指令就是上锁的代码
> 有两个monitorexit的原因，第二个monitorexit是为了防止锁住的代码抛异常后不能及时释放锁

在使用了synchornized代码块时需要指定一个对象，所以synchornized也被称为对象锁

monitor主要就是跟这个对象产生关联，如下图

![img](https://image.hyly.net/i/2025/09/22/826fbadb0d8796ad08b649f852bc9cfe-0.webp)

Monitor内部具体的存储结构：

1. Owner：存储当前获取锁的线程的，只能有一个线程可以获取
2. EntryList：关联没有抢到锁的线程，处于Blocked状态的线程
3. WaitSet：关联调用了wait方法的线程，处于Waiting状态的线程

具体的流程：

1. 代码进入synchorized代码块，先让lock（对象锁）关联的monitor，然后判断Owner是否有线程持有
2. 如果没有线程持有，则让当前线程持有，表示该线程获取锁成功
3. 如果有线程持有，则让当前线程进入entryList进行阻塞，如果Owner持有的线程已经释放了锁，在EntryList中的线程去竞争锁的持有权（非公平）
4. 如果代码块中调用了wait()方法，则会进去WaitSet中进行等待

参考回答：

1. Synchronized【对象锁】采用互斥的方式让同一时刻至多只有一个线程能持有【对象锁】
2. 它的底层由monitor实现的，monitor是jvm级别的对象（ C++实现），线程获得锁需要使用对象（锁）关联monitor
3. 在monitor内部有三个属性，分别是owner、entrylist、waitset
4. 其中owner是关联的获得锁的线程，并且只能关联一个线程；entrylist关联的是处于阻塞状态的线程；waitset关联的是处于Waiting状态的线程

###  synchronized关键字的底层原理-进阶

Monitor实现的锁属于重量级锁，你了解过锁升级吗？

- Monitor实现的锁属于重量级锁，里面涉及到了用户态和内核态的切换、进程的上下文切换，成本较高，性能比较低。
- 在JDK 1.6引入了两种新型锁机制：偏向锁和轻量级锁，它们的引入是为了解决在没有多线程竞争或基本没有竞争的场景下因使用传统锁机制带来的性能开销问题。

####  对象的内存结构

在HotSpot虚拟机中，对象在内存中存储的布局可分为3块区域：对象头（Header）、实例数据（Instance Data）和对齐填充

![img](https://image.hyly.net/i/2025/09/22/925cd88eae473d04c4a45e9d6f497161-0.webp)

我们需要重点分析MarkWord对象头

####  MarkWord

![img](https://image.hyly.net/i/2025/09/22/48edb748576e422dcfd7f310fdaa5580-0.webp)

> hashcode：25位的对象标识Hash码
> age：对象分代年龄占4位
> biased_lock：偏向锁标识，占1位 ，0表示没有开始偏向锁，1表示开启了偏向锁
> thread：持有偏向锁的线程ID，占23位
> epoch：偏向时间戳，占2位
> ptr_to_lock_record：轻量级锁状态下，指向栈中锁记录的指针，占30位
> ptr_to_heavyweight_monitor：重量级锁状态下，指向对象监视器Monitor的指针，占30位

我们可以通过lock的标识，来判断是哪一种锁的等级

- 后三位是001表示无锁
- 后三位是101表示偏向锁
- 后两位是00表示轻量级锁
- 后两位是10表示重量级锁

####  再说Monitor重量级锁

每个 Java 对象都可以关联一个 Monitor 对象，如果使用 synchronized 给对象上锁（重量级）之后，**该对象头的Mark Word 中就被设置指向 Monitor 对象的指针**

![img](https://image.hyly.net/i/2025/09/22/3d253617e4529c82a7a9b80b0d192135-0.webp)

简单说就是：每个对象的对象头都可以设置monoitor的指针，让对象与monitor产生关联

####  轻量级锁

在很多的情况下，在Java程序运行时，同步块中的代码都是不存在竞争的，不同的线程交替的执行同步块中的代码。这种情况下，用重量级锁是没必要的。因此JVM引入了轻量级锁的概念。

```
static final Object obj = new Object();

public static void method1() {
    synchronized (obj) {
        // 同步块 A
        method2();
    }
}

public static void method2() {
    synchronized (obj) {
        // 同步块 B
    }
}
```

**加锁的流程**

1.在线程栈中创建一个Lock Record，将其obj字段指向锁对象。

![img](https://image.hyly.net/i/2025/09/22/3cfcf5439bb91ab7d67cfd7d04e57132-0.webp)

2.通过CAS指令将Lock Record的地址存储在对象头的mark word中（数据进行交换），如果对象处于无锁状态则修改成功，代表该线程获得了轻量级锁。

![img](https://image.hyly.net/i/2025/09/22/70fd7eba3b94b10ac557874b23c06cf6-0.webp)

3.如果是当前线程已经持有该锁了，代表这是一次锁重入。设置Lock Record第一部分为null，起到了一个重入计数器的作用。

![img](https://image.hyly.net/i/2025/09/22/41b0a93e63f70132c6051abce7505d73-0.webp)

4.如果CAS修改失败，说明发生了竞争，需要膨胀为重量级锁。

**解锁过程**

1.遍历线程栈,找到所有obj字段等于当前锁对象的Lock Record。

2.如果Lock Record的Mark Word为null，代表这是一次重入，将obj设置为null后continue。

![img](https://image.hyly.net/i/2025/09/22/31da30789ba7c52887629e7ff1016816-0.webp)

3.如果Lock Record的 Mark Word不为null，则利用CAS指令将对象头的mark word恢复成为无锁状态。如果失败则膨胀为重量级锁。

![img](https://image.hyly.net/i/2025/09/22/73ff2685717885bfa7b51019862bc0b8-0.webp)

####  偏向锁

轻量级锁在没有竞争时（就自己这个线程），每次重入仍然需要执行 CAS 操作。

Java 6 中引入了偏向锁来做进一步优化：只有第一次使用 CAS 将线程 ID 设置到对象的 Mark Word 头，之后发现

这个线程 ID 是自己的就表示没有竞争，不用重新 CAS。以后只要不发生竞争，这个对象就归该线程所有

```
static final Object obj = new Object();

public static void m1() {
    synchronized (obj) {
        // 同步块 A
        m2();
    }
}

public static void m2() {
    synchronized (obj) {
        // 同步块 B
        m3();
    }
}

public static void m3() {
    synchronized (obj) {

    }
}
```

**加锁的流程**

1.在线程栈中创建一个Lock Record，将其obj字段指向锁对象。

![img](https://image.hyly.net/i/2025/09/22/81dc00e8cf6c6e3b89f2e57edac782b6-0.webp)

2.通过CAS指令将Lock Record的**线程id**存储在对象头的mark word中，同时也设置偏向锁的标识为101，如果对象处于无锁状态则修改成功，代表该线程获得了偏向锁。

![img](https://image.hyly.net/i/2025/09/22/716c71a6d95ea88657c916381ba9ccc3-0.webp)

3.如果是当前线程已经持有该锁了，代表这是一次锁重入。设置Lock Record第一部分为null，起到了一个重入计数器的作用。与轻量级锁不同的时，这里不会再次进行cas操作，只是判断对象头中的线程id是否是自己，因为缺少了cas操作，性能相对轻量级锁更好一些

![img](https://image.hyly.net/i/2025/09/22/d3a54f35c395fb5e2e8e5125e8f67fb3-0.webp)

解锁流程参考轻量级锁

####  参考回答

Java中的synchronized有偏向锁、轻量级锁、重量级锁三种形式，分别对应了锁只被一个线程持有、不同线程交替持有锁、多线程竞争锁三种情况。

<figure class='table-figure'><table>
<thead>
<tr><th>&nbsp;</th><th><strong>描述</strong></th></tr></thead>
<tbody><tr><td>重量级锁</td><td>底层使用的Monitor实现，里面涉及到了用户态和内核态的切换、进程的上下文切换，成本较高，性能比较低。</td></tr><tr><td>轻量级锁</td><td>线程加锁的时间是错开的（也就是没有竞争），可以使用轻量级锁来优化。轻量级修改了对象头的锁标志，相对重量级锁性能提升很多。每次修改都是CAS操作，保证原子性</td></tr><tr><td>偏向锁</td><td>一段很长的时间内都只被一个线程使用锁，可以使用了偏向锁，在第一次获得锁时，会有一个CAS操作，之后该线程再获取锁，只需要判断mark  word中是否是自己的线程id即可，而不是开销相对较大的CAS命令</td></tr></tbody>
</table></figure>

**一旦锁发生了竞争，都会升级为重量级锁**

### 你谈谈 JMM（Java 内存模型）

> 难易程度：☆☆☆
> 出现频率：☆☆☆

JMM(Java Memory Model)Java内存模型,是java虚拟机规范中所定义的一种内存模型。

Java内存模型(Java Memory Model)描述了Java程序中各种变量(线程共享变量)的访问规则，以及在JVM中将变量存储到内存和从内存中读取变量这样的底层细节。

![img](https://image.hyly.net/i/2025/09/22/6867e8213caaf1f574ae44051b790e50-0.webp)

特点：

1. 所有的共享变量都存储于主内存(计算机的RAM)这里所说的变量指的是实例变量和类变量。不包含局部变量，因为局部变量是线程私有的，因此不存在竞争问题。
2. 每一个线程还存在自己的工作内存，线程的工作内存，保留了被线程使用的变量的工作副本。
3. 线程对变量的所有的操作(读，写)都必须在工作内存中完成，而不能直接读写主内存中的变量，不同线程之间也不能直接访问对方工作内存中的变量，线程间变量的值的传递需要通过主内存完成。

###  CAS 你知道吗？

> 难易程度：☆☆☆
> 出现频率：☆☆

#### 概述及基本工作流程

CAS的全称是： Compare And Swap(比较再交换)，它体现的一种乐观锁的思想，在无锁情况下保证线程操作共享数据的原子性。

在JUC（ java.util.concurrent ）包下实现的很多类都用到了CAS操作

1. AbstractQueuedSynchronizer（AQS框架）
2. AtomicXXX类

例子：

我们还是基于刚才学习过的JMM内存模型进行说明

1. 线程1与线程2都从主内存中获取变量int a = 100,同时放到各个线程的工作内存中

![img](https://image.hyly.net/i/2025/09/22/d58d495edd998a4ad5623373e8306b6d-0.webp)

> 一个当前内存值V、旧的预期值A、即将更新的值B，当且仅当旧的预期值A和内存值V相同时，将内存值修改为B并返回true，否则什么都不做，并返回false。如果CAS操作失败，通过自旋的方式等待并再次尝试，直到成功

1. 线程1操作：V：int a = 100，A：int a = 100，B：修改后的值：int a = 101 (a++)
  - 线程1拿A的值与主内存V的值进行比较，判断是否相等
  - 如果相等，则把B的值101更新到主内存中

![img](https://image.hyly.net/i/2025/09/22/fd0a79ac2c30e88e26c68b44ba493b29-0.webp)

1. 线程2操作：V：int a = 100，A：int a = 100，B：修改后的值：int a = 99(a--)
  - 线程2拿A的值与主内存V的值进行比较，判断是否相等(目前不相等，因为线程1已更新V的值99)
  - 不相等，则线程2更新失败

![img](https://image.hyly.net/i/2025/09/22/93b8484a71b5279151d043367d249a28-0.webp)

1. 自旋锁操作
  1. 因为没有加锁，所以线程不会陷入阻塞，效率较高
  2. 如果竞争激烈，重试频繁发生，效率会受影响

![img](https://image.hyly.net/i/2025/09/22/5946a741568d839627ca5721a683a5e8-0.webp)

需要不断尝试获取共享内存V中最新的值，然后再在新的值的基础上进行更新操作，如果失败就继续尝试获取新的值，直到更新成功

####  CAS 底层实现

CAS 底层依赖于一个 Unsafe 类来直接调用操作系统底层的 CAS 指令

![img](https://image.hyly.net/i/2025/09/22/86ac835a7e66354bb5847c79d4b2a34b-0.webp)

都是native修饰的方法，由系统提供的接口执行，并非java代码实现，一般的思路也都是自旋锁实现

![img](https://image.hyly.net/i/2025/09/22/2b4b18e539eb900ac13ce1c1e2885630-0.webp)

在java中比较常见使用有很多，比如ReentrantLock和Atomic开头的线程安全类，都调用了Unsafe中的方法

1. ReentrantLock中的一段CAS代码

![img](https://image.hyly.net/i/2025/09/22/c42d42f4f02af61f272ee34c3a89db73-0.webp)

####  乐观锁和悲观锁

1. CAS 是基于乐观锁的思想：最乐观的估计，不怕别的线程来修改共享变量，就算改了也没关系，我吃亏点再重试呗。
2. synchronized 是基于悲观锁的思想：最悲观的估计，得防着其它线程来修改共享变量，我上了锁你们都别想改，我改完了解开锁，你们才有机会。

### 请谈谈你对 volatile 的理解

> 难易程度：☆☆☆
> 出现频率：☆☆☆

一旦一个共享变量（类的成员变量、类的静态成员变量）被volatile修饰之后，那么就具备了两层语义：

####  保证线程间的可见性

保证了不同线程对这个变量进行操作时的可见性，即一个线程修改了某个变量的值，这新值对其他线程来说是立即可见的,volatile关键字会强制将修改的值立即写入主存。

一个典型的例子：永不停止的循环

```
package com.itheima.basic;


// 可见性例子
// -Xint
public class ForeverLoop {
    static boolean stop = false;

    public static void main(String[] args) {
        new Thread(() -> {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            stop = true;
            System.out.println("modify stop to true...");
        }).start();
        foo();
    }

    static void foo() {
        int i = 0;
        while (!stop) {
            i++;
        }
        System.out.println("stopped... c:"+ i);
    }
}
```

当执行上述代码的时候，发现foo()方法中的循环是结束不了的，也就说读取不到共享变量的值结束循环。

主要是因为在JVM虚拟机中有一个JIT（即时编辑器）给代码做了优化。

> 上述代码
> `while (!stop) { i++; }`
> 在很短的时间内，这个代码执行的次数太多了，当达到了一个阈值，JIT就会优化此代码，如下：
> `while (true) { i++; }`
> 当把代码优化成这样子以后，及时`stop`变量改变为了`false`也依然停止不了循环

解决方案：

第一：

在程序运行的时候加入vm参数`-Xint`表示禁用即时编辑器，不推荐，得不偿失（其他程序还要使用）

第二：

在修饰`stop`变量的时候加上`volatile`,表示当前代码禁用了即时编辑器，问题就可以解决，代码如下：

```
static volatile boolean stop = false;
```

####  禁止进行指令重排序

用 volatile 修饰共享变量会在读、写共享变量时加入不同的屏障，阻止其他读写操作越过屏障，从而达到阻止重排序的效果

![img](https://image.hyly.net/i/2025/09/22/734d7d24ad63e981ec280e770b645405-0.webp)

在去获取上面的结果的时候，有可能会出现4种情况

情况一：先执行actor2获取结果--->0,0(正常)

情况二：先执行actor1中的第一行代码，然后执行actor2获取结果--->0,1(正常)

情况三：先执行actor1中所有代码，然后执行actor2获取结果--->1,1(正常)

情况四：先执行actor1中第二行代码，然后执行actor2获取结果--->1,0(发生了指令重排序，影响结果)

**解决方案**

在变量上添加volatile，禁止指令重排序，则可以解决问题

![img](https://image.hyly.net/i/2025/09/22/f76b7429b7cf3cce44490a6b5c70a898-0.webp)

屏障添加的示意图

![img](https://image.hyly.net/i/2025/09/22/9ae051468e7c079c9a7d21009ecbd41e-0.webp)

1. 写操作加的屏障是阻止上方其它写操作越过屏障排到volatile变量写之下
2. 读操作加的屏障是阻止下方其它读操作越过屏障排到volatile变量读之上

**其他补充**

我们上面的解决方案是把volatile加在了int y这个变量上，我们能不能把它加在int x这个变量上呢？

下面代码使用volatile修饰了x变量

![img](https://image.hyly.net/i/2025/09/22/02ccc76df5e0e8bed567ad67ce2c4107-0.webp)

屏障添加的示意图

![img](https://image.hyly.net/i/2025/09/22/51359b21f02aabdcb940d557015425df-0.webp)

这样显然是不行的，主要是因为下面两个原则：

1. 写操作加的屏障是阻止上方其它写操作越过屏障排到volatile变量写之下
2. 读操作加的屏障是阻止下方其它读操作越过屏障排到volatile变量读之上

所以，现在我们就可以总结一个volatile使用的小妙招：

1. 写变量让volatile修饰的变量的在代码最后位置
2. 读变量让volatile修饰的变量的在代码最开始位置

###  什么是AQS？

> 难易程度：☆☆☆
> 出现频率：☆☆☆

#### 概述

全称是 AbstractQueuedSynchronizer，是阻塞式锁和相关的同步器工具的框架，它是构建锁或者其他同步组件的基础框架

AQS与Synchronized的区别

<figure class='table-figure'><table>
<thead>
<tr><th><strong>synchronized</strong></th><th><strong>AQS</strong></th></tr></thead>
<tbody><tr><td>关键字，c++ 语言实现</td><td>java  语言实现</td></tr><tr><td>悲观锁，自动释放锁</td><td>悲观锁，手动开启和关闭</td></tr><tr><td>锁竞争激烈都是重量级锁，性能差</td><td>锁竞争激烈的情况下，提供了多种解决方案</td></tr></tbody>
</table></figure>

AQS常见的实现类

1. ReentrantLock      阻塞式锁
2. Semaphore        信号量
3. CountDownLatch   倒计时锁

#### 工作机制

1. 在AQS中维护了一个使用了volatile修饰的state属性来表示资源的状态，0表示无锁，1表示有锁
2. 提供了基于 FIFO 的等待队列，类似于 Monitor 的 EntryList
3. 条件变量来实现等待、唤醒机制，支持多个条件变量，类似于 Monitor 的 WaitSet

![img](https://image.hyly.net/i/2025/09/22/20016f48a4a863e78ddb2e5f63dd97ca-0.webp)

> 线程0来了以后，去尝试修改state属性，如果发现state属性是0，就修改state状态为1，表示线程0抢锁成功
> 线程1和线程2也会先尝试修改state属性，发现state的值已经是1了，有其他线程持有锁，它们都会到FIFO队列中进行等待，
> FIFO是一个双向队列，head属性表示头结点，tail表示尾结点

**如果多个线程共同去抢这个资源是如何保证原子性的呢？**

![img](https://image.hyly.net/i/2025/09/22/d8a45ad69c89ff0f1e09063023c1b55e-0.webp)

在去修改state状态的时候，使用的cas自旋锁来保证原子性，确保只能有一个线程修改成功，修改失败的线程将会进入FIFO队列中等待

**AQS是公平锁吗，还是非公平锁？**

- 新的线程与队列中的线程共同来抢资源，是非公平锁
- 新的线程到队列中等待，只让队列中的head线程获取锁，是公平锁

> 比较典型的AQS实现类ReentrantLock，它默认就是非公平锁，新的线程与队列中的线程共同来抢资源

###  ReentrantLock的实现原理

> 难易程度：☆☆☆☆
> 出现频率：☆☆☆

####  概述

ReentrantLock翻译过来是可重入锁，相对于synchronized它具备以下特点：

1. 可中断
2. 可以设置超时时间
3. 可以设置公平锁
4. 支持多个条件变量
5. 与synchronized一样，都支持重入

![img](https://image.hyly.net/i/2025/09/22/3fa6c07b2f3ec590ebfab2bac8928aff-0.webp)

####  实现原理

ReentrantLock主要利用CAS+AQS队列来实现。它支持公平锁和非公平锁，两者的实现类似

构造方法接受一个可选的公平参数（默认非公平锁），当设置为true时，表示公平锁，否则为非公平锁。公平锁的效率往往没有非公平锁的效率高，在许多线程访问的情况下，公平锁表现出较低的吞吐量。

查看ReentrantLock源码中的构造方法：

![img](https://image.hyly.net/i/2025/09/22/75034f61813e21e3e2ff67024f913cf1-0.webp)

提供了两个构造方法，不带参数的默认为非公平

如果使用带参数的构造函数，并且传的值为true，则是公平锁

其中NonfairSync和FairSync这两个类父类都是Sync

![img](https://image.hyly.net/i/2025/09/22/4a3d28955e501757027a3dbe6850592e-0.webp)

而Sync的父类是AQS，所以可以得出ReentrantLock底层主要实现就是基于AQS来实现的

![img](https://image.hyly.net/i/2025/09/22/ae2dccc44d092e7662913633b39e6db7-0.webp)

**工作流程**

![img](https://image.hyly.net/i/2025/09/22/81247ecbe4751840782adf8339b82b34-0.webp)

1. 线程来抢锁后使用cas的方式修改state状态，修改状态成功为1，则让exclusiveOwnerThread属性指向当前线程，获取锁成功
2. 假如修改状态失败，则会进入双向队列中等待，head指向双向队列头部，tail指向双向队列尾部
3. 当exclusiveOwnerThread为null的时候，则会唤醒在双向队列中等待的线程
4. 公平锁则体现在按照先后顺序获取锁，非公平体现在不在排队的线程也可以抢锁

###  synchronized和Lock有什么区别 ?

> 难易程度：☆☆☆☆
> 出现频率：☆☆☆☆

参考回答

1. 语法层面
  1. synchronized 是关键字，源码在 jvm 中，用 c++ 语言实现
  2. Lock 是接口，源码由 jdk 提供，用 java 语言实现
  3. 使用 synchronized 时，退出同步代码块锁会自动释放，而使用 Lock 时，需要手动调用 unlock 方法释放锁
2. 功能层面
  1. 二者均属于悲观锁、都具备基本的互斥、同步、锁重入功能
  2. Lock 提供了许多 synchronized 不具备的功能，例如获取等待状态、公平锁、可打断、可超时、多条件变量
  3. Lock 有适合不同场景的实现，如 ReentrantLock， ReentrantReadWriteLock
3. 性能层面
  1. 在没有竞争时，synchronized 做了很多优化，如偏向锁、轻量级锁，性能不赖
  2. 在竞争激烈时，Lock 的实现通常会提供更好的性能

###  死锁产生的条件是什么？

> 难易程度：☆☆☆☆
> 出现频率：☆☆☆

**死锁**：一个线程需要同时获取多把锁，这时就容易发生死锁

> 例如：
> t1 线程获得A对象锁，接下来想获取B对象的锁
> t2 线程获得B对象锁，接下来想获取A对象的锁

代码如下：

```
package com.itheima.basic;

import static java.lang.Thread.sleep;

public class Deadlock {

    public static void main(String[] args) {
        Object A = new Object();
        Object B = new Object();
        Thread t1 = new Thread(() -> {
            synchronized (A) {
                System.out.println("lock A");
                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
                synchronized (B) {
                    System.out.println("lock B");
                    System.out.println("操作...");
                }
            }
        }, "t1");

        Thread t2 = new Thread(() -> {
            synchronized (B) {
                System.out.println("lock B");
                try {
                    sleep(500);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
                synchronized (A) {
                    System.out.println("lock A");
                    System.out.println("操作...");
                }
            }
        }, "t2");
        t1.start();
        t2.start();
    }
}
```

控制台输出结果

![img](https://image.hyly.net/i/2025/09/22/c9a86fecfad3471fa38404aa1891e0f2-0.webp)

此时程序并没有结束，这种现象就是死锁现象...线程t1持有A的锁等待获取B锁，线程t2持有B的锁等待获取A的锁。

###  如何进行死锁诊断？

> 难易程度：☆☆☆
> 出现频率：☆☆☆

当程序出现了死锁现象，我们可以使用jdk自带的工具：jps和 jstack

步骤如下：

第一：查看运行的线程

![img](https://image.hyly.net/i/2025/09/22/0604c6f0a7afb0fcb35249b9d3ddb062-0.webp)

第二：使用jstack查看线程运行的情况，下图是截图的关键信息

运行命令：`jstack -l 46032`

![img](https://image.hyly.net/i/2025/09/22/41168f382e394185f53020a35f7dbd88-0.webp)

**其他解决工具，可视化工具**

1. jconsole

用于对jvm的内存，线程，类 的监控，是一个基于 jmx 的 GUI 性能监控工具

打开方式：java 安装目录 bin目录下 直接启动 jconsole.exe 就行

1. VisualVM：故障处理工具

能够监控线程，内存情况，查看方法的CPU时间和内存中的对 象，已被GC的对象，反向查看分配的堆栈

打开方式：java 安装目录 bin目录下 直接启动 jvisualvm.exe就行

###   ConcurrentHashMap

> 难易程度：☆☆☆
> 出现频率：☆☆☆☆

ConcurrentHashMap 是一种线程安全的高效Map集合

底层数据结构：

1. JDK1.7底层采用分段的数组+链表实现
2. JDK1.8 采用的数据结构跟HashMap1.8的结构一样，数组+链表/红黑二叉树。

#### （1） JDK1.7中concurrentHashMap

数据结构

![img](https://image.hyly.net/i/2025/09/22/8243c7f892ab53a16eeddb7cc4b29cd6-0.webp)

> 提供了一个segment数组，在初始化ConcurrentHashMap 的时候可以指定数组的长度，默认是16，一旦初始化之后中间不可扩容
> 在每个segment中都可以挂一个HashEntry数组，数组里面可以存储具体的元素，HashEntry数组是可以扩容的
> 在HashEntry存储的数组中存储的元素，如果发生冲突，则可以挂单向链表

存储流程

![img](https://image.hyly.net/i/2025/09/22/bd1cb3f302f52397db31d528f41734af-0.webp)

1. 先去计算key的hash值，然后确定segment数组下标
2. 再通过hash值确定hashEntry数组中的下标存储数据
3. 在进行操作数据的之前，会先判断当前segment对应下标位置是否有线程进行操作，为了线程安全使用的是ReentrantLock进行加锁，如果获取锁是被会使用cas自旋锁进行尝试

#### （2） JDK1.8中concurrentHashMap

在JDK1.8中，放弃了Segment臃肿的设计，数据结构跟HashMap的数据结构是一样的：数组+红黑树+链表

采用 CAS + Synchronized来保证并发安全进行实现

1. CAS控制数组节点的添加
2. synchronized只锁定当前链表或红黑二叉树的首节点，只要hash不冲突，就不会产生并发的问题 , 效率得到提升

![img](https://image.hyly.net/i/2025/09/22/b2dbec319354601755c81603163d4f2a-0.webp)

###  导致并发程序出现问题的根本原因是什么

> 难易程度：☆☆☆
> 出现频率：☆☆☆

Java并发编程三大特性

1. 原子性
2. 可见性
3. 有序性

#### （1）原子性

一个线程在CPU中操作不可暂停，也不可中断，要不执行完成，要不不执行

比如，如下代码能保证原子性吗？

![img](https://image.hyly.net/i/2025/09/22/e5ae124c3988326b0c39c74b13326f37-0.webp)

以上代码会出现超卖或者是一张票卖给同一个人，执行并不是原子性的

解决方案：

1.synchronized：同步加锁

2.JUC里面的lock：加锁

![img](https://image.hyly.net/i/2025/09/22/b2c04f8b9a228a34779b06735650d7be-0.webp)

#### （3）内存可见性

内存可见性：让一个线程对共享变量的修改对另一个线程可见

比如，以下代码不能保证内存可见性

![img](https://image.hyly.net/i/2025/09/22/dd112fa792b76f5a147a11500acbba69-0.webp)

解决方案：

1. synchronized
2. volatile（推荐）
3. LOCK

#### （3）有序性

指令重排：处理器为了提高程序运行效率，可能会对输入代码进行优化，它不保证程序中各个语句的执行先后顺序同代码中的顺序一致，但是它会保证程序最终执行结果和代码顺序执行的结果是一致的

还是之前的例子，如下代码：

![img](https://image.hyly.net/i/2025/09/22/e47a542dcdf720a189e68f1aa344abbd-0.webp)

解决方案：

1. volatile

## 线程池

###  说一下线程池的核心参数（线程池的执行原理知道嘛）

> 难易程度：☆☆☆
> 出现频率：☆☆☆☆

线程池核心参数主要参考ThreadPoolExecutor这个类的7个参数的构造函数

![img](https://image.hyly.net/i/2025/09/22/46a45f307d9d811fdbcc2cf436116d57-0.webp)

1. corePoolSize 核心线程数目
2. maximumPoolSize 最大线程数目 = (核心线程+救急线程的最大数目)
3. keepAliveTime 生存时间 - 救急线程的生存时间，生存时间内没有新任务，此线程资源会释放
4. unit 时间单位 - 救急线程的生存时间单位，如秒、毫秒等
5. workQueue - 当没有空闲核心线程时，新来任务会加入到此队列排队，队列满会创建救急线程执行任务
6. threadFactory 线程工厂 - 可以定制线程对象的创建，例如设置线程名字、是否是守护线程等
7. handler 拒绝策略 - 当所有线程都在繁忙，workQueue 也放满时，会触发拒绝策略

**工作流程**

![img](https://image.hyly.net/i/2025/09/22/d8321a1ab82ef2e9e7b81f3d47e1e797-0.webp)

> 1，任务在提交的时候，首先判断核心线程数是否已满，如果没有满则直接添加到工作线程执行
> 2，如果核心线程数满了，则判断阻塞队列是否已满，如果没有满，当前任务存入阻塞队列
> 3，如果阻塞队列也满了，则判断线程数是否小于最大线程数，如果满足条件，则使用临时线程执行任务
> 如果核心或临时线程执行完成任务后会检查阻塞队列中是否有需要执行的线程，如果有，则使用非核心线程执行任务
> 4，如果所有线程都在忙着（核心线程+临时线程），则走拒绝策略

拒绝策略：

1.AbortPolicy：直接抛出异常，默认策略；

2.CallerRunsPolicy：用调用者所在的线程来执行任务；

3.DiscardOldestPolicy：丢弃阻塞队列中靠最前的任务，并执行当前任务；

4.DiscardPolicy：直接丢弃任务；

参考代码：

```
public class TestThreadPoolExecutor {

    static class MyTask implements Runnable {
        private final String name;
        private final long duration;

        public MyTask(String name) {
            this(name, 0);
        }

        public MyTask(String name, long duration) {
            this.name = name;
            this.duration = duration;
        }

        @Override
        public void run() {
            try {
                LoggerUtils.get("myThread").debug("running..." + this);
                Thread.sleep(duration);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        @Override
        public String toString() {
            return "MyTask(" + name + ")";
        }
    }

    public static void main(String[] args) throws InterruptedException {
        AtomicInteger c = new AtomicInteger(1);
        ArrayBlockingQueue<Runnable> queue = new ArrayBlockingQueue<>(2);
        ThreadPoolExecutor threadPool = new ThreadPoolExecutor(
                2,
                3,
                0,
                TimeUnit.MILLISECONDS,
                queue,
                r -> new Thread(r, "myThread" + c.getAndIncrement()),
                new ThreadPoolExecutor.AbortPolicy());
        showState(queue, threadPool);
        threadPool.submit(new MyTask("1", 3600000));
        showState(queue, threadPool);
        threadPool.submit(new MyTask("2", 3600000));
        showState(queue, threadPool);
        threadPool.submit(new MyTask("3"));
        showState(queue, threadPool);
        threadPool.submit(new MyTask("4"));
        showState(queue, threadPool);
        threadPool.submit(new MyTask("5",3600000));
        showState(queue, threadPool);
        threadPool.submit(new MyTask("6"));
        showState(queue, threadPool);
    }

    private static void showState(ArrayBlockingQueue<Runnable> queue, ThreadPoolExecutor threadPool) {
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        List<Object> tasks = new ArrayList<>();
        for (Runnable runnable : queue) {
            try {
                Field callable = FutureTask.class.getDeclaredField("callable");
                callable.setAccessible(true);
                Object adapter = callable.get(runnable);
                Class<?> clazz = Class.forName("java.util.concurrent.Executors$RunnableAdapter");
                Field task = clazz.getDeclaredField("task");
                task.setAccessible(true);
                Object o = task.get(adapter);
                tasks.add(o);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        LoggerUtils.main.debug("pool size: {}, queue: {}", threadPool.getPoolSize(), tasks);
    }

}
```

###  线程池中有哪些常见的阻塞队列

> 难易程度：☆☆☆
> 出现频率：☆☆☆

workQueue - 当没有空闲核心线程时，新来任务会加入到此队列排队，队列满会创建救急线程执行任务

比较常见的有4个，用的最多是ArrayBlockingQueue和LinkedBlockingQueue

1.ArrayBlockingQueue：基于数组结构的有界阻塞队列，FIFO。

2.LinkedBlockingQueue：基于链表结构的有界阻塞队列，FIFO。

3.DelayedWorkQueue ：是一个优先级队列，它可以保证每次出队的任务都是当前队列中执行时间最靠前的

4.SynchronousQueue：不存储元素的阻塞队列，每个插入操作都必须等待一个移出操作。

**ArrayBlockingQueue的LinkedBlockingQueue区别**

| **LinkedBlockingQueue**          | **ArrayBlockingQueue** |
| -------------------------------- | ---------------------- |
| 默认无界，支持有界               | 强制有界               |
| 底层是链表                       | 底层是数组             |
| 是懒惰的，创建节点的时候添加数据 | 提前初始化 Node  数组  |
| 入队会生成新 Node                | Node需要是提前创建好的 |
| 两把锁（头尾）                   | 一把锁                 |

左边是LinkedBlockingQueue加锁的方式，右边是ArrayBlockingQueue加锁的方式

1. LinkedBlockingQueue读和写各有一把锁，性能相对较好
2. ArrayBlockingQueue只有一把锁，读和写公用，性能相对于LinkedBlockingQueue差一些

![img](https://image.hyly.net/i/2025/09/22/2cabdd707e2c54255d5b9b0d3fbcd1e0-0.webp)

### 如何确定核心线程数

> 难易程度：☆☆☆☆
> 出现频率：☆☆☆

在设置核心线程数之前，需要先熟悉一些执行线程池执行任务的类型

- IO密集型任务

一般来说：文件读写、DB读写、网络请求等

推荐：核心线程数大小设置为2N+1    （N为计算机的CPU核数）

- CPU密集型任务

一般来说：计算型代码、Bitmap转换、Gson转换等

推荐：核心线程数大小设置为N+1    （N为计算机的CPU核数）

java代码查看CPU核数

![img](https://image.hyly.net/i/2025/09/22/e0e96d395bba32b00c0efa708355e5b4-0.webp)

**参考回答：**

① 高并发、任务执行时间短 -->（ CPU核数+1 ），减少线程上下文的切换

② 并发不高、任务执行时间长

- IO密集型的任务 --> (CPU核数 * 2 + 1)
- 计算密集型任务 --> （ CPU核数+1 ）

③ 并发高、业务执行时间长，解决这种类型任务的关键不在于线程池而在于整体架构的设计，看看这些业务里面某些数据是否能做缓存是第一步，增加服务器是第二步，至于线程池的设置，设置参考（2）

###  线程池的种类有哪些

> 难易程度：☆☆☆
> 出现频率：☆☆☆

在java.util.concurrent.Executors类中提供了大量创建连接池的静态方法，常见就有四种

1. 创建使用固定线程数的线程池

![img](https://image.hyly.net/i/2025/09/22/0fb5da5c95cbe3bea7d3af3c11f84df6-0.webp)

1. 核心线程数与最大线程数一样，没有救急线程
2. 阻塞队列是LinkedBlockingQueue，最大容量为Integer.MAX_VALUE
3. 适用场景：适用于任务量已知，相对耗时的任务
4. 案例：

```
public class FixedThreadPoolCase {

    static class FixedThreadDemo implements Runnable{
        @Override
        public void run() {
            String name = Thread.currentThread().getName();
            for (int i = 0; i < 2; i++) {
                System.out.println(name + ":" + i);
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //创建一个固定大小的线程池，核心线程数和最大线程数都是3
        ExecutorService executorService = Executors.newFixedThreadPool(3);

        for (int i = 0; i < 5; i++) {
            executorService.submit(new FixedThreadDemo());
            Thread.sleep(10);
        }

        executorService.shutdown();
    }

}
```

1. 单线程化的线程池，它只会用唯一的工作线程来执行任 务，保证所有任务按照指定顺序(FIFO)执行

![img](https://image.hyly.net/i/2025/09/22/02cbbd1402af99447aa4c21f691db5fc-0.webp)

1. 核心线程数和最大线程数都是1
2. 阻塞队列是LinkedBlockingQueue，最大容量为Integer.MAX_VALUE
3. 适用场景：适用于按照顺序执行的任务
4. 案例：

```
public class NewSingleThreadCase {

    static int count = 0;

    static class Demo implements Runnable {
        @Override
        public void run() {
            count++;
            System.out.println(Thread.currentThread().getName() + ":" + count);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //单个线程池，核心线程数和最大线程数都是1
        ExecutorService exec = Executors.newSingleThreadExecutor();

        for (int i = 0; i < 10; i++) {
            exec.execute(new Demo());
            Thread.sleep(5);
        }
        exec.shutdown();
    }

}
```

1. 可缓存线程池

![img](https://image.hyly.net/i/2025/09/22/ca9b2e3db7043c58dfc8abc0282b15d4-0.webp)

- 核心线程数为0
- 最大线程数是Integer.MAX_VALUE
- 阻塞队列为SynchronousQueue:不存储元素的阻塞队列，每个插入操作都必须等待一个移出操作。
- 适用场景：适合任务数比较密集，但每个任务执行时间较短的情况
- 案例：

```
public class CachedThreadPoolCase {

    static class Demo implements Runnable {
        @Override
        public void run() {
            String name = Thread.currentThread().getName();
            try {
                //修改睡眠时间，模拟线程执行需要花费的时间
                Thread.sleep(100);

                System.out.println(name + "执行完了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //创建一个缓存的线程，没有核心线程数，最大线程数为Integer.MAX_VALUE
        ExecutorService exec = Executors.newCachedThreadPool();
        for (int i = 0; i < 10; i++) {
            exec.execute(new Demo());
            Thread.sleep(1);
        }
        exec.shutdown();
    }

}
```

1. 提供了“延迟”和“周期执行”功能的ThreadPoolExecutor。

![img](https://image.hyly.net/i/2025/09/22/2aa5d395592fc919b3fc3c8f695c3512-0.webp)

- 适用场景：有定时和延迟执行的任务
- 案例：

```
public class ScheduledThreadPoolCase {

    static class Task implements Runnable {
        @Override
        public void run() {
            try {
                String name = Thread.currentThread().getName();

                System.out.println(name + ", 开始：" + new Date());
                Thread.sleep(1000);
                System.out.println(name + ", 结束：" + new Date());

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        //按照周期执行的线程池，核心线程数为2，最大线程数为Integer.MAX_VALUE
        ScheduledExecutorService scheduledThreadPool = Executors.newScheduledThreadPool(2);
        System.out.println("程序开始：" + new Date());

        /**
         * schedule 提交任务到线程池中
         * 第一个参数：提交的任务
         * 第二个参数：任务执行的延迟时间
         * 第三个参数：时间单位
         */
        scheduledThreadPool.schedule(new Task(), 0, TimeUnit.SECONDS);
        scheduledThreadPool.schedule(new Task(), 1, TimeUnit.SECONDS);
        scheduledThreadPool.schedule(new Task(), 5, TimeUnit.SECONDS);

        Thread.sleep(5000);

        // 关闭线程池
        scheduledThreadPool.shutdown();

    }

}
```

### 为什么不建议用Executors创建线程池

> 难易程度：☆☆☆
> 出现频率：☆☆☆

参考阿里开发手册《Java开发手册-嵩山版》

![img](https://image.hyly.net/i/2025/09/22/543fcd88183cb364cd6cd828d6d8a6dc-0.webp)

## 线程使用场景问题

###  线程池使用场景CountDownLatch、Future（你们项目哪里用到了多线程）

> 难易程度：☆☆☆
> 出现频率：☆☆☆☆

####  CountDownLatch

CountDownLatch（闭锁/倒计时锁）用来进行线程同步协作，等待所有线程完成倒计时（一个或者多个线程，等待其他多个线程完成某件事情之后才能执行）

1. 其中构造参数用来初始化等待计数值
2. await() 用来等待计数归零
3. countDown() 用来让计数减一

![img](https://image.hyly.net/i/2025/09/22/265529510b5f712bb3c6ad8d394c35c6-0.webp)

案例代码：

```
public class CountDownLatchDemo {

    public static void main(String[] args) throws InterruptedException {
        //初始化了一个倒计时锁 参数为 3
        CountDownLatch latch = new CountDownLatch(3);

        new Thread(() -> {
            System.out.println(Thread.currentThread().getName()+"-begin...");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            //count--
            latch.countDown();
            System.out.println(Thread.currentThread().getName()+"-end..." +latch.getCount());
        }).start();
        new Thread(() -> {
            System.out.println(Thread.currentThread().getName()+"-begin...");
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            //count--
            latch.countDown();
            System.out.println(Thread.currentThread().getName()+"-end..." +latch.getCount());
        }).start();
        new Thread(() -> {
            System.out.println(Thread.currentThread().getName()+"-begin...");
            try {
                Thread.sleep(1500);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            //count--
            latch.countDown();
            System.out.println(Thread.currentThread().getName()+"-end..." +latch.getCount());
        }).start();
        String name = Thread.currentThread().getName();
        System.out.println(name + "-waiting...");
        //等待其他线程完成
        latch.await();
        System.out.println(name + "-wait end...");
    }
    
}
```

#### 案例一（es数据批量导入）

在我们项目上线之前，我们需要把数据库中的数据一次性的同步到es索引库中，但是当时的数据好像是1000万左右，一次性读取数据肯定不行（oom异常），当时我就想到可以使用线程池的方式导入，利用CountDownLatch来控制，就能避免一次性加载过多，防止内存溢出

整体流程就是通过CountDownLatch+线程池配合去执行

![img](https://image.hyly.net/i/2025/09/22/6aa9c838fc02762cc1e92ec725b4c352-0.webp)

详细实现流程：

![img](https://image.hyly.net/i/2025/09/22/0dc30758e8a81218a6db8a4ea89b29c6-0.webp)

> 详细实现代码，请查看当天代码

#### 案例二（数据汇总）

在一个电商网站中，用户下单之后，需要查询数据，数据包含了三部分：订单信息、包含的商品、物流信息；这三块信息都在不同的微服务中进行实现的，我们如何完成这个业务呢？

![img](https://image.hyly.net/i/2025/09/22/d73c94496158ebdbba587d104817cfe6-0.webp)

> 详细实现代码，请查看当天代码

- 在实际开发的过程中，难免需要调用多个接口来汇总数据，如果所有接口（或部分接口）的没有依赖关系，就可以使用线程池+future来提升性能
- 报表汇总

![img](https://image.hyly.net/i/2025/09/22/7a9dea19ab6747df91b3cf312ee28e83-0.webp)

#### 案例二（异步调用）

![img](https://image.hyly.net/i/2025/09/22/a3388d5102e9205c1a2c22888a6e5e2d-0.webp)

在进行搜索的时候，需要保存用户的搜索记录，而搜索记录不能影响用户的正常搜索，我们通常会开启一个线程去执行历史记录的保存，在新开启的线程执行的过程中，可以利用线程提交任务

### 如何控制某个方法允许并发访问线程的数量？

> 难易程度：☆☆☆
> 出现频率：☆☆

Semaphore [ˈsɛməˌfɔr] 信号量，是JUC包下的一个工具类，我们可以通过其限制执行的线程数量，达到限流的效果

当一个线程执行时先通过其方法进行获取许可操作，获取到许可的线程继续执行业务逻辑，当线程执行完成后进行释放许可操作，未获取达到许可的线程进行等待或者直接结束。

Semaphore两个重要的方法

lsemaphore.acquire()： 请求一个信号量，这时候的信号量个数-1（一旦没有可使用的信号量，也即信号量个数变为负数时，再次请求的时候就会阻塞，直到其他线程释放了信号量）

lsemaphore.release()：释放一个信号量，此时信号量个数+1

线程任务类：

```
public class SemaphoreCase {
    public static void main(String[] args) {
        // 1. 创建 semaphore 对象
        Semaphore semaphore = new Semaphore(3);
        // 2. 10个线程同时运行
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {

                try {
                    // 3. 获取许可
                    semaphore.acquire();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                try {
                    System.out.println("running...");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println("end...");
                } finally {
                    // 4. 释放许可
                    semaphore.release();
                }
            }).start();
        }
    }

}
```

## 其他

###  谈谈你对ThreadLocal的理解

> 难易程度：☆☆☆
> 出现频率：☆☆☆☆

####  概述

ThreadLocal是多线程中对于解决线程安全的一个操作类，它会为每个线程都分配一个独立的线程副本从而解决了变量并发访问冲突的问题。ThreadLocal 同时实现了线程内的资源共享

案例：使用JDBC操作数据库时，会将每一个线程的Connection放入各自的ThreadLocal中，从而保证每个线程都在各自的 Connection 上进行数据库的操作，避免A线程关闭了B线程的连接。

![img](https://image.hyly.net/i/2025/09/22/58242764f5450ad775234e48ea9a4497-0.webp)

####  ThreadLocal基本使用

三个主要方法：

1. set(value) 设置值
2. get() 获取值
3. remove() 清除值

```
public class ThreadLocalTest {
    static ThreadLocal<String> threadLocal = new ThreadLocal<>();

    public static void main(String[] args) {
        new Thread(() -> {
            String name = Thread.currentThread().getName();
            threadLocal.set("itcast");
            print(name);
            System.out.println(name + "-after remove : " + threadLocal.get());
        }, "t1").start();
        new Thread(() -> {
            String name = Thread.currentThread().getName();
            threadLocal.set("itheima");
            print(name);
            System.out.println(name + "-after remove : " + threadLocal.get());
        }, "t2").start();
    }

    static void print(String str) {
        //打印当前线程中本地内存中本地变量的值
        System.out.println(str + " :" + threadLocal.get());
        //清除本地内存中的本地变量
        threadLocal.remove();
    }

}
```

####  ThreadLocal的实现原理&源码解析

ThreadLocal本质来说就是一个线程内部存储类，从而让多个线程只操作自己内部的值，从而实现线程数据隔离

![img](https://image.hyly.net/i/2025/09/22/a6bc5a6003bb69c5d2c518e6f562e224-0.webp)

在ThreadLocal中有一个内部类叫做ThreadLocalMap，类似于HashMap

ThreadLocalMap中有一个属性table数组，这个是真正存储数据的位置

**set方法**

![img](https://image.hyly.net/i/2025/09/22/850418fe576d8aba2182b7e5bfe4eba5-0.webp)

**get方法/remove方法**

![ ](https://image.hyly.net/i/2025/09/22/ca921fdfaf037136f0b3576043238ada-0.webp)

####  ThreadLocal-内存泄露问题

Java对象中的四种引用类型：强引用、软引用、弱引用、虚引用

- 强引用：最为普通的引用方式，表示一个对象处于有用且必须的状态，如果一个对象具有强引用，则GC并不会回收它。即便堆中内存不足了，宁可出现OOM，也不会对其进行回收

![img](https://image.hyly.net/i/2025/09/22/51f524e5dba03700302e8a890013c354-0.webp)

- 弱引用：表示一个对象处于可能有用且非必须的状态。在GC线程扫描内存区域时，一旦发现弱引用，就会回收到弱引用相关联的对象。对于弱引用的回收，无关内存区域是否足够，一旦发现则会被回收

![img](https://image.hyly.net/i/2025/09/22/f9ef5ef16a85bb80c8374cf87acbbf93-0.webp)

每一个Thread维护一个ThreadLocalMap，在ThreadLocalMap中的Entry对象继承了WeakReference。其中key为使用弱引用的ThreadLocal实例，value为线程变量的副本

![img](https://image.hyly.net/i/2025/09/22/06d3ec9828174f4b56f94299678fc922-0.webp)

在使用ThreadLocal的时候，强烈建议：**务必手动remove**

##  真实面试还原

### 线程的基础知识

> **面试官**：聊一下并行和并发有什么区别？
> **候选人：**
> 是这样的~~
> 现在都是多核CPU，在多核CPU下
> 并发是同一时间应对多件事情的能力，多个线程轮流使用一个或多个CPU
> 并行是同一时间动手做多件事情的能力，4核CPU同时执行4个线程
>
> **面试官**：说一下线程和进程的区别？
> **候选人：**
> 嗯，好~
> 进程是正在运行程序的实例，进程中包含了线程，每个线程执行不同的任务
> 不同的进程使用不同的内存空间，在当前进程下的所有线程可以共享内存空间
> 线程更轻量，线程上下文切换成本一般上要比进程上下文切换低(上下文切换指的是从一个线程切换到另一个线程)
>
> **面试官**：如果在java中创建线程有哪些方式？
> **候选人：**
> 在java中一共有四种常见的创建方式，分别是：继承Thread类、实现runnable接口、实现Callable接口、线程池创建线程。通常情况下，我们项目中都会采用线程池的方式创建线程。
> **面试官**：好的，刚才你说的runnable 和 callable 两个接口创建线程有什么不同呢？
> **候选人：**
> 是这样的~
> 最主要的两个线程一个是有返回值，一个是没有返回值的。
> Runnable 接口run方法无返回值；Callable接口call方法有返回值，是个泛型，和Future、FutureTask配合可以用来获取异步执行的结果
> 还有一个就是，他们异常处理也不一样。Runnable接口run方法只能抛出运行时异常，也无法捕获处理；Callable接口call方法允许抛出异常，可以获取异常信息
> 在实际开发中，如果需要拿到执行的结果，需要使用Callalbe接口创建线程，调用FutureTask.get()得到可以得到返回值，此方法会阻塞主进程的继续往下执行，如果不调用不会阻塞。
>
> **面试官**：线程包括哪些状态，状态之间是如何变化的？
> **候选人：**
> 在JDK中的Thread类中的枚举State里面定义了6中线程的状态分别是：新建、可运行、终结、阻塞、等待和有时限等待六种。
> 关于线程的状态切换情况比较多。我分别介绍一下
> 当一个线程对象被创建，但还未调用 start 方法时处于**新建**状态，调用了 start 方法，就会由**新建**进入**可运行**状态。如果线程内代码已经执行完毕，由**可运行**进入**终结**状态。当然这些是一个线程正常执行情况。
> 如果线程获取锁失败后，由**可运行**进入 Monitor 的阻塞队列**阻塞**，只有当持锁线程释放锁时，会按照一定规则唤醒阻塞队列中的**阻塞**线程，唤醒后的线程进入**可运行**状态
> 如果线程获取锁成功后，但由于条件不满足，调用了 wait() 方法，此时从**可运行**状态释放锁**等待**状态，当其它持锁线程调用 notify() 或 notifyAll() 方法，会恢复为**可运行**状态
> 还有一种情况是调用 sleep(long) 方法也会从**可运行**状态进入**有时限等待**状态，不需要主动唤醒，超时时间到自然恢复为**可运行**状态
> **面试官**：嗯，好的，刚才你说的线程中的 wait 和 sleep方法有什么不同呢？
> **候选人：**
> 它们两个的相同点是都可以让当前线程暂时放弃 CPU 的使用权，进入阻塞状态。
> 不同点主要有三个方面：
> 第一：方法归属不同
> sleep(long) 是 Thread 的静态方法。而 wait()，是 Object 的成员方法，每个对象都有
> 第二：线程醒来时机不同
> 线程执行 sleep(long) 会在等待相应毫秒后醒来，而 wait() 需要被 notify 唤醒，wait() 如果不唤醒就一直等下去
> 第三：锁特性不同
> wait 方法的调用必须先获取 wait 对象的锁，而 sleep 则无此限制
> wait 方法执行后会释放对象锁，允许其它线程获得该对象锁（相当于我放弃 cpu，但你们还可以用）
> 而 sleep 如果在 synchronized 代码块中执行，并不会释放对象锁（相当于我放弃 cpu，你们也用不了）
> **面试官**：好的，我现在举一个场景，你来分析一下怎么做，新建 T1、T2、T3 三个线程，如何保证它们按顺序执行？
> **候选人：**
> 嗯~~，我思考一下 （适当的思考或想一下属于正常情况，脱口而出反而太假[背诵痕迹]）
> 可以这么做，在多线程中有多种方法让线程按特定顺序执行，可以用线程类的**join**()方法在一个线程中启动另一个线程，另外一个线程完成该线程继续执行。
> 比如说：
> 使用join方法，T3调用T2，T2调用T1，这样就能确保T1就会先完成而T3最后完成
> **面试官**：在我们使用线程的过程中，有两个方法。线程的 run()和 start()有什么区别？
> **候选人：**
> start方法用来启动线程，通过该线程调用run方法执行run方法中所定义的逻辑代码。start方法只能被调用一次。run方法封装了要被线程执行的代码，可以被调用多次。
> **面试官**：那如何停止一个正在运行的线程呢？
> **候选人**：
> 有三种方式可以停止线程
> 第一：可以使用退出标志，使线程正常退出，也就是当run方法完成后线程终止，一般我们加一个标记
> 第二：可以使用线程的stop方法强行终止，不过一般不推荐，这个方法已作废
> 第三：可以使用线程的interrupt方法中断线程，内部其实也是使用中断标志来中断线程
> 我们项目中使用的话，建议使用第一种或第三种方式中断线程

###  线程中并发锁

> **面试官**：讲一下synchronized关键字的底层原理？
> **候选人**：
> 嗯，好的，
> synchronized 底层使用的JVM级别中的Monitor 来决定当前线程是否获得了锁，如果某一个线程获得了锁，在没有释放锁之前，其他线程是不能或得到锁的。synchronized 属于悲观锁。
> synchronized 因为需要依赖于JVM级别的Monitor ，相对性能也比较低。
> **面试官**：好的，你能具体说下Monitor 吗？
> **候选人**：
> monitor对象存在于每个Java对象的对象头中，synchronized 锁便是通过这种方式获取锁的，也是为什么Java中任意对象可以作为锁的原因
> monitor内部维护了三个变量
> WaitSet：保存处于Waiting状态的线程
> EntryList：保存处于Blocked状态的线程
> Owner：持有锁的线程
> 只有一个线程获取到的标志就是在monitor中设置成功了Owner，一个monitor中只能有一个Owner
> 在上锁的过程中，如果有其他线程也来抢锁，则进入EntryList 进行阻塞，当获得锁的线程执行完了，释放了锁，就会唤醒EntryList 中等待的线程竞争锁，竞争的时候是非公平的。
> **面试官**：好的，那关于synchronized 的锁升级的情况了解吗？
> **候选人**：
> 嗯，知道一些（要谦虚）
> Java中的synchronized有偏向锁、轻量级锁、重量级锁三种形式，分别对应了锁只被一个线程持有、不同线程交替持有锁、多线程竞争锁三种情况。
> 重量级锁：底层使用的Monitor实现，里面涉及到了用户态和内核态的切换、进程的上下文切换，成本较高，性能比较低。
> 轻量级锁：线程加锁的时间是错开的（也就是没有竞争），可以使用轻量级锁来优化。轻量级修改了对象头的锁标志，相对重量级锁性能提升很多。每次修改都是CAS操作，保证原子性
> 偏向锁：一段很长的时间内都只被一个线程使用锁，可以使用了偏向锁，在第一次获得锁时，会有一个CAS操作，之后该线程再获取锁，只需要判断mark word中是否是自己的线程id即可，而不是开销相对较大的CAS命令
> 一旦锁发生了竞争，都会升级为重量级锁
> **面试官**：好的，刚才你说了synchronized它在高并发量的情况下，性能不高，在项目该如何控制使用锁呢？
> **候选人**：
> 嗯，其实，在高并发下，我们可以采用ReentrantLock来加锁。
> **面试官**：嗯，那你说下ReentrantLock的使用方式和底层原理？
> **候选人**：
> 好的，
> ReentrantLock是一个可重入锁:，调用 lock 方 法获取了锁之后，再次调用 lock，是不会再阻塞，内部直接增加重入次数 就行了，标识这个线程已经重复获取一把锁而不需要等待锁的释放。
> ReentrantLock是属于juc报下的类，属于api层面的锁，跟synchronized一样，都是悲观锁。通过lock()用来获取锁，unlock()释放锁。
> 它的底层实现原理主要利用**CAS+AQS队列**来实现。它支持公平锁和非公平锁，两者的实现类似
> 构造方法接受一个可选的公平参数（**默认非公平锁**），当设置为true时，表示公平锁，否则为非公平锁。公平锁的效率往往没有非公平锁的效率高。
> **面试官**：好的，刚才你说了CAS和AQS，你能介绍一下吗？
> **候选人**：
> 好的。
> CAS的全称是： Compare And Swap(比较再交换);它体现的一种乐观锁的思想，在无锁状态下保证线程操作数据的原子性。
> CAS使用到的地方很多：AQS框架、AtomicXXX类
> 在操作共享变量的时候使用的自旋锁，效率上更高一些
> CAS的底层是调用的Unsafe类中的方法，都是操作系统提供的，其他语言实现
> AQS的话，其实就一个jdk提供的类AbstractQueuedSynchronizer，是阻塞式锁和相关的同步器工具的框架。
> 内部有一个属性 state 属性来表示资源的状态，默认state等于0，表示没有获取锁，state等于1的时候才标明获取到了锁。通过cas 机制设置 state 状态
> 在它的内部还提供了基于 FIFO 的等待队列，是一个双向列表，其中
> tail 指向队列最后一个元素
> head  指向队列中最久的一个元素
> 其中我们刚刚聊的ReentrantLock底层的实现就是一个AQS。
> **面试官**：synchronized和Lock有什么区别 ?
> **候选人**：
> 嗯~~，好的，主要有三个方面不太一样
> 第一，语法层面
> synchronized 是关键字，源码在 jvm 中，用 c++ 语言实现，退出同步代码块锁会自动释放
> Lock 是接口，源码由 jdk 提供，用 java 语言实现，需要手动调用 unlock 方法释放锁
> 第二，功能层面
> 二者均属于悲观锁、都具备基本的互斥、同步、锁重入功能
> Lock 提供了许多 synchronized 不具备的功能，例如获取等待状态、公平锁、可打断、可超时、多条件变量，同时Lock 可以实现不同的场景，如 ReentrantLock， ReentrantReadWriteLock
> 第三，性能层面
> 在没有竞争时，synchronized 做了很多优化，如偏向锁、轻量级锁，性能不赖
> 在竞争激烈时，Lock 的实现通常会提供更好的性能
> 统合来看，需要根据不同的场景来选择不同的锁的使用。
>
> **面试官**：死锁产生的条件是什么？
> **候选人**：
> 嗯，是这样的，一个线程需要同时获取多把锁，这时就容易发生死锁，举个例子来说：
> t1 线程获得A对象锁，接下来想获取B对象的锁
> t2 线程获得B对象锁，接下来想获取A对象的锁
> 这个时候t1线程和t2线程都在互相等待对方的锁，就产生了死锁
> **面试官**：那如果产出了这样的，如何进行死锁诊断？
> **候选人**：
> 这个也很容易，我们只需要通过jdk自动的工具就能搞定
> 我们可以先通过jps来查看当前java程序运行的进程id
> 然后通过jstack来查看这个进程id，就能展示出来死锁的问题，并且，可以定位代码的具体行号范围，我们再去找到对应的代码进行排查就行了。
>
> **面试官**：请谈谈你对 volatile 的理解
> **候选人**：
> 嗯~~
> volatile 是一个关键字，可以修饰类的成员变量、类的静态成员变量，主要有两个功能
> 第一：保证了不同线程对这个变量进行操作时的可见性，即一个线程修改了某个变量的值，这新值对其他线程来说是立即可见的,volatile关键字会强制将修改的值立即写入主存。
> 第二： 禁止进行指令重排序，可以保证代码执行有序性。底层实现原理是，添加了一个**内存屏障**，通过插入内存屏障禁止在内存屏障**前后**的指令执行重排序优化
>
> **本文作者**：接《集合相关面试题》
> **面试官**：那你能聊一下ConcurrentHashMap的原理吗？
> **候选人**：
> 嗯好的，
> ConcurrentHashMap 是一种线程安全的高效Map集合，jdk1.7和1.8也做了很多调整。
> JDK1.7的底层采用是**分段的数组**+**链表** 实现
> JDK1.8 采用的数据结构跟HashMap1.8的结构一样，数组+链表/红黑二叉树。
> 在jdk1.7中 ConcurrentHashMap 里包含一个 Segment 数组。Segment 的结构和HashMap类似，是一 种数组和链表结构，一个 Segment 包含一个 HashEntry 数组，每个 HashEntry 是一个链表结构 的元素，每个 Segment 守护着一个HashEntry数组里的元素，当对 HashEntry 数组的数据进行修 改时，必须首先获得对应的 Segment的锁。
> Segment 是一种可重入的锁 ReentrantLock，每个 Segment 守护一个HashEntry 数组里得元 素，当对 HashEntry 数组的数据进行修改时，必须首先获得对应的 Segment 锁
> 在jdk1.8中的ConcurrentHashMap 做了较大的优化，性能提升了不少。首先是它的数据结构与jdk1.8的hashMap数据结构完全一致。其次是放弃了Segment臃肿的设计，取而代之的是采用Node + CAS + Synchronized来保 证并发安全进行实现，synchronized只锁定当前链表或红黑二叉树的首节点，这样只要hash不冲 突，就不会产生并发 , 效率得到提升

### 线程池

> **面试官**：线程池的种类有哪些？
> **候选人**：
> 嗯！是这样
> 在jdk中默认提供了4中方式创建线程池
> 第一个是：newCachedThreadPool创建一个可缓存线程池，如果线程池长度超过处理需要，可灵活回 收空闲线程，若无可回收，则新建线程。
> 第二个是：newFixedThreadPool 创建一个定长线程池，可控制线程最大并发数，超出的线程会在队列 中等待。
> 第三个是：newScheduledThreadPool 创建一个定长线程池，支持定时及周期性任务执行。
> 第四个是：newSingleThreadExecutor 创建一个单线程化的线程池，它只会用唯一的工作线程来执行任 务，保证所有任务按照指定顺序(FIFO, LIFO, 优先级)执行。
> **面试官**：线程池的核心参数有哪些？
> **候选人**：
> 在线程池中一共有7个核心参数：
> corePoolSize 核心线程数目 - 池中会保留的最多线程数
> maximumPoolSize 最大线程数目 - 核心线程+救急线程的最大数目
> keepAliveTime 生存时间 - 救急线程的生存时间，生存时间内没有新任务，此线程资源会释放
> unit 时间单位 - 救急线程的生存时间单位，如秒、毫秒等
> workQueue - 当没有空闲核心线程时，新来任务会加入到此队列排队，队列满会创建救急线程执行任务
> threadFactory 线程工厂 - 可以定制线程对象的创建，例如设置线程名字、是否是守护线程等
> handler 拒绝策略 - 当所有线程都在繁忙，workQueue 也放满时，会触发拒绝策略
> 在拒绝策略中又有4中拒绝策略
> 当线程数过多以后，第一种是抛异常、第二种是由调用者执行任务、第三是丢弃当前的任务，第四是丢弃最早排队任务。默认是直接抛异常。
> **面试官**：如何确定核心线程池呢？
> **候选人**：
> 是这样的，我们公司当时有一些规范，为了减少线程上下文的切换，要根据当时部署的服务器的CPU核数来决定，我们规则是：CPU核数+1就是最终的核心线程数。
> **面试官**：线程池的执行原理知道吗？
> **候选人**：
> 嗯~，它是这样的
> 首先判断线程池里的核心线程是否都在执行任务，如果不是则创建一个新的工作线程来执行任务。如果核心线程都在执行任务，则线程池判断工作队列是否已满，如果工作队列没有满，则将新提交的任务存储在这个工作队 列里。如果工作队列满了，则判断线程池里的线程是否都处于工作状态，如果没有，则创建一个新的工作线程来执行任 务。如果已经满了，则交给拒绝策略来处理这个任务。
> **面试官**：为什么不建议使用Executors创建线程池呢？
> **候选人**：
> 好的，其实这个事情在阿里提供的最新开发手册《Java开发手册-嵩山版》中也提到了
> 主要原因是如果使用Executors创建线程池的话，它允许的请求队列默认长度是Integer.MAX_VALUE，这样的话，有可能导致堆积大量的请求，从而导致OOM（内存溢出）。
> 所以，我们一般推荐使用ThreadPoolExecutor来创建线程池，这样可以明确规定线程池的参数，避免资源的耗尽。

###  线程使用场景问题

> **面试官**：如果控制某一个方法允许并发访问线程的数量？
> **候选人**：
> 嗯~~，我想一下
> 在jdk中提供了一个Semaphore[seməfɔːr]类（信号量）
> 它提供了两个方法，semaphore.acquire() 请求信号量，可以限制线程的个数，是一个正数，如果信号量是-1,就代表已经用完了信号量，其他线程需要阻塞了
> 第二个方法是semaphore.release()，代表是释放一个信号量，此时信号量的个数+1
> **面试官**：好的，那该如何保证Java程序在多线程的情况下执行安全呢？
> **候选人**：
> 嗯，刚才讲过了导致线程安全的原因，如果解决的话，jdk中也提供了很多的类帮助我们解决多线程安全的问题，比如：
> JDK Atomic开头的原子类、synchronized、LOCK，可以解决原子性问题
> synchronized、volatile、LOCK，可以解决可见性问题
> Happens-Before 规则可以解决有序性问题
>
> **面试官**：你在项目中哪里用了多线程？
> **候选人**：
> 嗯~~，我想一下当时的场景[根据自己简历上的模块设计多线程场景]
> 参考场景一：
> es数据批量导入
> 在我们项目上线之前，我们需要把数据量的数据一次性的同步到es索引库中，但是当时的数据好像是1000万左右，一次性读取数据肯定不行（oom异常），如果分批执行的话，耗时也太久了。所以，当时我就想到可以使用线程池的方式导入，利用CountDownLatch+Future来控制，就能大大提升导入的时间。
> 参考场景二：
> 在我做那个xx电商网站的时候，里面有一个数据汇总的功能，在用户下单之后需要查询订单信息，也需要获得订单中的商品详细信息（可能是多个），还需要查看物流发货信息。因为它们三个对应的分别三个微服务，如果一个一个的操作的话，互相等待的时间比较长。所以，我当时就想到可以使用线程池，让多个线程同时处理，最终再汇总结果就可以了，当然里面需要用到Future来获取每个线程执行之后的结果才行
> 参考场景三：
> 《黑马头条》项目中使用的
> 我当时做了一个文章搜索的功能，用户输入关键字要搜索文章，同时需要保存用户的搜索记录（搜索历史），这块我设计的时候，为了不影响用户的正常搜索，我们采用的异步的方式进行保存的，为了提升性能，我们加入了线程池，也就说在调用异步方法的时候，直接从线程池中获取线程使用

###  其他

> **面试官**：谈谈你对ThreadLocal的理解
> **候选人**：
> 嗯，是这样的~~
> ThreadLocal 主要功能有两个，第一个是可以实现资源对象的线程隔离，让每个线程各用各的资源对象，避免争用引发的线程安全问题，第二个是实现了线程内的资源共享
> **面试官**：好的，那你知道ThreadLocal的底层原理实现吗？
> **候选人**：
> 嗯，知道一些~
> 在ThreadLocal内部维护了一个一个 ThreadLocalMap 类型的成员变量，用来存储资源对象
> 当我们调用 set 方法，就是以 ThreadLocal 自己作为 key，资源对象作为 value，放入当前线程的 ThreadLocalMap 集合中
> 当调用 get 方法，就是以 ThreadLocal 自己作为 key，到当前线程中查找关联的资源值
> 当调用 remove 方法，就是以 ThreadLocal 自己作为 key，移除当前线程关联的资源值
> **面试官**：好的，那关于ThreadLocal会导致内存溢出这个事情，了解吗？
> **候选人**：
> 嗯，我之前看过源码，我想一下~~
> 是应为ThreadLocalMap 中的 key 被设计为弱引用，它是被动的被GC调用释放key，不过关键的是只有key可以得到内存释放，而value不会，因为value是一个强引用。
> 在使用ThreadLocal 时都把它作为静态变量（即强引用），因此无法被动依靠 GC 回收，建议主动的remove 释放 key，这样就能避免内存溢出。

**以下为其它地方整理的资料，可能会有重复，大家查漏补缺就好。**

## 面试的两个方向

![image-20220227155710574](https://image.hyly.net/i/2025/09/22/db9d5413af5025bcbbfc18c68b5749d7-0.webp)

面试向上问问题是如何解决的，向下问一些基础知识是否扎实。

## 为什么会产生死锁？

1. **互斥条件** 同一时间只能有一个线程获取资源。
2. **不可剥夺条件** 一个线程已经占有的资源，在释放之前不会被其它线程抢占。
3. **请求和保持条件** 线程等待过程中不会释放已占有的资源。
4. **循环等待条件** 多个线程互相等待对方释放资源。

## 如何解决死锁？

1. 由于资源互斥是资源使用的固有特性，无法改变，我们不讨论。
2. 破坏不可剥夺条件
	1. 一个进程不能获得所需要的全部资源时便处于等待状态，等待期间他占有的资源将被隐式的释放重新加入到系统的资源列表中，可以被其他的进程使用，而等待的进程只有重新获得自己原有的资源以及新申请的资源才可以重新启动，执行。
3. 破坏请求与保持条件
	1. 第一种方法静态分配即每个进程在开始执行时就申请他所需要的全部资源。
	2. 第二种是动态分配即每个进程在申请所需要的资源时他本身不占用系统资源。
4. 破坏循环等待条件
	1. 采用资源有序分配其基本思想是将系统中的所有资源顺序编号，将紧缺的，稀少的采用较大的编号，在申请资源时必须按照编号的顺序进行，一个进程只有获得较小编号的进程才能申请较大编号的进程。

## Java锁的类型

### 公平锁和非公平锁

公平锁：多个线程按照申请锁的顺序来获取锁

非公平锁：多个线程获取锁的顺序并不是按照申请锁的顺序，有可能后申请的线程比先申请的线程优先获取到锁。这会造成优先级反转或者锁饥饿现象。

在Java中，ReentrantLock可通过构造函数至指定是否是公平锁，默认是非公平锁

synchronized默认是非公平锁并且不能变为公平锁

### 独享锁和共享锁

独享锁：一个锁只能被一个线程所持有

共享锁：一个锁可被多个线程持有

在Java中，ReentrantLock是独享锁

ReadWriteLock中，读锁是共享锁，写锁是独享锁，即，读写，写读，写写是互斥的

Synchronized方法是独享锁

### 互斥锁和读写锁

互斥锁和读写锁是共享锁和独享锁的具体实现

### 乐观锁和悲观锁

不是具体的锁，是指看待并发同步的角度

悲观锁：对于同一数据的并发操作，悲观锁认为这是一定会修改数据的，因此会采取加锁的方式实现同步。

乐观锁：对于同一数据的并发操作，乐观锁认为这不一定会修改数据，因此在更新数据时，会采取不断尝试更新的操作。

在Java中，悲观锁是指利用各种锁机制；而乐观锁是指无锁编程，如CAS算法，典型的是原子类，通过CAS自旋实现原子操作的更新

### 分段锁

不是指具体的一种锁，而是一种锁的设计。

分段锁的设计目的是细化锁的操作，例如当操作不需要更新整个数组时，仅针对数组中的一个元素进行更新时，我们仅给该元素加锁即可。

ConcurrentHashMap就是利用分段锁的形式实现高效地并发操作：

ConcurrentHashMap和hashMap一样，有一个Entry数组，数组中的每个元素是一个链表，也是一个Segment（分段锁）。

当需要put元素时，不是先对整个hashMap加锁（线程安全的hashTable是整个加锁），而是通过hashCode知道它要放在哪一个分段中，然后对这个分段进行加锁，所以当有多个线程put时，只要不是放在同一个分段中，就不会产生同步阻塞现象。

在统计size时，即获取ConcurrentHashMap信息时，就需要获取所有分段锁才能统计。

### 偏向锁，轻量级锁，重量级锁

在Java5中，可以通过锁升级机制实现高效地Synchronized方法，这三种锁是指Synchronized锁的状态，通过对象监视器在对象头中的字段来表明。

偏向锁：指一段同步代码一直被一个线程所访问，那么该线程就会自动获取这个锁，以降低获取锁的代价。

轻量级锁：当前锁是偏向锁并且被另一个线程访问时，偏向锁会升级为轻量级锁，其他线程会通过自旋的形式尝试获取锁，不会阻塞其他线程。

重量级锁：当前锁时轻量级锁，另一个线程自旋到一定次数的时候还没获取到该锁时，轻量级锁就会升级为重量级锁，会阻塞其他线程。

### 自旋锁

指尝试获取锁的线程不会立即阻塞，而是采用循环的方式去尝试获取锁

### 可重入锁（递归锁）

指在同一线程在外层方法获取锁的时候，进入内层方法时会自动获取锁

## 线程创建的三种方式

![image-20220227160433348](https://image.hyly.net/i/2025/09/22/16970e33f4912254364a1b6751b39194-0.webp)

![image-20220311163254522](https://image.hyly.net/i/2025/09/22/ae3f688c125b4742737af9e528f414dc-0.webp)

1. 继承Thread。继承java.lang.Thread类，重写Thread类的run()方法，在run()方法中实现运行在线程上的代码，调用start()方法开启线程。Thread 类本质上是实现了 Runnable 接口的一个实例，代表一个线程的实例。启动线程的唯一方法就是通过 Thread 类的start()实例方法。start()方法是一个 native 方法，它将启动一个新线程，并执行 run()方法。
2. 实现Runnable接口。Runnable规定的方法是run()，无返回值，无法抛出异常。
3. 实现Callable，Callable规定的方法是call()，任务执行后有返回值，可以抛出异常
4. （拓展）通过线程池创建线程. 线程和数据库连接这些资源都是非常宝贵的资源。那么每次需要的时候创建，不需要的时候销毁，是非常浪费资源的。那么我们就可以使用缓存的策略，也就是使用
	线程池。
5. lambda表达式直接创建。

## 线程安全活跃态问题，竞态条件问题

**线程安全的活跃性问题可以分为 死锁、活锁、饥饿。**

**活锁：**就是有时线程虽然没有发生阻塞，但是仍然会存在执行不下去的情况，活锁不会阻塞线程，线程会一直重复执行某个相同的操作，并且一直失败重试。

1. 我们开发中使用的异步消息队列就有可能造成活锁的问题，在消息队列的消费端如果没有正确的ack消息，并且执行过程中报错了，就会再次放回消息头，然后再拿出来执行，一直循环往复的失败。这个问题除了正确的ack之外，往往是通过将失败的消息放入到延时队列中，等到一定的延时再进行重试来解决。

活锁的解决方案很简单，尝试等待一个随机的时间就可以，会按时间轮去重试。

**饥饿：**就是**线程因无法访问所需资源而无法执行下去的情况**，分为两种情况：

1. **一部分程在临界区做了无限循环或无限制等待资源的操作**，让其他的线程一直不能拿到锁进入临界区，对其他线程来说，就进入了饥饿状态。
2. **一部分线程优先级不合理的分配**，导致部分线程始终无法获取到CPU资源而一直无法执行。

饥饿解决方案：

1. 保证资源充足，很多场景下，资源的稀缺性无法解决。
2. 公平分配资源，在并发编程里使用公平锁，例如FIFO策略，线程等待是有顺序的，排在等待队列前面的线程会优先获得资源。
3. 避免持有锁的线程长时间执行，很多场景下，持有锁的线程的执行时间也很难缩短。

**死锁：**线程在对同一把锁进行竞争的时候，未抢占到锁的线程会等待持有锁的线程释放锁后继续抢占，如果两个或两个以上的线程互相持有对方将要抢占的锁，互相等待对方先行释放锁就会进入到一个循环等待的过程，这个过程就叫做死锁。

死锁的解决方案：破坏产生死锁的四个必要条件之一即可。

**线程安全的竞态条件问题**

1. 同一个程序多线程访问同一个资源，如果对资源的访问顺序敏感，就称存在竞态条件，代码区成为临界区。 大多数并发错误一样，竞态条件不总是会产生问题，还需要不恰当的执行时序。
2. 最常见的竞态条件为：
	1. 先检测后执行执行依赖于检测的结果，而检测结果依赖于多个线程的执行时序，而多个线程的执行时序通常情况下是不固定不可判断的，从而导致执行结果出现各种问题，见一种可能 的解决办法就是：在一个线程修改访问一个状态时，要防止其他线程访问修改，也就是加锁机制，保证原子性。
	2. 延迟初始化（典型为单例）。

## Java中的wait和sleep的区别与联系

1. 相同点：
	1. 两个方法都能使线程进入阻塞状态。
2. 不同点：
	1. sleep()方法是Thread类中的静态方法；而wait()方法是Object类中的方法；
	2. sleep()方法可以在任何地方调用；而wait()方法只能在同步代码块或同步方法中使用(即使用synchronized关键字修饰的)；
	3. 这两个方法都在同步代码块或同步方法中使用时，sleep()方法不会释放同步监视器（锁）；而wait()方法则会释放同步监视器（锁）；

## 描述一下进程与线程区别？

**进程（Process）：**

1. 是系统进行资源分配和调度的基本单位，是操作系统结构的基础。在当代面向线程设计的计算机结构中，进程是线程的容器。程序是指令、数据及其组织形式的描述，进程是程序的实体。是计算机中的程序关于某数据集合上的一次运行活动，是系统进行资源分配和调度的基本单位，是操作系统结构的基础。程序是指令、数据及其组织形式的描述，进程是程序的实体。总结: j进程是指在系统中正在运行的一个应用程序；程序一旦运行就是进程；进程——资源分配的最小单位。

**线程：**

1. 操作系统能够进行运算调度的最小单位。它被包含在进程之中，是进程中的实际运作单位。一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。总结: 系统分配处理器时间资源的基本单元，或者说进程之内独立执行的一个单元执行流。线程——程序执行的最小单位。

## 并发与并行的区别

并发是指一个处理器同时处理多个任务。并行是指多个处理器或者是多核的处理器同时处理多个不同的任务。并发是逻辑上的同时发生（ simultaneous），而并行是物理上的同时发生。

来个比喻：并发是一个人同时吃三个馒头，而并行是三个人同时吃三个馒头。

## 线程常用的三种方法

1. sleep，线程睡眠让其他线程先执行。
2. yield，线程先让出让其他线程先执行。
3. join，切换线程运行，运行完之后再运行本线程。常用做保证线程顺序执行完毕。

## 线程的生命周期常见状态

![image-20220311184208508](https://image.hyly.net/i/2025/09/22/caa2fccd597676a43e500211f60a1ebc-0.webp)

**大致包括5个阶段：**

1. 新建 就是刚使用new方法，new出来的线程；
2. 就绪 就是调用的线程的start()方法后，这时候线程处于等待CPU分配资源阶段，谁先抢的CPU资源，谁开始执行;
3. 运行 当就绪的线程被调度并获得CPU资源时，便进入运行状态，run方法定义了线程的操作和功能;
4. 阻塞 在运行状态的时候，可能因为某些原因导致运行状态的线程变成了阻塞状态，比如sleep()、wait()之后线程就处于了阻塞状态，这个时候需要其他机制将处于阻塞状态的线程唤醒，比如调用notify或者notifyAll()方法。唤醒的线程不会立刻执行run方法，它们要再次等待CPU分配资源进入运行状态;
5. 销毁 如果线程正常执行完毕后或线程被提前强制性的终止或出现异常导致结束，那么线程就要被销毁，释放资源。

**不建议使用stop方法关闭线程，容易造成数据不一致，可以让线程正常调度结束。**

## 程序开多少线程合适？

这里需要区别下应用是什么样的程序：

1. **CPU密集型程序：**
	1. 单核CPU： 一个完整请求，I/O操作可以在很短时间内完成， CPU还有很多运算要处理，也就是说 CPU 计算的比例占很大一部分，线程等待时间接近0。单核CPU处理CPU密集型程序，这种情况并不太适合使用多线程。
	2. 多核 ： 如果是多核CPU 处理 CPU 密集型程序，我们完全可以最大化的利用 CPU核心数，应用并发编程来提高效率。CPU 密集型程序的最佳线程数就是：因此对于CPU 密集型来说，理论上 线程数量 = CPU 核数（逻辑），但是实际上，数量一般会设置为 CPU 核数（逻辑）+ 1（经验值）。计算(CPU)密集型的线程恰好在某时因为发生一个页错误或者因其他原因而暂停，刚好有一个“额外”的线程，可以确保在这种情况下CPU周期不会中断工作
2. **I/O 密集型程序：**与 CPU 密集型程序相对，一个完整请求，CPU运算操作完成之后还有很多 I/O 操作要做，也就是说 I/O 操作占比很大部分，等待时间较长，线程等待时间所占比例越高，需要越多线程；线程CPU时间所占比例越高，需要越少线程。
	1. I/O 密集型程序的最佳线程数就是： 最佳线程数 = CPU核心数 (1/CPU利用率) =CPU核心数 (1 + (I/O耗时/CPU耗时))。
	2. 如果几乎全是 I/O耗时，那么CPU耗时就无限趋近于0，所以纯理论你就可以说是2N（N=CPU核数），当然也有说 2N + 1的，1应该是backup。

首先确认业务是CPU密集型还是IO密集型的，如果是CPU密集型的，那么就应该尽量少的线程数量，一般为CPU的核数+1；如果是IO密集型：所以可多分配一点 cpu核数*2 也可以使用公式：CPU 核数 / (1 - 阻塞系数)；其中阻塞系数 在 0.8 ～ 0.9 之间。

**一般我们说 2N + 1 就即可。**

## 描述一下notify和notifyAll区别？

首先最好说一下 锁池 和 等待池 的概念：

1. 锁池:假设线程A已经拥有了某个对象(注意:不是类)的锁，而其它的线程想要调用这个对象的某个synchronized方法(或者synchronized块)，由于这些线程在进入对象的synchronized方法之前必须先获得该对象的锁的拥有权，但是该对象的锁目前正被线程A拥有，所以这些线程就进入了该对象的锁池中。
2. 等待池:假设一个线程A调用了某个对象的wait()方法，线程A就会释放该对象的锁(因为wait()方法必须出现在synchronized中，这样自然在执行wait()方法之前线程A就已经拥有了该对象的锁)，同时线程A就进入到了该对象的等待池中。如果另外的一个线程调用了相同对象的notifyAll()方法，那么处于该对象的等待池中的线程就会全部进入该对象的锁池中，准备争夺锁的拥有权。如果另外的一个线程调用了相同对象的notify()方法，那么仅仅有一个处于该对象的等待池中的线程(随机)会进入该对象的锁池。

如果线程调用了对象的 wait()方法，那么线程便会处于该对象的等待池中，等待池中的线程不会去竞争该对象的锁。

当有线程调用了对象的 notifyAll()方法（唤醒所有 wait 线程）或 notify()方法（只随机唤醒一个 wait 线程），被唤醒的的线程便会进入该对象的锁池中，锁池中的线程会去竞争该对象锁。也就是说，调用了notify后只要一个线程会由等待池进入锁池，而notifyAll会将该对象等待池内的所有线程移动到锁池中，等待锁竞争。

所谓唤醒线程，另一种解释可以说是将线程由等待池移动到锁池，notifyAll调用后，会将全部线程由等待池移到锁池，然后参与锁的竞争，竞争成功则继续执行，如果不成功则留在锁池等待锁被释放后再次参与竞争。而notify只会唤醒一个线程。

## synchronized和lock的区别

<figure class='table-figure'><table>
<thead>
<tr><th><strong>类别</strong></th><th><strong>synchronized</strong></th><th><strong>Lock</strong></th></tr></thead>
<tbody><tr><td>存在层次</td><td>Java的关键字，在jvm层面上</td><td>是JVM的一个接口类</td></tr><tr><td>锁的释放</td><td>1、以获取锁的线程执行完同步代码，释放锁 2、线程执行发生异常，jvm会让线程释放锁</td><td>在finally中必须释放锁，不然容易造成线程死锁</td></tr><tr><td>锁的获取</td><td>假设A线程获得锁，B线程等待。如果A线程阻塞，B线程会一直等待</td><td>分情况而定，Lock有多个锁获取的方式，具体下面会说道，大致就是可以尝试获得锁，线程可以不用一直等待</td></tr><tr><td>锁状态</td><td>无法判断</td><td>可以判断</td></tr><tr><td>锁类型</td><td>可重入 不可中断 非公平</td><td>可重入 可判断 可公平（两者皆可）</td></tr><tr><td>性能</td><td>少量同步</td><td>大量同步</td></tr><tr><td>支持锁的场景</td><td>1. 独占锁</td><td>1. 公平锁与非公平锁</td></tr></tbody>
</table></figure>


区别如下：

1. 来源：lock是一个接口，而synchronized是java的一个关键字，synchronized是内置的语言实现；
2. 异常是否释放锁：synchronized在发生异常时候会自动释放占有的锁，因此不会出现死锁；而lock发生异常时候，不会主动释放占有的锁，必须手动unlock来释放锁，可能引起死锁的发生。（所以最好将同步代码块用try catch包起来，finally中写入unlock，避免死锁的发生。）
3. 是否响应中断：lock等待锁过程中可以用interrupt来中断等待，而synchronized只能等待锁的释放，不能响应中断；
4. 是否知道获取锁：Lock可以通过trylock来知道有没有获取锁，而synchronized不能；
5. Lock可以提高多个线程进行读操作的效率。（可以通过readwritelock实现读写分离）。
6. 在性能上来说，如果竞争资源不激烈，两者的性能是差不多的，而当竞争资源非常激烈时（即有大量线程同时竞争），此时Lock的性能要远远优于synchronized。所以说，在具体使用时要根据适当情况选择。
7. synchronized使用Object对象本身的wait 、notify、notifyAll调度机制，而Lock可以使用Condition进行线程之间的调度。

**synchronized和lock的用法区别：**

synchronized：在需要同步的对象中加入此控制，synchronized可以加在方法上，也可以加在特定代码块中，括号中表示需要锁的对象。

lock：一般使用ReentrantLock类做为锁。在加锁和解锁处需要通过lock()和unlock()显示指出。所以一般会在finally块中写unlock()以防死锁。

**synchronized和lock性能区别：**

synchronized是托管给JVM执行的，
而lock是java写的控制锁的代码。

在Java1.5中，synchronize是性能低效的。因为这是一个重量级操作，需要调用操作接口，导致有可能加锁消耗的系统时间比加锁以外的操作还多。相比之下使用Java提供的Lock对象，性能更高一些。

但是到了Java1.6，发生了变化。synchronize在语义上很清晰，可以进行很多优化，有适应自旋，锁消除，锁粗化，轻量级锁，偏向锁等等。导致在Java1.6上synchronize的性能并不比Lock差。官方也表示，他们也更支持synchronize，在未来的版本中还有优化余地。

2种机制的具体区别：
**synchronized原始采用的是CPU悲观锁机制，即线程获得的是独占锁。**独占锁意味着其他线程只能依靠阻塞来等待线程释放锁。而在CPU转换线程阻塞时会引起线程上下文切换，当有很多线程竞争锁的时候，会引起CPU频繁的上下文切换导致效率很低。

**而Lock用的是乐观锁方式。所谓乐观锁就是，每次不加锁而是假设没有冲突而去完成某项操作，如果因为冲突失败就重试，直到成功为止。乐观锁实现的机制就是CAS操作**（Compare and Swap）。我们可以进一步研究ReentrantLock的源代码，会发现其中比较重要的获得锁的一个方法是compareAndSetState。这里其实就是调用的CPU提供的特殊指令。

现代的CPU提供了指令，可以自动更新共享数据，而且能够检测到其他线程的干扰，而 compareAndSet() 就用这些代替了锁定。这个算法称作非阻塞算法，意思是一个线程的失败或者挂起不应该影响其他线程的失败或挂起的算法。

**synchronized和lock用途区别：**

synchronized原语和ReentrantLock在一般情况下没有什么区别，但是在非常复杂的同步应用中，请考虑使用ReentrantLock，特别是遇到下面2种需求的时候。

1.某个线程在等待一个锁的控制权的这段时间需要中断
2.需要分开处理一些wait-notify，ReentrantLock里面的Condition应用，能够控制notify哪个线程
3.具有公平锁功能，每个到来的线程都将排队等候

下面细细道来……

先说第一种情况，ReentrantLock的lock机制有2种，忽略中断锁和响应中断锁，这给我们带来了很大的灵活性。比如：如果A、B 2个线程去竞争锁，A线程得到了锁，B线程等待，但是A线程这个时候实在有太多事情要处理，就是一直不返回，B线程可能就会等不及了，想中断自己，不再等待这个锁了，转而处理其他事情。这个时候**ReentrantLock就提供了2种机制：可中断/可不中断**
第一，B线程中断自己（或者别的线程中断它），但是ReentrantLock不去响应，继续让B线程等待，你再怎么中断，我全当耳边风（synchronized原语就是如此）；
第二，B线程中断自己（或者别的线程中断它），ReentrantLock处理了这个中断，并且不再等待这个锁的到来，完全放弃。

## 简述下ABA问题

CAS：对于内存中的某一个值V，提供一个旧值A和一个新值B。如果提供的旧值V和A相等就把B写入V。这个过程是原子性的。

CAS执行结果要么成功要么失败，对于失败的情形下一班采用不断重试。或者放弃。

ABA：如果另一个线程修改V值假设原来是A，先修改成B，再修改回成A。当前线程的CAS操作无法分辨当前V值是否发生过变化。

比如：张三有个女朋友分手了，女朋友跟别人谈过了又回到张三身边，虽然人还是那个人但已经不是当初的女朋友了。

解决ABA问题就是加版本号，保证单向递增或者递减就不会存在此类问题。用时间戳不好控制位数问题。

## 什么是DCL？

为什么要用DCL（Double Check Locking）是因为多线程时当A线程获得锁进入sync代码块的时候此时才刚init初始化还没有赋初值，这时候B线程进来发现不为空了就直接把初值返回了，这样就造成了两个对象。

volatile禁止了指令重排序，所以确保了初始化顺序一定是1->2->3，所以也就不存在拿到未初始化的对象引用的情况。

```java
public class Singleton {
 //volatile是防止指令重排
 private static volatile Singleton singleton;
 private Singleton() {}
 public static Singleton getInstance() {
   //第一层判断singleton是不是为null
   //如果不为null直接返回，这样就不必加锁了
   if (singleton == null) {
     //现在再加锁
     synchronized (Singleton.class) {
       //第二层判断
       //如果A,B两个线程都在synchronized等待
       //A创建完对象之后，B还会再进入，如果不再检查一遍，B又会创建一个对象
       if (singleton == null) {
         singleton = new Singleton();
       }
     }
   }
   return singleton;
 }
}
```

## 实现一个阻塞队列（用Condition写生产者与消费者）？

[LinkedBlockingQueue和ArrayBlockingQueue的异同](https://www.cnblogs.com/lianliang/p/5765349.html)

现成的可以使用ArrayBlockingQueue或LinkBlockingQueue

```java
public class ProviderConsumer<T> {
 private int length;
 private Queue<T> queue;
 private ReentrantLock lock = new ReentrantLock();
 private Condition provideCondition = lock.newCondition();
 private Condition consumeCondition = lock.newCondition();
 public ProviderConsumer(int length){
   this.length = length;
   this.queue = new LinkedList<T>();
 }
 public void provide(T product){
   lock.lock();
   try {
     while (queue.size() >= length) {
       provideCondition.await();
     }
     queue.add(product);
     consumeCondition.signal();
   } catch (InterruptedException e) {
     e.printStackTrace();
   } finally {
     lock.unlock();
   }
 }
 public T consume() {
   lock.lock();
   try {
     while (queue.isEmpty()) {
       consumeCondition.await();
     }
     T product = queue.remove();
     provideCondition.signal();
     return product;
   } catch (InterruptedException e) {
     e.printStackTrace();
   } finally {
     lock.unlock();
   }
   return null;
 }
}
```

## 多线程之间是如何通信的?

1. 通过共享变量，变量需要volatile 修饰。
2. 使用wait()和notifyAll()方法，但是由于需要使用同一把锁，所以必须通知线程释放锁，被通知线程才能获取到锁，这样导致通知不及时。
3. 使用Condition的await()和signalAll()方法。
4. 使用CountDownLatch实现，通知线程到指定条件，调用countDownLatch.countDown()，被通知线程进行countDownLatch.await()。

## synchronized关键字加在静态方法和实例方法的区别?

synchronized是对对象加锁。哪个线程能进入临界区，需要看synchronized究竟是对哪个对象加锁，修饰static方法是对.class对象加锁，修饰成员方法是对当前类的某个对象加锁，修饰代码块是对特定对象加锁。

修饰静态方法，是对类进行加锁，如果该类中有methodA 和methodB都是被synchronized修饰的静态方法，此时有两个线程T1、T2分别调用methodA()和methodB()，则T2会阻塞等待直到T1执行完成之后才能执行。

修饰实例方法时，是对实例进行加锁，锁的是实例对象的对象头，如果调用同一个对象的两个不同的被synchronized修饰的实例方法时，看到的效果和上面的一样，如果调用不同对象的两个不同的被synchronized修饰的实例方法时，则不会阻塞。

## countdownlatch的用法？

**两种用法：**

1. 某一线程在开始运行前等待n个线程执行完毕。将CountDownLatch的计数器初始化为n new CountDownLatch(n) ，每当一个任务线程执行完毕，就将计数器减1 countdownlatch.countDown()，当计数器的值变为0时，在CountDownLatch上 await() 的线程就会被唤醒。一个典型应用场景就是启动一个服务时，主线程需要等待多个组件加载完毕，之后再继续执行。
2. 实现多个线程开始执行任务的最大并行性。注意是并行性，不是并发，强调的是多个线程在某一时刻同时开始执行。类似于赛跑，将多个线程放到起点，等待发令枪响，然后同时开跑。做法是初始化一个共享的CountDownLatch(1)，将其计数器初始化为1，多个线程在开始执行任务前首先 coundownlatch.await()，当主线程调用 countDown() 时，计数器变为0，多个线程同时被唤醒。

底层原理就是使用AQS的共享锁实现。

## 线程池问题

### Executor提供了几种线程池

#### newCachedThreadPool()（工作队列使用的是 SynchronousQueue）

创建一个线程池，如果线程池中的线程数量过大，它可以有效的回收多余的线程，如果线程数不足，那么它可以创建新的线程。

不足：这种方式虽然可以根据业务场景自动的扩展线程数来处理我们的业务，但是最多需要多少个线程同时处理却是我们无法控制的。

优点：如果当第二个任务开始，第一个任务已经执行结束，那么第二个任务会复用第一个任务创建的线程，并不会重新创建新的线程，提高了线程的复用率。

作用：该方法返回一个可以根据实际情况调整线程池中线程的数量的线程池。即该线程池中的线程数量不确定，是根据实际情况动态调整的。

#### newFixedThreadPool()（工作队列使用的是 LinkedBlockingQueue）

这种方式可以指定线程池中的线程数。如果满了后又来了新任务，此时只能排队等待。

优点：newFixedThreadPool 的线程数是可以进行控制的，因此我们可以通过控制最大线程来使我们的服务器达到最大的使用率，同时又可以保证即使流量突然增大也不会占用服务器过多的资源。

作用：该方法返回一个固定线程数量的线程池，该线程池中的线程数量始终不变，即不会再创建新的线程，也不会销毁已经创建好的线程，自始自终都是那几个固定的线程在工作，所以该线程池可以控制线程的最大并发数。

#### newScheduledThreadPool()

该线程池支持定时，以及周期性的任务执行，我们可以延迟任务的执行时间，也可以设置一个周期性的时间让任务重复执行。该线程池中有以下两种延迟的方法。

scheduleAtFixedRate 不同的地方是任务的执行时间，如果间隔时间大于任务的执行时间，任务不受执行时间的影响。如果间隔时间小于任务的执行时间，那么任务执行结束之后，会立马执行，至此间隔时间就会被
打乱。

scheduleWithFixedDelay 的间隔时间不会受任务执行时间长短的影响。

作用：该方法返回一个可以控制线程池内线程定时或周期性执行某任务的线程池。

#### newSingleThreadExecutor()

这是一个单线程池，至始至终都由一个线程来执行。

作用：该方法返回一个只有一个线程的线程池，即每次只能执行一个线程任务，多余的任务会保存到一个任务队列中，等待这一个线程空闲，当这个线程空闲了再按 FIFO 方式顺序执行任务队列中的任务。

#### newSingleThreadScheduledExecutor()

只有一个线程，用来调度任务在指定时间执行。

作用：该方法返回一个可以控制线程池内线程定时或周期性执行某任务的线程池。只不过和上面的区别是该线程池大小为 1，而上面的可以指定线程池的大小。

### 线程池的参数

```java
int corePoolSize,//线程池核心线程大小
int maximumPoolSize,//线程池最大线程数量
long keepAliveTime,//空闲线程存活时间
TimeUnit unit,//空闲线程存活时间单位，一共有七种静态属性(TimeUnit.DAYS天,TimeUnit.HOURS小时,TimeUnit.MINUTES分钟,TimeUnit.SECONDS秒,TimeUnit.MILLISECONDS毫秒,TimeUnit.MICROSECONDS微妙,TimeUnit.NANOSECONDS纳秒)
BlockingQueue<Runnable> workQueue,//工作队列
ThreadFactory threadFactory,//线程工厂，主要用来创建线程(默认的工厂方法是：Executors.defaultThreadFactory()对线程进行安全检查并命名)
RejectedExecutionHandler handler//拒绝策略(默认是：ThreadPoolExecutor.AbortPolicy不执行并抛出异常,jdk默认提供了四种拒绝策略：1、CallerRunsPolicy - 当触发拒绝策略，只要线程池没有关闭的话，则使用调用线程直接运行任务。一般并发比较小，性能要求不高，不允许失败。但是，由于调用者自己运行任务，如果任务提交速度过快，可能导致程序阻塞，性能效率上必然的损失较大。2、AbortPolicy - 丢弃任务，并抛出拒绝执行 RejectedExecutionException 异常信息。线程池默认的拒绝策略。必须处理好抛出的异常，否则会打断当前的执行流程，影响后续的任务执行。3、DiscardPolicy - 直接丢弃，其他啥都没有。4、DiscardOldestPolicy - 当触发拒绝策略，只要线程池没有关闭的话，丢弃阻塞队列 workQueue 中最老的一个任务，并将新任务加入。)
```

### 线程池任务放置的顺序过程

任务调度是线程池的主要入口，当用户提交了一个任务，接下来这个任务将如何执行都是由这个阶段决定的。了解这部分就相当于了解了线程池的核心运行机制。

首先，所有任务的调度都是由execute方法完成的，这部分完成的工作是：检查现在线程池的运行状态、运行线程数、运行策略，决定接下来执行的流程，是直接申请线程执行，或是缓冲到队列中执行，亦或是直接拒绝
该任务。其执行过程如下：

首先检测线程池运行状态，如果不是RUNNING，则直接拒绝，线程池要保证在RUNNING的状态下执行任务。

如果workerCount < corePoolSize，则创建并启动一个线程来执行新提交的任务。

如果workerCount >= corePoolSize，且线程池内的阻塞队列未满，则将任务添加到该阻塞队列中。

如果workerCount >= corePoolSize && workerCount < maximumPoolSize，且线程池内的阻塞队
列已满，则创建并启动一个线程来执行新提交的任务。

如果workerCount >= maximumPoolSize，并且线程池内的阻塞队列已满, 则根据拒绝策略来处理该任
务, 默认的处理方式是直接抛异常。

其执行流程如下图所示：

![image-20220314212331946](https://image.hyly.net/i/2025/09/22/45bf67d535f38c3333ef8c177b24e967-0.webp)

### 线程池任务结束后会不会回收线程

非核心线程空闲一段时间后回回收线程。

核心线程当设置了参数allowCoreThreadTimeOut为true时，核心线程也可以进行回收。

### 未使用的线程池中的线程放在哪里

private final HashSet<Worker> workers = new HashSet<Worker>();

### 线程池线程存在哪

private final HashSet<Worker> workers = new HashSet<Worker>();

## 如何在方法栈中进行数据传递？

通过方法参数传递;通过共享变量;如果在用一个线程中,还可以使用ThreadLocal进行传递。

## synchronized关键字

当多个线程访问同一个资源的时候就需要上锁。

**synchronized是可重入的。**比方说父类加锁，子类需要调用也加锁了，如果子类掉父类因为可重入是同一把锁所以能调用，如果不可重入就会产生死锁。

synchronized时当程序出现异常时，会释放锁，会引起其他线程程序乱入，除非捕获异常进行再处理。

**锁升级的概念：**

![image-20220227170756464](https://image.hyly.net/i/2025/09/22/ab4c0c488bf10d9aa5f0a22e18915147-0.webp)

### 零散概念：

1. 锁的是对象不是代码，最好用对象加锁，不要用基础常量加锁，会出现意想不到的问题。

2. ![image-20220227171208778](https://image.hyly.net/i/2025/09/22/afe9e1203b39171541b473d6964e62f5-0.webp)

3. 锁定方法，非锁定方法同时执行。

4. ![image-20220227174414968](https://image.hyly.net/i/2025/09/22/27d6e83e29293e8ebc54ef0ebc366b6d-0.webp)


## JUC同步工具

1. Semaphore
2. CountDownLatch
3. CyclicBarrier
4. Exchanger
5. Phaser

## 并发容器

**COW**（Copy-On-Write）有CopyOnWriteArrayList和CopyOnWriteArraySet

CopyOnWriteArrayList：支持高并发且线程安全的ArrayList，且读的时候无锁。在增加数据时会先copy出一个副本，再往新的容器里添加数据。这个时候读的是副本，最后把新的容器地址赋值给旧的地址。应用的是linux的 COW原理。

特点：适合读多写少场景，读写分离，线程安全。

缺点：不适合大数据量，内存开销比原数组大得多。不适合实时场景。和对强一致性的场景。

CopyOnWriteArraySet：线程安全的HashSet，不同于HashSet的散列表数据结构，它是通过CopyOnWriteArrayList实现的。

特点：和CopyOnWriteArrayList类似。它的Set 通常保持很小，只读操作远多于可变操作，需要在遍历期间防止线程间的冲突。所有可变操作开销都非常大。

## Disrupor

Martin Fowler在自己网站上写了一篇LMAX架构的文章，在文章中他介绍了LMAX是一种新型零售金融交易平台，它能够以很低的延迟产生大量交易。这个系统是建立在JVM平台上，其核心是一个业务逻辑处理器，它能够在一个线程里每秒处理6百万订单。业务逻辑处理器完全是运行在内存中，使用事件源驱动方式。业务逻辑处理器的核心是Disruptor。

Disruptor它是一个开源的并发框架，并获得2011 Duke’s 程序框架创新奖，能够在无锁的情况下实现网络的Queue并发操作。