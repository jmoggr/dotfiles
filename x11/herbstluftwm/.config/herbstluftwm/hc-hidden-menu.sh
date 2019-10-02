#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"

if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
    herbstclient add $hidden_tag 
fi

declare -a arr

for i in `herbstclient dump $hidden_tag | egrep -o "0x[0-9a-z]{6,7}"`; do
    arr+=($i)
done;

if [ ${#arr[@]} -le 0 ]; then
    if [ "$(herbstclient layout | grep "FOCUS" | egrep -o "0x[0-9a-z]{6,7}" | wc -l)" -gt 1 ]; then
        herbstclient move $hidden_tag
    fi

    exit 0
fi

if [ ${#arr[@]} -eq 1 ]; then
    herbstclient chain . lock . move $hidden_tag . bring ${arr[0]} . unlock
    exit 0
fi


test=$(
    for f in "${arr[@]}"; do 
         xwininfo -id $f | 
         grep xwininfo: | 
         cut -d '"' -f 2
    done |
    rofi -dmenu -format 'i' -no-custom 
)

if ! [ -z "$test" ]; then 
    herbstclient chain . lock . move $hidden_tag . bring ${arr[$test]} . unlock
fi

