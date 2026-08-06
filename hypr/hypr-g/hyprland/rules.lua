-- Window rules, layer rules, workspace rules
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Suppress maximize requests from all apps
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Layer rules
hl.layer_rule({ match = { namespace = "waybar" },               blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "rofi" },                 blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "fuzzel" },               blur = true })

-- Quickshell layer rules
hl.layer_rule({ match = { namespace = "quickshell:notificationsCenter" }, blur = true, ignore_alpha = 0.79, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:topBar" },              animation = "slide down" })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" },   blur = true, ignore_alpha = 0.79, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:toast" },               blur = true, ignore_alpha = 0.79, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:notifications" },       no_anim = true })

-- Misc layer rules
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "swappy" },    no_anim = true })
hl.layer_rule({ match = { namespace = "hyprshot" },  no_anim = true })
