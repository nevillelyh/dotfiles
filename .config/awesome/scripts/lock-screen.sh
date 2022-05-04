#!/bin/bash

# Kill existing xautolock
xautolock -exit

# Lock after 10 minutes with 5 seconds notifier
xautolock -time 10 -locker "gnome-screensaver-command --lock" -notify 5 -notifier $HOME/.config/awesome/scripts/fade-out.sh
