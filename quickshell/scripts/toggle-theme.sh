#!/bin/bash

# --- Configuration ---
# Source of truth for the theme mode (gitignored, managed by quickshell)
SETTINGS_FILE="$HOME/.config/quickshell/settings.json"

# GTK theme names
LIGHT_GTK_THEME="Adwaita"
DARK_GTK_THEME="Adwaita-dark"

# Kitty configuration file
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

# Hyprland reload command
HYPRLAND_RELOAD="hyprctl reload"

# Path to the wallpaper script
GET_WALLPAPER_SCRIPT="$HOME/.config/quickshell/scripts/get_wallpaper.sh"

# Read the stored theme mode from settings.json (defaults to dark)
read_mode() {
    if [ -f "$SETTINGS_FILE" ] && jq -e '.isDarkMode == false' "$SETTINGS_FILE" >/dev/null 2>&1; then
        echo "light"
    else
        echo "dark"
    fi
}

# Persist the theme mode into settings.json (quickshell picks it up via watchChanges)
write_mode() {
    if [ -f "$SETTINGS_FILE" ]; then
        local value tmp
        if [ "$1" = "dark" ]; then value="true"; else value="false"; fi
        tmp=$(mktemp)
        if jq --argjson v "$value" '.isDarkMode = $v' "$SETTINGS_FILE" > "$tmp"; then
            mv "$tmp" "$SETTINGS_FILE"
        else
            rm -f "$tmp"
            echo "Error: failed to update $SETTINGS_FILE" >&2
        fi
    fi
}

# Function to toggle the theme
toggle_theme() {
    NEW_MODE="$1"

    if [ "$NEW_MODE" != "dark" ] && [ "$NEW_MODE" != "light" ]; then
        # No valid mode argument: flip the stored mode
        if [ "$(read_mode)" = "light" ]; then
            NEW_MODE="dark"
        else
            NEW_MODE="light"
        fi
    fi

    # Keep settings.json in sync with the mode being applied
    write_mode "$NEW_MODE"

    # Get the current wallpaper path by executing the get_wallpaper script
    WALLPAPER_PATH=$("$GET_WALLPAPER_SCRIPT")

    if [ -z "$WALLPAPER_PATH" ]; then
        echo "Error: Could not get wallpaper path. Matugen requires a valid path." >&2
        exit 1
    fi

    # Regenerate the Matugen color palette with the new mode
    matugen image "$WALLPAPER_PATH" --mode "$NEW_MODE" --source-color-index 0

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

    # Forcer Qt/Dolphin à rafraîchir ses configurations à chaud
    touch "$HOME/.config/qt6ct/qt6ct.conf"
    touch "$HOME/.config/kdeglobals"
}

# Run the function
toggle_theme "$1"
