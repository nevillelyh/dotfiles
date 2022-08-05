#!/bin/bash

set -euo pipefail

cd "$HOME"
git clone git@github.com:google/flatbuffers.git
cd flatbuffers
git checkout "$(git tag | tail -n 1)"

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local"
make
cp flatc "$HOME/.local/bin"

rm -rf "$HOME/flatbuffers"
