#!/bin/bash

# Set default audio source and sink

# C3422WE causes USB error -110
preferred_sources=(nt-usb logitech webcam c3422we)
for name in "${preferred_sources[@]}"; do
    source=$(pactl list short sources | grep "\<alsa_input\." | grep -i "$name" | head -n 1 | cut -f 2)
    [[ -n "$source" ]] && pactl set-default-source "$source" && break
done

preferred_sinks=(audioengine focusrite logitech)
for name in "${preferred_sinks[@]}"; do
    sink=$(pactl list short sinks | grep "\<alsa_output\." | grep -i "$name" | head -n 1 | cut -f 2)
    [[ -n "$sink" ]] && pactl set-default-sink "$sink" && break
done
