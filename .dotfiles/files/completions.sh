#!/bin/bash

# Install missing ZSH completions for some packages, e.g. those from Cargo

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <DIR>"
    exit 1
fi

out=$(realpath "$1")
tmp=$(mktemp -d)
mkdir -p "$out"

cd "$tmp"

git clone https://github.com/sharkdp/bat.git
cd bat
cargo build --release
cp target/release/build/bat-*/out/assets/completions/bat.zsh "$out/_bat"
cd ..

git clone https://github.com/dandavison/delta.git
cd delta
cp etc/completion/completion.zsh "$out/_delta"
cd ..

git clone https://github.com/sharkdp/fd.git
cd fd
cp contrib/completion/_fd "$out"
cd ..

rm -rf "$tmp"
