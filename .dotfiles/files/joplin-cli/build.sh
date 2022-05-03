#!/bin/bash

set -euo pipefail

image=nevillelyh/joplin-cli
version=$(grep 'npm install' Dockerfile | grep -oP '(?<= joplin@).*$')

[[ -d dein.vim ]] && rm -rf dein.vim
git clone https://github.com/Shougo/dein.vim.git
docker build -t $image:$version -t $image:latest .
rm -rf dein.vim

docker push nevillelyh/joplin-cli:$version
docker push nevillelyh/joplin-cli:latest
