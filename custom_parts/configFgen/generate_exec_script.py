#!/usr/bin/python3

#  https://jinja.palletsprojects.com/en/2.11.x/api/

import os, sys
import jinja2,logging

import config

def read_template_file(path):
    templates = os.path.join(os.path.dirname(__file__), "templates")
    loader = jinja2.FileSystemLoader(searchpath=templates)

    logging.basicConfig()
    logger = logging.getLogger('logger')
    logger = jinja2.make_logging_undefined(logger=logger, base=jinja2.Undefined)

    env = jinja2.Environment(loader=loader, undefined=logger)
    env.lstrip_blocks = True
    env.trim_blocks = True
    return env.get_template(path)


def generate_host_argument(target) -> str:
    if (target == "bandwidth_eager" or target == "bandwidth" or "bw_eager_dev"):
        generated_host_argument= config.templete_exec_bandwidth_argument
    elif ( (target in config.p2p_microbenchmark) or (target in config.collective_microbenchmark) ):
        generated_host_argument = config.templete_exec_other_microbench_argument
    else:
        sys.exit("There is no argument template corresponding to \n  target=\""+target+"\"\nin generate_build_aocx_commnad():"+__file__)
    return generated_host_argument
    
def generate_exec_command() -> str:
    generated_exec_command = config.templete_exec_fpga2_ppx.format(config.default_smi_partition_at_ppx)
    return generated_exec_command


def generate_exec_script(targetname, binary_path="None") -> str:
    print("executed")
    generated_exec_command=generate_exec_command()
    generated_host_argument=generate_host_argument(targetname)
    if (binary_path != None):
        generated_host_argument += ("-b \"" + binary_path +"\"\n")
    template = read_template_file("exec_script.template")
    return template.render(TARGET=targetname
                        ,SLURM_AND_MPI_COMMANDS=generated_exec_command
                        ,HOST_ARGUMENTS=generated_host_argument)