#!/usr/bin/python3

import click


@click.command()
@click.argument('name', default='guest')

# A. Option機能を試す．
@click.option("-f", "--filename", "filename")

def hello(name, filename):
    click.echo(f'Hello {name}')
    # 普通に変数として使用できる．
    print(name)
    # A.
    if filename == None :
        print("Set filename: %s -f <filename>" % __file__)
        exit(1)
    else:
        print(filename)

 
if __name__ == '__main__':
    hello()