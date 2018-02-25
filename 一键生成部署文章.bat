@echo off
@echo -----------
@echo  生成文章
@echo  hexo g
@echo -----------
call hexo g
@echo -----------
@echo  部署文章静态页面
@echo  hexo d
@echo -----------
call hexo d
@echo -----------
@echo  部署文章源文件（.md文件）到Git
@echo  git add commit push
@echo -----------
call git add .
call git commit -m "添加新文章"
call git push
@echo bat执行结束，按任意键退出 & pause > nul