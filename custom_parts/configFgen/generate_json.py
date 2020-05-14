#!/usr/bin/python3

#  https://jinja.palletsprojects.com/en/2.11.x/api/

import os, sys

import config


def generate_json(target):
    nodelist = config.default_smi_partition_at_ppx
    if (target == "bandwidth_eager"):
        generated_json = config.templete_json_fpga2_p2p.format(nodelist, "bandwidth")
    elif (target in config.p2p_microbenchmark):
        generated_json = config.templete_json_fpga2_p2p.format(nodelist, target)
    elif (target in config.collective_microbenchmark):
        generated_json = config.templete_json_fpga2_collective.format(nodelist, target)
    else:
        sys.exit("There is no json template corresponding to \n  target=\""+target+"\"\nin generate_build_aocx_commnad():"+__file__)
    return generated_json
