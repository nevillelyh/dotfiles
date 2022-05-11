#!/bin/bash

# Bootstrap a new environment

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - AdGuard for Safari, Instapaper, Kindle, Messenger, Slack, The Unarchiver, WhatsApp
BREWS="bat code-minimap cmake colordiff exa fd fzf gh git git-delta gitui golang gpg htop jq neovim ninja pinentry-mac python ripgrep tmux wget zoxide"
CASKS="alacritty alfred dropbox github iterm2 jetbrains-toolbox joplin lastpass sublime-text visual-studio-code vimr"
CASKS_OPT="adobe-creative-cloud anki expressvpn firefox google-chrome guitar-pro macdive microsoft-edge shearwater-cloud spotify transmission vlc"

# Linux packages:
# compton - for alacritty background opacity
# wmctrl - for Slack & Spotify icon fixes
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# unzip, zip - for SDKMAN
# Not available or outdated in Ubuntu - bat, git-delta, zoxide
DEB_PKGS="build-essential cmake colordiff exa fd-find fzf htop jq neovim ninja-build ripgrep tmux unzip zip zsh"
DEB_GUI_PKGS="alacritty awesome compton fonts-powerline gnome-screensaver gnome-screenshot neovim-qt ubuntu-restricted-extras wmctrl xautolock xcalib"
LINUX_CRATES="bat code-minimap git-delta gitui zoxide"

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
    set +u
    [[ -n "$SSH_CONNECTION" ]] && return 0 # remote host
    set -u
    [[ -s $HOME/.ssh/private/id_ed25519 ]] || die "SSH private key not found"
    killall -q ssh-agent || true
    eval $(ssh-agent)
    ssh-add $HOME/.ssh/private/id_ed25519
}

setup_homebrew() {
    [[ "$uname_s" != "Darwin" ]] && return 0
    type brew &> /dev/null && return 0
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

setup_mac() {
    [[ "$uname_s" != "Darwin" ]] && return 0
    msg_box "Setting up Mac specifics"

    read -p "Enter hostname: "
    sudo scutil --set ComputerName $REPLY
    sudo scutil --set HostName $REPLY
    sudo scutil --set LocalHostName $REPLY
}

setup_apt() {
    [[ "$uname_s" != "Linux" ]] && return 0
    type gh &> /dev/null && return 0
    msg_box "Setting up Aptitude"

    sudo apt-get install -y apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install -y $DEB_PKGS

    # Third-party APT repositories
    apt_sh="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/apt.sh"
    curl -fsSL "$apt_sh" | bash -s -- github

    # The following are GUI apps
    dpkg-query --show xorg &> /dev/null || return 0

    sudo aptitude install -y $DEB_GUI_PKGS

    curl -fsSL "$apt_sh" | bash -s -- chrome
    curl -fsSL "$apt_sh" | bash -s -- code
    curl -fsSL "$apt_sh" | bash -s -- dropbox
    curl -fsSL "$apt_sh" | bash -s -- sublime
}

setup_linux() {
    [[ "$uname_s" != "Linux" ]] && return 0
    [[ -d /usr/local/go ]] && return 0
    msg_box "Setting up Linux specifics"

    # Go lang
    # TODO: include this in upgrade_dotfiles
    url="https://api.github.com/repos/golang/go/git/refs/tags"
    header="Accept: application/vnd.github.v3+json"
    version=$(curl -sSL -H "$header" $url | jq --raw-output '.[].ref' | grep 'refs/tags/go' | cut -d '/' -f 3 | tail -n 1)
    curl -sSL "https://go.dev/dl/$version.linux-amd64.tar.gz" | sudo tar -C /usr/local -xz

    type nvidia-smi &> /dev/null && sudo aptitude install -y nvtop

    # The following are GUI apps
    dpkg-query --show xorg &> /dev/null || return 0

    git clone https://github.com/dracula/gnome-terminal
    ./gnome-terminal/install.sh
    rm -rf gnome-terminal

    sudo aptitude install -y snapd
    sudo snap install slack spotify xseticon

    # Joplin uses AppImage
    curl -fsSL https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

    mkdir -p $HOME/.local/share/backgrounds
    wget -nv https://raw.githubusercontent.com/dracula/wallpaper/master/awesome.png -P $HOME/.local/share/backgrounds
    wget -nv https://raw.githubusercontent.com/dracula/wallpaper/master/pop.png -P $HOME/.local/share/backgrounds
    url="file://$HOME/.local/share/backgrounds/pop.png"
    gsettings set org.gnome.desktop.background picture-uri "$uri"
    gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
    gsettings set org.gnome.desktop.screensaver picture-uri "$uri"
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
    nvim -u $HOME/.config/nvim/dein.vim --headless "+call dein#install() | qall"
}

setup_python() {
    type ipython &> /dev/null && return 0
    msg_box "Setting up Python"

    # Homebrew python includes pip
    if [[ "$uname_s" == "Linux" ]]; then
        curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python3
    fi
    pip3 install ${PIP_PKGS}
}

setup_jdk() {
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    version="$1"
    suffix="$2"

    local jdk_version=$(sdk list java | grep -o "\<$version\.[^ ]*$suffix" | head -n 1)
    [[ -z "$jdk_version" ]] && die "No Java $version SDK available"
    sdk install java $jdk_version
}

setup_java() {
    type sbt &> /dev/null && return 0
    msg_box "Setting up SDKMAN"

    curl -fsSL "https://get.sdkman.io" | bash
    sed -i "s/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g" $HOME/.sdkman/etc/config
    sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" $HOME/.sdkman/etc/config

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

    sed -i "s/sdkman_auto_answer=true/sdkman_auto_answer=false/g" $HOME/.sdkman/etc/config
}

setup_rust() {
    type cargo &> /dev/null && return 0
    msg_box "Setting up Rust"

    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    source $HOME/.cargo/env
    [[ "$uname_s" == "Linux" ]] && cargo install -q $LINUX_CRATES
}

setup_code() {
    type code &> /dev/null || return 0
    code --list-extensions | grep dracula-theme.theme-dracula &> /dev/null && return 0
    msg_box "Setting up Visual Studio Code"

    code --install-extension \
        asvetliakov.vscode-neovim \
        dracula-theme.theme-dracula \
        GitHub.vscode-pull-request-github \
        ms-vscode.cpptools-extension-pack \
        rust-lang.rust \
        vadimcn.vscode-lldb
    if [[ "$uname_s" == "Darwin" ]]; then
        code --install-extension sswg.swift-lang
        defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
    fi
}

setup_fonts() {
    [[ "$uname_s" == "Darwin" ]] || dpkg-query --show xorg &> /dev/null || return 0
    msg_box "Setting up fonts"

    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    case "$uname_s" in
        Darwin)
            mkdir -p $HOME/Library/Fonts
            mv MesloLGS*.ttf $HOME/Library/Fonts
            ;;
        Linux)
            mkdir -p $HOME/.local/share/fonts
            mv MesloLGS*.ttf $HOME/.local/share/fonts
            fc-cache -fv $HOME/.local/share/fonts
            ;;
    esac

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
}

setup_zsh() {
    [[ "$SHELL" == "/bin/zsh" ]] && return 0
    msg_box "Setting up zsh"
    chsh -s /bin/zsh

    [[ "$uname_s" != "Linux" ]] && return 0

    # Missing ZSH completions for some packages, e.g. those from Cargo
    completions_sh="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/completions.sh"
    mkdir -p $HOME/.local/share/zsh/site-functions
    curl -fsSL "$completions_sh" | bash -s -- "$HOME/.local/share/zsh/site-functions"
}

########################################

# Bootstrap inside a Docker container

docker_build() {
    msg_box "Building Docker image"
    docker run -it -v $HOME/.dotfiles:/dotfiles -v $HOME/.ssh:/ssh --rm ubuntu:jammy /bin/bash /dotfiles/files/bootstrap.sh docker_inside
}

docker_inside() {
    msg_box "Setting up Docker container"
    # Prepare environment
    apt-get update
    apt-get install -y curl git openssh-client python3-distutils sudo wget
    useradd -m -s /bin/bash neville
    usermod -aG sudo neville

    # No password sudo and chsh
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    sed -i "s/^\(auth \+\)required\( \+pam_shells.so\)/\1sufficient\2/" /etc/pam.d/chsh

    mkdir -p /home/neville/.ssh/private
    cp -a /ssh/private/id* /home/neville/.ssh/private
    echo "Host *" >> /home/neville/.ssh/config
    echo "    StrictHostKeyChecking no" >> /home/neville/.ssh/config
    chown -R neville:neville /home/neville/.ssh

    su - neville /dotfiles/files/bootstrap.sh
}

########################################

help() {
    echo "Usage: $(basename $0) [COMMAND]"
    echo "    Commands:"
    echo "        docker"
    grep -o '^setup_\w\+()' $(readlink -f $0) | sed 's/^setup_\(.*\)()$/        \1/' | sort
    exit 0
}

if [[ $# -eq 1 ]]; then
    case "$1" in
        docker)
            docker_build
            ;;
        docker_inside)
            docker_inside
            ;;
        help)
            help
            ;;
        *)
            msg_box "Setting up single step $1"
            setup_$1
            ;;
    esac
    exit 0
fi

uname_s=$(uname -s)
uname_m=$(uname -m)

setup_ssh

case "$uname_s" in
    Darwin)
        setup_homebrew
        setup_mac
        ;;
    Linux)
        setup_apt
        setup_linux
        ;;
esac

setup_git
setup_gnupg
setup_neovim
setup_python
setup_java
setup_rust
setup_code
setup_fonts
setup_zsh

msg_box "Bootstrap complete"
