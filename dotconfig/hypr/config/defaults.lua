-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                  Default Programs / Variables               ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from defaults.conf for Hyprland 0.55 Lua config.
-- Use:  local defaults = require("config.defaults")

local M = {}

M.filemanager = ""
M.applauncher = "wofi --show drun,run"
M.terminal    = "kitty"
M.idlehandler = "hypridle"
M.capturing   = [[grim -g "$(slurp)" - | swappy -f -]]

return M
