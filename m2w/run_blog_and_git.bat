@echo off
REM 1. 激活 conda 环境，更改输出文字编码。
chcp 65001
echo 1. 运行myblog.exe
myblog.exe
if errorlevel 1 (
    echo myblog.exe 运行出错，停止执行
    pause
    exit /b 1
)
REM 3. 进入要上传的 git 仓库目录
echo 3. 进入git目录
cd /d D:\workDocument\somniloquy

REM 4. git 添加所有改动
echo 4. git add .
git add .

REM 5. git 提交（自动生成提交信息，含时间戳）
echo 5. git commit
set commitmsg=自动提交 %date% %time%
git commit -m "%commitmsg%" || echo 没有新的改动需要提交

REM 6. git 推送到远程仓库（默认分支为 main，修改为你实际分支名）
echo 6. git push
git push origin master

REM m2w文件记录推送
REM cd /d D:\workDocument\m2w
REM git add .
REM set commitmsg=自动提交 %date% %time%
REM git commit -m "%commitmsg%" || echo 没有新的改动需要提交
REM git push origin master
REM REM 7. 提示完成
REM echo 7. 上传完成
pause
