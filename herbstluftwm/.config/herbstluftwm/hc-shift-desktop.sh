#!/bin/bash

target_tag=$($HOME/.config/herbstluftwm/hc-check-tag.sh $1)

current_tag=$(herbstclient attr tags.focus.name)

if [[ "$current_tag" == "$target_tag" ]]; then
    exit 0
fi

herbstclient move "$1"

$HOME/.config/herbstluftwm/hc-ballance-windows.sh
$HOME/.config/herbstluftwm/hc-ballance-frames.sh

$HOME/.config/herbstluftwm/hc-ballance-windows.sh $1
$HOME/.config/herbstluftwm/hc-ballance-frames.sh $1

$HOME/.config/herbstluftwm/hc-input-dirty.sh
