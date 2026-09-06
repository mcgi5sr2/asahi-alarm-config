#!/bin/bash
# Polls charge state and adjusts active display Hz on change.
# Runs as a systemd user service.

last_state=""
while true; do
    state=$(cat /sys/class/power_supply/macsmc-battery/status)
    if [ "$state" != "$last_state" ]; then
        "$HOME/.config/hypr/display-hz.sh" active
        last_state="$state"
    fi
    sleep 5
done
