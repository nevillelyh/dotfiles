#!/bin/bash

# Build and publish joplin-cli Docker image

set -euo pipefail

image=nevillelyh/joplin-cli
version=$(grep "npm install" Dockerfile | grep -o "\<joplin@[0-9\.]\+$" | cut -d "@" -f 2)
arch=$(uname -m)
case $arch in
    aarch64)
        arch=arm64
        ;;
    x86_64)
        arch=amd64
        ;;
esac

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git
docker build --tag "$image:$arch" --tag "$image:$version-$arch" .
docker push "$image:$arch"
docker push "$image:$version-$arch"
rm -rf dein.vim
