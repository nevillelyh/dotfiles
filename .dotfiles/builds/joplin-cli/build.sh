#!/bin/bash

# Build and publish joplin-cli Docker image

set -euo pipefail

image=nevillelyh/joplin-cli
version=$(grep 'npm install' Dockerfile | grep -o '\<joplin@[0-9\.]\+$' | cut -d '@' -f 2)

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx inspect cross-build &> /dev/null || docker buildx create --name cross-build --use
docker buildx build --platform linux/amd64,linux/arm64 --tag "$image:latest" --tag "$image:$version" --push .

rm -rf dein.vim