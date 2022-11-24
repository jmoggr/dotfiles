#!/bin/bash
set -e
set -x
source ~/.config/herbstluftwm/hc-lib.sh

herbstclient unrule --all
herbstclient rule class~.* --hook=any_window
herbstclient rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' --manage=off

function Check_fullscreen
{
    # native herbst fullscreen
    hc_fullscreen_status=$(herbstclient attr .clients.focus.fullscreen 2>&1)

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

Firefox_Focused_Handler ()
{
    s=$(echo "$1" | cut -f 2 | xargs xwininfo -id | grep -e "Absolute upper-left [XY]:" -e "Width" -e "Height" | grep -oE "[0-9]+" | tr '\n' ' ')

    echo "echo printing s: $s"

    echo "$s" | { read borderX borderY width height
    
        eval $(xdotool getmouselocation --shell)

        if [[ "$X" -lt "$borderX" ]]; then
            newX=$borderX
        elif [[ "$X" -gt "$(($borderX + $width))" ]]; then
            newX=$(($borderX + $width))
        else
            newX=$X
        fi

        if [[ "$Y" -gt "$(($borderY + $height))" ]]; then
            newY=$(($borderY + $height))
        elif [[ "$Y" -lt "$borderY" ]]; then
            newY=$borderY
        else
            newY=$Y
        fi

       xdotool mousemove "$newX" "$newY"
    }
}

Window_Opened_Handler () 
{
    new_winID=$1

    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    # if current window is fullscreen 
    if Check_fullscreen $current_tag; then

        # move the new window to the hidden tag
        herbstclient chain . lock . bring $new_winID . move $hidden_tag . unlock

    # if current window is not fullscreen
    else

        # if there exists an empty frame in current tag
        if ! herbstclient dump $current_tag | egrep -q "\(clients (grid|horizontal|vertical|max):(0|1)\)"; then
            # if the new window shares a frame with an existing window
            if herbstclient layout $current_tag | egrep "0x[0-9a-z]{6,}.*0x[0-9a-z]{6,}" | grep -q ${new_winID}; then
                # set the new window to urgent to notify that there is a new
                # window that is hidden
                echo "pulse" > /tmp/hc-input-flag
                herbstclient set_attr .clients."$new_winID".urgent true 
            fi

            # else: the new window was spawned into an empty frame (there
            # are no more empty frames) and there is nothing for us to do
        fi

        $HOME/.config/herbstluftwm/hc-ballance-windows.sh
        $HOME/.config/herbstluftwm/hc-ballance-frames.sh

    fi

}

Window_Closed_Handler () 
{
    echo "close start"
    if [[ -z "$1" ]]; then
        $HOME/.config/herbstluftwm/hc-ballance-windows.sh
        $HOME/.config/herbstluftwm/hc-ballance-frames.sh

        $HOME/.config/herbstluftwm/hc-input-dirty.sh
        return
    fi

    closed_winid="$1"
    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    tag=$(herbstclient attr clients."$closed_winid".tag 2> /dev/null) && rc=$? || rc=$?
    if [[ "$rc" -ne 0 ]]; then
        # a window just closed but we know nothing about it, ballance
        # everything in the current tag and hope for the best
        $HOME/.config/herbstluftwm/hc-ballance-windows.sh
        $HOME/.config/herbstluftwm/hc-ballance-frames.sh

        $HOME/.config/herbstluftwm/hc-input-dirty.sh
    else
        # sometimes it takes a short period for the closed window to be removed from
        # the layout
        while true; do
            herbstclient attr clients | egrep -q "$closed_winid" > /dev/null 2>&1

            if [[ "$?" -ne 0 ]]; then
                break
            else
                sleep 0.02
            fi
        done

        if [[ "$current_tag" -ne "$tag" ]]; then
            echo "Error"
        else
            # if there exists an empty frame in the current tag
            if herbstclient dump $current_tag | egrep -q "\(clients (grid|horizontal|vertical|max):(0|1)\)"; then
                # get a window from the bottom of the queue in the hidden tag

                $HOME/.config/herbstluftwm/hc-ballance-windows.sh
                $HOME/.config/herbstluftwm/hc-ballance-frames.sh

                $HOME/.config/herbstluftwm/hc-input-dirty.sh

            fi
        fi
    fi
    echo "close stop"
}

previous_line=""

herbstclient -i | while read line; do

    if echo "$line" | grep -q 'Mozilla Firefox$'; then
        Firefox_Focused_Handler "$line"
        continue
    fi

    # skip any line with "tag_flags" in it, we don't need this for anything and it can come between a "window_closed" hook and a "window_unmanaged" hook. Not skipping this would require more logic to check if a window_unmanaged came after a window_closed
    if echo $line | grep -q tag_flags; then
        continue
    fi

    event_type=""
    
    if echo $line | grep -q window_closed; then
        event_type="window_closed"
        new_winID=$(echo $line | stdbuf -oL cut -f2 -d' ' )
    elif echo $line | grep -q any_window; then
        event_type="window_opened"
        new_winID=$(echo $line | stdbuf -oL cut -f3 -d' ' )

    # incorrect, windows opened by other programs, emit 'window_unmanaged' when closed by their parent program
    # dialog windows emit a window_unmanaged hook but do not emit a window_close hook, and regular windows emit both a window_close and a window_unmanaged hook. We want to detect close events for all windows closes but only perform one action per closed window. We do this by checking if the line before a window_unmanaged hook is a window_closed hook, since window_closed hooks alwasy come first if there is a window_unmanaged hook without a previous window_closed hook then we know it is a dialog window that is closing and should create an event for it. Otherwise it's a normal window closing that produced 2 events
    elif echo $line | grep -q window_unmanaged; then
        if echo $previous_line | grep -q -v window_closed; then
            event_type="window_closed"
        fi
    fi

    previous_line=$line

    case $event_type in

        "window_opened")
            Window_Opened_Handler $new_winID
            ;;
        "window_closed")
            Window_Closed_Handler $new_winID
            ;;
    esac

done


