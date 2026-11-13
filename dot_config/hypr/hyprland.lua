-- ~/.config/hypr/hyprland.lua
-- Hyprland 0.56.x native Lua configuration
-- Base: ML4W look and feel | Shell: Noctalia | Keys: Omarchy-inspired
--
-- Loading: Hyprland adds "<dir of this file>/?.lua" and "<dir>/?/init.lua" to
-- package.path, so require("config.input") loads <dir>/config/input.lua.
-- Order matters only for colors/lib (used by later modules).

require("config.monitors")
require("config.environment")
require("config.input")
require("config.appearance")
require("config.animations")
require("config.gestures")
require("config.rules")
require("config.autostart")
require("config.keybindings")

-- Optional user overrides (not shipped): ~/.config/hypr/custom.lua
local lib = require("config.lib")
if lib.exists(lib.root .. "/custom.lua") then
    require("custom")
end

