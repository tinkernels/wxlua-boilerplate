# CMakeList.txt : CMake project for WinDeskLauncher, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.8)

project ("WinDeskLauncher")

include_directories(include)
link_directories(lib)

# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:WINDOWS")

include(VersionInfo.cmake)
# Add source to this project's executable.
add_executable (WinDeskLauncher WIN32 WinDeskLauncher.cpp WinDeskLauncher.h WinDeskLauncher.rc ${APP_VERSION_RC_FILE})
target_link_libraries(WinDeskLauncher lua51 luajit)
add_custom_command(TARGET WinDeskLauncher POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:WinDeskLauncher> ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/lib/lua51.dll ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}
)