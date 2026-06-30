#!/usr/bin/env bash

set -euo pipefail

# Workarounds for Pop OS Cosmic tray icon issues

d="$HOME/.local/share/icons/hicolor/32x32/apps"
mkdir -p "$d"
ln -sf "$HOME/.local/share/JetBrains/jetbrains-toolbox/bin/toolbox-tray-color.png" "$d"

d="$HOME/.local/share/icons/Cosmic/32x32/apps"
mkdir -p "$d"
ln -sf /usr/share/spotify/icons/spotify-linux-32.png "$d"

killall cosmic-panel
