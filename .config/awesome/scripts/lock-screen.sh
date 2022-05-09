#!/bin/bash

# Changing background in gnome-control-center sets the following 2 settings
# - org.gnome.desktop.background picture-uri-dark
# - org.gnome.desktop.screensaver picture-uri
# While gnome-screensaver reads the following setting instead
# - org.gnome.desktop.background picture-uri
uri=$(gsettings get org.gnome.desktop.screensaver picture-uri)
gsettings set org.gnome.desktop.background picture-uri $uri

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
  -killtime 10 -killer "xset dpms force standby" \
  -notify 5 -notifier $HOME/.config/awesome/scripts/fade-out.sh
