#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"
hidden_layout=$(herbstclient dump $hidden_tag)
focus_winid=$(herbstclient attr clients.focus.winid)

for extra_winid in `herbstclient dump $current_tag | egrep -o  "0x[0-9a-z]{6,}" | grep -v "$focus_winid"`; do
    # add extra windids to start of hidden tag stack
    hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^:]+:[^\) ]+)(.*$)/\1 ${extra_winid}\2/")
    window_moved=true
done

if [[ "$window_moved" == "true" ]]; then
    herbstclient load $hidden_tag "$hidden_layout"
    herbstclient load $current_tag "(clients max:0 ${focus_winid})"

# even if no windows were moved there might still be empty frames
elif herbstclient layout | grep max | egrep -v -q "0x[0-9a-z]{6,}"; then
    herbstclient load $current_tag "(clients max:0 ${focus_winid})"
fi

$HOME/.config/herbstluftwm/hc-input-dirty.sh
$HOME/.config/herbstluftwm/hc-ballance-windows.sh
