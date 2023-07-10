#!/bin/bash

set -euo pipefail

cli_version=2023.5.0
desktop_version=2023.5.1
icon_url='https://github.com/bitwarden/clients/blob/master/apps/desktop/src/images/icon.png?raw=true'

run_guest() {
    git clone https://github.com/bitwarden/clients.git

    cd /clients
    git checkout "cli-v$cli_version"
    npm ci
    cd /clients/apps/cli
    sed -i 's/linux-x64/linux-arm64/g' package.json
    npm run dist:lin
    git reset --hard

    apt update -y
    apt upgrade -y
    apt install -y build-essential libsecret-1-dev libglib2.0-dev
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
    rustup target add aarch64-unknown-linux-musl
    export PKG_CONFIG_ALL_STATIC=1
    export PKG_CONFIG_ALLOW_CROSS=1

    cd /clients
    git checkout "desktop-v$desktop_version"
    npm ci
    cd /clients/apps/desktop/desktop_native
    npm run build -- --target aarch64-unknown-linux-musl
    cd /clients/apps/desktop
    sed -i 's/--linux --x64/--linux --arm64/g' package.json
    sed -i 's/"target": \[\(.*"AppImage".*\)],/"target": ["AppImage"],/g' electron-builder.json
    npm run dist:lin
    git reset --hard
}

run_host() {
    base="$(dirname "$(readlink -f "$0")")"
    cd "$base"
    docker run --name bitwarden --volume "$base":/build.sh node:18 /build.sh
    docker cp bitwarden:/clients/apps/cli/dist/linux/bw .
    docker cp "bitwarden:/clients/apps/desktop/dist/Bitwarden-$desktop_version-arm64.AppImage" .
    docker rm bitwarden

    mv bw "$HOME/.dotfiles/libexec/cache"
    mv "Bitwarden-$desktop_version-arm64.AppImage" "$HOME/.dotfiles/libexec/cache/Bitwarden.AppImage"
    mkdir -p "$HOME/.local/share/icons"
    curl -fsSL "$icon_url" -o "$HOME/.local/share/icons/bitwarden.png"
    mkdir -p "$HOME/.local/share/applications"
    ln -frs bitwarden.desktop "$HOME/.local/share/applications"
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
