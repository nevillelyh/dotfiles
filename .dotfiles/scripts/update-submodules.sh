#!/bin/bash

cwd=$(pwd)
cd ${HOME}

for path in $(git submodule | awk '{print $2}'); do
    echo Updating ${path}
    cd ${HOME}/${path}
    git pull
    echo
done

cd ${cwd}
