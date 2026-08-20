#!/bin/bash

# Query the swww/awww daemon for current wallpaper paths on all outputs
SWWW_OUTPUT=$(awww query 2>/dev/null)

# Check if daemon is running and returned output
if [ -z "$SWWW_OUTPUT" ]; then
    echo "Error: awww daemon is not running or returned no output." >&2
    exit 1
fi

# Dynamically detect the first connected monitor from sysfs
MAIN_MONITOR=$(grep -l '^connected$' /sys/class/drm/card*-*/status 2>/dev/null | head -n 1 | sed -E 's|.*/card[0-9]+-([^/]+)/status|\1|')

# Extract the wallpaper path for the detected monitor (or fallback to the first listed monitor)
if [ -n "$MAIN_MONITOR" ] && echo "$SWWW_OUTPUT" | grep -q "$MAIN_MONITOR"; then
    WALLPAPER_PATH=$(echo "$SWWW_OUTPUT" | grep "$MAIN_MONITOR" | head -n 1 | awk '{print $NF}')
else
    WALLPAPER_PATH=$(echo "$SWWW_OUTPUT" | head -n 1 | awk '{print $NF}')
fi

# Clean up any surrounding quotes around the path
WALLPAPER_PATH=$(echo "$WALLPAPER_PATH" | tr -d '"' | tr -d "'")

# Verify and print the result
if [ -n "$WALLPAPER_PATH" ]; then
    echo "$WALLPAPER_PATH"
else
    echo "Error: Could not query a wallpaper path for the main screen." >&2
    exit 1
fi