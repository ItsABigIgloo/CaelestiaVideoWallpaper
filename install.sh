#!/bin/bash

# --- CONFIGURATION ---
INSTALL_DIR="$HOME/.local/bin"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"
CONTROLLER_SCRIPT="$INSTALL_DIR/hypr_live_wallpaper.sh"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Multi-Monitor Live Wallpaper System...${NC}"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$WALLPAPER_DIR"

# Install Dependencies
for cmd in mpvpaper jq; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${YELLOW}$cmd not found. Installing...${NC}"
        if command -v paru &> /dev/null; then
            paru -S --needed "$cmd"
        elif command -v yay &> /dev/null; then
            yay -S --needed "$cmd"
        else
            echo "Error: Neither paru nor yay was found on this system."
            exit 1
        fi
    fi
done

# Write the actual script
cat << 'EOF' > "$CONTROLLER_SCRIPT"
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"
OVERRIDE_FILE="/tmp/wallpaper_disabled"

# Handle the Toggle
if [ "$1" == "toggle" ]; then
    if [ -f "$OVERRIDE_FILE" ]; then
        rm "$OVERRIDE_FILE"
        notify-send "Live Wallpaper" "Enabled Video Wallpaper"
    else
        touch "$OVERRIDE_FILE"
        pkill mpvpaper
        notify-send "Live Wallpaper" "Disabled Video Wallpaper"
    fi
    exit 0
fi

# Background Monitoring Logic
is_game_running() {
    pgrep -f "lutris|wine|wine64|steam_app|pcsx2|horizonxi|mercury|sudachi" > /dev/null
}

while true; do
    if [ -f "$OVERRIDE_FILE" ] || is_game_running; then
        pkill mpvpaper
    else
        # Detect all active monitors
        MONITORS=$(hyprctl monitors -j | jq -r '.[] | .name')
        for MONITOR in $MONITORS; do
            if ! pgrep -f "mpvpaper.*$MONITOR" > /dev/null; then
                VIDEO=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) | shuf -n 1)

                if [ -n "$VIDEO" ]; then
                    mpvpaper -o "loop panscan=1.0 --ao=null --no-audio --hwdec=auto --no-config" "$MONITOR" "$VIDEO" &
                fi
            fi
        done
    fi
    sleep 5
done
EOF

chmod +x "$CONTROLLER_SCRIPT"

# Update Hyprland Config
if [ -f "$HYPR_CONF" ]; then
    grep -q "$CONTROLLER_SCRIPT" "$HYPR_CONF" || echo -e "\n# Live Wallpaper Controller\nexec-once = sleep 3 && $CONTROLLER_SCRIPT" >> "$HYPR_CONF"
    grep -q "$CONTROLLER_SCRIPT toggle" "$HYPR_CONF" || echo "bind = SUPER_ALT, P, exec, $CONTROLLER_SCRIPT toggle" >> "$HYPR_CONF"
fi

echo -e "${GREEN}Installation Complete!${NC}"
echo "The default keybind is Super + Alt + P and can be adjusted in hyprland.conf"
echo "Place .mp4 wallpapers in ~/Pictures/Wallpapers/Live. the folder has already been created for you"
