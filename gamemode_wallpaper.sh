#!/bin/bash

# Configuration
VIDEO_WALLPAPER="mpvpaper -o '--hwdec=auto --no-audio --loop' eDP-1 $HOME/Pictures/Wallpapers/Live/yourvideo.mp4"

# Function to check if a game is running
is_game_running() {
    # pgrep -f searches the full command line name.
    # Added "wine64" to catch specific windows games not caught by "wine"
    pgrep -f "lutris|wine|wine64|steam_app|pcsx2|horizonxi|mercury|sudachi" > /dev/null
}

while true; do
    if is_game_running; then
        # Game is running (even in background): Kill wallpaper to save resources
        if pgrep -x "mpvpaper" > /dev/null; then
            pkill mpvpaper
        fi
    else
        # Game is NOT running: Play wallpaper
        if ! pgrep -x "mpvpaper" > /dev/null; then
            eval "$VIDEO_WALLPAPER &"
        fi
    fi
    sleep 5
done
