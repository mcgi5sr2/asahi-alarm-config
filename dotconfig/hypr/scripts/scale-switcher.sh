#!/usr/bin/env bash
# Display scale switcher for eDP-1.
# Presents a clean whole-pixel scale ladder in noctalia's launcher (dmenu)
# and applies the pick live via hyprctl. Session-only: does NOT persist across
# a Hyprland reload/reboot (same runtime-only approach as display-hz.sh).
set -euo pipefail

MON="eDP-1"
MODE="3024x1890@120"
POS="0x0"
W=3024
H=1890

# Coarse, whole-pixel ladder, ordered "from here up to native" (estate increases downward).
SCALES=(1.50 1.40 1.20 1.00)

# Logical pixels along one axis for a given native length and scale.
logical() { awk -v n="$1" -v s="$2" 'BEGIN{printf "%d", n/s}'; }

# Current scale for eDP-1 (parsed from hyprctl text; no jq dependency).
cur=$(hyprctl monitors 2>/dev/null | awk '/^Monitor '"$MON"' /{f=1} f&&/scale:/{print $2; exit}')

# Build menu lines: "<mark> <scale>  ->  <logical WxH>[ (native)]".
lines=()
for s in "${SCALES[@]}"; do
  tag=""; [ "$s" = "1.00" ] && tag=" (native)"
  mark="   "; [ "$s" = "$cur" ] && mark=" ● "
  lines+=("$(printf '%s%s  →  %s×%s%s' "$mark" "$s" "$(logical "$W" "$s")" "$(logical "$H" "$s")" "$tag")")
done

choice=$(printf '%s\n' "${lines[@]}" | noctalia dmenu -p "Display scale") || exit 0
[ -z "${choice:-}" ] && exit 0

# First decimal number on the line is the scale (logical dims have no decimal point).
scale=$(printf '%s' "$choice" | grep -oE '[0-9]+\.[0-9]+' | head -1)
[ -z "$scale" ] && exit 0

# Hyprland uses the Lua config parser here, so `hyprctl keyword` is rejected;
# drive the runtime hl.monitor() API via `hyprctl eval` instead.
hyprctl eval "hl.monitor({ output = \"${MON}\", mode = \"${MODE}\", position = \"${POS}\", scale = ${scale} })"
noctalia msg notification-show "Display scale" "${MON} → ${scale}  ($(logical "$W" "$scale")×$(logical "$H" "$scale"))" 2>/dev/null || true
