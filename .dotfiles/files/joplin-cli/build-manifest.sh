#!/bin/bash

# Build and publish cross-platform manifest

docker manifest create nevillelyh/joplin-cli:latest nevillelyh/joplin-cli:arm64 nevillelyh/joplin-cli:amd64
docker manifest push nevillelyh/joplin-cli:latest
