cmake_minimum_required(VERSION 3.16)

# 下载并解压protobuf
#（不想下载的话也可以删除FetchContent相关，然后使用子仓库管理protobuf或者直接将protobuf二进制添加到git中管理）
# FetchContent_Declare不支持生成器表达式，所以protobuf_url不能用生成器表达式赋值，例如set(protobuf_url $<$<PLATFORM_ID:Windows>:http://...>)
# 生成器表达式不能代替if，生成器表达式只能放在支持生成器表达式的函数中中使用
if(WIN32)
  set(protobuf_url "https://github.com/barry-ran/cmake-protobuf/releases/download/v21.1/protobuf-v21.1-win-x86-Shared.zip")
elseif(APPLE)
  set(protobuf_url "https://github.com/barry-ran/cmake-protobuf/releases/download/v21.1/protobuf-v21.1-mac-x64-Shared.zip")
endif()

message("** protobuf_url:${protobuf_url}")

include(FetchContent)
FetchContent_Declare(
  protobuf
  URL ${protobuf_url}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/protobuf
)
FetchContent_MakeAvailable(protobuf)

message("** protobuf:FetchContent:SOURCE_DIR:${protobuf_SOURCE_DIR}")

# 导入protobuf
# GLOBAL 指定protobuf全局可见，否则只有当前CMakeLists.txt和下级CMakeLists.txt可以引用protobuf，上面引用不到protobuf
if(WIN32)
  add_library(protobuf SHARED IMPORTED GLOBAL)
  set_target_properties(protobuf PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${protobuf_SOURCE_DIR}/include
    IMPORTED_LOCATION ${protobuf_SOURCE_DIR}/bin/libprotobuf.dll
    IMPORTED_LOCATION_DEBUG ${protobuf_SOURCE_DIR}/bin/libprotobufd.dll
    IMPORTED_IMPLIB  ${protobuf_SOURCE_DIR}/lib/libprotobuf.lib
    IMPORTED_IMPLIB_DEBUG  ${protobuf_SOURCE_DIR}/lib/libprotobufd.lib
    IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
  )

  # PARENT_SCOPE 上级可访问的变量
  # protobuf_BIN使用了生成器表达式，使用message打印出来是表达式原样，因为message不支持生成器表达式
  # 但是protobuf_BIN放到add_custom_command中会计算出生成器表达式的值，因为add_custom_command支持生成器表达式
  # 生成器表达式只能放在支持生成器表达式的函数中中使用
  set(protobuf_BIN ${protobuf_SOURCE_DIR}/bin/$<$<CONFIG:Debug>:libprotobufd.dll>$<$<CONFIG:Release>:libprotobuf.dll> PARENT_SCOPE)

elseif(APPLE)
  add_library(protobuf SHARED IMPORTED GLOBAL)
  set_target_properties(protobuf PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${protobuf_SOURCE_DIR}/include
    IMPORTED_LOCATION ${protobuf_SOURCE_DIR}/lib/libprotobuf.3.21.1.0.dylib
    IMPORTED_LOCATION_DEBUG ${protobuf_SOURCE_DIR}/lib/libprotobufd.3.21.1.0.dylib
    IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
  )

  # PARENT_SCOPE 上级可访问的变量
  set(protobuf_BIN ${protobuf_SOURCE_DIR}/lib/$<$<CONFIG:Debug>:libprotobufd.3.21.1.0.dylib>$<$<CONFIG:Release>:libprotobuf.3.21.1.0.dylib> PARENT_SCOPE)

endif()