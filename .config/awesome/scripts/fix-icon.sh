#!/bin/bash

# Fix icons and window states of some apps

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <APP>"
    exit 1
fi

case $1 in
    slack)
        icon="/snap/slack/current/usr/share/pixmaps/slack.png"
        regex="\<Slack\>"
        ;;
    spotify)
        icon="/snap/spotify/current/usr/share/spotify/icons/spotify-linux-512.png"
        regex="\<Spotify\>"
        ;;
    *)
        echo "Unsupported app: $1"
        exit 1
        ;;
esac

# Find app window(s) by name. You need to handle multiple windows here to
# actually get multiple workspaces working w/icons
readarray -t ws < <(wmctrl -l | grep $regex | cut -f 1 -d " ")

for w in "${ws[@]}"; do
    # Use "xseticon", a compiled C binary, to change the icon of a running program
    # Use absolute path to work around snap launcher issue
    /snap/xseticon/current/bin/xseticon -id "$w" $icon

    # Use "xprop" to set the window state, so that alt+tab works again
    xprop -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_NORMAL -id "$w"
done
