#!/bin/bash

# --- Configuration ---
# Set the path to your Waybar style file
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# Path to the Hyprland environment file
THEME_FILE="$HOME/.config/hypr/hypr-g/hyprland/env.conf"

# GTK theme names
LIGHT_GTK_THEME="Adwaita"
DARK_GTK_THEME="Adwaita-dark"

# Kitty configuration file
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

# Kitty theme names
LIGHT_KITTY_THEME="light_theme.conf"
DARK_KITTY_THEME="dark_theme.conf"

# Hyprland reload command
HYPRLAND_RELOAD="hyprctl reload"
WALLPAPER_PATH="~/.config/hypr/hypr-g/hyprlock/wallpaper.png"

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

    if [ "$NEW_MODE" = "dark" ]; then
        # Switch to dark themes
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme "$DARK_GTK_THEME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

        # Set Kitty theme
        sed -i 's|^include.*$|include '"$DARK_KITTY_THEME"'|' "$KITTY_CONFIG"

        # Set Waybar theme (find light colors and replace with dark)
        sed -i 's/@define-color background rgba(240, 240, 240, 0.9);/@define-color background rgba(27, 24, 24, 0.9);/g' "$WAYBAR_STYLE"
        sed -i 's/color: black;/color: white;/g' "$WAYBAR_STYLE"
    else
        # Switch to light themes
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme "$LIGHT_GTK_THEME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-light"

        # Set Kitty theme
        sed -i 's|^include.*$|include '"$LIGHT_KITTY_THEME"'|' "$KITTY_CONFIG"

        # Set Waybar theme (find dark colors and replace with light)
        sed -i 's/@define-color background rgba(27, 24, 24, 0.9);/@define-color background rgba(240, 240, 240, 0.9);/g' "$WAYBAR_STYLE"
        sed -i 's/color: white;/color: black;/g' "$WAYBAR_STYLE"
    fi

    # Reload Hyprland to apply changes
    $HYPRLAND_RELOAD
}

# Run the function
toggle_theme