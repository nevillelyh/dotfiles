#!/bin/bash

dirs=(
    .cache/bazel
    .cache/coursier
    .cache/pip
    .gradle/caches
    .ivy2/cache
    .ivy2/local
    .keras/datasets
    .m2/repository
    .sdkman/archives
    Library/Caches/Coursier
    Library/Caches/Homebrew
)

for d in "${dirs[@]}"; do
    du -hs "$HOME/$d"
done
