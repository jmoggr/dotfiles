#!/bin/bash


current_tag=""

# check if a valid tag name was passed in
if ! [[ -z "$1" ]]; then
    found=false
    for i in {0..9}; do
        if [[ "$i" == "$1" ]]; then
            current_tag=$i
            break
        fi
    done
fi

# if no valid tag was passed in use the current tag
if [[ -z "${current_tag// }" ]]; then
    current_tag=$(herbstclient attr tags.focus.name)
fi

hidden_tag="h$current_tag"

new_layout=$(herbstclient dump $current_tag)
change_made=false

for hidden_winid in `herbstclient dump $hidden_tag | egrep -o  "0x[0-9a-z]{6,}"`; do
    if echo $new_layout | egrep -q "\(clients (grid|horizontal|vertical|max):(0|1)\)"; then
        new_layout=$(echo $new_layout | sed -r "s/\(clients (grid|horizontal|vertical|max):(0|1)\)/\(clients \1:\2 ${hidden_winid}\)/")
        change_made=true
    else
        break
    fi
done

if [[ "$change_made" == "true" ]]; then
    herbstclient load $current_tag "$new_layout"
fi
