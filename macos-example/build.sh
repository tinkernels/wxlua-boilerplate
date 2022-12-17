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

cd "$SH_SELF_PATH_DIR_RESULT" || exit

pushd luajit-dist/lib/lua/5.1 || exit
    for F in *; do
        Prefix_=${F:0:3}
        LibName_=""
        if [ "$Prefix_" = "lib" ];then
            TmpName_=${F:3}
            LibName_=${TmpName_%.*}
        else
            LibName_=${F%.*}
        fi
        NewName_="$LibName_.so"
        if [ "$NewName_" != "$F" ] && [ ! -f "$NewName_" ]; then
            ln -sfv "$F" "$NewName_"
        fi
    done
popd || exit

/usr/bin/env bash clean-xcproj.sh

PROJECT_FILE="xcode-project/wxlua-example.xcodeproj"
BUILD_SCHEME="wxlua-example"

Try_Pretty=$(which cat)
[ "$(which xcpretty 2>&1 >/dev/null; echo $?)" = "0" ] && Try_Pretty=$(which xcpretty)

#         CODE_SIGNING_REQUIRED=NO \
#         CODE_SIGN_IDENTITY="" \
xcodebuild clean build \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        -derivedDataPath "$(pwd)/xcode-DerivedData" \
        -project "$PROJECT_FILE" \
        -scheme "$BUILD_SCHEME" -configuration Release | "$Try_Pretty"
