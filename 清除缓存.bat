@echo off
@echo -----------
@echo  清除缓存文件 (db.json) 和已生成的静态文件 (public)。
@echo  hexo clean
@echo -----------
call hexo clean

@echo bat执行结束，按任意键退出 & pause > nul