#!/bin/bash
bat=/sys/class/power_supply/BAT0

current=$(cat "$bat/current_now")
voltage=$(cat "$bat/voltage_now")
status=$(cat "$bat/status")

watts=$(awk "BEGIN {printf \"%.1f\", ($current * $voltage) / 1e12}")

if [[ "$status" == "Discharging" ]]; then
    class="discharging"
else
    class="charging"
fi

printf '{"text":"󱐋 %sW","tooltip":"Power: %sW\\nStatus: %s","class":"%s"}\n' \
    "$watts" "$watts" "$status" "$class"
