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