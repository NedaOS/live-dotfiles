-- Look and feel: ML4W "default" window/decoration/layout/misc variants.
-- Noctalia generates colors.lua; fresh installs work before the first palette.
local has_colors, c = pcall(require, "config.colors")
if not has_colors then
    c = { primary = "rgba(81d5ceff)", on_primary = "rgba(003734ff)" }
end

hl.config({
    general = {
        gaps_in          = 10,
        gaps_out         = 16,
        border_size      = 2,
        col = {
            active_border   = { colors = { c.primary, c.on_primary }, angle = 90 },
            inactive_border = c.on_primary,
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "scrolling",
        -- layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.6,
        fullscreen_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 32,
            render_power = 2,
            color        = "rgba(00000050)",
        },

        blur = {
            enabled           = true,
            size              = 4,
            passes            = 4,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = true,
            vibrancy          = 0.1696,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    binds = {
        workspace_back_and_forth = false,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },

    misc = {
        disable_hyprland_logo      = true,
        force_default_wallpaper    = 0,
        disable_splash_rendering   = true,
        initial_workspace_tracking = 1,
        on_focus_under_fullscreen  = 1,
        allow_session_lock_restore = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})
