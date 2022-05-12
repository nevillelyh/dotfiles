#!/bin/bash

# Build and publish joplin-cli Docker image

set -euo pipefail

image=nevillelyh/joplin-cli
version=$(grep "npm install" Dockerfile | grep -o "\<joplin@[0-9\.]\+$" | cut -d "@" -f 2)

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git
docker build -t "$image:$version" -t "$image:latest" .
rm -rf dein.vim

docker push "nevillelyh/joplin-cli:$version"
docker push "nevillelyh/joplin-cli:latest"
