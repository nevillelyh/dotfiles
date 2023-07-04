#!/bin/bash

set -euo pipefail

version="v0.12.2"
icon_url='https://raw.githubusercontent.com/alacritty/alacritty/master/extra/logo/alacritty-term.svg'

run_guest() {
    git clone https://github.com/alacritty/alacritty.git
    cd /alacritty
    git checkout "$version"
    make binary
}

run_host() {
    base="$(readlink -f "$0")"
    cd "$base"
    docker run --name alacritty --volume "$base":/build.sh rust:bookworm /build.sh
    docker cp alacritty:/alacritty/target/release/alacritty .
    docker rm alacritty

    mv alacritty "$HOME/.dotfiles/libexec/cache"
    mkdir -p "$HOME/.local/share/icons"
    curl -fsSL "$icon_url" -o "$HOME/.local/share/icons/alacritty.svg"
    mkdir -p "$HOME/.local/share/applications"
    ln -frs alacritty.desktop "$HOME/.local/share/applications"
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
