#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: snap.sh <app>"
    exit 1
fi

case $1 in
    slack)
        BIN="/snap/bin/slack"
        ICON="/snap/slack/current/usr/share/pixmaps/slack.png"
        REGEX='\<Slack\>'
        ;;
    spotify)
        BIN="/snap/bin/spotify"
        ICON="/snap/spotify/current/usr/share/spotify/icons/spotify-linux-512.png"
        REGEX='\<Spotify\>'
        ;;
    *)
        echo "Unsupported app: $1"
        exit 1
        ;;
esac

# Find app window(s) by name. You need to handle multiple windows here to
# actually get multiple workspaces working w/icons
WINDOWS=$(wmctrl -l | grep "$REGEX" | cut -f 1 -d ' ' | xargs)

for W in ${WINDOWS[@]}; do
    # Use "xseticon", a compiled C binary, to change the icon of a running program
    # Use absolute path to work around snap launcher issue
    /snap/xseticon/current/bin/xseticon -id $W $ICON

    # Use "xprop" to set the window state, so that alt+tab works again
    xprop -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_NORMAL -id $W
done
