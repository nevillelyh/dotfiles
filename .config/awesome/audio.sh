#!/bin/bash

set -euo pipefail

SOURCE=$(pactl list short sources | grep '\<alsa_input\.' | grep -i 'webcam' | head -n 1 | cut -f 2)
[ -n "$SOURCE" ] && pactl set-default-source $SOURCE

SINK=$(pactl list short sinks | grep '\<alsa_output\.' | grep -i 'audioengine' | head -n 1 | cut -f 2)
[ -n "$SINK" ] && pactl set-default-sink $SINK
