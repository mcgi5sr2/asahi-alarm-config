-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Monitor Configuration                    ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from monitor.conf for Hyprland 0.55 Lua config.
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Fallback rule: any unmatched output uses preferred mode/auto position
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Laptop built-in display
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
})

-- First external monitor (right of laptop)
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@144",
    position = "1920x0",
    scale    = 1,
})

-- Second external monitor (rightmost)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144",
    position = "4480x0",
    scale    = 1,
})

-- Uncomment to force zero XWayland scaling and set GDK scale factor:
-- hl.config({ xwayland = { force_zero_scaling = true } })
-- hl.env("GDK_SCALE", "1.25")
