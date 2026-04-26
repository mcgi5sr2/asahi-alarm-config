#!/bin/bash

read_cores() { grep '^cpu[0-9]' /proc/stat; }

mapfile -t before < <(read_cores)
sleep 0.5
mapfile -t after < <(read_cores)

bars="▁▂▃▄▅▆▇█"
text=""
tooltip_lines=()
max_usage=0

for i in "${!before[@]}"; do
    read -r _ u1 n1 s1 i1 w1 r1 c1 _ _ _ <<< "${before[$i]}"
    read -r _ u2 n2 s2 i2 w2 r2 c2 _ _ _ <<< "${after[$i]}"

    diff_idle=$(( i2 - i1 ))
    diff_total=$(( (u2+n2+s2+i2+w2+r2+c2) - (u1+n1+s1+i1+w1+r1+c1) ))

    if [[ $diff_total -le 0 ]]; then
        usage=0
    else
        usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
    fi

    bar_idx=$(( usage * 7 / 100 ))
    [[ $bar_idx -gt 7 ]] && bar_idx=7
    text+="${bars:$bar_idx:1}"

    [[ $usage -gt $max_usage ]] && max_usage=$usage
    tooltip_lines+=("Core $((i+1)): ${usage}%")
done

if   [[ $max_usage -ge 90 ]]; then class="critical"
elif [[ $max_usage -ge 60 ]]; then class="high"
else                                class="normal"
fi

tooltip=$(printf '%s\\n' "${tooltip_lines[@]}")
tooltip="${tooltip%\\n}"

printf '{"text":"󰻠 %s","tooltip":"%s","class":"%s"}\n' \
    "$text" "$tooltip" "$class"
