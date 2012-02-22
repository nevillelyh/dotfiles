#!/bin/bash

cwd=$(pwd)
cd ${HOME}

gitcmd () {
    cmd=$1
    echo "Running: ${cmd}"
    ${cmd}
    if [ $? -ne 0 ]; then
        echo "Failed: ${cmd}"
        cd ${cwd}
        exit 1
    fi
    echo "Done: ${cmd}"
    echo
}

gitcmd "git stash save"
gitcmd "git pull"
gitcmd "git submodule update --init --recursive"
gitcmd "git stash pop"

cd ${cwd}
