#/bin/bash

# dependencies:
# git - obviously
# vim-nox - vim with python and ruby support
# ctags - for vim Tagbar
# flake8 - for vim-flake8

sudo aptitude -t squeeze-backports install git vim-nox ctags python-pip
sudo pip install flake8

# set up git repository
cd ${HOME}
git init
git remote add origin git@github.com:nevillelyh/dotfiles.git
git fetch
git branch --set-upstream master origin/master
git checkout
git submodule update --init --recursive

# patch vim
sudo patch -p1 $(dpkg-query -L vim-runtime|grep filetype.vim) < .dotfiles/vim/patches/filetype-augroup.patch

# change default shell
chsh -s /bin/zsh
