#!/bin/bash

# Define the path to your wallpaper file
WALLPAPER_PATH=$1

# Define the static destination path for the hyprlock wallpaper
WALLPAPER_DEST_PATH=~/.config/hypr/hypr-g/hyprlock/wallpaper.png

# Create the destination directory if it doesn't exist
mkdir -p "$(dirname "$WALLPAPER_DEST_PATH")"

# Check if the wallpaper file exists
if [ -f "$WALLPAPER_PATH" ]; then
    # Use the 'file' command to check if it's a PNG image
    if file --mime-type "$WALLPAPER_PATH" | grep -q 'image/png'; then
        # Copy the target image to our static destination for hyprlock
        cp "$WALLPAPER_PATH" "$WALLPAPER_DEST_PATH"
        
        # Update hyprpaper for the desktop wallpaper
        hyprctl hyprpaper preload "$WALLPAPER_PATH"
        hyprctl hyprpaper wallpaper ", $WALLPAPER_PATH"
        
        echo "✅ Wallpaper set on all displays."
    else
        echo "Error: The file is not a PNG image." >&2
        exit 1
    fi
else
    echo "Error: Wallpaper file not found at $WALLPAPER_PATH" >&2
    exit 1
fi