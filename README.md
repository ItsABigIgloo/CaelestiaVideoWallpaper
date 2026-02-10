# CaelestiaVideoWallpaper
this is a how to get video wallpaper when using Caelestia Shell


#!/bin/bash

#In terminal use either paru or yay:
`paru -S mpvpaper-git`
#or
`yay -S mpvpaper-git`

#You will need to know the name of your monitor(s). in terminal:
`hyprctl monitors`

`mpvpaper <monitor_name> /path/to/your/video.mp4`
#i.e. /home/user/Pictures/Wallpapers/live/video.mp4

#for those who have multiple monitors and would like to span to all of the monitors use "*"
#instead of specific monitor name i.e. [mpvpaper * /path/to/your/video.mp4]

#you can limit FPS if you notice CPU usage is high with:
`mpvpaper -o "vf-add=fps=30:round=near"`

#to make it permanent use vim or nano
`sudo nano /home/user$/.config/hypr/hyprland/decoration.conf`
#or
`sudo vim /home/user$/.config/hypr/hyprland/decoration.conf`

#move video_wall.sh file to /home/user$/.config/hypr/scripts/
#move gamemode_wallpaper.sh to /home/user$/.config/hypr/scripts/

#Enjoy \(^_^)/
