#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
#xrandr --output LVDS-1 --mode 1920x1080

#xrandr --output LVDS-1 --mode 1400x1050
#xrandr --output VGA-1 --same-as LVDS-1
xrandr --newmode "2560x1440" 200.25 2560 2608 2640 2720 1440 1443 1448 1474 +HSync -Vsync
#xrandr --newmode 2560x1440 146.27 2560 2680 2944 3328 1440 1441 1444 1465 -HSync +Vsync
xrandr --addmode HDMI-1 2560x1440
xrandr --output HDMI-1 --mode 2560x1440
xrandr --output LVDS-1 --off
xrandr --output HDMI-1 --primary

xrdb /home/jason/.Xresources

setxkbmap -compat basic
setxkbmap -option ctrl:nocaps 
#setxkbmap -option terminate:ctrl_alt_bksp
xkbset sticky -twokey latchlock
xkbset exp sticky latchlock -twokey

xset r rate 200 25

#amixer sset Master 50%,50%
#amixer sset Master mute

feh --bg-center ~/.wallpapers/blue-blocks-cavern.jpg

exec herbstluftwm 
