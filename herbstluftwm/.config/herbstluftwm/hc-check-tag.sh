#!/bin/bash

current_tag=""

if [[ -z "$2" ]]; then
    regexp="h\K[0-9]+"
else
    regexp="^\s+\K[^ ]+(?=.$)"
fi

if ! [[ -z "$1" ]]; then
    for i in `herbstclient attr tags.by-name | grep -oP "${regexp}"`; do
            if [[ "$i" == "$1" ]]; then
                current_tag=$i
                break
            fi
    done
fi

if [[ -z "${current_tag// }" ]]; then
    current_tag=$(herbstclient attr tags.focus.name)
fi

echo $current_tag
