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

rm -rf ./build
mkdir build

pushd build

case "$(uname)" in
"Darwin")
  cmake -G "Xcode" ..
  cmake --build .
  ;;

"MINGW"*|"MSYS_NT"*)
  cmake -G "Visual Studio 16 2019" -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${script_path}/output -A Win32 ..
  cmake --build .
  ;;
*)
  echo "Unknown OS"
  exit 1
  ;;
esac

popd