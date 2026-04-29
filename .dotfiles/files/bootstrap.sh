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

BREWS=(
    age
    anomalyco/tap/opencode
    argocd
    awscli
    b2-tools
    bat
    bazelisk
    bitwarden-cli
    btop
    cfssl
    cmake
    colordiff
    coursier
    curl
    dust
    eza
    fd
    flatbuffers
    fnm
    fzf
    gh
    git
    git-delta
    gitea
    gitui
    golang
    gpg
    helm
    htop
    jq
    k3d
    k9s
    kconf
    kind
    kubectl
    kubectx
    kustomize
    lazydocker
    minikube
    neovim
    ninja
    oven-sh/bun/bun
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    ripgrep
    rustup
    shellcheck
    sops
    talosctl
    tmux
    tree-sitter-cli
    uv
    wget
    yamlfmt
    zoxide
)
CASKS=(
    claude-code
    codex
    copilot-cli
    gcloud-cli
    gemini-cli
)
FLATPAKS=(
    com.bitwarden.desktop
)
FLATPAKS_OPT=(
    com.discordapp.Discord
    com.plexamp.Plexamp
    org.libretro.RetroArch
)
readonly -a BREWS CASKS FLATPAKS

MAC_BREWS=(mas pinentry-mac)
MAC_CASKS=(
    alacritty
    alfred
    antigravity
    chatgpt
    claude
    codex-app
    cursor
    dbeaver-community
    discord
    docker
    dropbox
    github
    iterm2
    jetbrains-toolbox
    markedit
    notion
    scroll-reverser
    sublime-text
    tailscale
    vimr
    visual-studio-code
    zotero
)
MAC_CASKS_OPT=(
    adobe-creative-cloud
    anki
    firefox
    google-chrome
    guitar-pro
    hiarcs-chess-explorer
    macdive
    microsoft-edge
    plexamp
    protonvpn
    retroarch
    shearwater-cloud
    signal
    spotify
    steam
    subsurface
    transmission
    vlc
    waves-central
)
MAS=(
    1440147259 # AdGuard
    1352778147 # Bitwarden
    302584613  # Kindle
    441258766  # Magnet
    803453959  # Slack
    425424353  # Unarchiver
    310633997  # WhatsApp
)
readonly -a MAC_BREWS MAC_CASKS MAC_CASKS_OPT MAS

LINUX_BREWS=(nerdctl swift)
DEB_PKGS=(build-essential dnsutils libfuse2 lm-sensors nvme-cli smartmontools wl-clipboard zsh)
DEB_GUI_PKGS=(alacritty fonts-powerline ubuntu-restricted-extras vlc)
readonly -a LINUX_BREWS DEB_PKGS DEB_GUI_PKGS

cmd_ssh() {
    [[ -f "$HOME/.bootstrap-ssh" ]] && return 0
    local -a keys
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    keys=($(find "$HOME/.ssh" -type f -name 'id_*' ! -name '*.pub'))
    [[ "${#keys[@]}" -eq 0 ]] && bs_fatal "SSH private key not found"
    killall -q ssh-agent || true
    eval "$(ssh-agent)"
    ssh-add "${keys[@]}"
    touch "$HOME/.bootstrap-ssh"
}

cmd_homebrew() {
    [[ -f "$HOME/.bootstrap-homebrew" ]] && return 0
    bs_info_box "Setting up Homebrew"

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install "${BREWS[@]}"
    brew install "${CASKS[@]}"
    case "$BS_UNAME_S" in
        Darwin)
            brew install "${MAC_BREWS[@]}"
            brew install --cask "${MAC_CASKS[@]}"
            read -n 1 -r -p "Install optional casks? (y/N) "
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && brew install --cask "${MAC_CASKS_OPT[@]}"
            ;;
        Linux)
            brew install "${LINUX_BREWS[@]}"
            ;;
    esac

    touch "$HOME/.bootstrap-homebrew"
}

cmd_mac() {
    [[ -f "$HOME/.bootstrap-mac" ]] && return 0
    bs_info_box "Setting up Mac specifics"

    read -r -p "Enter hostname: "
    sudo scutil --set ComputerName "$REPLY"
    sudo scutil --set HostName "$REPLY"
    sudo scutil --set LocalHostName "$REPLY"
    dscacheutil -flushcache

    touch "$HOME/.bootstrap-mac"

    bs_warn_box "Restarting"
    sudo shutdown -r
}

cmd_mac_extras() {
    [[ -f "$HOME/.bootstrap-mac-extras" ]] && return 0
    bs_info_box "Setting up Mac extras"

    # https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
    # https://github.com/htop-dev/htop/issues/251
    cd "$HOME"
    wget -nv https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color
    mkdir -p "$HOME/.local/share/terminfo"
    /usr/bin/tic -x -o "$HOME/.local/share/terminfo" "$HOME/tmux-256color"
    rm "$HOME/tmux-256color"

    # https://github.com/MarkEdit-app/MarkEdit-preview
    dir=Library/Containers/app.cyan.markedit/Data/Documents/scripts
    mkdir -p "$dir"
    wget -nv https://raw.githubusercontent.com/MarkEdit-app/MarkEdit-preview/refs/heads/main/dist/markedit-preview.js -O "$dir/markedit-preview.js"

    mas install "${MAS[@]}"

    touch "$HOME/.bootstrap-mac-extras"
}

cmd_linux() {
    [[ -f "$HOME/.bootstrap-linux" ]] && return 0
    bs_info_box "Setting up Linux specifics"

    # Nothing to do here

    touch "$HOME/.bootstrap-linux"
}

cmd_apt() {
    [[ -f "$HOME/.bootstrap-apt" ]] && return 0
    bs_info_box "Setting up Aptitude"

    sudo apt-get install -y apt-transport-https aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install -y "${DEB_PKGS[@]}"

    # The following are GUI apps
    if dpkg-query --show xserver-xorg &> /dev/null; then
        sudo aptitude install -y "${DEB_GUI_PKGS[@]}"
    fi

    touch "$HOME/.bootstrap-apt"
}

cmd_linux_extras() {
    [[ -f "$HOME/.bootstrap-linux-extras" ]] && return 0
    bs_info_box "Setting up Linux extras"

    command -v nvidia-smi &> /dev/null && brew install nvtop

    # The following are GUI apps
    if dpkg-query --show xserver-xorg &> /dev/null; then
        flatpak install --assumeyes "${FLATPAKS[@]}"
        read -n 1 -r -p "Install optional flatpaks? (y/N) "
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && flatpak install --assumeyes "${FLATPAKS_OPT[@]}"

        # Custom repositories
        bs_df files/install.sh code sublime
        # FIXME: not available for Linux arm64
        [[ "$BS_UNAME_M" != x86_64 ]] || bs_df files/install.sh chrome dropbox
    fi

    touch "$HOME/.bootstrap-linux-extras"
}

cmd_git() {
    [[ -f "$HOME/.bootstrap-git" ]] && return 0
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

    touch "$HOME/.bootstrap-git"
}

cmd_gnupg() {
    [[ -f "$HOME/.bootstrap-gnupg" ]] && return 0
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

    touch "$HOME/.bootstrap-gnupg"
}

cmd_venv() {
    [[ -f "$HOME/.bootstrap-venv" ]] && return 0
    bs_info_box "Setting up venv"

    uv venv --color always --seed --prompt '' "$HOME/.venv"
    source "$HOME/.venv/bin/activate"
    python3 --version

    touch "$HOME/.bootstrap-venv"
}

cmd_neovim() {
    [[ -f "$HOME/.bootstrap-neovim" ]] && return 0
    bs_info_box "Setting up NeoVim"

    nvim --headless '+Lazy! update' '+Lazy! clean' +qa
    nvim --headless '+lua TSInstallParsers():wait(300000)' +qa

    touch "$HOME/.bootstrap-neovim"
}

cmd_fnm() {
    [[ -f "$HOME/.bootstrap-fnm" ]] && return 0
    bs_info_box "Setting up FNM"

    fnm install --lts

    touch "$HOME/.bootstrap-fnm"
}

cmd_go() {
    [[ -f "$HOME/.bootstrap-go" ]] && return 0
    bs_info_box "Setting up Go"

    export GOPATH="$HOME/.go"
    go install -v golang.org/x/tools/gopls@latest
    go install -v github.com/go-delve/delve/cmd/dlv@latest
    go install -v cuelang.org/go/cmd/cue@latest

    touch "$HOME/.bootstrap-go"
}

cmd_jvm() {
    [[ -f "$HOME/.bootstrap-jvm" ]] && return 0
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
    # FIXME: not available for Linux arm64
    [[ "$BS_UNAME_S-$BS_UNAME_M" != Linux-x86_64 ]] || sdk install mvnd
    sdk install sbt
    set -u

    bs_sed_i 's/sdkman_auto_answer=true/sdkman_auto_answer=false/g' "$HOME/.sdkman/etc/config"

    brew install coursier
    coursier install metals

    touch "$HOME/.bootstrap-jvm"
}

cmd_code() {
    [[ -f "$HOME/.bootstrap-code" ]] && return 0
    bs_info_box "Setting up Visual Studio Code"

    if [[ "$BS_UNAME_S" != "Darwin" ]]; then
        defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
    fi

    touch "$HOME/.bootstrap-code"
}

cmd_fonts() {
    [[ -f "$HOME/.bootstrap-fonts" ]] && return 0
    bs_info_box "Setting up fonts"

    if [[ "$BS_UNAME_S" == Darwin ]] || dpkg-query --show xserver-xorg &> /dev/null; then
        local fonts_dir
        case "$BS_UNAME_S" in
            Darwin) fonts_dir="$HOME/Library/Fonts" ;;
            Linux) fonts_dir="$HOME/.local/share/fonts" ;;
        esac

        local prefix="https://github.com/romkatv/powerlevel10k-media/raw/master"
        wget -nv "$prefix/MesloLGS%20NF%20Regular.ttf"
        wget -nv "$prefix/MesloLGS%20NF%20Bold.ttf"
        wget -nv "$prefix/MesloLGS%20NF%20Italic.ttf"
        wget -nv "$prefix/MesloLGS%20NF%20Bold%20Italic.ttf"
        mkdir -p "$fonts_dir"
        mv MesloLGS*.ttf "$fonts_dir"
        [[ "$BS_UNAME_S" == Linux ]] && fc-cache -fv "$HOME/.local/share/fonts"

        git clone https://github.com/powerline/fonts
        cd fonts
        ./install.sh
        cd ..
        rm -rf fonts
    fi

    touch "$HOME/.bootstrap-fonts"
}

cmd_zsh() {
    [[ -f "$HOME/.bootstrap-zsh" ]] && return 0

    [[ "$SHELL" == /bin/zsh ]] || chsh -s /bin/zsh
    [[ "$BS_UNAME_S" != Linux ]] && return 0
    bs_info_box "Setting up zsh"

    case "$BS_UNAME_S" in
        Darwin) rm -rf "$HOME/.bash_profile" "$HOME/.bashrc" ;;
        Linux) cp /etc/skel/.[^.]* "$HOME" ;;
    esac

    touch "$HOME/.bootstrap-zsh"
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
        export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
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
            cmd_homebrew
            cmd_linux_extras
            ;;
    esac

    cmd_git
    cmd_gnupg
    cmd_venv  # NeoVim needs Python
    cmd_neovim
    cmd_fnm
    cmd_go
    cmd_jvm
    cmd_code
    cmd_fonts
    cmd_zsh

    # In case install scripts e.g. SDKMAN modify anything by accident
    git reset --hard

    rm -rf "$HOME"/.bootstrap-*
    bs_info_box "Bootstrap complete"
}

bs_cmd_optional bootstrap "$@"
