#!/bin/bash

# Install third-party packages

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
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
    bs_info "Setting up GPG key $gpg"
    curl -fsSL "$url" | gpg --dearmor > "$gpg"
    sudo install -o root -g root -m 644 "$gpg" /etc/apt/trusted.gpg.d/
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
    sudo aptitude update
}

# https://docs.anaconda.com/anaconda/install/linux/
install_anaconda() {
    # Do not activate base automatically
    echo "auto_activate_base: false" > "$HOME/.condarc"

    brew_install_cask anaconda || return 0

    local url="https://www.anaconda.com/products/distribution"
    url=$(curl -fsSL $url | grep -o "\<https://repo.anaconda.com/archive/Anaconda3-.*-Linux-$BS_UNAME_M.sh\>" | uniq | tail -n 1)
    local pkg
    pkg=$(echo "$url" | grep -o '\<Anaconda3-.*.sh$')
    wget -nv "$url"
    bash "$pkg" -b -p "$HOME/.anaconda3"
    rm "$pkg"
}

install_awscli() {
    brew_install awscli || return 0

    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$BS_UNAME_M.zip" -o awscliv2.zip
    unzip awscliv2.zip
    ./aws/install --install-dir "$HOME/.aws" --bin-dir "$HOME/.local/bin"
    rm -rf awscliv2.zip aws
}

# Chrome manages its own repository
install_chrome() {
    brew_install_cask google-chrome || return 0

    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo aptitude install -fy
    rm google-chrome-stable_current_amd64.deb
}

# https://apt.kitware.com/
install_cmake() {
    brew_install cmake || return 0

    local url="https://apt.kitware.com/keys/kitware-archive-latest.asc"
    local repo
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/kitware-archive-keyring.gpg] https://apt.kitware.com/$(distro)/ $(codename) main"
    setup_gpg "$url" kitware-archive-keyring.gpg
    setup_apt "$repo" kitware.list
    sudo aptitude update
    sudo aptitude install -y cmake kitware-archive-keyring
}

# https://code.visualstudio.com/docs/setup/linux
install_code() {
    brew_install_cask visual-studio-code || return 0

    local url="https://packages.microsoft.com/keys/microsoft.asc"
    local repo="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    setup_gpg "$url" packages.microsoft.gpg
    setup_apt "$repo" vscode.list
    sudo aptitude update
    sudo aptitude install -y code
}

# https://dbeaver.io/download/
install_dbeaver() {
    brew_install_cask dbeaver-community || return 0

    local url="https://dbeaver.io/debs/dbeaver.gpg.key"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /"

    setup_gpg "$url" dbeaver.gpg
    setup_apt "$repo" dbeaver.list
    sudo aptitude update
    sudo aptitude install dbeaver-ce
}

install_discord() {
    brew_install_cask discord || return 0

    local url="https://discordapp.com/api/download/canary?platform=linux&format=deb"
    curl -fsSL "$url" -o discord.deb
    sudo dpkg -i discord.deb
    sudo aptitude install -fy
    rm discord.deb
}

# https://docs.docker.com/engine/install/ubuntu/
install_docker() {
    # Default is ctrl-p, ctrl-q
    mkdir -p "$HOME/.docker"
    echo '{"detachKeys": "ctrl-z,z"}' | jq --indent 4 > "$HOME/.docker/config.json"

    brew_install_cask docker || return 0

    local url
    url="https://download.docker.com/linux/$(distro)/gpg"
    local repo
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg] https://download.docker.com/linux/$(distro) $(codename) stable"
    setup_gpg "$url" docker-archive-keyring.gpg
    setup_apt "$repo" docker.list
    sudo aptitude update
    sudo aptitude install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$(whoami)"
}

# Dropbox manages its own repository
install_dropbox() {
    brew_install_cask dropbox || return 0

    local url
    url="https://linux.dropbox.com/packages/$(distro)/"
    local pkg
    pkg=$(curl -fsSL "$url" | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^dropbox_[\d\.]+_amd64.deb$' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i dropbox_*_amd64.deb
    sudo aptitude install -fy
    rm dropbox_*_amd64.deb
}

# https://cloud.google.com/sdk/docs/install#deb
install_gcloud() {
    brew_install_cask google-cloud-sdk || return 0

    local url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"

    setup_gpg "$url" cloud.google.gpg
    setup_apt "$repo" google-cloud-sdk.list
    sudo aptitude update
    sudo aptitude install google-cloud-cli
}

# https://go.dev/doc/install
install_go() {
    brew_install go || return 0

    local os
    os=$(echo "$BS_UNAME_S" | tr "[:upper:]" "[:lower:]")
    local arch
    arch=$(dpkg --print-architecture)
    tarball=$(curl -fsSL "https://go.dev/dl" | grep -oP '(?<=href=")[^"]+(?=")' | grep "/dl/go.*\.$os-$arch\.tar\.gz" | tac | tail -n 1)
    curl -fsSL "https://go.dev/$tarball" | sudo tar -C /usr/local -xz
}

# https://helm.sh/
install_helm() {
    brew_install helm || return 0
    sudo snap install helm --classic
}

# https://kubernetes.io/docs/tasks/tools/
install_kubectl() {
    brew_install kubectl || return 0

    local url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/cloud.google.gpg] https://apt.kubernetes.io/ kubernetes-xenial main"
    setup_gpg "$url" kubernetes-archive-keyring.gpg
    setup_apt "$repo" kubernetes.list
    sudo aptitude update
    sudo aptitude install -y kubectl
}

# https://minikube.sigs.k8s.io/docs/start/
install_minikube() {
    brew_install minikube || return 0

    local arch
    arch=$(dpkg --print-architecture)
    wget -nv "https://storage.googleapis.com/minikube/releases/latest/minikube_latest_$arch.deb"
    sudo dpkg -i minikube_latest_*.deb
    sudo aptitude install -fy
    rm minikube_latest_*.deb
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
install_nvidia() {
    local url="https://nvidia.github.io/libnvidia-container/gpgkey"
    local repo
    repo=$(curl -fsSL "https://nvidia.github.io/libnvidia-container/$(distro_version)/libnvidia-container.list" | sed 's@deb https://@deb [signed-by=/etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg] https://@g')
    setup_gpg "$url" nvidia-container-toolkit-keyring.gpg
    setup_apt "$repo" nvidia-container-toolkit.list
    sudo aptitude update
    sudo aptitude install -y nvidia-docker2
}

# https://github.com/GloriousEggroll/proton-ge-custom/tree/master#installation
install_proton() {
    local url="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
    local header="Accept: application/vnd.github.v3+json"
    local version
    version=$(curl -fsSL -H "$header" $url | jq --raw-output ".tag_name")
    local tarball
    tarball="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$version/$version.tar.gz"
    curl -fsSL "$tarball" | tar -C "$HOME/.steam/root/compatibilitytools.d" -xz
}

# https://www.retroarch.com/index.php?page=linux-instructions
install_retroarch() {
    brew_install_cask retroarch || return 0
    sudo add-apt-repository ppa:libretro/stable
    sudo aptitude update
    sudo aptitude install retroarch
}

# https://signal.org/download/
install_signal() {
    brew_install_cask signal || return 0
    local url="https://updates.signal.org/desktop/apt/keys.asc"
    local repo="deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main"
    setup_gpg "$url" signal-desktop-keyring.gpg
    setup_apt "$repo" signal-xenial.list
    sudo aptitude update
    sudo aptitude install -y signal-desktop
}

# https://repo.steampowered.com/steam/
install_steam() {
    brew_install_cask steam || return 0

    local url="https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    local line1="deb [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    local line2="deb-src [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    local repo
    repo=$(echo -e "$line1\n$line2")
    setup_gpg "$url" steam.gpg
    setup_apt "$repo" steam.list
    sudo aptitude update
    sudo aptitude install -y steam-launcher
}

# https://www.sublimetext.com/docs/linux_repositories.html
install_sublime() {
    brew_install_cask sublime-text || return 0

    local url="https://download.sublimetext.com/sublimehq-pub.gpg"
    local repo="deb https://download.sublimetext.com/ apt/stable/"
    setup_gpg "$url" sublimehq-pub.gpg
    setup_apt "$repo" sublime-text.list
    sudo aptitude update
    sudo aptitude install -y sublime-text
}

# https://www.swift.org/download/
install_swift() {
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
install_tailscale() {
    brew_install_cask tailscale || return 0

    local url
    url="https://pkgs.tailscale.com/stable/$(distro)/$(codename).noarmor.gpg"
    local repo
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/$(distro) $(codename) main"
    setup_gpg "$url" tailscale-archive-keyring.gpg
    setup_apt "$repo" tailscale.list
    sudo aptitude update
    sudo aptitude install -y tailscale

    sudo tailscale up
}

# https://aka.ms/get-teams-linux
install_teams() {
    brew_install_cask microsoft-teams || return 0

    local url="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/"
    local pkg
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^teams_[\d\.]+_amd64.deb$' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i teams_*_amd64.deb
    sudo aptitude install -fy
    rm teams_*_amd64.deb
}

# https://learn.hashicorp.com/tutorials/terraform/install-cli
install_terraform() {
    brew_install terraform || return 0

    setup_hashicorp
    sudo aptitude install -y terraform
}

# https://www.vaultproject.io/downloads
install_vault() {
    brew_install vault || return 0

    setup_hashicorp
    sudo aptitude install -y vault
}

# https://github.com/retorquere/zotero-deb/blob/master/install.sh
install_zotero() {
    brew_install_cask zotero || return 0

    local url="https://raw.githubusercontent.com/retorquere/zotero-deb/master/zotero-archive-keyring.gpg"
    local repo="deb [signed-by=/etc/apt/trusted.gpg.d/zotero-archive-keyring.gpg by-hash=force] https://zotero.retorque.re/file/apt-package-archive ./"
    setup_gpg "$url" zotero-archive-keyring.gpg
    setup_apt "$repo" zotero.list
    sudo aptitude update
    sudo aptitude install -y zotero
}

get_packages() {
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    pkgs=($(grep -o '^install_\w\+()' "$(readlink -f "$0")" | sed 's/^install_\(.*\)()$/\1/'))
}

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") [PACKAGE]..."
    echo "    Packages:"
    get_packages
    for pkg in "${pkgs[@]}"; do
        echo "        $pkg"
    done
    # exit 1
fi

for pkg in "$@"; do
    # curl | bash, file not available
    if [[ "$0" == "bash" ]]; then
        "install_$pkg"
    else
        get_packages
        if [[ "$(bs_array_contains "$pkg" "${pkgs[@]}")" == 0 ]]; then
            "install_$pkg"
        else
            echo "Package not found: $pkg"
            exit 1
        fi
    fi
done
