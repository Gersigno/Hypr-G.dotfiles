#!/bin/bash

# Query the swww daemon for the current wallpaper path on all outputs
SWWW_OUTPUT=$(swww query)

# Use grep to find the line with the image path and awk to extract the last field
WALLPAPER_PATH=$(echo "$SWWW_OUTPUT" | grep 'image:' | awk '{print $NF}')

# Check if a path was found and print it
if [ -n "$WALLPAPER_PATH" ]; then
    echo "$WALLPAPER_PATH"
else
    echo "Could not query a wallpaper path from swww." >&2
    exit 1
fi