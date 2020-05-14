#!/bin/sh 

SMI_ROOT="$(dirname $0)/../../../SMI"

sed -i -e "s|p520_max_sg280h|p520_max_sg280l|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "p520_max_sg280h" \
&& echo -e "\e[32;1m p520_max_sg280h Found . NG. \e[m " \
|| echo -e "\e[31;1m p520_max_sg280h Not Found.\e[m  Original CMakeLists.txt"

sed -i -e "s| GENERATE_PPX_JSON)|)|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "GENERATE_PPX_JSON" \
&& echo -e "\e[32;1m GENERATE_PPX_JSON Found . NG. \e[m " \
|| echo -e "\e[31;1m GENERATE_PPX_JSON Not Found.\e[m  Original CMakeLists.txt"


sed -i -e /'custom_parts\/ppx)'/d ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "custom_parts/ppx" \
&& echo -e "\e[32;1m custom_parts/ppx Found . NG. \e[m " \
|| echo -e "\e[31;1m custom_parts/ppx Not Found.\e[m  Original CMakeLists.txt"


sed -i -e "s|fpga = rank % 1|fpga = rank % 2|g" ${SMI_ROOT}/microbenchmarks/host/*.cpp
cat ${SMI_ROOT}/microbenchmarks/host/*.cpp | grep "fpga = rank % 1" \
&& echo -e "\e[32;1m Num of FPGA = 1. NG. \e[m " \
|| echo -e "\e[31;1m Num of FPGA = 2.\e[m  Original host program"
