-- Autostart. Noctalia replaces: bar, launcher, notifications, wallpaper,
-- lock screen, idle handling, tray host, polkit agent and clipboard history,
-- so none of waybar/swaync/hyprpaper/hyprlock/hypridle are started here.
local lib = require("config.lib")

hl.on("hyprland.start", function()
    -- Idempotent launcher (never starts a second Noctalia instance).
    hl.exec_cmd(lib.root .. "/scripts/start-noctalia.sh")

    -- Start KDE Connect daemon.
    hl.exec_cmd("/usr/bin/kdeconnectd")
end)
