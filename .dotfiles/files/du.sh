#!/bin/bash

# Check disk usage

dirs=(
    .cache/bazel
    .cache/coursier
    .cache/pip
    .gradle/caches
    .ivy2/cache
    .ivy2/local
    .keras/datasets
    .local/share/Steam/steamapps/common
    .m2/repository
    .nvman
    .sdkman/tmp
    Library/Caches/Coursier
    Library/Caches/Homebrew
    "Library/Application Support/Steam/steamapps/common"
)

for d in "${dirs[@]}"; do
    [[ -d "$HOME/$d" ]] && du -hs "$HOME/$d"
done
