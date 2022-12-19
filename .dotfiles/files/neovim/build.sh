#!/bin/bash

set -euo pipefail

run_host() {
    workdir="$(dirname "$(readlink -f "$0")")"
    docker run -it --rm -v "$workdir":/neovim debian:bullseye /neovim/build.sh
}

run_guest() {
    apt-get update
    apt-get install -y build-essential cmake curl gettext git libtool-bin pkg-config unzip

    mkdir -p /build
    cd /build
    git clone https://github.com/neovim/neovim

    cd neovim
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH="
    make DESTDIR=/build/neovim/build/release/nvim-linux64 install

    cd /build/neovim/build
    cpack -C Release

    cp nvim-linux64.deb nvim-linux64.tar.gz /neovim
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
