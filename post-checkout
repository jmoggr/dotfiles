#!/bin/bash

for d in $(git rev-parse --show-toplevel)/*/; do 
	xstow -dir $(git rev-parse --show-toplevel) -target $HOME $(basename $d)
done
