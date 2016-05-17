#!/bin/bash

if [[ -x "post-checkout" ]]; then
	cp post-checkout $(git rev-parse --show-toplevl)/.git/hooks
	source $(git rev-parse --show-toplevl)/.git/hooks/post-checkout
fi
