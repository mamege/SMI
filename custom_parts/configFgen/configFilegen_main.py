#!/usr/bin/python3

import os,click,sys

import config
from generate_build_script import generate_build_script
from generate_exec_script import generate_exec_script

from generate_json import generate_json

def prepare_directory(path):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

def write_file(path, content, binary=False):
    prepare_directory(os.path.dirname(os.path.abspath(path)))
    with open(path, "wb" if binary else "w") as f:
        f.write(content)

@click.command()
@click.option("-t", "--targetname", "targetname", required=True, help="Specify Target Name (e.g. bandwidth, gather ...)")
@click.option("-c", "--category", "category", required=True, help="Specify Build Category == host || aocx")
@click.option("-v", "--version", "version")
@click.option("-spath", "--smi_path", "smi_path", required=True)
@click.option("-bpath", "--smi_build_path", "build_path", required=True)
@click.option("-o", "--output", "output", required=True)
def codegen_build_script(targetname, category, version, smi_path, build_path, output):    
    str = generate_build_script(category, targetname, version, smi_path, build_path)
    #print(str)
    write_file(output, str)
    os.chmod(output,0o755)


@click.command()
@click.option("-t", "--targetname", "targetname", required=True, help="Specify Target Name (e.g. bandwidth, gather ...)")
@click.option("-o", "--output_dir", "output_dir", required=True, help="Specify Dirctory Path (e.g. <build_dir>/<target>)")
def codegen_json(targetname, output_dir):    
    str = generate_json(targetname)
    print(str)
    write_file(output_dir, str)

@click.command()
@click.option("-t", "--targetname", "targetname", required=True, help="Specify Target Name (e.g. bandwidth, gather ...)")
@click.option("-o", "--output", "output", required=True)
@click.option("-b", "--binary_path", "binary_path")
def codegen_exec_script(targetname, output, binary_path):    
    str = generate_exec_script(targetname, binary_path)
    print(str)
    generated_exec_file = output+"/"+targetname+".sh"
    write_file(generated_exec_file, str)
    os.chmod(generated_exec_file,0o755)
    print("== generate exec file for %s at\n %s" % (targetname, generated_exec_file))

    generate_rankfile(output)

def generate_rankfile(output):
    rankfile = output+'/rankfile'
    with open(rankfile,'w') as f:
        rank = 0;
        for i in config.default_smi_partition_at_ppx:
            f.write(config.template_rankfile_ppx.format(str(rank), i) )
            rank+=1
    print("== generate rankfile at\n %s" % rankfile)

@click.group()
def cli():
    pass


if __name__ == "__main__":
    cli.add_command(codegen_build_script)
    cli.add_command(codegen_exec_script)
    cli.add_command(codegen_json)
    cli()