#!/bin/bash
STATE_FILE="/tmp/hyprsunset_state"

if [ ! -f "$STATE_FILE" ]; then
    HOUR=$(date +%-H)
    if [ "$HOUR" -ge 21 ] || [ "$HOUR" -lt 8 ]; then
        echo "night" > "$STATE_FILE"
    else
        echo "day" > "$STATE_FILE"
    fi
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "night" ]; then
    hyprctl hyprsunset identity
    echo "day" > "$STATE_FILE"
else
    hyprctl hyprsunset temperature 3500
    echo "night" > "$STATE_FILE"
fi

pkill -RTMIN+8 waybar
