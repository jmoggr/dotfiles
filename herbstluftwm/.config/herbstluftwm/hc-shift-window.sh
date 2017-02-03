#!/bin/bash

source ~/.config/herbstluftwm/hc-lib.sh

desktop_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$desktop_tag"

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

focus_winID=$(herbstclient attr clients.focus.winid)
if [ "$?" != "0" ]; then
    focus_winID=0
fi
    
herbstclient lock

herbstclient focus $direction
if [ "$?" != "0" ]; then
    herbstclient unlock
    exit 0
fi

opposite_winID=$(herbstclient attr clients.focus.winid)
if [ "$?" != "0" ]; then
    opposite_winID=0
fi

herbstclient focus $opposite

herbstclient unlock

# If there is a window in both the opposite  and focused frame
if [[ "$opposite_winID" != 0 ]] && [[ "$focus_winID" != 0 ]]; then
    
    Hidden_Push_Back $hidden_tag $focus_winID
    Hidden_Push_Back $hidden_tag $opposite_winID

    Bring_Window $desktop_tag $opposite_winID

    herbstclient focus $direction

    Bring_Window $desktop_tag $focus_winID

# If there is a window in the opposite frame but not the focused 
elif [[ "$opposite_winID" == 0 ]] && [[ "$focus_winID" != 0 ]]; then
    Hidden_Push_Back $hidden_tag $focus_winID

    herbstclient focus $direction

    Bring_Window $desktop_tag $focus_winID

# If there is no window in the opposite frame but one in the focused
elif [[ "$opposite_winID" != 0 ]] && [[ "$focus_winID" == 0 ]]; then
    Hidden_Push_Back $hidden_tag $opposite_winID

    Bring_Window $desktop_tag $opposite_winID

    herbstclient focus $direction

# if there is no window in the opposite framed or the focused fram
else
    herbstclient focus $direction
fi

