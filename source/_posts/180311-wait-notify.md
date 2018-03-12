---
title: wait-notify 生产者-消费者示例(继承Thread和实现Runnable)
date: Sun Mar 11 2018 23:46:38
tags:
	- Thread
---
**注意：**
通过继承Thread父类和通过实现Runnable接口实现线程操作，在线程的运行本质上没有什么区别，网上一些说 **“与继承Thread相比，使用Runnable实现多线程可以达到资源共享目的” 是错的。他们用来证明的例子也是错的。大多数例子都是用继承Thread类的多个线程去操作了多个不同的资源，而用实现Runnable接口的多个线程去操作了相同的资源，然后拿两者的运行结果作比较，从而得出了上面错误的结论。**，实际上以上两者都可以达到资源共享，也都可以资源不共享（而且都存在多种不同的实现方式），想要达到资源共享，只需把握住问题的核心 “想办法让多个线程操作的是同一个资源” 无论用哪种方式，只要遵循了这个核心原则，就都能达成资源共享的目的。

## 那 Thread 与 Runnable 有啥区别呢？
Thread本身继承自Runnable，是一个Runnable的具体实现，对Runnable进行了增强处理。所以Thread在功能上要比Runnable接口丰富。Thread提供了一系列 线程方法与属性跟踪，还可以跟踪线程堆栈及线程组与子线程的情况。
其次就是java本身的 “继承父类” 与 “实现接口” 之间的区别了。java只能单继承，但可以实现多个接口（java8开始，接口允许为方法提供“默认实现”了，也就是相当于可以实现多继承了）

<!-- more -->

## 什么时候用 Thread 什么时候用 Runnable
个人感觉这个没啥可纠结的，看具体情况吧！如果只单纯的用到了一个run方法，没有用到其它额外功能的方法就用实现Runnable的方式足够了，其它用继承Thread的方式吧！（其实都可以，看具体情况吧）。


**下面的两个例子中，队列`sharedQ`的操作都是synchronized同步的,类型可以换成 LinkedList 增、删速度较快，懒得再改了，备注一下。**
## 生产者-消费者示例，处理单个共享队列(实现接口方式)

```java

import java.util.Vector;


/**  
 * @Title: WaitNotifyTest.java
 * @Description: wait-notify 生产者-消费者示例，处理单个共享队列(实现接口方式)
 * @author Code0   
 * @date 2018年3月11日 下午8:26:12 
 */
public class WaitNotifyTest {

	public static void main(String[] args) {

		Vector sharedQ =new Vector();
		
		
		Thread p1=new Thread(new Producer(sharedQ),"p1");
		Thread p2=new Thread(new Producer(sharedQ),"p2");
		Thread c1=new Thread(new Consumer(sharedQ),"c1");
		p1.start();
		p2.start();
		c1.start();
		
		
	}
	
	static class Producer implements Runnable{
		private  Vector sharedQ;//共享队列
		private  int size=20;
		public Producer(Vector sharedQ){
			this.sharedQ=sharedQ;
		}

		@Override
		public void run() {
			
			while(true){
				try {
					Thread.sleep(1000l);//睡会儿，慢点生产。
				} catch (InterruptedException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				synchronized(sharedQ){
					//下面的wait用while做条件判断，可以在醒来后再做一次判断，避免“虚假唤醒”或睡眠期间条件被其它线程改变。
					//如果确定不存在 虚假唤醒 并能保证该线程唤醒后，睡前条件仍成立，则下面的while也可以改为if
					//查阅相关资料后发现，为稳妥期间推荐使用while进行判断。
					while(sharedQ.size()==size){
						try {
							//这句打印放到wait前面，因为wait执行后，会释放sharedQ的锁，可能会被消费者立马消耗掉，这句话出现的位置就有可能不对了。
							System.out.println("mmm-队列满了，队列上的生产者"+Thread.currentThread().getName()+"进入等待状态");
							sharedQ.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
					String prod=Thread.currentThread().getName()+"-"+System.currentTimeMillis();
					System.out.println(Thread.currentThread().getName()+"生产了产品："+prod);
					sharedQ.add(prod);
					sharedQ.notify();
					
				}
			}
		}
		
	}
	
	static class Consumer implements Runnable{

		private Vector sharedQ;//共享队列
		
		public Consumer(Vector sharedQ){
			this.sharedQ=sharedQ;
		}
		@Override
		public void run() {
			while(true){
				try {
					Thread.sleep(1000l);//睡会儿，慢点消耗。
				} catch (InterruptedException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				synchronized(sharedQ){
					while(sharedQ.size()==0){
						try {
							//这句打印放到wait前面，因为wait执行后，会释放sharedQ的锁，可能生产者立刻就会生产出新的，这句话出现的位置就有可能不对了。
							System.out.println("kkk-队列空了，队列上的消费者"+Thread.currentThread().getName()+"进入等待状态");
							sharedQ.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
					System.out.println(Thread.currentThread().getName()+"移除了产品： "+sharedQ.remove(0));//移除目前共享列表顶端（即最早生产的）数据
					sharedQ.notifyAll();//每当移除一个产品就唤醒sharedQ队列上其它的线程。以便生产新的产品。
					System.out.println("当前队列索引0对应产品： "+(sharedQ.size()>0 ? sharedQ.get(0):"null"));
					System.out.println("=========================");
				}
			}
			
		}
		
	}
	


}


```
## 生产者-消费者示例，处理多个共享队列(继承父类方式)

```java

import java.util.Vector;


/**  
 * @Title: WaitNotifyTest2.java
 * @Description: wait-notify 生产者-消费者示例，处理多个共享队列(继承父类方式)
 * @author Code0   
 * @date 2018年3月12日 上午10:11:52 
 */
public class WaitNotifyTest2 {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		//第一个产品队列
		SharedQ sharedQ=new SharedQ("队列1");
		int maxSize=50;
		
		//第二个产品队列
		SharedQ sharedQ2=new SharedQ("队列2");
		int maxSize2=20;
		
		//第一组线程
		Thread producer1g1=new Producer(sharedQ, maxSize,"1组的producer1");
		Thread consumer1g1=new Consumer(sharedQ,"1组的consumer1");
		Thread consumer1g2=new Consumer(sharedQ,"1组的consumer2");
		producer1g1.start();
		consumer1g1.start();
		consumer1g2.start();
		//另一组线程
		Thread producer2g1=new Producer(sharedQ2, maxSize2,"2组的producer1");
		Thread producer2g2=new Producer(sharedQ2, maxSize2,"2组的producer2");
		Thread consumer2g1=new Consumer(sharedQ2,"2组的consumer1");
		producer2g1.start();
		producer2g2.start();
		consumer2g1.start();
	}

	public static class SharedQ<E> extends Vector<E>{
		private String name;
		public SharedQ(String name){
			this.name=name;
		}
		
		public String getName(){
			return this.name;
		}
	}
	
	public static class Producer extends Thread{

		private SharedQ sharedQ;
		private int maxSize;
		
		public  Producer (SharedQ sharedQ,int maxSize,String name){
			this.sharedQ=sharedQ;
			this.maxSize=maxSize;
			this.setName(name);
		}
		
		@Override
		public void run() {
			while(true){
				try {
					Thread.sleep(1000l);
				} catch (InterruptedException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
				synchronized(sharedQ){
					while(sharedQ.size()>=maxSize){
						try {
							System.out.println(sharedQ.getName()+"队列已满,生产者"+Thread.currentThread().getName()+"进入等待");
							sharedQ.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						
					}
					String prod=Thread.currentThread().getName()+"-"+System.currentTimeMillis();
					System.out.println("生产者- "+Thread.currentThread().getName()+"生产了："+prod);
					sharedQ.add(prod);
					sharedQ.notifyAll();
					
				}
			}
		}
		
	}
	
	public static class Consumer extends Thread{

		private SharedQ sharedQ;
		public Consumer(SharedQ sharedQ,String name){
			this.sharedQ=sharedQ;
			this.setName(name);
		}
		@Override
		public void run() {
			while(true){
				try {
					Thread.sleep(1000l);
				} catch (InterruptedException e1) {
					e1.printStackTrace();
				}
				synchronized(sharedQ){
					while(sharedQ.size()==0){
						try {
							System.out.println(sharedQ.getName()+"产品队列空了，消费者："+Thread.currentThread().getName()+"进入等待");
							sharedQ.wait();
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
					System.out.println("消费者："+Thread.currentThread().getName()+"消耗了："+sharedQ.remove(0));
					sharedQ.notifyAll();
				}
			}
			
		}
		
	}
}

```
暂时就这些，后面没有了！(=^ ^=)



