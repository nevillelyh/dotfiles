#!/bin/bash

# Install from third-party APT repositories

set -euo pipefail

setup_gpg() {
    url="$1"
    gpg="$2"
    echo "Setting up GPG key $gpg"
    curl -sSL "$url" | gpg --dearmor > $gpg
    sudo install -o root -g root -m 644 $gpg /etc/apt/trusted.gpg.d/
    rm $gpg
}

setup_apt() {
    repo="$1"
    list="$2"
    echo "Setting up APT repo $list"
    echo "$repo" | sudo tee /etc/apt/sources.list.d/$list > /dev/null
}

# Chrome manages its own repository
install_chrome() {
    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
}

# Prefer Ubuntu instead
# https://apt.kitware.com/
install_cmake() {
    url="https://apt.kitware.com/keys/kitware-archive-latest.asc"
    repo="deb [signed-by=/etc/apt/trusted.gpg.d/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main"

    setup_gpg "$url" kitware-archive-keyring.gpg
    setup_apt "$repo" kitware.list
    sudo aptitude update
    sudo aptitude install -y cmake kitware-archive-keyring
}

# https://code.visualstudio.com/docs/setup/linux
install_code() {
    url="https://packages.microsoft.com/keys/microsoft.asc"
    repo="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"

    setup_gpg "$url" packages.microsoft.gpg
    setup_apt "$repo" vscode.list
    sudo aptitude update
    sudo aptitude install -y code
}

# https://docs.docker.com/engine/install/ubuntu/
install_docker() {
    url="https://download.docker.com/linux/ubuntu/gpg"
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    setup_gpg "$url" docker-archive-keyring.gpg
    setup_apt "$repo" docker.list
    sudo aptitude update
    sudo aptitude install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

# Dropbox manages its own repository
install_dropbox() {
    url="https://linux.dropbox.com/packages/ubuntu/"
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^dropbox_[\d\.]+_amd64.deb$' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i dropbox_*_amd64.deb
    rm -f dropbox_*_amd64.deb
}

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
install_github() {
    url="https://cli.github.com/packages/githubcli-archive-keyring.gpg"
    repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"

    setup_gpg "$url" githubcli-archive-keyring.gpg
    setup_apt "$repo" github-cli.list
    sudo aptitude update
    sudo aptitude install -y gh
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
install_nvidia() {
    url="https://nvidia.github.io/libnvidia-container/gpgkey"
    dist="ubuntu$(lsb_release -rs)"
    repo=$(curl -sSL "https://nvidia.github.io/libnvidia-container/$dist/libnvidia-container.list" | sed 's#deb https://#deb [signed-by=/etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg] https://#g')

    setup_gpg "$url" nvidia-container-toolkit-keyring.gpg
    setup_apt "$repo" nvidia-container-toolkit.list
    sudo aptitude update
    sudo aptitude install -y nvidia-docker2
}

# https://signal.org/download/
install_signal() {
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
    url="https://packagecloud.io/slacktechnologies/slack/gpgkey"
    repo=$(curl -sSL "https://packagecloud.io/install/repositories/slacktechnologies/slack/config_file.list?os=debian&dist=jessie&source=script")

    setup_gpg "$url" slacktechnologies_slack.gpg
    setup_apt "$repo" slacktechnologies_slack.list
    sudo aptitude update
    sudo aptitude install -y slack-desktop
}

# Prefer snap instead
# https://www.spotify.com/us/download/linux/
install_spotify() {
    url="https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg"
    repo="deb http://repository.spotify.com stable non-free"

    setup_gpg "$url" spotify.gpg
    setup_apt "$repo" spotify.list
    sudo aptitude update
    sudo aptitude install -y spotify-client
}

# https://repo.steampowered.com/steam/
install_steam() {
    url="https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    line1="deb [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    line2="deb-src [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    repo=$(echo -e "$line1\n$line2")
    echo "$repo"

    setup_gpg "$url" steam.gpg
    setup_apt "$repo" steam.list
    sudo aptitude update
    sudo aptitude install -y steam-launcher
}

# https://www.sublimetext.com/docs/linux_repositories.html
install_sublime() {
    url="https://download.sublimetext.com/sublimehq-pub.gpg"
    repo="deb https://download.sublimetext.com/ apt/stable/"

    setup_gpg "$url" sublimehq-pub.gpg
    setup_apt "$repo" sublime-text.list
    sudo aptitude update
    sudo aptitude install -y sublime-text
}

install_teams() {
    url="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/"
    pkg=$(curl -fsSL $url | grep -oP '(?<=href=")[^"]+(?=")' | grep -P '^teams_[\d\.]+_amd64.deb$' | tail -n 1)
    wget -nv "$url/$pkg"
    sudo dpkg -i teams_*_amd64.deb
    sudo aptitude install -y teams # Install missing dependencies
    rm -f teams_*_amd64.deb
}

if [[ $#  -ne 1 ]]; then
    echo "Usage: $(basename $0) <PACKAGE>"
    exit 1
fi

install_$1
