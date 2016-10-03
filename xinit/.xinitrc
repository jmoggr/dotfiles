#!/bin/sh

xrdb .Xresources
xkbcomp $HOME/.config/keyboard/blackbird-keymap.xkb $DISPLAY

amixer set Master 50%,50%
amixer set Master mute

xset -b

case "$(hostname)" in
    "warrig")
        exec startxfce4
    ;;
    "doofwagon")
        xrandr --setprovideroutputsource modesetting NVIDIA-0

        xrandr --newmode "2560x1440" 200.25 2560 2608 2640 2720 1440 1443 1448 1474 +HSync -Vsync
        #xrandr --newmode 2560x1440 146.27 2560 2680 2944 3328 1440 1441 1444 1465 -HSync +Vsync
        xrandr --addmode HDMI-1 2560x1440
        xrandr --output HDMI-1 --mode 2560x1440
        xrandr --output LVDS-1 --off
        xrandr --output HDMI-1 --primary
        
        feh --bg-center $HOME/.backgrounds/blue-blocks-cavern.jpg
        
        exec herbstluftwm 
    ;;
esac




