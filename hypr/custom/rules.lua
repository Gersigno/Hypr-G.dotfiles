-- Custom window rules and workspace rules
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Tor Browser window rules
hl.window_rule({ match = { class = "^(Tor Browser)$" },         float = true, center = true })
hl.window_rule({ match = { class = "^(Tor Browser Launcher)$" }, float = true, center = true })

-- Persistent workspaces per monitor
-- Monitor 2 (HDMI-A-1) - workspaces 5-8
hl.workspace_rule({ workspace = "5",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "6",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "7",  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = "8",  monitor = "HDMI-A-1", persistent = true })

-- Monitor 3 (DP-2) - workspaces 9-12
hl.workspace_rule({ workspace = "9",  monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "11", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "12", monitor = "DP-2", persistent = true })
