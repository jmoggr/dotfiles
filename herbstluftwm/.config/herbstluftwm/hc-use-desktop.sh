#!/bin/bash

target_tag=$($HOME/.config/herbstluftwm/hc-check-tag.sh $1)

current_tag=$(herbstclient attr tags.focus.name)

if [[ "$current_tag" != "$target_tag" ]]; then
    herbstclient use "$1"

    $HOME/.config/herbstluftwm/hc-input-dirty.sh
fi


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




