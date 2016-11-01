#!/bin/bash

mkfifo /tmp/dmenu-input
exec 3<> /tmp/dmenu-input

cat applications.txt | grep -v "^#" | grep -oP "^[^\s]+" >&3
app_selected="false"
selected_app=""
base_path=""
target=""
launch_command=""

function update_dmenu
{
    echo "CLEAR" >&3

    if [[ "$hidden_files" = "true" ]]; then
        if [[ "$select_dir" = "true" ]]; then
            ls -1da $target/{.*,*}/ | xargs basename -a >&3
        else
            ls -1a "$target" >&3
        fi
    else 
        if [[ "$select_dir" = "true" ]]; then
            { echo "."; echo ".."; ls -d -1 $target/*/; } | xargs basename -a >&3
        else
            { echo ".."; ls -1 "$target"; } >&3
        fi
    fi

}

while read line; do
    if [[ "$app_selected" = "false" ]]; then
        app_line=$(cat applications.txt | grep -P "^${line}")

        read app_selected launch_command with_path select_dir hidden_files base_path <<< $(echo $app_line)

        launch_command="${launch_command/#\~/$HOME}"
        if [[ "$with_path" = "true" ]]; then
            app_selected="true"
            selected_app=$line
            target=$base_path
            target="${target/#\~/$HOME}"

            update_dmenu
            continue
        else
            echo "STOP" >&3
            herbstclient spawn $launch_command
            break
        fi
    fi

    target="${target}/${line}"

    if [[ "$select_dir" = true ]] && ( [[ "$line" = "." ]] || ! ls -d -l $target/*/ > /dev/null 2>&1 ); then
        herbstclient spawn $launch_command $target
        echo "STOP" >&3
        break
    elif [ -f "$target" ] && [[ "$select_dir" = "false" ]]; then
        herbstclient spawn $launch_command $target
        echo "STOP" >&3
        break
    fi

    update_dmenu

done < <(dmenu -l 20 -p "prompt: " -I -x 646 -y 74 -w 1268 -ct "CLEAR" -st "STOP" <&3)

exec 3>&-
rm /tmp/dmenu-input
