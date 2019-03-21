#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap-dotfiles.sh)"

# fail early
set -e

# Packages:

# Mac:
# python - do not mess with OS X bundled python
# zsh (with --disable-etcdir)
BREWS="ack colordiff git htop hub python tmux tree wget z"
CASKS="alfred dropbox gitter macvim slack vlc"

# Ubuntu:
# build-essential - for GCC, GNU Make, etc.
# ruby-dev - for Vim Command-T
# python3-distutils - missing on Ubuntu 18.04
DEB_PKGS="ack-grep build-essential colordiff curl git htop python3-distutils ruby-dev tmux tree vim-nox zsh"

# PIP:
PIP_PKGS="autoenv ipython virtualenv virtualenvwrapper flake8"

die() {
    echo "Error: $1"
    exit 1
}

ask() {
    while true; do
        read -p "$1 (y/n) " yn
        case $yn in
            y|Y|yes|YES) return 0;;
            n|N|no|NO)   return 1;;
            *)           echo "Please answer yes or no.";;
        esac
    done
}

_usr_local() {
    # homebrew works without owning /usr/local
    if [[ "$(uname)" != "Darwin" ]]; then
        # personal system, make /usr/local personal and bypass sudo
        sudo mv /usr/local /usr/local.orig
        sudo mkdir /usr/local
        sudo chown $(whoami):$(groups | awk '{print $1}') /usr/local
    fi
}

_aptitude() {
    sudo apt-get update
    sudp apt-get install aptitude
    sudo aptitude install ${DEB_PKGS}
    # zsh on Ubuntu 18.04 creates /usr/local/share
    sudo chown $(whoami):$(groups | awk '{print $1}') /usr/local/share
}

_homebrew() {
    # homebrew packages
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install ${BREWS}

    # work around for OS X mis-configuration
    brew install --without-etcdir zsh

    brew cask install ${CASKS}
}

_pip() {
    if ask "Install Python packages with pip?"; then
        owner=$(\ls -l /usr | grep -v '^l' | grep 'local$' | awk '{print $3}')
        if [[ "$(uname -s)" == "Darwin" ]] || [[ "${owner}" == "$(whoami)" ]]; then
            SUDO=""
        else
            SUDO="sudo"
        fi
        curl https://bootstrap.pypa.io/get-pip.py | ${SUDO} python3
        ${SUDO} pip3 install ${PIP_PKGS}
    fi
}

_git() {
    if [[ -z ${http_proxy} ]]; then
        GIT_URL="git@github.com:nevillelyh/dotfiles.git"
    else
        GIT_URL="https://github.com/nevillelyh/dotfiles.git"
    fi

    cd ${HOME}
    git init
    git config branch.master.rebase true
    git remote add origin ${GIT_URL}
    git fetch
    git reset --hard origin/master
    git submodule update --init --recursive
    git branch --set-upstream-to=origin/master
}

_zsh() {
    # change default shell
    if [[ "$(uname -s)" == "Darwin" ]]; then
        cat << EOF | sudo tee -a /etc/shells
/usr/local/bin/zsh
EOF
        chsh -s /usr/local/bin/zsh
    else
        chsh -s /bin/zsh
    fi

    # Cannot add submodule within oh-my-zsh submodule
    mkdir -p ${HOME}/.dotfiles/zsh/omz/custom/plugins
    cd ${HOME}/.dotfiles/zsh/omz/custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
}

_vundle() {
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    vim -u ${HOME}/.vim/vimrc.d/vundle.vim +BundleInstall +qall
}

_commandt() {
    for cmd in ruby ruby1.8; do
        command -v ${cmd} > /dev/null && RUBY=${cmd} && break
    done
    cd ${HOME}/.vim/bundle/Command-T/ruby/command-t/ext/command-t
    ${RUBY} extconf.rb
    make
    cd ${HOME}
}

_xmonad() {
    if ask "Install XMonad packages?"; then
        sudo add-apt-repository ppa:gekkio/xmonad
        sudo aptitude update
        sudo aptitude install gmrun gnome-session-xmonad xmonad
    fi
}

_jdk() {
    if ask "Install JDK?"; then
        sudo add-apt-repository ppa:webupd8team/java
        sudo aptitude update
        sudo aptitude install oracle-java8-installer
    fi
}

_desktop() {
    if ask "Install desktop packages?"; then
        sudo add-apt-repository ppa:gekkio/xmonad
        sudo aptitude update
        sudo aptitude install fonts-powerline gmrun gnome-session-xmonad xmonad
        sudo cp ~/.dotfiles/files/50-logitech.conf /usr/share/X11/xorg.conf.d
    fi
}

cwd=$(pwd)

_usr_local
[[ -f /usr/bin/lsb_release ]] && _aptitude
[[ "$(uname -s)" == "Darwin" ]] && _homebrew
_pip
_git
_zsh
_vundle
_commandt
[[ -f /usr/bin/lsb_release ]] && _jdk
[[ -f /usr/bin/lsb_release ]] && _desktop

cd ${cwd}
