#!/bin/bash

if [[ -x "post-checkout" ]]; then
	cp post-checkout $(git rev-parse --show-toplevel)/.git/hooks
	source $(git rev-parse --show-toplevel)/.git/hooks/post-checkout
fi
