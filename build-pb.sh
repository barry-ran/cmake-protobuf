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

SHARED_LIBS=OFF
if [[ $1 != "Shared" && $1 != "Static" ]]; then
    echo "error: unkonow build mode -- $1, use default Static"
fi
if [[ $1 == "Shared" ]]; then
    SHARED_LIBS=ON
fi
if [[ $1 == "Static" ]]; then
    SHARED_LIBS=OFF
fi

uname

# 定义平台变量
case "$(uname)" in
"Darwin")
  OS="mac"
  ARCH="x64"
  ;;

"MINGW"*|"MSYS_NT"*)
  OS="win"
  ARCH="x86"
  ;;
*)
  echo "Unknown OS"
  exit 1
  ;;
esac

PB_VERSION="v21.1"
PB_REP_PATH="$script_path/protobuf"
PB_INSTALL_PATH="$script_path/install/protobuf"
PB_BUILD_PATH="$script_path/build"
INSTALL_NAME="protobuf-$PB_VERSION-$OS-$ARCH-$1.zip"

if [ ! -d "protobuf" ]; then
  git clone -b $PB_VERSION https://github.com/protocolbuffers/protobuf.git
  pushd "protobuf"
    git submodule update --init --recursive
  popd
fi

rm -rf $PB_BUILD_PATH
mkdir $PB_BUILD_PATH

pushd "${PB_BUILD_PATH}"

case "$(uname)" in
"Darwin")
  cmake -G "Xcode" -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_UNICODE=ON \
    -DBUILD_SHARED_LIBS=${SHARED_LIBS} \
    -DCMAKE_INSTALL_PREFIX=${PB_INSTALL_PATH} \
    ${PB_REP_PATH}
  ;;

"MINGW"*|"MSYS_NT"*)
  cmake -G "Visual Studio 16 2019" -A Win32 -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_UNICODE=ON \
    -Dprotobuf_MSVC_STATIC_RUNTIME=OFF \
    -DBUILD_SHARED_LIBS=${SHARED_LIBS} \
    -DCMAKE_INSTALL_PREFIX=${PB_INSTALL_PATH} \
    ${PB_REP_PATH}
  ;;

*)
  echo "Unknown OS"
  exit 1
  ;;
esac

cmake_build() {
  cmake --build . --config ${1} --target install
}

cmake_build Debug
cmake_build Release

popd

7z a ./$INSTALL_NAME ./install/*
echo "${INSTALL_NAME}" > INSTALL_NAME