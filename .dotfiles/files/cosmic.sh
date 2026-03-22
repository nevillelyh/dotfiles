#!/bin/bash

set -euo pipefail

# Workarounds for Pop OS Cosmic tray icon issues

m="$(uname -m)"
v="$(cat "$HOME/.dropbox-dist/VERSION")"
d="$HOME/.local/share/pixmaps"
mkdir -p "$d"
for f in "$HOME/.dropbox-dist/dropbox-lnx.$m-$v/images/hicolor/16x16/status/"*.png; do
  ln -sf "$f" "$d"
done

d="$HOME/.local/share/icons/hicolor/32x32/apps"
mkdir -p "$d"
ln -sf "$HOME/.local/share/JetBrains/jetbrains-toolbox/bin/toolbox-tray-color.png" "$d"

d="$HOME/.local/share/icons/Cosmic/32x32/apps"
mkdir -p "$d"
ln -sf /usr/share/spotify/icons/spotify-linux-32.png "$d"

killall cosmic-panel
