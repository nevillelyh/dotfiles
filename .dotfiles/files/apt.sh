#!/bin/bash

set -euo pipefail

setup_gpg() {
    URL="$1"
    GPG="$2"
    echo "Setting up GPG key $GPG"
    wget -qO - "$URL" | gpg --dearmor > $GPG
    sudo install -o root -g root -m 644 $GPG /etc/apt/trusted.gpg.d/
    rm $GPG
}

setup_apt() {
    REPO="$1"
    LIST="$2"
    echo "Setting up APT repo $LIST"
    echo "$REPO" | sudo tee /etc/apt/sources.list.d/$LIST > /dev/null
}

# Prefer Ubuntu instead
# https://apt.kitware.com/
install_cmake() {
    URL="https://apt.kitware.com/keys/kitware-archive-latest.asc"
    REPO="deb [signed-by=/etc/apt/trusted.gpg.d/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main"

    setup_gpg "$URL" kitware-archive-keyring.gpg
    setup_apt "$REPO" kitware.list
    sudo aptitude update
    sudo aptitude install -y cmake kitware-archive-keyring
}

# https://code.visualstudio.com/docs/setup/linux
install_code() {
    URL="https://packages.microsoft.com/keys/microsoft.asc"
    REPO="deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main"

    setup_gpg "$URL" packages.microsoft.gpg
    setup_apt "$REPO" vscode.list
    sudo aptitude update
    sudo aptitude install -y code
}

# https://docs.docker.com/engine/install/ubuntu/
install_docker() {
    URL="https://download.docker.com/linux/ubuntu/gpg"
    REPO="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    setup_gpg "$URL" docker-archive-keyring.gpg
    setup_apt "$REPO" docker.list
    sudo aptitude update
    sudo aptitude install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
install_nvidia() {
    URL="https://nvidia.github.io/libnvidia-container/gpgkey"
    DIST="ubuntu$(lsb_release -rs)"
    REPO=$(wget -qO - "https://nvidia.github.io/libnvidia-container/$DIST/libnvidia-container.list" | sed 's#deb https://#deb [signed-by=/etc/apt/trusted.gpg.d/nvidia-container-toolkit-keyring.gpg] https://#g')

    setup_gpg "$URL" nvidia-container-toolkit-keyring.gpg
    setup_apt "$REPO" nvidia-container-toolkit.list
    sudo aptitude update
    sudo aptitude install -y nvidia-docker2
}

# https://signal.org/download/
install_signal() {
    URL="https://updates.signal.org/desktop/apt/keys.asc"
    REPO="deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main"

    setup_gpg "$URL" signal-desktop-keyring.gpg
    setup_apt "$REPO" signal-xenial.list
    sudo aptitude update
    sudo aptitude install -y signal-desktop
}

# Prefer snap instead
# https://packagecloud.io/app/slacktechnologies/slack/gpg#gpg-apt
install_slack() {
    URL="https://packagecloud.io/slacktechnologies/slack/gpgkey"
    REPO=$(wget -qO - "https://packagecloud.io/install/repositories/slacktechnologies/slack/config_file.list?os=debian&dist=jessie&source=script")

    setup_gpg "$URL" slacktechnologies_slack.gpg
    setup_apt "$REPO" slacktechnologies_slack.list
    sudo aptitude update
    sudo aptitude install -y slack-desktop
}

# Prefer snap instead
# https://www.spotify.com/us/download/linux/
install_spotify() {
    URL="https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg"
    REPO="deb http://repository.spotify.com stable non-free"

    setup_gpg "$URL" spotify.gpg
    setup_apt "$REPO" spotify.list
    sudo aptitude update
    sudo aptitude install -y spotify-client
}

# https://repo.steampowered.com/steam/
install_steam() {
    URL="https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    R1="deb [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    R2="deb-src [arch=amd64,i386] http://repo.steampowered.com/steam/ stable steam"
    REPO=$(echo -e "$R1\n$R2")
    echo "$REPO"

    setup_gpg "$URL" steam.gpg
    setup_apt "$REPO" steam.list
    sudo aptitude update
    sudo aptitude install -y steam-launcher
}
# https://www.sublimetext.com/docs/linux_repositories.html
install_sublime() {
    URL="https://download.sublimetext.com/sublimehq-pub.gpg"
    REPO="deb https://download.sublimetext.com/ apt/stable/"

    setup_gpg "$URL" sublimehq-pub.gpg
    setup_apt "$REPO" sublime-text.list
    sudo aptitude update
    sudo aptitude install -y sublime-text
}

if [ $#  -ne 1 ]; then
    echo "Usage: apt.sh <package>"
    exit
fi

install_$1
