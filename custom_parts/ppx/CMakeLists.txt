
set(bw_eager_dev_dir ${CMAKE_CURRENT_SOURCE_DIR}/../my_benchmark/bw_eager_dev)
smi_target(bw_eager_dev 
  "${CMAKE_SOURCE_DIR}/microbenchmarks/kernels/bw_eager_dev.json" 
  "${bw_eager_dev_dir}/bw_eager_dev_host.cpp" 
  "${bw_eager_dev_dir}/bw_eager_dev_0.cl;${bw_eager_dev_dir}/bw_eager_dev_1.cl" 
  8 8 8 OFF)



# set(PPX_JSON_GENERATOR ${CMAKE_CURRENT_SOURCE_DIR}/SMI_1NodeConfigFiles_generator.py)
# add_custom_target(GENERATE_PPX_JSON
#         COMMAND python 
#           ${PPX_JSON_GENERATOR}
#         WORKING_DIRECTORY ${WORKDIR}
# )
# set(EXEC_TARGET exec_${TARGET_NAME}) #ppx
# add_custom_target(${EXEC_TARGET} #ppx
#         COMMAND echo #ppx
#             ./${HOST_TARGET} #ppx
#         WORKING_DIRECTORY ${WORKDIR} #ppx
# ) #ppx
# add_dependencies(${EXEC_TARGET} ${HOST_TARGET}) #ppx