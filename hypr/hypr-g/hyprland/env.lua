-- Environment variables
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE",                  "24")
hl.env("XCURSOR_THEME",                 "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",               "24")
hl.env("QT_QPA_PLATFORMTHEME",          "qt6ct")
hl.env("QT_QPA_PLATFORM",               "wayland")
hl.env("XDG_MENU_PREFIX",               "arch-")

hl.env("THEME_MODE",                "dark")
hl.env("HYPRSHOT_DIR",                  os.getenv("HOME") .. "/Pictures/Screenshots")

hl.env("ELECTRON_OZONE_PLATFORM_HINT",  "wayland")
hl.env("OZONE_PLATFORM",                "wayland")
hl.env("GTK_CSD",                       "0")
hl.env("GTK_OVERLAY_SCROLLING", "1")
hl.env("CHROMIUM_USER_FLAGS",           "--disable-features=WindowControlsOverlay,WebAppWindowControlsOverlay")