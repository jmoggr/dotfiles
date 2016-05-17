#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"

hidden_tag_focused=false
current_tag_focused=false

if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
    herbstclient add $hidden_tag 
    exit 0
fi

if herbstclient dump $hidden_tag | egrep -q "0x[0-9a-z]{6,}"; then
    hidden_tag_focused=true
fi

if herbstclient attr clients | grep -q "focus"; then
    current_tag_focused=true
fi

if [ "$(herbstclient layout | grep "FOCUS" | egrep -o "0x[0-9a-z]{6,}" | wc -l)" -gt 1 ]; then
    herbstclient chain . lock . move $hidden_tag . unlock
    exit 0
fi

hidden_layout=$(herbstclient dump $hidden_tag)
#new_layout_current=$(herbstclient dump $current_tag)

# There is a window in the hidden tag and current tag
if [ "$hidden_tag_focused" == true ] && [ "$current_tag_focused" == true ]; then

    new_focus=$(herbstclient dump $hidden_tag | egrep -o "0x[0-9a-z]{6,}" | head -n 1 )

    current_focus=$(herbstclient attr clients.focus.winid)

    hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^\)]+)(\))/\1 ${current_focus}\2/")
    hidden_layout=$(echo $hidden_layout | sed -r "s/$new_focus//")

    herbstclient chain . lock . move $hidden_tag . bring $new_focus . unlock 
    herbstclient load $hidden_tag "$hidden_layout"

# There is a window in the hidden tag but none in the current tag
elif [ "$hidden_tag_focused" == true ] && [ "$current_tag_focused" == false ]; then
    new_focus=$(herbstclient dump $hidden_tag | egrep -o "0x[0-9a-z]{6,}" | tail -n 1 )

    herbstclient chain . lock . bring $new_focus . unlock
fi

