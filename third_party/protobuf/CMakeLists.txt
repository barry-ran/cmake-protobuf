cmake_minimum_required(VERSION 3.16)

# 下载并解压protobuf
include(FetchContent)
FetchContent_Declare(
  protobuf
  URL https://github.com/barry-ran/cmake-protobuf/releases/download/v21.1/protobuf-v21.1-win-x86.zip
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/protobuf
)
FetchContent_MakeAvailable(protobuf)

message("** protobuf:FetchContent:SOURCE_DIR:${protobuf_SOURCE_DIR}")

# 导入protobuf
# GLOBAL 指定protobuf全局可见，否则只有当前CMakeLists.txt和下级CMakeLists.txt可以引用protobuf，上面引用不到protobuf
add_library(protobuf SHARED IMPORTED GLOBAL)
set_target_properties(protobuf PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${protobuf_SOURCE_DIR}/include
  IMPORTED_LOCATION ${protobuf_SOURCE_DIR}/bin/libprotobuf.dll
  IMPORTED_IMPLIB  ${protobuf_SOURCE_DIR}/lib/libprotobuf.lib
)

# PARENT_SCOPE 上级可访问的变量
set(protobuf_BIN ${protobuf_SOURCE_DIR}/bin/libprotobuf.dll PARENT_SCOPE)