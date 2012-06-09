#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/scripts/bootstrap-dotfiles.sh)"

# Debian package dependencies:
# git - obviously
# vim-nox - Vim with python and ruby support
# ctags - for Vim Tagbar
# build-essential - for GCC, GNU Make, etc.
# python-pip - for flake8
# ruby-dev - for Vim Command-T

# PIP dependencies:
# flake8 - for vim-flake8
# virtualenv

PKGS="git vim-nox ctags build-essential ipython python-pip ruby-dev tmux"

[[ -f /usr/bin/lsb_release ]] && DISTRO=$(lsb_release --codename --short)

if [[ "${DISTRO}" == "squeeze" ]]; then
    APTITUDE="aptitude -t squeeze-backports"
elif [[ "${DISTRO}" == "oneiric" ]]; then
    APTITUDE="aptitude"
else
    echo "Unsupported distribution: ${DISTRO}"
    exit 1
fi

sudo ${APTITUDE} install ${PKGS}
sudo pip install flake8
sudo pip install virtualenv

# set up git repository
cwd=$(pwd)
cd ${HOME}
git init
git remote add origin git@github.com:nevillelyh/dotfiles.git
git fetch
git branch --set-upstream master origin/master
git checkout
git submodule update --init --recursive

# Vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
vim +BundleInstall +qall

# Command-T
for cmd in ruby ruby1.8; do
    command -v ${cmd} > /dev/null && RUBY=${cmd} && break
done
cd ${HOME}/.vim/bundle/command-t/ruby/command-t
${RUBY} extconf.rb
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
