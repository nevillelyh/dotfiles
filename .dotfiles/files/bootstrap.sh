#!/bin/bash

# Bootstrap a new environment

# bash -c "$(curl -fsSL https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/bootstrap.sh)"

set -euo pipefail

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - AdGuard for Safari, Instapaper, Kindle, Messenger, Slack, The Unarchiver, WhatsApp
BREWS=(bat code-minimap cmake colordiff dust exa fd fzf git git-delta gitui golang gpg htop jq mas neovim ninja pinentry-mac python ripgrep shellcheck tmux wget zoxide)
CASKS=(alacritty alfred discord dropbox github iterm2 jetbrains-toolbox joplin lastpass sublime-text visual-studio-code vimr)
CASKS_OPT=(adobe-creative-cloud anki expressvpn firefox google-chrome guitar-pro macdive microsoft-edge shearwater-cloud spotify transmission vlc)
# AdGuard Xcode Unarchiver Kindle Messenger Pocket Slack WhatsApp
MAS=(1440147259 497799835 425424353 405399194 1480068668 1477385213 803453959 1147396723)

# Linux packages:
# compton - for alacritty background opacity
# wmctrl - for Slack & Spotify icon fixes
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# unzip, zip - for SDKMAN
# Not available or outdated in Ubuntu - bat, git-delta, zoxide
DEB_PKGS=(build-essential cmake colordiff exa fd-find fzf htop jq neovim ninja-build ripgrep shellcheck tmux unzip zip zsh)
DEB_GUI_PKGS=(alacritty awesome compton fonts-powerline gnome-screensaver gnome-screenshot neovim-qt ubuntu-restricted-extras vlc wmctrl xautolock xcalib xprintidle)
LINUX_CRATES=(bat code-minimap du-dust git-delta gitui zoxide)

# PIP packages:
PIP_PKGS=(flake8 ipython virtualenv virtualenvwrapper)

setup_ssh() {
    [[ -n "${SSH_CONNECTION-}" ]] && return 0 # remote host
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    keys=($(find "$HOME/.ssh" -name id_dsa -or -name id_rsa -or -name id_ecdsa -or -name id_ed25519))
    [[ "${#keys[@]}" -gt 0 ]] || die "SSH private key not found"
    killall -q ssh-agent || true
    eval "$(ssh-agent)"
    ssh-add "${keys[@]}"
}

setup_homebrew() {
    [[ "$os" != "Darwin" ]] && return 0
    [[ -L /opt/homebrew/bin/zoxide ]] && return 0
    msg_box "Setting up Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -d /opt/homebrew ]] && export PATH=/opt/homebrew/bin:$PATH
    brew install "${BREWS[@]}"
    brew install --cask "${CASKS[@]}"

    mas install "${MAS[@]}"

    read -p "Install optional casks (y/N)? " -n 1 -r
    echo # (optional) move to a new line
    [[ $REPLY =~ ^[Yy]$ ]] && brew install --cask "${CASKS_OPT[@]}"
}

setup_mac() {
    [[ "$os" != "Darwin" ]] && return 0
    msg_box "Setting up Mac specifics"

    read -r -p "Enter hostname: "
    sudo scutil --set ComputerName "$REPLY"
    sudo scutil --set HostName "$REPLY"
    sudo scutil --set LocalHostName "$REPLY"
}

setup_apt() {
    [[ "$os" != "Linux" ]] && return 0
    type nvim &> /dev/null && return 0
    msg_box "Setting up Aptitude"

    sudo apt-get install -y apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install -y "${DEB_PKGS[@]}"

    # The following are GUI apps
    dpkg-query --show xorg &> /dev/null || return 0

    sudo aptitude install -y "${DEB_GUI_PKGS[@]}"

}

setup_linux() {
    [[ "$os" != "Linux" ]] && return 0
    [[ -d /usr/local/go ]] && return 0
    msg_box "Setting up Linux specifics"

    type nvidia-smi &> /dev/null && sudo aptitude install -y nvtop

    # Third-party APT repositories
    install go

    # The following are GUI apps
    dpkg-query --show xorg &> /dev/null || return 0

    # Snap Store
    sudo aptitude install -y snapd
    sudo snap install slack spotify xseticon

    # Custom repositories
    install chrome code discord dropbox sublime

    # Joplin uses AppImage
    curl -fsSL https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

    git clone https://github.com/dracula/gnome-terminal
    ./gnome-terminal/install.sh
    rm -rf gnome-terminal

    mkdir -p "$HOME/.local/share/backgrounds"
    wget -nv https://raw.githubusercontent.com/dracula/wallpaper/master/awesome.png -P "$HOME/.local/share/backgrounds"
    wget -nv https://raw.githubusercontent.com/dracula/wallpaper/master/pop.png -P "$HOME/.local/share/backgrounds"
    uri="file://$HOME/.local/share/backgrounds/pop.png"
    gsettings set org.gnome.desktop.background picture-uri "$uri"
    gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
    gsettings set org.gnome.desktop.screensaver picture-uri "$uri"
}

setup_git() {
    [[ -d $HOME/.dotfiles/oh-my-zsh ]] && return 0
    msg_box "Setting up Git"

    cd "$HOME"
    git init --initial-branch=main
    git config branch.main.rebase true
    git remote add origin git@github.com:nevillelyh/dotfiles.git
    git fetch
    git reset --hard origin/main
    git submodule update --init --recursive
    git branch --set-upstream-to=origin/main
    git remote set-head origin --auto
}

setup_gnupg() {
    [[ -s $HOME/.gnupg/gpg-agent.conf ]] && return 0
    msg_box "Setting up GnuPG"

    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"

    echo "default-cache-ttl 7200" >> "$HOME/.gnupg/gpg-agent.conf"
    echo "max-cache-ttl 86400" >> "$HOME/.gnupg/gpg-agent.conf"

    case "$os" in
        Darwin)
            echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> "$HOME/.gnupg/gpg-agent.conf"
            # Disable Pinentry "Save in Keychain"
            # https://gpgtools.tenderapp.com/kb/gpg-mail-faq/gpg-mail-hidden-settings#disable-option-to-store-password-in-macos-keychain
            defaults write org.gpgtools.common DisableKeychain -bool yes
            ;;
        Linux)
            # Disable Pinentry "Save in password manager"
            echo "no-allow-external-cache" >> "$HOME/.gnupg/gpg-agent.conf"
            ;;
    esac
}

setup_neovim() {
    dir=$HOME/.local/share/dein/repos/github.com/Shougo
    [[ -d $dir ]] && return 0
    msg_box "Setting up NeoVim"

    mkdir -p "$dir"
    git clone git@github.com:Shougo/dein.vim.git "$dir/dein.vim"
    nvim -u "$HOME/.config/nvim/dein.vim" --headless "+call dein#install() | qall"
}

setup_go() {
    [[ -d $HOME/.go ]] && return 0
    msg_box "Setting up Go"
    [[ -d /usr/local/go/bin ]] && export PATH=/usr/local/go/bin:$PATH
    export GOPATH=$HOME/.go
    go install -v golang.org/x/tools/gopls@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest
    go install -v cuelang.org/go/cmd/cue@latest
}

setup_jdk() {
    version="$1"
    vendor="$2"

    jdk_version=$(sdk list java | grep -o "\<$version\.[0-9.]*-$vendor" | sort | head -n 1)
    [[ -z "$jdk_version" ]] && die "No Java $version SDK available"
    sdk install java "$jdk_version"
}

setup_jvm() {
    [[ -d $HOME/.sdkman ]] && return 0
    msg_box "Setting up JVM"

    curl -fsSL "https://get.sdkman.io" | bash
    sed -i '' "s/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g" "$HOME/.sdkman/etc/config"
    sed -i '' "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" "$HOME/.sdkman/etc/config"

    sdkman_sh="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/sdkman.sh"
    curl -fsSL "$sdkman_sh" | bash

    set +u
    # shellcheck source=/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    sdk install gradle
    sdk install kotlin
    sdk install maven
    sdk install mvnd
    sdk install sbt
    set -u

    sed -i '' "s/sdkman_auto_answer=true/sdkman_auto_answer=false/g" "$HOME/.sdkman/etc/config"
}

setup_python() {
    type ipython &> /dev/null && return 0
    msg_box "Setting up Python"

    # Homebrew python includes pip
    if [[ "$os" == "Linux" ]]; then
        curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
        export PATH=$HOME/.local/bin:$PATH
    fi
    python3 -m pip install "${PIP_PKGS[@]}"
}

setup_rust() {
    [[ -d $HOME/.cargo ]] && return 0
    msg_box "Setting up Rust"

    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    [[ "$os" == "Linux" ]] && cargo install -q "${LINUX_CRATES[@]}"
}

setup_code() {
    type code &> /dev/null || return 0
    code --list-extensions | grep dracula-theme.theme-dracula &> /dev/null && return 0
    msg_box "Setting up Visual Studio Code"

    code --install-extension \
        dracula-theme.theme-dracula \
        GitHub.vscode-pull-request-github \
        golang.go \
        ms-azuretools.vscode-docker \
        ms-vscode.cpptools-extension-pack \
        rust-lang.rust-analyzer \
        sswg.swift-lang \
        vadimcn.vscode-lldb
    if [[ "$os" == "Darwin" ]]; then
        defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
    fi
}

setup_fonts() {
    [[ "$os" == "Darwin" ]] || dpkg-query --show xorg &> /dev/null || return 0
    case "$os" in
        Darwin) fonts_dir="$HOME/Library/Fonts" ;;
        Linux) fonts_dir="$HOME/.local/share/fonts" ;;
    esac
    [[ -f "$fonts_dir/Hack-Regular.ttf" ]] && return 0
    msg_box "Setting up fonts"

    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mkdir -p "$fonts_dir"
    mv MesloLGS*.ttf "$fonts_dir"
    [[ "$os" == "Linux" ]] && fc-cache -fv "$HOME/.local/share/fonts"

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
}

setup_zsh() {
    [[ "$SHELL" == "/bin/zsh" ]] || chsh -s /bin/zsh
    [[ "$os" != "Linux" ]] && return 0
    [[ -d "$HOME/.local/share/zsh/site-functions" ]] && return 0
    msg_box "Setting up zsh"

    case "$os" in
        Darwin) rm -rf "$HOME/.bash_profile" "$HOME/.bashrc" ;;
        Linux) cp /etc/skel/.[^.]* "$HOME" ;;
    esac

    # Missing ZSH completions for some packages, e.g. those from Cargo
    completions_sh="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/completions.sh"
    mkdir -p "$HOME/.local/share/zsh/site-functions"
    curl -fsSL "$completions_sh" | bash -s -- "$HOME/.local/share/zsh/site-functions"
}

########################################
# Helper functions
########################################

INSTALL_SH="https://raw.github.com/nevillelyh/dotfiles/master/.dotfiles/files/install.sh"

install() {
    if [[ -s "$basedir/install.sh" ]]; then
        bash "$basedir/install.sh" "$1"
    else
        curl -fsSL "$INSTALL_SH" | bash -s -- "$1"
    fi
}

msg_box() {
    color='\033[1;35m' # magenta
    reset='\033[0m' #reset
    echo -e "${color}╔═${1//[[:ascii:]]/═}═╗${reset}"
    echo -e "${color}║ $1 ║${reset}"
    echo -e "${color}╚═${1//[[:ascii:]]/═}═╝${reset}"
}

die() {
    msg_box "Error: $1"
    exit 1
}

run_check() {
    msg_box "Checking bootstrap"

    ssh git@github.com 2>&1 | grep -q nevillelyh
    case "$os" in
        Darwin) brew --version &> /dev/null ;;
        Linux) aptitude --version &> /dev/null ;;
    esac
    git --version &> /dev/null
    gpg --output - --sign "$HOME/.dotfiles/files/bootstrap.sh" /dev/null
    nvim --headless "+version | qall" &> /dev/null
    go version &> /dev/null
    gopls version &> /dev/null
    sdk version &> /dev/null
    java -version &> /dev/null
    pip3 --version &> /dev/null
    flake8 --version &> /dev/null
    rustup --version &> /dev/null
    cargo --version &> /dev/null
}

get_commands() {
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    cmds=($(grep -o "^setup_\w\+()" "$(readlink -f "$0")" | sed "s/^setup_\(.*\)()$/\1/"))
}

help() {
    echo "Usage: $(basename "$0") [COMMAND]"
    echo "    Commands:"
    echo "        check"
    get_commands
    for cmd in "${cmds[@]}"; do
        echo "        $cmd"
    done
    exit 0
}

########################################
# Script starts
########################################

basedir=$(dirname "$(readlink -f "$0")")
os=$(uname -s)

if [[ $# -eq 1 ]]; then
    case "$1" in
        check) run_check ;;
        help) help ;;
        *)
            get_commands
            if [[ " ${cmds[*]} " =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
                msg_box "Setting up single step $1"
                "setup_$1"
            else
                die "Command not found: $1"
            fi
            ;;
    esac
    exit 0
fi

setup_ssh

case "$os" in
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
setup_go
setup_jvm
setup_python
setup_rust
setup_code
setup_fonts
setup_zsh

# In case install scripts e.g. SDKMAN modify anything by accident
git reset --hard

msg_box "Bootstrap complete"
