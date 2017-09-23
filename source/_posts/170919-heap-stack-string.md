---
title: Java 堆、栈、方法区、几种常量池，String
date: 2017-09-19 15:32:41
tags:
	- heap、stack
	- 堆、栈
	- 常量池
	- String
---
**在JAVA中，数据的交互存在于以下地方：**

**寄存器（register）：** 位于CPU。
**栈（stack）：** 位于RAM。
**堆（heap）：** 位于RAM。
**方法区（PermGen）：** 位于RAM。
**非RAM存储：** 如硬盘等其它存储空间。

**就速度来说，从快到慢依次为： 寄存器 >栈 > 堆 > 其它。**


**JAVA的JVM的内存可分为3个区：`栈(stack)`、`堆(heap)`和`方法区(PermGen)`也叫永久代。**

<!-- more -->

## **寄存器（register）**
 这是最快的存储区，因为它位于不同于其他存储区的地方——处理器内部。但是寄存器的数量极其有限，所以寄存器由编译器根据需求进行分配。你不能直接控制，也不能在程序中感觉到寄存器存在的任何迹象。    

+ 最快的存储区, 由编译器根据需求进行分配,我们在程序中无法控制.

## **栈（stack）**
位于通用RAM中，但通过它的“栈指针”可以从处理器哪里获得支持。栈指针若向下移动，则分配新的内存；若向上移动，则释放那些 内存。这是一种快速有效的分配存储方法，仅次于寄存器。程序编译时，JAVA编译器必须知道存储在栈内所有数据的确切大小和生命周期，因为它必须生成相应的代码，以便上下移动栈指针。这一约束限制了程序的灵活性。    

+ **每个线程包含一个栈区**，栈中只存放**局部变量** <a href="#1">[1]</a> （包含基本类型和引用类型）。因为基本类型变量的变量值存的是字面[值]，是 基本类型【原始类型|值类型】,所以大小可知。如`int a = 3;` [^2] 这里的a是一个int类型的变量，指向`3`这个值。这些字面值的数据，由于大小可知，生存期可知【这些字面值固定定义在某个程序块里面，程序块退出后，字面值生存期就结束了】，出于追求速度的原因，就存在于栈中了，而对象由于大小不可知，所以栈中只存放了对象的引用。

+ 每个栈中的数据都是私有的，其他栈不能访问。

+ 栈中的**基本类型**变量值在该栈中是可以被共享的（共享性质有点`类似`字符串常量池，相同的值只会被创建一次）。如：
  ``` java
  int a=3;
  int b=3;
  ```
  编译器先处理`int a = 3；`首先它会在栈中创建一个 [变量] a，然后查找栈中是否有3这个值，如果没找到，就在栈中开辟一块空间将3这个值存放进来，然后将a指向3的地址。接着处理`int b = 3；`在创建完b的变量后，因为在栈中已经有3这个值，便将b直接指向3的地址。这样，就出现了a与b同时均指向3的情况。 特 别注意的是，这种基本类型的变量与引用类型的变量不同。假定两个引用类型的变量同时指向一个对象，如果一个变量修改了这个对象的内部状态，那么另一个变量也即刻反映出这个变化。相反，如果是两个基本类型的变量，修改其中一个的值，不会导致另一个指向此字面值的变量也跟着改变的情况。如上例，我们定义完a与 b的值后，再令a=4；那么，b不会等于4，还是等于3。在编译器内部，遇到a=4；时，它就会重新搜索栈中是否有4的字面值，如果没有，重新开辟地址存放4的值；如果已经有了，则直接将a指向这个地址。因此a值的改变不会影响到b的值。

## **堆（heap）**
一种通用性的内存池（也存在于RAM中），用于存放所有的JAVA对象，无论是成员变量，局部变量，还是类变量，它们指向的对象都存储在堆中。堆不同于栈的好处是：编译器不需要知道要从堆里分配多少存储区域，也不必知道存储的数据在堆里存活多长时间。因此，在堆里分配存储有很大的灵活性。当你需要创建一个对象的时候，只需要new写一行简单的代码，当执行这行代码时，会自动在堆里进行存储分配。当没有引用指向该对象时，垃圾回收机制会在恰当的时候将其回收掉。当然，为这种灵活性必须要付出相应的代价。用堆进行存储分配比用栈进行存储需要更多的时间。  

+  **jvm只有一个堆区(heap)，该区域被所有线程共享。** 存储的全部是对象实例。堆中不存放`基本类型`和`对象的引用`，只存放对象本身，[**几乎**]所有的 `对象实例` 和 `数组` 都在堆中分配。

## **方法区（PermGen）**
又叫永久代，跟堆一样，**被所有的线程共享**。它用于存储已经被虚拟机加载的`类信息`、`常量`、`静态变量`、`即时编译器编译后的代码`等数据。

+ JDK7之前 `运行时常量池` `字符串常量池` 还有很多[元数据](#关于java的元数据)都在方法区。

+ JDK7开始执行 PermGen移除（去永久代）计划，JDK8彻底移除PermGen。

+ JDK8彻底移除PermGen后，原本方法区中的这些对象被挪到GC堆外的一块叫做Metaspace的空间里做特殊管理，仍然间接的受GC管理。

## **非RAM存储**
如果数据完全存活于程序之外，那么它可以不受程序的任何控制，在程序没有运行时也可以存在。

# 几种常量池介绍
## **Class文件常量池**
存在于java文件编译完成后的class文件中, Class文件中除了有类的版本、字段、方法、接口等描述信息外，还有常量池(Constant Pool Table)，存放编译期生成的各种[字面量]和符号引用，这部分内容将在类加载后进入方法区的运行时常量池。

这里面主要存放两大类常量：

+ [字面量](Literal)：用双引号引起来的字符串 等。

+ 符号引用(Symbolic References)：属于编译原理方面的概念，包含三类常量：

	+ 类和接口的全限定名(Full Qualified Name)

	+ 字段的名称和描述符(Descriptor)

	+ 方法的名称和描述符

这些可以用[javap]命令进行查看。

## **运行时常量池**
方法区的一部分。类加载后由 class文件 衍生的产物，class文件常量池中的数据 在类加载后进入运行时常量池。

[类在加载时]的 解析（resolve）阶段 虚拟机会将常量池内的符号引用替换为直接引用，然后加载到运行时常量池中。但String类型的字面量有点特殊，Class文件常量池中 String字面量牵扯到两个常量池项的类型 `CONSTANT_Utf8` 和 `CONSTANT_String`  后者是String常量的类型，但它并不直接持有String常量的内容，而是只持有一个index，这个index所指定的另一个常量池项必须是一个CONSTANT_Utf8类型的常量，而CONSTANT_Utf8才真正指向持有字符串内容的对象。
CONSTANT_Utf8会在类加载的过程中就全部创建出来，而CONSTANT_String则是lazy resolve的，它会在**第一次引用该项的【地方】ldc指令被第一次执行到的时候**才会resolve。在尚未resolve的时候，[HotSpot VM][^3]把它的类型叫做JVM_CONSTANT_UnresolvedString，内容跟Class文件里一样只是一个index；等到resolve过后这个项的常量类型就会变成最终的JVM_CONSTANT_String，而内容则变成实际的那个字符串对象引用。
**总结：** 
CONSTANT_Utf8 会在类加载时 resolve 阶段进入运行时常量池。
CONSTANT_String 是lazy resolve 的，此时不会进入运行时常量池。

最直接的**体现**或者可以说：该字符串字面量对象的引用 进入了运行时常量池，但 该字符串字面量对象的引用 未进入字符串常量池。

**关于`CONSTANT_Utf8` 和 `CONSTANT_String` ：**
CONSTANT_Utf8：
+ CONSTANT_Utf8 -> Symbol* -> Symbol [^4] 	# CONSTANT_Utf8指向一个Symbol*，然后该Symbol*指向一个Symbol 。

	Symbol*的意思是 指向Symbol对象的指针。
	Symbol对象是一个固定长度的头部和一个可变长度、装有实际字符内容的尾部。

CONSTANT_String：
+ CONSTANT_String 在尚未resolve的时候，HotSpot VM把它的类型叫做JVM_CONSTANT_UnresolvedString。
+ 未 resolve 时的它只是持有一个指向 CONSTANT_Utf8 的指针【index】，而当 resolve 过后，则指向一个实际的Java对象的引用。
+ 一个 CONSTANT_String项  在第一次被执行ldc指令时会被 resolve， 此时会去到字符串常量池查找，字符串常量池支持以Symbol为key来查询是否已经有**内容匹配**的项存在与否，存在则直接返回匹配项的引用，不存在则创建出内容匹配的**java.lang.String对象**。没错，是创建和Symbol对象的内容相匹配的**java.lang.String对象**，然后返回该对象的引用，并将该引用驻留在 字符串常量池。


## **字符串常量池**
HotSpot VM里，记录interned string的一个全局表叫做StringTable，即：【[全局]字符串常量池】，它本质上就是个HashSet<String>，是HotSpot VM里用来实现字符串驻留功能的全局数据结构。这是个纯运行时的结构，而且是惰性（lazy）维护的。注意它只存储对java.lang.String实例的引用，而不存储String对象的内容。 注意，它只存了引用，根据这个引用可以得到具体的String对象。在驻留的过程中，StringTable::lookup() 函数是必经之路，是用来探测（probe）看某个字符串是否已经驻留在StringTable里了。

一般我们说一个字符串**进入了全局的字符串常量池**其实是说**在这个StringTable中保存了对它的引用**，反之，如果说没有在其中就是说StringTable中没有对它的引用。

JVM层面触发的字符串驻留（例如把Class文件里的CONSTANT_String类型常量转换为运行时对象，即：执行ldc指令的时候），以及Java代码主动触发的字符串驻留（java.lang.String.intern()），两种请求都由StringTable来处理，**就是说触发字符串进入字符串常量池有两种情况**。

1. JVM层面触发：
一个字符串字面量在第一次引用它的地方,ldc指令被第一次执行到的时候。
2. java代码主动触发：
一个String对象首次执行intern()方法，且当前字符串常量池没有与该对象**内容相同**的对象的引用驻留时。

以上两种情况都会在堆中创建String对象，并将引用驻留StringTable。


## **关于 String**
**new：**
当我们使用了new来构造字符串对象的时候，不管字符串常量池中有没有相同内容的对象的引用，新的字符串对象都会创建。

**intern：**
调用intern方法后，首先检查字符串常量池中是否有和该对象的**内容相同**的对象的引用，如果存在，则将这个引用返回，否则将该对象的引用加入并返回。

**摘抄的例子：**


``` java
class NewTest1{ 
	public static String ss1="static"; // 第一句 
	public static void main(String[] args) { 
		String s1=new String("he")+new String("llo"); //第二句 
		s1.intern(); // 第三句 
		String s2="hello"; //第四句 
		System.out.println(s1==s2);//第五句，输出是true。 
	} 
}
```
"static" "he" "llo" "hello"都会进入Class的常量池， 按照上面说的，类加载阶段由于resolve 阶段是lazy的，所以是不会创建实例，更不会驻留字符串常量池了。但是要注意这个“static”和其他三个不一样，它是静态的，在类加载阶段中的初始化阶段，会为静态变量指定初始值，也就是要把“static”赋值给ss1，这个赋值操作要怎么搞啊，先ldc指令把它放到栈顶，然后用putstatic指令完成赋值。注意，ldc指令，根据上面说的，会创建"static"字符串对象，并且会保存一个指向它的引用到字符串常量池。OK了， 这是第一句。

运行main方法后，首先是第二句，一样的，要先用ldc把"he"和"llo"送到栈顶，换句话说，会创建他俩的对象，并且会保存引用到字符串常量池中；然后有个＋号对吧，内部是创建了一个StringBuilder对象，一路append，最后调用StringBuilder对象的toString方法得到一个String对象（内容是hello，注意这个toString方法会new一个String对象），并把它赋值给s1。注意啊，没有把hello的引用放入字符串常量池。

然后是第三句，intern方法一看，字符串常量池里面没有，它会把上面的这个hello对象的引用保存到字符串常量池，然后返回这个引用，但是这个返回值我们并没有使用变量去接收，所以没用。

第四句，字符串常量池里面已经有了，直接用嘛

第五句，已经很明显了。

再看另外一段代码：

``` java
class NewTest2{ 
	public static void main(String[] args) { 
		String s1=new String("he")+new String("llo"); // ① 
		String s2=new String("h")+new String("ello"); // ② 
		String s3=s1.intern(); // ③ 
		String s4=s2.intern(); // ④ 
		System.out.println(s1==s3); 
		System.out.println(s1==s4); 
	} 
}
```
类加载阶段，什么都没干。

然后运行main方法，先看第一句，会创建"he"和"llo"对象，并放入字符串常量池，然后会创建一个"hello"对象，没有放入字符串常量池，s1指向这个"hello"对象。

第二句，创建"h"和"ello"对象，并放入字符串常量池，然后会创建一个"hello"对象，没有放入字符串常量池，s2指向这个"hello"对象。

第三句，字符串常量池里面还没有，于是会把s1指向的String对象的引用放入字符串常量池（换句话说，放入池中的引用和s1指向了同一个对象），然后会把这个引用返回给了s3，所以s3==s1是true。

第四句，字符串常量池里面已经有了，直接将它返回给了s4，所以s4==s1是true。

## **参考资料**
部分资料有疏漏和一些笼统[错误]的观点，参考时需与其他资料互相印证。
★标记的资料是我认为没有错误的资料，是我的最终参考，准确度、含金量 最高。
https://www.zhihu.com/question/55994121	★
https://www.zhihu.com/question/29833675	★
http://rednaxelafx.iteye.com/blog/1847971#comments	★
http://rednaxelafx.iteye.com/blog/774673#comments	★
http://droidyue.com/blog/2014/12/21/string-literal-pool-in-java/index.html	☆
http://www.cnblogs.com/xiohao/p/4296088.html

## **附录：**

### 关于java的元数据

HotSpot VM 里有一套对象专门用来存放元数据，它们包括： 

*   Klass系对象。元数据的最主要入口。用于描述类型的总体信息
*   ConstantPool/ConstantPoolCache对象。每个InstanceKlass关联着一个ConstantPool，作为该类型的运行时常量池。这个常量池的结构跟Class文件里的常量池基本上是对应的。可以参考[R大以前的一个回帖](http://hllvm.group.iteye.com/group/topic/26412#post-187861)。ConstantPoolCache主要用于存储某些字节码指令所需的解析（resolve）好的常量项，例如给[get|put]static、[get|put]field、invoke[static|special|virtual|interface|dynamic]等指令对应的常量池项用。
*   Method对象，用来描述Java方法的总体信息，像是方法入口地址、调用/循环计数器等等
*   ConstMethod对象，记录着Java方法的不变的描述信息，包括方法名、方法的访问修饰符、**字节码**、行号表、局部变量表等等。注意了，字节码就嵌在这ConstMethod对象里面。
*   Symbol对象，对应Class文件常量池里的JVM_CONSTANT_Utf8类型的常量。有一个VM全局的SymbolTable管理着所有Symbol。Symbol由所有Java类所共享。
*   MethodData对象，记录着Java方法执行时的profile信息，例如某方法里的某个字节码之类是否从来没遇到过null，某个条件跳转是否总是走同一个分支，等等。这些信息在解释器（多层编译模式下也在低层的编译生成的代码里）收集，然后供给HotSpot Server Compiler用于做激进优化。

在PermGen移除前，上述元数据对象都在PermGen里，直接被GC管理着。 
JDK8彻底移除PermGen后，这些对象被挪到GC堆外的一块叫做Metaspace的空间里做特殊管理，仍然间接的受GC管理。


<a id="1">
变量是变量，变量名是变量名，变量值是变量值，对象是对象，对象的引用是对象的引用。这个一定要搞清楚。变量 由: ***“一个包含部分已知或未知数值或资讯（即一个[值]）之[储存位址]”*** —— 变量值，以及 ***“相对应之[符号名称]（[识别字]）”*** —— 变量名，组成。如：`int a = 1;`a变量 的变量名为符号 ‘a’ ，变量值为[值] ‘3’。`Test t = new Test();` t变量 的变量名为符号 ‘t’ ，变量值为一个Test对象在内存中的存储位置（即对象的引用）。[↩](https://segmentfault.com/q/1010000000464492/a-1020000000464503#fnref2:footnote)
</a>
[^2]: int有class但不是类,其它基本类型也是如此，int.class对应的Class对象是JVM合成出来的，并不是从Class文件加载出来的，在JVM初始化的时候就会把原始类型和void对应的Class对象创建出来。这些Class对象的创建不依赖任何外部信息，(例如说需要从Class文件加载的信息)，不需要经历类加载过程，而纯粹是JVM的实现细节。
[^3]: JVM的一种实现，早期由Sun维护目前由Oracle，JVM有不止一种实现。[HotSpot VM]
[^4]: JDK6及之前的HotSpot VM使用symbolOop来实现CONSTANT_Utf8的内容，symbolOop存放在PermGen里；JDK7开始HotSpot VM把symbol移到了native memory里，类型名改为Symbol。跟StringTable相似，Symbol的管理也是有一个SymbolTable来管理的。所有Symbol都是interned在SymbolTable里的。同样SymbolTable里只存Symbol*（指向Symbol对象的指针）而不存Symbol自身的内容。


[变量]: https://zh.wikipedia.org/wiki/%E5%8F%98%E9%87%8F_(%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1)#.E5.9C.A8.E6.BA.90.E4.BB.A3.E7.A0.81.E4.B8.AD
[值]: https://zh.wikipedia.org/wiki/%E5%80%BC_(%E9%9B%BB%E8%85%A6%E7%A7%91%E5%AD%B8)
[储存位址]: https://zh.wikipedia.org/wiki/%E8%A8%98%E6%86%B6%E9%AB%94%E4%BD%8D%E5%9D%80
[符号名称]: https://zh.wikipedia.org/wiki/%E7%AC%A6%E8%99%9F
[识别字]: https://zh.wikipedia.org/wiki/%E6%A8%99%E8%AD%98%E7%AC%A6
[字面量]: https://zh.wikipedia.org/wiki/%E5%AD%97%E9%9D%A2%E5%B8%B8%E9%87%8F_(C%E8%AF%AD%E8%A8%80)
[HotSpot VM]: https://zh.wikipedia.org/wiki/HotSpot
[类在加载时]: http://wiki.jikexueyuan.com/project/java-vm/class-loading-mechanism.html
[javap]: https://maode.github.io/2017/09/02/170921-javap/