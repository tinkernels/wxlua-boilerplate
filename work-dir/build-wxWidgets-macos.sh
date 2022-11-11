#!/usr/bin/env bash

# shellcheck disable=SC2296
# ---------------- GET SELF PATH ----------------
ORIGINAL_PWD_GETSELFPATHVAR=$(pwd)
if test -n "$BASH"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${BASH_SOURCE[0]}
elif test -n "$ZSH_NAME"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${(%):-%x}
elif test -n "$KSH_VERSION"; then SH_FILE_RUN_PATH_GETSELFPATHVAR=${.sh.file}
else SH_FILE_RUN_PATH_GETSELFPATHVAR=$(lsof -p $$ -Fn0 | tr -d '\0' | grep "${0##*/}" | tail -1 | sed 's/^[^\/]*//g')
fi
cd "$(dirname "$SH_FILE_RUN_PATH_GETSELFPATHVAR")" || return 1
SH_FILE_RUN_BASENAME_GETSELFPATHVAR=$(basename "$SH_FILE_RUN_PATH_GETSELFPATHVAR")
while [ -L "$SH_FILE_RUN_BASENAME_GETSELFPATHVAR" ]; do
    SH_FILE_REAL_PATH_GETSELFPATHVAR=$(readlink "$SH_FILE_RUN_BASENAME_GETSELFPATHVAR")
    cd "$(dirname "$SH_FILE_REAL_PATH_GETSELFPATHVAR")" || return 1
    SH_FILE_RUN_BASENAME_GETSELFPATHVAR=$(basename "$SH_FILE_REAL_PATH_GETSELFPATHVAR")
done
SH_SELF_PATH_DIR_RESULT=$(pwd -P)
SH_FILE_REAL_PATH_GETSELFPATHVAR=$SH_SELF_PATH_DIR_RESULT/$SH_FILE_RUN_BASENAME_GETSELFPATHVAR
cd "$ORIGINAL_PWD_GETSELFPATHVAR" || return 1
unset ORIGINAL_PWD_GETSELFPATHVAR SH_FILE_RUN_PATH_GETSELFPATHVAR SH_FILE_RUN_BASENAME_GETSELFPATHVAR SH_FILE_REAL_PATH_GETSELFPATHVAR
# ---------------- GET SELF PATH ----------------
# USE $SH_SELF_PATH_DIR_RESULT BEBLOW

mkdir "$SH_SELF_PATH_DIR_RESULT/build-wxWidgets"
cd "$SH_SELF_PATH_DIR_RESULT/build-wxWidgets" || exit
TK_CUSTOM_BUILD_DIR=$(pwd -P)
echo "TK_CUSTOM_BUILD_DIR: $TK_CUSTOM_BUILD_DIR"

TK_CUSTOM_CONFIGURE_OPTS=(--with-cocoa)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-unicode)
TK_CUSTOM_CONFIGURE_OPTS+=(--disable-shared)
# TK_CUSTOM_CONFIGURE_OPTS+=(--disable-shared=no)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-shared)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-optimise)
# TK_CUSTOM_CONFIGURE_OPTS+=(--disable-optimise)
# TK_CUSTOM_CONFIGURE_OPTS+=(--with-dmalloc)
TK_CUSTOM_CONFIGURE_OPTS+=(--without-dmalloc)
TK_CUSTOM_CONFIGURE_OPTS+=(--disable-profile)
TK_CUSTOM_CONFIGURE_OPTS+=(--disable-sys-libs)
TK_CUSTOM_CONFIGURE_OPTS+=(--disable-debug-info)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-debug)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-debug_flag)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-debug_info)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-debug_gdb)
# TK_CUSTOM_CONFIGURE_OPTS+=(--enable-debug_cntxt)
TK_CUSTOM_CONFIGURE_OPTS+=(--with-opengl)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-sound)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-mediactrl)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-graphics_ctx)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-controls)
TK_CUSTOM_CONFIGURE_OPTS+=(--enable-dataviewctrl)

echo "TK_CUSTOM_CONFIGURE_OPTS: ${TK_CUSTOM_CONFIGURE_OPTS[*]}"

cd "$TK_CUSTOM_BUILD_DIR" || exit

COMMON_FLAGS="-Os"
export CFLAGS="${COMMON_FLAGS}"
export CXXFLAGS="${COMMON_FLAGS}"
export CPPFLAGS="${COMMON_FLAGS}"

../wxWidgets-src/configure  "${TK_CUSTOM_CONFIGURE_OPTS[@]}" 2>&1 | tee configure-macos2ud.log

echo -n "press enter to continue: "; read -r

make -j9

echo -en '\a'