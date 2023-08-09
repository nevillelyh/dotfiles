#!/bin/bash

# Build and publish Kraft Docker image

set -euo pipefail

image=nevillelyh/kraft
version=$(grep '^ARG VERSION=' Dockerfile | cut -d '=' -f 2)

if [[ "$(uname -m)" == x86_64 ]]; then
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
fi
docker buildx inspect cross-build &> /dev/null || docker buildx create --name cross-build --use
docker buildx build --platform linux/amd64,linux/arm64 --tag "$image:latest" --tag "$image:$version" --push .
