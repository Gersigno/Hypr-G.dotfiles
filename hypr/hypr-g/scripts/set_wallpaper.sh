#!/bin/bash

# Define the path to your wallpaper file
WALLPAPER_PATH=$1

THEME_FILE=~/.config/hypr/hypr-g/hyprland/env.conf

# Load the current theme mode from the environment file
if [ -f "$THEME_FILE" ]; then
    # Parse the THEME_MODE from the Hyprland env.conf file
    THEME_MODE=$(grep "^env = THEME_MODE" "$THEME_FILE" | cut -d',' -f2)
else
    # Default to dark mode if the file doesn't exist
    THEME_MODE="dark"
fi

# Check if the wallpaper file exists
if [ -f "$WALLPAPER_PATH" ]; then
    # Update swww for the desktop wallpaper
    swww img "$WALLPAPER_PATH" -t random --transition-duration 2.5
    # Generate and apply a color palette using Matugen with the stored mode
    matugen image "$WALLPAPER_PATH" --mode "$THEME_MODE"
    
    echo "✅ Wallpaper and color palette set."
else
    echo "Error: Wallpaper file not found at $WALLPAPER_PATH" >&2
    exit 1
fi