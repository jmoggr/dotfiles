#!/bin/bash

source ~/.config/herbstluftwm/hc-lib.sh

current_tag=$(herbstclient attr tags.focus.name)
hidden_tag="h$current_tag"

hidden_tag_focused=false
current_tag_focused=false

# if there is a focused window
if herbstclient attr clients | grep -q "focus"; then
    current_tag_focused=true
fi

# if there is a window in the hidden tag to cycle with
if herbstclient dump $hidden_tag | egrep -q "0x[0-9a-z]{6,}"; then
    hidden_tag_focused=true
fi

# if there is more than one window in the focussed frame, move the top window to
# the hidden tag
# this should never happen: there should never be more than one window per frame
if [ "$(herbstclient layout | grep "FOCUS" | egrep -o "0x[0-9a-z]{6,}" | wc -l)" -gt 1 ]; then

    # move a window in the overfull frame to the hidden tag
    current_focus=$(herbstclient attr clients.focus.winid)
    Hidden_Push_Back $current_focus $hidden_tag

    $HOME/.config/herbstluftwm/hc-input-dirty.sh
    exit 0
fi

# if there is a window in the hidden tag and desktop tag
if [ "$hidden_tag_focused" == true ] && [ "$current_tag_focused" == true ]; then

    # move the focused window to the hidden tag
    current_focus=$(herbstclient attr clients.focus.winid)
    Hidden_Push_Back $hidden_tag $current_focus

    # move a window in the hidden tag to the dekstop tag
    Hidden_Pop_Front $hidden_tag $current_tag
    $HOME/.config/herbstluftwm/hc-input-dirty.sh

# if there is a window in the hidden tag but none in the current tag
# this should never happen: windows should be automatically filled into frames
# whenevr possible
elif [ "$hidden_tag_focused" == true ] && [ "$current_tag_focused" == false ]; then

    # move a window in the hidden tag to the desktop tag
    Hidden_Pop_Front $hidden_tag $current_tag

    $HOME/.config/herbstluftwm/hc-input-dirty.sh
fi

