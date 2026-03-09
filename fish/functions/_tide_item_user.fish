function _tide_item_user
    if set -q SSH_TTY
        set -fx tide_context_color $tide_context_color_ssh
    else if test "$EUID" = 0
        set -fx tide_context_color $tide_context_color_root
    else if test "$tide_context_always_display" = true
        set -fx tide_context_color $tide_context_color_default
    else
        return
    end

    string match -qr "^(?<h>(\.?[^\.]*){0,$tide_context_hostname_parts})" @$hostname
    set user_cap (string upper (string sub -l 1 $USER))(string sub -s 2 $USER) # Capitalize first letter of username
    set host_cap (string upper (string sub -l 1 $hostname))(string sub -s 2 $hostname) # Capitalize first letter of hostname
    set bold_user (printf '\e[1m%s\e[22m' $user_cap)
    _tide_print_item context $bold_user@$host_cap
end
