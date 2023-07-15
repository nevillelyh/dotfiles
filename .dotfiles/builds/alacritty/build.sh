#!/bin/bash

# Build Alacritty for arm64

set -euo pipefail

version="0.12.2"
icon_url='https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg'

read -r -d '' desktop << EOF || true
[Desktop Entry]
Version=$version
Type=Application
Name=Alacritty
Exec=/home/neville/.dotfiles/libexec/cache/alacritty
Icon=alacritty.svg
EOF

run_guest() {
    git clone https://github.com/alacritty/alacritty.git
    cd /alacritty
    git checkout "v$version"
    make binary
}

run_host() {
    script="$(readlink -f "$0")"
    cd "$(dirname "$script")"
    docker run --name alacritty --volume "$script":/build.sh rust:bookworm /build.sh
    docker cp alacritty:/alacritty/target/release/alacritty .
    docker rm alacritty

    mv alacritty "$HOME/.dotfiles/libexec/cache"
    mkdir -p "$HOME/.local/share/icons"
    curl -fsSL "$icon_url" -o "$HOME/.local/share/icons/alacritty.svg"
    mkdir -p "$HOME/.local/share/applications"
    echo "$desktop" > "$HOME/.local/share/applications/alacritty.desktop"
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
