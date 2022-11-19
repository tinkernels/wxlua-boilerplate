@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

7z x -aoa -o. ..\work-dir\luajit-dist-win32.7z
7z x -aoa -o. ..\work-dir\luajit-dist-winx64.7z
7z x -aoa -o. ..\work-dir\wxlua-dist-win32.7z
7z x -aoa -o. ..\work-dir\wxlua-dist-winx64.7z
7z x -aoa -o. ..\work-dir\wxWidgets-dist-win32.7z
7z x -aoa -o. ..\work-dir\wxWidgets-dist-winx64.7z
