---
title: 文件完整性校验sha和md5
date: 2018-11-03 15:32:41
tags:
	- sha校验
	- md5校验
---

## windows
```cmd
certutil -hashfile filename MD5
certutil -hashfile filename SHA1
certutil -hashfile filename SHA256
certutil -hashfile filename SHA512
```

## linux

```bash
$ md5sum filename
$ sha1sum filename
$ sha256sum filename
$ sha512sum filename
```

根据hash文件来判断文件的完整性。将hash文件和要校验的文件放在同一目录下，然后用`命令 -c hash文件`的方式来校验。如：
```bash
$ md5sum -c md5-hash.txt
$ sha1sum -c sha1-hash.txt
```


（完）



