#!/bin/bash

# fail early
set -e

rm -rf ~/backup

DEST="$HOME/backup/Pictures"
mkdir -p "$DEST"
cd ~/Pictures
cp -a Exported\ Settings Lightroom Lightroom\ Library.lrlibrary "$DEST"

DEST="$HOME/backup/Library/Adobe/CameraRaw"
mkdir -p "$DEST"
cd ~/Library/Application\ Support/Adobe/CameraRaw
cp -a Settings "$DEST"

DEST="$HOME/backup/Library/MacDive"
mkdir -p "$DEST"
cd ~/Library/Application\ Support/MacDive
cp -a *.mdlicense "$DEST"

cd ~
tar cjvf backup.tar.bz2 backup
mv backup.tar.bz2 ~/Dropbox/Downloads
