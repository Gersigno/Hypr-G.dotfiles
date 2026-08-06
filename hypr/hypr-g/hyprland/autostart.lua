-- Autostart
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("awww restore")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("waybar")
    -- hl.exec_cmd("dunst")
    hl.exec_cmd("hyprctl setenv qsConfig default")
    hl.exec_cmd("quickshell")
    -- DISABLED: borders-plus-plus crashes Hyprland 0.55 (plugin not yet updated for Lua API)
    -- hl.exec_cmd("hyprpm reload && hyprctl dismissnotify")
    -- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)
