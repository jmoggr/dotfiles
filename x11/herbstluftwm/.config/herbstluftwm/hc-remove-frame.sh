#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"

herbstclient lock
if [ $(herbstclient layout | wc -l) -gt 1 ]; then

    for winid in $(herbstclient layout | grep "FOCUS" | egrep -o "0x[0-9a-z]{6,}"); do
       herbstclient move $hidden_tag 
    done

    herbstclient remove
fi

$HOME/.config/herbstluftwm/hc-ballance-frames.sh

herbstclient unlock

