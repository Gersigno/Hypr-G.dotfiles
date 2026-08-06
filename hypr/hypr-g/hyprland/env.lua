-- Environment variables
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE",              "24")
hl.env("XCURSOR_THEME",             "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",           "24")
hl.env("QT_QPA_PLATFORMTHEME",      "qt6ct")
hl.env("QT_QPA_PLATFORM",           "wayland")
hl.env("THEME_MODE",                "dark")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_MENU_PREFIX",           "arch-")
hl.env("HYPRSHOT_DIR",              os.getenv("HOME") .. "/Pictures/Screenshots")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION","1")
