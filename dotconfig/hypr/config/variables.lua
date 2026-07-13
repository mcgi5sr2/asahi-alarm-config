-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                   Variables Configuration                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from variables.conf for Hyprland 0.55 Lua config.
-- https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("config.colors")

-- ======= General =======
-- https://wiki.hypr.land/Configuring/Basics/Variables/#general

hl.config({
    general = {
        gaps_in    = 6,
        gaps_out   = 12,
        border_size = 2,

        col = {
            -- Two-colour gradient border: `{ colors = {...}, angle = degrees }`
            active_border   = { colors = { "rgba(82dccc33)", "rgba(01ccffee)" }, angle = 90 },
            inactive_border = "rgba(18254533)",
        },

        layout = "dwindle",  -- master | dwindle

        snap = {
            enabled = true,
        },
    },
})

-- ======= Gestures =======
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- Uncomment to enable trackpad gestures:
-- hl.gesture({ fingers = 3, direction = "down",       action = "close",      mod = "ALT" })
-- hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen",  mod = "SUPER", scale = 1.5 })
-- hl.gesture({ fingers = 3, direction = "left",       action = "float",       scale = 1.5 })

-- ======= Group =======
hl.config({
    group = {
        col = {
            border_active          = colors.cachydgreen,
            border_inactive        = colors.cachylgreen,
            border_locked_active   = colors.cachymgreen,
            border_locked_inactive = colors.cachydblue,
        },

        groupbar = {
            font_family = "Noto Sans",
            text_color  = colors.cachydblue,
            col = {
                active          = colors.cachydgreen,
                inactive        = colors.cachylgreen,
                locked_active   = colors.cachymgreen,
                locked_inactive = colors.cachydblue,
            },
        },
    },
})

-- ======= Misc =======
-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
-- NOTE: misc:vfr moved to debug:vfr in 0.55 — not present here so unaffected.
hl.config({
    misc = {
        font_family        = "Noto Sans",
        splash_font_family = "Noto Sans",
        disable_hyprland_logo = true,
        col = {
            splash = colors.cachylgreen,
        },
        background_color   = colors.cachydblue,
        enable_swallow     = true,
        swallow_regex      = "^(cachy-browser|firefox|nautilus|nemo|thunar|btrfs-assistant.)$",
        focus_on_activate  = true,
        vrr                = 2,
    },
})

-- ======= Render =======
hl.config({
    render = {
        direct_scanout = true,
        -- render:cm_fs_passthrough removed in 0.55; behaviour is now automatic via cm_auto_hdr.
    },
})

-- ======= Dwindle Layout =======
-- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- NOTE: dwindle:pseudotile was removed in 0.55.
hl.config({
    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.8,
    },
})

-- ======= Master Layout =======
-- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status           = "master",
        special_scale_factor = 0.8,
    },
})
