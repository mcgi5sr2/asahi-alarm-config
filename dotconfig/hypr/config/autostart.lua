-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                   Autostart Configuration                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from autostart.conf for Hyprland 0.55 Lua config.
-- exec-once = ...  maps to  hl.on("hyprland.start", function() ... end)
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

local defaults = require("config.defaults")

hl.on("hyprland.start", function()
    -- Wallpaper daemon
    hl.exec_cmd("hyprpaper")

    -- Status bar
    hl.exec_cmd("waybar &")

    -- Input method
    hl.exec_cmd("fcitx5 -d &")

    -- Notification daemon
    hl.exec_cmd("mako &")

    -- Network tray applet
    hl.exec_cmd("nm-applet --indicator &")

    -- wob (overlay bar) — reads from a named pipe
    hl.exec_cmd([[bash -c "mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob & disown" &]])

    -- Polkit agent
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 &")

    -- Environment import for systemd / dbus services
    hl.exec_cmd("systemctl --user import-environment &")
    hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null &")
    hl.exec_cmd("dbus-update-activation-environment --systemd &")

    -- Idle handler (hypridle)
    hl.exec_cmd(defaults.idlehandler)

    -- Blue-light filter
    hl.exec_cmd("hyprsunset")

    -- Reload plugin manager
    hl.exec_cmd("hyprpm reload")
end)
