#!/bin/bash

# --- Configuration ---
# Path to the Hyprland environment file
THEME_FILE="$HOME/.config/hypr/hypr-g/hyprland/env.conf"

# GTK theme names
LIGHT_GTK_THEME="Adwaita"
DARK_GTK_THEME="Adwaita-dark"

# Kitty configuration file
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

# Hyprland reload command
HYPRLAND_RELOAD="hyprctl reload"

# Path to the wallpaper script
GET_WALLPAPER_SCRIPT="$HOME/.config/hypr/hypr-g/scripts/get_wallpaper.sh"

# Function to toggle the theme
toggle_theme() {
    # Check the current theme by reading the env.conf file
    if [ -f "$THEME_FILE" ]; then
        # Parse the THEME_MODE from the Hyprland env.conf file
        CURRENT_MODE=$(grep "^env = THEME_MODE" "$THEME_FILE" | cut -d',' -f2)
    else
        # Default to dark mode if the file doesn't exist
        CURRENT_MODE="dark"
    fi

    # Determine the new mode based on the current one
    if [ "$CURRENT_MODE" = "light" ]; then
        echo "Switching to dark mode..."
        NEW_MODE="dark"
    else
        echo "Switching to light mode..."
        NEW_MODE="light"
    fi

    # Use sed to update the theme_mode line in the Hyprland env.conf file
    sed -i "s|^env = THEME_MODE.*$|env = THEME_MODE,$NEW_MODE|" "$THEME_FILE"

    # Get the current wallpaper path by executing the get_wallpaper script
    WALLPAPER_PATH=$("$GET_WALLPAPER_SCRIPT")

    if [ -z "$WALLPAPER_PATH" ]; then
        echo "Error: Could not get wallpaper path. Matugen requires a valid path." >&2
        exit 1
    fi
    
    # Regenerate the Matugen color palette with the new mode
    matugen image "$WALLPAPER_PATH" --mode "$NEW_MODE"

    if [ "$NEW_MODE" = "dark" ]; then
        # Switch to dark themes
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme "$DARK_GTK_THEME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    else
        # Switch to light themes
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme "$LIGHT_GTK_THEME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    fi

    # Reload Hyprland to apply changes
    $HYPRLAND_RELOAD
}

# Run the function
toggle_theme