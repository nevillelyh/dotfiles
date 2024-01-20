#!/bin/bash

# Build and publish kcat Docker image

set -euo pipefail

image=nevillelyh/kcat

[[ -d kcat ]] && rm -rf kcat
git clone https://github.com/edenhill/kcat.git
cd kcat

version=$(git describe --tags)

sed -i 's/^FROM alpine:.\+$/FROM alpine:3.17/' Dockerfile
sed -i 's/ python / python3 /' Dockerfile

if [[ "$(uname -m)" == x86_64 ]]; then
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
fi
docker buildx inspect cross-build &> /dev/null || docker buildx create --name cross-build --use
docker buildx build --platform linux/amd64,linux/arm64 --tag "$image:latest" --tag "$image:$version" --push .
docker pull "$image:latest"

cd ..
rm -rf kcat
