#!/bin/bash

# Define the path to your wallpaper file
WALLPAPER_PATH=$1

# Source of truth for the theme mode (gitignored, managed by quickshell)
SETTINGS_FILE="$HOME/.config/quickshell/settings.json"

# Load the current theme mode from the quickshell settings (defaults to dark)
THEME_MODE="dark"
if [ -f "$SETTINGS_FILE" ] && jq -e '.isDarkMode == false' "$SETTINGS_FILE" >/dev/null 2>&1; then
    THEME_MODE="light"
fi

# Check if the wallpaper file exists
if [ -f "$WALLPAPER_PATH" ]; then
    # Update swww for the desktop wallpaper
    cursor=$(hyprctl cursorpos | tr -d ' ') # Get current cursor position
    echo "Setting wallpaper with swww at cursor position: $cursor"
    
    # Correction de awww -> swww (ajuste si awww était un wrapper perso)
    awww img "$WALLPAPER_PATH" -t grow --transition-duration 2.5 --transition-step 90 --transition-fps 60 --transition-pos "$cursor" 
    
    # Generate and apply a color palette using Matugen with the stored mode
    matugen image "$WALLPAPER_PATH" --mode "$THEME_MODE" --source-color-index 0
    
    echo "Done."
else
    echo "Error: Wallpaper file not found at $WALLPAPER_PATH" >&2
    exit 1
fi
