-- Main Hyprland Lua configuration
-- Refer to https://wiki.hypr.land/Configuring/Start/
-- Please put your modifications in files under hypr/custom/

-- Hypr-G base configuration
require("hypr-g.hyprland.colors")
require("hypr-g.hyprland.monitors")
require("hypr-g.hyprland.programs")
require("hypr-g.hyprland.autostart")
require("hypr-g.hyprland.env")
require("hypr-g.hyprland.permissions")
require("hypr-g.hyprland.interface")
require("hypr-g.hyprland.input")
require("hypr-g.hyprland.keybinds")
require("hypr-g.hyprland.rules")
require("hypr-g.hyprland.workspaces")

-- Custom user overrides
require("custom.monitors")
require("custom.programs")
require("custom.autostart")
require("custom.env")
require("custom.permissions")
require("custom.interface")
require("custom.input")
require("custom.keybinds")
require("custom.rules")
