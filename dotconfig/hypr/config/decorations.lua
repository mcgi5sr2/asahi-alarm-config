-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                  Decorations Configuration                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from decorations.conf for Hyprland 0.55 Lua config.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration

-- decoration:shadow:ignore_window was removed in 0.55 (now always behaves as enabled).

hl.config({
    decoration = {
        active_opacity   = 1,
        inactive_opacity = 0.92,
        rounding         = 8,

        blur = {
            size    = 15,
            passes  = 2,    -- more passes = more resource intensive
            xray    = true,
        },

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 2,
            color        = "rgba(00000066)",
            color_inactive = "rgba(00000033)",
        },
    },
})
