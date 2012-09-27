#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/scripts/bootstrap-dotfiles.sh)"

# Debian package dependencies:
# build-essential - for GCC, GNU Make, etc.
# curl - obviously
# exuberant-ctags - for Vim Tagbar
# git - obviously
# ruby-dev - for Vim Command-T
# tmux - obviously
# vim-nox - Vim with python and ruby support
# zsh - obviously

# PIP dependencies:
# distribute, pip
# ipython, virtualenv
# flake8 - for vim-flake8

BREWS="autojump ctags git macvim python tmux"
DEB_PKGS="build-essential curl exuberant-ctags git ruby-dev tmux vim-nox zsh"
PIP_PKGS="ipython virtualenv flake8"

die() {
    echo "Error: $1"
    exit 1
}

_aptitude() {
    DISTRO=$(lsb_release --codename --short)
    case ${DISTRO} in
        squeeze)
            APTITUDE="aptitude -t squeeze-backports"
            SUDO="sudo"
            ;;
        precise)
            APTITUDE="aptitude"
            DEB_PKGS="autojump ${DEB_PKGS}"

            # personal system, make /usr/local personal and bypass sudo
            SUDO=""
            sudo mv /usr/local /usr/local.orig
            sudo mkdir /usr/local
            sudo chown $(whoami):$(groups | awk '{print $1}') /usr/local
            ;;
        *)
            die "unsupported distribution: ${DISTRO}"
            ;;
    esac
    sudo ${APTITUDE} install ${DEB_PKGS}

    # custom fonts for vim-powerline
    if [[ "${DISTRO}" == "precise" ]]; then
        mkdir -p .fonts
        cd .fonts
        git clone https://github.com/scotu/ubuntu-mono-powerline.git
        cd ..
    fi
}

_homebrew() {
    # homebrew packages
    ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
    brew install ${BREWS}
}

_pip() {
    # PIP packages
    curl http://python-distribute.org/distribute_setup.py | ${SUDO} python
    curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | ${SUDO} python
    ${SUDO} pip install ${PIP_PKGS}
}

_git() {
    # set up git repository
    cd ${HOME}
    git init
    git config branch.master.rebase true
    git remote add origin git@github.com:nevillelyh/dotfiles.git
    git fetch
    git reset --hard origin/master
    git branch --set-upstream master origin/master
    git submodule update --init --recursive
}

_zsh() {
    # change default shell
    chsh -s /bin/zsh
}

_vundle() {
    # Vundle
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    vim -u ${HOME}/.vim/modules/vundle.vim +BundleInstall +qall
}

_commandt() {
    for cmd in ruby ruby1.8; do
        command -v ${cmd} > /dev/null && RUBY=${cmd} && break
    done
    cd ${HOME}/.vim/bundle/command-t/ruby/command-t
    ${RUBY} extconf.rb
    make
    cd ${HOME}
}

cwd=$(pwd)

[[ -f /usr/bin/lsb_release ]] && _aptitude
[[ "$(uname -s)" == "Darwin" ]] && _homebrew
_pip
_git
_zsh
_vundle
_commandt

cd ${cwd}
