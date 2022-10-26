---
title: discuz隐藏ip的方法
date: Wed Oct 26 2021 14:44:26
tags:
	- discuz
---

## 隐藏帖子左侧头像旁的IP

修改`template/default/forum/viewthread_node.htm`，查找`<a href="javascript:;">$_G[setting][anonymoustext] <em>$post[useip]{if $post[port]}:$post[port]{/if}</em></a>`,将其中的`<em>$post[useip]{if $post[port]}:$post[port]{/if}</em>` 删除即可。

## 隐藏点击“回复”按钮时，默认添加的IP 

修改`source/include/post/post_newreply.php`,查找`$thapost['useip']`和`$thaquote['author']`将为其赋值拼接ip的地方`$thapost['useip']`和`$thaquote['useip']`删除即可。(或将`$thapost['useip']`和`$thaquote['useip']`赋值为空也可)

## 删除Discuz首页“今日”“昨日”“欢迎新会员”等文字

进入`templeta/default/forum/Discuz.htm`   (使用非默认模版的请修改当前使用模版的discuz.htm)删除以下代码即可,可以通过搜索`welcome`快速定位代码位置。
```
<p class="chart z">{lang index_today}: <em>$todayposts</em><span class="pipe">|</span>{lang index_yesterday}: <em>$postdata[0]</em><span class="pipe">|</span>{lang index_posts}: <em>$posts</em><span class="pipe">|</span>{lang index_members}: <em>$_G['cache']['userstats']['totalmembers']</em><!--{if $_G['cache']['userstats']['newsetuser']}--><span class="pipe">|</span>{lang welcome_new_members}: <em><a href="home.php?mod=space&username={echo rawurlencode($_G['cache']['userstats']['newsetuser'])}" target="_blank" class="xi2">$_G['cache']['userstats']['newsetuser']</a></em><!--{/if}--></p>
```

（完）


