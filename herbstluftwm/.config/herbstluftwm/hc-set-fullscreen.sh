#!/bin/bash

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"
hidden_layout=$(herbstclient dump $hidden_tag)
focus_winid=$(herbstclient attr clients.focus.winid)

if [[ "$(herbstclient dump | egrep -o '0x[0-9a-z]{6,}' | wc -l)" -eq "1" ]]; then
    if [ -f "/tmp/${hidden_tag}-minscreen-layout.txt" ]; then
        minscreen_layout=$(cat "/tmp/${hidden_tag}-minscreen-layout.txt")

        herbstclient load $current_tag "$minscreen_layout"

        $HOME/.config/herbstluftwm/hc-input-dirty.sh
        $HOME/.config/herbstluftwm/hc-ballance-windows.sh
    else
        # even if no windows were moved there might still be empty frames
        if herbstclient layout | grep max | egrep -v -q "0x[0-9a-z]{6,}"; then
            herbstclient load $current_tag "(clients max:0 ${focus_winid})"
        fi
    fi

else
    herbstclient dump > "/tmp/${hidden_tag}-minscreen-layout.txt"

    for extra_winid in `herbstclient dump $current_tag | egrep -o  "0x[0-9a-z]{6,}" | grep -v "$focus_winid"`; do
        # add extra windids to start of hidden tag stack
        hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^:]+:[^\) ]+)(.*$)/\1 ${extra_winid}\2/")
        window_moved=true
    done

    if [[ "$window_moved" == "true" ]]; then
        herbstclient load $hidden_tag "$hidden_layout"
        herbstclient load $current_tag "(clients max:0 ${focus_winid})"
    fi

    $HOME/.config/herbstluftwm/hc-input-dirty.sh
    $HOME/.config/herbstluftwm/hc-ballance-windows.sh
fi

