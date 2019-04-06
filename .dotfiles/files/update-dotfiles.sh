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

vim -u ${HOME}/.vim/vimrc.d/vundle.vim +BundleInstall +qall
vim -u ${HOME}/.vim/vimrc.d/vundle.vim +BundleUpdate +qall
vim -u ${HOME}/.vim/vimrc.d/vundle.vim +BundleClean +qall

cd ${cwd}
