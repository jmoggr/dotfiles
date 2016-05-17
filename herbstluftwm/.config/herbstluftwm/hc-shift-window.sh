#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"

if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
    herbstclient add $hidden_tag 
fi

if [ "left" == "$1" ]; then
    direction="left"
    opposite="right"
elif [ "right" == "$1" ]; then
    direction="right"
    opposite="left"
elif [ "up" == "$1" ]; then
    direction="up"
    opposite="down"
elif [ "down" == "$1" ]; then
    direction="down"
    opposite="up"
else
    exit 1
fi

herbstclient lock
current_focus=$(herbstclient attr clients.focus.winid)

result="$((herbstclient focus $direction) 2>&1)"

if [ "$result" == "focus: No neighbour found" ]; then
    herbstclient unlock
    exit 0
fi

opposite_focus=$(herbstclient attr clients.focus.winid)
opposite_status=$?

herbstclient focus $opposite
herbstclient unlock

#hidden_layout=$(herbstclient dump $hidden_tag)
#current_layout=$(herbstclient dump $current_tag)

#move_focus=$(herbstclient attr clients.focus.winid)

echo $opposite_focus

new_focus=$(herbstclient dump $hidden_tag | egrep -o "0x[0-9a-z]{6,}" | head -n 1 )

if [[ -z "${new_focus// }" ]] && [[ "$opposite_status" == 0 ]]; then

    echo "case 1"
    herbstclient chain . lock . move $hidden_tag . focus $direction . move $hidden_tag . unlock
    sleep 0.4
    herbstclient chain . lock . focus $opposite . bring $opposite_focus . focus $direction . bring $current_focus . unlock


elif [[ "${new_focus// }" ]] && [[ "$opposite_status" != 0 ]]; then
    echo "case 2"
    herbstclient chain . lock . move $hidden_tag . bring $new_focus . unlock 
    herbstclient focus $direction
    sleep 0.4 
    herbstclient chain . lock . bring $current_focus . unlock 

elif [[ "${new_focus// }" ]] && [[ "$opposite_status" == 0 ]]; then
    echo "case 3"
    herbstclient chain . lock . move $hidden_tag . bring $new_focus . unlock 
    herbstclient focus $direction
    sleep 0.4 
    herbstclient chain . lock . move $hidden_tag . bring $current_focus . unlock 

elif [[ -z "${new_focus// }" ]] && [[ "$opposite_status" != 0 ]]; then
    echo "case 4"
    herbstclient move $hidden_tag
    herbstclient focus $direction
    sleep 0.4
    herbstclient bring $current_focus
fi


#hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^\)]+)(\))/\1 ${move_focus}\2/")
#hidden_layout=$(echo $hidden_layout | sed -r "s/$new_focus//")

#current_layout=$(echo $current_layout | sed -r "s/${current_focus}/${new_focus}/")
#current_layout=$(echo $current_layout | sed -r "s/${move_focus}/${current_focus}/")

#echo $current_layout
#echo ""
#echo $hidden_layout

#herbstclient load $hidden_tag "${hidden_layout}" 
#echo "HERE"
#herbstclient load $current_tag "${current_layout}"

#herbstclient chain . lock . move $hidden_tag . bring $new_focus . unlock 



#herbstclient . focus $direction . move $hidden_tag . bring $current_focus . focus $opposite . bring $new_focus . focus $direction

#herbstclient chain . focus $opposite . move $hidden_tag . focus $direction . move $hidden_tag . bring $current_focus . focus $opposite . bring $new_focus . focus $direction
#herbstclient chain . move $hidden_tag . bring $current_focus . focus $opposite . bring $new_focus . focus $direction

