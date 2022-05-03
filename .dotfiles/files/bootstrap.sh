#!/bin/bash

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"
APT_SH="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/apt.sh"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - AdGuard for Safari, Instapaper, Kindle, Messenger, Slack, The Unarchiver, WhatsApp
BREWS="bat cmake colordiff exa fd fzf git git-delta gitui gpg htop hub neovim ninja pinentry-mac python ripgrep tmux wget zoxide"
CASKS="alacritty alfred dropbox github iterm2 jetbrains-toolbox joplin lastpass sublime-text visual-studio-code vimr"
CASKS_OPT="adobe-creative-cloud anki expressvpn firefox google-chrome guitar-pro macdive microsoft-edge shearwater-cloud spotify transmission vlc"

# Linux packages:
# compton - for alacritty background opacity
# wmctrl - for Slack & Spotify icon fixes
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# unzip, zip - for SDKMAN
# Not available or outdated in Ubuntu - bat, git-delta, zoxide
DEB_PKGS="build-essential cmake colordiff exa fd-find fzf htop hub neovim ninja-build ripgrep tmux unzip zip zsh"
DEB_GUI_PKGS="alacritty awesome compton fonts-powerline gnome-screensaver neovim-qt ubuntu-restricted-extras wmctrl xautolock xcalib"
LINUX_CRATES="bat git-delta gitui zoxide"

# PIP packages:
PIP_PKGS="flake8 ipython virtualenv virtualenvwrapper"

msg_box() {
    line="##$(echo "$1" | sed 's/./#/g')##"
    echo "$line"
    echo "# $1 #"
    echo "$line"
}

die() {
    msg_box "Error: $1"
    exit 1
}

setup_ssh() {
    [[ -n "$SSH_CONNECTION" ]] && return 0 # remote host
    [[ -f $HOME/.ssh/private/id_rsa ]] || die 'SSH private key not found'
    killall -q ssh-agent || true
    eval $(ssh-agent)
    ssh-add $HOME/.ssh/private/id_rsa
}

setup_homebrew() {
    [[ "$uname_s" != "Darwin" ]] && return 0
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
    [[ "$uname_s" != "Linux" ]] && return 0
    command -v nvim &> /dev/null && return 0
    msg_box "Setting up Aptitude"

    sudo apt-get install -y apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install -y $DEB_PKGS

    dpkg-query -l xorg &> /dev/null && sudo aptitude install -y $DEB_GUI_PKGS
}

setup_linux() {
    [[ "$uname_s" != "Linux" ]] && return 0
    command -v hub &> /dev/null && return 0
    msg_box "Setting up Linux specifics"

    # The following are GUI apps
    dpkg-query -l xorg &> /dev/null || return 0

    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb

    curl -fsSL "$APT_SH" | bash -s -- code
    curl -fsSL "$APT_SH" | bash -s -- sublime
    curl -fsSL https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

    git clone https://github.com/dracula/gnome-terminal
    ./gnome-terminal/install.sh
    rm -rf gnome-terminal

    # Dropbox has its own repository
    url="https://linux.dropbox.com/packages/ubuntu/"
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^dropbox_\d{4}\.\d{2}\.\d{2}_amd64.deb$' | sort | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i dropbox_*_amd64.deb
    rm -f dropbox_*_amd64.deb

    setup_snap
}

setup_snap() {
    sudo aptitude install -y snapd
    sudo snap install slack spotify xseticon
}

setup_mac() {
    [[ "$uname_s" != "Darwin" ]] && return 0
    msg_box "Setting up Mac specifics"

    read -p "Enter hostname: "
    sudo scutil --set ComputerName $REPLY
    sudo scutil --set HostName $REPLY
    sudo scutil --set LocalHostName $REPLY
}

setup_fonts() {
    dpkg-query -l xorg &> /dev/null || return 0
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
    case "$uname_s" in
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
    msg_box "Setting up GnuPG"

    mkdir -p ${HOME}/.gnupg
    chmod 700 ${HOME}/.gnupg

    case "$uname_s" in
        Darwin)
            echo "pinentry-program /opt/homebrew/bin/pinentry-mac" > $HOME/.gnupg/gpg-agent.conf
            # Disable Pinentry "Save in Keychain"
            # https://gpgtools.tenderapp.com/kb/gpg-mail-faq/gpg-mail-hidden-settings#disable-option-to-store-password-in-macos-keychain
            defaults write org.gpgtools.common DisableKeychain -bool yes
            ;;
        Linux)
            echo "no-allow-external-cache" > $HOME/.gnupg/gpg-agent.conf
            ;;
    esac
}

setup_neovim() {
    dir=$HOME/.local/share/dein/repos/github.com/Shougo
    [[ -d $dir ]] && return 0
    msg_box "Setting up NeoVim"

    mkdir -p $dir
    git clone git@github.com:Shougo/dein.vim.git $dir/dein.vim
    nvim -u $HOME/.config/nvim/dein.vim --headless '+call dein#install() | qall'
}

setup_pip() {
    command -v ipython &> /dev/null && return 0
    msg_box "Setting up Python"

    # Homebrew python includes pip
    if [[ "$uname_s" == "Linux" ]]; then
        curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python3
    fi
    pip3 install ${PIP_PKGS}
}

setup_jdk() {
    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    version="$1"
    suffix="$2"

    local jdk_version=$(sdk list java | grep -o "\<$version\.[^ ]*$suffix" | head -n 1)
    [[ -z "$jdk_version" ]] && die 'No Java $version SDK available'
    sdk install java $jdk_version
}

setup_sdkman() {
    command -v sbt &> /dev/null && return 0
    msg_box "Setting up SDKMAN"

    curl -fsSL "https://get.sdkman.io" | bash
    sed -i 's/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g' $HOME/.sdkman/etc/config

    set +u
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    if [[ "$uname_s" == "Darwin" ]] && [[ "$uname_m" == "arm64" ]]; then
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

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    source $HOME/.cargo/env
    [[ "$uname_s" == "Linux" ]] && cargo install -q $LINUX_CRATES
}

setup_zsh() {
    [[ "$SHELL" == "/bin/zsh" ]] && return 0
    msg_box "Setting up zsh"
    chsh -s /bin/zsh
}

uname_s=$(uname -s)
uname_m=$(uname -m)

if [[ $# -eq 1 ]]; then
    msg_box "Setting up single step $1"
    setup_$1
    exit
fi

setup_ssh

case "$uname_s" in
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
