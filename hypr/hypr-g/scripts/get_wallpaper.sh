#!/bin/bash

# Query the swww daemon for the current wallpaper path on all outputs
SWWW_OUTPUT=$(swww query)

# Use grep to find the line for the main monitor and then awk to extract the path.
WALLPAPER_PATH=$(echo "$SWWW_OUTPUT" | grep 'eDP-1' | awk '{print $NF}')

# Check if a path was found and print it
if [ -n "$WALLPAPER_PATH" ]; then
    echo "$WALLPAPER_PATH"
else
    echo "Could not query a wallpaper path for the main screen." >&2
    exit 1
fi