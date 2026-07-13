#!/bin/bash
# Laptop power readout for x86 Intel hardware (Dell):
#   text    -> battery charge/discharge watts (BAT0)
#   tooltip -> CPU package temp (coretemp) + battery status
#
# Replaces the Asahi (macsmc) and the NVIDIA/k10temp desktop variants.
# No root required: derives watts from BAT0 current*voltage and reads coretemp.
# (Intel RAPL energy_uj is root-only on modern kernels, so it is not used.)

# --- CPU package temp via coretemp (hwmon numbering is unstable across boots)
cpu_temp="?"
for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = coretemp ] || continue
    t="$h/temp1_input"                       # fallback
    for l in "$h"/temp*_label; do            # prefer the "Package id 0" sensor
        [ "$(cat "$l" 2>/dev/null)" = "Package id 0" ] && { t="${l%_label}_input"; break; }
    done
    [ -f "$t" ] && cpu_temp=$(awk '{printf "%.0f", $1/1000}' "$t")
    break
done

# --- Battery power via BAT0 -------------------------------------------------
B=/sys/class/power_supply/BAT0
status=$(cat "$B/status" 2>/dev/null || echo Unknown)

watts=""
if [ -r "$B/power_now" ]; then
    watts=$(awk '{v=$1; if(v<0)v=-v; printf "%.1f", v/1000000}' "$B/power_now")
elif [ -r "$B/current_now" ] && [ -r "$B/voltage_now" ]; then
    watts=$(awk -v i="$(cat "$B/current_now")" -v v="$(cat "$B/voltage_now")" \
                'BEGIN{if(i<0)i=-i; printf "%.1f", (i*v)/1e12}')
fi

if [ -z "$watts" ]; then
    printf '{"text":"󱐋 -- W","tooltip":"No battery power data\\nCPU: %s°C","class":"idle"}\n' "$cpu_temp"
    exit
fi

# Colour by discharge magnitude; charging / AC-idle stay neutral.
case "$status" in
    Discharging)
        icon="󱐋"; w=${watts%.*}
        if   (( w >= 30 )); then class="critical"
        elif (( w >= 18 )); then class="medium"
        else                     class="idle"; fi ;;
    Charging) icon="󰂄"; class="idle" ;;
    *)        icon="󰚥"; class="idle" ;;   # Full / not-charging
esac

printf '{"text":"%s %sW","tooltip":"Battery: %sW (%s)\\nCPU: %s°C","class":"%s"}\n' \
    "$icon" "$watts" "$watts" "$status" "$cpu_temp" "$class"
