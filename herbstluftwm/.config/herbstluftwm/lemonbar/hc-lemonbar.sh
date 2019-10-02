#!/bin/bash

# z3bra - (c) wtfpl 2014
# Fetch infos on your computer, and print them to stdout every second.
source $HOME/.config/herbstluftwm/hc-colors.sh

function get_urgency_colour 
{
    as_degree=$((( (100 - $1) * 120)/100))

    hex_color=$(python3 $HOME/.config/herbstluftwm/lemonbar/c.py $as_degree 100 35)
    echo $hex_color
}

calendar_date() 
{
    date_string=$(date '+%a %b %d')
    echo "%{T4}%{F$text_color}$date_string"
}

time_of_day() 
{
    time_string=$(date '+%R')
    echo "%{F$text_color}$time_string"
}

battery() 
{
    AC_pattern="/sys/class/power_supply/AC*"
    BAT_pattern="/sys/class/power_supply/BAT*"

    if  ! ls -A $AC_pattern  > /dev/null 2>&1 || ! ls -A $BAT_pattern 2>&1 > /dev/null; then
        icon=""
        hex_color="#00B200"
        echo "%{F${hex_color}}$icon%{F$text_color}"
    else 
        AC_dirs=( $AC_pattern )
        AC_path="${AC_dirs[0]}"
        AC_status=$(cat $AC_path/online)

        BAT_dirs=( $BAT_pattern )
        BAT_path="${BAT_dirs[0]}"

        capacity=$(cat $BAT_pattern/capacity | xargs printf "%02d")
        status=$(cat $BAT_pattern/status)

        if [[ "$capacity" == "99" ]]; then
            capacity=100
        fi

        if [[ "$AC_status" == "1" ]]; then
            icon=""
        elif [[ "$capacity" -ge "80" ]]; then
            icon=""
        elif [[ "$capacity" -ge "60" ]] && [[ "$capacity" -lt "80" ]]; then
            icon=""
        elif [[ "$capacity" -ge "40" ]] && [[ "$capacity" -lt "60" ]]; then
            icon=""
        elif [[ "$capacity" -ge "20" ]] && [[ "$capacity" -lt "40" ]]; then
            icon=""
        else
            icon=""
        fi

        hex_color=$(get_urgency_colour $((100 - $capacity)))

        echo "%{F${hex_color}}%{+u}%{U${hex_color}}$icon%{F$text_color} $capacity%%{-u}"
    fi
}

volume() {

    percent=$(amixer get Master | sed -n -r "s/^.*\[([0-9]+)\%\].*$/\1/p" | head -n 1 | xargs printf "%02d")
    color=""
    icon=""

    if amixer get Master | egrep -q "\[[0-9]{1,2}%\].*\[off\]"; then
        color="$urgent_color"
    else
        color="$accent_color"
    fi

    volume_widget="%{F${color}}%{+u}%{U${color}}"
    volume_widget+="%{A1:volume mute:}%{A4:volume up:}%{A5:volume down:}"
    volume_widget+="${icon}%{F$text_color} %{T0}${percent}%%{-u}"
    volume_widget+="%{A}%{A}%{A}"

    echo "$volume_widget"
}

cpuload() 
{
     cpu_use_percent=$((
        (
            $(
                ps -eo pcpu | 
                grep -vE '^\s*(0.0|%CPU)' | 
                awk '{s+=$1} END {print s * 10}'
            ) / $(nproc)
        ) / 10
    ))

    hex_color=$(get_urgency_colour $cpu_use_percent)

    icon="" 

    echo "%{F${hex_color}}%{+u}%{U${hex_color}}$icon%{F${text_color}} $cpu_use_percent%%{-u}"
}


temperature()
{
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    temp=${temp::-3}

    percent=$(((((temp - 40) * 10)/6)))

    hex_color=$(get_urgency_colour $percent)

    icon=""
    echo "%{F${hex_color}}%{+u}%{U${hex_color}}$icon%{F${text_color}} $temp°C%{-u}"
}

memused() {
    total=$(grep MemTotal /proc/meminfo | grep -Eo "[0-9]+")
    available=$(grep MemAvailable /proc/meminfo | grep -Eo "[0-9]+")

    # TODO what if zfs isn't being used, or the file cannot be read?
    arc_size=$(awk '/^size/ { print $3 }' < /proc/spl/kstat/zfs/arcstats)
    icon=""
    mem_use_percent=$((100 - ($available * 100) / ($total - $arc_size/1024)))

    hex_color=$(get_urgency_colour $mem_use_percent)

    echo "%{F${hex_color}}%{+u}%{U${hex_color}}$icon%{F${text_color}} $mem_use_percent%%{-u}"
}

# Creates a desktop pager
#
# The pager consists of a line of icons, each represnting the state of a
# workspace. When clicked the icons echo their name in the form 
# 'hc_use_tag $name', this may be used to focus on different workspaces.
#
# see the tag_status command in herbstluftwm for a list of valid tag states and
# the characters that represent the states.
desktop_pager()
{
    # the status of each workspace is a combination of the status of the
    # workspaces desktop and hidden tags. States are combined in the
    # workspace_status_chars array with each element containing a string
    # of the combined statuses.
    declare -A workspace_status_chars

    focussed_tag=$(timeout -s 9 1 herbstclient attr tags.focus.name)
    if [ $? -ne 0 ]; then
        return 1
    fi

    tag_status=$(timeout -s 9 1 herbstclient tag_status)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # loop over each tag
    for tag in $(echo "$tag_status"); do
        # if the tag is part of a valid workspace 
        if [[ $tag =~ [\.\:\+\#\-\%\!]h?[1-6] ]]; then
            # get the workspace number
            workspace_number=$(sed 's/[^1-9]*//g' <<< $tag)

            # get the tag state character
            tag_symbol=${tag:0:1}

            # add the new state character to the workspace state string
            workspace_status_chars[$workspace_number]+=$tag_symbol
        fi
    done

    pager_string=""
    # loop for each workspace, workspaces are indexed at 1
    for ((i = 1 ; i < ${#workspace_status_chars[@]} + 1 ; i++)); do
        status_chars=${workspace_status_chars[$i]}

        # default settings for each workspace icon
        foreground_color=$text_color
        background_color=$normal_color
        tag_status_icon=""  

        # if the workspace is focussed and urgent
        if [[ $i == $focussed_tag ]] && [[ $status_chars == *"!"* ]]; then
            foreground_color="$urgent_color"
            tag_status_icon=""
            background_color=$active_color

        # if the workspace is focussed
        elif [[ $i == $focussed_tag ]]; then
            background_color=$active_color
            tag_status_icon=""

        # if the workspace is urgent
        elif [[ $status_chars == *"!"* ]]; then
            foreground_color="$urgent_color"
            tag_status_icon=""

        # if the workspace has a window
        elif [[ $status_chars == *":"* ]]; then
            tag_status_icon=""
        fi

        # build the icon onto the pager
        pager_string+="%{A:hc_use_tag $i:}"
        pager_string+="%{B$background_color}%{F$foreground_color}"
        pager_string+="  $tag_status_icon  "
        pager_string+="%{B$normal_color}%{F$text_color}"
        pager_string+="%{A}"
    done

    last_pager_string="$pager_string"
    # print the pager to the lemonbar
    echo "$pager_string"
}

hidden_window_count()
{
    current_tag=$(timeout -s 9 1 herbstclient attr tags.focus.name)
    if [ $? -ne 0 ]; then
        return 1
    fi

    hidden_tag="h$current_tag"
    window_count=$(timeout -s 9 1 herbstclient dump "$hidden_tag" | egrep -o "0x[0-9a-z]{6,}" | wc -l)
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "%{T2}%{F#ffffff}$window_count%{T-}%{F$text_color}"
}

fade_out() 
{
    fade=$(seq 255 -5 0 | xargs printf "%%{B#%x${normal_color:1}} ")
    echo $fade
}

fade_in() 
{
    fade=$(seq 0 5 255 | xargs printf "%%{B#%x${normal_color:1}} ")
    echo $fade
}

print_lemonbar_string()
{
    pager_string="$(desktop_pager)"
    if [ $? -ne 0 ]; then
        if [ -n "$last_pager_string" ]; then
            pager_string="$last_pager_string"
        fi
    else
        last_pager_string="$pager_string"
    fi

    hidden_window_string="$(hidden_window_count)"
    if [ $? -ne 0 ]; then
        if [ -n "$last_hidden_window_count" ]; then
            hidden_window_string="$last_hidden_window_string"
        fi
    else
        last_hidden_window_string="$hidden_window_string"
    fi

    echo "%{B$normal_color}{F$text_color}%{l}${pager_string} %{F$accent_color}┃%{F$text_color} ${hidden_window_string} %{F$accent_color}┃%{F$text_color}  $(fade_out)  %{r}$(fade_in)    $(battery)    $(memused)    $(temperature)   $(cpuload)    $(volume)    %{B$active_color}   $(calendar_date)   $(time_of_day) %{B#00000000}"
}

watch_file="/tmp/hc-input-flag"

touch $watch_file

# This loop will fill a buffer with our infos, and output it to stdout.
while :; do
    start_time=$(date '+%s')
    print_lemonbar_string
    stop_time=$(date '+%s')
    delta_time=$(($stop_time -$start_time))

    (>&2 echo "Clock Time: $(date '+%R'), Print Duration: $delta_time")

    inotifywait --timeout 2 --event open $watch_file 1>&2

    truncate -s 0 $watch_file

done | \
    lemonbar -d -u 2 \
        -f "DejaVu:pixelsize=15:antialias=true" \
        -f "DejaVu Sans:pixelsize=15:antialias=true:weight=180" \
        -f "FontAwesome-13" \
        -f "DejaVu Sans:pixelsize=15:antialias=true:weight=120" \
        -g x24++ \
| while read line; do
    if [[ "$line" =~ ^hc_use_tag.* ]]; then
        tag=$(echo "$line" | cut -f 2 -d' ')
        $HOME/.config/herbstluftwm/hc-use-desktop.sh $tag
    elif [[ "$line" =~ ^volume.* ]]; then
        cmd=$(cut -f 2 -d' ' <<< "$line")
        $HOME/.config/herbstluftwm/hc-volume-control.sh $cmd
    fi
done

