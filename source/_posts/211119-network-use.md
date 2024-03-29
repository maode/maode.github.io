---
title: 计算机网络相关知识点
date: Wed Oct 26 2021 17:19:34
tags:
	- 网络
---

一个设备工作在哪一层，关键看它工作时利用哪一层的数据头部信息。网桥（交换机）工作时，是以MAC头部来决定转发端口的，因此显然它是数据链路层的设备。
路由器是根据IP地址进行的路由，因此它是网络层设备。

广播域 是二层的概念，指的是mac帧的目的地址为全1，这样的广播帧能够影响的范围
ip网段 是三层的概念，如192.168.1.0/24 192.168.2.0/24 就分属两个ip网段

二层交换机为二层设备，内部存有一张“MAC地址和交换机设备端口”的映射表。交换机不会去关心数据包中的IP信息，因为IP数据包属于第三层。交换机转发数据时只解析链路层（只解析MAC地址），MAC地址属于链路层地址中的一种。

二层交换机只会处理以太网帧，换句话说，如果帧是广播帧，交换机肯定会转发泛洪，但如果不同ip网段，那么丢弃这个ip数据包的是主机，而不是交换机。 



# 二层广播：
广播帧的目的MAC地址为十六进制的FFFFFFFFFFFF，所有收到该广播帧的主机都要接收并处理这个帧。所有收到该广播帧的主机都要接收并处理这个帧。（交换机一般所发送的广播帧，目的MAC全为F）
二层广播针对MAC，指目的MAC地址为十六进制的FFFFFFFFFFFF的数据帧，为广播帧。


泛洪：
有明确的目的MAC地址，但是该MAC地址在交换机的MAC地址表中找不到，此时交换机将从该接口收到的数据流，向除该接口之外的所有接口发送出去。目标主机收到后进行处理，其它主机丢弃。（有具体的目标MAC地址，但交换机在Mac地址表中找不到）


# 三层广播：
一般是路由传播。TCP/IP协议栈中, 传输层只有UDP可以广播，只能对同一子网内部广播, 广播数据包不经过路由器。
192.168.1.255 一个网段内的广播
255.255.255.255 全网络广播
三层广播针对IP，指主机标识段host ID 为全1 的IP 地址为广播地址，广播的分组传送给host ID段所涉及的所有计算机。例如，对于10.1.1.0 （255.255.255.0 ）网段，其广播地址为10.1.1.255 （255 即为2 进制的11111111 ），当发出一个目的地址为10.1.1.255 的分组（封包）时，它将被分发给该网段上的所有计算机。详细介绍参考百度百科 [广播地址](https://baike.baidu.com/item/%E5%B9%BF%E6%92%AD%E5%9C%B0%E5%9D%80)



# 组播：

第三种发送方式为组播，组播比广播更加高效。组播转发可以理解为选择性的广播，主机侦听特定组播地址，接收并处理目的MAC地址为该组播MAC地址的帧。

组播MAC地址和单播MAC地址是通过第一字节中的第8个比特区分的。组播MAC地址的第8个比特为1，而单播MAC地址的第8个比特为0。

当需要网络上的一组主机（而不是全部主机）接收相同信息，并且其他主机不受影响的情况下通常会使用组播方式。








三层交换机等同于路由器。也就是说源ip和目的ip在数据包里一直不变（不经过nat的情况），mac地址将时刻改变。广播只存在二层。三层情况下是路由寻址。

路由不是禁止广播，而是终结广播，就是说路由无法不禁止广播。

vlan划分隔离的是vlan之间的广播，同一二层内广播依就，意思是vlan仅仅是将管理目标划分成不同的二层区域。

二层广播是因为不知道目标而产生的，属于被动产生；三层广播是因为应用的需要而主动进行的，是两个概念。当然，他们都不会跨越路由。

凡是能够接收到一个广播范围的区域叫做广播域，也就是说一个二层范围就是一个广播域。（因为到了三层就到路由器了，而路由器终结广播，所以说一个二层范围就是一个广播域，不知道这么理解对不对）

# 四层交换机
第四层交换机是基于传输层数据包的交换过程的，是一类基于TCP/IP协议应用层的用户应用交换需求的新型局域网交换机。第四层交换机支持TCP/UDP第四层以下的所有协议，可识别至少80个字节的数据包包头长度，可根据TCP/UDP端口号来区分数据包的应用类型，从而实现应用层的访问控制和服务质量保证。所以，与其说第四层交换机是硬件网络设备，还不如说它是软件网络管理系统。也就是说，第四层交换机是一类以软件技术为主，以硬件技术为辅的网络管理交换设备。
我们说第四层交换机基于第四层数据包交换，这是说它可以根据第四层TCP/UDP端口号来分析数据包应用类型，即第四层交换机不仅完全具备第三层交换机的所有交换功能和性能，还能支持第三层交换机不可能拥有的网络流量和服务质量控制的智能型功能。


# IP地址主机号全0和全1：

主机号全0，即最后一段全为二进制0，如：192.168.1.0，代表一个网段。
主机号全1，即最后一段全为二进制1，如：192.168.1.255，如果子网掩码为255.255.255.0，则代表 192.168.1.0/24 网段的广播地址。


# 子网掩码：

IP  地址：192.168.1.199       ‐＞11000000.10101000.00000001.11000111
子网掩码：255.255.255.0       ‐＞11111111.11111111.11111111.00000000
十进制的显示形式是给人看的，二进制的显示形式是给计算机看的。。。子网掩码的左边是网络位，用二进制数字“1”表示，1的数目等于网络位的长度；右边是主机位，用二进制数字“0”表示，0的数目等于主机位的长度。 例如上面的子网掩码255.255.255.0的  “1”的个数是左边24位，则对应IP地址左边的位数也是24位;即可用192.168.1.0/24表示，其中24代表网络位的个数。其余为主机位。
详细可参考 [如何理解子网掩码](https://www.zhihu.com/question/56895036)

# 子网网段划分

## 求某网段内的网络地址
将IP地址和子网掩码换算为二进制，子网掩码在二进制表现形式下，其中全为1的二进制位是网络位，全为0的二进制位是主机位。然后两者进行与运算，计算结果就是是**网络地址**。
**网络地址代表该网段的起始地址**。

## 求某网段内的广播地址
先求出网段的网络地址，二进制表现形式下，网络地址中的网络位部分保持不变，主机位变为全1，结果就是该网段的**广播地址**。 
**广播地址代表该网段的结束地址**。

## 求某网段内的最大主机数
1. 先得出子网掩码在二进制表现形式下，全为1的二进制位是网络位，全0的二进制位是主机位。此处能得出有几个二进制位是主机位。假设有n位。
2. 2的n次方就是该网段能划分的最大主机数。然后减去2（减2是减去一个网络地址和一个广播地址.如 192.168.1.0/24 网段的网络地址为：192.168.1.0广播地址为：192.168.1.255）。
或者还有一个简单的方法，如果已知网络地址和广播地址，那么这两者之间相减，就是该网段最大主机数。
## 关于网络IP的CIDR写法（无类别域间路由，Classless Inter-Domain Routing）
CIDR 地址中斜杠前代表标准的32位IP地址斜杠后表示该网段的网络前缀位数的信息。以CIDR地址222.80.18.18/25为例，其中“/25”表示其前面地址中的前25位代表网络部分，其余位代表主机部分。
如：192.168.1.0/24 斜杠后面的数字是代表该地址在二进制表现形式下网路位的位数是24位。



# 子网掩码、网段、主机数、计算方法

详情参考：https://blog.csdn.net/yinshitaoyuan/article/details/51782330

1、利用子网数目计算子网掩码

把B类地址172.16.0.0划分成30个子网络，它的子网掩码是多少？

①将子网络数目30转换成二进制表示11110

②统计一下这个二进制的数共有5位

③注意：当二进制数中只有一个1的时候，所统计的位数需要减1（例如：10000要统计为4位）

④将B类地址的子网掩码255.255.0.0主机地址部分的前5位变成1

⑤这就得到了所要的子网掩码（11111111.11111111.11111000.00000000）255.255.248.0。

 

2、利用主机数目计算子网掩码

把B类地址172.16.0.0划分成若干子网络，每个子网络能容纳500台主机，它的子网掩码是多少？

①把500转换成二进制表示111110100

②统计一下这个二进制的数共有9位

③将子网掩码255.255.255.255从后向前的9位变成0

④这就得到了所要的子网掩码（11111111.11111111.11111110.00000000）255.255.254.0。

 

3、利用子网掩码计算最大有效子网数

A类IP地址，子网掩码为255.224.0.0，它所能划分的最大有效子网数是多少？

①将子网掩码转换成二进制表示11111111.11100000.00000000.00000000

②统计一下它的网络位共有11位

③A类地址网络位的基础数是8，二者之间的位数差是3

④最大有效子网数就是2的3次方，即最多可以划分8个子网络。

 

4、利用子网掩码计算最大可用主机数

A类IP地址，子网掩码为255.252.0.0，将它划分成若干子网络，每个子网络中可用主机数有多少？

①将子网掩码转换成二进制表示11111111.11111100.00000000.00000000

②统计一下它的主机位共有18位

③最大可用主机数就是2的18次方减2（除去全是0的网络地址和全是1广播地址），即每个子网络最多有262142台主机可用。

 

5、利用子网掩码确定子网络的起止地址

B类IP地址172.16.0.0，子网掩码为255.255.192.0，它所能划分的子网络起止地址是多少？

①利用子网掩码计算，最多可以划分4个子网络

②利用子网掩码计算，每个子网络可容纳16384台主机（包括网络地址和广播地址）

③用16384除以256（网段内包括网络地址和广播地址的全部主机数），结果是64

④具体划分网络起止方法如下：

172.16.0.0～172.16.63.255

172.16.64.0～172.16.127.255

172.16.128.0～172.16.191.255

172.16.192.0～172.16.255.255

6、以下是资深人士经验总结的关系表

A类IP地址段：1.0.0.0～126.255.255.255 私有地址段：10.0.0.0～10.255.255.255
B类IP地址段：128.0.0.0～191.255.255.255 私有地址段：172.16.0.0～172.31.255.255
C类IP地址段：192.0.0.0～223.255.255.255 私有地址段：192.168.0.0～192.168.255.255



# 不同网段通信：
在没有路由器的情况下，两个网段之间是不能进行TCP/IP通信的，即使是两个网络连接在同一台交换机（或集线器）上，基于TCP/IP协议发送数据时，发送端主机会根据子网掩码（255.255.255.0）与远程主机的IP 地址作 “与” 运算来判定两个主机是否处于相同的网段里。要实现两个网段之间的通信，必须通过网关。
比如有网络A和网络B，网络A的IP地址范围为“192.168.1.1~192. 168.1.254”，子网掩码为255.255.255.0；网络B的IP地址范围为“192.168.2.1~192.168.2.254”，子网掩码为255.255.255.0
如果网络A中的主机发现数据包的目的主机不在本网段中，就把数据包转发给它自己的网关，再由网关转发给网络B的网关，网络B的网关再转发给网络B的某个主机。

如果目的IP地址显示不是同一网段的，那么A要实现和B的通讯，在路由缓存条目中没有对应MAC地址条目，就将第一个正常数据包发送向一个缺省网关，这个缺省网关一般在操作系统中已经设好，对应第三层路由模块，所以可见对于不是同一子网的数据，最先在MAC表中放的是缺省网关的MAC地址；然后就由三层模块接收到此数据包，查询路由表以确定到达B的路由，将构造一个新的帧头，其中以缺省网关的MAC地址为源MAC地址，以主机B的MAC地址为目的MAC地址。通过一定的识别触发机制，确立主机A与B的MAC地址及转发端口的对应关系，并记录进流缓存条目表，以后的A到B的数据，就直接交由二层交换模块完成。这就通常所说的一次路由多次转发。

# 相同网段通信：
比如A要给B发送数据，如果在同一网段，但A不知道B的MAC地址，A就发送一个ARP请求，交换机查MAC表，有则返回，无则泛洪。B收到ARP请求后，返回其MAC地址，A用此MAC封装数据包并发送给交换机，交换机启用二层交换模块，查找MAC地址表，将数据包转发到相应的端口。

# 网关：
网关(Gateway)又称网间连接器、协议转换器。网关在传输层以上实现网络互连，是最复杂的网络互连设备，仅用于两个高层协议不同的网络互连。网关的结构也和路由器类似，不同的是互连层。网关既可以用于广域网互连，也可以用于局域网互连。 **网关是一种充当转换重任的计算机系统或设备。**在使用不同的通信协议、数据格式或语言，甚至体系结构完全不同的两种系统之间，网关是一个翻译器。与网桥只是简单地传达信息不同，**网关对收到的信息要重新打包，以适应目的系统的需求。**同时，网关也可以提供过滤和安全功能。大多数网关运行在OSI 7层协议的顶层--应用层。

顾名思义，网关(Gateway)就是一个网络连接到另一个网络的“关口”。在OSI中，网关有两种：一种是面向连接的网关，一种是无连接的网关。当两个子网之间有一定距离时，往往将一个网关分成两半，中间用一条链路连接起来，我们称之为半网关。

按照不同的分类标准，网关也有不同种类。TCP/IP协议里的网关是最常用的。

# 路由
进行网络寻址和路径转发，工作在第三层网络层。

# 以太网、无线局域网（WLAN）、ADSL 区别

<!-- more -->

严格来说，三者都是不同的技术标准，但是都可以用来连接网络。大家基于这些标准制造了许多可以上网的设备以及传输介质。
以太网和无线局域网，都属于 IEEE 802 系列标准，IEEE 802系列标准是IEEE 802 LAN/MAN 标准委员会制定的局域网、城域网技术标准。其中最广泛使用的有以太网、令牌环、无线局域网等。这一系列标准中的每一个子标准都由委员会中的一个专门工作组负责。IEEE 802中定义的服务和协议限定在OSI模型的最低两层（即物理层和数据链路层）。
ADSL和上面两者不是一个路子，关于ADSL 的国际标准主要是ANSI 制定的。

以太网是一种通信协议标准 IEEE802.3 并不严格要求一定要在哪种物理介质上使用，虽然目前的以太网主要使用双绞线。传输介质：双绞线，光纤等。

无线局域网（WLAN）是另一种通信协议标准 IEEE802.11 传输介质：无线电波发送射频信号。

ADSL：全名Asymmetric Digital Subscriber Line，非对称数字用户线路，是数字用户线路服务中最流行的一种。一种基于电话线的上网传输技术名称。特指基于电话线的上网技术。
通过ADSL上网时，关键的一个玩意就是猫（ADSL Modem），猫负责以太网数据包和电信号之间的转换。所谓转换，就是一种表现形式的电信号（方波信号）转换为另一种表现形式的电信号（正弦波），归根结底都是指代同一段数据，只是表现形式不同。

# 关于网络信号的在不同传输介质中的传输
计算机眼睛里只有0、1，计算机上看到的汉字、英文字母、数字、特殊符号，在计算机眼里也是由0、1组成的串串。当把“01100011”存储到物理介质上，这个二进制流在不同介质有不同的表示方法，硬盘、光盘、磁带机、U盘对这个串串，肯定有不同的表现形式，但计算机并不关心，因为下次读取介质时，依然会读取“01100011”，0是一种状态，1是另一种状态，写入/读取数据时，遵从同样的标准，读取数据时，才能还原出原始的数据，对吗？同理，当传输“01100011”时，无论是采用电信号、光信号、电磁信号，只是每种传输介质对于0、1的不同呈现形式，只要通信的双方遵从同样的标准，发送方把0、1以特有的信号状态，把“01100011”编码成一串状态流，接收方再把这串状态流还原成“01100011”，这就是计算机通信的基础原理，这就是大名鼎鼎的OSI参考模型的物理层！例如：电话线和双绞线是以电信号的方式传输（虽然都是电信号，但两者是不同形式的电信号），光纤是以光信号的方式传输，无线网是以电磁信号的方式传输。

# 链路层的作用
链路层的主要作用是把网络层传下来的数据封装成帧，然后发送到链路上去。数据链路层主要有两个功能 ：帧编码和误差纠正控制。


# 网络信息怎么在网线里传播的
复制自知乎 https://www.zhihu.com/question/276312505 西凉太守24601的回答，讲的挺形象的，是基于TCP/IP四层模型进行的讲解，。
**问：**
网线传播的是电信号，光纤是光信号，咱们上网的各种信息转换为电信号或者光信号在网线里传播吗？还有丢包是怎么回事，数据包也是一种电信号吧，丢包指的电信号在网线里发热没了吗？全世界的网络互通的，怎么确定我要发送的信息能准确到达目的地，既然全世界网络互通的，怎么实现的各种限制，理论上是不我有一根联网的网线是不就能截获各种信息，比如某人的密码，银行工作流水等等？

**答：**
作者：西凉太守24601
链接：https://www.zhihu.com/question/276312505/answer/386797838
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

题主的问题非常大。其实别人再跟你讲，你还是不会清楚，应该自己去看一套完整的网络基础教程。但是刚好我最近闲，我就给你梳理一下，当然每一步都很简略，因为说详细了就太长了。首先要了解一点，网络是分层组织的，相邻的层之间暴露接口给对方使用。这是计算机世界典型的组织模式。举个例子，我去寄邮件，首先我要对我要邮寄的东西进行打包，这就相当于货物的第一层处理；之后我要叫快递小哥，我可以叫顺丰圆通韵达，交给他们就完了，这是对货物的第二层处理；快递小哥拿到货物以后，他给你的快递上贴个地址，就交给自己的物流了，这就是第三层处理；物流这时候就开始转运了啊，比如你寄给了上海，上海在哪里，这需要有人来定义好，你的货物需要从济南转运中心到苏州转运中心再到上海转运中心，最后到上海，这是对你货物的第四层处理，到了上海之后，就是把整个过程倒过来，物流把货物交给快递小哥，快递小哥交给收货人，收货人打开包装，收货。我们为什么要分层，因为这样这样比较好组织，我打包的这一层不需要知道其它层怎么运作的，我小哥也不需要关心你到底怎么打包的，物流不需要知道小哥到底怎么安排自己的取货时间和路线。每个层相互独立，我只要专心干好打包一件事情，知道打包完了交给小哥就行了，剩下的我不管了。OK。这和网络传输是一样一样的。那么，上述的送快递的四个层，大概相当于网络传输的哪些层呢？
## 一、应用层
应用层就是产生货物的那一层，就相当于我想寄货，我只要准备好货物，打包好就OK了。这一层有HTTP协议，FTP协议，SMTP协议等。分别对应不同的应用。我们浏览网页，用的是HTTP，去FTP下载，是FTP，发邮件，是SMTP。就是产生货物，并将其打包。打包后的数据就是数据包了。然后我们开始叫快递小哥。
## 二、传输层
货物打包完了，我就叫快递小哥来。网络世界里运送货物的主要有两个快递公司，一个是TCP协议，一个是UDP协议。就像顺丰与韵达的关系吧，都是用来发送货物的。应用层产生的数据，交给传输层，传输层会再将数据进行一些处理，具体就是给数据套个传输层的头，头里面包含一些传输层自己需要用到的数据，比如说送到天都小区8号楼6层2号。就像快递小哥往你打包好的东西上贴个地址。之后小哥就带着你的货物去找自己的公司物流了。也就是数据包交付给了网络层。
## 三、网络层
网络层只有一个协议，就是IP协议（这个地方写错了，网络层有很多协议，IP协议只是使用比较广泛的其中一种）。目前我们广泛使用的是IPv4。IPv4协议就要讲细致一点了，因为与你的问题息息相关。这个协议负责干嘛呢？第一：他负责编址。就像上海到底是哪个上海，在什么地方。IPv4最重要的功能就是给网络上的主机编号，比如你发给百度的东西，IPv4负责给百度一个地址，然后通过某种方式，把这个地址广而告之整个网络。于是现在就知数据往哪里发了。这就是你的问题：“全世界的网络互通的，怎么确定我要发送的信息能准确到达目的地。”答案的第一部分，因为主机有独立的IP地址，这个IP地址不同于公网上的任何其他地址，因此你的数据知道往哪里发。第二：他负责路由你的数据。路由这两个字读起来拗口，不如快递的“转运”两个字听起来好理解，其实就是规定你的数据包如何转运。显然你和目的主机之间没有直接连着一根网线，所以你的数据包得经过转运，比如说，你家里的路由上层只直接连接着小区的路由，你产生的流量他只能发到小区的路由，小区的路由说，我直接连着北京的机房呢，所以把数据发到北京的机房去，北京的机房（是超级大的路由）一看，这IP地址是南京的啊，我没直接相连，不过我用光缆连着上海的机房，上海的机房也告诉我他可以把我的数据发到南京，我就先发到上海的机房，上海的机房直接连着南京的机房，南京的机房连着跟你微信的小妹妹的小区的路由，小区的路由连着她家里的路由，她家里的路由连着她的手机。这样你的数据就发到目的地了。显然，你的数据不止有一条路，假如北京的机房和苏州的机房也相连，苏州也跟你的路由说送南京的数据我也能送啊，北京的路由就有可能选择把数据发到苏州机房转运。路由之间通过某种协议来交换自己能到达的主机的信息。这样你的数据包有了地址以后，就可以在网络世界传送了。这就是你的问题：“全世界的网络互通的，怎么确定我要发送的信息能准确到达目的地。”答案的第二部分，因为路由器之间可以相互交换自己能够连接的主机的信息，所以数据能够到达目的地，但到达和准确到达其实还有点距离。意思是传输中可能出现一些异常情况，导致数据无法到达或者传输出错。IP层也部分处理这种情况。第三：他负责处理网络的一些异常情况。网络世界是一个松散的组织，你很难保证你数据包在传输中不出错，比如说光缆受到了干扰，这都可能使你的数据包出错，IPv4还提供了一个简单的校验功能，如果计算出来发现数据包在传输中出错了，他就丢掉，这是丢包的一个原因；另外，假如说一段互联网线路特别繁忙，就像一个高速公路，本来一小时只能传输1000吨货物，你现在发了1500吨的东西过来，路由器来不及发送，他就把多余的货物存在自己的存储空间里，但你还接着发，发了2000吨货物，把存储空间都撑满了，你再发送的数据，路由器就直接丢弃了，这是丢包的第二个原因。发热发没了这种事情其实也不是不可能存在，就是传输中数据出错了呗，或者直接就在路上翻车了，永远没有到达下一个路由。那你可能会说，这怎么办呢？有很多办法，比如说目的地的快递小哥一直等不到包裹，就跟北京说，这哥们货物怕是丢了，这时候北京的小哥会再发一份包裹出去；或者北京的小哥一直等不到目的地的小哥说自己收到货了，他猜是弄丢了，于是就重发了一份（反正网络数据可以复制嘛），这是传输层纠错；也可以是你寄货的发现，我擦怎么都发出去500ms了怎么小姐姐还还没收到，我再发一份，这是应用层纠错。
## 四、物理层（按照TCP/IP四层模型来对应的话。应该是网络访问层更贴切，包含链路层和物理层）
网络搞清楚发到哪里、怎么转运以后，就交给物理层来具体发送数据。还以上文的例子继续讲，北京的机房说我发到上海去，然后就把数据转换为光信号或者电信号，甚至说不定通过卫星中继的还可以是无线（电磁）信号，发出去了。到底怎么转的，你可以自己去查一下。这就相当于我发到南京的包裹，网络层负责告知要通过上海转运，但怎么发到上海去，可以像顺丰，有自己的飞机，也可以是陆运用车拉，总之这就是物理层的功能，负责最底层的货物运送。所以，你的问题“咱们上网的各种信息转换为电信号或者光信号在网线里传播吗？”，基本上可以认为，是的。你可能会疑问，那光电信号怎么承载信息呢，这就是二进制如何编码为不同文件的问题，可以自行了解。至此，你就知道网络数据到底是怎么从一个主机传送到另外一个主机了。送到目的地之后的事，不过是把上面的过程倒过来再走一次。“既然全世界网络互通的，怎么实现的各种限制”。不知道你想说的限制是什么。限速？用户认证？问题不清楚就没有答案。“理论上是不我有一根联网的网线是不就能截获各种信息，比如某人的密码，银行工作流水等等”。从上文你也看到了，网络数据可能并不路过你有掌控权的主机，因此这部分数据你是无法截获的。就像你在自己家门口的路上蹲着等快递，从纽约发往华盛顿的东西你是不可能截获的一样。但是你是否就一定不能获取从纽约发往华盛顿的东西呢？也不尽然，你可以安排一个眼线，蹲在纽约到华盛顿的高速公路上，把货物劫了再发到你家门口，这也是截获的一种，或者说你在网上扯着嗓子喊，说我这里是华盛顿，万一有哪个路由信了，就把数据发给你了。但是显然网络工程师不是傻子，他们也设计了很多方法来保证你截获不了数据，比如你能掌握联通北京机房的控制权吗？当然很难，防火墙什么的都是白弄得吗？就算你截获了，打开一看，货物是本天书，都是加密过的，你不知道密码，也看不懂；你在门口高喊我是华盛顿，快递小哥听到后心想，就你还有资格把这里定义成华盛顿？直接不理你，你的声音都传不出你家门口那条路。最后，我觉得你也就是一时兴起随口问一下这个问题，我回答这么长或许你都懒得看，但其实也无所谓，我整理一下思路，对我也没什么损失，但你如果真想了解网络世界的构成，你就应该去认真看书，系统地学习，一时兴起学不到东西，我的回答也受我自身能力所限，有错误或者遗漏，你问到的也不一定是对的。以上，共勉。

# ADSL 接入网的结构和工作方式
请参考这篇文章：https://www.cnblogs.com/errornull/p/10015698.html

# 数据帧、数据包、数据报、端、消息/报文
所谓数据帧（Data frame），就是数据链路层的协议数据单元，**它包括三部分：帧头，数据部分，帧尾。**其中，帧头和帧尾包含一些必要的控制信息，比如同步信息、地址信息、差错控制信息等；**数据部分则包含网络层传下来的数据，比如IP数据包，等等。**以MAC帧来讲，帧头包括三个字段共占8字节，数据部分包括一个字段共占46~1500字节，帧尾包括一个字段共占4字节。

数据帧（Frame）：是一种信息单位，它的起始点和目的点都是数据**链路层**。
数据包（Packet）：也是一种信息单位，它的起始和目的地是**网络层**。
数据报（Datagram）：通常是指起始点和目的地都使用无连接网络服务的的**传输层**的信息单元，如常说的UDP数据包。
数据段（Segment）：通常是指起始点和目的地都是**传输层**的信息单元，如TCP数据段（TCP协议是将字节流分段发送的，每一段就是一个数据段）。
消息/报文（message）：是指起始点和目的地都在**网络层以上**（经常在**应用层**）的信息单元。

数据发送时由上层向下层封装，下层数据包含上层数据。

# 以太网协议标准和tcp/ip协议的关系
以太网是局域网的一种，以太网协议是链路层协议的一种，其他的比如还有令牌环、FDDI。和局域网对应的就是广域网，如Internet，城域网等。
从网络层次看，局域网协议主要偏重于低层（业内一般把物理层、数据链路层归为低层）。以太网协议（IEEE 802.3）主要针对数据链路层（只规定MAC和LLC）的定义；而Internet采用的TCP/IP协议主要偏重于中间层（网络层/传输层）。
以太网的高层协议既可以是TCP/IP协议、也可以是IPX协议（NetWare）、NetBEUI协议等；反过来，TCP/IP协议既可以运行在以太网上，也可运行在FDDI、WLAN上。打个比方，协议是车，局域网是路。机动车既可以在公路上行驶，也可以在乡间小道行驶；路上既可以跑机动车，也可以跑自行车。
以太网是TCP/IP使用最普遍的物理网络，换句话说，以太网是用户接入Internet最常见的实现方式，而TCP/IP又是Internet采用的协议，因此，以太网+TCP/IP 成为IT行业中应用最普遍的技术。以太网+TCP/IP 的组合就相当于 机动车畅行在公路上。

# TCP/IP 五层模型详解（四层和七层也可以参考）
作者：小秋仙女
链接：https://www.zhihu.com/question/19718686/answer/185348786
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

计网（计算机网络）的目的是通信，是为了连接端到端所以我们首先要考虑——网怎么设计

我们有两种网：1.分组交换；2.电路交换（电话）

在很久很久以前，你记不记着，有个“拨号连接”，有个叫做“猫”的东西？？？
没错，就是那个，一上网就打不了座机的时代
此时，我们还是电路交换哟
这样太蠢了！！！
如果我只是想上网看下小电影的简介，那我打开介绍小电影的网站，就暂时不会再通信了
所以，没必要一直给我连接着啊！

于是，我们用起了分组交换
分组交换还有两种方式：
1.虚电路，如ATM（模拟电话线路）；2.数据报，如因特网

>为啥因特网不用虚电路？
肯定是因为，大多数时候，虚电路没必要啊，而且麻烦不好用啊

>为啥虚电路没必要&不好用？
因为大多数时候，互联网没有实时要求啊，&他的面向连接浪费资源啊

好嘞，现在我们知道了，因特网使用的是，数据报
我们先不管数据报是什么，我们先考虑下如何传输数据报

## 物理层

我们的因特网，肯定是基于物理电路的，
因此，我们需要一个，将数据转化为物理信号的层，
于是，物理层诞生啦

## 链路层

有了处理物理信号的物理层，可我们还得知道，信号发给谁啊
你肯定知道，每个主机都有一个，全球唯一的MAC地址吧
所以，我们可以用MAC地址来寻址啊
恭喜你，链路层诞生啦

## 网络层

别急，你知道MAC地址，是扁平化的吧。也就是说，MAC地址的空间分布，是无规律的！！！
如果你有十万台主机，要通过MAC地址来寻址，不管你设计什么样的算法，数据量都太大了！！！
所以，我们需要IP地址啊，有了IP地址，恭喜你，网络层诞生啦

## 传输层

然而，一台主机不能只和一台服务器通信啊，
毕竟下小电影，也要同时货比三家啊
那如何实现并行通信呢？
嘿嘿，我们有端口号啊
再基于不同需求：
有人想要连得快，不介意数据丢失，比如你的小电影
有人必须要数据可靠，比如发一个电子邮件
于是产生了UDP&TCP
恭喜你，传输层诞生啦

## 应用层（对应OSI七层模型的 会话层，表示层，应用层）

别急，你知道的吧，不同应用，有不同的传输需求
比如，请求网页，发送邮件，P2P...
而且，还有DHCP服务器啊
为了方便开发者，我们就对这些常用需求，进行了封装
恭喜你，应用层诞生啦


（完）






