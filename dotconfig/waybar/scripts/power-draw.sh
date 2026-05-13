#!/bin/bash
hwmon=/sys/class/hwmon/hwmon2

read_w() { awk '{printf "%.1f", $1/1000000}' "$hwmon/$1"; }

total=$(read_w power1_input)
ac=$(read_w power2_input)
rail=$(read_w power3_input)
heat=$(read_w power4_input)

status=$(cat /sys/class/power_supply/macsmc-battery/status)
if [[ "$status" == "Discharging" ]]; then
    class="discharging"
else
    class="charging"
fi

printf '{"text":"󱐋 %sW","tooltip":"Total: %sW\\nAC Input: %sW\\n3.8V Rail: %sW\\nHeatpipe: %sW","class":"%s"}\n' \
    "$total" "$total" "$ac" "$rail" "$heat" "$class"
