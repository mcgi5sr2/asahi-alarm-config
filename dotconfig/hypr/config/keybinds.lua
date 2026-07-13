-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                        Keybinds                             ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from keybinds.conf for Hyprland 0.55 Lua config.
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Bind flag mapping from old hyprlang:
--   bind   →  hl.bind(keys, dispatcher)
--   bindd  →  hl.bind(keys, dispatcher)             -- description becomes a comment
--   bindel →  hl.bind(keys, dispatcher, { locked=true, repeating=true })
--   bindm  →  hl.bind(keys, dispatcher, { mouse=true })
--   binde  →  hl.bind(keys, dispatcher, { repeating=true })

local defaults = require("config.defaults")
local M        = "SUPER"  -- main modifier

-- ======= Application Launchers =======

hl.bind(M .. " + RETURN", hl.dsp.exec_cmd(defaults.terminal))
-- M + E: file manager (empty in defaults — bind is a no-op until set)
if defaults.filemanager ~= "" then
    hl.bind(M .. " + E", hl.dsp.exec_cmd(defaults.filemanager))
end
hl.bind(M .. " + S",          hl.dsp.exec_cmd(defaults.capturing))
hl.bind(M .. " + SHIFT + S",  hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(M .. " + SPACE",      hl.dsp.exec_cmd(defaults.applauncher))
hl.bind(M .. " + SHIFT + P",  hl.dsp.exec_cmd("gnome-calculator"))
hl.bind(M .. " + L",          hl.dsp.exec_cmd("hyprlock"))
hl.bind(M .. " + O",          hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))  -- reload Waybar

-- ======= Window Management =======

hl.bind(M .. " + Q",         hl.dsp.window.close())
hl.bind(M .. " + SHIFT + M", hl.dsp.exec_cmd('loginctl terminate-user ""'))
hl.bind(M .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + F",         hl.dsp.window.fullscreen())
hl.bind(M .. " + Y",         hl.dsp.window.pin())
hl.bind(M .. " + J",         hl.dsp.layout("togglesplit"))  -- dwindle only

-- ======= Grouping Windows =======

hl.bind(M .. " + K",   hl.dsp.group.toggle())  -- togglegroup
hl.bind(M .. " + Tab", hl.dsp.group.next())    -- changegroupactive forward

-- ======= Gap Toggles (runtime hyprctl) =======

hl.bind(M .. " + SHIFT + G", hl.dsp.exec_cmd([[hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"]]))
hl.bind(M .. " + G",         hl.dsp.exec_cmd([[hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"]]))

-- ======= Volume Control =======
-- bindel (locked + repeating) — works on lock screen, repeats while held

hl.bind("XF86AudioRaiseVolume",
    hl.dsp.exec_cmd([[pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>100) system("pactl set-sink-volume @DEFAULT_SINK@ 100%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioLowerVolume",
    hl.dsp.exec_cmd([[pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]),
    { locked = true, repeating = true }
)
hl.bind("XF86AudioMute",
    hl.dsp.exec_cmd([[amixer sset Master toggle | sed -En '/\[on\]/ s/.*\[([0-9]+)%\].*/\1/ p; /\[off\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]]),
    { locked = true, repeating = true }
)

-- ======= Playback Control =======

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ======= Screen Brightness =======

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- ======= Focus Movement =======

hl.bind(M .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(M .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(M .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(M .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- ======= Move Window in Tiling =======

hl.bind(M .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(M .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(M .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(M .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- ======= Window Resize =======
-- Keyboard resize submap (SUPER + R to enter, Escape to exit)

hl.bind(M .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right",   hl.dsp.window.resize({ x =  15, y =   0, relative = true }), { repeating = true })
    hl.bind("left",    hl.dsp.window.resize({ x = -15, y =   0, relative = true }), { repeating = true })
    hl.bind("up",      hl.dsp.window.resize({ x =   0, y = -15, relative = true }), { repeating = true })
    hl.bind("down",    hl.dsp.window.resize({ x =   0, y =  15, relative = true }), { repeating = true })
    hl.bind("l",       hl.dsp.window.resize({ x =  15, y =   0, relative = true }), { repeating = true })
    hl.bind("h",       hl.dsp.window.resize({ x = -15, y =   0, relative = true }), { repeating = true })
    hl.bind("k",       hl.dsp.window.resize({ x =   0, y = -15, relative = true }), { repeating = true })
    hl.bind("j",       hl.dsp.window.resize({ x =   0, y =  15, relative = true }), { repeating = true })
    hl.bind("escape",  hl.dsp.submap("reset"))
end)

-- Quick resize (no submap required) — SUPER + CTRL + SHIFT + arrow / hjkl
hl.bind(M .. " + CTRL + SHIFT + right", hl.dsp.window.resize({ x =  15, y =   0, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + left",  hl.dsp.window.resize({ x = -15, y =   0, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + up",    hl.dsp.window.resize({ x =   0, y = -15, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + down",  hl.dsp.window.resize({ x =   0, y =  15, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + l",     hl.dsp.window.resize({ x =  15, y =   0, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + h",     hl.dsp.window.resize({ x = -15, y =   0, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + k",     hl.dsp.window.resize({ x =   0, y = -15, relative = true }))
hl.bind(M .. " + CTRL + SHIFT + j",     hl.dsp.window.resize({ x =   0, y =  15, relative = true }))

-- Mouse drag: move and resize windows
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ======= Workspace Navigation =======

for i = 1, 10 do
    local key = i % 10  -- key 0 maps to workspace 10
    hl.bind(M .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(M .. " + CTRL + " .. key,      hl.dsp.window.move({ workspace = i }))
    hl.bind(M .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i, silent = true }))
end

-- Relative workspace scrolling
hl.bind(M .. " + CTRL + left",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + CTRL + right",  hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + PERIOD",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + COMMA",         hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + mouse_down",    hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + mouse_up",      hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + slash",         hl.dsp.focus({ workspace = "previous" }))

-- Special workspaces (scratchpads)
hl.bind(M .. " + minus",               hl.dsp.window.move({ workspace = "special" }))
hl.bind(M .. " + equal",               hl.dsp.workspace.toggle_special("special"))
hl.bind(M .. " + F1",                  hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(M .. " + ALT + SHIFT + F1",    hl.dsp.window.move({ workspace = "special:scratchpad", silent = true }))

-- ======= Binds Settings =======
-- https://wiki.hypr.land/Configuring/Basics/Binds/#misc

hl.config({
    binds = {
        allow_workspace_cycles            = true,
        workspace_back_and_forth          = true,
        workspace_center_on               = 1,    -- 0|1|2 integer
        movefocus_cycles_fullscreen       = true,
        window_direction_monitor_fallback = true,
    },
})
