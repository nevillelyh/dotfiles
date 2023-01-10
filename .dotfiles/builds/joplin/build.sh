#!/bin/bash

# Build and publish joplin Docker image

set -euo pipefail

image=nevillelyh/joplin
version=$(grep '^ARG VERSION=' Dockerfile | cut -d '=' -f 2)

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx inspect cross-build &> /dev/null || docker buildx create --name cross-build --use
docker buildx build --platform linux/amd64,linux/arm64 --tag "$image:latest" --tag "$image:$version" --push .

rm -rf dein.vim
