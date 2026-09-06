#!/bin/sh
# Trackpad control for Hyprland's Lua config.
#
#   trackpad.sh on|off|toggle    manual control
#   trackpad.sh auto             enable/disable to match external-mouse presence
#   trackpad.sh watch            long-running: run `auto` whenever input devices change
#
# Hyprland 0.55+ parses hyprland.lua, so `hyprctl keyword` refuses device options
# ("keyword can't work with non-legacy parsers"). Everything goes through `hyprctl eval`.

DEV="apple-spi-trackpad"
STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-trackpad.state"

# Pointers that are not a real external mouse: the trackpad itself, and the
# virtual pointer keyd creates when it grabs the Apple keyboard.
IGNORE_MICE="$DEV keyd-virtual-pointer"

has_external_mouse() {
    hyprctl devices -j | IGNORE="$IGNORE_MICE" python3 -c '
import json, os, sys
ignore = set(os.environ["IGNORE"].split())
mice = json.load(sys.stdin).get("mice", [])
sys.exit(0 if any(m.get("name") not in ignore for m in mice) else 1)
'
}

apply() {
    # $1 = true|false. Always re-issues the eval rather than short-circuiting on
    # the state file: `hyprctl reload` resets device options to their config
    # defaults, so a cached "already false" would leave the trackpad silently
    # re-enabled. The state file only suppresses duplicate notifications.
    prev=$(cat "$STATE" 2>/dev/null)

    if ! hyprctl eval "hl.device({ name = \"$DEV\", enabled = $1 })" | grep -q '^ok'; then
        notify-send -u critical "Trackpad" "Failed to set enabled=$1" 2>/dev/null
        return 1
    fi
    printf '%s' "$1" > "$STATE"

    [ "$prev" = "$1" ] && return 0

    if [ "$1" = "true" ]; then
        notify-send -t 1500 "Trackpad" "Enabled" 2>/dev/null
    else
        notify-send -t 1500 "Trackpad" "Disabled" 2>/dev/null
    fi
}

case "$1" in
    on)  apply true  ;;
    off) apply false ;;
    toggle)
        if [ "$(cat "$STATE" 2>/dev/null)" = "false" ]; then apply true; else apply false; fi
        ;;
    auto)
        if has_external_mouse; then apply false; else apply true; fi
        ;;
    watch)
        "$0" auto
        # udevadm monitor emits several lines per connect; `apply` collapses
        # them by ignoring no-op transitions.
        udevadm monitor --udev --subsystem-match=input | while read -r line; do
            case "$line" in
                *" add "*|*" remove "*)
                    sleep 1
                    "$0" auto
                    ;;
            esac
        done
        ;;
    *)
        echo "usage: ${0##*/} on|off|toggle|auto|watch" >&2
        exit 2
        ;;
esac
