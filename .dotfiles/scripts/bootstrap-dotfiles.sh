#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/scripts/bootstrap-dotfiles.sh)")

# dependencies:
# git - obviously
# vim-nox - vim with python and ruby support
# ctags - for vim Tagbar
# flake8 - for vim-flake8

[[ -f /usr/bin/lsb_release ]] && DISTRO=$(lsb_release --codename --short)

if [[ "${DISTRO}" == "squeeze" ]]; then
    APTITUDE="aptitude -t squeeze-backports"
elif [[ "${DISTRO}" == "oneiric" ]]; then
    APTITUDE="aptitude"
else
    echo "Unsupported distribution: ${DISTRO}"
    exit 1
fi

sudo ${APTITUDE} install git vim-nox ctags python-pip
sudo pip install flake8

# set up git repository
cwd=$(pwd)
cd ${HOME}
git init
git remote add origin git@github.com:nevillelyh/dotfiles.git
git fetch
git branch --set-upstream master origin/master
git checkout
git submodule update --init --recursive

# patch vim
sudo patch -p1 $(dpkg-query -L vim-runtime|grep filetype.vim) < .dotfiles/vim/patches/filetype-augroup.patch

# Vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
vim +BundleInstall +qall

# Command-T
cd ${HOME}/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
cd ${HOME}

# change default shell
chsh -s /bin/zsh

# custom fonts for vim-powerline
if [[ "${DISTRO}" == "oneiric" ]]; then
    mkdir -p .fonts
    cd .fonts
    git clone https://github.com/scotu/ubuntu-mono-powerline.git
    cd ..
fi

cd ${cwd}
