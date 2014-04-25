#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/scripts/bootstrap-dotfiles.sh)"

# fail early
set -e

# Packages:
# command line tools: autojump tmux tree wget zsh
# developer tools: ctags git macvim/vim-nox

# Mac:
# python - do not mess with OS X bundled python

# also zsh (with --disable-etcdir)
BREWS="ack autojump ctags git macvim python tmux tree wget"

# Debian/Ubuntu:
# build-essential - for GCC, GNU Make, etc.
# ruby-dev - for Vim Command-T

# also autojump (Ubuntu only)
DEB_PKGS="ack-grep build-essential curl exuberant-ctags git ruby-dev tmux tree vim-nox zsh"

# PIP:
# distribute, pip
# ipython, virtualenv
# flake8 - for vim-flake8

PIP_PKGS="ipython virtualenv virtualenvwrapper flake8"

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
        precise|trusty)
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

    # work around for OS X mis-configuration
    brew install --disable-etcdir zsh
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
    if [[ "$(uname -s)" == "Darwin" ]]; then
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
    # Vundle
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    vim -u ${HOME}/.vim/vimrc.d/vundle.vim +BundleInstall +qall
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
