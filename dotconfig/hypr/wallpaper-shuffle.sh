#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
INTERVAL=300  # 5 minutes

sleep 2  # wait for hyprpaper to start

while true; do
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

    if [[ -n "$WALLPAPER" ]]; then
        hyprctl hyprpaper preload "$WALLPAPER"

        # Apply to all connected monitors
        while IFS= read -r monitor; do
            hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
        done < <(hyprctl monitors | grep "^Monitor" | awk '{print $2}')

        hyprctl hyprpaper unload all
    fi

    sleep "$INTERVAL"
done
