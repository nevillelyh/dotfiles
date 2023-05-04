#!/bin/bash

# Install missing ZSH completions for some packages, e.g. those from Cargo

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <DIR>"
    exit 1
fi

out=$(realpath "$1")
mkdir -p "$out"

tmp=$(mktemp -d)

git clone https://github.com/sharkdp/bat.git "$tmp/bat"
cd "$tmp/bat"
cargo build --release
cp target/release/build/bat-*/out/assets/completions/bat.zsh "$out/_bat"
rm -rf "$tmp"

prefix="https://raw.githubusercontent.com"
curl -fsSL "$prefix/dandavison/delta/master/etc/completion/completion.zsh" -o "$out/_delta"
curl -fsSL "$prefix/bootandy/dust/master/completions/_dust" -o "$out/_dust"
curl -fsSL "$prefix/sharkdp/fd/master/contrib/completion/_fd" -o "$out/_fd"
curl -fsSL "$prefix/ajeetdsouza/zoxide/main/contrib/completions/_zoxide" -o "$out/_zoxide"
