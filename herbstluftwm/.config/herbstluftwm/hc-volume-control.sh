#!/bin/bash

case "$1" in
    up)
        amixer set Master 2%+ 
    ;;

    down)
        amixer set Master 2%- 
    ;;

    mute) 
	# TODO: Find a subsystem agnostic way of muting/unmuting everything or perform a check on whether or not pulse is running
	# ALSA 
        # amixer set Master toggle 

	# Pulseaudio - to control all devices at once
	amixer -q -D pulse set Master toggle
    ;;
esac

$HOME/.config/herbstluftwm/hc-input-dirty.sh
