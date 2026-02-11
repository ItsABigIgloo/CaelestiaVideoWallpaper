#!/usr/bin/env python3
import subprocess
import json
import os
import sys
import random
import time

WALLPAPER_DIR = os.path.expanduser("~/Pictures/Wallpapers/Live")
OVERRIDE_FILE = "/tmp/wallpaper_disabled"
GAMES = ["lutris", "wine", "steam_app", "pcsx2", "horizonxi", "mercury", "sudachi"]

def notify(title, message):
    subprocess.run(["notify-send", title, message])

def toggle():
    if os.path.exists(OVERRIDE_FILE):
        os.remove(OVERRIDE_FILE)
        notify("Live Wallpaper", "Enabled Video Wallpaper")
    else:
        with open(OVERRIDE_FILE, 'w') as f:
            f.write('disabled')
        subprocess.run(["pkill", "mpvpaper"], stderr=subprocess.DEVNULL)
        notify("Live Wallpaper", "Disabled Video Wallpaper")

def is_game_running():
    try:
        subprocess.check_call(["pgrep", "-f", "|".join(GAMES)], stdout=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        return False

def get_monitors():
    try:
        result = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True)
        return [m['name'] for m in json.loads(result.stdout)]
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return []

def run_monitor():
    while True:
        if os.path.exists(OVERRIDE_FILE) or is_game_running():
            subprocess.run(["pkill", "mpvpaper"], stderr=subprocess.DEVNULL)
        else:
            monitors = get_monitors()
            for monitor in monitors:
                # Check if mpvpaper is already running for this specific monitor
                check = subprocess.run(["pgrep", "-f", f"mpvpaper.*{monitor}"], capture_output=True)
                if check.returncode != 0:
                    videos = [f for f in os.listdir(WALLPAPER_DIR) if f.lower().endswith(('.mp4', '.mkv', '.webm'))]
                    if videos:
                        video_path = os.path.join(WALLPAPER_DIR, random.choice(videos))
                        subprocess.Popen([
                            "mpvpaper", "-o",
                            "loop panscan=1.0 --ao=null --no-audio --hwdec=auto --vo=gpu --no-config",
                            monitor, video_path
                        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(1)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        toggle()
    else:
        run_monitor()
