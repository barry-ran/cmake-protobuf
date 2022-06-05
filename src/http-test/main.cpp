#include <iostream>

#include "./protobuf/cpp/test.pb.h"
#include "google/protobuf/util/time_util.h"
using namespace google::protobuf::util;
using namespace google::protobuf;

#include "httplib.h"

int main(int argc, char *argv[]) {
    if (2 > argc) {
        std::cout << "need a param: c/s" << std::endl; 
    }
    
    bool server = true;
    std::string type = argv[1];
    if (type == "c") {
        server = false;
    } else {
        server = true;
    }
    std::cout << "http-test:" << TimeUtil::ToString(TimeUtil::GetCurrentTime()) << std::endl;

    if (server) {
        httplib::Server svr;
        svr.Post("/search", [](const httplib::Request &req, httplib::Response &res) {
            std::cout << "server: recv SearchRequest length:" << req.body.length() << std::endl;

            SearchRequest searchReq; 
            searchReq.ParseFromString(req.body);
            std::cout << "server recv query: " << searchReq.query() << std::endl;
            std::cout << "server: recv page number:" << searchReq.page_number() << std::endl;
            std::cout << "server: recv result per page:" << searchReq.result_per_page() << std::endl;

            SearchResponse searchRsp;
            searchRsp.set_code(1);
            auto result = searchRsp.add_results();
            *result = "result1";
            result = searchRsp.add_results();
            *result = "result2";
            res.set_content(searchRsp.SerializeAsString(), "application/x-protobuf");
        });

        svr.Post("/any", [](const httplib::Request &req, httplib::Response &res) {
            std::cout << "server: recv AnyRequest length:" << req.body.length() << std::endl;
            AnyRequest anyRequest;
            anyRequest.ParseFromString(req.body);
            std::cout << "server: recv data type:" << anyRequest.data_type() << std::endl;

            switch (anyRequest.data_type())
            {
            case AnyRequest_DataType_DATATYPE_A:
            {
                // data_type不是必须的，any内部有唯一url来判断类型
                std::cout << "server: recv is da:" << anyRequest.data().Is<DataA>() << std::endl;
                DataA da;
                anyRequest.data().UnpackTo(&da);
                std::cout << "server: recv da:" << da.name() << std::endl;
            }
                break;
            case AnyRequest_DataType_DATATYPE_B:
            {
                // data_type不是必须的，any内部有唯一url来判断类型
                // anyRequest.data().Is<DataA>();
                DataB db;
                anyRequest.data().UnpackTo(&db);
            }
            default:
                break;
            }

            AnyResponse anyResponse;
            anyResponse.set_code(11);
            res.set_content(anyResponse.SerializeAsString(), "application/x-protobuf");

        });

        std::cout << "server listen 8080..." << std::endl;
        svr.listen("0.0.0.0", 8080);
    } else {
        httplib::Client cli("http://127.0.0.1:8080");

        std::cout << "client: **************SearchRequest**************" << std::endl;
        SearchRequest req;
        req.set_query("test query");
        req.set_page_number(2);
        req.set_result_per_page(10);
        std::string data = req.SerializeAsString();

        std::cout << "client: send SearchRequest length:" << data.length() << std::endl;

        httplib::Headers headers = {
            { "Accept-Encoding", "identity" }
        };
        auto res = cli.Post("/search", headers, data.c_str(), data.length(), "application/x-protobuf");
        std::cout << "client: recv:" << res->status << std::endl;

        SearchResponse searchRsp;
        searchRsp.ParseFromString(res->body);
        std::cout << "client: " << searchRsp.code() << std::endl;
        for (int i=0; i<searchRsp.results_size(); i++) {
            auto result = searchRsp.results(i);
            std::cout << "client: " << result << std::endl;
        }

        std::cout << "client: **************AnyRequest**************" << std::endl;
        AnyRequest anyRequest;
        anyRequest.set_data_type(AnyRequest_DataType_DATATYPE_A);
        DataA da;
        da.set_name("dataa");
        anyRequest.mutable_data()->PackFrom(da);
        data = anyRequest.SerializeAsString();
        
        std::cout << "client: send AnyRequest length:" << data.length() << std::endl;

        res = cli.Post("/any", headers, data.c_str(), data.length(), "application/x-protobuf");
        std::cout << "client: recv status:" << res->status << std::endl;

        AnyResponse anyResponse;
        anyResponse.ParseFromString(res->body);
        std::cout << "client: recv code:" << anyResponse.code() << std::endl;
        getchar();
    }
    
    return 0;
}