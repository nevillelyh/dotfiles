#!/usr/bin/env python3

import os
import sys
from collections import namedtuple


Command = namedtuple('Command', ['base', 'args'])
commands = {
    'b2ls': Command('b2 ls', {'j': 'json', 'l': 'long', 'r': 'recursive'}),
    's3cp': Command('aws s3 cp', {'q': 'quiet', 'r': 'recursive'}),
    's3ls': Command('aws s3 ls', {'h': 'human-readable', 'r': 'recursive', 's': 'summarize'}),
    's3mv': Command('aws s3 mv', {'q': 'quiet', 'r': 'recursive'}),
    's3rm': Command('aws s3 rm', {'q': 'quiet', 'r': 'recursive'}),
    's3sync': Command('aws s3 sync', {'q': 'quiet', 'r': 'recursive'}),
}


def help(name, cmd):
    lines = []
    lines.append('CLI wrapper for: %s' % cmd.base)
    lines.append('Usage: %s [OPTION]...' % name)
    lines.append('    --help: show this help message')
    for k, v in cmd.args.items():
        lines.append('    -%s: --%s' % (k, v))
    sep = '=' * max(map(len, lines))
    print(sep)
    for line in lines:
        print(line)
    print(sep)


def main():
    name = os.path.basename(sys.argv[0])
    if name not in commands:
        print('Command not recognized: %s' % name)
        print('Supported commands:')
        for k in commands:
            print('    ' + k)
        sys.exit(1)

    cmd = commands[name]
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
        help(name, cmd)
        print()

    os.execvp(argv[0], argv)


if __name__ == '__main__':
    main()
