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

# Current scale for eDP-1 (parsed from hyprctl text; no jq dependency).
cur=$(hyprctl monitors 2>/dev/null | awk '/^Monitor '"$MON"' /{f=1} f&&/scale:/{print $2; exit}')

# Build menu lines: "<mark> <scale>  ->  <logical WxH>[ (native)]".
lines=()
for s in "${SCALES[@]}"; do
  lw=$(awk -v w="$W" -v s="$s" 'BEGIN{printf "%d", w/s}')
  lh=$(awk -v h="$H" -v s="$s" 'BEGIN{printf "%d", h/s}')
  tag=""; [ "$s" = "1.00" ] && tag=" (native)"
  mark="   "; [ "$s" = "$cur" ] && mark=" ● "
  lines+=("$(printf '%b%s  →  %d×%d%s' "$mark" "$s" "$lw" "$lh" "$tag")")
done

choice=$(printf '%s\n' "${lines[@]}" | noctalia dmenu -p "Display scale") || exit 0
[ -z "${choice:-}" ] && exit 0

# First decimal number on the line is the scale (logical dims have no decimal point).
scale=$(printf '%s' "$choice" | grep -oE '[0-9]+\.[0-9]+' | head -1)
[ -z "$scale" ] && exit 0

hyprctl keyword monitor "${MON},${MODE},${POS},${scale}"
lw=$(awk -v w="$W" -v s="$scale" 'BEGIN{printf "%d", w/s}')
lh=$(awk -v h="$H" -v s="$scale" 'BEGIN{printf "%d", h/s}')
noctalia msg notification-show "Display scale" "${MON} → ${scale}  (${lw}×${lh})" 2>/dev/null || true
