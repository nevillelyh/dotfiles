#!/bin/bash

# Install third-party packages

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

brew_install() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    brew install "$@"
    return 1
}

brew_install_cask() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    brew install --cask "$@"
    return 1
}

brew_install_hashicorp() {
    [[ "$BS_UNAME_S" != "Darwin" ]] && return 0
    brew tap hashicorp/tap
    for f in "$@"; do
        brew install "hashicorp/tap/$f"
    done
    return 1
}

distro() {
    local id
    id=$(lsb_release -is | tr "[:upper:]" "[:lower:]")
    case "$id" in
        pop) echo ubuntu ;;
        *) echo "$id" ;;
    esac
}

distro_version() {
    echo "$(distro)$(lsb_release -rs)"
}

codename() {
    lsb_release -cs
}

setup_gpg() {
    local url=$1
    local gpg=$2
    local dst=${3:-/etc/apt/trusted.gpg.d}
    bs_info "Setting up GPG key $gpg"
    curl -fsSL "$url" | gpg --dearmor > "$gpg"
    sudo install -o root -g root -m 644 "$gpg" "$dst"
    rm "$gpg"
}

setup_apt() {
    local repo=$1
    local list=$2
    bs_info "Setting up APT repo $list"
    echo "$repo" | sudo tee "/etc/apt/sources.list.d/$list" > /dev/null
}

setup_hashicorp() {
    local url="https://apt.releases.hashicorp.com/gpg"
    local repo
    repo="deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(codename) main"
    setup_gpg "$url" hashicorp.gpg
    setup_apt "$repo" hashicorp.list
    sudo apt-get update
}

# https://support.1password.com/install-linux/
cmd_1password() {
    brew_install 1password 1password-cli || return 0

    local url="https://downloads.1password.com/linux/keys/1password.asc"
    local repo
    repo="deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main"
    setup_gpg "$url" 1password-archive-keyring.gpg
    setup_apt "$repo" 1password.list
    sudo apt-get update
    sudo apt-get install -y 1password 1password-cli
}

# https://docs.ankiweb.net/platform/linux/installing.html
cmd_anki() {
    brew_install_cask anki || return 0

    local url="https://apps.ankiweb.net/"
    url=$(bs_urls "$url" | grep -- "-linux-qt6.tar.zst$")
    curl -fsSL "$url" | tar -C "$HOME" -x --zstd
    local dir
    dir="$(basename "$url" ".tar.zst")"
    cd "$dir"
    sudo ./install.sh
    rm -rf "${HOME:?}/$dir"
}

cmd_awscli() {
    brew_install awscli || return 0

    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$BS_UNAME_M.zip" -o awscliv2.zip
    unzip awscliv2.zip
    ./aws/install --install-dir "$HOME/.aws" --bin-dir "$HOME/.local/bin"
    rm -rf awscliv2.zip aws
}

cmd_btop() {
    brew_install btop || return 0

    git clone git@github.com:aristocratos/btop.git
    cd btop
    make
    PREFIX=$HOME/.local make install
    cd ..
    rm -rf btop
}

# Chrome manages its own repository
cmd_chrome() {
    brew_install_cask google-chrome || return 0

    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg --install --force-all google-chrome-stable_current_amd64.deb
    sudo apt-get install -fy
    rm google-chrome-stable_current_amd64.deb
}

# https://apt.kitware.com/
cmd_cmake() {
    brew_install cmake || return 0

    local url="https://apt.kitware.com/keys/kitware-archive-latest.asc"
    local repo
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/kitware-archive-keyring.gpg] https://apt.kitware.com/$(distro)/ $(codename) main"
    setup_gpg "$url" kitware-archive-keyring.gpg
    setup_apt "$repo" kitware.list
    sudo apt-get update
    sudo apt-get install -y cmake kitware-archive-keyring
}

# https://code.visualstudio.com/docs/setup/linux
cmd_code() {
    brew_install_cask visual-studio-code || return 0

    local url="https://packages.microsoft.com/keys/microsoft.asc"
    local repo="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    setup_gpg "$url" packages.microsoft.gpg
    setup_apt "$repo" vscode.list
    sudo apt-get update
    sudo apt-get install -y code
}

# https://dbeaver.io/download/
cmd_dbeaver() {
    brew_install_cask dbeaver-community || return 0

    local url="https://dbeaver.io/debs/dbeaver.gpg.key"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /"

    setup_gpg "$url" dbeaver.gpg
    setup_apt "$repo" dbeaver.list
    sudo apt-get update
    sudo apt-get install dbeaver-ce
}

cmd_discord() {
    brew_install_cask discord || return 0

    local url="https://discord.com/api/download?platform=linux&format=deb"
    curl -fsSL "$url" -o discord.deb
    sudo dpkg --install --force-all discord.deb
    sudo apt-get install -fy
    rm discord.deb
}

# https://docs.docker.com/engine/install/ubuntu/
cmd_docker() {
    # Default is ctrl-p, ctrl-q
    mkdir -p "$HOME/.docker"
    printf '{\n    "detachKeys": "ctrl-z,z"\n}\n' > "$HOME/.docker/config.json"

    brew_install_cask docker || return 0

    local url
    url="https://download.docker.com/linux/$(distro)/gpg"
    local repo
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg] https://download.docker.com/linux/$(distro) $(codename) stable"
    setup_gpg "$url" docker-archive-keyring.gpg
    setup_apt "$repo" docker.list
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$(whoami)"
}

# Dropbox manages its own repository
cmd_dropbox() {
    brew_install_cask dropbox || return 0

    local url
    url="https://linux.dropbox.com/packages/$(distro)/"
    local pkg
    pkg=$(curl -fsSL "$url" | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^dropbox_[\d\.]+_amd64.deb$' | grep '2020\.03\.04' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg --install --force-all dropbox_*_amd64.deb
    sudo apt-get install -fy
    rm dropbox_*_amd64.deb
}

# https://cloud.google.com/sdk/docs/install#deb
cmd_gcloud() {
    brew_install_cask google-cloud-sdk || return 0

    local url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"

    setup_gpg "$url" cloud.google.gpg
    setup_apt "$repo" google-cloud-sdk.list
    sudo apt-get update
    sudo apt-get install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin
}

# https://go.dev/doc/install
cmd_go() {
    brew_install go || return 0

    local os
    os=$(echo "$BS_UNAME_S" | tr "[:upper:]" "[:lower:]")
    local arch
    arch=$(dpkg --print-architecture)
    tarball=$(curl -fsSL "https://go.dev/dl" | grep -oP '(?<=href=")[^"]+(?=")' | grep "/dl/go.*\.$os-$arch\.tar\.gz" | tac | tail -n 1)
    curl -fsSL "https://go.dev/$tarball" | sudo tar -C /usr/local -xz
}

# https://helm.sh/
cmd_helm() {
    brew_install helm || return 0

    local url="https://baltocdn.com/helm/signing.asc"
    local repo
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main"
    setup_gpg "$url" helm.gpg
    setup_apt "$repo" helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install -y helm
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
cmd_nvidia() {
    local url="https://nvidia.github.io/libnvidia-container/gpgkey"
    local repo
    repo=$(curl -fsSL "https://nvidia.github.io/libnvidia-container/$(distro_version)/libnvidia-container.list" | sed 's@deb https://@deb [signed-by=/etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg] https://@g')
    setup_gpg "$url" nvidia-container-toolkit-keyring.gpg
    setup_apt "$repo" nvidia-container-toolkit.list
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
}

cmd_packer() {
    brew_install_hashicorp packer || return 0

    setup_hashicorp
    sudo apt-get install -y packer
}

# https://github.com/GloriousEggroll/proton-ge-custom/tree/master#installation
cmd_proton() {
    local url="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
    local header="Accept: application/vnd.github.v3+json"
    local version
    version=$(curl -fsSL -H "$header" $url | jq --raw-output ".tag_name")
    local tarball
    tarball="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$version/$version.tar.gz"
    curl -fsSL "$tarball" | tar -C "$HOME/.steam/root/compatibilitytools.d" -xz
}

# https://www.retroarch.com/index.php?page=linux-instructions
cmd_retroarch() {
    brew_install_cask retroarch || return 0
    sudo add-apt-repository ppa:libretro/stable
    sudo apt-get update
    sudo apt-get install retroarch
}

# https://signal.org/download/
cmd_signal() {
    brew_install_cask signal || return 0
    local url="https://updates.signal.org/desktop/apt/keys.asc"
    local repo="deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main"
    setup_gpg "$url" signal-desktop-keyring.gpg
    setup_apt "$repo" signal-xenial.list
    sudo apt-get update
    sudo apt-get install -y signal-desktop
}

# https://repo.steampowered.com/steam/
cmd_steam() {
    brew_install_cask steam || return 0

    local url="https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    local line1="deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] http://repo.steampowered.com/steam/ stable steam"
    local line2="deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] http://repo.steampowered.com/steam/ stable steam"
    local repo
    repo=$(echo -e "$line1\n$line2")
    setup_gpg "$url" steam.gpg /usr/share/keyrings
    setup_apt "$repo" steam-stable.list
    sudo apt-get update
    sudo apt-get install -y steam-launcher
}

# https://www.sublimetext.com/docs/linux_repositories.html
cmd_sublime() {
    brew_install_cask sublime-text || return 0

    local url="https://download.sublimetext.com/sublimehq-pub.gpg"
    local repo="deb https://download.sublimetext.com/ apt/stable/"
    setup_gpg "$url" sublimehq-pub.gpg
    setup_apt "$repo" sublime-text.list
    sudo apt-get update
    sudo apt-get install -y sublime-text
}

# https://www.swift.org/download/
cmd_swift() {
    local dist
    dist="$(distro_version)"
    [[ "$BS_UNAME_M" == "aarch64" ]] && dist="$dist-aarch64"
    local url="https://www.swift.org/download/"

    url=$(curl -fsSL --compressed $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P "$dist.tar.gz\$" | tac | tail -n 1)
    local base
    base=$(basename --suffix .tar.gz "$url")
    curl -fsSL "$url" | tar -C "$HOME" -xz
    rm -rf "$HOME/.swift"
    mv "$HOME/$base" "$HOME/.swift"
}

# https://tailscale.com/download/linux/ubuntu-2204
cmd_tailscale() {
    brew_install_cask tailscale || return 0

    local url
    url="https://pkgs.tailscale.com/stable/$(distro)/$(codename).noarmor.gpg"
    local repo
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/$(distro) $(codename) main"
    setup_gpg "$url" tailscale-archive-keyring.gpg
    setup_apt "$repo" tailscale.list
    sudo apt-get update
    sudo apt-get install -y tailscale

    sudo tailscale up
}

# https://aka.ms/get-teams-linux
cmd_teams() {
    brew_install_cask microsoft-teams || return 0

    local url="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/"
    local pkg
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^teams_[\d\.]+_amd64.deb$' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg --install --force-all teams_*_amd64.deb
    sudo apt-get install -fy
    rm teams_*_amd64.deb
}

# https://learn.hashicorp.com/tutorials/terraform/install-cli
cmd_terraform() {
    brew_install_hashicorp terraform || return 0

    setup_hashicorp
    sudo apt-get install -y terraform
}

# https://www.vaultproject.io/downloads
cmd_vault() {
    brew_install_hashicorp vault || return 0

    setup_hashicorp
    sudo apt-get install -y vault
}

# https://github.com/retorquere/zotero-deb/blob/master/install.sh
cmd_zotero() {
    brew_install_cask zotero || return 0

    local url="https://raw.githubusercontent.com/retorquere/zotero-deb/master/zotero-archive-keyring.gpg"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/zotero-archive-keyring.gpg by-hash=force] https://zotero.retorque.re/file/apt-package-archive ./"
    setup_gpg "$url" zotero-archive-keyring.gpg
    setup_apt "$repo" zotero.list
    sudo apt-get update
    sudo apt-get install -y zotero
}

bs_cmd_required "$@"
