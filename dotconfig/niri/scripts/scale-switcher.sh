#!/usr/bin/env bash
# Display scale switcher — ported from the old Hyprland+noctalia
# scale-switcher (dotconfig/hypr/scripts/scale-switcher.sh on
# origin/noctalia-migration, which drove `hyprctl eval hl.monitor(...)`
# for a hardcoded eDP-1). Applies to whichever monitor is currently
# focused instead of a hardcoded output, since niri's IPC gives us that
# directly and this repo now spans multiple monitor layouts/machines.
#
# Presents a scale ladder in noctalia's launcher (dmenu) and applies the
# pick live via `niri msg output ... scale`. Session-only, like the
# original: this is a temporary niri output override and does NOT
# persist across a niri config reload/reboot. For a permanent change,
# set `scale` in the matching `output` block in config.kdl instead.
set -euo pipefail

info=$(niri msg focused-output)
MON=$(printf '%s' "$info" | head -1 | grep -oP '\(\K[^)]+(?=\)$)')
read -r W H <<<"$(printf '%s' "$info" | grep -oP 'Current mode: \K[0-9]+x[0-9]+' | tr x ' ')"
cur=$(printf '%s' "$info" | grep -oP 'Scale: \K[0-9.]+' | awk '{printf "%.2f", $1}')

# Coarse, whole-fraction ladder. Below 1.00 downscales (more logical
# desktop space than native pixels, at a sharpness cost — niri accepts
# it, tested live down to 0.8 on eDP-1); above 1.00 is normal HiDPI upscale.
SCALES=(0.75 0.80 0.90 1.00 1.25 1.50 1.75 2.00)

# Logical pixels along one axis for a given native length and scale.
logical() { awk -v n="$1" -v s="$2" 'BEGIN{printf "%d", n/s}'; }

# Build menu lines: "<mark> <scale>  ->  <logical WxH>[ (native)]".
lines=()
for s in "${SCALES[@]}"; do
  tag=""; [ "$s" = "1.00" ] && tag=" (native)"
  mark="   "; [ "$s" = "$cur" ] && mark=" ● "
  lines+=("$(printf '%s%s  →  %s×%s%s' "$mark" "$s" "$(logical "$W" "$s")" "$(logical "$H" "$s")" "$tag")")
done

choice=$(printf '%s\n' "${lines[@]}" | noctalia dmenu -p "Display scale — ${MON}") || exit 0
[ -z "${choice:-}" ] && exit 0

# First decimal number on the line is the scale (logical dims have no decimal point).
scale=$(printf '%s' "$choice" | grep -oE '[0-9]+\.[0-9]+' | head -1)
[ -z "$scale" ] && exit 0

niri msg output "$MON" scale "$scale"
noctalia msg notification-show "Display scale" "${MON} → ${scale}  ($(logical "$W" "$scale")×$(logical "$H" "$scale"))" 2>/dev/null || true
