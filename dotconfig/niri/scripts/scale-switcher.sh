#!/usr/bin/env bash
# Display scale switcher for umbriel (noctalia-dev's niri-like scrolling
# compositor). Driven by the noctalia `scale` custom_button widget.
#
# History: this started as a Hyprland `hyprctl eval` switcher, was ported
# to niri `niri msg output ... scale`, and is now on umbriel. The file
# still lives under ~/.config/niri/scripts/ (a misnomer kept so the
# existing widget exec keeps working) — the niri→umbriel config migration
# in this repo is still outstanding.
#
# Unlike the niri version, this is NOT a session-only override: umbriel
# exposes no runtime "set scale" IPC, so the pick is written into the
# matching `[output.<name>]` block of umbriel's config and applied with
# `umbriel msg config-reload`. The change therefore persists across
# reloads/reboots. The edit is validated (`umbriel validate`) and the old
# config backed up before it is swapped in, so a bad write can't brick the
# compositor.
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/umbriel/config.toml"

notify() { noctalia msg notification-show "$1" "$2" 2>/dev/null || true; }

[ -f "$CONFIG" ] || { notify "Display scale" "No umbriel config at $CONFIG"; exit 1; }

# Enabled outputs with their current scale and current mode, one per line:
#   "<name> <scale> <WxH>"
mapfile -t OUTS < <(umbriel outputs 2>/dev/null | awk '
  /^[^ \t]/            { name=$1; en=""; sc="" }
  /^[ \t]+Enabled:/    { en=$2 }
  /^[ \t]+Scale:/      { sc=sprintf("%.2f",$2) }
  /current\)/ {
    mode=""
    for (i=1;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+$/) { mode=$i; break }
    if (en=="yes") print name, sc, mode
  }')

[ "${#OUTS[@]}" -gt 0 ] || { notify "Display scale" "No enabled outputs reported by umbriel"; exit 1; }

# Pick the output: single one is automatic; otherwise ask (umbriel exposes
# no focused-output query, so we let the user choose).
if [ "${#OUTS[@]}" -eq 1 ]; then
  sel="${OUTS[0]}"
else
  omenu=()
  for o in "${OUTS[@]}"; do
    read -r n s m <<<"$o"
    omenu+=("$(printf '%s   (scale %s, %s)' "$n" "$s" "$m")")
  done
  opick=$(printf '%s\n' "${omenu[@]}" | noctalia dmenu -p "Scale — which output?") || exit 0
  [ -z "${opick:-}" ] && exit 0
  oname=${opick%% *}
  for o in "${OUTS[@]}"; do [ "${o%% *}" = "$oname" ] && sel="$o"; done
fi

read -r MON cur mode <<<"$sel"
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

# Write the new scale into the matching [output.<MON>] block. Replace an
# existing `scale =` line in place (preserving any trailing comment), or
# insert one; create the section at EOF if it's absent entirely.
tmp=$(mktemp "${TMPDIR:-/tmp}/umbriel-config.XXXXXX.toml")
trap 'rm -f "$tmp"' EXIT
awk -v name="$MON" -v newv="$scale" '
  BEGIN { target="[output." name "]"; inSec=0; done=0 }
  /^\[/ {
    if (inSec && !done) { print "scale = " newv; done=1 }
    inSec = ($0 == target) ? 1 : 0
  }
  {
    if (inSec && !done && $0 ~ /^[ \t]*scale[ \t]*=/) {
      sub(/^[ \t]*scale[ \t]*=[ \t]*[0-9.]+/, "scale = " newv)
      done=1
    }
    print
  }
  END {
    if (!done) { print ""; print target; print "scale = " newv }
  }
' "$CONFIG" > "$tmp"

if ! umbriel validate -c "$tmp" >/dev/null 2>&1; then
  notify "Display scale" "Edit failed validation — scale unchanged"
  exit 1
fi

cp -f "$CONFIG" "${CONFIG}.bak-scale-$(date +%Y%m%d-%H%M%S)"
cp -f "$tmp" "$CONFIG"
umbriel msg config-reload >/dev/null 2>&1 || true

notify "Display scale" "${MON} → ${scale}  ($(logical "$W" "$scale")×$(logical "$H" "$scale"))"
