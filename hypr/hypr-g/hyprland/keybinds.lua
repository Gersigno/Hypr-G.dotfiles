-- Keybinds
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- Requires programs.lua to be loaded first (defines global "programs" table)

local mainMod = "SUPER" -- "Windows" key as main modifier

-- General window management
hl.bind(mainMod .. " + J",     hl.dsp.layout("togglesplit"))         -- dwindle: toggle split
hl.bind(mainMod .. " + P",     hl.dsp.window.pseudo())               -- toggle pseudotiling
hl.bind(mainMod .. " + B",     hl.dsp.global("quickshell:topBarToggle"))
hl.bind(mainMod .. " + N",     hl.dsp.global("quickshell:notificationsCenterToggle"))
hl.bind(mainMod .. " + F1",    hl.dsp.global("quickshell:controlCenterToggle"))

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region")) -- screenshot

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + Shift + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move window to workspace (and follow)
hl.bind(mainMod .. " + ALT + Page_Down",    hl.dsp.window.move({ workspace = "+1",  follow = true }))
hl.bind(mainMod .. " + ALT + Page_Up",      hl.dsp.window.move({ workspace = "-1",  follow = true }))
hl.bind(mainMod .. " + SHIFT + Page_Down",  hl.dsp.window.move({ workspace = "r+1", follow = true }))
hl.bind(mainMod .. " + SHIFT + Page_Up",    hl.dsp.window.move({ workspace = "r-1", follow = true }))

-- Move window to relative workspace (no follow)
hl.bind("CTRL + " .. mainMod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("CTRL + " .. mainMod .. " + SHIFT + left",  hl.dsp.window.move({ workspace = "r-1" }))

-- Switch workspace on current monitor
hl.bind("CTRL + " .. mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CTRL + " .. mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "m-1" }))

-- Switch workspaces with mainMod + [1-0]
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Focused window actions
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized" })) -- maximized (keeps gaps)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- true fullscreen

-- Multimedia / volume keys (repeating + locked so they work on lockscreen)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { repeating = true, locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { repeating = true, locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { repeating = true, locked = true })

-- Media control (locked so they work on lockscreen)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- Application launchers
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd(programs.web_browser))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd(programs.ide))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(programs.file_explorer))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + Space",             hl.dsp.exec_cmd(programs.launcher))
hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd(programs.emoji))

-- Debug keybinds
hl.bind("CTRL + " .. mainMod .. " + ALT + SHIFT + N",
    hl.dsp.exec_cmd('notify-send -i "dialog-information" "Hyprland Debug" "Test notification"'))
hl.bind("CTRL + " .. mainMod .. " + ALT + SHIFT + D",
    hl.dsp.exec_cmd('zenity --info --text="Test dialog box"'))
