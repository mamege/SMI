#!/bin/sh 

CURRNT_DIR="$(dirname $0)"
${CURRNT_DIR}/ppx_init.sh 
MICROBENCH=bw_eager_dev ${CURRNT_DIR}/ppx_build.sh
${CURRNT_DIR}/ppx_uninit.sh
