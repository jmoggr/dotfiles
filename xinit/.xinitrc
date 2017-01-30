#!/bin/sh

xrdb .Xresources
xkbcomp $HOME/.config/keyboard/blackbird-keymap.xkb $DISPLAY

# Default volume settings
amixer set Master 50%,50%
amixer set Master mute

# disable the system bell
xset -b

case "$(hostname)" in
    "warrig")
        urxvtd --quiet --opendisplay -f
        compton -b

        feh --bg-center $HOME/.backgrounds/blue-blocks-cavern.jpg
            
        # start window manager
        exec herbstluftwm 
    ;;
    "thenux")
        # setup screen

        # Modeline setting to run a DVI-D 2560x1440 monitor at 55Hz over HDMI
        # 55Hz at 2560x1440 about fills the bandwidth available on HDMI1.2
        xrandr --newmode "2560x1440" 200.25 2560 2608 2640 2720 1440 1443 1448 1474 +HSync -Vsync

        if glxinfo | grep -i vendor | grep -iq nvidia; then
            xrandr --setprovideroutputsource modesetting NVIDIA-0

            xrandr --addmode HDMI-1-1 2560x1440
            xrandr --output HDMI-1-1 --mode 2560x1440
            xrandr --output HDMI1-1 --primary
            xrandr --output LVDS-1-1 --off
            #xrandr --output LVDS-1-1 --mode 1920x1080
        else
            xrandr --addmode HDMI-1 2560x1440
            xrandr --output HDMI-1 --mode 2560x1440
            xrandr --output HDMI-1 --primary
            xrandr --output LVDS-1 --off
            #xrandr --output LVDS-1 --mode 1920x1080
        fi


        # start user daemons
        urxvtd --quiet --opendisplay -f
        compton -b

        # set background
        feh --bg-center $HOME/.backgrounds/blue-blocks-cavern.jpg
            
        # start window manager
        exec herbstluftwm 
    ;;
    "doofwagon")
        # start user daemons
        urxvtd --quiet --opendisplay -f
        compton -b

        # set background
        feh --bg-center $HOME/.backgrounds/blue-blocks-cavern.jpg

        # start window manager
        exec herbstluftwm
    ;;
esac
