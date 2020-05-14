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


def generate_build_aocx_commnad(target):
    if (target == "bandwidth_eager"):
        generate_build_aocx_commnad = config.templete_build_p2p_command.format("bandwidth_eager", "bandwidth")
    elif (target in config.p2p_microbenchmark):
        generate_build_aocx_commnad = config.templete_build_p2p_command.format(target, target)
    elif (target in config.collective_microbenchmark):
        generate_build_aocx_commnad = config.templete_build_collective_command.format(target, target)
    else:
        sys.exit("There is no build command corresponding to \n  target=\""+target+"\"\nin generate_build_aocx_commnad():"+__file__)
    return generate_build_aocx_commnad

        
def generate_build_command(category, target) -> str:
    if (category == "host"):
        generated_build_command = config.templete_build_host_commad.format(target)
    else:
        generated_build_command = generate_build_aocx_commnad(target)
    return generated_build_command


def generate_build_script(category, targetname,version, smi_path, build_path) -> str:
    print("executed")
    selected_version_modules = config.available_modules.get(version, config.available_modules['v194'])
    generated_build_command=generate_build_command(category, targetname)
    template = read_template_file("build_script.template")
    return template.render(AOCX_INVOLVED_MODULES=selected_version_modules
                        ,SMI_PREFIX=smi_path
                        ,SMI_BUILDDIR=build_path
                        ,BUILD_COMMANDS=generated_build_command)
                    
