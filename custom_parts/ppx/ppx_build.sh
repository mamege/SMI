#!/bin/bash

#######################################################
# * SMIにおけるmicrobenchmark/bandwidthのビルド実行方法(@ppx)#
#######################################################
: ${smi_quartus_version:="19.4"}
: ${TMP_SMI_PREFIX:="/home/kashino/log/2020-04/SMI_v19_4/"}
: ${TMP_SMI_BUILDDIR:="/home/kashino/log/2020-04/SMI_v19_4/build_rm_ok"}
: ${MICROBENCH:="bandwidth_eager"}

#---------- 環境設定 ----------
module purge; module use /home/kashino/modules;

case ${smi_quartus_version} in
    18.1 )
        module load quartus/18.1.1.263.p1 aocl/520n ;;
    19.1 ) 
        module load quartus/19.1.0.240 aocl/520n_191 ;;
    19.4 ) 
        module load quartus/19.4.0.64 aocl/520n_194 ;;
    *)
        module load quartus/19.4.0.64 aocl/520n_194 ;;
esac

module load cmake/3.15.0 gcc/4.8.5 openmpi/3.0.1 
module load llvm/8.0.0rtti python/3.8.2
module switch gcc/9.1.0
module list

mkdir -p ${TMP_SMI_BUILDDIR} && cd ${TMP_SMI_BUILDDIR} &&  echo "== TMP_SMI_BUILDDIR = ${PWD} =="

# [対策]/usr/bin/ld: -ltinfo が見つかりません
L="$HOME/local/ppxsvc_usr/lib:$HOME/local/ppxsvc_usr/lib64"
export LIBRARY_PATH="$L:$LIBRARY_PATH"
#---------- ビルド ----------
# /home/kashino/log/2020-04/SMI_v19_4/rm_CMakeRelated_fileAndDir.sh

rm ${TMP_SMI_BUILDDIR}/CMakeCache.txt
CC=gcc cmake ${TMP_SMI_PREFIX}/SMI
[ ! -f ./bin/activate ] && $(which python3) -m virtualenv . -p python3 && echo "== Set python virtualenvironment"
source ./bin/activate && echo "== python virtualENV activated "# 終了する時は　$ deactivate" =="
[ ! -d ./lib/python*/site-packages/click ] && pip3 install click jinja2 networkx bitstring



echo "== Start ${MICROBENCH} benchmark aocx build ...==" && pwd

srun -p syn2,syn3 -- make ${MICROBENCH}_${MICROBENCH}_0_aoc_build VERBOSE=1 & #1> $PWD/output.msg 2>&1
sleep 10
srun -p syn2,syn3 -- make ${MICROBENCH}_${MICROBENCH}_1_aoc_build VERBOSE=1 &

wait 

make ${MICROBENCH}_host VERBOSE=1
