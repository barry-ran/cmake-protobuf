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

if [[ $1 != "Debug" && $1 != "Release" ]]; then
    echo "error: unkonow build mode -- $1"
    exit 1
fi

uname

rm -rf ./build
mkdir build

pushd build

case "$(uname)" in
"Darwin")
  cmake -G "Xcode" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${script_path}/output ..
  cmake --build . --config ${1}
  ;;

"MINGW"*|"MSYS_NT"*)
  cmake -G "Visual Studio 16 2019" -A Win32 -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${script_path}/output ..
  cmake --build . --config ${1}
  ;;
*)
  echo "Unknown OS"
  exit 1
  ;;
esac

popd