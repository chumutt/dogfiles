-- Hyprland config (Lua), ported from a dwm/LARBS keymap.
-- Workspaces 1-9 stand in for dwm tags. Verify: hyprctl configerrors

local M = "SUPER"

local function sh(cmd)  return hl.dsp.exec_cmd(cmd) end
local function term(cmd) return hl.dsp.exec_cmd("foot " .. cmd) end

-- split-monitor-workspaces: per-monitor 1-9 blocks. Loaded before monitors so they map on startup.
package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. os.getenv("HOME") .. "/.config/hypr/?/init.lua;" .. package.path
smw = require("smw")
smw.setup({
    workspace_count = 9,
    keep_focused = true,
    enable_persistent_workspaces = true,
    link_monitors = false,
    enable_wrapping = true,
})

------------------
---- MONITORS ----
------------------
-- Ported from ~/.screenlayout/default.sh. Hyprland (Wayland) output names differ from xrandr:
--   HDMI-0 -> HDMI-A-1 (AOC 24B2W1), DP-2 -> DP-2 (AOC G2460), DP-4 -> DP-3 (Sceptre O34 3440x1440),
--   HDMI-1 -> HDMI-A-2 (HAT Kamvas 13, drawing tablet display)
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0",     scale = 1 })
hl.monitor({ output = "DP-2",     mode = "preferred", position = "1920x0",  scale = 1 })
hl.monitor({ output = "DP-3",     mode = "preferred", position = "0x1080",  scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "683x2520", scale = 1 })

-----------------------
---- WORKSPACES ----
-----------------------

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    sh("sh -c 'pidof -s mpd || mpd'")
    -- dwm scratchpads (spterm / spcalc), started hidden on their special workspaces
    term("-a spterm -W 120x34")
    term("-a spcalc -f monospace:size=16 -W 50x20 -e bc -lq")
end)

---------------------
---- ENVIRONMENT ----
---------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Mirrors dwm: borderpx 3, selected border #770000, normal border #444444,
-- gaps inner h20/v10 outer h10/v30, square corners, no animation, no blur.
hl.config({
    general = {
        gaps_in  = { top = 2, right = 4, bottom = 2, left = 4 },
        gaps_out = { top = 4, right = 4, bottom = 4, left = 4 },
        border_size = 3,
        col = {
            active_border   = "rgba(51afefff)",
            inactive_border = "rgba(3f444aff)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },
    animations = { enabled = false },
    master = {
        mfact = 0.55,          -- dwm mfact
        new_status = "master", -- dwm attaches new clients as master
        new_on_top = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = -0.7,
    },
})

-------------------------
---- WINDOW RULES ----
-------------------------

-- Scratchpads: float, centered, parked on their special workspaces.
hl.window_rule({ name = "spterm", match = { class = "^spterm$" },
    float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.6" },
    workspace = "special:spterm silent" })
hl.window_rule({ name = "spcalc", match = { class = "^spcalc$" },
    float = true, center = true, size = { "monitor_w*0.4", "monitor_h*0.4" },
    workspace = "special:spcalc silent" })

-- Fix XWayland drag issues (kept from the stock config)
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Suppress app maximize requests (dwm does not maximize windows)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

------------------
---- KEYBINDS ----
------------------

-- Launch / windows
hl.bind(M .. " + Return", term(""))
hl.bind(M .. " + SHIFT + Return", hl.dsp.workspace.toggle_special("spterm"))
hl.bind(M .. " + apostrophe", hl.dsp.workspace.toggle_special("spcalc"))
hl.bind(M .. " + D", sh("fuzzel"))                  -- dmenu_run -> fuzzel
hl.bind(M .. " + SHIFT + D", sh("passmenu"))
hl.bind(M .. " + Q", hl.dsp.window.close())         -- killclient
hl.bind(M .. " + SHIFT + Q", sh("hyprsysact"))
hl.bind(M .. " + BackSpace", sh("hyprsysact"))
hl.bind(M .. " + SHIFT + BackSpace", sh("hyprsysact"))
hl.bind(M .. " + W", sh("firefox"))
hl.bind(M .. " + SHIFT + W", term("-e sudo nmtui"))
hl.bind(M .. " + E", term("ez"))
hl.bind(M .. " + SHIFT + E", term("-e neomutt"))
hl.bind(M .. " + SHIFT + CTRL + E", term("-e abook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook"))
hl.bind(M .. " + R", term("-e lfub"))
hl.bind(M .. " + SHIFT + R", term("-e htop"))
hl.bind(M .. " + C", term("-e profanity"))
hl.bind(M .. " + N", term("-e nvim -c VimwikiIndex"))
hl.bind(M .. " + SHIFT + N", term("-e newsboat"))
hl.bind(M .. " + M", term("-e ncmpcpp"))
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(M .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(M .. " + S", hl.dsp.window.pin({ action = "toggle" }))
hl.bind(M .. " + V", hl.dsp.window.float({ action = "toggle" }))   -- dwm STACKKEYS V area; float toggle is the closest
hl.bind(M .. " + space", hl.dsp.layout("swapwithmaster auto"))     -- dwm zoom
hl.bind(M .. " + SHIFT + V", hl.dsp.layout("swapwithmaster auto"))

-- Focus / stack (dwm j/k focusstack, Shift+j/k pushstack)
hl.bind(M .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(M .. " + K", hl.dsp.layout("cycleprev"))
hl.bind(M .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(M .. " + SHIFT + K", hl.dsp.layout("swapprev"))

-- Master area (dwm h/l mfact, o/Shift+o nmaster)
hl.bind(M .. " + H", hl.dsp.layout("mfact -0.05"))
hl.bind(M .. " + L", hl.dsp.layout("mfact +0.05"))
hl.bind(M .. " + O", hl.dsp.layout("removemaster"))
hl.bind(M .. " + SHIFT + O", hl.dsp.layout("addmaster"))

-- Layouts (dwm t/y/u/i): Hyprland 0.57 exposes no runtime layout-switch dispatcher,
-- so the layout is fixed to master here. See notes in the chat for the alternatives.

-- Tags -> workspaces 1-9
-- Per-monitor numbering via split-monitor-workspaces (~/.config/hypr/smw, pinned 78e3cf8).
-- Each screen owns its own 1-9 block; SUPER+N never pulls another screen's workspace.
for i = 1, smw.get_amount_of_workspaces() do
    local n = tostring(i)
    hl.bind(M .. " + " .. n,         smw.workspace(n))
    hl.bind(M .. " + SHIFT + " .. n, smw.move_to_workspace_silent(n))
end
hl.bind(M .. " + Tab",       hl.dsp.focus({ workspace = "previous" }))
hl.bind(M .. " + backslash", hl.dsp.focus({ workspace = "previous" }))
hl.bind(M .. " + G",         hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + SHIFT + G", hl.dsp.window.move({ workspace = "e-1", on_current_monitor = true }))
hl.bind(M .. " + semicolon",       hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + SHIFT + semicolon", hl.dsp.window.move({ workspace = "e+1", on_current_monitor = true }))
hl.bind(M .. " + Page_Up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + SHIFT + Page_Up",   hl.dsp.window.move({ workspace = "e-1", on_current_monitor = true }))
hl.bind(M .. " + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(M .. " + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "e+1", on_current_monitor = true }))

-- Monitors (dwm focusmon/tagmon)
hl.bind(M .. " + Left",        hl.dsp.focus({ monitor = "-1" }))
hl.bind(M .. " + Right",       hl.dsp.focus({ monitor = "+1" }))
hl.bind(M .. " + SHIFT + Left",  hl.dsp.window.move({ monitor = "-1" }))
hl.bind(M .. " + SHIFT + Right", hl.dsp.window.move({ monitor = "+1" }))

-- Media (dwm mpc / wpctl bindings)
hl.bind(M .. " + P",              sh("mpc toggle"))
hl.bind(M .. " + SHIFT + P",      sh("mpc pause; pauseallmpv"))
hl.bind(M .. " + bracketleft",    sh("mpc seek -10"))
hl.bind(M .. " + SHIFT + bracketleft",  sh("mpc seek -60"))
hl.bind(M .. " + bracketright",   sh("mpc seek +10"))
hl.bind(M .. " + SHIFT + bracketright", sh("mpc seek +60"))
hl.bind(M .. " + comma",          sh("mpc prev"))
hl.bind(M .. " + SHIFT + comma",  sh("mpc seek 0%"))
hl.bind(M .. " + period",         sh("mpc next"))
hl.bind(M .. " + SHIFT + period", sh("mpc repeat"))
hl.bind(M .. " + minus",          sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind(M .. " + SHIFT + minus",  sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%-"))
hl.bind(M .. " + equal",          sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind(M .. " + SHIFT + equal",  sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 15%+"))
hl.bind(M .. " + SHIFT + M",      sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Function row (dwm F1-F12)
hl.bind(M .. " + F1",  sh("groff -mom /usr/local/share/dwm/larbs.mom -Tpdf | zathura -"))
hl.bind(M .. " + F2",  sh("tutorialvids"))
hl.bind(M .. " + F3",  sh("displayselect"))
hl.bind(M .. " + F4",  term("-e pulsemixer"))
hl.bind(M .. " + F5",  hl.dsp.reload_config())
hl.bind(M .. " + F6",  sh("torwrap"))
hl.bind(M .. " + F7",  sh("td-toggle"))
hl.bind(M .. " + F8",  sh("mailsync"))
hl.bind(M .. " + F9",  sh("mounter"))
hl.bind(M .. " + F10", sh("unmounter"))
hl.bind(M .. " + F11", sh("mpv --untimed --no-cache --no-osc --no-input-default-bindings --profile=low-latency --input-conf=/dev/null --title=webcam $(ls /dev/video[0,2,4,6,8] | tail -n 1)"))
hl.bind(M .. " + F12", sh("remaps"))

-- Screenshots / recording (dwm used maim; Wayland needs grim + slurp)
hl.bind("Print",         sh([[sh -c 'f=pic-full-$(date "+%y%m%d-%H%M-%S").png; grim "$f" && wl-copy < "$f"']]))
hl.bind("SHIFT + Print", sh([[sh -c 'f=pic-sel-$(date "+%y%m%d-%H%M-%S").png; grim -g "$(slurp)" "$f" && wl-copy < "$f"']]))
hl.bind(M .. " + Print",      sh("dmenurecord"))
hl.bind(M .. " + SHIFT + Print", sh("dmenurecord kill"))
hl.bind(M .. " + Delete",     sh("dmenurecord kill"))

-- Hardware / XF86 keys
hl.bind("XF86AudioMute",        sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),            { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+"),             { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"),             { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     sh("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),         { locked = true })
hl.bind("XF86AudioPrev",        sh("mpc prev"),  { locked = true })
hl.bind("XF86AudioNext",        sh("mpc next"),  { locked = true })
hl.bind("XF86AudioPause",       sh("mpc pause"), { locked = true })
hl.bind("XF86AudioPlay",        sh("mpc play"),  { locked = true })
hl.bind("XF86AudioStop",        sh("mpc stop"),  { locked = true })
hl.bind("XF86AudioRewind",      sh("mpc seek -10"), { locked = true })
hl.bind("XF86AudioForward",     sh("mpc seek +10"), { locked = true })
hl.bind("XF86AudioMedia",       term("-e ncmpcpp"))
hl.bind("XF86Calculator",       term("-e bc -l"))
hl.bind("XF86WWW",              sh("firefox"))
hl.bind("XF86Mail",             term("-e neomutt"))
hl.bind("XF86MyComputer",       term("-e lfub /"))
hl.bind("XF86TaskPane",         term("-e htop"))
hl.bind("XF86Sleep",            sh("sudo -A zzz"))
hl.bind("XF86ScreenSaver",      sh("sh -c 'hyprlock & hyprctl dispatch dpms off; mpc pause; pauseallmpv'"))
hl.bind("XF86MonBrightnessUp",  sh("brightnessctl set +15%"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",sh("brightnessctl set 15%-"),  { locked = true, repeating = true })

-- Mouse: dwm MOD+drag move/resize
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
