#!/bin/bash

set -euo pipefail

IMG=nevillelyh/joplin-cli
VER=$(grep 'npm install' Dockerfile | grep -oP '(?<= joplin@).*$')

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git
docker build -t $IMG:$VER -t $IMG:latest .
rm -rf dein.vim

docker push nevillelyh/joplin-cli:$VER
docker push nevillelyh/joplin-cli:latest
