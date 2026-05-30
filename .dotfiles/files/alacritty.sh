#!/bin/bash

set -euo pipefail
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo> <version>"
    exit 1
fi

cd "$1"
git checkout "$2"

# https://github.com/alacritty/alacritty/blob/master/INSTALL.md#macos

make clean app
mv target/release/osx/Alacritty.app /Applications

sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
