#!/bin/bash

# Install third-party packages

set -euo pipefail

brew_install() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        brew install "$@"
        [[ $(type -t post_brew) == "function" ]] && post_brew
        exit 0
    fi
}

brew_install_cask() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        brew install --cask "$@"
        [[ $(type -t post_brew) == "function" ]] && post_brew
        exit 0
    fi
}

setup_gpg() {
    url=$1
    gpg=$2
    echo "Setting up GPG key $gpg"
    curl -fsSL "$url" | gpg --dearmor > "$gpg"
    sudo install -o root -g root -m 644 "$gpg" /etc/apt/trusted.gpg.d/
    rm "$gpg"
}

setup_apt() {
    repo=$1
    list=$2
    echo "Setting up APT repo $list"
    echo "$repo" | sudo tee "/etc/apt/sources.list.d/$list" > /dev/null
}

setup_hashicorp() {
    url="https://apt.releases.hashicorp.com/gpg"
    repo="deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    setup_gpg "$url" hashicorp.gpg
    setup_apt "$repo" hashicorp.list
    sudo aptitude update
}

# https://docs.anaconda.com/anaconda/install/linux/
install_anaconda() {
    # Do not activate base automatically
    echo "auto_activate_base: false" > "$HOME/.condarc"

    brew_install_cask anaconda

    url="https://www.anaconda.com/products/distribution"
    arch=$(uname -m)
    url=$(curl -fsSL $url | grep -o "\<https://repo.anaconda.com/archive/Anaconda3-.*-Linux-$arch.sh\>" | uniq | tail -n 1)
    pkg=$(echo "$url" | grep -o "\<Anaconda3-.*.sh$")
    wget -nv "$url"
    bash "$pkg" -b -p "$HOME/.anaconda3"
    rm "$pkg"
}

install_awscli() {
    brew_install awscli

    arch=$(uname -m)
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$arch.zip" -o awscliv2.zip
    unzip awscliv2.zip
    ./aws/install --install-dir "$HOME/.aws" --bin-dir "$HOME/.local/bin"
    rm -rf awscliv2.zip aws
}

# Chrome manages its own repository
install_chrome() {
    brew_install_cask google-chrome

    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
}

# Prefer Ubuntu instead
# https://apt.kitware.com/
install_cmake() {
    brew_install cmake

    url="https://apt.kitware.com/keys/kitware-archive-latest.asc"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main"
    setup_gpg "$url" kitware-archive-keyring.gpg
    setup_apt "$repo" kitware.list
    sudo aptitude update
    sudo aptitude install -y cmake kitware-archive-keyring
}

# https://code.visualstudio.com/docs/setup/linux
install_code() {
    brew_install_cask visual-studio-code

    url="https://packages.microsoft.com/keys/microsoft.asc"
    repo="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    setup_gpg "$url" packages.microsoft.gpg
    setup_apt "$repo" vscode.list
    sudo aptitude update
    sudo aptitude install -y code
}

# https://dbeaver.io/download/
install_dbeaver() {
    brew_install_cask dbeaver-community

    url="https://dbeaver.io/debs/dbeaver.gpg.key"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /"

    setup_gpg "$url" dbeaver.gpg
    setup_apt "$repo" dbeaver.list
    sudo aptitude update
    sudo aptitude install dbeaver-ce
}

# https://docs.docker.com/engine/install/ubuntu/
install_docker() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Which container runtime to install?"
        echo " [1] Docker Desktop"
        echo " [2] Colima"
        read -p "Enter number: " -n 1 -r
        echo # (optional) move to a new line
        case "$REPLY" in
            1)
                brew install --cask docker
                ;;
            2)
                brew install colima docker docker-compose
                mkdir -p "$HOME/.docker/cli-plugins"
                ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose "$HOME/.docker/cli-plugins/docker-compose"
                ;;
            *)
                exit 1
                ;;
        esac
    else
        url="https://download.docker.com/linux/ubuntu/gpg"
        repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        setup_gpg "$url" docker-archive-keyring.gpg
        setup_apt "$repo" docker.list
        sudo aptitude update
        sudo aptitude install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    # Default is ctrl-p, ctrl-q
    echo '{"detachKeys": "ctrl-z,z"}' | jq --indent 4 > "$HOME/.docker/config.json"
}

# Dropbox manages its own repository
install_dropbox() {
    brew_install_cask dropbox

    url="https://linux.dropbox.com/packages/ubuntu/"
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P "^dropbox_[\d\.]+_amd64.deb$" | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i dropbox_*_amd64.deb
    rm -f dropbox_*_amd64.deb
}

# https://cloud.google.com/sdk/docs/install#deb
install_gcloud() {
    brew_install_cask google-cloud-sdk

    arch=$(uname -m)
    url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"

    setup_gpg "$url" cloud.google.gpg
    setup_apt "$repo" google-cloud-sdk.list
    sudo aptitude update
    sudo aptitude install google-cloud-cli
}


# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
install_github() {
    brew_install gh

    url="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
    setup_gpg "$url" githubcli-archive-keyring.gpg
    setup_apt "$repo" github-cli.list
    sudo aptitude update
    sudo aptitude install -y gh
}

# https://go.dev/doc/install
install_go() {
    brew_install go

    os=$(uname -s | tr "[:upper:]" "[:lower:]")
    arch=$(dpkg --print-architecture)
    tarball=$(curl -fsSL "https://go.dev/dl" | grep -oP '(?<=href=")[^"]+(?=")' | grep "/dl/go.*\.$os-$arch\.tar\.gz" | tac | tail -n 1)
    curl -fsSL "https://go.dev/$tarball" | sudo tar -C /usr/local -xz
}

# https://helm.sh/
install_helm() {
    brew_install helm
    sudo snap install helm --classic
}

# https://kubernetes.io/docs/tasks/tools/
install_kubectl() {
    brew_install kubectl

    url="https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main"
    setup_gpg "$url" kubernetes-archive-keyring.gpg
    setup_apt "$repo" kubernetes.list
    sudo aptitude update
    sudo aptitude install -y kubectl
}

# https://minikube.sigs.k8s.io/docs/start/
install_minikube() {
    brew_install minikube

    arch=$(dpkg --print-architecture)
    wget -nv "https://storage.googleapis.com/minikube/releases/latest/minikube_latest_$arch.deb"
    sudo dpkg -i minikube_latest_*.deb
    rm minikube_latest_*.deb
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
install_nvidia() {
    url="https://nvidia.github.io/libnvidia-container/gpgkey"
    dist="ubuntu$(lsb_release -rs)"
    repo=$(curl -fsSL "https://nvidia.github.io/libnvidia-container/$dist/libnvidia-container.list" | sed "s#deb https://#deb [signed-by=/etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg] https://#g")
    setup_gpg "$url" nvidia-container-toolkit-keyring.gpg
    setup_apt "$repo" nvidia-container-toolkit.list
    sudo aptitude update
    sudo aptitude install -y nvidia-docker2
}

# https://github.com/GloriousEggroll/proton-ge-custom/tree/master#installation
install_proton() {
    url="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
    header="Accept: application/vnd.github.v3+json"
    version=$(curl -fsSL -H "$header" $url | jq --raw-output ".tag_name")
    tarball="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$version/$version.tar.gz"
    curl -fsSL "$tarball" | tar -C "$HOME/.steam/root/compatibilitytools.d" -xz
}

# https://signal.org/download/
install_signal() {
    brew_install_cask signal
    url="https://updates.signal.org/desktop/apt/keys.asc"
    repo="deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main"
    setup_gpg "$url" signal-desktop-keyring.gpg
    setup_apt "$repo" signal-xenial.list
    sudo aptitude update
    sudo aptitude install -y signal-desktop
}

# Prefer snap instead
# https://packagecloud.io/app/slacktechnologies/slack/gpg#gpg-apt
install_slack() {
    brew_install_cask slack

    url="https://packagecloud.io/slacktechnologies/slack/gpgkey"
    repo=$(curl -fsSL "https://packagecloud.io/install/repositories/slacktechnologies/slack/config_file.list?os=debian&dist=jessie&source=script")
    setup_gpg "$url" slacktechnologies_slack.gpg
    setup_apt "$repo" slacktechnologies_slack.list
    sudo aptitude update
    sudo aptitude install -y slack-desktop
}

# Prefer snap instead
# https://www.spotify.com/us/download/linux/
install_spotify() {
    brew_install_cask spotify

    url="https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg"
    repo="deb http://repository.spotify.com stable non-free"
    setup_gpg "$url" spotify.gpg
    setup_apt "$repo" spotify.list
    sudo aptitude update
    sudo aptitude install -y spotify-client
}

# https://repo.steampowered.com/steam/
install_steam() {
    brew_install_cask steam

    url="https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    line1="deb [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    line2="deb-src [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    repo=$(echo -e "$line1\n$line2")
    setup_gpg "$url" steam.gpg
    setup_apt "$repo" steam.list
    sudo aptitude update
    sudo aptitude install -y steam-launcher
}

# https://www.sublimetext.com/docs/linux_repositories.html
install_sublime() {
    brew_install_cask sublime-text

    url="https://download.sublimetext.com/sublimehq-pub.gpg"
    repo="deb https://download.sublimetext.com/ apt/stable/"
    setup_gpg "$url" sublimehq-pub.gpg
    setup_apt "$repo" sublime-text.list
    sudo aptitude update
    sudo aptitude install -y sublime-text
}

# https://www.swift.org/download/
install_swift() {
    re="ubuntu$(lsb_release -rs)"
    [[ "$(uname -m)" == "aarch64" ]] && re="$re-aarch64"
    url="https://www.swift.org/download/"

    url=$(curl -fsSL --compressed $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P "$re.tar.gz\$" | tac | tail -n 1)
    base=$(basename --suffix .tar.gz "$url")
    curl -fsSL "$url" | tar -C "$HOME" -xz
    rm -rf "$HOME/.swift"
    mv "$HOME/$base" "$HOME/.swift"
}

# https://tailscale.com/download/linux/ubuntu-2204
install_tailscale() {
    brew_install tailscale

    url="https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/ubuntu jammy main"
    setup_gpg "$url" tailscale-archive-keyring.gpg
    setup_apt "$repo" tailscale.list
    sudo aptitude update
    sudo aptitude install -y tailscale

    sudo tailscale up
}

# https://aka.ms/get-teams-linux
install_teams() {
    brew_install_cask microsoft-teams

    url="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/"
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P "^teams_[\d\.]+_amd64.deb$" | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i teams_*_amd64.deb
    sudo aptitude install -y teams # Install missing dependencies
    rm -f teams_*_amd64.deb
}

# https://learn.hashicorp.com/tutorials/terraform/install-cli
install_terraform() {
    brew_install terraform

    setup_hashicorp
    sudo aptitude install -y terraform
}

# https://www.vaultproject.io/downloads
install_vault() {
    brew_install vault

    setup_hashicorp
    sudo aptitude install -y vault
}

# https://github.com/retorquere/zotero-deb/blob/master/install.sh
install_zotero() {
    brew_install_cask zotero

    url="https://raw.githubusercontent.com/retorquere/zotero-deb/master/zotero-archive-keyring.gpg"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/zotero-archive-keyring.gpg by-hash=force] https://zotero.retorque.re/file/apt-package-archive ./"
    setup_gpg "$url" zotero-archive-keyring.gpg
    setup_apt "$repo" zotero.list
    sudo aptitude update
    sudo aptitude install -y zotero
}

if [[ $#  -ne 1 ]]; then
    echo "Usage: $(basename "$0") <PACKAGE>"
    exit 1
fi

"install_$1"
