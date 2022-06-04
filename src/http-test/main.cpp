#include <iostream>

#include "./protobuf/cpp/test.pb.h"
#include "google/protobuf/util/time_util.h"
using namespace google::protobuf::util;

int main() {
    std::cout << "hello pb:" << TimeUtil::ToString(TimeUtil::GetCurrentTime()) << std::endl;

    SearchRequest req;
    req.set_query("test query");
    req.set_page_number(2);
    req.set_result_per_page(10);

    std::string data = req.SerializeAsString();

    getchar();
    return 0;
}