#/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
BREWS="colordiff fzf git htop hub neovim pinentry-mac python tmux tree wget z"
CASKS="adobe-creative-cloud alfred dropbox expressvpn gitter google-chrome google-cloud-sdk guitar-pro iterm2 keybase kindle macdive slack transmission visual-studio-code vimr vlc"

# Linux packages:
# python3-distutils - for pip
# fonts-powerline - PowerlineSymbols only, no patched fonts
DEB_PKGS="awesome colordiff fonts-powerline fzf gnome-screensaver htop neovim snapd tmux tree zsh"

# PIP packages:
PIP_PKGS="ipython virtualenvwrapper flake8"

die() {
    echo "Error: $1"
    exit 1
}

_homebrew() {
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install $BREWS
    brew cask install $CASKS
}

_aptitude() {
    sudo apt-get install aptitude
    sudo aptitude update
    sudo aptitude upgrade
    sudo aptitude install $DEB_PKGS
}

_linux() {
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb

    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    # Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    # Update the package list and install the Cloud SDK
    sudo apt-get update && sudo apt-get install google-cloud-sdk

    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install code # or code-insiders

    sudo snap install spotify
    sudo snap install hub --classic
    sudo snap install slack --classic

    git clone https://github.com/powerline/fonts.git
    ./fonts/install.sh
    rm -rf fonts
}

_mac() {
    mkdir -p ${HOME}/.gnupg
    chmod 700 ${HOME}/.gnupg
    cp ${HOME}/.dotfiles/files/gpg-agent.conf ${HOME}/.gnupg
}

_git() {
    cd $HOME
    git init
    git config branch.master.rebase true
    git remote add origin git@github.com:nevillelyh/dotfiles.git
    git fetch
    git reset --hard origin/master
    git submodule update --init --recursive
    git branch --set-upstream-to=origin/master
}

_neovim() {
    mkdir -p $HOME/.local/share/dein/repos/github.com/Shougo
    git clone git@github.com:Shougo/dein.vim.git $HOME/.local/share/dein/repos/github.com/Shougo/dein.vim
    nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'
}

_pip() {
    owner=$(ls -l /usr | grep '\<local$' | awk '{print $3}')
    if [[ "${owner}" == "$(whoami)" ]]; then
        SUDO=""
    else
        SUDO="sudo"
    fi
    curl https://bootstrap.pypa.io/get-pip.py | ${SUDO} python3
    ${SUDO} pip3 install ${PIP_PKGS}
}

_sdkman() {
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    local JDK_VERSION=$(sdk list java | grep -o '8\.[^ ]*\.hs-adpt' | head -n 1)
    [[ -z "$JDK_VERSION" ]] && die 'No Java 8 SDK available'
    sdk install java $JDK_VERSION

    local JDK_VERSION=$(sdk list java | grep -o '11\.[^ ]*\.hs-adpt' | head -n 1)
    [[ -z "$JDK_VERSION" ]] && die 'No Java 11 SDK available'
    sdk install java $JDK_VERSION

    sdk install maven
    sdk default maven

    sdk install scala
    sdk default scala

    sdk install sbt
    sdk default sbt
}

_zsh() {
    chsh -s /bin/zsh
}

[[ -f $HOME/.ssh/private/id_rsa ]] || die 'SSH private key not found'

case "$(uname -s)" in
    Darwin)
        _homebrew
        _mac
        ;;
    Linux)
        _aptitude
        _linux
        ;;
esac
_git
_neovim
_pip
_sdkman
_zsh
