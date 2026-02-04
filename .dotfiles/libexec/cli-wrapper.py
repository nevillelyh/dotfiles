#!/usr/bin/env python3

import os
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class Command:
    base: str
    args: dict


COMMANDS = {
    'b2ls': Command('b2 ls', {'j': 'json', 'l': 'long', 'r': 'recursive'}),
    's3cp': Command('aws s3 cp', {'q': 'quiet', 'r': 'recursive'}),
    's3ls': Command('aws s3 ls', {'h': 'human-readable', 'r': 'recursive', 's': 'summarize'}),
    's3mv': Command('aws s3 mv', {'q': 'quiet', 'r': 'recursive'}),
    's3rm': Command('aws s3 rm', {'q': 'quiet', 'r': 'recursive'}),
    's3sync': Command('aws s3 sync', {'q': 'quiet', 'r': 'recursive'}),
}


def show_help(name, cmd):
    lines = [
        f'CLI wrapper for: {cmd.base}',
        f'Usage: {name} [OPTION]...',
        '    --help: show this help message',
    ]
    lines.extend([f'    -{k}: --{v}' for k, v in cmd.args.items()])
    sep = '=' * max(len(line) for line in lines)
    print(sep)
    print('\n'.join(lines))
    print(sep)


def main():
    name = os.path.basename(sys.argv[0])
    if name not in COMMANDS:
        print(f'Command not recognized: {name}')
        print('Supported commands:')
        for k in COMMANDS:
            print(f'    {k}')
        sys.exit(1)

    cmd = COMMANDS[name]
    argv = cmd.base.split()

    show_help = False
    for arg in sys.argv[1:]:
        if arg[0] == '-' and arg[1:].isalpha():
            for c in arg[1:]:
                if c in cmd.args:
                    argv.append('--' + cmd.args[c])
                else:
                    argv.append('-' + c)
        else:
            if arg == '--help':
                show_help = True
            argv.append(arg)

    if show_help:
        show_help(name, cmd)
        print()

    os.execvp(argv[0], argv)


if __name__ == '__main__':
    main()
