# shared list
# https://docs.python.org/3/faq/programming.html#how-do-i-share-global-variables-across-modules
p2p_microbenchmark= ['bw_eager_dev', 'bandwidth', 'latency', 'injection_rate']
collective_microbenchmark=['broadcast', 'gather', 'reduce', 'scatter']


#--- generated_build_scirpt.py

templete_build_host_commad="numactl --cpunodebind=1 make {0}_host VERBOSE=1 -j"
templete_build_p2p_command="""\
srun -p syn2,syn3 -- make {0}_{1}_0_aoc_build VERBOSE=1 & #1> $PWD/output.msg 2>&1
sleep 1m
srun -p syn2,syn3 -- make {0}_{1}_1_aoc_build VERBOSE=1 &\
"""
templete_build_collective_command="""\
srun -p syn2,syn3 -- make {0}_{1}_aoc_build VERBOSE=1 &\
"""
available_modules = {
    "v18": "module load quartus/18.1.1.263.p1 aocl/520n"
    ,"v191": "module load quartus/19.1.0.240 aocl/520n_191"
    ,"v194": "module load quartus/19.4.0.64 aocl/520n_194"
}

default_smi_partition_at_ppx = [5, 6]
template_rankfile_ppx="rank {0}=ppx2-{1:02} slot=0:0\n"

templete_json_fpga2_p2p='''{{
    "fpgas": {{
      "ppx2-{0[0]:02}:acl0": "{1}_0",
      "ppx2-{0[1]:02}:acl0": "{1}_1"
    }},
    "connections": {{
      "ppx2-{0[0]:02}:acl0:ch0": "ppx2-{0[1]:02}:acl0:ch1"
    }}
  }}
'''
templete_json_fpga2_collective='''{{
    "fpgas": {{
      "ppx2-{0[0]:02}:acl0": "{1}",
      "ppx2-{0[1]:02}:acl0": "{1}"
    }},
    "connections": {{
      "ppx2-{0[0]:02}:acl0:ch0": "ppx2-{0[1]:02}:acl0:ch1"
    }}
  }}
'''
#--- generated_exec_scirpt.py


templete_exec_fpga2_ppx="""
salloc -p smi -N 2 \\
  -w ppx2-{0[0]:02} \\
  -w ppx2-{0[0]:02} \\
  -- mpirun  --mca orte_base_help_aggregate 0 --mca mpi_warn_on_fork 0 \\
  --rankfile ./rankfile -np 2 -display-map \\\
"""

templete_exec_bandwidth_argument="""\
-k ${val} \
"""
templete_exec_other_microbench_argument="""\
-n ${val} \
"""

