#!/bin/bash

if which stow > /dev/null 2>&1; then
    stow_cmd="stow"
elif which xstow > /dev/null 2>&1; then
    stow_cmd="xstow"
else
    echo "Error - no stow program found, please insteall stow or xstow"
    exit 1
fi

for d in $(git rev-parse --show-toplevel)/*/; do 
    eval $stow_cmd --dir=$(git rev-parse --show-toplevel) --restow --target=$HOME $(basename $d)
done

