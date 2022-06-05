cmake_minimum_required(VERSION 3.16)

# 项目名称
set(PROJECT_NAME "http-test")

add_executable(${PROJECT_NAME} 
  main.cpp
  httplib.h
  protobuf/cpp/test.pb.h
  protobuf/cpp/test.pb.cc
)

# 动态库方式使用protobuf一定要将这个宏添加到预处理器，在代码中定义太晚了
target_compile_definitions(${PROJECT_NAME} PRIVATE PROTOBUF_USE_DLLS)

target_link_libraries(${PROJECT_NAME} protobuf)

message("** protobuf_BIN:${protobuf_BIN}")
# 复制protoobuf动态库到http-test的生成目录中
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${protobuf_BIN} $<TARGET_FILE_DIR:${PROJECT_NAME}>
)