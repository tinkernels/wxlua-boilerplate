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

%_PSC% Copy-Item -Path "..\work-dir\luajit-dist-win32.7z" -Recurse -Force -Destination .
%_PSC% Copy-Item -Path "..\work-dir\luajit-dist-winx64.7z" -Recurse -Force -Destination .
%_PSC% Copy-Item -Path "..\work-dir\wxlua-dist-win32.7z" -Recurse -Force -Destination .
%_PSC% Copy-Item -Path "..\work-dir\wxlua-dist-winx64.7z" -Recurse -Force -Destination .
%_PSC% Copy-Item -Path "..\work-dir\wxWidgets-dist-win32.7z" -Recurse -Force -Destination .
%_PSC% Copy-Item -Path "..\work-dir\wxWidgets-dist-winx64.7z" -Recurse -Force -Destination .

7z x luajit-dist-win32.7z
7z x luajit-dist-winx64.7z
7z x wxlua-dist-win32.7z
7z x wxlua-dist-winx64.7z
7z x wxWidgets-dist-win32.7z
7z x wxWidgets-dist-winx64.7z
