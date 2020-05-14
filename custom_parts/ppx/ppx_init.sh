#!/bin/sh 

SMI_ROOT="$(dirname $0)/../../../SMI"


recept_name="GENERATE_PPX_\${TARGET_NAME}_JSON"
smi_host_src_files="\
$(find ${SMI_ROOT}/microbenchmarks/host/ -name "*.cpp") \
$(find ${SMI_ROOT}/custom_parts/my_benchmark/ -name "*.cpp") \
"

DELETE=${1:-"None"}
if [ $DELETE = "del" ]; then
    
    sed -i -e /'#ppx'/d ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
    sed -i -e "s|p520_max_sg280h|p520_max_sg280l|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
    sed -i -e "s| $recept_name)|)|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
    ls ${smi_host_src_files} | xargs sed -i -e "s|fpga = rank % 1|fpga = rank % 2|g" 
else 
    echo "Edit ${SMI_ROOT}/CMakeLists.txt for ppx"

    line_number=$(grep "endfunction()" ${SMI_ROOT}/CMakeLists.txt -n | head -n 1 | sed -e 's/[^0-9]//g') && echo $line_number
    TMPF='/tmp/tmp.tmp'
    cat << 'EOS' > $TMPF
set(ConfigF_GENERATOR ${CMAKE_CURRENT_SOURCE_DIR}/../configFgen/configFilegen_main.py) #ppx
#set(ConfigF_GENERATOR /home/kashino/log/2020-05/GitAction_sample/python/configFilegen_main.py) #ppx
add_custom_target(GENERATE_PPX_${TARGET_NAME}_JSON #ppx
        COMMAND python #ppx
            ${ConfigF_GENERATOR} #ppx
            codegen-json #ppx
            -t ${TARGET_NAME} #ppx
            -o ${CONNECTION_FILE} #ppx 
        WORKING_DIRECTORY ${WORKDIR} #ppx
)  #ppx  
add_custom_target(GENERATE_PPX_${TARGET_NAME}_EXEC #ppx
        COMMAND python3 #ppx
            ${ConfigF_GENERATOR} #ppx
            codegen-exec-script #ppx
            -t ${TARGET_NAME} #ppx
            -o ${WORKDIR} #ppx 
        WORKING_DIRECTORY ${WORKDIR} #ppx
)  #ppx
add_custom_target(exec_${TARGET_NAME} #ppx
        COMMAND cd ${WORKDIR} #ppx
        COMMAND echo "== execute script" #ppx
        COMMAND echo "@"`pwd`"/${TARGET_NAME}.sh " #ppx
        COMMAND ./${TARGET_NAME}.sh #ppx
        WORKING_DIRECTORY ${WORKDIR} #ppx
)  #ppx
add_dependencies(exec_${TARGET_NAME} GENERATE_PPX_${TARGET_NAME}_EXEC ${TARGET_NAME}_host) #ppx
EOS
    sed -i -e "$((line_number-1))r ${TMPF}" ${SMI_ROOT}/CMakeLists.txt && echo "add commands" || echo "failed"
  
    sed -i -e "s|p520_max_sg280l|p520_max_sg280h|g" ${SMI_ROOT}/CMakeLists.txt 2> /dev/null
    # revert: sed -i -e "s|p520_max_sg280h|p520_max_sg280l|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .
    
    sed -i -e "s\
|add_dependencies(\${KERNEL_TARGET} rewriter)\
|add_dependencies(\${KERNEL_TARGET} rewriter $recept_name)\
|g" ${SMI_ROOT}/CMakeLists.txt 
    # revert: sed -i -e "s| $recept_name)|)|g" ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .

    sed -i -e '$ a add_subdirectory(custom_parts/ppx) #ppx' ${SMI_ROOT}/CMakeLists.txt 2>/dev/null
    # revert: sed -i -e /'custom_parts\/ppx)'/d ${SMI_ROOT}/CMakeLists.txt # or @SMI$ git checkout .

    echo "Edit ${SMI_ROOT}/microbenchmarks/host/* for ppx"
    ls ${smi_host_src_files} | xargs sed -i -e "s|fpga = rank % 2|fpga = rank % 1|g" 
    # revert: sed -i -e "s|fpga = rank % 2|fpga = rank % 1|g" ${SMI_ROOT}/microbenchmarks/host/*.cpp
fi


cat ${SMI_ROOT}/CMakeLists.txt | grep "p520_max_sg280h" \
&& echo -e "\e[32;1m p520_max_sg280h Found. OK. \e[m " \
|| echo -e "\e[31;1m p520_max_sg280h Not Found.\e[m  Original CMakeLists.txt"

cat ${SMI_ROOT}/CMakeLists.txt | grep "$recept_name" \
&& echo -e "\e[32;1m $recept_name Found. OK. \e[m " \
|| echo -e "\e[31;1m $recept_name Not Found.\e[m  Original CMakeLists.txt"

cat ${SMI_ROOT}/CMakeLists.txt | grep "custom_parts/ppx" \
&& echo -e "\e[32;1m custom_parts/ppx Found. OK. \e[m " \
|| echo -e "\e[31;1m custom_parts/ppx Not Found.\e[m  Original CMakeLists.txt"

cat ${smi_host_src_files} | grep "fpga = rank % 1" \
&& echo -e "\e[32;1m Num of FPGA = 1. OK. \e[m " \
|| echo -e "\e[31;1m Num of FPGA != 1. \e[m  Original host program"
