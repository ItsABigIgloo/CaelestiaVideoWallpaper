#!/bin/bash

# --- INSTALLER CONFIGURATION ---
INSTALL_DIR="$HOME/.local/bin"
# Define the new folder path
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"
WALLPAPER_SCRIPT="$INSTALL_DIR/video_wallpaper.sh"
TOGGLE_SCRIPT="$INSTALL_DIR/toggle_wallpaper.sh"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

# Colors for pretty output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Universal Live Wallpaper Installation...${NC}"

# 1. Create the directories if they don't exist
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
fi

if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Creating wallpaper asset folder at $WALLPAPER_DIR..."
    mkdir -p "$WALLPAPER_DIR"
fi

# 2. Automatically install mpvpaper
echo "Checking dependencies..."
if ! command -v mpvpaper &> /dev/null; then
    echo -e "${YELLOW}mpvpaper not found. Attempting to install...${NC}"
    if command -v paru &> /dev/null; then
        paru -S --needed mpvpaper
    elif command -v yay &> /dev/null; then
        yay -S --needed mpvpaper
    else
        echo -e "${RED}Error: Neither 'paru' nor 'yay' found. Please install mpvpaper manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}mpvpaper is already installed.${NC}"
fi

# 3. Create video_wallpaper.sh with AUTO-DETECT
echo "Creating wallpaper daemon..."
cat << EOF > "$WALLPAPER_SCRIPT"
#!/bin/bash

# --- CONFIGURATION ---
# Uses the path defined during installation
WALLPAPER_DIR="$WALLPAPER_DIR/"
OVERRIDE_FILE="/tmp/wallpaper_disabled"

# --- MONITOR DETECTION ---
MONITOR=\$(hyprctl monitors | grep "Monitor" | awk '{print \$2}' | head -n 1)

if [ -z "\$MONITOR" ]; then
    echo "Warning: Could not detect monitor. Defaulting to eDP-1"
    MONITOR="eDP-1"
fi

# --- SAFETY CHECK ---
if [ ! -d "\$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory not found at \$WALLPAPER_DIR"
    exit 1
fi

# --- FUNCTIONS ---
is_game_running() {
    pgrep -f "lutris|wine|wine64|steam_app|pcsx2|horizonxi|mercury|sudachi" > /dev/null
}

# --- MAIN LOOP ---
while true; do
    if [ -f "\$OVERRIDE_FILE" ] || is_game_running; then
        pkill mpvpaper
    else
        if ! pgrep -x "mpvpaper" > /dev/null; then
            # PICK RANDOM VIDEO
            RANDOM_VIDEO=\$(find "\$WALLPAPER_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) | shuf -n 1)

            if [ -n "\$RANDOM_VIDEO" ]; then
                setsid mpvpaper -o "--no-audio loop panscan=1.0" "\$MONITOR" "\$RANDOM_VIDEO" &
            fi
        fi
    fi
    sleep 2
done
EOF

# 4. Create toggle_wallpaper.sh
echo "Creating toggle switch..."
cat << 'EOF' > "$TOGGLE_SCRIPT"
#!/bin/bash
OVERRIDE_FILE="/tmp/wallpaper_disabled"
if [ -f "$OVERRIDE_FILE" ]; then
    rm "$OVERRIDE_FILE"
    notify-send "Live Wallpaper" "Enabled (Auto-Mode)"
else
    touch "$OVERRIDE_FILE"
    pkill mpvpaper
    notify-send "Live Wallpaper" "Disabled (Manual)"
fi
EOF

# 5. Make them executable
chmod +x "$WALLPAPER_SCRIPT"
chmod +x "$TOGGLE_SCRIPT"

# 6. Automatically update hyprland.conf
echo "Updating $HYPR_CONF..."
if [ -f "$HYPR_CONF" ]; then
    # Add exec-once if not present
    if ! grep -q "$WALLPAPER_SCRIPT" "$HYPR_CONF"; then
        echo -e "\n# Live Wallpaper Daemon\nexec-once = $WALLPAPER_SCRIPT" >> "$HYPR_CONF"
        echo "Added exec-once to config."
    fi
    # Add keybind if not present
    if ! grep -q "$TOGGLE_SCRIPT" "$HYPR_CONF"; then
        echo "bind = SUPER_ALT, P, exec, $TOGGLE_SCRIPT" >> "$HYPR_CONF"
        echo "Added keybind (SUPER_ALT + P) to config."
    fi
else
    echo -e "${RED}Warning: $HYPR_CONF not found. Please add the lines manually.${NC}"
fi

echo -e "${GREEN}Installation Complete!${NC}"
echo "Place your video files in: $WALLPAPER_DIR"
