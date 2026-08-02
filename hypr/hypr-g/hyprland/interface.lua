-- Interface / Look and Feel
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
-- Requires colors.lua to be loaded first (defines global "colors" table)

hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 8,
        gaps_workspaces  = 50,
        border_size      = 1,
        resize_on_border = false,
        allow_tearing    = true,
        layout           = "dwindle",
        no_focus_fallback = true,

        col = {
            active_border   = colors.border_active,
            inactive_border = colors.border_inactive,
        },

        snap = {
            enabled = true,
        },
    },

    misc = {
        background_color           = colors.background,
        allow_session_lock_restore = true,
        middle_click_paste         = false,
    },

    decoration = {
        rounding       = 10,
        rounding_power = 4,

        active_opacity   = 0.85,
        inactive_opacity = 0.8,
        fullscreen_opacity = 1.0,

        dim_inactive = false,
        dim_strength = 0.1,
        dim_special  = 0,

        blur = {
            enabled          = true,
            size             = 8,
            passes           = 4,
            new_optimizations = true,
            xray             = true,
            ignore_opacity   = true,
            vibrancy         = 0.20,
            contrast         = 0.9,
            brightness       = 0.9,
            noise            = 0.1,
            special          = false,
            popups           = true,
            input_methods    = false,
        },

        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 2,
            sharp        = false,
            color        = colors.shadow_active,
            color_inactive = colors.shadow_inactive,
        },
    },

    animations = {
        enabled = true,
    },
})

-- DISABLED: borders-plus-plus crashes Hyprland 0.55 (pluginInit calls addConfigValueV2 which ABORTs)
-- Re-enable when the plugin is updated for the new Lua config API.
-- hl.config({
--     plugin = {
--         ["borders-plus-plus"] = {
--             add_borders    = 1,
--             col            = { border_1 = colors.border_secondary },
--             border_size_1  = 1,
--             natural_rounding = true,
--         },
--     },
-- })

-- Bezier curves
hl.curve("default",        { type = "bezier", points = { {0.12, 0.92}, {0.08, 1.0}  } })
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1.0}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("wind",           { type = "bezier", points = { {0.12, 0.92}, {0.08, 1.0}  } })
hl.curve("overshot",       { type = "bezier", points = { {0.18, 0.95}, {0.2, 1.08}  } })
hl.curve("OutElastic", { 
    type = "spring",
    mass = 1.0,
    stiffness = 205,
    dampening = 15.5
})
-- Animations
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })

hl.animation({ leaf = "windows",       enabled = true, speed = 5,    bezier = "wind",         style = "popin 60%" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3,    bezier = "overshot",     style = "popin 60%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 4,    bezier = "overshot",     style = "popin 60%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4,    bezier = "overshot",     style = "gnomed" }) -- TODO: use for top-bar anim

hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })

hl.animation({ leaf = "layers",        enabled = true, speed = 4,    bezier = "overshot",     style = "slide" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "overshot",     style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 4,    bezier = "overshot",     style = "slide" })

hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 1,    spring = "OutElastic",     style = "slide" })
-- hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "slide" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })
