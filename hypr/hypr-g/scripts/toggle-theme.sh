#!/bin/bash

# --- Configuration ---
# Set the path to your Waybar style file
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

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

# Function to toggle the theme
toggle_theme() {
    # Check current Waybar theme by looking for a dark color definition
    if grep -q "rgba(27, 24, 24, 0.9)" "$WAYBAR_STYLE"; then
        echo "Switching to light mode..."
        MODE="light"
    else
        echo "Switching to dark mode..."
        MODE="dark"
    fi

    if [ "$MODE" = "dark" ]; then
        # Switch to dark themes
        # Set GTK theme
        gsettings set org.gnome.desktop.interface gtk-theme "$DARK_GTK_THEME"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

        # Set Kitty theme
        sed -i 's|^include.*$|include '"$DARK_KITTY_THEME"'|' "$KITTY_CONFIG"

        # Set Waybar theme (find light colors and replace with dark)
        sed -i 's/@define-color background rgba(240, 240, 240, 0.9);/@define-color background rgba(27, 24, 24, 0.9);/g' "$WAYBAR_STYLE"
        sed -i 's/@define-color inactive rgba(150, 150, 150, 0.667);/@define-color inactive rgba(89, 89, 89, 0.667);/g' "$WAYBAR_STYLE"
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
        sed -i 's/@define-color inactive rgba(89, 89, 89, 0.667);/@define-color inactive rgba(150, 150, 150, 0.667);/g' "$WAYBAR_STYLE"
        sed -i 's/color: white;/color: black;/g' "$WAYBAR_STYLE"
    fi

    # Reload Hyprland to apply changes
    $HYPRLAND_RELOAD
}

# Run the function
toggle_theme