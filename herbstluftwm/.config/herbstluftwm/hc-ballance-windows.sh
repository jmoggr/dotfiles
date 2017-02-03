#!/bin/bash

current_tag=$($HOME/.config/herbstluftwm/hc-check-tag.sh $1)
hidden_tag="h$current_tag"

if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
    herbstclient add $hidden_tag 
fi

hidden_layout=$(herbstclient dump $hidden_tag)

window_moved=false

for extra_winid in `herbstclient layout $current_tag | egrep "0x[0-9a-z]{6,} .*?0x[0-9a-z]{6,}" | egrep -o "0x[0-9a-z]{6,}" | tail -n -1`; do

    # add window to back of hidden tag
    hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^\)]+)(\))/\1 ${extra_winid}\2/")
    window_moved=true
done

if [[ "$window_moved" == "true" ]]; then
    echo "ballancing windows change" >> ~/hce.out
    herbstclient load $hidden_tag "$hidden_layout"
fi

