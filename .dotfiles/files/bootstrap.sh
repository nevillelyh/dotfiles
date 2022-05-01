#!/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - AdGuard for Safari, Instapaper, Kindle, Messenger, Slack, The Unarchiver, WhatsApp
BREWS="bat colordiff exa fd fzf git git-delta gitui gpg htop hub neovim pinentry-mac python ripgrep tmux wget zoxide"
CASKS="alacritty alfred dropbox iterm2 jetbrains-toolbox joplin lastpass sublime-text visual-studio-code vimr"
CASKS_OPT="adobe-creative-cloud anki expressvpn firefox google-chrome guitar-pro macdive microsoft-edge shearwater-cloud spotify transmission vlc"

# Linux packages:
# compton - for alacritty background opacity
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# unzip, zip - for SDKMAN
# Not available or outdated in Ubuntu - bat, git-delta, zoxide
DEB_PKGS="build-essential colordiff exa fd-find fzf htop neovim ripgrep snapd tmux unzip zip zsh"
DEB_GUI_PKGS="alacritty awesome compton fonts-powerline gnome-screensaver neovim-qt ubuntu-restricted-extras xautolock xcalib"
LINUX_CRATES="bat git-delta gitui zoxide"

# PIP packages:
PIP_PKGS="flake8 ipython virtualenvwrapper"

msg_box() {
    LINE="##$(echo "$1" | sed 's/./#/g')##"
    echo "$LINE"
    echo "# $1 #"
    echo "$LINE"
}

die() {
    msg_box "Error: $1"
    exit 1
}

setup_ssh() {
    [[ -n "$SSH_TTY" ]] && return 0 # remote host
    [[ -f $HOME/.ssh/private/id_rsa ]] || die 'SSH private key not found'
    killall -q ssh-agent || true
    eval $(ssh-agent)
    ssh-add $HOME/.ssh/private/id_rsa
}

setup_homebrew() {
    [[ "$UNAME_S" != "Darwin" ]] && return 0
    command -v brew &> /dev/null && return 0
    msg_box "Setting up Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -d /opt/homebrew ]] && export PATH=/opt/homebrew/bin:$PATH
    brew install $BREWS
    brew install --cask $CASKS

    read -p "Install optional casks (y/N)? " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install --cask $CASKS_OPT
    fi
}

setup_aptitude() {
    [[ "$UNAME_S" != "Linux" ]] && return 0
    command -v nvim &> /dev/null && return 0
    msg_box "Setting up Aptitude"

    sudo apt-get install apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade
    sudo aptitude install $DEB_PKGS

    XORG=$(dpkg-query -l | grep xorg)
    [[ -z "$XORG" ]] || sudo aptitude install $DEB_GUI_PKGS
}

setup_linux() {
    [[ "$UNAME_S" != "Linux" ]] && return 0
    command -v hub &> /dev/null && return 0
    msg_box "Setting up Linux specifics"

    sudo snap install hub --classic

    # The following are GUI apps
    XORG=$(dpkg-query -l | grep xorg)
    [[ -z "$XORG" ]] && return 0

    sudo snap install spotify

    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb

    wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor > sublimehq-pub.gpg
    sudo install -o root -g root -m 644 *.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo sh -c 'echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list'
    rm -f *.gpg

    sudo aptitude update
    sudo aptitude install code sublime-text # or code-insiders

    git clone https://github.com/dracula/gnome-terminal
    ./gnome-terminal/install.sh
    rm -rf gnome-terminal

    # Dropbox has its own repository
    URL="https://linux.dropbox.com/packages/ubuntu/"
    PKG=$(wget -qO - $URL | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^dropbox_\d{4}\.\d{2}\.\d{2}_amd64.deb$' | sort | tail -n 1)
    wget -nv "$URL/$PKG"
    sudo dpkg -i dropbox_*_amd64.deb
    rm -f dropbox_*_amd64.deb

    # Slack from Snap is broken
    URL=$(wget -qO - "https://slack.com/downloads/instructions/ubuntu" | grep -oP '(?<=href=")[^"]+(?=")' | grep 'slack-desktop-.\+-amd64.deb')
    wget -nv $URL
    sudo dpkg -i slack-desktop-*-amd64.deb
    rm -f slack-desktop-*-amd64.deb
    # Edit /usr/share/applications/slack.desktop to use wrapper
    # for icon and _NET_WM_WINDOW_TYPE fixes
}

setup_mac() {
    [[ "$UNAME_S" != "Darwin" ]] && return 0
    msg_box "Setting up Mac specifics"

    read -p "Enter hostname: "
    sudo scutil --set ComputerName $REPLY
    sudo scutil --set HostName $REPLY
    sudo scutil --set LocalHostName $REPLY

}

setup_fonts() {
    XORG=$(dpkg-query -l | grep xorg)
    [[ -z "$XORG" ]] && return 0
    msg_box "Setting up fonts"

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts

    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    case "$UNAME_S" in
        Darwin)
            mv MesloLGS*.ttf $HOME/Library/Fonts
            ;;
        Linux)
            mv MesloLGS*.ttf $HOME/.local/share/fonts
            fc-cache -fv $HOME/.local/share/fonts
            ;;
    esac
}

setup_git() {
    [[ -d ${HOME}/.dotfiles/oh-my-zsh ]] && return 0
    msg_box "Setting up Git"

    cd $HOME
    git init --initial-branch=main
    git config branch.main.rebase true
    git remote add origin git@github.com:nevillelyh/dotfiles.git
    git fetch
    git reset --hard origin/main
    git submodule update --init --recursive
    git branch --set-upstream-to=origin/main
}

setup_gnupg() {
    [[ -d ${HOME}/.gnupg ]] && return 0
    [[ "$UNAME_S" != "Darwin" ]] && return 0
    msg_box "Setting up GnuPG"

    mkdir -p ${HOME}/.gnupg
    chmod 700 ${HOME}/.gnupg
    cp ${HOME}/.dotfiles/files/gpg-agent.conf ${HOME}/.gnupg

    # https://gpgtools.tenderapp.com/kb/gpg-mail-faq/gpg-mail-hidden-settings#disable-option-to-store-password-in-macos-keychain
    defaults write org.gpgtools.common DisableKeychain -bool yes
}

setup_neovim() {
    DIR=$HOME/.local/share/dein/repos/github.com/Shougo
    [[ -d $DIR ]] && return 0
    msg_box "Setting up NeoVim"

    mkdir -p $DIR
    git clone git@github.com:Shougo/dein.vim.git $DIR/dein.vim
    nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'
}

setup_pip() {
    command -v ipython &> /dev/null && return 0
    msg_box "Setting up Python"

    DIR=/usr/local/lib
    [[ -d /opt/homebrew ]] && DIR=/opt/homebrew/lib

    owner=$(ls -l $DIR | grep '\<python.*$' | awk '{print $3}')
    if [[ "${owner}" == "$(whoami)" ]]; then
        SUDO=""
    else
        SUDO="sudo"
    fi
    curl -s https://bootstrap.pypa.io/get-pip.py | ${SUDO} python3
    pip3 install ${PIP_PKGS}
}

setup_jdk() {
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    VERSION="$1"
    SUFFIX="$2"

    local JDK_VERSION=$(sdk list java | grep -o "\<$VERSION\.[^ ]*$SUFFIX" | head -n 1)
    [[ -z "$JDK_VERSION" ]] && die 'No Java $VERSION SDK available'
    sdk install java $JDK_VERSION
}

setup_sdkman() {
    command -v sbt &> /dev/null && return 0
    msg_box "Setting up SDKMAN"

    curl -s "https://get.sdkman.io" | bash
    sed -i 's/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g' $HOME/.sdkman/etc/config

    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    if [[ "$UNAME_S" == "Darwin" ]] && [[ "$UNAME_M" == "arm64" ]]; then
        setup_jdk 8 "-zulu"
        setup_jdk 11 "-zulu"
        setup_jdk 17 "-tem"
    else
        setup_jdk 8 "-tem"
        setup_jdk 11 "-tem"
        setup_jdk 17 "-tem"
    fi

    sdk install gradle
    sdk install kotlin
    sdk install maven
    sdk install scala
    sdk install sbt
    set -u
}

setup_cargo() {
    command -v cargo &> /dev/null && return 0
    msg_box "Setting up Rust"

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    source $HOME/.cargo/env
    [[ "$UNAME_S" == "Linux" ]] && cargo install -q $LINUX_CRATES
}

setup_zsh() {
    [[ "$SHELL" == "/bin/zsh" ]] && return 0
    msg_box "Setting up zsh"
    chsh -s /bin/zsh
}

UNAME_S=$(uname -s)
UNAME_M=$(uname -m)

if [ $# -eq 1 ]; then
    msg_box "Setting up single step $1"
    setup_$1
    exit
fi

setup_ssh

case "$UNAME_S" in
    Darwin)
        setup_homebrew
        setup_mac
        ;;
    Linux)
        setup_aptitude
        setup_linux
        ;;
esac
setup_git
setup_gnupg
setup_neovim
setup_pip
setup_sdkman
setup_cargo
setup_zsh
setup_fonts

msg_box "Bootstrap complete"
