# Set system wallpaper with "wallpaper [IMAGE_PATH]" command
function wallpaper --description "Sets the wallpaper using the provided path"
    if not count $argv > /dev/null
        echo "Error: No wallpaper path provided."
        echo "Usage: wallpaper /path/to/your/image.jpg or wallpaper ./relative/image.png"
        return 1
    end
    
    set provided_path $argv[1]

    if not test -f "$provided_path"
        echo "Error: The file '$provided_path' does not exist."
        return 1
    end

    set full_path (realpath "$provided_path")
    
    ~/.config/hypr/hypr-g/scripts/set_wallpaper.sh "$full_path"
end

alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias neofetch fastfetch

# temp ugly code
alias light "set kvantum_theme_name 'Kv-Gnome-Light' \
&& gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' \
&& gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' \
&& echo 'Theme set to light mode'"

# temp ugly code
alias dark "set kvantum_theme_name 'Kv-Gnome-Dark' \
&& gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' \
&& gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' \
&& echo 'Theme set to dark mode'"