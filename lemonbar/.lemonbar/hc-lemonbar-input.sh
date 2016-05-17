#!/bin/bash

# z3bra - (c) wtfpl 2014
# Fetch infos on your computer, and print them to stdout every second.

default_background="1d2b30"
highlight_background="296B5F"
#default_foreground="dcdab1"
#default_foreground="f4dab1"
#default_foreground="f4e9d6"
default_foreground="f4d4cc"
status_normal="2B8DA6"
status_urgent="b20600"

function get_urgency_colour {
    as_degree=$((( (100 - $1) * 120)/100))

    hex_color=$(python3 /home/jason/.lemonbar/c.py $as_degree 100 35)
    echo $hex_color
}


calendar_date() {
    test=$(date '+%a %b %d')
    echo "%{F#$default_foreground}%{F#$status_normal}%{U#$status_normal}%{+u}%{F#$default_foreground}  $test%{-u}"
}

time_of_day() {
    test=$(date '+%R')
    echo "%{F#$default_foreground}%{F#$status_normal}%{U#$status_normal}%{+u}%{F#$default_foreground}  $test%{-u}"
}

battery() {
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

    if [[ "$capacity" != "100" ]]; then
        #TODO 
        capacity=" $capacity"
    fi

    hex_color=$(get_urgency_colour $((100 - $capacity)))

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#$default_foreground}  $capacity%%{-u}"
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

    echo "%{F#${color}}%{+u}%{U#${color}}${icon}%{F#$default_foreground}  ${percent}%%{-u}"
}

cpuload() {
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

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}}   $cpu_use_percent%%{-u}"
}


temperature() {
    temp=$(cat /sys/class/thermal/thermal_zone1/temp)
    temp=${temp::-3}

    percent=$(((((temp - 40) * 10)/6)))
    #echo $percent

    hex_color=$(get_urgency_colour $percent)

    icon=""
    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}}   $temp°C%{-u}"
}

memused() {
    read total available <<< `grep -E 'Mem(Total|Available)' /proc/meminfo | awk '{print $2}'`

    icon=""
    mem_use_percent=$((100 - ($available * 100) / $total))

    hex_color=$(get_urgency_colour $mem_use_percent)

    echo "%{F#${hex_color}}%{+u}%{U#${hex_color}}$icon%{F#${default_foreground}}   $mem_use_percent%%{-u}"
}

desktop_pager() {
    output=""
    for tag in `herbstclient tag_status`; do

        found=false
        for real_tag in {0..5}; do
            if [[ "${tag:1:2}" == "$real_tag" ]]; then
                found=true
                break
            fi
        done

        if [[ "$found" != "true" ]]; then
            continue
        fi
        
        
        case ${tag:0:1} in
            "#") output+="%{A:herbstclient use ${tag:1:2}:}%{B#$highlight_background}    %{B#$default_background}%{A}" ;;
            ":") output+="%{A:herbstclient use ${tag:1:2}:}    %{A}" ;;
            "!") output+="%{A:herbstclient use ${tag:1:2}:}    %{A}" ;;
            *)   output+="%{A:herbstclient use ${tag:1:2}:}    %{A}"
        esac

        output+=""

    done

    echo "${output}"
}

hidden_window_count() {
    current_tag=$(herbstclient attr tags.focus.name)
    hidden_tag="h$current_tag"

    if ! herbstclient attr tags.by-name | grep -q $hidden_tag; then
        herbstclient add $hidden_tag 
    fi

    count=$(herbstclient dump "h$(herbstclient attr tags.focus.name)" | egrep -o "0x[0-9a-z]{6,}" | wc -l)

    echo "%{T2}%{F#ffffff}$count%{T-}%{F#$default_foreground}"
}

fade_out() {
    #export -f get_urgency_colour
    #fade=$(seq 100 -2 0 | xargs -I {} sh -c 'get_urgency_colour "$@"' _ {} | xargs -I {} printf "%%{B#{}} ")
    fade=$(seq 255 -5 0 | xargs printf "%%{B#%x$default_background} ")
    echo $fade
}

fade_in() {
    fade=$(seq 0 5 255 | xargs printf "%%{B#%x$default_background} ")
    echo $fade
}

counter() {
   /home/jason/.lemonbar/counter-bin 
}

quote() {
    echo "%{T2}For I knew I had to rise above it all, or drown in my own shit%{T1}"
}


#echo "$(date)"

echo "%{B#$default_background}%{F#$default_foreground}%{l}$(desktop_pager)%{F#124A69}┃%{F#$default_foreground}  $(hidden_window_count)  %{F#124A69}┃%{F#$default_foreground}  $(counter) $(fade_out) %{c}$(quote) %{r}$(fade_in) $(battery)    $(volume)    $(memused)    $(temperature)    $(cpuload)    $(calendar_date)    $(time_of_day) %{B#00000000}"

# This loop will fill a buffer with our infos, and output it to stdout.
#while :; do
    #echo "%{B#$default_background}%{F#$default_foreground}%{l}$(desktop_pager)%{F#124A69}┃%{F#$default_foreground}  $(hidden_window_count)  %{F#124A69}┃%{F#$default_foreground}  $(counter) $(fade_out) %{c}$(quote) %{r}$(fade_in) $(battery)    $(volume)    $(memused)    $(temperature)    $(cpuload)    $(calendar_date)    $(time_of_day) %{B#00000000}"
    ##echo "%{B#$default_background}%{F#$default_foreground}%{l}$(desktop_pager)%{F#124A69}┃%{F#$default_foreground}  $(hidden_window_count) $(fade_out)  %{r}$(fade_in) $(battery)    $(volume)    $(memused)    $(temperature)    $(cpuload)    $(calendar_date)    $(time_of_day) %{B#00000000}"
    #sleep 0.5 # The HUD will be updated every second
#done | lemonbar -d -u 2 -f "xft:DejaVu Sans Mono for Powerline:pixelsize=15:antialias=true" -f "xft:DejaVu Sans Mono for Powerline:pixelsize=15:antialias=true:weight=180" -f "FontAwesome-15" -g x24++ | /bin/sh

