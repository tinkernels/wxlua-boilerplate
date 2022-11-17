@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

set _PWSH=powershell
where pwsh.exe 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo=
    echo found pwsh
    echo=
    set _PWSH=pwsh
)
set _PSC=%_PWSH% -NoProfile -ExecutionPolicy Bypass -Command

cmd /c prepare.cmd
cmd /c build-wxLuaLauncher.cmd
%_PSC% Copy-Item -Path ..\lua-app-example\lua-app -Recurse -Force -Destination wxLuaLauncher-winx64-dist 
%_PSC% Copy-Item -Path ..\lua-app-example\lua-app -Recurse -Force -Destination wxLuaLauncher-win32-dist
