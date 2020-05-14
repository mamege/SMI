#!/bin/sh 

SMI_ROOT="$(dirname $0)/../../../SMI"

echo "Edit ${SMI_ROOT}/CMakeLists.txt for ppx"
sed -i -e "s|p520_max_sg280l|p520_max_sg280h|g" ${SMI_ROOT}/CMakeLists.txt 2> /dev/null
# revert: sed -i -e "s|p520_max_sg280h|p520_max_sg280l|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "p520_max_sg280h" \
&& echo -e "\e[32;1m p520_max_sg280h Found . OK. \e[m " \
|| echo -e "\e[31;1m p520_max_sg280h Not Found.\e[m  Edit your CMakeLists.txt"

sed -i -e "s\
|add_dependencies(\${KERNEL_TARGET} rewriter)\
|add_dependencies(\${KERNEL_TARGET} rewriter GENERATE_PPX_JSON)\
|g" ${SMI_ROOT}/CMakeLists.txt 
# revert: sed -i -e "s| GENERATE_PPX_JSON)|)|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "GENERATE_PPX_JSON" \
&& echo -e "\e[32;1m GENERATE_PPX_JSON Found . OK. \e[m " \
|| echo -e "\e[31;1m GENERATE_PPX_JSON Not Found.\e[m  Edit your CMakeLists.txt"


sed -i -e '$ a add_subdirectory(custom_parts/ppx)' ${SMI_ROOT}/CMakeLists.txt 2>/dev/null
# revert: sed -i -e /'custom_parts\/ppx)'/d ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
cat ${SMI_ROOT}/CMakeLists.txt | grep "custom_parts/ppx" \
&& echo -e "\e[32;1m custom_parts/ppx Found . OK. \e[m " \
|| echo -e "\e[31;1m custom_parts/ppx Not Found.\e[m  Edit your CMakeLists.txt"



echo "Edit ${SMI_ROOT}/microbenchmarks/host/* for ppx"
sed -i -e "s|fpga = rank % 2|fpga = rank % 1|g" ${SMI_ROOT}/microbenchmarks/host/*.cpp
# revert: sed -i -e "s|fpga = rank % 2|fpga = rank % 1|g" ${SMI_ROOT}/microbenchmarks/host/*.cpp
cat ${SMI_ROOT}/microbenchmarks/host/*.cpp | grep "fpga = rank % 1" \
&& echo -e "\e[32;1m Num of FPGA = 1. OK. \e[m " \
|| echo -e "\e[31;1m Num of FPGA != 1. NG. \e[m  Edit your host program"
