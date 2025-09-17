---
category: [Java技术栈]
tag: [java,面试]
postType: post
status: publish
---

## JDK1.8新特性

### Lambda表达式

**Lambda表达式的语法:**

基本语法: **(parameters) -> expression** 或 **(parameters) ->{ statements; }**

```java
// 1. 不需要参数,返回值为 5  

() -> 5  

// 2. 接收一个参数(数字类型),返回其2倍的值  

x -> 2 * x  

// 3. 接受2个参数(数字),并返回他们的差值  

(x, y) -> x – y  

// 4. 接收2个int型整数,返回他们的和  

(int x, int y) -> x + y  

// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  

(String s) -> System.out.print(s) 
```

### 函数式接口，函数式编程

函数式接口在Java中是指：有且仅有一个抽象方法的接口。

函数式接口，即适用于函数式编程场景的接口。而Java中的函数式编程体现就是Lambda，所以函数式接口就是可以适用于Lambda使用的接口。只有确保接口中有且仅有一个抽象方法，Java中的Lambda才能顺利地进行推导。

在兼顾面向对象特性的基础上，Java语言通过Lambda表达式与方法引用等，为开发者打开了函数式编程的大门。

### 方法引用和构造器调用

### Stream API

Java 8 API添加了一个新的抽象称为流Stream，可以让你以一种声明的方式处理数据。

这种风格将要处理的元素集合看作一种流， 流在管道中传输， 并且可以在管道的节点上进行处理， 比如筛选，排序，聚合等操作。元素流在管道中经过中间操作（intermediate operation）的处理，最后由最终操作(terminal operation)得到前面处理的结果。Java中的Stream并不会存储元素，而是按需计算。

数据源中流的来源 可以是集合，数组，I/O channel， 产生器generator 等。

### 接口中的默认方法和静态方法

### 新时间日期API

Java 8 在 java.time 包下提供了很多新的 API 。两个比较重要的 API：Local(本地) − 简化了日期时间的处理，没有时区的问题。Zoned(时区) − 通过制定的时区处理日期时间。

## equals()和==区别

equals只能用于引用类型。

==是运算符，可以用于基本数据类型和引用类型。

## hashmap线程安全的方式？

HashMap不是线程安全的,往往在写程序时需要通过一些方法来回避.其实JDK原生的提供了2种方法让HashMap支持线程安全.

方法一:通过Collections.synchronizedMap()返回一个新的Map,这个新的map就是线程安全的. 这个要求大家习惯基于接口编程,因为返回的并不是HashMap,而是一个Map的实现.

方法二:重新改写了HashMap,具体的可以查看java.util.concurrent.ConcurrentHashMap. 这个方法比方法一有了很大的改进.

下面对这2中实现方法从各个角度进行分析和比较.