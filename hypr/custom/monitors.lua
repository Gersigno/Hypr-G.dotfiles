-- Custom monitors
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Run `hyprctl monitors all` to list available outputs

-- Home setup
hl.monitor({ output = "desc:Chimei Innolux Corporation 0x1550", mode = "1920x1080@60", position = "0x0",       scale = 1 })
hl.monitor({ output = "HDMI-A-1",                                mode = "1920x1080@60", position = "-1920x0",   scale = 1 })
hl.monitor({ output = "desc:Beihai Century Joint Innovation Technology Co.Ltd PGM340 V2",
             mode = "3440x1440@144", position = "-860x-1440", scale = 1 }) -- Wide display (on top)

-- hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })
