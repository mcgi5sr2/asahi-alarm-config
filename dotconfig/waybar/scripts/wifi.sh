#!/bin/bash
iface=$(iw dev | awk '$1=="Interface"{print $2}' | head -1)

# Check for ethernet first
eth=$(ip -4 addr show label "e*" 2>/dev/null | awk '/inet/{print $2}' | cut -d/ -f1 | head -1)
if [[ -n "$eth" ]]; then
    printf '{"text":"󰈀 %s","tooltip":"Ethernet\\nIP: %s","class":"strong"}\n' "$eth" "$eth"
    exit
fi

link=$(iw dev "$iface" link 2>/dev/null)
if [[ "$link" == "Not connected." || -z "$link" ]]; then
    printf '{"text":"󰤭 Disconnected","tooltip":"No network","class":"disconnected"}\n'
    exit
fi

signal=$(awk '/signal:/{print $2}' <<< "$link")
ssid=$(awk '/SSID:/{print $2}' <<< "$link")
ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet/{print $2}' | cut -d/ -f1)

strength=$(( (signal + 100) * 2 ))
[[ $strength -lt 0 ]] && strength=0
[[ $strength -gt 100 ]] && strength=100

if   [[ $strength -ge 70 ]]; then class="strong"; icon="󰤨"
elif [[ $strength -ge 40 ]]; then class="medium"; icon="󰤥"
else                               class="weak";   icon="󰤢"
fi

printf '{"text":"%s  %s","tooltip":"SSID: %s\\nSignal: %ddBm (%d%%)\\nIP: %s","class":"%s"}\n' \
    "$icon" "$ssid" "$ssid" "$signal" "$strength" "${ip:-N/A}" "$class"
