#!/bin/bash

set -euo pipefail

preferred_sources=(webcam c3422we)
for name in "${preferred_sources[@]}"; do
    source=$(pactl list short sources | grep "\<alsa_input\." | grep -i "$name" | head -n 1 | cut -f 2 || true)
    [[ -n "$source" ]] && pactl set-default-source "$source" && break
done

preferred_sinks=(focusrite audioengine)
for name in "${preferred_sinks[@]}"; do
    sink=$(pactl list short sinks | grep "\<alsa_output\." | grep -i "$name" | head -n 1 | cut -f 2 || true)
    [[ -n "$sink" ]] && pactl set-default-sink "$sink" && break
done
