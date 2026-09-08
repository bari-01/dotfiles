-- Internal stuff --
-- require("hyprland.lib")
-- require("hyprland.services")
-- require("hyprland.env")

-----------------------
--  Library / setup  --
-----------------------

---- Helpers
HOME = os.getenv("HOME")

function is_file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then
      io.close(f)
      return true
   else
      return false
   end
end

function create_if_not_exists(path)
   if not is_file_exists(path) then
      os.execute("mkdir -p \"$(dirname \"" .. path .. "\")")
      os.execute("echo '-- This file will not be overwritten across dots-hyprland updates.\n-- The file name is for the sake of organization and does not matter\n-- See the corresponding files in ~/.config/hypr/hyprland for examples' > \"" .. path .. "\"")
      return true
   end
   return false
end

function workspace_in_group(i)
    local curr = hl.get_active_workspace().id
    local newVal = math.floor((curr - 1) / workspaceGroupSize) * workspaceGroupSize + i
    -- hl.notification.create({ text = "curr " .. curr .. " floor " .. math.floor(curr / 10) .. " new " .. newVal, duration = 5000 })
    return newVal
end

-- require("hyprland.lib")
-- require("hyprland.variables")
if is_file_exists(HOME .. "/.config/hypr/custom/variables.lua") then
    require("custom.variables")
end

---- Apps / variables
-- require("hyprland.variables")
-- Default variables

-- The folder within ~/.config/quickshell containing the config
-- hl.env("qsConfig", "ii")

-- Apps
-- PULL REQUESTS ADDING MORE WILL NOT BE ACCEPTED, CONFIG FOR YOURSELF
-- terminal = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'foot' 'kitty -1' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm'"
terminal = 'alacritty'
-- fileManager = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'dolphin' 'nautilus' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"
fileManager = 'dolphin'
-- browser = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'google-chrome-stable' 'zen-browser' 'firefox' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"
browser = 'firefox-bin'
-- codeEditor = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'windsurf' 'antigravity' 'code' 'codium' 'cursor' 'zed' 'zedit' 'zeditor' 'kate' 'gnome-text-editor' 'emacs' 'command -v nvim && kitty -1 nvim' 'command -v micro && kitty -1 micro'"
codeEditor = 'alacritty -e vim'
-- officeSoftware = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'wps' 'onlyoffice-desktopeditors' 'libreoffice'"
officeSoftware = 'onlyoffice-desktopeditors'
textEditor = 'alacritty -e vim' -- "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kate' 'gnome-text-editor' 'emacs'"
volumeMixer = 'pavucontrol-qt' -- "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol'"
-- settingsApp = "XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'qs -p ~/.config/quickshell/$qsConfig/settings.qml' 'systemsettings' 'gnome-control-center' 'better-control'"
settingsApp = 'better-control'
-- taskManager = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'gnome-system-monitor' 'plasma-systemmonitor --page-name Processes' 'command -v btop && kitty -1 fish -c btop'"
taskManager = 'alacritty -e btop'

workspaceGroupSize = 10

---------------------------
--  Environment / execs  --
---------------------------

---- Environment variables
local home_dir = os.getenv("HOME")

------ Wayland
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

------ Applications
local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" .. xdg_data_dirs_old)

------ Themes
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

---- Virtual environment
-- hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", home_dir .. "/.local/state/quickshell/.venv")

-- if is_file_exists(HOME .. "/.config/hypr/custom/env.lua") then
--    require("custom.env")
-- end

---- Startup execs
-- require("hyprland.execs")
-- put former exec-once commands inside the func and former exec commands outside
-- Custom configurations --
-- if is_file_exists(HOME .. "/.config/hypr/custom/execs.lua") then
--     require("custom.execs")
-- end
hl.on("hyprland.start", function ()

    ------ Bar, wallpaper
    -- hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")
    -- hl.exec_cmd("qs -c $qsConfig")
    -- hl.exec_cmd("$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")
    
    ------ Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("dbus-update-activation-environment --all")
    -- hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP") -- Some fix idk

    ------ Audio
    hl.exec_cmd("easyeffects --hide-window --service-mode")

    ------ Clipboard: history
   hl.exec_cmd("wl-paste --watch cliphist store")
    --hl.exec_cmd("wl-paste --type text --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'")
    --hl.exec_cmd("wl-paste --type image --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'")

    ------ Cursor
    hl.exec_cmd("hyprctl setcursor BreezeX-Black 26")
end)

------------------------
--  General settings  --
------------------------

-- require("hyprland.general")

---- Monitor
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1
})

---- Gestures
hl.gesture({
    fingers = 3,
    direction = "swipe",
    action = "move"
})
hl.gesture({
    fingers = 3,
    direction = "pinch",
    action = "fullscreen"
})
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace"
})
hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
    end
})
hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
    end
})

hl.config({
    gestures = {
        workspace_swipe_distance = 500,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true
    },
    general = {
        -- Gaps and border
        gaps_in = 4,
        gaps_out = 5,
        gaps_workspaces = 50,

        border_size = 1,

        col = {
            active_border   = "rgba(42474e77)",
            inactive_border = "rgba(181c2033)",
        },
        resize_on_border = true,

        no_focus_fallback = true,
        allow_tearing = true, -- This just allows the `immediate` window rule to work
        snap = {
            enabled = true,
            window_gap = 4,
            monitor_gap = 5,
            respect_gaps = true
        }
    },
    decoration = {
        -- 2 = circle, higher = squircle, 4 = very obvious squircle
        -- Fuck clearly visible squircles. 100% Apple brainrot.
        rounding_power = 2.5,
        rounding = 18,

        blur = {
            enabled = true,
            xray = true,
            special = false,
            new_optimizations = true,
            size = 10,
            passes = 3,
            brightness = 1,
            noise = 0.05,
            contrast = 0.89,
            vibrancy = 0.5,
            vibrancy_darkness = 0.5,
            popups = false,
            popups_ignorealpha = 0.6,
            input_methods = true,
            input_methods_ignorealpha = 0.8
        },
        shadow = {
            enabled = true,
            range = 20,
            offset = {0, 2},
            render_power = 10,
            color = "rgba(00000020)"

        },
        -- Dim
        dim_inactive = true,
        dim_strength = 0.05,
        dim_special = 0.2
    },
    animations = {
        enabled = true
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false
        -- precise_mouse_move = true,
    },
})

---- Misc / binds / cursor / xwayland
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = false,
        swallow_regex = "(foot|kitty|allacritty|Alacritty)",
        on_focus_under_fullscreen = 2,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        initial_workspace_tracking = false,
        focus_on_activate = true
    },

    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = true
    },

    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        zoom_disable_aa = true,
        hotspot_padding = 1
    },

    xwayland = {
        force_zero_scaling = true
    }
})

---- Colors
--require("hyprland.colors")
hl.config({
    misc = {
        background_color = "rgba(101418FF)",
    },
})

---- Input
-- if is_file_exists(HOME .. "/.config/hypr/custom/general.lua") then
--     require("custom.general")
-- end
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

------------------
--  Animations  --
------------------

---- Curves
hl.curve("expressiveFastSpatial", {
    type = "bezier",
    points = {{0.42, 1.67}, {0.21, 0.90}}
})
hl.curve("expressiveSlowSpatial", {
    type = "bezier",
    points = {{0.39, 1.29}, {0.35, 0.98}}
})
hl.curve("expressiveDefaultSpatial", {
    type = "bezier",
    points = {{0.38, 1.21}, {0.22, 1.00}}
})
hl.curve("emphasizedDecel", {
    type = "bezier",
    points = {{0.05, 0.7}, {0.1, 1}}
})
hl.curve("emphasizedAccel", {
    type = "bezier",
    points = {{0.3, 0}, {0.8, 0.15}}
})
hl.curve("standardDecel", {
    type = "bezier",
    points = {{0, 0}, {0, 1}}
})
hl.curve("menu_decel", {
    type = "bezier",
    points = {{0.1, 1}, {0, 1}}
})
hl.curve("menu_accel", {
    type = "bezier",
    points = {{0.52, 0.03}, {0.72, 0.08}}
})
hl.curve("stall", {
    type = "bezier",
    points = {{1, -0.1}, {0.7, 0.85}}
})

-- Configs
---- Window animations
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 3,
    bezier = "emphasizedDecel",
    style = "popin 80%"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 3,
    bezier = "emphasizedDecel"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2,
    bezier = "emphasizedDecel",
    style = "popin 90%"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 2,
    bezier = "emphasizedDecel"
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 3,
    bezier = "emphasizedDecel",
    style = "slide"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 10,
    bezier = "emphasizedDecel"
})

------ Layers
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 2.7,
    bezier = "emphasizedDecel",
    style = "popin 93%"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 2.4,
    bezier = "menu_accel",
    style = "popin 94%"
})
------ Fade
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 0.5,
    bezier = "menu_decel"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2.7,
    bezier = "stall"
})
------ Workspaces
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 7,
    bezier = "menu_decel",
    style = "slide"
})
------ specialWorkspace
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 2.8,
    bezier = "emphasizedDecel",
    style = "slidevert"
})
hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 1.2,
    bezier = "emphasizedAccel",
    style = "slidevert"
})
------ zoom
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 3,
    bezier = "standardDecel"
})

--------------------
--  Window rules  --
--------------------

--require("hyprland.rules")

---- Disable blur for xwayland context menus
hl.window_rule({match = {class = "^()$", title = "^()$" },                   no_blur = true })

-- Disable blur for every window
hl.window_rule({match = {class = ".*" }, no_blur = true })

---- Floating
hl.window_rule({match = {title = "^(Open File)(.*)$" },                      center = true})
hl.window_rule({match = {title = "^(Open File)(.*)$" },                      float = true})
hl.window_rule({match = {title = "^(Select a File)(.*)$" },                  center = true})
hl.window_rule({match = {title = "^(Select a File)(.*)$" },                  float = true})
hl.window_rule({match = {title = "^(Select what to share)(.*)$" },           center = true})
hl.window_rule({match = {title = "^(Select what to share)(.*)$" },           float = true})
hl.window_rule({match = {title = "^(Choose wallpaper)(.*)$" },               center = true})
hl.window_rule({match = {title = "^(Choose wallpaper)(.*)$" },               float = true})
hl.window_rule({match = {title = "^(Choose wallpaper)(.*)$" },               size = {"(monitor_w*0.60)", "(monitor_h*0.65)"} })
hl.window_rule({match = {title = "^(Open Folder)(.*)$" },                    center = true})
hl.window_rule({match = {title = "^(Open Folder)(.*)$" },                    float = true})
hl.window_rule({match = {title = "^(Save As)(.*)$" },                        center = true})
hl.window_rule({match = {title = "^(Save As)(.*)$" },                        float = true})
hl.window_rule({match = {title = "^(Library)(.*)$" },                        center = true})
hl.window_rule({match = {title = "^(Library)(.*)$" },                        float = true})
hl.window_rule({match = {title = "^(File Upload)(.*)$" },                    center = true})
hl.window_rule({match = {title = "^(File Upload)(.*)$" },                    float = true})
hl.window_rule({match = {title = "^(.*)(wants to save)$" },                  center = true})
hl.window_rule({match = {title = "^(.*)(wants to save)$" },                  float = true})
hl.window_rule({match = {title = "^(.*)(wants to open)$" },                  center = true})
hl.window_rule({match = {title = "^(.*)(wants to open)$" },                  float = true})
hl.window_rule({match = {class = "^(blueberry\\.py)$" },                     float = true})
hl.window_rule({match = {class = "^(guifetch)$" },                           float = true}) -- FlafyDev/guifetch
hl.window_rule({match = {class = "^(pavucontrol)$" },                        float = true})
hl.window_rule({match = {class = "^(pavucontrol)$" },                        size = {"(monitor_w*0.45)", "(monitor_h*0.45)"} })
hl.window_rule({match = {class = "^(pavucontrol)$" },                        center = true})
hl.window_rule({match = {class = "^(org.pulseaudio.pavucontrol)$" },         float = true})
hl.window_rule({match = {class = "^(org.pulseaudio.pavucontrol)$" },         size = {"(monitor_w*0.45)", "(monitor_h*0.45)"} })
hl.window_rule({match = {class = "^(org.pulseaudio.pavucontrol)$" },         center = true})
hl.window_rule({match = {class = "^(nm-connection-editor)$" },               float = true})
hl.window_rule({match = {class = "^(nm-connection-editor)$" },               size = {"(monitor_w*0.45)", "(monitor_h*0.45)"} })
hl.window_rule({match = {class = "^(nm-connection-editor)$" },               center = true})
hl.window_rule({match = {class = ".*plasmawindowed.*" },                     float = true})
hl.window_rule({match = {class = "kcm_.*" },                                  float = true})
hl.window_rule({match = {class = ".*bluedevilwizard" },                      float = true})
hl.window_rule({match = {title = ".*Welcome" },                              float = true})
hl.window_rule({match = {title = "^(illogical-impulse Settings)$" },         float = true})
hl.window_rule({match = {title = ".*Shell conflicts.*" },                    float = true})
hl.window_rule({match = {class = "org.freedesktop.impl.portal.desktop.kde" }, float = true})
hl.window_rule({match = {class = "org.freedesktop.impl.portal.desktop.kde" }, size = {"(monitor_w*0.60)", "(monitor_h*0.65)"} })
hl.window_rule({match = {class = "^(Zotero)$" },                             float = true})
hl.window_rule({match = {class = "^(Zotero)$" },                             size = {"(monitor_w*0.45)", "(monitor_h*0.45)"} })

hl.window_rule({match = {title = "^(Copying)(.*)(Dolphin)$" },               float = true})
hl.window_rule({match = {title = "^(Copying)(.*)(Dolphin)$" },               center = true})
hl.window_rule({match = {class = "^(pavucontrol-qt)$" },                        float = true})
hl.window_rule({match = {class = "^(pavucontrol-qt)$" },                        size = {"(monitor_w*0.45)", "(monitor_h*0.45)"} })
hl.window_rule({match = {class = "^(pavucontrol-qt)$" },                        center = true})


---- Move
------ kde-material-you-colors spawns a window when changing dark/light theme. This is to make sure it doesn't interfere at all.
hl.window_rule({match = {class = "^(plasma-changeicons)$" }, float = true})
hl.window_rule({match = {class = "^(plasma-changeicons)$" }, no_initial_focus = true})
hl.window_rule({match = {class = "^(plasma-changeicons)$" }, move = {999999, 999999}})
------ Stupid dolphin copy
hl.window_rule({match = {title = "^(Copying — Dolphin)$" }, move = {40, 80}})

---- Tiling
hl.window_rule({match = {class = "^dev\\.warp\\.Warp$" }, tile = true})

------ Picture-in-Picture
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true})
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, keep_aspect_ratio = true})
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, move = {"(monitor_w*0.73)", "(monitor_h*0.72)"} })
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, size = {"(monitor_w*0.25)", "(monitor_h*0.25)"} })
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true})
hl.window_rule({match = {title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true})

------ Screen sharing
hl.window_rule({match = {title = ".*is sharing (a window|your screen).*" }, float = true})
hl.window_rule({match = {title = ".*is sharing (a window|your screen).*" }, pin = true})
hl.window_rule({match = {title = ".*is sharing (a window|your screen).*" }, move = {"(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)"} })

---- Tearing
hl.window_rule({match = {title = ".*\\.exe" }, immediate = true})
hl.window_rule({match = {title = ".*minecraft.*" }, immediate = true})
hl.window_rule({match = {class = "^(steam_app).*" }, immediate = true})

---- No shadow for tiled windows
hl.window_rule({match = {float = 0 }, no_shadow = true})

---- Pinned window border
hl.window_rule({
    match        = { pin = 1 },
    border_color = "rgba(9bcbfbAA) rgba(9bcbfb77)",
})

-----------------------
--  Workspace rules  --
-----------------------

hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

-------------------
--  Layer rules  --
-------------------

hl.layer_rule({ match = { namespace = ".*" }, xray = true})
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true})
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true})
hl.layer_rule({ match = { namespace = "overview" }, no_anim = true})
hl.layer_rule({ match = { namespace = "anyrun" }, no_anim = true})
hl.layer_rule({ match = { namespace = "indicator.*" }, no_anim = true})
hl.layer_rule({ match = { namespace = "osk" }, no_anim = true})
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true})

hl.layer_rule({ match = { namespace = "noanim" }, no_anim = true})
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true})
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0})
hl.layer_rule({ match = { namespace = "launcher" }, blur = true})
hl.layer_rule({ match = { namespace = "launcher" }, ignore_alpha = 0.5})
hl.layer_rule({ match = { namespace = "notifications" }, blur = true})
hl.layer_rule({ match = { namespace = "notifications" }, ignore_alpha = 0.69})
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true}) -- wlogout

---- AGS
hl.layer_rule({ match = { namespace = "sideleft.*" }, animation = "slide left"})
hl.layer_rule({ match = { namespace = "sideright.*" }, animation = "slide right"})
hl.layer_rule({ match = { namespace = "session[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "bar[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "bar[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "barcorner.*" }, blur = true})
hl.layer_rule({ match = { namespace = "barcorner.*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "dock[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "dock[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "indicator.*" }, blur = true})
hl.layer_rule({ match = { namespace = "indicator.*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "overview[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "overview[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "cheatsheet[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "cheatsheet[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "sideright[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "sideright[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "sideleft[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "sideleft[0-9]*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "indicator.*" }, blur = true})
hl.layer_rule({ match = { namespace = "indicator.*" }, ignore_alpha = 0.6})
hl.layer_rule({ match = { namespace = "osk[0-9]*" }, blur = true})
hl.layer_rule({ match = { namespace = "osk[0-9]*" }, ignore_alpha = 0.6})

---- Quickshell
------ Quickshell: illogical-impulse (to be refactored)
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur_popups = true})
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true})
hl.layer_rule({ match = { namespace = "quickshell:.*" }, ignore_alpha = 0.79})
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide"})
hl.layer_rule({ match = { namespace = "quickshell:actionCenter" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:cheatsheet" }, animation = "slide bottom"})
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom"})
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%"})
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade"})
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, ignore_alpha = 1})
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom"})
hl.layer_rule({ match = { namespace = "quickshell:polkit" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:popup" }, xray = false}) -- No weird color for bar tooltips (this in theory should suffice)
hl.layer_rule({ match = { namespace = "quickshell:popup" }, ignore_alpha = 1}) -- No weird color for bar tooltips (but somehow this is necessary)
hl.layer_rule({ match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1}) -- Same as above
hl.layer_rule({ match = { namespace = "quickshell:reloadPopup" }, animation = "slide"})
hl.layer_rule({ match = { namespace = "quickshell:regionSelector" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true})
hl.layer_rule({ match = { namespace = "quickshell:session" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:session" }, ignore_alpha = 0})
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right"})
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left"})
hl.layer_rule({ match = { namespace = "quickshell:verticalBar" }, animation = "slide"})
hl.layer_rule({ match = { namespace = "quickshell:osk" }, order = -1})
------ Quickshell: waffles
hl.layer_rule({ match = { namespace = "quickshell:wallpaperSelector" }, animation = "slide top"})
hl.layer_rule({ match = { namespace = "quickshell:wNotificationCenter" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:wOnScreenDisplay" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:wStartMenu" }, no_anim = true})
hl.layer_rule({ match = { namespace = "quickshell:wTaskView" }, ignore_alpha = 0})
hl.layer_rule({ match = { namespace = "quickshell:wTaskView" }, no_anim = true})

---- Launchers need to be FAST
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true})

----------------
--  Keybinds  --
----------------

--require("hyprland.keybinds")

local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

---- Shell
hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"), { description = "Shell: Toggle search" })
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))
hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))

hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"),
    { ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"),
    { ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { description = "Shell: Toggle overview" })
-- hl.bind("SUPER + V", hl.dsp.global("quickshell:overviewClipboardToggle"))
hl.bind("SUPER + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))
-- hl.bind("SUPER + A", hl.dsp.global("quickshell:sidebarLeftToggle"), { description = "Shell: Toggle left sidebar" })
hl.bind("SUPER + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
-- hl.bind("SUPER + B", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind("SUPER + O", hl.dsp.global("quickshell:sidebarLeftToggle"))
hl.bind("SUPER + N", hl.dsp.global("quickshell:sidebarRightToggle"), { description = "Shell: Toggle right sidebar" })
hl.bind("SUPER + Slash", hl.dsp.global("quickshell:cheatsheetToggle"), { description = "Shell: Toggle cheatsheet" })
hl.bind("SUPER + Up", hl.dsp.global("quickshell:oskToggle"), { description = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + M", hl.dsp.global("quickshell:mediaControlsToggle"), { description = "Shell: Toggle media controls" })
--hl.bind("SUPER + ALT + G", hl.dsp.global("quickshell:overlayToggle"), { description = "Shell: Toggle widget overlay" })
hl.bind("CTRL + ALT + Delete", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Toggle session menu" })
hl.bind("SUPER + Down", hl.dsp.global("quickshell:barToggle"), { description = "Shell: Toggle bar" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"))
hl.bind("SHIFT + SUPER + ALT + Slash", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"))

hl.bind("CTRL + SUPER + T", hl.dsp.global("quickshell:wallpaperSelectorToggle"),
    { description = "Shell: Change wallpaper" })
hl.bind("CTRL + SUPER + ALT + T", hl.dsp.global("quickshell:wallpaperSelectorRandom"),
    { description = "Shell: Random wallpaper" })
hl.bind("CTRL + SUPER + SHIFT + D", hl.dsp.global("quickshell:toggleLightDark"),
    { description = "Shell: Toggle light/dark mode" })
hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/colors/switchwall.sh"))
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("killall ydotool qs quickshell; qs -c $qsConfig &"),
    { description = "Shell: Restart widgets" })
hl.bind("CTRL + SUPER + P", hl.dsp.global("quickshell:panelFamilyCycle"), { description = "Shell: Cycle panel family" })

--##! Utilities
--# Screenshot, Record, OCR, Color picker, Clipboard history
hl.bind("SUPER + C", hl.dsp.exec_cmd(
        qsIsAlive .. " || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"),
    { description = "Utilities: Clipboard history >> clipboard" })
hl.bind("SUPER + Period", hl.dsp.exec_cmd(
        qsIsAlive .. " || pkill fuzzel || " .. hyprScripts .. "/fuzzel-emoji.sh copy"),
    { description = "Utilities: Emoji >> clipboard" })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"), { description = "Utilities: Screen snip" })
hl.bind("SUPER + SHIFT + S",
    hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"))
hl.bind("SUPER + SHIFT + A", hl.dsp.global("quickshell:regionSearch"), { description = "Utilities: Google Lens" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || " .. hyprScripts .. "/snip_to_search.sh"))
--# OCR
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:regionOcr"),
    { description = "Utilities: Character recognition >> clipboard" })
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:screenTranslate"),
    { description = "Utilities: Translate screen content" })
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd(
    qsIsAlive ..
    " || pidof slurp || grim -g \"$(slurp $SLURP_ARGS)\" \"/tmp/ocr_image.png\" && tesseract \"/tmp/ocr_image.png\" stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/') | wl-copy && rm \"/tmp/ocr_image.png\""
))
--# Color picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"),
    { description = "Utilities: Pick color #RRGGBB >> clipboard" })
--# Recording stuff
hl.bind("SUPER + SHIFT + R", hl.dsp.global("quickshell:regionRecord"),
    { locked = true, description = "Utilities: Record region (no sound)" })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })
hl.bind("SUPER + ALT + R", hl.dsp.global("quickshell:regionRecord"), { locked = true })
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen --sound"),
    { locked = true, description = "Utilities: Record screen (with sound)" })
--# Fullscreen screenshot
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"),
    { locked = true, description = "Utilities: Screenshot >> clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    "mkdir -p $(xdg-user-dir PICTURES)/Screenshots && " ..
    grimhyprctl .. " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"
), { locked = true, non_consuming = true, description = "Utilities: Screenshot >> clipboard & file" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"), { locked = true, non_consuming = true })
--# AI
hl.bind("SUPER + SHIFT + ALT + mouse:273", hl.dsp.exec_cmd(hyprScripts .. "/ai/primary-buffer-query.sh"),
    { description = "Utilities: Generate AI summary for selected text" })
-- (requires a running ollama model)

---- Screen
------ Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind("SUPER + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Screen: Zoom out" })
hl.bind("SUPER + Equal", function() zoomfunction(0.3) end, { repeating = true, description = "Screen: Zoom in" })

------ Zoom with keypad
hl.bind("SUPER + code:82", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind("SUPER + code:86", function() zoomfunction(0.3) end, { repeating = true })

---- Brightness / Volume
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
--     { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
--     { locked = true, repeating = true })
-- hl.bind("SUPER + F1", hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
--     { locked = true, repeating = true })
-- hl.bind("SUPER + F2", hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
--     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("xbacklight -inc 5"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("xbacklight -dec 5"),
    { locked = true, repeating = true })
hl.bind("SUPER + F1", hl.dsp.exec_cmd("xbacklight -inc 5"),
    { locked = true, repeating = true })
hl.bind("SUPER + F2", hl.dsp.exec_cmd("xbacklight -dec 5"),
    { locked = true, repeating = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
    { locked = true, repeating = true })

---- Media
local mediaNextCommand =
"playerctl next || playerctl position `bc <<< \"100 * $(playerctl metadata mpris:length) / 1000000 / 100\"`"
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(mediaNextCommand), { locked = true, description = "Media: Next track" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(mediaNextCommand), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + mouse:275", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + ALT + mouse:276", hl.dsp.exec_cmd(mediaNextCommand))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"),
    { locked = true, description = "Media: Previous track" })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true, description = "Media: Play/pause media" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"),
    { locked = true, description = "Media: Toggle mute" })
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"),
    { locked = true, description = "Media: Toggle mic" })

---- Session
hl.bind("SUPER + Right", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Session: Lock" })
hl.bind("SUPER + SHIFT + Right", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"),
    { locked = true, description = "Session: Sleep" }) -- Sleep
-- hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), {locked = true} ) -- # [hidden] Suspend when laptop lid is closed, uncomment if for whatever reason it's not the default behavior

hl.bind("CTRL + SHIFT + ALT + SUPER + Delete", hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"),
    { description = "Session: Shut down" }) -- # [hidden] Power off


---- Apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), { description = "App: Terminal" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager), { description = "App: File manager" })
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser), { description = "App: Browser" })
-- hl.bind("SUPER + C", hl.dsp.exec_cmd(codeEditor), { description = "App: Code editor" })
hl.bind("CTRL + SUPER + SHIFT + ALT + W", hl.dsp.exec_cmd(officeSoftware), { description = "App: Office software" })
hl.bind("SUPER + X", hl.dsp.exec_cmd(textEditor), { description = "App: Text editor" })
hl.bind("CTRL + SUPER + V", hl.dsp.exec_cmd(volumeMixer), { description = "App: Volume mixer" })
hl.bind("SUPER + I", hl.dsp.exec_cmd(settingsApp), { description = "App: Settings app" })
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(taskManager), { description = "App: Task manager" })

---- Testing
hl.bind("SUPER + ALT + F11",
    hl.dsp.exec_cmd(
        "bash -c 'RANDOM_IMAGE=$(find ~/Pictures -type f | shuf -n 1); ACTION=$(notify-send \"Test notification with body image\" \"This notification should contain your user account <b>image</b> and <a href=\\\"https://discord.com/app\\\">Discord</a> <b>icon</b>. Oh and here is a random image in your Pictures folder: <img src=\\\"$RANDOM_IMAGE\\\" alt=\\\"Testing image\\\"/>\" -a \"Hyprland\" -p -h \"string:image-path:/var/lib/AccountsService/icons/$USER\" -t 6000 -i \"discord\" -A \"openImage=Profile image\" -A \"action2=Open the random image\" -A \"action3=Useless button\"); [[ $ACTION == *openImage ]] && xdg-open \"/var/lib/AccountsService/icons/$USER\"; [[ $ACTION == *action2 ]] && xdg-open \"$RANDOM_IMAGE\"'")
) -- # [hidden]
hl.bind("SUPER + ALT + F12",
    hl.dsp.exec_cmd(
        "bash -c 'RANDOM_IMAGE=$(find ~/Pictures -type f | shuf -n 1); ACTION=$(notify-send \"Test notification\" \"This notification should contain a random image in your <b>Pictures</b> folder and <a href=\\\"https://discord.com/app\\\">Discord</a> <b>icon</b>.\\n<i>Flick right to dismiss!</i>\" -a \"Discord (fake)\" -p -h \"string:image-path:$RANDOM_IMAGE\" -t 6000 -i \"discord\" -A \"openImage=Profile image\" -A \"action2=Useless button\"); [[ $ACTION == *openImage ]] && xdg-open \"/var/lib/AccountsService/icons/$USER\"'")
)                                                                                                        -- # [hidden]
hl.bind("SUPER + ALT + Equal",
    hl.dsp.exec_cmd("notify-send 'Urgent notification' 'Ah hell no' -u critical -a 'Hyprland keybind'")) -- # [hidden]



---------------
--  Plugins  --
---------------
hl.permission("/usr/lib/hyprland-plugins/", "plugin", "allow")
---- hy3
hl.plugin.load("/usr/lib/hyprland-plugins/libhy3.so")

hl.config({
    general = {
        layout = "hy3",
    },
})

--hl.set("general:layout", "hy3")

--hl.config("plugin:hy3", {
--    no_gaps_when_only = 1,
--    autotile = {
--        enable = true,
--        trigger_width = 800,
--        trigger_height = 500,
--    }
--})
--------------
--  Window  --
--------------
----- (was under keybinds but makes more sense here after hy3)
---- config
local hy3 = hl.plugin.hy3

---- Window Groups
hl.bind("SUPER + B", hy3.make_group("h"))
hl.bind("SUPER + V", hy3.make_group("v"))
hl.bind("SUPER + G", hy3.make_group("tab", { toggle = true, }))
hl.bind("SUPER + Tab", hy3.focus_tab({
    direction = "r",
    wrap = true,
}))

hl.bind("SUPER + SHIFT + Tab", hy3.focus_tab({
    direction = "l",
    wrap = true,
}))

--hl.bind("SUPER + SHIFT + G", hy3.change_group("untab"))
hl.bind("SUPER + CTRL + G", hy3.change_group("toggletab"))

---- Focusing
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })
---- #/# bind = SUPER + ←/↑/→/↓,, -- Focus in direction
--for i = 1, 4 do
--    local arrowkey = { "h", "l", "k", "j" }
--    local focusdir = { "l", "r", "u", "d" }
--    hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }),
--        { description = "Window: Focus " .. arrowkey[i] })
--end
hl.bind("SUPER + h", hy3.move_focus("l", { visible = true }))
hl.bind("SUPER + BracketLeft", hy3.move_focus("l", { visible = true }))
hl.bind("SUPER + j", hy3.move_focus("d", { visible = true }))
hl.bind("SUPER + k", hy3.move_focus("u", { visible = true }))
hl.bind("SUPER + l", hy3.move_focus("r", { visible = true }))
hl.bind("SUPER + BracketRight", hy3.move_focus("r", { visible = true }))
--for i = 1, 2 do
--    local arrowkey = { "BracketLeft", "BracketRight" }
--    local focusdir = { "l", "r" }
--    hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }))
--end
---- #/# bind = SUPER + SHIFT, ←/↑/→/↓,, -- Move in direction
--for i = 1, 4 do
--    local arrowkey = { "h", "l", "k", "j" }
--    local focusdir = { "l", "r", "u", "d" }
--    hl.bind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ direction = focusdir[i] }),
--        { description = "Window: Move " .. arrowkey[i] })
--end
hl.bind("SUPER + SHIFT + h", hy3.move_window("l", { visible = true }))
hl.bind("SUPER + SHIFT + BracketLeft", hy3.move_window("l", { visible = true }))
hl.bind("SUPER + SHIFT + j", hy3.move_window("d", { visible = true }))
hl.bind("SUPER + SHIFT + k", hy3.move_window("u", { visible = true }))
hl.bind("SUPER + SHIFT + l", hy3.move_window("r", { visible = true }))
hl.bind("SUPER + SHIFT + BracketRight", hy3.move_window("r", { visible = true }))

hl.bind("ALT + F4",
    function()
        hl.exec_cmd(
            "notify-send \"Wrong close keybind\" \"Super+Q to close. Use Alt+F4 for Windows VMs\" -a Hyprland")
    end,
    { non_consuming = true })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"), { description = "Window: Forcefully zap a window" })

------ Window split ratio

---- #/# binde = SUPER, ;/',, -- Adjust split ratio
----- (resize doesn't work with hy3)
hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })
--# Positioning mode
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float/Tile" })
hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
    { description = "Window: Maximize" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    { description = "Window: Fullscreen" })
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3, action = "toggle" }),
    { description = "Window: Fullscreen spoof" })
hl.bind("SUPER + P", hl.dsp.window.pin(), { description = "Window: Pin" })

---- #/# bind = SUPER+ALT, Hash,, -- Send to workspace -- (1, 2, 3,...)
for i = 1, 10 do
    hl.bind("SUPER + ALT + " .. (i % 10), function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = false }))
    end, { description = "Window: Send to workspace " .. i })
end
--# We also use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
-- for i = 1, 10 do
--     local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
--     hl.bind("SUPER + ALT + code:" .. numberkey[i], function()
--         hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = false }))
--     end)
-- end
----  Keypad numbers
for i = 1, 10 do
    local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
    hl.bind("SUPER + ALT + code:" .. numpadkey[i], function()
        hl.dispatch(hl.dsp.window.move({ workspace = workspace_in_group(i), follow = false }))
    end)
end

---- #/# bind = SUPER+SHIFT, Scroll ↑/↓,, -- Send to workspace left/right
for i = 1, 4 do
    local key = { "SUPER + SHIFT + mouse_", "SUPER + ALT + mouse_" }
    local keycombos = { key[1] .. "down", key[1] .. "up", key[2] .. "down", key[2] .. "up" }
    local prefix = { "r-", "r+", "r-", "r+" }
    hl.bind(keycombos[i], hl.dsp.window.move({ workspace = prefix[i] .. "1" }))
end

---- #/# bind = SUPER+SHIFT, Page_↑/↓,, -- Send to workspace left/right
for i = 1, 2 do
    local keydirs = { "Up", "Down" }
    local prefix = { "r-", "r+" }
    local descdir = { "left", "right" }
    hl.bind("SUPER + SHIFT + Page_" .. keydirs[i], hl.dsp.window.move({ workspace = prefix[i] .. "1" }), {description = "Window: Send to workspace " .. descdir[i]})
end
for i = 1, 4 do
    local key = { "SUPER + ALT + Page_", "CTRL + SUPER + SHIFT + " }
    local keycombos = { key[1] .. "down", key[1] .. "up", key[2] .. "Right", key[2] .. "Left" }
    local prefix = { "r+", "r-", "r+", "r-" }
    hl.bind(keycombos[i], hl.dsp.window.move({ workspace = prefix[i] .. "1" })) -- # [hidden]
end

hl.bind("SUPER + ALT + S",
    hl.dsp.window.move({ workspace = "special:special", follow = false }), { description = "Window: Send to scratchpad" })
hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special("special"))

---- Cursed stuff
------ Make window not amogus large
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.resize({ x = 640, y = 480, "exact" }))

----- Dwindle (removed)
--hl.bind("SUPER + A", hl.dsp.layout("togglesplit"))

------------------
--  Workspaces  --
------------------

---- Switching
---- #/# bind = SUPER, Hash,, -- Focus workspace -- (1, 2, 3,...)
for i = 1, 10 do
    hl.bind("SUPER + " .. (i % 10), function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i) }))
    end, { description = "Workspace: Focus " .. i })
end
---- We also use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
for i = 1, 10 do
    local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
    hl.bind("SUPER + code:" .. numberkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i) }))
    end)
end
---- Keypad numbers
for i = 1, 10 do
    local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
    hl.bind("SUPER + code:" .. numpadkey[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = workspace_in_group(i) }))
    end)
end

-- #/# bind = CTRL+SUPER, ←/→,, -- Focus left/right
---- #/# bind = CTRL+SUPER+ALT, ←/→,, -- # [hidden] Focus busy left/right
for i = 1, 2 do
    local keys = { "h", "l" }
    local prefix = { "r-", "r+" }
    local descdir = { "left", "right" }
    hl.bind("CTRL + SUPER + " .. keys[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }), {description = "Workspace: Focus " .. descdir[i]})
end
for i = 1, 2 do
    local keys = { "Left", "Right" }
    local prefix = { "m-", "m+" }
    hl.bind("CTRL + SUPER + ALT + " .. keys[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }))
end
---- #/# bind = SUPER, Page_↑/↓,, -- Focus left/right
for i = 1, 4 do
    local key = { "SUPER + Page_Down", "SUPER + Page_Up" }
    local keycombos = { key[1], key[2], "CTRL + " .. key[1], "CTRL + " .. key[2] }
    local prefix = { "r+", "r-", "r+", "r-" }
    hl.bind(keycombos[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }))
end
---- #/# bind = SUPER, Scroll ↑/↓,, -- Focus left/right
for i = 1, 4 do
    local key = { "SUPER + mouse_up", "SUPER + mouse_down" }
    local keycombos = { key[1], key[2], "CTRL + " .. key[1], "CTRL + " .. key[2] }
    local prefix = { "+", "-", "r+", "r-" }
    hl.bind(keycombos[i], hl.dsp.focus({ workspace = prefix[i] .. "1" }))
end
---- Special
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })
hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special("special"))
for i = 1, 4 do
    local key = { "BracketLeft", "BracketRight", "Up", "Down" }
    local prefix = { "-1", "+1", "r-5", "r+5" }
    hl.bind("CTRL + SUPER + " .. key[i], hl.dsp.focus({ workspace = prefix[i] }))
end

---- Virtual machines
hl.define_submap("virtual-machine", function()
    hl.bind("SUPER + ALT + F1", function()
        local currentsubmap = hl.get_current_submap()
        if currentsubmap == "virtual-machine" then
            hl.dispatch(hl.dsp.exec_cmd(
                "notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'"))
            hl.dispatch(hl.dsp.submap("reset"))
        elseif currentsubmap == "" then
            hl.dispatch(hl.dsp.exec_cmd(
                "notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. hit SUPER+ALT+F1 to escape' -a 'Hyprland'"))
            hl.dispatch(hl.dsp.submap("virtual-machine"))
        end
    end, { submap_universal = true })
end)

-- if is_file_exists(HOME .. "/.config/hypr/custom/rules.lua") then
--     require("custom.rules")
-- end
-- if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
--     require("custom.keybinds")
-- end
-- require("hyprland.lib")

-- nwg-displays support --
-- if is_file_exists(HOME .. "/.config/hypr/workspaces.lua") then
--     require("workspaces")
-- end
-- if is_file_exists(HOME .. "/.config/hypr/monitors.lua") then
--     require("monitors")
-- end

-- Shell overrides --
-- require("hyprland.shellOverrides.main")

------------------------
--  Autofolding hint  --
------------------------

-- Add this to vim to autofold this config:
-- 
-- """ defines a foldlevel for each line of code
-- function! LuaFolds(lnum)
--     let s:thisline = getline(a:lnum)
--     if match(s:thisline, '^---- ') >= 0
--         return '>2'
--     endif
--     if match(s:thisline, '^------ ') >= 0
--         return '>3'
--     endif
--     let s:two_following_lines = 0
--     if line(a:lnum) + 2 <= line('$')
--         let s:line_1_after = getline(a:lnum+1)
--         let s:line_2_after = getline(a:lnum+2)
--         let s:two_following_lines = 1
--     endif
--     if !s:two_following_lines
--         return '='
--     endif
--     else
--       if match(s:thisline, '^--------\+$') >= 0 &&
--          \ match(s:line_1_after, '^--.\ +--\s*$') >= 0 &&
--          \ match(s:line_2_after, '^--------\+$') >= 0
--         return '>1'
--       else
--         return '='
--     endif
--   endif
-- endfunction
-- 
-- """ defines a foldtext
-- function! LuaFoldText()
--     let s:info = '('.(v:foldend-v:foldstart).' l)'
-- 
--     if v:foldlevel == 1
--         let s:line = ' ◇ '..getline(v:foldstart+1)[3:-3]
--     elseif v:foldlevel == 2
--         let s:line = '   ● '.getline(v:foldstart)[5:]
--     elseif v:foldlevel == 3
--         let s:line = '     ▪ '.getline(v:foldstart)[7:]
--     endif
--     if strwidth(s:line) > 80 - len(s:info) - 3
--         return s:line[:79-len(s:info)-3+len(s:line)-strwidth(s:line)].'...'.s:info
--     else
--         return s:line.repeat(' ', 80-strwidth(s:line)-len(s:info)).s:info
--     endif
-- endfunction
-- 
-- """ set foldsettings automatically for lua files
-- augroup fold_lua
--     autocmd!
--     autocmd FileType lua
--                 \ setlocal foldmethod=expr |
--                 \ setlocal foldexpr=LuaFolds(v:lnum) |
--                 \ setlocal foldtext=LuaFoldText() |
--                 \ setlocal foldlevel=0
-- augroup END
