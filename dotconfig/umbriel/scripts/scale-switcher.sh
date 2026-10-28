#!/usr/bin/env bash
# Display scale switcher for umbriel (noctalia-dev's niri-like scrolling
# compositor). Driven by the noctalia `scale` custom_button widget.
#
# History: this started as a Hyprland `hyprctl eval` switcher, was ported
# to niri `niri msg output ... scale`, and is now on umbriel.
#
# Session-only, like the niri version: the pick is applied live through
# wlr-output-management (wlr-randr) and is NOT written to any config.
# Replugging a monitor (kanshi) or a changed output policy in umbriel's
# config puts it back to its profile scale (native 1.0 by default).
#
# When the enabled outputs sit in a single row, the row is re-packed left
# to right after the change so the rescaled output neither overlaps nor
# leaves a gap to its neighbours (umbriel needs outputs to touch for the
# pointer to cross between them).
set -euo pipefail

notify() { noctalia msg notification-show "$1" "$2" 2>/dev/null || true; }

command -v wlr-randr >/dev/null || { notify "Display scale" "wlr-randr is not installed"; exit 1; }

# Enabled outputs, focused first, one per line:
#   "<name> <scale> <WxH> <x> <y>"
mapfile -t OUTS < <(umbriel outputs 2>/dev/null | awk '
  /^[^ \t]/            { name=$1; en=""; sc=""; fo=""; px=""; py="" }
  /^[ \t]+Enabled:/    { en=$2 }
  /^[ \t]+Focused:/    { fo=$2 }
  /^[ \t]+Position:/   { split($2, p, ","); px=p[1]; py=p[2] }
  /^[ \t]+Scale:/      { sc=sprintf("%.2f",$2) }
  /current\)/ {
    mode=""
    for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+$/) { mode=$i; break }
    if (en=="yes") print (fo=="yes" ? 0 : 1), name, sc, mode, px, py
  }' | sort -s -k1,1n | cut -d' ' -f2-)

[ "${#OUTS[@]}" -gt 0 ] || { notify "Display scale" "No enabled outputs reported by umbriel"; exit 1; }

# Pick the output: single one is automatic; otherwise ask (the widget
# can't tell which bar was clicked, so ask; the focused output is listed first).
if [ "${#OUTS[@]}" -eq 1 ]; then
  sel="${OUTS[0]}"
else
  omenu=()
  for o in "${OUTS[@]}"; do
    read -r n s m _ <<<"$o"
    omenu+=("$(printf '%s   (scale %s, %s)' "$n" "$s" "$m")")
  done
  opick=$(printf '%s\n' "${omenu[@]}" | noctalia dmenu -p "Scale — which output?") || exit 0
  [ -z "${opick:-}" ] && exit 0
  oname=${opick%% *}
  for o in "${OUTS[@]}"; do [ "${o%% *}" = "$oname" ] && sel="$o"; done
fi

read -r MON cur mode _ <<<"$sel"
W=${mode%x*}; H=${mode#*x}

# Coarse, whole-fraction ladder. Below 1.00 downscales (more logical
# desktop space than native pixels, at a sharpness cost); above 1.00 is
# normal HiDPI upscale.
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
[ "$scale" = "$cur" ] && exit 0

# Re-pack a single row left to right in its current x order, using each
# output's logical width at its (new) scale. Rounding down makes neighbours
# overlap by under a pixel rather than leave a gap. Stacked or mixed
# layouts are left alone: only the scale changes.
args=(--output "$MON" --scale "$scale")
if [ "$(printf '%s\n' "${OUTS[@]}" | awk '{print $5}' | sort -u | wc -l)" -eq 1 ]; then
  args=()
  x=""
  while read -r n s m px py; do
    [ "$n" = "$MON" ] && s=$scale
    [ -z "$x" ] && x=$px
    args+=(--output "$n" --pos "$x,$py")
    [ "$n" = "$MON" ] && args+=(--scale "$scale")
    x=$(( x + $(logical "${m%x*}" "$s") ))
  done < <(printf '%s\n' "${OUTS[@]}" | sort -k4,4n)
fi

if ! wlr-randr "${args[@]}" >/dev/null 2>&1; then
  notify "Display scale" "wlr-randr rejected the change — scale unchanged"
  exit 1
fi

notify "Display scale" "${MON} → ${scale}  ($(logical "$W" "$scale")×$(logical "$H" "$scale"))"
