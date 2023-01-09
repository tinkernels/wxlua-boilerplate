@echo off
chcp 65001 >NUL 2>NUL

set ORIGINAL_CWD=%CD%
cd /D %~dp0

set _PWSH=powershell
where pwsh.exe 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo=
    echo found pwsh
    echo=
    set _PWSH=pwsh
)
set _PSC=%_PWSH% -NoProfile -ExecutionPolicy Bypass -Command

set CMAKE_GENERATOR_PARAM=
for /F "tokens=1 delims=." %%a in ('MSBuild -nologo -version') do (
    set MSVC_TOOLSET=%%a
)
if "%MSVC_TOOLSET%x"=="x" (
    echo MSVC_TOOLSET not found
) else (
    echo MSVC_TOOLSET %MSVC_TOOLSET%
    if "%MSVC_TOOLSET%"=="15" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 15 2017"
    )
    if "%MSVC_TOOLSET%"=="16" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 16 2019"
    )
    if "%MSVC_TOOLSET%"=="17" (
        set CMAKE_GENERATOR_PARAM=-G "Visual Studio 17 2022"
    )
)

set CMAKE_GENERATOR_PARAM=%CMAKE_GENERATOR_PARAM% -A Win32
echo=
echo CMAKE_GENERATOR_PARAM: %CMAKE_GENERATOR_PARAM%

set TKVAR_BUILD_DIR=build-wxLuaLauncher\x86
set TKVAR_LUAJIT_DIST_DIR=luajit-dist-win32
set TKVAR_LAUNCHER_DIST_DIR=wxLuaLauncher-dist-win32
set TKVAR_WX_DLL_DIR=wxWidgets-dist-win32\lib\vc_dll
set TKVAR_WX_INC_DIR=wxWidgets-dist-win32\include
set TKVAR_WXLUA_DLL_DIR=wxlua-dist-win32\bin
set TK_Lua_App_Dir=..\lua-app-example\lua-app

rmdir /q /s "%TKVAR_BUILD_DIR%"
mkdir "%TKVAR_BUILD_DIR%"

rmdir /q /s "%TKVAR_LAUNCHER_DIST_DIR%"
mkdir "%TKVAR_LAUNCHER_DIST_DIR%\lua"

rmdir /q /s wxLuaLauncher\lib
rmdir /q /s wxLuaLauncher\include
mkdir wxLuaLauncher\lib
mkdir wxLuaLauncher\include

%_PSC% Copy-Item -Path "%TKVAR_LUAJIT_DIST_DIR%\lib\*" -Recurse -Force -Destination "wxLuaLauncher\lib"
%_PSC% Copy-Item -Path "%TKVAR_LUAJIT_DIST_DIR%\include\*" -Recurse -Force -Destination "wxLuaLauncher\include"
%_PSC% Copy-Item -Path "%TKVAR_WX_INC_DIR%\*" -Recurse -Force -Destination "wxLuaLauncher\include"

cmake %CMAKE_GENERATOR_PARAM% -DWXLIB_ARCH=winx64 -DCMAKE_INSTALL_PREFIX="%TKVAR_LAUNCHER_DIST_DIR%" -S wxLuaLauncher -B "%TKVAR_BUILD_DIR%"

cmake --build "%TKVAR_BUILD_DIR%" --config "Release"
cmake --install "%TKVAR_BUILD_DIR%" --config "Release"
@REM devenv %TKVAR_BUILD_DIR%\WinDeskLauncher.sln /Build "MinSizeRel|Win32"

%_PSC% Copy-Item -Path "%TKVAR_BUILD_DIR%\*.exe" -Recurse -Force -Destination "%TKVAR_LAUNCHER_DIST_DIR%"
%_PSC% Copy-Item -Path "%TKVAR_LUAJIT_DIST_DIR%\lib\*.dll" -Recurse -Force -Destination "%TKVAR_LAUNCHER_DIST_DIR%"
%_PSC% Copy-Item -Path "%TKVAR_WX_DLL_DIR%\*.dll" -Recurse -Force -Destination "%TKVAR_LAUNCHER_DIST_DIR%"
%_PSC% Copy-Item -Path "%TKVAR_WXLUA_DLL_DIR%\wx.dll" -Recurse -Force -Destination "%TKVAR_LAUNCHER_DIST_DIR%"
%_PSC% Copy-Item -Path "%TK_Lua_App_Dir%" -Recurse -Force -Destination "%TKVAR_LAUNCHER_DIST_DIR%"

:__end
set TKVAR_BUILD_DIR=
set TKVAR_LUAJIT_DIST_DIR=
set TKVAR_LAUNCHER_DIST_DIR=
set TKVAR_WX_DLL_DIR=
set TKVAR_WXLUA_DLL_DIR=
