@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

cmd /c build-wxLuaLauncher-x64.cmd
cmd /c build-wxLuaLauncher-x86.cmd
