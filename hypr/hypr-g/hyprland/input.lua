-- Input configuration
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout  = "fr",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        repeat_delay = 250,
        repeat_rate  = 35,

        numlock_by_default = true,
        follow_mouse       = 1,

        accel_profile = "flat",
        -- sensitivity    = -0.9375,
        -- force_no_accel = true,

        touchpad = {
            natural_scroll        = true,
            disable_while_typing  = true,
            clickfinger_behavior  = true,
            scroll_factor         = 0.5,
            tap_to_click          = true,
        },
    },
})

-- Touchpad gestures
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- Swipe left/right with 3 fingers to switch workspace on the current monitor.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
