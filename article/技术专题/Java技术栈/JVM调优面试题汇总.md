---
category: [Java技术栈]
tag: [JVM,调优,面试]
postType: post
status: publish
---

## JVM组成

### JVM由那些部分组成，运行流程是什么？

JVM是什么

Java Virtual Machine Java程序的运行环境（java二进制字节码的运行环境）

好处：

1. 一次编写，到处运行
2. 自动内存管理，垃圾回收机制

![img](https://image.hyly.net/i/2025/09/19/c12e0e5b4bc792eca204172bb07fdd61-0.webp)

JVM由哪些部分组成，运行流程是什么？

![img](https://image.hyly.net/i/2025/09/19/eecb54c0d0b597a04de01151fb74e65e-0.webp)

从图中可以看出 JVM 的主要组成部分

1.  ClassLoader（类加载器）
2. Runtime Data Area（运行时数据区，内存分区）
3. Execution Engine（执行引擎）
4. Native Method Library（本地库接口）

运行流程：

（1）类加载器（ClassLoader）把Java代码转换为字节码

（2）运行时数据区（Runtime Data Area）把字节码加载到内存中，而字节码文件只是JVM的一套指令集规范，并不能直接交给底层系统去执行，而是有执行引擎运行

（3）执行引擎（Execution Engine）将字节码翻译为底层系统指令，再交由CPU执行去执行，此时需要调用其他语言的本地库接口（Native Method Library）来实现整个程序的功能。

### 什么是程序计数器？

程序计数器：线程私有的，内部保存的字节码的行号。用于记录正在执行的字节码指令的地址。

```
javap -verbose  xx.class    打印堆栈大小，局部变量的数量和方法的参数。
```

![img](https://image.hyly.net/i/2025/09/19/8e4e214c83286e2f3a9dfe7e84216528-0.webp)

java虚拟机对于多线程是通过线程轮流切换并且分配线程执行时间。在任何的一个时间点上，一个处理器只会处理执行一个线程，如果当前被执行的这个线程它所分配的执行时间用完了【挂起】。处理器会切换到另外的一个线程上来进行执行。并且这个线程的执行时间用完了，接着处理器就会又来执行被挂起的这个线程。

那么现在有一个问题就是，当前处理器如何能够知道，对于这个被挂起的线程，它上一次执行到了哪里？那么这时就需要从程序计数器中来回去到当前的这个线程他上一次执行的行号，然后接着继续向下执行。

程序计数器是JVM规范中唯一一个没有规定出现OOM的区域，所以这个空间也不会进行GC。

### 你能给我详细的介绍Java堆吗?

线程共享的区域：主要用来保存对象实例，数组等，当堆中没有内存空间可分配给实例，也无法再扩展时，则抛出OutOfMemoryError异常。

![img](https://image.hyly.net/i/2025/09/19/c7073605dff8241928a79972398875c1-0.webp)

1. 年轻代被划分为三部分，Eden区和两个大小严格相同的Survivor区，根据JVM的策略，在经过几次垃圾收集后，任然存活于Survivor的对象将被移动到老年代区间。
2. 老年代主要保存生命周期长的对象，一般是一些老的对象
3. 元空间保存的类信息、静态变量、常量、编译后的代码

为了避免方法区出现OOM，所以在java8中将堆上的方法区【永久代】给移动到了本地内存上，重新开辟了一块空间，叫做**元空间**。那么现在就可以避免掉OOM的出现了。

![img](https://image.hyly.net/i/2025/09/19/65230aa3a21e789d6bd5d7173ff3edba-0.webp)

#### 元空间(MetaSpace)介绍

在 HotSpot JVM 中，永久代（ ≈ 方法区）中用于存放类和方法的元数据以及常量池，比如Class 和 Method。每当一个类初次被加载的时候，它的元数据都会放到永久代中。

永久代是有大小限制的，因此如果加载的类太多，很有可能导致永久代内存溢出，即OutOfMemoryError，为此不得不对虚拟机做调优。

那么，Java 8 中 PermGen 为什么被移出 HotSpot JVM 了？

官网给出了解释：http://openjdk.java.net/jeps/122

```
This is part of the JRockit and Hotspot convergence effort. JRockit customers do not need to configure the permanent generation (since JRockit does not have a permanent generation) and are accustomed to not configuring the permanent generation.

移除永久代是为融合HotSpot JVM与 JRockit VM而做出的努力，因为JRockit没有永久代，不需要配置永久代。
```

1. 由于 PermGen 内存经常会溢出，引发OutOfMemoryError，因此 JVM 的开发者希望这一块内存可以更灵活地被管理，不要再经常出现这样的 OOM。
2. 移除 PermGen 可以促进 HotSpot JVM 与 JRockit VM 的融合，因为 JRockit 没有永久代。

准确来说，Perm 区中的字符串常量池被移到了堆内存中是在 Java7 之后，Java 8 时，PermGen 被元空间代替，其他内容比如**类元信息、字段、静态属性、方法、常量**等都移动到元空间区。比如 java/lang/Object 类元信息、静态属性 System.out、整型常量等。

元空间的本质和永久代类似，都是对 JVM 规范中方法区的实现。不过元空间与永久代之间最大的区别在于：元空间并不在虚拟机中，而是使用本地内存。因此，默认情况下，元空间的大小仅受本地内存限制。

### 什么是虚拟机栈

Java Virtual machine Stacks (java 虚拟机栈)

1. 每个线程运行时所需要的内存，称为虚拟机栈，先进后出
2. 每个栈由多个栈帧（frame）组成，对应着每次方法调用时所占用的内存
3. 每个线程只能有一个活动栈帧，对应着当前正在执行的那个方法

![img](https://image.hyly.net/i/2025/09/20/1538a0e0aefcaa84410d1c6d471a0b58-0.webp)

1. 垃圾回收是否涉及栈内存？

垃圾回收主要指就是堆内存，当栈帧弹栈以后，内存就会释放

1. 栈内存分配越大越好吗？

未必，默认的栈内存通常为1024k

栈帧过大会导致线程数变少，例如，机器总内存为512m，目前能活动的线程数则为512个，如果把栈内存改为2048k，那么能活动的栈帧就会减半

1. 方法内的局部变量是否线程安全？
	1. 如果方法内局部变量没有逃离方法的作用范围，它是线程安全的
	2. 如果是局部变量引用了对象，并逃离方法的作用范围，需要考虑线程安全
	3. 比如以下代码：

![img](https://image.hyly.net/i/2025/09/20/3444d8213922750c0a0c166cbe210aa4-0.webp)

**栈内存溢出情况**

1. 栈帧过多导致栈内存溢出，典型问题：递归调用
![img](https://image.hyly.net/i/2025/09/20/3c6f0fb891a6ab96608b2d9696c2347d-0.webp)
2. 栈帧过大导致栈内存溢出

组成部分：堆、方法区、栈、本地方法栈、程序计数器

1. 堆解决的是对象实例存储的问题，垃圾回收器管理的主要区域。
2. 方法区可以认为是堆的一部分，用于存储已被虚拟机加载的信息，常量、静态变量、即时编译器编译后的代码。
3. 栈解决的是程序运行的问题，栈里面存的是栈帧，栈帧里面存的是局部变量表、操作数栈、动态链接、方法出口等信息。
4. 本地方法栈与栈功能相同，本地方法栈执行的是本地方法，一个Java调用非Java代码的接口。
5. 程序计数器（PC寄存器）程序计数器中存放的是当前线程所执行的字节码的行数。JVM工作时就是通过改变这个计数器的值来选取下一个需要执行的字节码指令。

### 能不能解释一下方法区？

#### 概述：

1. 方法区(Method Area)是各个线程共享的内存区域
2. 主要存储类的信息、运行时常量池
3. 虚拟机启动的时候创建，关闭虚拟机时释放
4. 如果方法区域中的内存无法满足分配请求，则会抛出OutOfMemoryError: Metaspace

![img](https://image.hyly.net/i/2025/09/21/966b5a693b7fffaed1118750f0359476-0.webp)

#### 常量池

可以看作是一张表，虚拟机指令根据这张常量表找到要执行的类名、方法名、参数类型、字面量等信息

查看字节码结构（类的基本信息、常量池、方法定义）`javap -v xx.class`

比如下面是一个Application类的main方法执行，源码如下：

```
public class Application {
    public static void main(String[] args) {
        System.out.println("hello world");
    }
}
```

找到类对应的class文件存放目录，执行命令：`javap -v Application.class`   查看字节码结构：

```
D:\code\jvm-demo\target\classes\com\heima\jvm>javap -v Application.class
Classfile /D:/code/jvm-demo/target/classes/com/heima/jvm/Application.class
  Last modified 2023-05-07; size 564 bytes    //最后修改的时间
  MD5 checksum c1b64ed6491b9a16c2baab5061c64f88   //签名
  Compiled from "Application.java"   //从哪个源码编译
public class com.heima.jvm.Application   //包名，类名
  minor version: 0
  major version: 52     //jdk版本
  flags: ACC_PUBLIC, ACC_SUPER  //修饰符
Constant pool:   //常量池
   #1 = Methodref          #6.#20         // java/lang/Object."<init>":()V
   #2 = Fieldref           #21.#22        // java/lang/System.out:Ljava/io/PrintStream;
   #3 = String             #23            // hello world
   #4 = Methodref          #24.#25        // java/io/PrintStream.println:(Ljava/lang/String;)V
   #5 = Class              #26            // com/heima/jvm/Application
   #6 = Class              #27            // java/lang/Object
   #7 = Utf8               <init>
   #8 = Utf8               ()V
   #9 = Utf8               Code
  #10 = Utf8               LineNumberTable
  #11 = Utf8               LocalVariableTable
  #12 = Utf8               this
  #13 = Utf8               Lcom/heima/jvm/Application;
  #14 = Utf8               main
  #15 = Utf8               ([Ljava/lang/String;)V
  #16 = Utf8               args
  #17 = Utf8               [Ljava/lang/String;
  #18 = Utf8               SourceFile
  #19 = Utf8               Application.java
  #20 = NameAndType        #7:#8          // "<init>":()V
  #21 = Class              #28            // java/lang/System
  #22 = NameAndType        #29:#30        // out:Ljava/io/PrintStream;
  #23 = Utf8               hello world
  #24 = Class              #31            // java/io/PrintStream
  #25 = NameAndType        #32:#33        // println:(Ljava/lang/String;)V
  #26 = Utf8               com/heima/jvm/Application
  #27 = Utf8               java/lang/Object
  #28 = Utf8               java/lang/System
  #29 = Utf8               out
  #30 = Utf8               Ljava/io/PrintStream;
  #31 = Utf8               java/io/PrintStream
  #32 = Utf8               println
  #33 = Utf8               (Ljava/lang/String;)V
{
  public com.heima.jvm.Application();  //构造方法
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 3: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   Lcom/heima/jvm/Application;

  public static void main(java.lang.String[]);  //main方法
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=1, args_size=1
         0: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
         3: ldc           #3                  // String hello world
         5: invokevirtual #4                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
         8: return
      LineNumberTable:
        line 7: 0
        line 8: 8
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       9     0  args   [Ljava/lang/String;
}
SourceFile: "Application.java"
```

下图，左侧是main方法的指令信息，右侧constant pool  是常量池

main方法按照指令执行的时候，需要到常量池中查表翻译找到具体的类和方法地址去执行

![img](https://image.hyly.net/i/2025/09/21/9a459bcf0ca2003e11511e3abbdc9a68-0.webp)

#### 运行时常量池

常量池是 *.class 文件中的，当该类被加载，它的常量池信息就会放入运行时常量池，并把里面的符号地址变为真实地址：

![img](https://image.hyly.net/i/2025/09/21/2ce4e491d5eeeeb33687d4995e50a693-0.webp)

### 你听过直接内存吗？

不受 JVM 内存回收管理，是虚拟机的系统内存，常见于 NIO 操作时，用于数据缓冲区，分配回收成本较高，但读写性能高，不受 JVM 内存回收管理

举例：

需求，在本地电脑中的一个较大的文件（超过100m）从一个磁盘挪到另外一个磁盘

![img](https://image.hyly.net/i/2025/09/21/6d8d5a32b5c672d59a4c250a1d352899-0.webp)

代码如下：

```
/**
 * 演示 ByteBuffer 作用
 */
public class Demo1_9 {
    static final String FROM = "E:\\编程资料\\第三方教学视频\\youtube\\Getting Started with Spring Boot-sbPSjI4tt10.mp4";
    static final String TO = "E:\\a.mp4";
    static final int _1Mb = 1024 * 1024;

    public static void main(String[] args) {
        io(); // io 用时：1535.586957 1766.963399 1359.240226
        directBuffer(); // directBuffer 用时：479.295165 702.291454 562.56592
    }

    private static void directBuffer() {
        long start = System.nanoTime();
        try (FileChannel from = new FileInputStream(FROM).getChannel();
             FileChannel to = new FileOutputStream(TO).getChannel();
        ) {
            ByteBuffer bb = ByteBuffer.allocateDirect(_1Mb);
            while (true) {
                int len = from.read(bb);
                if (len == -1) {
                    break;
                }
                bb.flip();
                to.write(bb);
                bb.clear();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        long end = System.nanoTime();
        System.out.println("directBuffer 用时：" + (end - start) / 1000_000.0);
    }

    private static void io() {
        long start = System.nanoTime();
        try (FileInputStream from = new FileInputStream(FROM);
             FileOutputStream to = new FileOutputStream(TO);
        ) {
            byte[] buf = new byte[_1Mb];
            while (true) {
                int len = from.read(buf);
                if (len == -1) {
                    break;
                }
                to.write(buf, 0, len);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        long end = System.nanoTime();
        System.out.println("io 用时：" + (end - start) / 1000_000.0);
    }
}
```

可以发现，使用传统的IO的时间要比NIO操作的时间长了很多了，也就说NIO的读性能更好。

这个是跟我们的JVM的直接内存是有一定关系，如下图，是传统阻塞IO的数据传输流程

![img](https://image.hyly.net/i/2025/09/21/4cde84862dde099f53933b1b27ba5352-0.webp)

下图是NIO传输数据的流程，在这个里面主要使用到了一个直接内存，不需要在堆中开辟空间进行数据的拷贝，jvm可以直接操作直接内存，从而使数据读写传输更快。

![img](https://image.hyly.net/i/2025/09/21/19c2ff5543734311f73c0393811e40fa-0.webp)

### 堆栈的区别是什么？

1、栈内存一般会用来存储局部变量和方法调用，但堆内存是用来存储Java对象和数组的的。堆会GC垃圾回收，而栈不会。

2、栈内存是线程私有的，而堆内存是线程共有的。

3,、两者异常错误不同，但如果栈内存或者堆内存不足都会抛出异常。

栈空间不足：java.lang.StackOverFlowError。

堆空间不足：java.lang.OutOfMemoryError。

## 类加载器

什么是类加载器，类加载器有哪些?

要想理解类加载器的话，务必要先清楚对于一个Java文件，它从编译到执行的整个过程。

![img](https://image.hyly.net/i/2025/09/21/624207f05242b428a1408ff8c15949b0-0.webp)

1. 类加载器：用于装载字节码文件(.class文件)
2. 运行时数据区：用于分配存储空间
3. 执行引擎：执行字节码文件或本地方法
4. 垃圾回收器：用于对JVM中的垃圾内容进行回收

**类加载器**

JVM只会运行二进制文件，而类加载器（ClassLoader）的主要作用就是将**字节码文件加载到JVM中**，从而让Java程序能够启动起来。现有的类加载器基本上都是java.lang.ClassLoader的子类，该类的只要职责就是用于将指定的类找到或生成对应的字节码文件，同时类加载器还会负责加载程序所需要的资源

**类加载器种类**

类加载器根据各自加载范围的不同，划分为四种类加载器：

- **启动类加载器(BootStrap ClassLoader)：**

该类并不继承ClassLoader类，其是由C++编写实现。用于加载**JAVA_HOME/jre/lib**目录下的类库。

- **扩展类加载器(ExtClassLoader)：**

该类是ClassLoader的子类，主要加载**JAVA_HOME/jre/lib/ext**目录中的类库。

- **应用类加载器(AppClassLoader)：**

该类是ClassLoader的子类，主要用于加载**classPath**下的类，也就是加载开发者自己编写的Java类。

- **自定义类加载器：**

开发者自定义类继承ClassLoader，实现自定义类加载规则。

上述三种类加载器的层次结构如下如下：

![img](https://image.hyly.net/i/2025/09/21/69d0487c1007a31a69123683799b5a81-0.webp)

类加载器的体系并不是“继承”体系，而是**委派体系**，类加载器首先会到自己的parent中查找类或者资源，如果找不到才会到自己本地查找。类加载器的委托行为动机是为了避免相同的类被加载多次。

### 什么是双亲委派模型？

如果一个类加载器在接到加载类的请求时，它首先不会自己尝试去加载这个类，而是把这个请求任务委托给父类加载器去完成，依次递归，如果父类加载器可以完成类加载任务，就返回成功；只有父类加载器无法完成此加载任务时，才由下一级去加载。

![img](https://image.hyly.net/i/2025/09/21/7968d9399e2b3e2e3d12147af43de46e-0.webp)

### JVM为什么采用双亲委派机制

（1）通过双亲委派机制可以避免某一个类被重复加载，当父类已经加载后则无需重复加载，保证唯一性。

（2）为了安全，保证类库API不会被修改

在工程中新建java.lang包，接着在该包下新建String类，并定义main函数

```
public class String {

    public static void main(String[] args) {

        System.out.println("demo info");
    }
}
```

此时执行main函数，会出现异常，在类 java.lang.String 中找不到 main 方法

![img](https://image.hyly.net/i/2025/09/21/109b8735bff471ca02728c457c8d7ef6-0.webp)

出现该信息是因为由双亲委派的机制，java.lang.String的在启动类加载器(Bootstrap classLoader)得到加载，因为在核心jre库中有其相同名字的类文件，但该类中并没有main方法。这样就能防止恶意篡改核心API库。

### 说一下类装载的执行过程？

类从加载到虚拟机中开始，直到卸载为止，它的整个生命周期包括了：加载、验证、准备、解析、初始化、使用和卸载这7个阶段。其中，验证、准备和解析这三个部分统称为连接（linking）。

![img](https://image.hyly.net/i/2025/09/21/dbd6807a0969d940472af9057bf52454-0.webp)

**类加载过程详解**

1.加载

![img](https://image.hyly.net/i/2025/09/21/a8b7d40ce2fef45ffe3370ee7f522a32-0.webp)

1. 通过类的全名，获取类的二进制数据流。
2. 解析类的二进制数据流为方法区内的数据结构（Java类模型）
3. 创建java.lang.Class类的实例，表示该类型。作为方法区这个类的各种数据的访问入口

![img](https://image.hyly.net/i/2025/09/21/21b5a88c9b2f2654c2fd488f21ca9bb8-0.webp)

2.验证

![img](https://image.hyly.net/i/2025/09/21/2ae024a5ce963efdb524bb7fe65d722a-0.webp)

**验证类是否符合JVM规范，安全性检查**

(1)文件格式验证:是否符合Class文件的规范

(2)元数据验证

这个类是否有父类（除了Object这个类之外，其余的类都应该有父类）

这个类是否继承（extends）了被final修饰过的类（被final修饰过的类表示类不能被继承）

类中的字段、方法是否与父类产生矛盾。（被final修饰过的方法或字段是不能覆盖的）

(3)字节码验证

主要的目的是通过对数据流和控制流的分析，确定程序语义是合法的、符合逻辑的。

(4)符号引用验证：符号引用以一组符号来描述所引用的目标，符号可以是任何形式的字面量

```
比如：int i = 3;
字面量：3
符号引用：i
```

3.准备

![img](https://image.hyly.net/i/2025/09/21/345ee8227a72555e7da699c11837880a-0.webp)

**为类变量分配内存并设置类变量初始值**

1. static变量，分配空间在准备阶段完成（设置默认值），赋值在初始化阶段完成
2. static变量是final的基本类型，以及字符串常量，值已确定，赋值在准备阶段完成
3. static变量是final的引用类型，那么赋值也会在初始化阶段完成

![img](https://image.hyly.net/i/2025/09/21/71aae006b90d49dda8989a73b5469e30-0.webp)

4.解析

![img](https://image.hyly.net/i/2025/09/21/508324c5368357c3b3434c00b88b42dc-0.webp)

**把类中的符号引用转换为直接引用**

比如：方法中调用了其他方法，方法名可以理解为符号引用，而直接引用就是使用指针直接指向方法。

![img](https://image.hyly.net/i/2025/09/21/b0c91b45e6051d83ac0e7db2d1850de4-0.webp)

5.初始化

![img](https://image.hyly.net/i/2025/09/21/79b5e1f2833bfc47ae48c50b2d291db9-0.webp)

**对类的静态变量，静态代码块执行初始化操作**

1. 如果初始化一个类的时候，其父类尚未初始化，则优先初始化其父类。
2. 如果同时包含多个静态变量和静态代码块，则按照自上而下的顺序依次执行。

6.使用

![img](https://image.hyly.net/i/2025/09/21/9cdf99f085314dc841542cabd38e48ab-0.webp)

JVM 开始从入口方法开始执行用户的程序代码

- 调用静态类成员信息（比如：静态字段、静态方法）
- 使用new关键字为其创建对象实例

7.卸载

当用户程序代码执行完毕后，JVM 便开始销毁创建的 Class 对象，最后负责运行的 JVM 也退出内存

## 垃圾收回

### 简述Java垃圾回收机制？（GC是什么？为什么要GC）

为了让程序员更专注于代码的实现，而不用过多的考虑内存释放的问题，所以，在Java语言中，有了自动的垃圾回收机制，也就是我们熟悉的GC(Garbage Collection)。

有了垃圾回收机制后，程序员只需要关心内存的申请即可，内存的释放由系统自动识别完成。

在进行垃圾回收时，不同的对象引用类型，GC会采用不同的回收时机

换句话说，自动的垃圾回收的算法就会变得非常重要了，如果因为算法的不合理，导致内存资源一直没有释放，同样也可能会导致内存溢出的。

当然，除了Java语言，C#、Python等语言也都有自动的垃圾回收机制。

### 对象什么时候可以被垃圾器回收

![img](https://image.hyly.net/i/2025/09/21/548f061b8cc186aea4ffaef0d736ac9c-0.webp)

简单一句就是：如果一个或多个对象没有任何的引用指向它了，那么这个对象现在就是垃圾，如果定位了垃圾，则有可能会被垃圾回收器回收。

如果要定位什么是垃圾，有两种方式来确定，第一个是引用计数法，第二个是可达性分析算法

#### 引用计数法

一个对象被引用了一次，在当前的对象头上递增一次引用次数，如果这个对象的引用次数为0，代表这个对象可回收

```
String demo = new String("123");
```

![img](https://image.hyly.net/i/2025/09/21/29e0fa6aa4ac5c8fb3a706631ee00f5f-0.webp)

```
String demo = null;
```

![img](https://image.hyly.net/i/2025/09/21/efa1d98e0e4b3e3e76b8b4e9aa599cb8-0.webp)

当对象间出现了循环引用的话，则引用计数法就会失效

![img](https://image.hyly.net/i/2025/09/21/16aa7684a17f102f5adfcd61bbf8f18b-0.webp)

先执行右侧代码的前4行代码

![img](https://image.hyly.net/i/2025/09/21/5d72b22c0249446f21a14e7f0eeaaa6e-0.webp)

目前上方的引用关系和计数都是没问题的，但是，如果代码继续往下执行，如下图：

![img](https://image.hyly.net/i/2025/09/21/c35a28750af9a33b8ee0e9629ac23175-0.webp)

虽然a和b都为null，但是由于a和b存在循环引用，这样a和b永远都不会被回收。

优点：

1. 实时性较高，无需等到内存不够的时候，才开始回收，运行时根据对象的计数器是否为0，就可以直接回收。
2. 在垃圾回收过程中，应用无需挂起。如果申请内存时，内存不足，则立刻报OOM错误。
3. 区域性，更新对象的计数器时，只是影响到该对象，不会扫描全部对象。

缺点：

1. 每次对象被引用时，都需要去更新计数器，有一点时间开销。
2. 浪费CPU资源，即使内存够用，仍然在运行时进行计数器的统计。
3. 无法解决循环引用问题，会引发内存泄露。（最大的缺点）

#### 可达性分析算法

现在的虚拟机采用的都是通过可达性分析算法来确定哪些内容是垃圾。

会存在一个根节点【GC Roots】，引出它下面指向的下一个节点，再以下一个节点节点开始找出它下面的节点，依次往下类推。直到所有的节点全部遍历完毕。

根对象是那些肯定不能当做垃圾回收的对象，就可以当做根对象
局部变量，静态方法，静态变量，类信息
核心是：判断某对象是否与根对象有直接或间接的引用，如果没有被引用，则可以当做垃圾回收

![img](https://image.hyly.net/i/2025/09/21/07f6fea53bac9f40faf3eea2be62e42f-0.webp)

X,Y这两个节点是可回收的，但是**并不会马上的被回收！！** 对象中存在一个方法【finalize】。当对象被标记为可回收后，当发生GC时，首先**会判断这个对象是否执行了finalize方法**，如果这个方法还没有被执行的话，那么就会先来执行这个方法，接着在这个方法执行中，可以设置当前这个对象与GC ROOTS产生关联，那么这个方法执行完成之后，GC会再次判断对象是否可达，如果仍然不可达，则会进行回收，如果可达了，则不会进行回收。

finalize方法对于每一个对象来说，只会执行一次。如果第一次执行这个方法的时候，设置了当前对象与RC ROOTS关联，那么这一次不会进行回收。 那么等到这个对象第二次被标记为可回收时，那么该对象的finalize方法就不会再次执行了。

**GC ROOTS：**

虚拟机栈（栈帧中的本地变量表）中引用的对象

```
/**
 * demo是栈帧中的本地变量，当 demo = null 时，由于此时 demo 充当了 GC Root 的作用，demo与原来指向的实例 new Demo() 断开了连接，对象被回收。
 */
public class Demo {
    public static  void main(String[] args) {
    	Demo demo = new Demo();
    	demo = null;
    }
}
```

方法区中类静态属性引用的对象

```
/**
 * 当栈帧中的本地变量 b = null 时，由于 b 原来指向的对象与 GC Root (变量 b) 断开了连接，所以 b 原来指向的对象会被回收，而由于我们给 a 赋值了变量的引用，a在此时是类静态属性引用，充当了 GC Root 的作用，它指向的对象依然存活!
 */
public class Demo {
    public static Demo a;
    public static  void main(String[] args) {
        Demo b = new Demo();
        b.a = new Demo();
        b = null;
    }
}
```

方法区中常量引用的对象

```
/**
 * 常量 a 指向的对象并不会因为 demo 指向的对象被回收而回收
 */
public class Demo {
    
    public static final Demo a = new Demo();
    
    public static  void main(String[] args) {
        Demo demo = new Demo();
        demo = null;
    }
}
```

本地方法栈中 JNI（即一般说的 Native 方法）引用的对象

### JVM 垃圾回收算法有哪些？

#### 标记清除算法

标记清除算法，是将垃圾回收分为2个阶段，分别是**标记和清除**。

1.根据可达性分析算法得出的垃圾进行标记

2.对这些标记为可回收的内容进行垃圾回收

![img](https://image.hyly.net/i/2025/09/21/5953b649e3b44ad735712504069b8304-0.webp)

可以看到，标记清除算法解决了引用计数算法中的循环引用的问题，没有从root节点引用的对象都会被回收。

同样，标记清除算法也是有缺点的：

1. 效率较低，**标记和清除两个动作都需要遍历所有的对象**，并且在GC时，**需要停止应用程序**，对于交互性要求比较高的应用而言这个体验是非常差的。
2. **（重要）**通过标记清除算法清理出来的内存，碎片化较为严重，因为被回收的对象可能存在于内存的各个角落，所以清理出来的内存是不连贯的。

#### 复制算法

复制算法的核心就是，**将原有的内存空间一分为二，每次只用其中的一块**，在垃圾回收时，将正在使用的对象复制到另一个内存空间中，然后将该内存空间清空，交换两个内存的角色，完成垃圾的回收。

如果内存中的垃圾对象较多，需要复制的对象就较少，这种情况下适合使用该方式并且效率比较高，反之，则不适合。

![img](https://image.hyly.net/i/2025/09/21/7ebd04e961a2040cccbae528275eccf7-0.webp)

1）将内存区域分成两部分，每次操作其中一个。

2）当进行垃圾回收时，将正在使用的内存区域中的存活对象移动到未使用的内存区域。当移动完对这部分内存区域一次性清除。

3）周而复始。

优点：

1. 在垃圾对象多的情况下，效率较高
2. 清理后，内存无碎片

缺点：

1. 分配的2块内存空间，在同一个时刻，只能使用一半，内存使用率较低

#### 标记整理算法

标记压缩算法是在标记清除算法的基础之上，做了优化改进的算法。和标记清除算法一样，也是从根节点开始，对对象的引用进行标记，在清理阶段，并不是简单的直接清理可回收对象，而是将存活对象都向内存另一端移动，然后清理边界以外的垃圾，从而解决了碎片化的问题。

![img](https://image.hyly.net/i/2025/09/21/03c71e29ac092b8f89c1ebdb333ea636-0.webp)

1）标记垃圾。

2）需要清除向右边走，不需要清除的向左边走。

3）清除边界以外的垃圾。

优缺点同标记清除算法，解决了标记清除算法的碎片化的问题，同时，标记压缩算法多了一步，对象移动内存位置的步骤，其效率也有有一定的影响。

与复制算法对比：复制算法标记完就复制，但标记整理算法得等把所有存活对象都标记完毕，再进行整理

#### 分代收集算法

##### 概述

在java8时，堆被分为了两份：**新生代和老年代【1：2】**，在java7时，还存在一个永久代。

![img](https://image.hyly.net/i/2025/09/21/03984aa7203dcbcfffc9294858a87013-0.webp)

对于新生代，内部又被分为了三个区域。Eden区，S0区，S1区【8：1：1】
当对新生代产生GC：MinorGC【young GC】
当对老年代代产生GC：Major GC
当对新生代和老年代产生FullGC： 新生代 + 老年代完整垃圾回收，暂停时间长，**应尽力避免**

##### 工作机制

![img](https://image.hyly.net/i/2025/09/21/67c90bfc1aa1a1490bf2db73092defea-0.webp)

新创建的对象，都会先分配到eden区

![img](https://image.hyly.net/i/2025/09/21/5cd35bb82e3ff7079e294f6e8edf43ea-0.webp)

当伊甸园内存不足，标记伊甸园与 from（现阶段没有）的存活对象
将存活对象采用复制算法复制到 to 中，复制完毕后，伊甸园和 from 内存都得到释放

![img](https://image.hyly.net/i/2025/09/21/3860974799a9f265e6d64452e0bb57cf-0.webp)

经过一段时间后伊甸园的内存又出现不足，标记eden区域to区存活的对象，将存活的对象复制到from区

![img](https://image.hyly.net/i/2025/09/21/5c495b39c919b72cc7d129e4230559db-0.webp)

![img](https://image.hyly.net/i/2025/09/21/0777bb8261465797a2c0c897f305f3eb-0.webp)

当幸存区对象熬过几次回收（最多15次），晋升到老年代（幸存区内存不足或大对象会导致提前晋升）

##### MinorGC、 Mixed GC 、 FullGC的区别是什么

![img](https://image.hyly.net/i/2025/09/21/ae5bf90e492c0aa509af57fb474ec3c1-0.webp)

1. MinorGC【young GC】发生在新生代的垃圾回收，暂停时间短（STW）
2. Mixed GC 新生代 + 老年代部分区域的垃圾回收，G1 收集器特有
3. FullGC： 新生代 + 老年代完整垃圾回收，暂停时间长（STW），应尽力避免？

名词解释：
STW（Stop-The-World）：暂停所有应用程序线程，等待垃圾回收的完成

### 说一下 JVM 有哪些垃圾回收器？

在jvm中，实现了多种垃圾收集器，包括：

1. 串行垃圾收集器
2. 并行垃圾收集器
3. CMS（并发）垃圾收集器
4. G1垃圾收集器

#### 串行垃圾收集器

Serial和Serial Old串行垃圾收集器，是指使用单线程进行垃圾回收，堆内存较小，适合个人电脑

1. Serial 作用于新生代，采用复制算法
2. Serial Old 作用于老年代，采用标记-整理算法

垃圾回收时，只有一个线程在工作，并且java应用中的所有线程都要暂停（STW），等待垃圾回收的完成。

![img](https://image.hyly.net/i/2025/09/21/754a5251744b09fb4b296bb93630d78f-0.webp)

#### 并行垃圾收集器

Parallel New和Parallel Old是一个并行垃圾回收器，**JDK8默认使用此垃圾回收器**

1. Parallel New作用于新生代，采用复制算法
2. Parallel Old作用于老年代，采用标记-整理算法

垃圾回收时，多个线程在工作，并且java应用中的所有线程都要暂停（STW），等待垃圾回收的完成。

![img](https://image.hyly.net/i/2025/09/21/e9ac0c8e8c9aa3e86c34d454505a5169-0.webp)

#### CMS（并发）垃圾收集器

CMS全称 Concurrent Mark Sweep，是一款并发的、使用标记-清除算法的垃圾回收器，该回收器是针对老年代垃圾回收的，是一款以获取最短回收停顿时间为目标的收集器，停顿时间短，用户体验就好。其最大特点是在进行垃圾回收时，应用仍然能正常运行。

![img](https://image.hyly.net/i/2025/09/21/f345b050f97d0a05926a821692963c30-0.webp)

![img](https://image.hyly.net/i/2025/09/21/6ad5cd64a83c4525f918b6770c283504-0.webp)

### 详细聊一下G1垃圾回收器

#### 概述

1. 应用于新生代和老年代，**在JDK9之后默认使用G1**
2. 划分成多个区域，每个区域都可以充当 eden，survivor，old， humongous，其中 humongous 专为大对象准备
3. 采用复制算法
4. 响应时间与吞吐量兼顾
5. 分成三个阶段：新生代回收、并发标记、混合收集
6. 如果并发失败（即回收速度赶不上创建新对象速度），会触发 Full GC

![img](https://image.hyly.net/i/2025/09/21/c562d86a0ac8ea0087ed7525593db4c0-0.webp)

#### Young Collection(年轻代垃圾回收)

初始时，所有区域都处于空闲状态

![img](https://image.hyly.net/i/2025/09/21/891e68efb12b96347f06b42fa90efffc-0.webp)

创建了一些对象，挑出一些空闲区域作为伊甸园区存储这些对象

![img](https://image.hyly.net/i/2025/09/21/a2a1a2846333ed2cb6885e2b195fbad1-0.webp)

当伊甸园需要垃圾回收时，挑出一个空闲区域作为幸存区，用复制算法复制存活对象，需要暂停用户线程

![img](https://image.hyly.net/i/2025/09/21/36c8a9a79bd8dd6a66b6f9e38dcba490-0.webp)

![img](https://image.hyly.net/i/2025/09/21/bbd92a438dac987374300f178f496b87-0.webp)

随着时间流逝，伊甸园的内存又有不足
将伊甸园以及之前幸存区中的存活对象，采用复制算法，复制到新的幸存区，其中较老对象晋升至老年代

![img](https://image.hyly.net/i/2025/09/21/6cd32275fc2928f496cf42e8bb9d42ae-0.webp)

![img](https://image.hyly.net/i/2025/09/21/7064f8b11ab24c87590d32dc2af93c78-0.webp)

![img](https://image.hyly.net/i/2025/09/21/b25f4f932a764405d0162be6cd86c2ff-0.webp)

#### Young Collection + Concurrent Mark (年轻代垃圾回收+并发标记)

当老年代占用内存超过阈值(默认是45%)后，触发并发标记，这时无需暂停用户线程

![img](https://image.hyly.net/i/2025/09/21/b5814aac94d33908afc7a3c3409be708-0.webp)

- 并发标记之后，会有重新标记阶段解决漏标问题，此时需要暂停用户线程。
- 这些都完成后就知道了老年代有哪些存活对象，随后进入混合收集阶段。此时不会对所有老年代区域进行回收，而是根据暂停时间目标优先回收价值高（存活对象少）的区域（这也是 Gabage First 名称的由来）。

![img](https://image.hyly.net/i/2025/09/21/db3d3a0678300c1030ea0ac2f5aaf97a-0.webp)

#### Mixed Collection (混合垃圾回收)

复制完成，内存得到释放。进入下一轮的新生代回收、并发标记、混合收集

![img](https://image.hyly.net/i/2025/09/21/8da995216db7f2fddb0d5ba0fc90daf4-0.webp)

其中H叫做巨型对象，如果对象非常大，会开辟一块连续的空间存储巨型对象

![img](https://image.hyly.net/i/2025/09/21/3b544b01b1b26c703a3552a86355ee77-0.webp)

### 强引用、软引用、弱引用、虚引用的区别？

#### 强引用

强引用：只有所有 GC Roots 对象都不通过【强引用】引用该对象，该对象才能被垃圾回收

```
User user = new User();
```

![img](https://image.hyly.net/i/2025/09/21/605e4e51c6697b419c91fea845bc69c8-0.webp)

#### 软引用

软引用：仅有软引用引用该对象时，在垃圾回收后，内存仍不足时会再次出发垃圾回收

```
User user = new User();
SoftReference softReference = new SoftReference(user);
```

![img](https://image.hyly.net/i/2025/09/21/78d9c2c6ee248f91d0690a9c2a8b6f67-0.webp)

####  弱引用

弱引用：仅有弱引用引用该对象时，在垃圾回收时，无论内存是否充足，都会回收弱引用对象

```
User user = new User();
WeakReference weakReference = new WeakReference(user);
```

![img](https://image.hyly.net/i/2025/09/22/61a573b3b668f6302274d8b3dbcbf0e4-0.webp)

> 延伸话题：ThreadLocal内存泄漏问题

ThreadLocal用的就是弱引用，看以下源码：

```
static class Entry extends WeakReference<ThreadLocal<?>> {
    Object value;

    Entry(ThreadLocal<?> k, Object v) {
         super(k);
         value = v; //强引用，不会被回收
     }
}
```

`Entry`的key是当前ThreadLocal，value值是我们要设置的数据。

`WeakReference`表示的是弱引用，当JVM进行GC时，一旦发现了只具有弱引用的对象，不管当前内存空间是否足够，都会回收它的内存。但是`value`是强引用，它不会被回收掉。

> ThreadLocal使用建议：使用完毕后注意调用清理方法。

#### 虚引用

虚引用：必须配合引用队列使用，被引用对象回收时，会将虚引用入队，由 Reference Handler 线程调用虚引用相关方法释放直接内存

![img](https://image.hyly.net/i/2025/09/22/5fe348ae207adf1a3052b720c719052f-0.webp)

![img](https://image.hyly.net/i/2025/09/22/441eb61bff32e97d9f448215c3bd16b1-0.webp)

##  JVM实践（调优）

### JVM 调优的参数可以在哪里设置参数值？

#### tomcat的设置vm参数

修改TOMCAT_HOME/bin/catalina.sh文件，如下图

```
JAVA_OPTS="-Xms512m -Xmx1024m" 
```

![img](https://image.hyly.net/i/2025/09/22/74b94211fb3fda2d292e24705dde5618-0.webp)

#### springboot项目jar文件启动

通常在linux系统下直接加参数启动springboot项目

```
nohup java -Xms512m -Xmx1024m -jar xxxx.jar --spring.profiles.active=prod &
```

> nohup  :  用于在系统后台不挂断地运行命令，退出终端不会影响程序的运行
> 参数 **&**  ：让命令在后台执行，终端退出后命令仍旧执行。

### 用的 JVM 调优的参数都有哪些？

对于JVM调优，主要就是调整年轻代、年老大、元空间的内存空间大小及使用的垃圾回收器类型。

https://www.oracle.com/java/technologies/javase/vmoptions-jsp.html

1）设置堆的初始大小和最大大小，为了防止垃圾收集器在初始大小、最大大小之间收缩堆而产生额外的时间，通常把最大、初始大小设置为相同的值。

```
-Xms：设置堆的初始化大小

-Xmx：设置堆的最大大小
```

2） 设置年轻代中Eden区和两个Survivor区的大小比例。该值如果不设置，则默认比例为8:1:1。Java官方通过增大Eden区的大小，来减少YGC发生的次数，但有时我们发现，虽然次数减少了，但Eden区满的时候，由于占用的空间较大，导致释放缓慢，此时STW的时间较长，因此需要按照程序情况去调优。

```
-XXSurvivorRatio=3，表示年轻代中的分配比率：survivor:eden = 2:3
```

3）年轻代和老年代默认比例为1：2。可以通过调整二者空间大小比率来设置两者的大小。

```
-XX:newSize   设置年轻代的初始大小
-XX:MaxNewSize   设置年轻代的最大大小，  初始大小和最大大小两个值通常相同
```

4）线程堆栈的设置：**每个线程默认会开启1M的堆栈**，用于存放栈帧、调用参数、局部变量等，但一般256K就够用。通常减少每个线程的堆栈，可以产生更多的线程，但这实际上还受限于操作系统。

> -Xss   对每个线程stack大小的调整,-Xss128k

5）一般来说，当survivor区不够大或者占用量达到50%，就会把一些对象放到老年区。通过设置合理的eden区，survivor区及使用率，可以将年轻对象保存在年轻代，从而避免full GC，使用-Xmn设置年轻代的大小

6）系统CPU持续飙高的话，首先先排查代码问题，如果代码没问题，则咨询运维或者云服务器供应商，通常服务器重启或者服务器迁移即可解决。

7）对于占用内存比较多的大对象，一般会选择在老年代分配内存。如果在年轻代给大对象分配内存，年轻代内存不够了，就要在eden区移动大量对象到老年代，然后这些移动的对象可能很快消亡，因此导致full GC。通过设置参数：-XX:PetenureSizeThreshold=1000000，单位为B，标明对象大小超过1M时，在老年代(tenured)分配内存空间。

8）一般情况下，年轻对象放在eden区，当第一次GC后，如果对象还存活，放到survivor区，此后，每GC一次，年龄增加1，当对象的年龄达到阈值，就被放到tenured老年区。这个阈值可以同构-XX:MaxTenuringThreshold设置。如果想让对象留在年轻代，可以设置比较大的阈值。

```
（1）-XX:+UseParallelGC:年轻代使用并行垃圾回收收集器。这是一个关注吞吐量的收集器，可以尽可能的减少垃圾回收时间。

（2）-XX:+UseParallelOldGC:设置老年代使用并行垃圾回收收集器。
```

9）尝试使用大的内存分页：使用大的内存分页增加CPU的内存寻址能力，从而系统的性能。

```
-XX:+LargePageSizeInBytes 设置内存页的大小
```

10）使用非占用的垃圾收集器。

```
-XX:+UseConcMarkSweepGC老年代使用CMS收集器降低停顿。
```

### 说一下 JVM 调优的工具？

#### 命令工具

#####  jps（Java Process Status）

输出JVM中运行的进程状态信息(现在一般使用jconsole)

![img](https://image.hyly.net/i/2025/09/22/f2ee70ba3edc750323c940843a6f965f-0.webp)

##### jstack

查看java进程内**线程的堆栈**信息

```
jstack [option] <pid>  
```

java案例

```
package com.heima.jvm;

public class Application {

    public static void main(String[] args) throws InterruptedException {
        while (true){
            Thread.sleep(1000);
            System.out.println("哈哈哈");
        }
    }
}
```

使用jstack查看进行堆栈运行信息

![img](https://image.hyly.net/i/2025/09/22/b8156538932e520a434859d5c8e55baa-0.webp)

#####  jmap

用于生成堆转存快照

> jmap [options] pid  内存映像信息
> jmap -heap pid   显示Java堆的信息
> jmap -dump:format=b,file=heap.hprof pid
> 		format=b表示以hprof二进制格式转储Java堆的内存
> 		file= 用于指定快照dump文件的文件名。

例：显示了某一个java运行的堆信息

```
C:\Users\yuhon>jmap -heap 53280
Attaching to process ID 53280, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.321-b07

using thread-local object allocation.
Parallel GC with 8 thread(s)   //并行的垃圾回收器

Heap Configuration:  //堆配置
   MinHeapFreeRatio         = 0   //空闲堆空间的最小百分比
   MaxHeapFreeRatio         = 100  //空闲堆空间的最大百分比
   MaxHeapSize              = 8524922880 (8130.0MB) //堆空间允许的最大值
   NewSize                  = 178257920 (170.0MB) //新生代堆空间的默认值
   MaxNewSize               = 2841640960 (2710.0MB) //新生代堆空间允许的最大值
   OldSize                  = 356515840 (340.0MB) //老年代堆空间的默认值
   NewRatio                 = 2 //新生代与老年代的堆空间比值，表示新生代：老年代=1：2
   SurvivorRatio            = 8 //两个Survivor区和Eden区的堆空间比值为8,表示S0:S1:Eden=1:1:8
   MetaspaceSize            = 21807104 (20.796875MB) //元空间的默认值
   CompressedClassSpaceSize = 1073741824 (1024.0MB) //压缩类使用空间大小
   MaxMetaspaceSize         = 17592186044415 MB //元空间允许的最大值
   G1HeapRegionSize         = 0 (0.0MB)//在使用 G1 垃圾回收算法时，JVM 会将 Heap 空间分隔为若干个 Region，该参数用来指定每个 Region 空间的大小。

Heap Usage:
PS Young Generation
Eden Space: //Eden使用情况
   capacity = 134217728 (128.0MB)
   used     = 10737496 (10.240074157714844MB)
   free     = 123480232 (117.75992584228516MB)
   8.000057935714722% used
From Space: //Survivor-From 使用情况
   capacity = 22020096 (21.0MB)
   used     = 0 (0.0MB)
   free     = 22020096 (21.0MB)
   0.0% used
To Space: //Survivor-To 使用情况
   capacity = 22020096 (21.0MB)
   used     = 0 (0.0MB)
   free     = 22020096 (21.0MB)
   0.0% used
PS Old Generation  //老年代 使用情况
   capacity = 356515840 (340.0MB)
   used     = 0 (0.0MB)
   free     = 356515840 (340.0MB)
   0.0% used

3185 interned Strings occupying 261264 bytes.
```

#####  jhat

用于分析jmap生成的堆转存快照（一般不推荐使用，而是使用Ecplise Memory Analyzer）

#####   jstat

是JVM统计监测工具。可以用来显示垃圾回收信息、类加载信息、新生代统计信息等。

**常见参数**：

①总结垃圾回收统计

```
jstat -gcutil pid
```

![img](https://image.hyly.net/i/2025/09/22/7c3a571521d3477ddc9564f310d0cb93-0.webp)

<figure class='table-figure'><table>
<thead>
<tr><th><strong>字段</strong></th><th><strong>含义</strong></th></tr></thead>
<tbody><tr><td>S0</td><td>幸存1区当前使用比例</td></tr><tr><td>S1</td><td>幸存2区当前使用比例</td></tr><tr><td>E</td><td>伊甸园区使用比例</td></tr><tr><td>O</td><td>老年代使用比例</td></tr><tr><td>M</td><td>元数据区使用比例</td></tr><tr><td>CCS</td><td>压缩使用比例</td></tr><tr><td>YGC</td><td>年轻代垃圾回收次数</td></tr><tr><td>YGCT</td><td>年轻代垃圾回收消耗时间</td></tr><tr><td>FGC</td><td>老年代垃圾回收次数</td></tr><tr><td>FGCT</td><td>老年代垃圾回收消耗时间</td></tr><tr><td>GCT</td><td>垃圾回收消耗总时间</td></tr></tbody>
</table></figure>

②垃圾回收统计

```
jstat -gc pid
```

![img](https://image.hyly.net/i/2025/09/22/1fafb4edf5599b7097346248f56c2263-0.webp)

####  可视化工具

#####  jconsole

用于对jvm的内存，线程，类 的监控，是一个基于 jmx 的 GUI 性能监控工具

打开方式：java 安装目录 bin目录下 直接启动 jconsole.exe 就行

![img](https://image.hyly.net/i/2025/09/22/c470c0ae43c1e0f2753cd7ef6ec22223-0.webp)

可以内存、线程、类等信息

![img](https://image.hyly.net/i/2025/09/22/a87bead5aef0e2c28119e454e837fc4c-0.webp)

#####  VisualVM：故障处理工具

能够监控线程，内存情况，查看方法的CPU时间和内存中的对 象，已被GC的对象，反向查看分配的堆栈

打开方式：java 安装目录 bin目录下 直接启动 jvisualvm.exe就行

![img](https://image.hyly.net/i/2025/09/22/9503ee1c31d74dc5c65d2cde9cb64d5d-0.webp)

监控程序运行情况

![img](https://image.hyly.net/i/2025/09/22/e2600a0fff2d4bcceba67c3be5d393af-0.webp)

查看运行中的dump

![img](https://image.hyly.net/i/2025/09/22/87fb2c934d9332a3b7890e6932476774-0.webp)

查看堆中的信息

![img](https://image.hyly.net/i/2025/09/22/0e5046cfa1f22dd570380ad13c760de7-0.webp)

###  java内存泄露的排查思路？

原因：

如果线程请求分配的栈容量超过java虚拟机栈允许的最大容量的时候，java虚拟机将抛出一个StackOverFlowError异常

如果java虚拟机栈可以动态拓展，并且扩展的动作已经尝试过，但是目前无法申请到足够的内存去完成拓展，或者在建立新线程的时候没有足够的内存去创建对应的虚拟机栈，那java虚拟机将会抛出一个OutOfMemoryError异常

如果一次加载的类太多，元空间内存不足，则会报OutOfMemoryError: Metaspace

![img](https://image.hyly.net/i/2025/09/22/8e0334a6fd6e39f8d65f01f396e097ff-0.webp)

1、通过jmap指定打印他的内存快照 dump

> 有的情况是内存溢出之后程序则会直接中断，而jmap只能打印在运行中的程序，所以建议通过参数的方式的生成dump文件，配置如下：
> -XX:+HeapDumpOnOutOfMemoryError
> -XX:HeapDumpPath=/home/app/dumps/      指定生成后文件的保存目录

2、通过工具， VisualVM（Ecplise MAT）去分析 dump文件

VisualVM可以加载离线的dump文件，如下图

文件-->装入--->选择dump文件即可查看堆快照信息

> 如果是linux系统中的程序，则需要把dump文件下载到本地（windows环境）下，打开VisualVM工具分析。VisualVM目前只支持在windows环境下运行可视化

![img](https://image.hyly.net/i/2025/09/22/de355d8871217373c0df70e0ea7540e4-0.webp)

3、通过查看堆信息的情况，可以大概定位内存溢出是哪行代码出了问题

![img](https://image.hyly.net/i/2025/09/22/391d1ee118bcb22a77a4aaaddef74cb1-0.webp)

4、找到对应的代码，通过阅读上下文的情况，进行修复即可

###  CPU飙高排查方案与思路？

1.使用top命令查看占用cpu的情况

![img](https://image.hyly.net/i/2025/09/22/5c95a6e6e8dabc110661342231ed0160-0.webp)

2.通过top命令查看后，可以查看是哪一个进程占用cpu较高，上图所示的进程为：30978

3.查看当前线程中的进程信息

```
ps H -eo pid,tid,%cpu | grep 40940
```

> pid  进行id
> tid   进程中的线程id
> %  cpu使用率

![img](https://image.hyly.net/i/2025/09/22/4ed4f442e42c022da6baed3cbb12ec01-0.webp)

4.通过上图分析，在进程30978中的线程30979占用cpu较高

> 注意：上述的线程id是一个十进制，我们需要把这个线程id转换为16进制才行，因为通常在日志中展示的都是16进制的线程id名称
> 转换方式：
> 在linux中执行命令
> `printf "%x\n" 30979`

![img](https://image.hyly.net/i/2025/09/22/c066aad8db601c97899f949d7841908d-0.webp)

5.可以根据线程 id 找到有问题的线程，进一步定位到问题代码的源码行号

执行命令

```
jstack 30978   此处是进程id
```

![img](https://image.hyly.net/i/2025/09/22/1d2a414d7b8d368ff4ecedd3aa1f841f-0.webp)

##  面试现场

###  JVM组成

> **面试官**：JVM由那些部分组成，运行流程是什么？
> **候选人:**
> 嗯，好的~~
> 在JVM中共有四大部分，分别是ClassLoader（类加载器）、Runtime Data Area（运行时数据区，内存分区）、Execution Engine（执行引擎）、Native Method Library（本地库接口）
> 它们的运行流程是：
> 第一，类加载器（ClassLoader）把Java代码转换为字节码
> 第二，运行时数据区（Runtime Data Area）把字节码加载到内存中，而字节码文件只是JVM的一套指令集规范，并不能直接交给底层系统去执行，而是有执行引擎运行
> 第三，执行引擎（Execution Engine）将字节码翻译为底层系统指令，再交由CPU执行去执行，此时需要调用其他语言的本地库接口（Native Method Library）来实现整个程序的功能。
> **面试官**：好的，你能详细说一下 JVM 运行时数据区吗？
> **候选人:**
> 嗯，好~
> 运行时数据区包含了堆、方法区、栈、本地方法栈、程序计数器这几部分，每个功能作用不一样。
> 堆解决的是对象实例存储的问题，垃圾回收器管理的主要区域。
> 方法区可以认为是堆的一部分，用于存储已被虚拟机加载的信息，常量、静态变量、即时编译器编译后的代码。
> 栈解决的是程序运行的问题，栈里面存的是栈帧，栈帧里面存的是局部变量表、操作数栈、动态链接、方法出口等信息。
> 本地方法栈与栈功能相同，本地方法栈执行的是本地方法，一个Java调用非Java代码的接口。
> 程序计数器（PC寄存器）程序计数器中存放的是当前线程所执行的字节码的行数。JVM工作时就是通过改变这个计数器的值来选取下一个需要执行的字节码指令。
> **面试官**：好的，你再详细介绍一下程序计数器的作用？
> **候选人:**
> 嗯，是这样~~
> java虚拟机对于多线程是通过线程轮流切换并且分配线程执行时间。在任何的一个时间点上，一个处理器只会处理执行一个线程，如果当前被执行的这个线程它所分配的执行时间用完了【挂起】。处理器会切换到另外的一个线程上来进行执行。并且这个线程的执行时间用完了，接着处理器就会又来执行被挂起的这个线程。这时候程序计数器就起到了关键作用，程序计数器在来回切换的线程中记录他上一次执行的行号，然后接着继续向下执行。
> **面试官**：你能给我详细的介绍Java堆吗?
> **候选人:**
> 好的~
> Java中的堆术语线程共享的区域。主要用来保存**对象实例，数组**等，当堆中没有内存空间可分配给实例，也无法再扩展时，则抛出OutOfMemoryError异常。
> 	在JAVA8中堆内会存在年轻代、老年代
> 	1）Young区被划分为三部分，Eden区和两个大小严格相同的Survivor区，其中，Survivor区间中，某一时刻只有其中一个是被使用的，另外一个留做垃圾收集时复制对象用。在Eden区变满的时候， GC就会将存活的对象移到空闲的Survivor区间中，根据JVM的策略，在经过几次垃圾收集后，任然存活于Survivor的对象将被移动到Tenured区间。
> 	2）Tenured区主要保存生命周期长的对象，一般是一些老的对象，当一些对象在Young复制转移一定的次数以后，对象就会被转移到Tenured区。
> **面试官**：能不能解释一下方法区？
> **候选人:**
> 好的~
> 与虚拟机栈类似。本地方法栈是为虚拟机**执行本地方法时提供服务的**。不需要进行GC。本地方法一般是由其他语言编写。
> **面试官**：你听过直接内存吗？
> **候选人:**
> 嗯~~
> 它又叫做**堆外内存**，**线程共享的区域**，在 Java 8 之前有个**永久代**的概念，实际上指的是 HotSpot 虚拟机上的永久代，它用永久代实现了 JVM 规范定义的方法区功能，**主要存储类的信息，常量，静态变量**，即时编译器编译后代码等，这部分由于是在堆中实现的，受 GC 的管理，不过由于永久代有 -XX:MaxPermSize 的上限，所以如果大量动态生成类（将类信息放入永久代），很容易造成 OOM，有人说可以把永久代设置得足够大，但很难确定一个合适的大小，受类数量，常量数量的多少影响很大。
> 	所以在 Java 8 中就把方法区的实现移到了本地内存中的元空间中，这样方法区就不受 JVM 的控制了,也就不会进行 GC，也因此提升了性能。
> **面试官**：什么是虚拟机栈
> **候选人:**
> 虚拟机栈是描述的是方法执行时的内存模型,是线程私有的，生命周期与线程相同,每个方法被执行的同时会创建**栈桢**。保存执行方法时的**局部变量、动态连接信息、方法返回地址信息**等等。方法开始执行的时候会进栈，方法执行完会出栈【相当于清空了数据】，所以这块区域**不需要进行 GC**。
> **面试官**：能说一下堆栈的区别是什么吗？
> **候选人:**
> 嗯，好的，有这几个区别
> 第一，栈内存一般会用来存储局部变量和方法调用，但堆内存是用来存储Java对象和数组的的。堆会GC垃圾回收，而栈不会。
> 第二、栈内存是线程私有的，而堆内存是线程共有的。
> 第三、两者异常错误不同，但如果栈内存或者堆内存不足都会抛出异常。
> 栈空间不足：java.lang.StackOverFlowError。
> 堆空间不足：java.lang.OutOfMemoryError。

###  类加载器

> **面试官**：什么是类加载器，类加载器有哪些?
> **候选人:**
> 嗯，是这样的
> JVM只会运行二进制文件，而类加载器（ClassLoader）的主要作用就是将**字节码文件加载到JVM中**，从而让Java程序能够启动起来。
> 常见的类加载器有4个
> 第一个是启动类加载器(BootStrap ClassLoader)：其是由C++编写实现。用于加载JAVA_HOME/jre/lib目录下的类库。
> 第二个是扩展类加载器(ExtClassLoader)：该类是ClassLoader的子类，主要加载JAVA_HOME/jre/lib/ext目录中的类库。
> 第三个是应用类加载器(AppClassLoader)：该类是ClassLoader的子类，主要用于加载classPath下的类，也就是加载开发者自己编写的Java类。
> 第四个是自定义类加载器：开发者自定义类继承ClassLoader，实现自定义类加载规则。
> **面试官**：说一下类装载的执行过程？
> **候选人:**
> 嗯，这个过程还是挺多的。
> 类从加载到虚拟机中开始，直到卸载为止，它的整个生命周期包括了：加载、验证、准备、解析、初始化、使用和卸载这7个阶段。其中，验证、准备和解析这三个部分统称为连接（linking）
> 1.加载：查找和导入class文件
> 2.验证：保证加载类的准确性
> 3.准备：为类变量分配内存并设置类变量初始值
> 4.解析：把类中的符号引用转换为直接引用
> 5.初始化：对类的静态变量，静态代码块执行初始化操作
> 6.使用：JVM 开始从入口方法开始执行用户的程序代码
> 7.卸载：当用户程序代码执行完毕后，JVM 便开始销毁创建的 Class 对象，最后负责运行的 JVM 也退出内存
> **面试官**：什么是双亲委派模型？
> **候选人:**
> 嗯，它是是这样的。
> 如果一个类加载器收到了类加载的请求，它首先不会自己尝试加载这个类，而是把这请求委派给父类加载器去完成，每一个层次的类加载器都是如此，因此所有的加载请求最终都应该传说到顶层的启动类加载器中，只有当父类加载器返回自己无法完成这个加载请求（它的搜索返回中没有找到所需的类）时，子类加载器才会尝试自己去加载
> **面试官**：JVM为什么采用双亲委派机制
> **候选人:**
> 主要有两个原因。
> 第一、通过双亲委派机制可以避免某一个类被重复加载，当父类已经加载后则无需重复加载，保证唯一性。
> 第二、为了安全，保证类库API不会被修改

###  垃圾回收

> **面试官**：简述Java垃圾回收机制？（GC是什么？为什么要GC）
> **候选人:**
> 嗯，是这样~~
> 为了让程序员更专注于代码的实现，而不用过多的考虑内存释放的问题，所以，在Java语言中，有了自动的垃圾回收机制，也就是我们熟悉的GC(Garbage Collection)。
> 有了垃圾回收机制后，程序员只需要关心内存的申请即可，内存的释放由系统自动识别完成。
> 在进行垃圾回收时，不同的对象引用类型，GC会采用不同的回收时机
> **面试官**：强引用、软引用、弱引用、虚引用的区别？
> **候选人:**
> 嗯嗯~
> 强引用最为普通的引用方式，表示一个对象处于**有用且必须**的状态，如果一个对象具有强引用，则GC并不会回收它。即便堆中内存不足了，宁可出现OOM，也不会对其进行回收
> 软引用表示一个对象处于**有用且非必须**状态，如果一个对象处于软引用，在内存空间足够的情况下，GC机制并不会回收它，而在内存空间不足时，则会在OOM异常出现之间对其进行回收。但值得注意的是，因为GC线程优先级较低，软引用并不会立即被回收。
> 弱引用表示一个对象处于**可能有用且非必须**的状态。在GC线程扫描内存区域时，一旦发现弱引用，就会回收到弱引用相关联的对象。对于弱引用的回收，无关内存区域是否足够，一旦发现则会被回收。同样的，因为GC线程优先级较低，所以弱引用也并不是会被立刻回收。
> 虚引用表示一个对象处于**无用**的状态。在任何时候都有可能被垃圾回收。虚引用的使用必须和引用队列Reference Queue联合使用
> **面试官**：对象什么时候可以被垃圾器回收
> **候选人:**
> 思考一会~~
> 如果一个或多个对象没有任何的引用指向它了，那么这个对象现在就是垃圾，如果定位了垃圾，则有可能会被垃圾回收器回收。
> 如果要定位什么是垃圾，有两种方式来确定，第一个是引用计数法，第二个是可达性分析算法
> 通常都使用可达性分析算法来确定是不是垃圾
> **面试官**： JVM 垃圾回收算法有哪些？
> **候选人:**
> 我记得一共有四种，分别是标记清除算法、复制算法、标记整理算法、分代回收
> **面试官**： 你能详细聊一下分代回收吗？
> **候选人:**
> 关于分代回收是这样的
> 在java8时，堆被分为了两份：新生代和老年代，它们默认空间占用比例是1:2
> 对于新生代，内部又被分为了三个区域。Eden区，S0区，S1区默认空间占用比例是8:1:1
> 具体的工作机制是有些情况：
> 1）当创建一个对象的时候，那么这个对象会被分配在新生代的Eden区。当Eden区要满了时候，触发YoungGC。
> 2）当进行YoungGC后，此时在Eden区存活的对象被移动到S0区，并且**当前对象的年龄会加1**，清空Eden区。
> 3）当再一次触发YoungGC的时候，会把Eden区中存活下来的对象和S0中的对象，移动到S1区中，这些对象的年龄会加1，清空Eden区和S0区。
> 4）当再一次触发YoungGC的时候，会把Eden区中存活下来的对象和S1中的对象，移动到S0区中，这些对象的年龄会加1，清空Eden区和S1区。
> 5）对象的年龄达到了某一个限定的值（**默认15岁**  ），那么这个对象就会进入到老年代中。
> 当然也有特殊情况，如果进入Eden区的是一个大对象，在触发YoungGC的时候，会直接存放到老年代
> 当老年代满了之后，**触发FullGC**。**FullGC同时回收新生代和老年代**，当前只会存在一个FullGC的线程进行执行，其他的线程全部会被挂起。  我们在程序中要尽量避免FullGC的出现。
> **面试官**：讲一下新生代、老年代、永久代的区别？
> **候选人:**
> 嗯！是这样的，简单说就是
> **新生代**主要用来存放新生的对象。
> **老年代**主要存放应用中生命周期长的内存对象。
> **永久代**指的是永久保存区域。主要存放Class和Meta（元数据）的信息。在Java8中，永久代已经被移除，取而代之的是一个称之为“元数据区”（**元空间**）的区域。元空间和永久代类似，不过元空间与永久代之间最大的区别在于：元空间并不在虚拟机中，而是使用本地内存。因此，默认情况下，元空间的大小仅受本地内存的限制。
> **面试官**：说一下 JVM 有哪些垃圾回收器？
> **候选人:**
> 在jvm中，实现了多种垃圾收集器，包括：串行垃圾收集器、并行垃圾收集器（JDK8默认）、CMS（并发）垃圾收集器、G1垃圾收集器（JDK9默认）
> **面试官**：Minor GC、Major GC、Full GC是什么
> **候选人:**
> 嗯，其实它们指的是不同代之间的垃圾回收
> Minor GC 发生在新生代的垃圾回收，暂停时间短
> Major GC 老年代区域的垃圾回收，老年代空间不足时，会先尝试触发Minor GC。Minor GC之后空间还不足，则会触发Major GC，Major GC速度比较慢，暂停时间长
> Full GC 新生代 + 老年代完整垃圾回收，暂停时间长，**应尽力避免**

### JVM实践（调优）

> **面试官**：JVM 调优的参数可以在哪里设置参数值？
> **候选人:**
> 我们当时的项目是springboot项目，可以在项目启动的时候，java -jar中加入参数就行了
> **面试官**：用的 JVM 调优的参数都有哪些？
> **候选人:**
> 嗯，这些参数是比较多的
> 我记得当时我们设置过堆的大小，像-Xms和-Xmx
> 还有就是可以设置年轻代中Eden区和两个Survivor区的大小比例
> 还有就是可以设置使用哪种垃圾回收器等等。具体的指令还真记不太清楚。
> **面试官**：嗯，好的，你们平时调试 JVM都用了哪些工具呢？
> **候选人:**
> 嗯，我们一般都是使用jdk自带的一些工具，比如
> jps 输出JVM中运行的进程状态信息
> jstack查看java进程内**线程的堆栈**信息。
> jmap 用于生成堆转存快照
> jstat用于JVM统计监测工具
> 还有一些可视化工具，像jconsole和VisualVM等
> **面试官**：假如项目中产生了java内存泄露，你说一下你的排查思路？
> **候选人:**
> 嗯，这个我在之前项目排查过
> 第一呢可以通过jmap指定打印他的内存快照 dump文件，不过有的情况打印不了，我们会设置vm参数让程序自动生成dump文件
> 第二，可以通过工具去分析 dump文件，jdk自带的VisualVM就可以分析
> 第三，通过查看堆信息的情况，可以大概定位内存溢出是哪行代码出了问题
> 第四，找到对应的代码，通过阅读上下文的情况，进行修复即可
> **面试官**：好的，那现在再来说一种情况，就是说服务器CPU持续飙高，你的排查方案与思路？
> **候选人:**
> 嗯，我思考一下~~
> 可以这么做~~
> 第一可以使用使用top命令查看占用cpu的情况
> 第二通过top命令查看后，可以查看是哪一个进程占用cpu较高，记录这个进程id
> 第三可以通过ps 查看当前进程中的线程信息，看看哪个线程的cpu占用较高
> 第四可以jstack命令打印进行的id，找到这个线程，就可以进一步定位问题代码的行号

**以下是自己收集的关于JVM的其它资料，可能会有重复，大家查漏补缺就好。**

## JDK、JRE和JVM是什么关系（JDK包含JRE，而JRE包含JVM）

JDK:JDK(Java Development Kit) 是整个JAVA的核心，包括了Java运行环境（Java Runtime Envirnment），一堆Java工具（javac/java/jdb等）和Java基础的类库（即Java API 包括rt.jar）。JDK是java开发工具包，基本上每个学java的人都会先在机器 上装一个JDK，那他都包含哪几部分呢？在目录下面有 六个文件夹、一个src类库源码压缩包、和其他几个声明文件。其中，真正在运行java时起作用的 是以下四个文件夹：bin、include、lib、 jre。有这样一个关系，JDK包含JRE，而JRE包 含JVM。

1. bin:最主要的是编译器(javac.exe)
2. include:java和JVM交互用的头文件
3. lib：类库
4. jre:java运行环境

JRE:JRE（Java Runtime Environment，Java运行环境），包含JVM标准实现及Java核心类库（jre里有运行.class的java.exe）。JRE是Java运行环境，并不是一个开发环境，所以没有包含任何开发工具（如编译器和调试器）

总的来说JDK是用于java程序的开发,而jre则是只能运行class而没有编译的功能

JVM:即java虚拟机, java运行时的环境。针对java用户，也就是拥有可运行的.class文件包（jar或者war）的用户。里面主要包含了jvm和java运行时基本类库（rt.jar）。rt.jar可以简单粗暴地理解为：它就是java源码编译成的jar包。Java虚拟机在执行字节码时，把字节码解释成具体平台上的机器指令执行。这就是Java的能够“一次编译，到处运行”的原因。

## JVM内存结构

![image-20220309162712856](https://image.hyly.net/i/2025/09/17/361335b5883a81cb9f4d2b68571156aa-0.webp)

### 程序计数器

程序计数器是一块较小的内存空间，可以看作是当前线程所执行的字节码的行号指示器。字节码解释器工作时通过改变这个计数器的值来选取下一条需要执行的字节码指令，分支、循环、跳转、异常处理、线程恢复等功能都需要依赖这个计数器来完。

java虚拟机的多线程是通过线程轮流切换并分配CPU的时间片的方式实现的，因此在任何时刻一个处理器（如果是多核处理器，则只是一个核）都只会处理一个线程，为了线程切换后能恢复到正确的执行位置，每条线程都需要有一个独立的程序计数器，各线程之间计数器互不影响，独立存储，因此这类内存区域为“线程私有”的内存。

程序计数器主要有两个作用：

1. 字节码解释器通过改变程序计数器来依次读取指令，从而实现代码的流程控制，如：顺序执行、选择、循环、异常处理。

2. 在多线程的情况下，程序计数器用于记录当前线程执行的位置，从而当线程被切换回来的时候能够知道该线程上次运行到哪儿了。

### 虚拟机栈

Java虚拟机栈也是线程私有的，它的生命周期和线程相同，描述的是 Java 方法执行的内存模型。Java虚拟机栈是由一个个栈帧组成，线程在执行一个方法时，便会向栈中放入一个栈帧，每个栈帧中都拥有局部变量表、操作数栈、动态链接、方法出口信息。局部变量表主要存放了编译器可知的各种基本数据类型（boolean、byte、char、short、int、float、long、double）和对象引用（reference类型，它不同于对象本身，可能是一个指向对象起始地址的引用指针，也可能是指向一个代表对象的句柄或其他与此对象相关的位置）。

### 本地方法栈

本地方法栈和虚拟机栈所发挥的作用非常相似，区别是：虚拟机栈为虚拟机执行 Java 方法 （也就是字节码）服务，而本地方法栈则为虚拟机使用到的 Native 方法服务。 

本地方法被执行的时候，在本地方法栈也会创建一个栈帧，用于存放该本地方法的局部变量表、操作数栈、动态链接、出口信息。方法执行完毕后相应的栈帧也会出栈并释放内存空间

### 方法区

方法区与 Java 堆一样，是各个线程共享的内存区域，它用于存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。虽然Java虚拟机规范把方法区描述为堆的一个逻辑部分，但是它却有一个别名叫做 Non-Heap（非堆），目的应该是与 Java 堆区分开来。

HotSpot 虚拟机中方法区也常被称为 “永久代”，本质上两者并不等价。仅仅是因为 HotSpot 虚拟机设计团队用永久代来实现方法区而已，这样 HotSpot 虚拟机的垃圾收集器就可以像管理 Java 堆一样管理这部分内存了。但是这并不是一个好主意，因为这样更容易遇到内存溢出问题。

相对而言，垃圾收集行为在这个区域是比较少出现的，但并非数据进入方法区后就“永久存在”了

### 堆

堆是Java 虚拟机所管理的内存中最大的一块，Java 堆是所有线程共享的一块内存区域，在虚拟机启动时创建。此内存区域的唯一目的就是存放对象实例，几乎所有的对象实例以及数组都在这里分配内存

Java 堆是垃圾收集器管理的主要区域，因此也被称作GC堆（Garbage Collected Heap）。从垃圾回收的角度，由于现在收集器基本都采用分代垃圾收集算法，所以Java堆还可以细分为：新生代和老年代：其中新生代又分为：Eden（伊甸）空间、Survivor From 、Survivor To 空间。进一步划分的目的是更好地回收内存，或者更快地分配内存。“分代回收”是基于这样一个事实：对象的生命周期不同，所以针对不同生命周期的对象可以采取不同的回收方式，以便提高回收效率。从内存分配的角度来看，线程共享的java堆中可能会划分出多个线程私有的分配缓冲区（Thread Local Allocation Buffer，TLAB）。

![img](https://image.hyly.net/i/2025/09/19/c7f10b588b7b75470c4eb9752c2aa8bc-0.webp)

如图所示，JVM内存主要由新生代、老年代、永久代构成。

① 新生代（Young Generation）：大多数对象在新生代中被创建，其中很多对象的生命周期很短。每次新生代的垃圾回收（又称Minor GC）后只有少量对象存活，所以选用复制算法，只需要少量的复制成本就可以完成回收。

新生代内又分三个区：一个Eden区，两个Survivor区（一般而言），大部分对象在Eden区中生成。当Eden区满时，还存活的对象将被复制到两个Survivor区（中的一个）。当这个Survivor区满时，此区的存活且不满足“晋升”条件的对象将被复制到另外一个Survivor区。对象每经历一次Minor GC，年龄加1，达到“晋升年龄阈值”后，被放到老年代，这个过程也称为“晋升”。显然，“晋升年龄阈值”的大小直接影响着对象在新生代中的停留时间，在Serial和ParNew GC两种回收器中，“晋升年龄阈值”通过参数MaxTenuringThreshold设定，默认值为15。

② 老年代（Old Generation）：在新生代中经历了N次垃圾回收后仍然存活的对象，就会被放到年老代，该区域中对象存活率高。老年代的垃圾回收（又称Major GC）通常使用“标记-清除”或“标记-整理”算法。整堆包括新生代和老年代的垃圾回收称为Full GC（HotSpot VM里，除了CMS之外，其它能收集老年代的GC都会同时收集整个GC堆，包括新生代）。

③ 永久代（Perm Generation）：主要存放元数据，例如Class、Method的元信息，与垃圾回收要回收的Java对象关系不大。相对于新生代和年老代来说，该区域的划分对垃圾回收影响比较小。

在 JDK 1.8中移除整个永久代，取而代之的是一个叫元空间（Metaspace）的区域（永久代使用的是JVM的堆内存空间，而元空间使用的是物理内存，直接受到本机的物理内存限制）。

## 类加载顺序

![image-20220309225822124](https://image.hyly.net/i/2025/09/19/514794b1543d913e19af3b3ecfe04a8e-0.webp)

## 为什么要调优

1. 是因为早期垃圾回收器GC的时候STW会造成JVM卡顿，如果JVM运行时间长那么卡顿时间会非常长。不利于高性能所以需要JVMGC调优。

## 什么叫垃圾

1. 没有引用指向的对象就叫垃圾

## 如何解决线上GC频繁的问题？

1. 查看监控（无日志不调优，项目上线要默认启动GC日志），以了解出现问题的时间点以及当前FGC的频率（可对比正常情况看频率是否正常）
2. 了解该时间点之前有没有程序上线、基础组件升级等情况。
3. 了解JVM的参数设置，包括：堆空间各个区域的大小设置，新生代和老年代分别采用了哪些垃圾收集器，然后分析JVM参数设置是否合理。最大堆最小堆要设置为一致，防止内存动荡。serial old单线程所以加大内存反而GC变慢。使用CMS算法加大内存升级硬件，反而使得STW变长，是因为CMS采用标记清除会产生碎片，然后使用serial old 去压缩碎片，serial old是单线程的所以会变慢。
4. 再对步骤1中列出的可能原因做排除法，其中元空间被打满、内存泄漏、代码显式调用gc方法比较容易排查。
5. 针对大对象或者长生命周期对象导致的FGC，可通过 jmap -histo 命令并结合dump堆内存文件作进一步分析，需要先定位到可疑对象。因为jmap -histo会立即导致STW所以一般不使用，而使用阿尔萨斯（Arthas）进行分析。
6. 通过可疑对象定位到具体代码再次分析，这时候要结合GC原理和JVM参数设置，弄清楚可疑对象是否满足了进入到老年代的条件才能下结论。

##  简述一下内存溢出的原因，如何排查线上问题？

内存溢出：一直往内存里放东西，内存满了还放就溢出了。

内存泄漏：有一块内存不知道被放了什么东西，而且永远不会用，少了一块内存用。

**内存溢出的原因：**

1. java.lang.OutOfMemoryError: ......java heap space..... 堆栈溢出，代码问题的可能性极大
2. java.lang.OutOfMemoryError: GC over head limit exceeded 系统处于高频的GC状态，而且回收的效果依然不佳的情况，就会开始报这个错误，这种情况一般是产生了很多不可以被释放的对象，有可能是引用使用不当导致，或申请大对象导致，但是java heap space的内存溢出有可能提前不会报这个错误，也就是可能内存就直接不够导致，而不是高频GC。
3. java.lang.OutOfMemoryError: PermGen space jdk1.7之前才会出现的问题 ，原因是系统的代码非常多或引用的第三方包非常多、或代码中使用了大量的常量、或通过intern注入常量、或者通过动态代码加载等方法，导致常量池的膨胀。
4. java.lang.OutOfMemoryError: Direct buffer memory 直接内存不足，因为jvm垃圾回收不会回收掉直接内存这部分的内存，所以可能原因是直接或间接使用了ByteBuffer中的allocateDirect方法的时候，而没有做clear。
5. java.lang.StackOverflowError - Xss设置的太小了。
6. java.lang.OutOfMemoryError: unable to create new native thread 堆外内存不足，无法为线程分配内存区域。
7. java.lang.OutOfMemoryError: request {} byte for {}out of swap 地址空间不够。

## 垃圾回收的算法

### 基本算法

#### Mark-Sweep（标记清除）

1. ![](https://image.hyly.net/i/2025/09/19/962914a5659ed0e03ce95226467a8a70-0.webp)
2. 优点：算法相对简单，存活对象比较多的情况下效率较高。
3. 缺点：两遍扫描，效率偏低，容易产生碎片。

#### Copying（拷贝）

1. ![](https://image.hyly.net/i/2025/09/19/65ae53b6822ee4451d2bb3451943cac2-0.webp)
2. 缺点：有一半空间用不上。

#### Mark-Compact（标记压缩）

1. ![](https://image.hyly.net/i/2025/09/19/b7ea799086676aa03a11dcc16a615944-0.webp)
2. 原理：先进行垃圾回收，清除指定内存区域的垃圾然后把零散的整理放到一块去。
3. 优点：不会产生碎片，方便对象分配，不会产生内存减半。
4. 缺点：扫描两次，需要移动对象，效率偏低效率太慢。

### 常用算法

1. ![image-20220225175214956](https://image.hyly.net/i/2025/09/19/1691cdabfffcccab8d3d2d3d89a534f5-0.webp)

新生代收集器（全部都是复制算法）：ParNew、Serial、Parallel Scavenge。

老年代收集器：CMS（标记清除）、Serial Old（标记整理）、Parallel Old（标记整理）

整堆收集器：G1（一个Region中是标记清除，2个Region之间是复制算法）

并行（Parallel）：多个垃圾收集线程并行工作，此时用户线程处于等待状态。

并发（Concurrent）：用户线程和垃圾收集线程同时执行。

吞吐量：运行用户代码时间／（运行用户代码时间＋垃圾回收时间）。

吞吐量优先：Parallel Scavenge+Parallel Old（多线程并行）

响应时间优先：cms+par new（并发回收垃圾）

#### ParNew、CMS配套使用

1. **ParNew**

   1. 新生代
   2. 主要与CMS配套使用

2. **CMS**

   1. 老年代
   2. 并发执行

   CMS(Concurrent Mark Sweep)收集器是一种以获取最短回收停顿时间为目标的收集器。目前很大一部分的Java应用集中在互联网网站或者基于浏览器的B/S系统的服务端上，这类应用通常都会较为关注服务的响应速度，希望系统停顿时间尽可能短，以给用户带来良好的交互体验。CMS收集器就非常符合这类应用的需求(但是实际由于某些问题,很少有使用CMS作为主要垃圾回收器的)。

   CMS是基于“标记-清除”算法实现的，整个过程分为4个步骤：

   1. 初始标记（CMS initial mark）。
   2. 并发标记（CMS concurrent mark）。
   3. 重新标记（CMS remark）。
   4. 并发清除（CMS concurrent sweep）。

   注意：“标记”是指将存活的对象和要回收的对象都给标记出来，而“清除”是指清除掉将要回收的对象。

   其中初始标记、重新标记这两个步骤仍然需要“Stop The World”。初始标记仅仅只是标记一下GCRoots能直接关联到的对象，速度很快；

   并发标记阶段就是从GC Roots的直接关联对象开始遍历整个对象图的过程，这个过程耗时较长但是不需要停顿用户线程，可以与垃圾收集线程一起并发运行；

   重新标记阶段则是为了修正并发标记期间，因用户程序继续运作而导致标记产生变动的那一部分对象的标记记录，这个阶段的停顿时间通常会比初始标记阶段稍长一些，但也远比并发标记阶段的时间短；

   最后是并发清除阶段，清理删除掉标记阶段判断的已经死亡的对象，由于不需要移动存活对象，所以这个阶段也是可以与用户线程同时并发的。由于在整个过程中耗时最长的并发标记和并发清除阶段中，垃圾收集器线程都可以与用户线程一起工作，所以从总体上来说，CMS收集器的内存回收过程是与用户线程一起并发执行的。

   **CMS解决办法:增量更新**

   在应对漏标问题时，CMS使用了增量更新(Increment Update)方法来做：

   在一个未被标记的对象（白色对象）被重新引用后，**引用它的对象若为黑色则要变成灰色，在下次二次标记时让GC线程继续标记它的属性对象**。

   但是就算时这样，其仍然是存在漏标的问题：

   在一个灰色对象正在被一个GC线程回收时，当它已经被标记过的属性指向了一个白色对象（垃圾）

   而这个对象的属性对象本身还未全部标记结束，则为灰色不变

   **而这个GC线程在标记完最后一个属性后，认为已经将所有的属性标记结束了，将这个灰色对象标记为黑色，被重新引用的白色对象，无法被标记**

   

   **CMS另两个致命缺陷**

   ​		CMS采用了Mark-Sweep算法，最后会产生许多内存碎片，当到一定数量时，CMS无法清理这些碎片了，CMS会让Serial Old垃圾处理器来清理这些垃圾碎片，而Serial Old垃圾处理器是单线程操作进行清理垃圾的，效率很低。所以使用CMS就会出现一种情况，硬件升级了，却越来越卡顿，其原因就是因为进行Serial Old GC时，效率过低。解决方案：使用Mark-Sweep-Compact算法，减少垃圾碎片调优参数（配套使用）：-XX:+UseCMSCompactAtFullCollection 开启CMS的压缩 -XX:CMSFullGCsBeforeCompaction 默认为0，指经过多少次CMS FullGC才进行压缩

   当JVM认为内存不够，再使用CMS进行并发清理内存可能会发生OOM的问题，而不得不进行Serial Old GC，Serial Old是单线程垃圾回收，效率低解决方案：降低触发CMS GC的阈值，让浮动垃圾不那么容易占满老年代调优参数：-XX:CMSInitiatingOccupancyFraction 92% 可以降低这个值，让老年代占用率达到该值就进行CMS GC

   

   **CMS并不会full GC，而其他种类的都是full GC**。


#### Serial、Serial Old配套使用

1. Serial
   1. a stop-the-world,copying collector which uses a single GC thread
   2. 新生代
   3. 单线程
   4. 单CPU效率最高，虚拟机是Client模式的默认垃圾回收器。
   
2. SerialOld
   1. 老年代
   2. 单线程

#### Parallel Scavenge、Parallel Old配套使用（JDK1.8默认使用）

1. Parallel Scavenge
   1. a stop-the world,copying collector which uses multiple GC threads
   2. 新生代
   3. Serial的进阶版本，多线程。

2. Parallel Old
   1. 老年代
   2. Serial Old的进阶版本，多线程。

#### G1（逻辑分代，物理分区）

G1也是会短暂停顿的，虽然非常非常细微。

G1(Garbage First)物理内存不再分代，而是由一块一块的Region组成,但是逻辑分代仍然存在。G1不再坚持固定大小以及固定数量的分代区域划分，而是把连续的Java堆划分为多个大小相等的独立区域（Region），每一个Region都可以根据需要，扮演新生代的Eden空间、Survivor空间，或者老年代空间。收集器能够对扮演不同角色的Region采用不同的策略去处理，这样无论是新创建的对象还是已经存活了一段时间、熬过多次收集的旧对象都能获取很好的收集效果。

Region中还有一类特殊的Humongous区域，专门用来存储大对象。G1认为只要大小超过了一个Region容量一半的对象即可判定为大对象。每个Region的大小可以通过参数-XX：G1HeapRegionSize设定，取值范围为1MB～32MB，且应为2的N次幂。而对于那些超过了整个Region容量的超级大对象，将会被存放在N个连续的Humongous Region之中，G1的大多数行为都把Humongous Region作为老年代的一部分来进行看待，如图所示

![img](https://image.hyly.net/i/2025/09/19/69a3424b932863dcfd759083d63ef364-0.webp)

#### ZGC

ZGC 全称 Z Garbage Collector，是一款在 JDK11 新加入的具有实验性质的低延迟垃圾收集器，由 Oracle 公司研发。ZGC 与 Shenandoah 的目标高度相似，都希望在对吞吐量影响不大的前提下，实现任意堆内存大小下垃圾收集停顿时间限制在十毫秒以内，但两者的实现思路又有显著差异。ZGC 是一款基于 Region 内存布局的，不设分代的，使用读屏障、染色指针和内存多重映射等技术来实现可并发的标记 - 整理算法的，以低延迟为首要目标的一款垃圾收集器

#### Shenandoah

Shenandoah 作为一款第一个不由 Oracle 开发的 HotSpot 收集器，被官方明确拒绝在 OracleJDK12 中支持 Shenandoah 收集器，因此 Shenandoah 收集器只在 OpenJDK 才会包含。Shenandoah 收集器能实现在任何堆内存大小下都把垃圾停顿时间限制在十毫秒以内，这意味着相比 CMS 和 G1，Shenandoah 不仅要进行并发的垃圾标记，还要并发低进行对象清理后的整理

目标与ZGL一样，但因为不被Oracle接受，所以比较小众，而且能被ZGL代替。

#### Epsilon

1. 不干任何事的垃圾回收器，不执行任何垃圾回收工作。一旦java的堆被耗尽，jvm就直接关闭。设计的目的是提供一个完全消极的GC实现，分配有限的内存分配，最大限度降低消费内存占用量和内存吞吐时的延迟时间。一个好的实现是隔离代码变化，不影响其他GC，最小限度的改变其他的JVM代码。
2. 什么都不执行的GC非常适合用于差异性分析。no-op GC可以用于过滤掉GC诱发的新能损耗，比如GC线程的调度，GC屏障的消耗，GC周期的不合适触发，内存位置变化等。此外有些延迟者不是由于GC引起的，比如scheduling hiccups, compiler transition hiccups，所以去除GC引发的延迟有助于统计这些延迟。

### 三色标记算法

![image-20220227131210481](https://image.hyly.net/i/2025/09/19/bf1b65ce038742152725efd32cbd7cd6-0.webp)

三色标记法是一种垃圾回收法，它可以让JVM不发生或仅短时间发生STW(Stop The World)，从而达到清除JVM内存垃圾的目的。JVM中的**CMS、G1垃圾回收器**所使用垃圾回。

#### 三色标记算法思想

三色标记法将对象的颜色分为了黑、灰、白，三种颜色。

**白色**：该对象没有被标记过。（对象垃圾）

**灰色**：该对象已经被标记过了，但该对象下的属性没有全被标记完。（GC需要从此对象中去寻找垃圾）

**黑色**：该对象已经被标记过了，且该对象下的属性也全部都被标记过了。（程序所需要的对象）

![img](https://image.hyly.net/i/2025/09/19/6d7b92b473a5bdd7f6275ad902b69d25-0.webp)

#### 算法流程

从我们main方法的根对象（JVM中称为GC Root）开始沿着他们的对象向下查找，用黑灰白的规则，标记出所有跟GC Root相连接的对象,扫描一遍结束后，一般需要进行一次短暂的STW(Stop The World)，再次进行扫描，此时因为黑色对象的属性都也已经被标记过了，所以只需找出灰色对象并顺着继续往下标记（且因为大部分的标记工作已经在第一次并发的时候发生了，所以灰色对象数量会很少，标记时间也会短很多）, 此时程序继续执行，GC线程扫描所有的内存，找出扫描之后依旧被标记为白色的对象（垃圾）,清除。

#### 具体流程:

1. 首先创建三个集合：白、灰、黑。

2. 将所有对象放入白色集合中。

3. 然后从根节点开始遍历所有对象（注意这里并不**递归遍历**），把遍历到的对象从白色集合放入灰色集合。
4. 之后遍历灰色集合，将灰色对象引用的对象从白色集合放入灰色集合，之后将此灰色对象放入黑色集合
5. 重复 4 直到灰色中无任何对象
6. 通过write-barrier检测对象有变化，重复以上操作
7. 收集所有白色对象（垃圾）

#### 三色标记存在问题

1. 浮动垃圾：并发标记的过程中，若一个已经被标记成黑色或者灰色的对象，突然变成了垃圾，由于不会再对黑色标记过的对象重新扫描,所以不会被发现，那么这个对象不是白色的但是不会被清除，重新标记也不能从GC Root中去找到，所以成为了浮动垃圾，**浮动垃圾对系统的影响不大，留给下一次GC进行处理即可**。

2. 对象漏标问题（需要的对象被回收）：并发标记的过程中，一个业务线程将一个未被扫描过的白色对象断开引用成为垃圾（删除引用），同时黑色对象引用了该对象（增加引用）（这两部可以不分先后顺序）；因为黑色对象的含义为其属性都已经被标记过了，重新标记也不会从黑色对象中去找，导致该对象被程序所需要，却又要被GC回收，此问题会导致系统出现问题，而CMS与G1，两种回收器在使用三色标记法时，都采取了一些措施来应对这些问题，**CMS对增加引用环节进行处理（Increment Update），G1则对删除引用环节进行处理(SATB)。**

#### 产生的问题

1. ![image-20220225222830851](JVM调优.assets/image-20220225222830851.png)

## 什么叫做阻塞队列的有界和无界，实际中有用过吗？

在并发编程中，有时候需要使用线程安全的队列。如果要实现一个线程安全的队列有两种方式：一种是使用阻塞算法，另一种是使用非阻塞算法。

使用阻塞算法的队列可以用一个锁（入队和出队用同一把锁）或两个锁（入队和出队用不同的锁）等方式来实现。非阻塞的实现方式则可以使用自旋+CAS的方式来实现。

既然用锁或 synchronized 关键字可以实现原子操作，那么为什么还要用 CAS 呢，因为加锁或使用 synchronized 关键字带来的性能损耗较大，而用 CAS 可以实现乐观锁，它实际上是直接利用了 CPU 层面的指令，所以性能很高。CAS 是实现自旋锁的基础，CAS 利用 CPU 指令保证了操作的原子性，以达到锁的效果，至于自旋呢，看字面意思也很明白，自己旋转，翻译成人话就是循环，一般是用一个无限循环实现。这样一来，一个无限循环中，执行一个 CAS 操作，当操作成功，返回 true 时，循环结束；当返回 false 时，接着执行循环，继续尝试 CAS 操作，直到返回 true。

ArrayBlockingQueue和LinkedBlockingQueue最大的区别是LinkedBlockingQueue有两把锁（take锁，put锁）所以并发性能高。但前者能用CPU缓存行而后者没有。

**阻塞队列：**

1. ArrayBlockingQueue：一个由数组结构组成的有界阻塞队列，线程池，生产者消费者。
2. LinkedBlockingQueue：一个由链表结构组成的无界阻塞队列，线程池，生产者消费者。
3. PriorityBlockingQueue：一个支持优先级排序的无界阻塞队列，可以实现精确的定时任务。
4. DelayQueue：一个使用优先级队列实现的无界阻塞队列，可以实现精确的定时任务。
5. SynchronousQueue：一个不存储元素的阻塞队列，线程池。
6. LinkedTransferQueue：一个由链表结构组成的无界阻塞队列。
7. LinkedBlockingDeque：一个由链表结构组成的双向无界阻塞队列，可以用在“工作窃取”模式中。



 
