#!/bin/bash
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume=$(awk '{printf "%d", $2 * 100}' <<< "$output")
muted=$(grep -c MUTED <<< "$output")

if   [[ $muted -ge 1 ]];    then class="muted";   icon="󰝟"; text="$icon Muted"
elif [[ $volume -ge 71 ]];  then class="loud";    icon="󰕾"; text="$icon ${volume}%"
elif [[ $volume -ge 30 ]];  then class="healthy"; icon="󰖀"; text="$icon ${volume}%"
else                              class="quiet";   icon="󰕿"; text="$icon ${volume}%"
fi

printf '{"text":"%s","tooltip":"Volume: %d%%","class":"%s"}\n' "$text" "$volume" "$class"
