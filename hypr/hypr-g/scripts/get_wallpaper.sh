HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Use grep to find the wallpaper line and awk to get the second field (the path)
WALLPAPER_PATH=$(grep "wallpaper =" "$HYPRPAPER_CONFIG" | awk -F',' '{print $2}' | tr -d '[:space:]')

# Check if a path was found and print it
if [ -n "$WALLPAPER_PATH" ]; then
    echo "$WALLPAPER_PATH"
else
    echo "Could not find a wallpaper path in hyprpaper.conf"
    exit 1
fi