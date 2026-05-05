@echo off
cd /d "F:\1. P71 Backup\MY WORK\VocalIQ"
echo Adding safe directory exception...
git config --global --add safe.directory "F:/1. P71 Backup/MY WORK/VocalIQ"
echo Cleaning up old .git folder...
rmdir /s /q .git 2>nul
echo Initializing fresh git repo...
git init
git config user.email "160136681+TrueGrit16@users.noreply.github.com"
git config user.name "Kundan"
git branch -M main
git add -A
git commit -m "Initial commit: vocaliQ enterprise voice AI platform"
git remote add origin https://github.com/TrueGrit16/vocaliQ.git
git push -u origin main
echo.
echo Done! Press any key to close.
pause >nul
