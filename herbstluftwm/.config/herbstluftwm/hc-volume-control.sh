#!/bin/bash

case "$1" in
    up)
        amixer set Master 2%+ 
    ;;

    down)
        amixer set Master 2%- 
    ;;

    mute) 
        amixer set Master toggle 
    ;;
esac

$HOME/.config/herbstluftwm/hc-input-dirty.sh
