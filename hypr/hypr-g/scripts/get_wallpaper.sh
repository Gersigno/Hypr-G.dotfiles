#!/bin/bash

# Query the swww daemon for the current wallpaper path on all outputs
SWWW_OUTPUT=$(swww query)

# Use awk to extract the first wallpaper path
# The output is formatted as "OUTPUT_NAME: /path/to/wallpaper.png"
WALLPAPER_PATH=$(echo "$SWWW_OUTPUT" | awk '{print $2}' | head -n 1)

# Check if a path was found and print it
if [ -n "$WALLPAPER_PATH" ]; then
    echo "$WALLPAPER_PATH"
else
    echo "Could not query a wallpaper path from swww."
    exit 1
fi