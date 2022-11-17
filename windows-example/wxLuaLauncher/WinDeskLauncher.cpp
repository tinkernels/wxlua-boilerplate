// WinDeskLauncher.cpp : Defines the entry point for the application.
//

#include "framework.h"
#include "WinDeskLauncher.h"

#include <fstream>
#include <shellapi.h>
#include <iostream>
#include <atlstr.h>
#include <direct.h>

#include "lua.hpp"

#define UNUSED(x) [&x] {}()
#define MAX_ARGC_I 1024
#define MAX_FPATH_LEN 2048

char currentWD[MAX_FPATH_LEN];
std::ofstream logfstream;

//  Write Log.
template <typename T>
void logBeforeExit(T logStr)
{
    if (!logfstream.is_open())
    {
        ensureLogDir();
        char logsDir_[MAX_FPATH_LEN];
        PathCombine(logsDir_, currentWD, "logs");
        char errLogFile_[MAX_FPATH_LEN];
        if (GetFileAttributes(logsDir_) == INVALID_FILE_ATTRIBUTES)
        {
            PathCombine(errLogFile_, currentWD, "error.log");
        }
        else
        {
            PathCombine(errLogFile_, logsDir_, "error.log");
        }
        logfstream.open(errLogFile_, std::ios::app);
    }
    logfstream << currentDateTime() << " " << logStr << std::endl;
}

void ensureLogDir()
{
    char logsDir_[MAX_FPATH_LEN];
    PathCombine(logsDir_, currentWD, "logs");
    CreateDirectory(logsDir_, NULL);
}

// Write log to file before return.
#define ERRLOG_4EXIT(s) \
    logBeforeExit(s);   \
    logfstream.flush(); \
    logfstream.close();

// Get current date/time, format is YYYY-MM-DD.HH:mm:ss
const std::string currentDateTime()
{
    struct tm localTime_;
    time_t now_ = time(0);
    char buf_[80];
    localtime_s(&localTime_, &now_);
    // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
    // for more information about date/time format
    strftime(buf_, sizeof(buf_), "%Y-%m-%dT%X", &localTime_);
    return buf_;
}

std::string dirnameOf(const std::string &fname)
{
    size_t pos = fname.find_last_of("\\/");
    return (std::string::npos == pos)
               ? ""
               : fname.substr(0, pos);
}

static char *wchar2mbstr(const wchar_t *ws)
{
    // Convert the wchar_t string to a char* string. Record
    // the length of the original string and add 1 to it to
    // account for the terminating null character.
    size_t origsize_ = wcslen(ws) + 1;
    size_t convertedChars_ = 0;

    // Allocate two bytes in the multibyte output string for every wide
    // character in the input string (including a wide character
    // null). Because a multibyte character can be one or two bytes,
    // you should allot two bytes for each character. Having extra
    // space for the new string isn't an error, but having
    // insufficient space is a potential security problem.
    const size_t newsize_ = origsize_ * 2;
    // The new string will contain a converted copy of the original
    // string plus the type of string appended to it.
    char *nstring_ = new char[newsize_];

    // Put a copy of the converted string into nstring_
    wcstombs_s(&convertedChars_, nstring_, newsize_, ws, _TRUNCATE);
    return nstring_;
}

int APIENTRY wWinMain(
    _In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPWSTR lpCmdLine,
    _In_ int nCmdShow)
{
    UNREFERENCED_PARAMETER(hInstance);
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(nCmdShow);

    _getcwd(currentWD, MAX_FPATH_LEN);
    std::string exeFDir = "";

    // When NULL is passed to GetModuleHandle, the handle of the exe itself is returned
    HMODULE hModule_ = GetModuleHandle(NULL);
    if (hModule_ != NULL)
    {
        char fpath_[MAX_FPATH_LEN] = {0};
        // Use GetModuleFileName() with module handle to get the path
        GetModuleFileName(hModule_, fpath_, (sizeof(fpath_)));
        exeFDir = dirnameOf(fpath_);
        if (exeFDir.compare(currentWD) != 0)
        {
            _chdir(exeFDir.c_str());
            _getcwd(currentWD, MAX_FPATH_LEN);
            if (exeFDir.compare(currentWD) != 0)
            {
                ensureLogDir();
                ERRLOG_4EXIT("Error: chdir to " + exeFDir + " failed.")
                return 1;
            }
        }
    }
    else
    {
        ensureLogDir();
        ERRLOG_4EXIT("Module handle is NULL")
        return 1;
    }
    ensureLogDir();

    int exeArgc_ = 0;
    auto exeArgv_ = CommandLineToArgvW(lpCmdLine, &exeArgc_);

    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    char script[] = "lua-app\\main.lua";

    if (luaL_dofile(L, script) != LUA_OK)
    {
        auto errMsg_ = lua_tostring(L, -1);
        ERRLOG_4EXIT(errMsg_)
        return 1;
    }

    lua_pop(L, lua_gettop(L));
    lua_getglobal(L, "test");
    if (lua_isfunction(L, -1))
    {
        if (NULL != exeArgv_ || exeArgc_ > 1)
        {
            lua_newtable(L);

            for (int i = 0; i < exeArgc_; i++)
            {
                // const char* arg_ = wchar2mbstr(exeArgv_[i]);
                CW2A arg_(exeArgv_[i], CP_UTF8);
                lua_pushstring(L, arg_);
                lua_rawseti(L, -2, i + 1);
                // delete[] arg_;
            }
            if (lua_pcall(L, 1, 0, 0) != 0)
            {
                auto errMsg_ = lua_tostring(L, -1);
                ERRLOG_4EXIT(errMsg_)
                lua_close(L);
                return 1;
            }
        }
        else
        {
            if (lua_pcall(L, 0, 0, 0) != 0)
            {
                auto errMsg_ = lua_tostring(L, -1);
                ERRLOG_4EXIT(errMsg_)
                lua_close(L);
                return 1;
            }
        }
    }
    lua_close(L);
    return 0;
}