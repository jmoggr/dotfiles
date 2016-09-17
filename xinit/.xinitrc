#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
#xrandr --output LVDS-1 --mode 1920x1080

#xrandr --output VGA-1 --same-as LVDS-1
xrandr --newmode "2560x1440" 200.25 2560 2608 2640 2720 1440 1443 1448 1474 +HSync -Vsync
#xrandr --newmode 2560x1440 146.27 2560 2680 2944 3328 1440 1441 1444 1465 -HSync +Vsync
xrandr --addmode HDMI-1 2560x1440
xrandr --output HDMI-1 --mode 2560x1440
xrandr --output LVDS-1 --off
xrandr --output HDMI-1 --primary

amixer sset Master 50%,50%
amixer sset Master mute

#source /home/jason/keyboard.sh

xkbcomp $HOME/.config/keyboard/blackbird-keymap.xkb $DISPLAY

exec herbstluftwm 
