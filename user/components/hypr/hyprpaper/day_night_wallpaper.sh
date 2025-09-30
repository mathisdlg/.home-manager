#!/bin/bash

GENERAL_WALLPAPER_PATH="$HOME/.backgrounds/images/general"
DAYTIME_WALLPAPER_PATH="$HOME/.backgrounds/images/daytime"
NIGHTTIME_WALLPAPER_PATH="$HOME/.backgrounds/images/nighttime"

current_hour=$(date +'%H')

if [ "$current_hour" -ge 6 ] && [ "$current_hour" -lt 18 ]; then
	wallpaper_path="$DAYTIME_WALLPAPER_PATH"
else
	wallpaper_path="$NIGHTTIME_WALLPAPER_PATH"
fi

images=("$GENERAL_WALLPAPER_PATH"/* "$wallpaper_path"/*)

random_index=$((RANDOM % ${#images[@]}))
selected_image="${images[$random_index]}"

hyprctl hyprpaper preload "$selected_image"
hyprctl hyprpaper wallpaper "$selected_image"

sleep 1

hyprctl hyprpaper unload unused