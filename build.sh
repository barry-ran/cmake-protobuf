# 所有执行的命令都打印到终端
set -x
# 如果执行过程中有非0退出状态，则立即退出
set -e
# 引用未定义变量则立即退出
set -u

help | head

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
  cmake -G "Visual Studio 16 2019" -A Win32 ..
  cmake --build .
  ;;
*)
  echo "Unknown OS"
  exit 1
  ;;
esac

popd