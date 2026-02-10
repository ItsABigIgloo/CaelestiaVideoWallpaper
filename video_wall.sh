#!/bin/bash

VIDEO="$HOME/Pictures/Wallpapers/Live/SakuraHD.mp4"
MONITOR="eDP-1"

if pgrep -x "mpvpaper" > /dev/null; then
    killall mpvpaper
    # Optional: Restart your static wallpaper daemon if it was killed
    # swww-daemon &
else
    killall swww hyprpaper 2>/dev/null
    mpvpaper -o "--hwdec=auto --no-audio --loop" "$MONITOR" "$VIDEO" &
fi
