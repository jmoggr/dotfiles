#!/bin/bash

# z3bra - (c) wtfpl 2014
# Fetch infos on your computer, and print them to stdout every second.
default_background="1b2b34"
highlight_background="296B5F"
default_foreground="f4d4cc"

status_urgent="EC5f67"
status_normal="2B8DA6"

accent="124A69"
fullscreen="C594C5"

#default_background="1d2b30"
#highlight_background="296B5F"
#default_foreground="f4d4cc"
#status_normal="2B8DA6"
#status_urgent="b20600"

function get_urgency_colour 
{
    as_degree=$((( (100 - $1) * 120)/100))

    hex_color=$(python3 $HOME/.config/herbstluftwm/lemonbar/c.py $as_degree 100 35)
    echo $hex_color
}


calendar_date() 
{
    date_string=$(date '+%a %b %d')
    echo "%{T4}%{F#$default_foreground}$date_string"
}

time_of_day() 
{
    time_string=$(date '+%R')
    echo "%{F#$default_foreground}$time_string"
}

battery() 
{
    capacity=$(cat /sys/class/power_supply/BAT/capacity | xargs printf "%02d")
    status=$(cat /sys/class/power_supply/BAT/status)

    icon=""

    if [[ "$capacity" -ge "80" ]]; then
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

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#$default_foreground} $capacity%%{-u}"
}

volume() {

    percent=$(amixer get Master | sed -n -r "N;s/^.*\[([0-9]+)\%\].*$/\1/p" | xargs printf "%02d")
    color=""
    icon=""
    
    if amixer get Master | egrep -q "\[[0-9]{1,2}%\] \[off\]"; then
        color="$status_urgent"
    else
        color="$status_normal"
    fi

    echo "%{F#${color}}%{+u}%{U#${color}}${icon}%{F#$default_foreground} %{T0}${percent}%%{-u}"
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

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}} $cpu_use_percent%%{-u}"
}


temperature() 
{
    temp=$(cat /sys/class/thermal/thermal_zone1/temp)
    temp=${temp::-3}

    percent=$(((((temp - 40) * 10)/6)))
    #echo $percent

    hex_color=$(get_urgency_colour $percent)

    icon=""
    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}} $temp°C%{-u}"
}

memused() {
    read total available <<< `grep -E 'Mem(Total|Available)' /proc/meminfo | awk '{print $2}'`

    icon=""
    mem_use_percent=$((100 - ($available * 100) / $total))

    hex_color=$(get_urgency_colour $mem_use_percent)

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}} $mem_use_percent%%{-u}"
}

desktop_pager() 
{
    pager_string="%{F#$default_foreground}"

    for tag in `herbstclient tag_status`; do

        visible_tag_found=false
        for visible_tag in {0..5}; do
            if [[ "${tag:1:2}" == "$visible_tag" ]]; then
                visible_tag_found=true
                break
            fi
        done

        if [[ "$visible_tag_found" != "true" ]]; then
            continue
        fi
        
        case ${tag:0:1} in
            "#") pager_string+="%{A:hc_use_tag ${tag:1:2}:}%{B#$highlight_background}  %{B#$default_background}%{A}" ;;
            ":") pager_string+="%{A:hc_use_tag ${tag:1:2}:}  %{A}" ;;
            "!") pager_string+="%{A:hc_use_tag ${tag:1:2}:}%{F#$status_urgent}  %{F#$default_foreground}%{A}" ;;
            *)   pager_string+="%{A:hc_use_tag ${tag:1:2}:}  %{A}"
        esac
    done

    echo "${pager_string}"
}

hidden_window_count() 
{
    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    window_count=$(herbstclient dump "$hidden_tag" | egrep -o "0x[0-9a-z]{6,}" | wc -l)

    echo "%{T2}%{F#ffffff}$window_count%{T-}%{F#$default_foreground}"
}

fade_out() 
{
    fade=$(seq 255 -5 0 | xargs printf "%%{B#%x$default_background} ")
    echo $fade
}

fade_in() 
{
    fade=$(seq 0 5 255 | xargs printf "%%{B#%x$default_background} ")
    echo $fade
}

var=250
update="false"
watch_file="/tmp/hc-input-flag"

# This loop will fill a buffer with our infos, and output it to stdout.
while :; do
    ((var++))

    if [ "$var" -ge 250 ]; then
        var=0
        update="true"
    fi
        
    if [ -f "$watch_file" ]; then
        rm "$watch_file"
        update="true"
    fi

    if [ "$update" == "true" ]; then
        echo "%{B#$default_background}{F#$default_foreground}%{l}$(desktop_pager) %{F#$accent}┃%{F#$default_foreground} $(hidden_window_count) %{F#$accent}┃%{F#$default_foreground}  $(fade_out)  %{r}$(fade_in)  $(battery)    $(memused)    $(temperature)   $(cpuload)    $(volume)    %{B#$highlight_background}   $(calendar_date)   $(time_of_day) %{B#00000000}"
        update="false"
    fi

    sleep 0.02 

done | \
    lemonbar -d -u 2 \
        -f "DejaVu:pixelsize=15:antialias=true" \
        -f "DejaVu Sans:pixelsize=15:antialias=true:weight=180" \
        -f "FontAwesome-15" \
        -f "DejaVu Sans:pixelsize=15:antialias=true:weight=120" \
        -g x24++ \
| while read line; do
    if [[ "$line" =~ ^hc_use_tag.* ]]; then
        tag=$(echo "$line" | cut -f 2 -d' ')
        $HOME/.config/herbstluftwm/hc-use-desktop.sh $tag
    fi
done

