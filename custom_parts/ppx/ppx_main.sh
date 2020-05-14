#!/bin/sh 

CURRNT_DIR="$(dirname $0)"
${CURRNT_DIR}/ppx_init.sh del
${CURRNT_DIR}/ppx_init.sh 
# 1)ターゲット名, 2)ビルドcategory(host|aocx) 3)version 指定でビルドスクリプトを自動生成する．
/home/kashino/log/2020-05/GitAction_sample/python/configFilegen_main.py \
-- codegen-build-script \
--smi_path "/home/kashino/log/2020-04/SMI_v19_4/SMI" \
--smi_build_path "/home/kashino/log/2020-04/SMI_v19_4/build_rm_ok" \
-t bw_eager_dev -c host \
-o ${CURRNT_DIR}/ppx_build_gened.sh
chmod +x ${CURRNT_DIR}/ppx_build_gened.sh && $_ || ${CURRNT_DIR}/ppx_init.sh del

#${CURRNT_DIR}/ppx_init.sh del

return
./configFilegen_main.py codegen-exec-script \
-t bw_eager_dev \
-o /home/kashino/log/2020-04/SMI_v19_4/build_rm_ok/custom_parts/ppx/bw_eager_dev \
-b '/home/kashino/log/2020-04/SMI_v19_4/build_rm_ok/custom_parts/ppx/bw_eager_dev/bw_eager_dev_<rank>/bw_eager_dev_<rank>.aocx'