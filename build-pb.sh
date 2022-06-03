# 编译脚本参考 https://github.com/google/gfbuild-angle/blob/master/build.sh
# win编译参考 https://github.com/protocolbuffers/protobuf/blob/main/cmake/README.md
# mac编译参考 https://github.com/protocolbuffers/protobuf/blob/main/src/README.md

# 所有执行的命令都打印到终端
set -x
# 如果执行过程中有非0退出状态，则立即退出
set -e
# 引用未定义变量则立即退出
set -u

help | head

{
cd $(dirname "$0")
script_path=$(pwd)
cd -
} &> /dev/null # disable output

uname

PB_REP_PATH="$script_path/protobuf"
PB_INSTALL_PATH="$script_path/install/protobuf"
PB_BUILD_PATH="$script_path/build"

rm -rf $PB_BUILD_PATH
mkdir $PB_BUILD_PATH

git clone -b v21.1 https://github.com/protocolbuffers/protobuf.git
pushd "protobuf"
git submodule update --init --recursive
popd

pushd "${PB_BUILD_PATH}"

case "$(uname)" in
"Darwin")
  cmake -G "Xcode" -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_UNICODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PB_INSTALL_PATH} \
    ${PB_REP_PATH}
  ;;

"MINGW"*|"MSYS_NT"*)
  cmake -G "Visual Studio 16 2019" -A Win32 -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_UNICODE=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PB_INSTALL_PATH} \
    ${PB_REP_PATH}
  ;;

*)
  echo "Unknown OS"
  exit 1
  ;;
esac

cmake --build . --config Release --target install
popd