---
title: 【摘】Hibernate的saveOrUpdate方法
date: Thu Feb 08 2018 15:35:43
tags:
	- Hibernate
---

在Hibernate中，最核心的概念就是对PO的状态管理。一个PO有三种状态： 

1、未被持久化的VO 
此时就是一个内存对象VO，由JVM管理生命周期 

2、已被持久化的PO，并且在Session生命周期内 
此时映射数据库数据，由数据库管理生命周期 

3、曾被持久化过，但现在和Session已经detached了，以VO的身份在运行 
这种和Session已经detached的PO还能够进入另一个Session，继续进行PO状态管理，此时它就成为PO的第二种状态了。**这种PO实际上是跨了Session进行了状态维护的。 **

在传统的JDO1.x中，PO只有前面两种状态，一个PO一旦脱离PM，就丧失了状态了，不再和数据库数据关联，成为一个纯粹的内存VO，它即使进入一个新的PM，也不能恢复它的状态了。 

Hibernate强的地方就在于，一个PO脱离Session之后，还能保持状态，再进入一个新的Session之后，就恢复状态管理的能力，但此时状态管理需要使用session.update或者session.saveOrUpdate，这就是Hibernate Reference中提到的“requires a slightly different programming model ” 

现在正式进入本话题： 
<!-- more -->
**简单的来说，update和saveOrUpdate是用来对跨Session的PO进行状态管理的。 **

假设你的PO不需要跨Session的话，那么就不需要用到，例如你打开一个Session，对PO进行操作，然后关闭，之后这个PO你也不会再用到了，那么就不需要用update。 

因此，我们来看看例子： 

``` java
  Foo foo=sess.load(Foo.class,id);
  foo.setXXX(xxx);
  sess.flush();
  sess.commit();
```
PO对象foo的操作都在一个Session生命周期内完成，因此不需要显式的进行sess.update(foo)这样的操作。Hibernate会自动监测到foo对象已经被修改过，因此就向数据库发送一个update的sql。当然如果你非要加上sess.update(foo)也不会错，只不过这样做没有任何必要。 

而跨Session的意思就是说这个PO对象在Session关闭之后，你还把它当做一个VO来用，后来你在Session外面又修改了它的属性，然后你又想打开一个Session，把VO的属性修改保存到数据库里面，那么你就需要用update了。 


``` java
  // in the first session   
  Cat cat = (Cat); firstSession.load(Cat.class, catId);   
  Cat potentialMate = new Cat();   
  firstSession.save(potentialMate);   

  // in a higher tier of the application   
  cat.setMate(potentialMate);   

  // later, in a new session   
  secondSession.update(cat);  // update cat   
  secondSession.update(mate); // update mate  
```
cat和mate对象是在第一个session中取得的，在第一个session关闭之后，他们就成了PO的第三种状态，和Session已经detached的PO，此时他们的状态信息仍然被保留下来了。当他们进入第二个session之后，立刻就可以进行状态的更新。但是由于对cat的修改操作：cat.setMate(potentialMate); 是在Session外面进行的，Hibernate不可能知道cat对象已经被改过了，第二个Session并不知道这种修改，因此一定要显式的调用secondSession.update(cat); 通知Hibernate，cat对象已经修改了，你必须发送update的sql了。 

所以update的作用就在于此，它只会被用于当一个PO对象跨Session进行状态同步的时候才需要写。而一个PO对象当它不需要跨Session进行状态管理的时候，是不需要写update的。 

再谈谈saveOrUpdate的用场： 

saveOrUpdate和update的区别就在于在跨Session的PO状态管理中，Hibernate对PO采取何种策略。 

例如当你写一个DAOImpl的时候，让cat对象增加一个mate，如下定义： 

``` java
public void addMate(Cat cat, Mate mate); {  
	Session session = ...;  
	Transacton tx = ...;  
	session.update(cat);  
	cat.addMate(mate);  
	tx.commit();  
	session.close();  
};  
```
显然你是需要把Hibernate的操作封装在DAO里面的，让业务层的程序员和Web层的程序员不需要了解Hibernate，直接对DAO进行调用。 

此时问题就来了：上面的代码运行正确有一个必要的前提，那就是方法调用参数cat对象必须是一个已经被持久化过的PO，也就是来说，它应该首先从数据库查询出来，然后才能这样用。但是业务层的程序员显然不知道这种内部的玄妙，如果他的业务是现在增加一个cat，然后再增加它的mate，他显然会这样调用，new一个cat对象出来，然后就addMate： 

``` java
  Cat cat = new Cat();  
  cat.setXXX();  
  daoimpl.addMate(cat,mate);  
```
但是请注意看，这个cat对象只是一个VO，它没有被持久化过，它还不是PO，它没有资格调用addMate方法，因此调用addMate方法不会真正往数据库里面发送update的sql，这个cat对象必须先被save到数据库，在真正成为一个PO之后，才具备addMate的资格。 

你必须这样来操作： 

``` java
  Cat cat = new Cat();  
  cat.setXXX();  
  daoimpl.addCat(cat);  
  daoimpl.addMate(cat, mate);  
```
先持久化cat，然后才能对cat进行其他的持久化操作。因此要求业务层的程序员必须清楚cat对象处于何种状态，到底是第一种，还是第三种。如果是第一种，就要先save，再addMate；如果是第三种，就直接addMate。 

但是最致命的是，如果整个软件分层很多，业务层的程序员他拿到这个cat对象也可能是上层Web应用层传递过来的cat，他自己也不知道这个cat究竟是VO，没有被持久化过，还是已经被持久化过，那么他根本就没有办法写程序了。 

所以这样的DAOImpl显然是有问题的，它会对业务层的程序员造成很多编程上的陷阱，业务层的程序员必须深刻的了解他调用的每个DAO对PO对象进行了何种状态管理，必须深刻的了解他的PO对象在任何时候处于什么确切的状态，才能保证编程的正确性，显然这是做不到的，但是有了saveOrUpdate，这些问题就迎刃而解了。 

现在你需要修改addMate方法： 

``` java
  public void addMate(Cat cat, Mate mate) {  
	  Session session = ...;  
	  Transacton tx = ...;  
	  session.saveOrUpdate(cat);
	  cat.addMate(mate);
	  tx.commit();
	  session.close();
  };  
```
如上，如果业务层的程序员传进来的是一个已经持久化过的PO对象，那么Hibernate会更新cat对象(假设业务层的程序员在Session外面修改过cat的属性)，如果传进来的是一个新new出来的对象，那么向数据库save这个PO对象。 

BTW: Hibernate此时究竟采取更新cat对象，还是save cat对象，取决于unsave-value的设定。 

这样，业务层的程序员就不必再操心PO的状态问题了，对于他们来说，不管cat是new出来的对象，只是一个VO也好；还是从数据库查询出来的的PO对象也好，全部都是直接addMate就OK了： 

``` java
  daoimple.addMate(cat, mate);  
```
这便是saveOrUpdate的作用。

摘自：http://www.iteye.com/topic/2632




