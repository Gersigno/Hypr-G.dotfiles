#!/bin/sh

# Get the current username
CURRENT_USER=$(whoami)

# --- Define potential profile picture paths ---

# 1. Check for the AccountsService entry
ACCOUNTS_SERVICE_CONF="/var/lib/AccountsService/users/$CURRENT_USER"
ACCOUNTS_SERVICE_ICON_DIR="/var/lib/AccountsService/icons"

# 2. Traditional ~/.face or ~/.face.icon
HOME_FACE_ICON="$HOME/.face.icon"
HOME_FACE="$HOME/.face"

# --- Function to check if a file exists and is a valid image ---
is_image() {
    [ -f "$1" ] && file --mime-type -b "$1" | grep -qE 'image/(png|jpeg|webp|gif)'
}

# --- Search for the profile picture ---
PROFILE_PIC=""

# Check AccountsService configuration first
if [ -f "$ACCOUNTS_SERVICE_CONF" ]; then
    ICON_PATH=$(grep "^Icon=" "$ACCOUNTS_SERVICE_CONF" | cut -d'=' -f2-)
    if [ -n "$ICON_PATH" ]; then
        # Remove "file://" prefix if present
        ICON_PATH=$(echo "$ICON_PATH" | sed 's|^file://||')
        if is_image "$ICON_PATH"; then
            PROFILE_PIC="$ICON_PATH"
        elif is_image "${ACCOUNTS_SERVICE_ICON_DIR}/${CURRENT_USER}"; then
            # Sometimes the Icon path is just the filename, not full path
            PROFILE_PIC="${ACCOUNTS_SERVICE_ICON_DIR}/${CURRENT_USER}"
        fi
    fi
fi

# If not found via AccountsService, check home directory
if [ -z "$PROFILE_PIC" ]; then
    if is_image "$HOME_FACE_ICON"; then
        PROFILE_PIC="$HOME_FACE_ICON"
    elif is_image "$HOME_FACE"; then
        PROFILE_PIC="$HOME_FACE"
    fi
fi

# --- Output the result ---
if [ -n "$PROFILE_PIC" ]; then
    echo "$PROFILE_PIC"
else
    echo "" # Return empty if no picture found, Hyprlock will just not display anything
fi