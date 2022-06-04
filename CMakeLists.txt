cmake_minimum_required(VERSION 3.16)

project("cmake-protobuf")

message("** CMAKE_RUNTIME_OUTPUT_DIRECTORY:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# protobuf导出protobuf_BIN变量可以在当前scope及子scope访问
add_subdirectory(third_party/protobuf)

add_subdirectory(src/http-test)