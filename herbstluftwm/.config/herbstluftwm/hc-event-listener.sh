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

herbstclient -i | while read line; do
    
    any=$(echo $line | grep --line-buffered any_window | stdbuf -oL cut -f3 -d' ' )
    close=$(echo $line | grep --line-buffered window_closed | stdbuf -oL cut -f2 -d' ' )

    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    if ! [ -z "${any// }" ]; then

        if Check_fullscreen $current_tag; then
            herbstclient chain . lock . bring $any . move $hidden_tag . unlock
        else
            new_layout=$(herbstclient dump $current_tag)

            # check if there is an empty frame on the current tag
            if echo $new_layout | egrep -q "\(clients (grid|horizontal|vertical|max):(0|1)\)"; then

                # Check if the new window shares a frame with any other window. If it does, move the new window.
                if herbstclient layout $current_tag | egrep "0x[0-9a-z]{6,}.*0x[0-9a-z]{6,}" | grep -q ${any}; then

                    # remove the new window from the layout
                    new_layout=$(echo $new_layout | sed -r "s/${any}//")

                    # add the new window to an empty frame
                    new_layout=$(echo $new_layout | sed -r "s/\(clients (grid|horizontal|vertical|max):(0|1)\)/\(clients \1:\2 ${any}\)/")

                    herbstclient load $current_tag "$new_layout"
                fi

            # if there are no empty frames then the new window may be sharing a frame, if it is then
            # we want to remove all other windows from that frame
            else

                herbstclient lock
                # loop over the current frame in focus (where the new window would have spawned) and hide all
                # windows that are not the new window
                for window_id in `herbstclient layout $current_tag | grep "FOCUS" | egrep -o "0x[a-z0-9]{6,}"`; do

                    if ! [ "$window_id" == "$any" ]; then
                        herbstclient chain . bring $window_id . move $hidden_tag
                    fi
                done

                herbstclient unlock
            fi

            $HOME/.config/herbstluftwm/hc-ballance-windows.sh
            $HOME/.config/herbstluftwm/hc-ballance-frames.sh

        fi

        $HOME/.config/herbstluftwm/hc-input-dirty.sh

    elif ! [ -z "${close// }" ]; then
	   
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


