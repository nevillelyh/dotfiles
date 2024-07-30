#!/bin/bash

# Install missing ZSH completions for some packages, e.g. those from Cargo

set -euo pipefail

out="$HOME/.local/share/zsh/site-functions"
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
curl -fsSL "$prefix/ajeetdsouza/zoxide/main/contrib/completions/_zoxide" -o "$out/_zoxide"
