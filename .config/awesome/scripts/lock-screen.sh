#!/bin/bash

# Lock screen with a fade out notification

# There are 2 background settings:
# - org.gnome.desktop.background picture-uri
# - org.gnome.desktop.background picture-uri-dark
# And a desktop color scheme:
# - org.gnome.desktop.interface color-scheme
# gnome-screensaver ignores its own setting and uses background URI instead
# - org.gnome.desktop.screensaver picture-uri
uri="file:///home/neville/.local/share/backgrounds/pop.png"
gsettings set org.gnome.desktop.background picture-uri $uri
gsettings set org.gnome.desktop.background picture-uri-dark $uri
gsettings set org.gnome.desktop.screensaver picture-uri $uri

# Kill existing xautolock first
xautolock -exit

# Wait till the previous session exits
sleep 3

# Do not lock when mouse cursor is in bottom right corner
# Lock after 10 minutes with 5 seconds notifier
# Turn off after 10 minutes
xautolock \
  -corners 000- \
  -time 10 -locker "gnome-screensaver-command --lock" \
  -notify 5 -notifier "$HOME/.config/awesome/scripts/fade-out.sh"
