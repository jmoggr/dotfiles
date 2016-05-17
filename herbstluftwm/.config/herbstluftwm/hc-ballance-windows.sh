#!/bin/bash

current_tag=""

if ! [[ -z "$1" ]]; then
    found=false
    for i in {0..9}; do
        if [[ "$i" == "$1" ]]; then
            current_tag=$i
            break
        fi
    done
fi

if [[ -z "${current_tag// }" ]]; then
    current_tag=$(herbstclient attr tags.focus.name)
fi

old_tag=$(herbstclient attr tags.focus.name)

hidden_tag="h$current_tag"

if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
    herbstclient add $hidden_tag 
fi

hidden_layout=$(herbstclient dump $hidden_tag)

window_moved=false

for extra_winid in `herbstclient layout $current_tag | egrep "0x[0-9a-z]{6,} .*?0x[0-9a-z]{6,}" | egrep -o "0x[0-9a-z]{6,}" | head -n -1`; do

    hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^\)]+)(\))/\1 ${extra_winid}\2/")
    window_moved=true
done

if [[ "$window_moved" == "true" ]]; then
    herbstclient load $hidden_tag "$hidden_layout"
fi

