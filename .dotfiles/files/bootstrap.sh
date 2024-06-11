#!/bin/bash

# Bootstrap a new environment

# bash -c "$(curl -fsSL bit.ly/bootstrap-sh)"

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

GUI=${GUI:-1}

# Mac packages:
# python - leave macOS bundled python alone
# pinentry-mac - for GPG
# App Store - AdGuard for Safari, Instapaper, Kindle, Messenger, Slack, The Unarchiver, WhatsApp
BREWS=(bat btop cmake colordiff dust eza fd fzf git git-delta gitui golang gpg htop jq mas neovim ninja pinentry-mac python ripgrep shellcheck tmux wget zoxide)
CASKS=(alacritty alfred dbeaver-community discord docker dropbox expressvpn github iterm2 jetbrains-toolbox notion sublime-text tailscale visual-studio-code vimr zotero)
CASKS_OPT=(adobe-creative-cloud anki firefox google-chrome google-cloud-sdk guitar-pro hiarcs-chess-explorer macdive microsoft-edge retroarch signal shearwater-cloud spotify steam subsurface transmission vlc waves-central)
# AdGuard Bitwarden Kindle Magnet Messenger Pocket Slack Unarchiver WhatsApp
MAS=(1440147259 1352778147 405399194 441258766 1480068668 1477385213 803453959 425424353 1147396723)

# Linux packages:
# compton - for alacritty background opacity
# wmctrl - for Slack & Spotify icon fixes
# fonts-powerline - PowerlineSymbols only, no patched fonts
# gnome-screensaver xautolock xcalib - for screen locking in awesome
# libfuse2 - for AppImage, e.g. JetBrains Toolbox, NeoVim
# unzip, zip - for SDKMAN
# Not available or outdated in Ubuntu - bat, git-delta, zoxide
DEB_PKGS=(build-essential colordiff exa fd-find fzf htop jq libfuse2 ninja-build python3-venv ripgrep shellcheck tmux unzip zip zsh)
DEB_GUI_PKGS=(alacritty awesome compton fonts-powerline gnome-screensaver gnome-screenshot ubuntu-restricted-extras vlc wmctrl xautolock xcalib xprintidle)
LINUX_CRATES=(bat du-dust git-delta gitui zoxide)

# PIP packages:
PIP_PKGS=(flake8 ipython requests virtualenv virtualenvwrapper)
BREW_PIP_PKGS=(flake8 ipython python-requests virtualenv virtualenvwrapper)

cmd_ssh() {
    [[ -n "${SSH_CONNECTION-}" ]] && return 0 # remote host
    local keys
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    keys=($(find "$HOME/.ssh" -name id_dsa -or -name id_rsa -or -name id_ecdsa -or -name id_ed25519))
    [[ "${#keys[@]}" -eq 0 ]] && bs_fatal "SSH private key not found"
    killall -q ssh-agent || true
    eval "$(ssh-agent)"
    ssh-add "${keys[@]}"
}

cmd_mac() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    bs_info_box "Setting up Mac specifics"

    read -r -p "Enter hostname: "
    [[ "$(scutil --get ComputerName)" == "$REPLY" ]] && return 0
    sudo scutil --set ComputerName "$REPLY"
    sudo scutil --set HostName "$REPLY"
    sudo scutil --set LocalHostName "$REPLY"
    dscacheutil -flushcache

    bs_warn_box "Restarting"
    sudo shutdown -r
}

cmd_homebrew() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    [[ -L /opt/homebrew/bin/zoxide ]] && return 0
    bs_info_box "Setting up Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install "${BREWS[@]}"
    brew install --cask "${CASKS[@]}"

    read -n 1 -r -p "Install optional casks (y/N)? "
    echo # (optional) move to a new line
    [[ $REPLY =~ ^[Yy]$ ]] && brew install --cask "${CASKS_OPT[@]}"
}

cmd_mac_extras() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    [[ -d "$HOME/.local/share/terminfo" ]] && return 0
    bs_info_box "Setting up Mac extras"

    # https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
    # https://github.com/htop-dev/htop/issues/251
    cd "$HOME"
    wget -nv https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color
    mkdir -p "$HOME/.local/share/terminfo"
    /usr/bin/tic -x -o "$HOME/.local/share/terminfo" "$HOME/tmux-256color"
    rm "$HOME/tmux-256color"

    mas install "${MAS[@]}"
}

cmd_linux() {
    [[ "$BS_UNAME_S" != "Linux" ]] && return 0
    bs_info_box "Setting up Linux specifics"
    # Nothing to do here
}

cmd_apt() {
    [[ "$BS_UNAME_S" != "Linux" ]] && return 0
    type shellcheck &> /dev/null && return 0
    bs_info_box "Setting up Aptitude"

    sudo apt-get install -y apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install -y "${DEB_PKGS[@]}"

    # The following are GUI apps
    [[ $GUI -eq 1 ]] || return 0
    dpkg-query --show xorg &> /dev/null || return 0

    sudo aptitude install -y "${DEB_GUI_PKGS[@]}"
}

cmd_linux_extras() {
    [[ "$BS_UNAME_S" != "Linux" ]] && return 0
    [[ -d /usr/local/go ]] && return 0
    bs_info_box "Setting up Linux extras"

    type nvidia-smi &> /dev/null && sudo aptitude install -y nvtop

    # Third-party packages
    bs_df files/install.sh cmake go

    sudo aptitude install -y snapd
    sudo snap install btop

    # The following are GUI apps
    [[ $GUI -eq 1 ]] || return 0
    dpkg-query --show xorg &> /dev/null || return 0

    sudo snap install btop spotify xseticon
    # Workaround for AppArmor on PopOS
    # https://forum.snapcraft.io/t/apparmor-blocking-the-opening-of-slack/29212
    sudo snap install --devmode slack

    # Custom repositories
    bs_df files/install.sh chrome code discord dropbox sublime

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

cmd_git() {
    [[ -d $HOME/.dotfiles/oh-my-zsh ]] && return 0
    bs_info_box "Setting up Git"

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

cmd_gnupg() {
    [[ -s $HOME/.gnupg/gpg-agent.conf ]] && return 0
    bs_info_box "Setting up GnuPG"

    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"

    echo "default-cache-ttl 7200" >> "$HOME/.gnupg/gpg-agent.conf"
    echo "max-cache-ttl 86400" >> "$HOME/.gnupg/gpg-agent.conf"

    case "$BS_UNAME_S" in
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

cmd_neovim() {
    local dir=$HOME/.local/share/dein/repos/github.com/Shougo
    [[ -d $dir ]] && return 0
    bs_info_box "Setting up NeoVim"

    mkdir -p "$dir"
    git clone git@github.com:Shougo/dein.vim.git "$dir/dein.vim"
    nvim -u "$HOME/.config/nvim/dein.vim" --headless "+call dein#install() | qall"
}

cmd_go() {
    [[ -d $HOME/.go ]] && return 0
    bs_info_box "Setting up Go"
    export GOPATH=$HOME/.go
    go install -v golang.org/x/tools/gopls@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest
    go install -v cuelang.org/go/cmd/cue@latest
}

cmd_jvm() {
    [[ -d $HOME/.sdkman ]] && return 0
    bs_info_box "Setting up JVM"

    curl -fsSL "https://get.sdkman.io" | bash
    bs_sed_i 's/sdkman_rosetta2_compatible=true/sdkman_rosetta2_compatible=false/g' "$HOME/.sdkman/etc/config"
    bs_sed_i 's/sdkman_auto_answer=false/sdkman_auto_answer=true/g' "$HOME/.sdkman/etc/config"

    bs_df files/sdkman.sh

    set +u
    # shellcheck source=/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"

    sdk install gradle
    sdk install kotlin
    sdk install maven
    sdk install mvnd
    sdk install sbt
    set -u

    bs_sed_i 's/sdkman_auto_answer=true/sdkman_auto_answer=false/g' "$HOME/.sdkman/etc/config"
}

cmd_python() {
    type ipython &> /dev/null && return 0
    bs_info_box "Setting up Python"

    case "$BS_UNAME_S" in
        Darwin)
            brew install "${BREW_PIP_PKGS[@]}"
            ;;
        Linux)
            curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
            python3 -m pip install "${PIP_PKGS[@]}"
            ;;
    esac
}

cmd_rust() {
    [[ -d $HOME/.cargo ]] && return 0
    bs_info_box "Setting up Rust"

    curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    [[ "$BS_UNAME_S" == "Linux" ]] && cargo install -q "${LINUX_CRATES[@]}"
}

cmd_code() {
    type code &> /dev/null || return 0
    code --list-extensions | grep 'dracula-theme\.theme-dracula' &> /dev/null && return 0
    bs_info_box "Setting up Visual Studio Code"

    extensions=(
        dracula-theme.theme-dracula
        GitHub.vscode-pull-request-github
        golang.go
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.python
        ms-vscode.cpptools-extension-pack
        rust-lang.rust-analyzer
        sswg.swift-lang
        vadimcn.vscode-lldb
        zxh404.vscode-proto3
    )
    for ext in "${extensions[@]}"; do
        code --install-extension "$ext"
    done
    [[ "$BS_UNAME_S" != "Darwin" ]] || defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
}

cmd_fonts() {
    [[ $GUI -eq 1 ]] || return 0
    [[ "$BS_UNAME_S" == "Darwin" ]] || dpkg-query --show xorg &> /dev/null || return 0
    case "$BS_UNAME_S" in
        Darwin) fonts_dir="$HOME/Library/Fonts" ;;
        Linux) fonts_dir="$HOME/.local/share/fonts" ;;
    esac
    [[ -f "$fonts_dir/Hack-Regular.ttf" ]] && return 0
    bs_info_box "Setting up fonts"

    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -nv https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mkdir -p "$fonts_dir"
    mv MesloLGS*.ttf "$fonts_dir"
    [[ "$BS_UNAME_S" == "Linux" ]] && fc-cache -fv "$HOME/.local/share/fonts"

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
}

cmd_zsh() {
    [[ "$SHELL" == "/bin/zsh" ]] || chsh -s /bin/zsh
    [[ "$BS_UNAME_S" != "Linux" ]] && return 0
    [[ -d "$HOME/.local/share/zsh/site-functions" ]] && return 0
    bs_info_box "Setting up zsh"

    case "$BS_UNAME_S" in
        Darwin) rm -rf "$HOME/.bash_profile" "$HOME/.bashrc" ;;
        Linux) cp /etc/skel/.[^.]* "$HOME" ;;
    esac

    # Missing ZSH completions for some packages, e.g. those from Cargo
    bs_df files/completions.sh
}

cmd_check() {
    bs_info_box "Checking bootstrap"

    ssh git@github.com 2>&1 | grep -q nevillelyh
    case "$BS_UNAME_S" in
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

########################################
# Script starts
########################################

case "$BS_UNAME_S" in
    Darwin)
        export PATH=/opt/homebrew/bin:$PATH
        export PATH=$HOME/.local/bin:$PATH
        ;;
    Linux)
        export PATH=/usr/local/go/bin:$PATH
        ;;
esac
export PATH=$HOME/.dotfiles/bin:$PATH

bootstrap() {
    cmd_ssh

    case "$BS_UNAME_S" in
        Darwin)
            cmd_mac
            cmd_homebrew
            cmd_mac_extras
            ;;
        Linux)
            cmd_linux
            cmd_apt
            cmd_linux_extras
            ;;
    esac

    cmd_git
    cmd_gnupg
    cmd_neovim
    cmd_go
    cmd_jvm
    cmd_python
    cmd_rust
    cmd_code
    cmd_fonts
    cmd_zsh

    # In case install scripts e.g. SDKMAN modify anything by accident
    git reset --hard

    bs_info_box "Bootstrap complete"
}

bs_cmd_optional bootstrap "$@"
