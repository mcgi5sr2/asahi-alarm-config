-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Plugins Configuration                    ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from plugins.conf for Hyprland 0.55 Lua config.
-- Confirmed: hyprlang `plugin:dynamic-cursors {}` maps to
--            hl.config({ plugin = { dynamic_cursors = { ... } } })
--            (hyphens become underscores in Lua table keys)
-- Source: VirtCode/hypr-dynamic-cursors README

hl.config({
    plugin = {
        dynamic_cursors = {
            enabled = true,
            mode    = "none",

            shake = {
                enabled   = true,
                threshold = 6.0,
                base      = 4.0,
                speed     = 4.0,
                timeout   = 2000,
            },

            hyprcursor = {
                enabled = true,
                nearest = true,
            },
        },
    },
})
