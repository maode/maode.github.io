---
title: alwayslight(sed命令设置树莓派常亮)
date: Wed Oct 26 2021 14:34:47
tags:
	- 树莓派
---

```bash
#!/bin/bash
sudo sed -i  '/^.*xserver-command.*(can.*$/!s/^.*xserver-command.*$/xserver-command=X -s 0 -dpms/'  /etc/lightdm/lightdm.conf
```


（完）




