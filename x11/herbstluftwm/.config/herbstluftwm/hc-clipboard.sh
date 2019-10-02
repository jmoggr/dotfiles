#!/bin/bash

# Helper functions for managing clipboard/x selection

case "$1" in
    promote)
        xsel -p | xsel -ib
    ;;
esac
