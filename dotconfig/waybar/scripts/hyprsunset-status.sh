#!/bin/bash
STATE_FILE="/tmp/hyprsunset_state"

# Initialise state from system time if no state file exists
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
    echo '{"text": "󰽥", "class": "night", "tooltip": "Night filter ON"}'
else
    echo '{"text": "󰖙", "class": "day", "tooltip": "Night filter OFF"}'
fi
