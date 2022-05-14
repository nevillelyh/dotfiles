#!/bin/bash

# Fix gnome-control-center crashes

gsettings reset-recursively org.gnome.ControlCenter
gsettings reset-recursively org.gnome.desktop.wm.keybindings
