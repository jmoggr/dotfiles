#!/bin/bash

herbstclient close_or_remove

# setting the dirty flag will be done by the even listener when it catches the window close hook. The flag does not need to be set for deleting empty frames.
