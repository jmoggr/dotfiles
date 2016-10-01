#!/bin/bash

mkfifo /tmp/dmenu-input
exec 3<> /tmp/dmenu-input

cat applications.txt | grep -oP "^[^\s]+" >&3
app_selected="false"
selected_app=""
base_path=""
target=""

while read line; do

    if [[ "$app_selected" = "false" ]]; then
        app_line=$(cat applications.txt | grep -P "^${line}")

        read app_selected with_path select_dir hidden_files base_path <<< $(echo $app_line)

        if [[ "$with_path" = "true" ]]; then
            app_selected="true"
            selected_app=$line
            target=$base_path

            echo "CLEAR" >&3
            
            if [[ "$hidden_files" = "true" ]]; then
                if [[ "$select_dir" = "true" ]]; then
                    ls -1da $base_path/{.*,*}/ | xargs basename -a >&3
                else
                    ls -1a "$base_path" >&3
                fi
            else 
                if [[ "$select_dir" = "true" ]]; then
                    { echo "."; echo ".."; ls -d -1 $base_path/*/; } | xargs basename -a >&3
                else
                    { echo "."; echo ".."; ls -1 "$base_path"; } >&3
                fi
            fi
        else
            echo "STOP" >&3
            herbstclient spawn $line 
            break
        fi

    
            new_target="${target}/${line}"

            if [[ "$select_dir" = true ]] && [[ "$line" = "." ]]; then
                herbstclient spawn $selected_app $target
                echo "STOP" >&3
                break
            elif [ -f "$new_target" ] && [[ "$select_dir" = false ]]; then
                herbstclient spawn $selected_app $new_target
                echo "STOP" >&3
                break
            fi

            target=$(realpath "$new_target")
            echo $target

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
                    { echo "."; echo ".."; ls -1 "$target"; } >&3
                fi
            fi
    fi
done < <(dmenu -l 20 -p "prompt: " -I -x 646 -y 74 -w 1268 -ct "CLEAR" -st "STOP" <&3)

exec 3>&-
rm /tmp/dmenu-input
