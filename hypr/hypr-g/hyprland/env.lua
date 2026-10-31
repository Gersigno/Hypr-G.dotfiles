-- Session variables
hl.env("XDG_CURRENT_DESKTOP",           "Hyprland")
hl.env("XDG_SESSION_TYPE",              "wayland")
hl.env("XDG_SESSION_DESKTOP",           "Hyprland")

-- cursor
hl.env("XCURSOR_SIZE",                  "24")
hl.env("XCURSOR_THEME",                 "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE",               "24")

-- QT
hl.env("QT_QPA_PLATFORMTHEME",          "qt6ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6",      "qt6ct")
hl.env("QT_QPA_PLATFORM",               "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION",   "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",           "1")
hl.env("GDK_BACKEND",                   "wayland,x11,*")
hl.env("ELECTRON_OZONE_PLATFORM_HINT",  "wayland")
hl.env("XDG_MENU_PREFIX",               "arch-")

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("MOZ_DBUS_REMOTE", "1")

hl.env("HYPRSHOT_DIR",                  os.getenv("HOME") .. "/Pictures/Screenshots")

hl.env("ELECTRON_OZONE_PLATFORM_HINT",  "wayland")
hl.env("OZONE_PLATFORM",                "wayland")
hl.env("GTK_CSD",                       "0")
hl.env("GTK_OVERLAY_SCROLLING", "1")
hl.env("CHROMIUM_USER_FLAGS",           "--disable-features=WindowControlsOverlay,WebAppWindowControlsOverlay")