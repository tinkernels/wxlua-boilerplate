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

%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/openresty-luajit2-dist/releases/latest/download/luajit-dist-win32.7z" -OutFile "luajit-dist-win32.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/openresty-luajit2-dist/releases/latest/download/luajit-dist-winx64.7z" -OutFile "luajit-dist-winx64.7z"

%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/luajit-dist-win32.7z" -OutFile "luajit-dist-win32.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/luajit-dist-winx64.7z" -OutFile "luajit-dist-winx64.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/wxlua-dist-win32.7z" -OutFile "wxlua-dist-win32.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/wxlua-dist-winx64.7z" -OutFile "wxlua-dist-winx64.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/wxWidgets-dist-win32.7z" -OutFile "wxWidgets-dist-win32.7z"
%_PSC% Invoke-WebRequest -Uri "https://github.com/tinkernels/libwxlua-dist/releases/latest/download/wxWidgets-dist-winx64.7z" -OutFile "wxWidgets-dist-winx64.7z"
