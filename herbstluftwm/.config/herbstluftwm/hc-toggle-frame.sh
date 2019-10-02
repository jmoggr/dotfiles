#!/bin/bash

if [[ "$(herbstclient get frame_gap)" == "24" ]]; then 
    herbstclient set frame_gap 0
else
    herbstclient set frame_gap 24
fi
