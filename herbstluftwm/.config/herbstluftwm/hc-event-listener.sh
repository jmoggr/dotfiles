#!/bin/bash

herbstclient unrule --all
herbstclient rule class~.* --hook=any_window

function Check_fullscreen
{
    # native herbst fullscreen
    hc_fullscreen_status=$(herbstclient attr clients.focus.fullscreen)

    # self rolled fullscreen
    layout_file_name="/tmp/h${1}-layout.txt"

    if [ -e "$layout_file_name" ]; then

        if [ "$hc_fullscreen_status" == "true" ]; then 
            herbstclient fullscreen off
        fi

        return 0
    elif [ "$hc_fullscreen_status" == "true" ]; then 
        return 0
    else
        return 1 
    fi
}

previous_line=""

herbstclient -i | while read line; do

    # skip any line with "tag_flags" in it, we don't need this for anything and it can come between a "window_closed" hook and a "window_unmanaged" hook. Not skipping this would require more logic to check if a window_unmanaged came after a window_closed
    if echo $line | grep -q tag_flags; then
        continue
    fi
    
    window_close=false
    window_open=false
    window_unmanaged=false

    if echo $line | grep -q window_closed; then
        window_close=true
        echo "window closed"
    elif echo $line | grep -q any_window; then
        window_open=true
        new_winID=$(echo $line | stdbuf -oL cut -f3 -d' ' )
        echo "window open"

    # dialog windows emit a window_unmanaged hook but do not emit a window_close hook, and regular windows emit both a window_close and a window_unmanaged hook. We want to detect close events for all windows closes but only perform one action per closed window. We do this by checking if the line before a window_unmanaged hook is a window_closed hook, since window_closed hooks alwasy come first if there is a window_unmanaged hook without a previous window_closed hook then we know it is a dialog window that is closing and should create an event for it. Otherwise it's a normal window closing that produced 2 events
    elif echo $line | grep -q window_unmanaged; then
        if echo $previous_line | grep -q -v window_closed; then
            window_unmanaged=true
        fi
    fi

    previous_line=$line

    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    if [ "$window_open" = true ]; then
        echo $new_winID

        if Check_fullscreen $current_tag; then
            herbstclient chain . lock . bring $new_winID . move $hidden_tag . unlock
        else
            new_layout=$(herbstclient dump $current_tag)

            # check if there is an empty frame on the current tag
            if echo $new_layout | egrep -q "\(clients (grid|horizontal|vertical|max):(0|1)\)"; then

                # Check if the new window shares a frame with new_winID other window. If it does, move the new window.
                if herbstclient layout $current_tag | egrep "0x[0-9a-z]{6,}.*0x[0-9a-z]{6,}" | grep -q ${new_winID}; then

                    # remove the new window from the layout
                    new_layout=$(echo $new_layout | sed -r "s/${new_winID}//")

                    # add the new window to an empty frame
                    new_layout=$(echo $new_layout | sed -r "s/\(clients (grid|horizontal|vertical|max):(0|1)\)/\(clients \1:\2 ${new_winID}\)/")

                    herbstclient load $current_tag "$new_layout"
                fi

            # if there are no empty frames then the new window may be sharing a frame, if it is then
            # we want to remove all other windows from that frame
            else

                herbstclient lock
                # loop over the current frame in focus (where the new window would have spawned) and hide all
                # windows that are not the new window
                for window_id in `herbstclient layout $current_tag | grep "FOCUS" | egrep -o "0x[a-z0-9]{6,}"`; do

                    if ! [ "$window_id" == "$new_winID" ]; then
                        herbstclient chain . bring $window_id . move $hidden_tag
                    fi
                done

                herbstclient unlock
            fi

            $HOME/.config/herbstluftwm/hc-ballance-windows.sh
            $HOME/.config/herbstluftwm/hc-ballance-frames.sh

        fi

        $HOME/.config/herbstluftwm/hc-input-dirty.sh

    # we treat window_close and window_unmanaged the same way for now since we have no special treatment for dialog windows
    elif [ "$window_close" = true ] || [ "$window_unmanaged" = true ]; then
	   
        echo "closing"
        # get a window from the bottom of the queue in the hidden tag
        new_focus=$(herbstclient dump $hidden_tag | egrep -o  "0x[0-9a-z]{6,}" | tail -n 1)

        # if such a window exists bring it to the current tag. 
        if ! [ -z "${new_focus// }" ]; then
            herbstclient chain . lock . bring $new_focus . unlock
            echo "moving $new_focus"
        fi

        $HOME/.config/herbstluftwm/hc-ballance-windows.sh
        $HOME/.config/herbstluftwm/hc-ballance-frames.sh

        $HOME/.config/herbstluftwm/hc-input-dirty.sh
    fi

done


