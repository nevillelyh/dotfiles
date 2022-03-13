#!/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - Kindle, Slack, The Unarchiver
BREWS="bat colordiff exa fd fzf git git-delta gpg htop hub neovim pinentry-mac python ripgrep tig tmux wget z"
CASKS="alacritty alfred dropbox google-cloud-sdk iterm2 jetbrains-toolbox joplin sublime-text visual-studio-code vimr"
CASKS_OPT="adobe-creative-cloud expressvpn guitar-pro macdive shearwater-cloud transmission vlc"

# Linux packages:
# compton - for alacritty background opacity
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# bat - outdated in Ubuntu, use binary instead
# git-delta - not available for Ubuntu, use binary instead
DEB_PKGS="alacritty awesome colordiff compton exa fd-find fonts-powerline fzf gnome-screensaver htop neovim neovim-qt snapd ripgrep tig tmux ubuntu-restricted-extras xautolock xcalib zsh"

# PIP packages:
PIP_PKGS="flake8 ipython virtualenvwrapper"

die() {
    echo "Error: $1"
    exit 1
}

_homebrew() {
    command -v brew &> /dev/null && return
    echo "Setting up Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -d /opt/homebrew ]] && export PATH=/opt/homebrew/bin:$PATH
    brew install $BREWS
    brew install --cask $CASKS

    # May be pre-installed
    [[ -d "/Applications/Google Chrome.app" ]] || brew install --cask google-chrome
    [[ -d "/Applications/Spotify.app" ]] || brew install --cask spotify

    read -p "Install optional casks (y/N)? " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        brew install --cask $CASKS_OPT
    fi
}

_aptitude() {
    command -v htop &> /dev/null && return
    echo "Setting up Aptitude"

    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get install aptitude
    sudo aptitude update
    sudo aptitude upgrade
    sudo aptitude install $DEB_PKGS
}

_linux() {
    command -v hub &> /dev/null && return
    echo "Setting up Linux specifics"

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
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install code sublime-text # or code-insiders

    sudo snap install spotify
    sudo snap install hub --classic

    git clone https://github.com/dracula/gnome-terminal
    ./gnome-terminal/install.sh
    rm -rf gnome-terminal

    # Dropbox has its own repository
    # sudo dpkg -i dropbox_*_amd64.deb
    # Slack from Snap is broken
    # sudo dpkg -i slack-desktop-*-amd64.deb
    # Edit /usr/share/applications/slack.desktop to use wrapper
    # for icon and _NET_WM_WINDOW_TYPE fixes
}

_mac() {
    echo "Setting up Mac specifics"

    read -p "Enter hostname: "
    sudo scutil --set ComputerName $REPLY
    sudo scutil --set HostName $REPLY
    sudo scutil --set LocalHostName $REPLY

}

_fonts() {
    echo "Setting up fonts"

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts

    # Also install powerlevel10k patched fonts
    # https://github.com/romkatv/powerlevel10k#fonts
}

_git() {
    [[ -d ${HOME}/.dotfiles/oh-my-zsh ]] && return
    echo "Setting up Git"

    cd $HOME
    git init
    git config branch.master.rebase true
    git remote add origin git@github.com:nevillelyh/dotfiles.git
    git fetch
    git reset --hard origin/master
    git submodule update --init --recursive
    git branch --set-upstream-to=origin/master
}

_gnupg() {
    [[ -d ${HOME}/.gnupg ]] && return
    [[ "$(uname -s)" != "Darwin" ]] && return
    echo "Setting up GnuPG"

    mkdir -p ${HOME}/.gnupg
    chmod 700 ${HOME}/.gnupg
    cp ${HOME}/.dotfiles/files/gpg-agent.conf ${HOME}/.gnupg

    # https://gpgtools.tenderapp.com/kb/gpg-mail-faq/gpg-mail-hidden-settings#disable-option-to-store-password-in-macos-keychain
    defaults write org.gpgtools.common DisableKeychain -bool yes
}

_neovim() {
    DIR=$HOME/.local/share/dein/repos/github.com/Shougo
    [[ -d $DIR ]] && return
    echo "Setting up NeoVim"

    mkdir -p $DIR
    git clone git@github.com:Shougo/dein.vim.git $DIR/dein.vim
    nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'
}

_pip() {
    command -v ipython &> /dev/null && return
    echo "Setting up Python"

    DIR=/usr/local/lib
    [[ -d /opt/homebrew ]] && DIR=/opt/homebrew/lib

    owner=$(ls -l $DIR | grep '\<python.*$' | awk '{print $3}')
    if [[ "${owner}" == "$(whoami)" ]]; then
        SUDO=""
    else
        SUDO="sudo"
    fi
    curl https://bootstrap.pypa.io/get-pip.py | ${SUDO} python3
    pip3 install ${PIP_PKGS}
}

_jdk() {
	set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
	VERSION="$1"
	SUFFIX="$2"

	local JDK_VERSION=$(sdk list java | grep -o "$VERSION\.[^ ]*$SUFFIX" | head -n 1)
    [[ -z "$JDK_VERSION" ]] && die 'No Java $VERSION SDK available'
    echo sdk install java $JDK_VERSION
}

_sdkman() {
    command -v sbt &> /dev/null && return
    echo "Setting up SDKMAN"

    curl -s "https://get.sdkman.io" | bash
    sed -i 's/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g' $HOME/.sdkman/etc/config

    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    if [[ "$(uname -s)" == "Darwin" ]] && [[ "$(uname -m)" == "arm64" ]]; then
        _jdk 8 "-zulu"
        _jdk 11 "-zulu"
        _jdk 17 "-tem"
    else
        _jdk 8 "-tem"
        _jdk 11 "-tem"
        _jdk 17 "-tem"
    fi

    sdk install maven
    sdk default maven

    sdk install scala
    sdk default scala

    sdk install sbt
    sdk default sbt
    set -u
}

_cargo() {
    command -v cargo &> /dev/null && return
    echo "Setting up Rust"

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

_zsh() {
    chsh -s /bin/zsh
}

[[ -f $HOME/.ssh/private/id_rsa ]] || die 'SSH private key not found'
ssh-add $HOME/.ssh/private/id_rsa

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
_gnupg
_neovim
_pip
_sdkman
_cargo
_zsh
