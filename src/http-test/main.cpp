#include <iostream>

#include "google/protobuf/util/time_util.h"
using namespace google::protobuf::util;

int main() {
    std::cout << "hello pb:" << TimeUtil::ToString(TimeUtil::GetCurrentTime()) << std::endl;
    getchar();
    return 0;
}