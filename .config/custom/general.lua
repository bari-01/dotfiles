-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

hl.config({
    input = {
        kb_layout = "us,us",
        kb_variant = ",dvorak",
        kb_options = "grp:win_space_toggle",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 60,
        sensitivity = -0.1,
        accel_profile = "adaptive",

        follow_mouse = 1,
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 1
        }
    }
})

-- hl.monitor({
--   output = "eDP-1",
--   mode = "1920x1080@165",
--   position = "0x0",
--   scale = 1,
--   transform = 3,
-- })
