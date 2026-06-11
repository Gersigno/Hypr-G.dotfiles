#!/bin/bash

# Define the path to your wallpaper file
WALLPAPER_PATH=$1

# Path to the Hyprland environment file (MODIFIÉ EN .LUA)
THEME_FILE="$HOME/.config/hypr/hypr-g/hyprland/env.lua"

# Load the current theme mode from the environment file
if [ -f "$THEME_FILE" ]; then
    # Parse THEME_MODE depuis la syntaxe Lua hl.env("THEME_MODE", "valeur")
    THEME_MODE=$(grep "hl.env(\"THEME_MODE\"" "$THEME_FILE" | sed -E 's/.*"([^"]+)".*/\1/')
else
    # Default to dark mode if the file doesn't exist
    THEME_MODE="dark"
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