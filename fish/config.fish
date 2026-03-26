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

#set --universal fish_greeting "Welcome back $(whoami)!"
set --universal fish_greeting ""
#set --erase fish_greeting

# Tide prompt configuration
set --universal tide_left_prompt_separator_diff_color ''
set --universal tide_left_prompt_separator_same_color ''
set --universal tide_right_prompt_separator_diff_color ''
set --universal tide_right_prompt_separator_same_color ''

set --universal tide_context_always_display true

set --universal tide_context_bg_color blue
#set --universal tide_time_style bold

set --universal tide_pwd_bg_color brblue
set --universal tide_pwd_color_dirs brblack
set --universal tide_pwd_color_anchors brblack

set tide_left_prompt_items os user pwd git newline character
set tide_right_prompt_items status cmd_duration jobs node rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig time

#set tide_left_prompt_items user hostname directory git jobs time
#set tide_right_prompt_items status nodejs python ruby battery date

set --universal tide_prompt_add_newline_before true

alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias neofetch "fastfetch"