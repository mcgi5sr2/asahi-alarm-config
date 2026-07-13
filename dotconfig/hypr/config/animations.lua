-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                   Animations Configuration                  ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
-- Converted from animations.conf for Hyprland 0.55 Lua config.
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.config({ animations = { enabled = true } })

-- Bezier curves: old  `bezier = name, x1, y1, x2, y2`
--                new  `hl.curve("name", { type="bezier", points={{x1,y1},{x2,y2}} })`
hl.curve("smooth",    { type = "bezier", points = { {0.25, 0.1},  {0.25, 1.0}  } })
hl.curve("snappy",    { type = "bezier", points = { {0.4,  0.0},  {0.2,  1.0}  } })
hl.curve("overshoot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.05} } })

-- Animations: old  `animation = leaf, enabled(0/1), speed, bezier[, style]`
--             new  `hl.animation({ leaf=..., enabled=..., speed=..., bezier=..., style=... })`
hl.animation({ leaf = "windowsIn",      enabled = true,  speed = 3, bezier = "overshoot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",     enabled = true,  speed = 2, bezier = "snappy",    style = "popin 85%" })
hl.animation({ leaf = "windowsMove",    enabled = true,  speed = 3, bezier = "smooth",    style = "slide" })
hl.animation({ leaf = "fadeIn",         enabled = true,  speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeOut",        enabled = true,  speed = 2, bezier = "smooth" })
hl.animation({ leaf = "border",         enabled = true,  speed = 4, bezier = "smooth" })
hl.animation({ leaf = "borderangle",    enabled = false, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "workspacesIn",   enabled = true,  speed = 3, bezier = "snappy",    style = "slidefade 90%" })
hl.animation({ leaf = "workspacesOut",  enabled = true,  speed = 3, bezier = "snappy",    style = "slidefade 90%" })
