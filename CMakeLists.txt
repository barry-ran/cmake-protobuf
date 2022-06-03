cmake_minimum_required(VERSION 3.16)

project("cmake-protobuf")

add_subdirectory(third_party/protobuf)
add_subdirectory(src/http-test)

target_link_libraries(http-test protobuf)