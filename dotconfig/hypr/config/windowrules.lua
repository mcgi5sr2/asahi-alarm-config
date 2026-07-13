-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                  Window / Layer / Workspace Rules           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from windowrulesUpdate.conf for Hyprland 0.55 Lua config.
-- (windowrules.conf was already superseded by windowrulesUpdate.conf.)
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

local colors = require("config.colors")

-- ======= Float Necessary Windows =======

hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" },                                    float = true })
hl.window_rule({ match = { class = "^$",  title = "^(Picture in picture)$" },                             float = true })
hl.window_rule({ match = { class = "^$",  title = "^(Save File)$" },                                      float = true })
hl.window_rule({ match = { class = "^$",  title = "^(Open File)$" },                                      float = true })
hl.window_rule({ match = { class = "^$",  title = "^(Steam - Self Updater)$" },                            float = true })
hl.window_rule({ match = { class = "^(LibreWolf)$",  title = "^(Picture-in-Picture)$" },                  float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" },                                                float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" }, float = true })
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" }, float = true })
hl.window_rule({ match = { class = "^(CachyOSHello)$" },                                                  float = true })
hl.window_rule({ match = { class = "^(zenity)$" },                                                        float = true })

-- ======= Opacity =======

hl.window_rule({ match = { class = "^(thunar|nemo)$" },               opacity = 0.92 })
hl.window_rule({ match = { class = "^(discord|armcord|webcord)$" },   opacity = 0.96 })
hl.window_rule({ match = { title = "^(QQ|Telegram)$" },               opacity = 0.95 })
hl.window_rule({ match = { title = "^(NetEase Cloud Music Gtk4)$" },  opacity = 0.95 })

-- ======= Picture-in-Picture =======

hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    size  = "960 540",
    move  = "25%- 0",
})

-- ======= Media / Float Helpers =======

hl.window_rule({
    match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" },
    float = true,
    size  = "960 540",
    move  = "25%- 0",
})

-- ======= Specific Float Tweaks =======

hl.window_rule({ match = { title = "^(danmufloat)$" },            pin      = true })
hl.window_rule({ match = { title = "^(danmufloat|termfloat)$" },  rounding = 5 })

-- ======= App-Specific Behaviour =======

hl.window_rule({ match = { class = "^(kitty|Alacritty)$" },       animation = "slide right" })
hl.window_rule({ match = { class = "^(org.mozilla.firefox)$" },   no_blur   = true })

-- ======= Floating Window Decorations (workspaces 1–10) =======

hl.window_rule({
    match        = { float = true, workspace = "w[fv1-10]" },
    border_size  = 2,
    border_color = colors.cachylblue,
    rounding     = 8,
})

-- ======= Tiling Window Decorations (workspaces 1–10) =======

hl.window_rule({
    match       = { float = false, workspace = "f[1-10]" },
    border_size = 3,
    rounding    = 4,
})

-- ======= Workspace Rules (smart gaps) =======
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({ workspace = "w[tv1-10]", gaps_out = 5, gaps_in = 3 })
hl.workspace_rule({ workspace = "f[1]",      gaps_out = 5, gaps_in = 3 })

-- ======= Layer Rules =======

hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "waybar" },        animation = "slide down" })
hl.layer_rule({ match = { namespace = "wallpaper" },     animation = "fade 50%" })
