#!/bin/bash

# Fix gnome-control-center crashes

set -euo pipefail

gsettings reset-recursively org.gnome.ControlCenter
gsettings reset-recursively org.gnome.desktop.wm.keybindings
