#!/usr/bin/env python3

import os
import re

import sys
"""
    if sys.version_info.major == 3:
        print('Python3')
        user_input = input("fnode[1-32]: ")
    else:
        print('Python2')
        user_input = raw_input("fnode[1-32]: ")
    int(re.sub("\\D", "", user_input))
"""

# Python3
NODES = [5, 6]

JSONDIR='/home/kashino/log/2020-04/SMI_v19_4/SMI/microbenchmarks/kernels/'
HOSTFILE='./hostfile'
RANKFILE='./rankfile'
p2p_microbenchmark= ['bw_eager_dev', 'bandwidth', 'latency', 'injection_rate']
collective_microbenchmark=['broadcast', 'gather', 'reduce', 'scatter']


fpga2_templete_collective_str='''{{
    "fpgas": {{
      "ppx2-{0[0]:02}:acl0": "{1}",
      "ppx2-{0[1]:02}:acl0": "{1}"
    }},
    "connections": {{
      "ppx2-{0[0]:02}:acl0:ch0": "ppx2-{0[1]:02}:acl0:ch1"
    }}
  }}
'''

fpga2_templete_p2p_str='''{{
    "fpgas": {{
      "ppx2-{0[0]:02}:acl0": "{1}_0",
      "ppx2-{0[1]:02}:acl0": "{1}_1"
    }},
    "connections": {{
      "ppx2-{0[0]:02}:acl0:ch0": "ppx2-{0[1]:02}:acl0:ch1"
    }}
  }}
'''

def generate_collective_json():
    for i in collective_microbenchmark:
        filepath=JSONDIR + i + '.json'
        print(filepath)
        with open(filepath,'w') as f:
            f.write(fpga2_templete_collective_str.format(NODES, i))

#        with open(filepath,'r') as f:
#            for row in f:
#                print(row.strip())

def generate_p2p_json():
    for i in p2p_microbenchmark:
        filepath=JSONDIR + i + '.json'
        print(filepath)
        with open(filepath,'w') as f:
            f.write(fpga2_templete_p2p_str.format(NODES, i))

#        with open(filepath,'r') as f:
#            for row in f:
#                print(row.strip())

def generate_hostfile():
    with open(HOSTFILE,'w') as f:
        for i in NODES:
            f.write("ppx2-{:02} slots=1\n".format(i) )

def generate_rankfile():
    with open(RANKFILE,'w') as f:
        rank = 0;
        for i in NODES:
            f.write("rank "+str(rank)+"=ppx2-{:02} slot=0:0\n".format(i) )
            rank+=1

if __name__ == "__main__":
    generate_rankfile()
    generate_hostfile()
    generate_collective_json()
    generate_p2p_json()

