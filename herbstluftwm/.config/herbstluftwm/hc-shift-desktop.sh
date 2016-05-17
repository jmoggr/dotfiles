#!/bin/bash

if [[ -z "$1" ]]; then
    exit 0
fi

found=false
for i in {0..9}; do
    if [[ "$i" == "$1" ]]; then
        found=true
        break
    fi
done

if [[ "$found" == "false" ]]; then
    exit 0
fi

herbstclient move "$1"

$HOME/.config/herbstluftwm/hc-ballance-windows.sh
$HOME/.config/herbstluftwm/hc-ballance-frames.sh

$HOME/.config/herbstluftwm/hc-ballance-windows.sh $1
$HOME/.config/herbstluftwm/hc-ballance-frames.sh $1


#if [ "left" == "$1" ]; then
    #direction="left"
    #opposite="right"
#elif [ "right" == "$1" ]; then
    #direction="right"
    #opposite="left"
#elif [ "up" == "$1" ]; then
    #direction="up"
    #opposite="down"
#elif [ "down" == "$1" ]; then
    #direction="down"
    #opposite="up"
#else
    #exit 1
#fi


#herbstclient lock
#current_focus=$(herbstclient attr clients.focus.winid)

#result="$((herbstclient focus $direction) 2>&1)"

#if [ "$result" == "focus: No neighbour found" ]; then
    #herbstclient unlock
    #exit 0
#fi

#herbstclient shift -e $opposite

#herbstclient jumpto $current_focus
#herbstclient shift -e $direction

#herbstclient unlock
