cmake_minimum_required(VERSION 3.16)

# 项目名称
set(PROJECT_NAME "http-test")

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} protobuf)

message("** protobuf_BIN:${protobuf_BIN}")
# 复制protoobuf动态库到http-test的生成目录中
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${protobuf_BIN} $<TARGET_FILE_DIR:${PROJECT_NAME}>
)