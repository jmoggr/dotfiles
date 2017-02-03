#!/bin/bash

Hidden_Push_Back ()
{
    hidden_tag=$1
    windowID=$2

    hidden_layout=$(herbstclient dump $hidden_tag)
    hidden_layout=$(echo $hidden_layout | sed -r "s/(^[^\)]+)(\))/\1 ${windowID}\2/")
    herbstclient load $hidden_tag "$hidden_layout"
}

Hidden_Pop_Front ()
{
    hidden_tag=$1
    desktop_tag=$2

    windowID=$(herbstclient dump $hidden_tag | egrep -o "0x[0-9a-z]{6,}" | head -n 1 )
    desktop_layout=$(herbstclient dump $desktop_tag)
    desktop_layout=$(echo "$windowID; $desktop_layout" | ~/.config/herbstluftwm/find-focus.pl)
    herbstclient load $desktop_tag "$desktop_layout"
}

Hidden_Pop_Back ()
{
    hidden_tag=$1
    desktop_tag=$2
    windowID=$(herbstclient dump $hidden_tag | egrep -o  "0x[0-9a-z]{6,}" | tail -n 1)

    # if there is a window in the hidden tag
    if ! [ -z "${windowID// }" ]; then
        
        # add the window to the current tag
        desktop_layout=$(herbstclient dump $desktop_tag)
        desktop_layout=$(echo "$windowID; $desktop_layout" | ~/.config/herbstluftwm/find-focus.pl)

        herbstclient load $desktop_tag "$desktop_layout"
    fi
}

Bring_Window ()
{
    desktop_tag=$1
    windowID=$2

    desktop_layout=$(herbstclient dump $desktop_tag)
    desktop_layout=$(echo "$windowID; $desktop_layout" | ~/.config/herbstluftwm/find-focus.pl)
    herbstclient load $desktop_tag "$desktop_layout"
}
