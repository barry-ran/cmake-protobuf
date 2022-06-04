# cmake-protobuf

执行`./build.sh Debug`即可编译示例

只有更新proto文件以后才需要重新生成，示例如下：
```
.\third_party\protobuf\protobuf\bin\protoc.exe --proto_path=./src/http-test/protobuf/proto --cpp_out=./src/http-test/protobuf/cpp test.proto api.proto
```
# protobuf协议定义说明
- service：是定义RPC接口用的，一般使用http协议通信时会用，定义了service后，protoc会生成为服务端和客户端生成相关中间层代码，方便基于自己的协议接入RPC。木器在proto3中标记为已弃用
- extensions：预留序号，方便后期扩展message
- oneof和any：都类似C++中的union，any更通用，支持任意类型，代码中读写稍微复杂一些，oneof简单些，但是oneof中不能有repeated和map
- http：不存在粘包概念，所以可以直接发送message序列化数据，对端收到直接反序列化，由于是短连接，一般message就是req&rsp成对存在，不同的message很好区分
- websocket：不存在粘包概念（websocket虽是长连接，但是协议本身已处理粘包），对端收到直接反序列化，由于是长连接，不同的message可以区分吗？
- tcp：存在粘包问题，所以需要自己定义包头，在包体中存放message序列化数据，例如
    ```
    固定格式包头+Length(2B)+ flag(1B) + cmd(2B) + subcmd(2B) + message序列化数据
    ```
    其中message序列化数据对应的message中会有一个oneof/any字段，根据cmd和subcmd定位到具体message
