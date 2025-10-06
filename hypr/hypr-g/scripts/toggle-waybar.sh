#!/bin/bash

# Use -x for exact process name match
WAYBAR_PID=$(pgrep -x waybar)

if [ -z "$WAYBAR_PID" ]; then
    # Waybar is NOT running, so start it in the background (&)
    # Use the full path for maximum reliability
    /usr/bin/waybar &
    # Optionally echo for debugging (viewable in a terminal if launched from there)
    echo "Waybar started."
else
    # Waybar IS running, so kill it completely
    killall waybar
    echo "Waybar killed (PID: $WAYBAR_PID)."
fi