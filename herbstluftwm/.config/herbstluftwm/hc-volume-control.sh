#!/bin/bash

case "$1" in
    up)
        amixer -q set Master 2%+ 
    ;;

    down)
        amixer -q set Master 2%- 
    ;;

    mute) 
        if pactl list 2>&1 > /dev/null; then
	        amixer -q -D pulse set Master toggle
        elif aplay -l 2>&1 > /dev/null; then
            amixer -q set Master toggle 
        fi
    ;;
esac

$HOME/.config/herbstluftwm/hc-input-dirty.sh
