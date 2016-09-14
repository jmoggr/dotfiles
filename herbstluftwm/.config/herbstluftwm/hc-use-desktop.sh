#!/bin/bash

herbstclient use "$1"

$HOME/.config/herbstluftwm/hc-input-dirty.sh

#switch_tag="false"

#if [[ -n $1 ]]; then
    #switch_tag=$(herbstclient attr tags.focus.name)
#else:
    #for i in {1..10}; do 
        #if [[ "$i" == "$1" ]]; then
           #switch_tag="$i"
           #break
        #fi
    #done
    
    #if [[ "$switch_tag" == "false" ]]; then
        #exit 0
    #fi
#fi

#current_tag=$(herbstclient attr tags.focus.name)

#if [[ -n $HC_PREVIOUS_TAG ]]; then
    #prevous_tag=""
    #is_current="false"
    #for i in {1..10}; do 
        #if [[ "$i" == $HC_PREVIOUS_TAG ]]; then
            #if [[ "$i" != "$current_tag"]]; then
               #previous_tag="$i" 
               #break
            #else:
                #is_current="true"
                #break
            #fi
        #fi
    #done

    #if ! [[ -n "$previous_tag" ]]; then
        #export HC_PREVIOUS_TAG="$current_tag" 
    #else:
        #export HC_PREVIOUS_TAG="$current_tag" 
        #herbstclient use "$previous_tag"
    #fi
#else:
    #export HC_PREVIOUS_TAG="$current_tag" 
#fi




