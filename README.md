# cmake-protobuf

编译&运行：
```
# 编译
./build.sh Debug
# 执行http server
./output/Debug/http-test s
# 执行http client
./output/Debug/http-test c
```

只有更新proto文件以后才需要重新生成（编译多个proto的话只需要直接在最后追加proto文件即可），示例如下：
```
./third_party/protobuf/protobuf/bin/protoc.exe --proto_path=./src/http-test/protobuf/proto --cpp_out=./src/http-test/protobuf/cpp test.proto
```
# protobuf协议定义说明
- service：主要是服务端用来定义rpc接口的，同时服务端对外一定是要提供Restful接口，如果内部调用使用grpc，在某些情况下要同时对外提供相同功能的Restful接口，那么就要写两套API接口，这样就不仅降低了开发效率，也增加了调试的复杂度。于是就想着有没有一个转换机制，让Restful和gprc可以相互转化使grpc可以提供Restful接口能力，参考[这里](https://grpc.io/blog/coreos/)。（客户端不需要关心这个）
- extensions：预留序号，方便后期扩展message
- oneof和any：都类似C++中的union，any更通用，支持任意类型，且内部自带url，直接使用Is判断类型；oneof简单些，并且oneof中不能有repeated和map，一般需要配合额外type字段使用；除此之外，表示任意类型还可以用string，把string当作二进制容器使用，把目标message序列化以后，存入string，同样需要额外type字段配合才行。
- http：不存在粘包概念，所以可以直接发送message序列化数据，对端收到直接反序列化，由于是短连接，一般message就是req&rsp成对存在，并且和Restful接口唯一对于，所以不同的message很好区分（Restful接口只处理和自己对应的req&rsp）
- websocket：不存在粘包概念（websocket虽是长连接，但是协议本身已处理粘包），对端收到直接反序列化，由于是长连接，不同的message没法区分，所以需要message:type+any/oneof/string格式
- tcp：存在粘包问题，所以需要自己定义包头，在包体中存放message序列化数据，例如
    ```
    固定格式包头+Length(2B)+ flag(1B) + message序列化数据（type+any/oneof/string）
    ```
    其中message序列化数据中的type用来确定oneof/an/string message的具体类型
