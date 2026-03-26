#!/bin/bash
# Sets display refresh rate based on charge state and active/idle mode.
# Usage: display-hz.sh active|idle

uid=$(id -u)
sig=$(ls /run/user/$uid/hypr/ 2>/dev/null | head -1)
[ -z "$sig" ] && exit 1
export HYPRLAND_INSTANCE_SIGNATURE=$sig
export XDG_RUNTIME_DIR=/run/user/$uid

charging() {
    grep -qE "Charging|Full" /sys/class/power_supply/macsmc-battery/status
}

case "$1" in
    active)
        if charging; then
            hyprctl keyword monitor eDP-1,3024x1890@120,0x0,2
        else
            hyprctl keyword monitor eDP-1,3024x1890@60,0x0,2
        fi
        ;;
    idle)
        if charging; then
            hyprctl keyword monitor eDP-1,3024x1890@60,0x0,2
        else
            hyprctl keyword monitor eDP-1,3024x1890@30,0x0,2
        fi
        ;;
    *)
        echo "Usage: $0 active|idle" >&2
        exit 1
        ;;
esac
