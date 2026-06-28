@echo off
REM 独立启动 refresh-nodes.ps1, 完全脱离调用方 session
REM 输出到 outputs\refresh-bg.log
cd /d E:\VPN
powershell -NoProfile -ExecutionPolicy Bypass -File "E:\VPN\refresh-nodes.ps1" -SkipPush > "E:\VPN\outputs\refresh-bg.log" 2>&1
echo RC=%ERRORLEVEL% >> "E:\VPN\outputs\refresh-bg.log"
