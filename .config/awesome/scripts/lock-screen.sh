#!/bin/bash

# Lock screen with a fade out notification

notify_sec=10
lock_min=10
kill_min=10

help() {
    echo "Usage: $(basename "$script") [xautolock|notify|lock|kill] ..."
    exit 1
}

run_xautolock() {
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
    script="$(readlink -f "$0")"
    xautolock \
        -corners 000- \
        -notify $notify_sec -notifier "$script notify" \
        -time $lock_min -locker "$script lock" \
        -killtime $kill_min -killer "$script kill"
}

run_notify() {
    # Screen already locked, do not fade out again for xautolock killer
    gnome-screensaver-command --query | grep -q "^The screensaver is active$" && exit 0

    # Always clear changes
    trap "xcalib -clear" EXIT

    frames=100
    interval="$(echo "$notify_sec" / $frames | bc -l)"

    last_idle="$(xprintidle)"

    (( c = frames ))
    while (( c > 0 )); do
        new_idle="$(xprintidle)"
        [[ $last_idle -gt $new_idle ]] && exit 0
        last_idle=$new_idle
        xcalib -alter -contrast $c
        sleep "$interval"
        (( c = c - 1 ))
    done
}

run_lock() {
    gnome-screensaver-command --lock

    # xautolock killer only works when the locker is running
    while true; do
        gnome-screensaver-command --query | grep -q "^The screensaver is inactive$" && break
        sleep 1
    done
}

run_kill() {
    xset dpms force standby
}

[[ $# -eq 1 ]] || help

case $1 in
    xautolock)
        run_xautolock
        ;;
    notify)
        run_notify
        ;;
    lock)
        run_lock
        ;;
    kill)
        run_kill
        ;;
    *)
        help
        ;;
esac
