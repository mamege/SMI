#!/usr/bin/python3

#  https://jinja.palletsprojects.com/en/2.11.x/api/
# 

import jinja2,os,logging


def prepare_directory(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

def write_file(path, content, binary=False):
    prepare_directory(os.path.dirname(os.path.abspath(path)))
    with open(path, "wb" if binary else "w") as f:
        f.write(content)

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

global_str="""\
複数の文章からなる値も問題ないと
存じ上げるところでございます．\
"""
def generate_program_host() -> str:
    template = read_template_file("jinja2_template.txt")
    return template.render(character=global_str)

print(generate_program_host())

write_file("generate.out", generate_program_host())