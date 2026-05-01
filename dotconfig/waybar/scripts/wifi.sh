#!/bin/bash

# Ethernet check
eth=$(ip -4 addr show label "e*" 2>/dev/null | awk '/inet/{print $2}' | cut -d/ -f1 | head -1)
if [[ -n "$eth" ]]; then
    printf '{"text":"󰈀 %s","tooltip":"Ethernet\\nIP: %s","class":"strong"}\n' "$eth" "$eth"
    exit
fi

active=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes:')
if [[ -z "$active" ]]; then
    printf '{"text":"󰤭 Disconnected","tooltip":"No network","class":"disconnected"}\n'
    exit
fi

ssid=$(echo "$active" | cut -d: -f2)
signal=$(echo "$active" | cut -d: -f3)
iface=$(nmcli -t -f active,device dev wifi | grep '^yes:' | cut -d: -f2)
ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet/{print $2}' | cut -d/ -f1)

if   [[ $signal -ge 70 ]]; then class="strong"; icon="󰤨"
elif [[ $signal -ge 40 ]]; then class="medium"; icon="󰤥"
else                             class="weak";   icon="󰤢"
fi

printf '{"text":"%s  %s","tooltip":"SSID: %s\\nSignal: %d%%\\nIP: %s","class":"%s"}\n' \
    "$icon" "$ssid" "$ssid" "$signal" "${ip:-N/A}" "$class"
