#!/bin/bash
# Desktop power readout: GPU watts (live) + CPU/GPU temps in tooltip.
# Replaces the laptop BAT0-based version. Works on NVIDIA + AMD k10temp.

# Find k10temp dynamically (hwmon numbering is unstable across boots)
hwmon_amd=""
for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "k10temp" ] && { hwmon_amd=$h; break; }
done

cpu_temp="?"
[ -n "$hwmon_amd" ] && [ -f "$hwmon_amd/temp1_input" ] && \
    cpu_temp=$(awk '{printf "%.0f", $1/1000}' "$hwmon_amd/temp1_input")

gpu_watts=""
gpu_temp="?"
if command -v nvidia-smi >/dev/null 2>&1; then
    read -r gpu_watts gpu_temp < <(
        nvidia-smi --query-gpu=power.draw,temperature.gpu \
            --format=csv,noheader,nounits 2>/dev/null \
            | awk -F', *' '{printf "%.0f %s", $1, $2}'
    )
fi

if [ -z "$gpu_watts" ]; then
    printf '{"text":"󱐋 -- W","tooltip":"GPU not detected\\nCPU: %s°C","class":"idle"}\n' "$cpu_temp"
    exit
fi

if   (( gpu_watts >= 200 )); then class="critical"
elif (( gpu_watts >= 100 )); then class="medium"
else                              class="idle"
fi

printf '{"text":"󱐋 %sW","tooltip":"GPU: %sW @ %s°C\\nCPU: %s°C","class":"%s"}\n' \
    "$gpu_watts" "$gpu_watts" "$gpu_temp" "$cpu_temp" "$class"
