#!/bin/bash

# Script changes volume based on arguments
#
# Setting a default audio device/sink should preferable to  changing this 
# script. This can be done in the ~/.asoundrc file. Recommended that the 
# default be pulse.

case "$1" in
    up)
        #pactl set-sink-volume 0 +2%
        amixer set Master 2%+,2%+
    ;;

    down)
        #pactl set-sink-volume 0 -2%
        amixer set Master 2%-,2%-
    ;;

    mute) 
        # Default device should be pulse. 
        amixer set Master toggle
    ;;
esac

$HOME/.config/herbstluftwm/hc-input-dirty.sh
