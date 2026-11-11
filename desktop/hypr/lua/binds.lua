-- Raccourcis (ex configs/Keybinds.conf, configs/Laptops.conf, UserConfigs/UserKeybinds.conf, hyprland.conf)
local H   = require("lua.helpers")
local S   = require("lua.settings")
local dsp = hl.dsp

local mainMod     = "SUPER"
local scriptsDir  = H.scriptsDir
local UserScripts = H.UserScripts
local term        = "kitty"
local files       = "thunar"

local function k(mods, key)
    if mods == nil or mods == "" then return key end
    return mods:gsub("%s+", " + ") .. " + " .. key
end

-- bind avec description (équivalent de bindd)
local function b(mods, key, desc, action, opts)
    opts = opts or {}
    opts.description = desc
    -- pcall : une touche inconnue ne doit pas interrompre le chargement des autres raccourcis
    local ok, res = pcall(hl.bind, k(mods, key), action, opts)
    if not ok then
        hl.notification.create({ text = "bind " .. k(mods, key) .. " : " .. tostring(res), duration = 8000 })
    end
    return res
end

local function exec(cmd) return dsp.exec_cmd(cmd) end
local function layout_is(name) return hl.get_config("general.layout") == name end

-- ── Applications ────────────────────────────────────────────────
b(mainMod, "D", "app launcher", exec("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"))
b(mainMod, "B", "open default browser", exec('xdg-open "https://"'))
b(mainMod, "A", "desktop overview", exec(scriptsDir .. "/OverviewToggle.sh"))
b(mainMod, "Return", "Open terminal", exec(term))
b(mainMod, "E", "file manager", exec(files))

-- ── Fonctions KooL ──────────────────────────────────────────────
b(mainMod, "T", "Global theme switcher using Wallust", exec(scriptsDir .. "/ThemeChanger.sh"))
b(mainMod, "H", "help / cheat sheet", exec(scriptsDir .. "/KeyHints.sh"))
b(mainMod .. " ALT", "R", "refresh bar and menus", exec(scriptsDir .. "/Refresh.sh"))
b(mainMod .. " ALT", "E", "emoji menu", exec(scriptsDir .. "/RofiEmoji.sh"))
b(mainMod, "S", "web search", exec(scriptsDir .. "/RofiSearch.sh"))
b(mainMod .. " CTRL", "S", "window switcher", exec("rofi -show window"))
b(mainMod .. " ALT", "O", "toggle blur", exec(scriptsDir .. "/ChangeBlur.sh"))
b(mainMod .. " SHIFT", "G", "toggle game mode", exec(scriptsDir .. "/GameMode.sh"))
b(mainMod .. " ALT", "V", "clipboard manager", exec(scriptsDir .. "/ClipManager.sh"))
b(mainMod .. " CTRL", "R", "rofi theme selector", exec(scriptsDir .. "/RofiThemeSelector.sh"))
b(mainMod .. " CTRL SHIFT", "R", "rofi theme selector (modified)", exec("pkill rofi || true && " .. scriptsDir .. "/RofiThemeSelector-modified.sh"))

-- Bascule dwindle <-> master (remplace scripts/ChangeLayout.sh, qui utilisait "hyprctl keyword")
b(mainMod .. " ALT", "L", "toggle master/dwindle layout", function()
    local new = layout_is("master") and "dwindle" or "master"
    hl.config({ general = { layout = new } })
    local label = (new == "master") and " Master Layout" or " Dwindle Layout"
    hl.dispatch(dsp.exec_cmd('notify-send -e -u low -i "$HOME/.config/swaync/images/ja.png" "' .. label .. '"'))
end)
-- J/K/O selon la disposition (remplace KeybindsLayoutInit.sh)
b(mainMod, "J", "next window", function()
    if layout_is("master") then hl.dispatch(dsp.layout("cyclenext"))
    else hl.dispatch(dsp.window.cycle_next()) end
end)
b(mainMod, "K", "previous window", function()
    if layout_is("master") then hl.dispatch(dsp.layout("cycleprev"))
    else hl.dispatch(dsp.window.cycle_next({ next = false })) end
end)
b(mainMod, "O", "toggle split (dwindle)", function()
    if not layout_is("master") then hl.dispatch(dsp.layout("togglesplit")) end
end)

b(mainMod .. " SHIFT", "F", "fullscreen", dsp.window.fullscreen())
b(mainMod .. " CTRL", "F", "maximize window", dsp.window.fullscreen({ mode = "maximized" }))
b(mainMod, "SPACE", "Float current window", dsp.window.float({ action = "toggle" }))
b(mainMod .. " ALT", "SPACE", "Float all windows", function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    for _, w in ipairs(hl.get_workspace_windows(ws)) do
        hl.dispatch(dsp.window.float({ window = w, action = "toggle" }))
    end
end)
b(mainMod .. " SHIFT", "Return", "DropDown terminal", exec(scriptsDir .. "/Dropterminal.sh " .. term))

-- Zoom écran
b(mainMod .. " ALT", "mouse_down", "zoom in", S.zoom(2.0))
b(mainMod .. " ALT", "mouse_up", "zoom out", S.zoom(0.5))

-- Waybar
b(mainMod .. " CTRL ALT", "B", "toggle waybar on/off", exec("pkill -SIGUSR1 waybar"))
b(mainMod .. " CTRL", "B", "waybar styles menu", exec(scriptsDir .. "/WaybarStyles.sh"))
b(mainMod .. " ALT", "B", "waybar layout menu", exec(scriptsDir .. "/WaybarLayout.sh"))

b(mainMod, "N", "toggle night light", exec(scriptsDir .. "/Hyprsunset.sh toggle"))
b(mainMod .. " SHIFT", "M", "online music", exec(UserScripts .. "/RofiBeats.sh"))
b(mainMod, "W", "select wallpaper", exec(UserScripts .. "/WallpaperSelect.sh"))
b(mainMod .. " SHIFT", "W", "wallpaper effects", exec(UserScripts .. "/WallpaperEffects.sh"))
b("CTRL ALT", "W", "random wallpaper", exec(UserScripts .. "/WallpaperRandom.sh"))
-- Opacité forcée : bascule une étiquette, la règle "opaque_toggle" (rules.lua) fait le reste
b(mainMod .. " CTRL", "O", "toggle active window opacity", dsp.window.tag({ tag = "opaque_toggle" }))
b(mainMod .. " SHIFT", "K", "search keybinds", exec(scriptsDir .. "/KeyBinds.sh"))
b(mainMod .. " SHIFT", "A", "animations menu", exec(scriptsDir .. "/Animations.sh"))
b(mainMod .. " SHIFT", "O", "change oh-my-zsh theme", exec(UserScripts .. "/ZshChangeTheme.sh"))

-- Disposition clavier (touches modificatrices seules)
b("ALT", "Shift_L", "switch keyboard layout globally", exec(scriptsDir .. "/KeyboardLayout.sh switch"), { locked = true, non_consuming = true })
b("SHIFT", "Alt_L", "switch keyboard layout per-window", exec(scriptsDir .. "/Tak0-Per-Window-Switch.sh"), { locked = true, non_consuming = true })
b(mainMod .. " ALT", "C", "calculator", exec(UserScripts .. "/RofiCalc.sh"))

-- Déplacer l'espace de travail vers un autre écran
b(mainMod .. " CTRL", "F9",  "move workspace to left monitor",  dsp.workspace.move({ monitor = "l" }))
b(mainMod .. " CTRL", "F10", "move workspace to right monitor", dsp.workspace.move({ monitor = "r" }))
b(mainMod .. " CTRL", "F11", "move workspace to up monitor",    dsp.workspace.move({ monitor = "u" }))
b(mainMod .. " CTRL", "F12", "move workspace to down monitor",  dsp.workspace.move({ monitor = "d" }))

-- ── Fenêtres / session ──────────────────────────────────────────
b("CTRL ALT", "Delete", "exit Hyprland", dsp.exit())
b(mainMod, "Q", "close active window", dsp.window.close())
b(mainMod .. " SHIFT", "Q", "Terminate active process", exec(scriptsDir .. "/KillActiveProcess.sh"))
b("CTRL ALT", "L", "lock screen", exec(scriptsDir .. "/LockScreen.sh"))
b("CTRL ALT", "P", "powermenu", exec(scriptsDir .. "/Wlogout.sh"))
b(mainMod .. " SHIFT", "N", "notification panel", exec("swaync-client -t -sw"))
b(mainMod .. " SHIFT", "E", "Quick settings menu", exec(scriptsDir .. "/Kool_Quick_Settings.sh"))

-- Dispositions
b(mainMod .. " CTRL", "D", "remove master", dsp.layout("removemaster"))
b(mainMod, "I", "add master", dsp.layout("addmaster"))
b(mainMod .. " CTRL", "Return", "swap with master", dsp.layout("swapwithmaster"))
b(mainMod .. " SHIFT", "I", "toggle split (dwindle)", dsp.layout("togglesplit"))
b(mainMod, "P", "toggle pseudo (dwindle)", dsp.window.pseudo())
b(mainMod, "M", "set split ratio 0.3", dsp.layout("splitratio 0.3"))

b("ALT", "Tab", "cycle next window", function()
    hl.dispatch(dsp.window.cycle_next())
    hl.dispatch(dsp.window.bring_to_top())
end)

-- ── Son, média ──────────────────────────────────────────────────
b("", "XF86AudioRaiseVolume", "volume up", exec(scriptsDir .. "/Volume.sh --inc"), { repeating = true, locked = true })
b("", "XF86AudioLowerVolume", "volume down", exec(scriptsDir .. "/Volume.sh --dec"), { repeating = true, locked = true })
b("ALT", "XF86AudioRaiseVolume", "volume up precise", exec(scriptsDir .. "/Volume.sh --inc-precise"), { repeating = true, locked = true })
b("ALT", "XF86AudioLowerVolume", "volume down precise", exec(scriptsDir .. "/Volume.sh --dec-precise"), { repeating = true, locked = true })
b("", "XF86AudioMicMute", "toggle mic mute", exec(scriptsDir .. "/Volume.sh --toggle-mic"), { locked = true })
b("", "XF86AudioMute", "toggle mute", exec(scriptsDir .. "/Volume.sh --toggle"), { locked = true })
b("", "XF86Sleep", "sleep", exec("systemctl suspend"), { locked = true })
b("", "XF86Rfkill", "airplane mode", exec(scriptsDir .. "/AirplaneMode.sh"), { locked = true })
b("", "XF86AudioPause", "pause", exec(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
b("", "XF86AudioPlay", "play", exec(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
b("", "XF86AudioNext", "next track", exec(scriptsDir .. "/MediaCtrl.sh --nxt"), { locked = true })
b("", "XF86AudioPrev", "previous track", exec(scriptsDir .. "/MediaCtrl.sh --prv"), { locked = true })
b("", "XF86AudioStop", "stop", exec(scriptsDir .. "/MediaCtrl.sh --stop"), { locked = true })

-- ── Captures d'écran ────────────────────────────────────────────
b(mainMod, "Print", "screenshot now", exec(scriptsDir .. "/ScreenShot.sh --now"))
b(mainMod .. " SHIFT", "Print", "screenshot (area)", exec(scriptsDir .. "/ScreenShot.sh --area"))
b(mainMod .. " CTRL", "Print", "screenshot in 5s", exec(scriptsDir .. "/ScreenShot.sh --in5"))
b(mainMod .. " CTRL SHIFT", "Print", "screenshot in 10s", exec(scriptsDir .. "/ScreenShot.sh --in10"))
b("ALT", "Print", "screenshot active window", exec(scriptsDir .. "/ScreenShot.sh --active"))
b(mainMod .. " SHIFT", "S", "screenshot (swappy)", exec(scriptsDir .. "/ScreenShot.sh --swappy"))

-- ── Redimensionner / déplacer / échanger ────────────────────────
local dirs = { left = { -50, 0 }, right = { 50, 0 }, up = { 0, -50 }, down = { 0, 50 } }
for _, d in ipairs({ "left", "right", "up", "down" }) do
    local v = dirs[d]
    b(mainMod .. " SHIFT", d, "resize " .. d, dsp.window.resize({ x = v[1], y = v[2], relative = true }), { repeating = true })
    b(mainMod .. " CTRL", d, "move window " .. d, dsp.window.move({ direction = d }))
    b(mainMod .. " ALT", d, "swap window " .. d, dsp.window.swap({ direction = d }))
    b(mainMod, d, "focus " .. d, dsp.focus({ direction = d }))
end

-- ── Groupes ─────────────────────────────────────────────────────
b(mainMod, "G", "toggle group", dsp.group.toggle())
b(mainMod .. " CTRL", "Tab", "change active in group", dsp.group.next())
b(mainMod .. " CTRL", "K", "Move left into group", dsp.window.move({ into_group = "left" }))
b(mainMod .. " CTRL", "L", "Move Right into group", dsp.window.move({ into_group = "right" }))
b(mainMod .. " CTRL", "H", "Move active out of group", dsp.window.move({ out_of_group = true }))
-- NB : dans l'ancienne config, SUPER+Tab / SUPER+SHIFT+Tab étaient liés deux fois
-- (groupe puis espace de travail) : les deux actions s'exécutaient. On garde le même comportement.
b(mainMod, "Tab", "group forward + next workspace", function()
    hl.dispatch(dsp.group.next())
    hl.dispatch(dsp.focus({ workspace = "m+1" }))
end)
b(mainMod .. " SHIFT", "Tab", "group back + previous workspace", function()
    hl.dispatch(dsp.group.prev())
    hl.dispatch(dsp.focus({ workspace = "m-1" }))
end)

-- ── Espaces de travail ──────────────────────────────────────────
b(mainMod .. " SHIFT", "U", "move to special workspace", dsp.window.move({ workspace = "special:special" }))
b(mainMod, "U", "toggle special workspace", dsp.workspace.toggle_special("special"))

for i = 1, 10 do
    local code = "code:" .. (9 + i) -- code:10 = touche 1 ... code:19 = touche 0
    b(mainMod, code, "workspace " .. i, dsp.focus({ workspace = i }))
    b(mainMod .. " SHIFT", code, "move to workspace " .. i, dsp.window.move({ workspace = i }))
    b(mainMod .. " CTRL", code, "move silently to workspace " .. i, dsp.window.move({ workspace = i, follow = false }))
end
b(mainMod .. " SHIFT", "bracketleft", "move to previous workspace", dsp.window.move({ workspace = "-1" }))
b(mainMod .. " SHIFT", "bracketright", "move to next workspace", dsp.window.move({ workspace = "+1" }))
b(mainMod .. " CTRL", "bracketleft", "move silently to previous workspace", dsp.window.move({ workspace = "-1", follow = false }))
b(mainMod .. " CTRL", "bracketright", "move silently to next workspace", dsp.window.move({ workspace = "+1", follow = false }))

b(mainMod, "mouse_down", "next workspace", dsp.focus({ workspace = "e+1" }))
b(mainMod, "mouse_up", "previous workspace", dsp.focus({ workspace = "e-1" }))
b(mainMod, "period", "next workspace", dsp.focus({ workspace = "e+1" }))
b(mainMod, "comma", "previous workspace", dsp.focus({ workspace = "e-1" }))

-- Souris : déplacer / redimensionner
b(mainMod, "mouse:272", "move window", dsp.window.drag(), { mouse = true })
b(mainMod, "mouse:273", "resize window", dsp.window.resize(), { mouse = true })

-- ── Touches portable (configs/Laptops.conf) ─────────────────────
b("", "XF86KbdBrightnessDown", "keyboard brightness down", exec(scriptsDir .. "/BrightnessKbd.sh --dec"), { repeating = true })
b("", "XF86KbdBrightnessUp", "keyboard brightness up", exec(scriptsDir .. "/BrightnessKbd.sh --inc"), { repeating = true })
b("", "XF86Launch1", "ROG control center", exec("rog-control-center"))
b("", "XF86Launch3", "keyboard RGB profile", exec("asusctl led-mode -n"))
b("", "XF86Launch4", "fan profile", exec("asusctl profile -n"))
b("", "XF86MonBrightnessDown", "monitor brightness down", exec(scriptsDir .. "/Brightness.sh --dec"), { repeating = true })
b("", "XF86MonBrightnessUp", "monitor brightness up", exec(scriptsDir .. "/Brightness.sh --inc"), { repeating = true })
b("", "XF86TouchpadToggle", "toggle touchpad", exec(scriptsDir .. "/TouchPad.sh"))
b(mainMod, "F6", "screenshot", exec(scriptsDir .. "/ScreenShot.sh --now"))
b(mainMod .. " SHIFT", "F6", "screenshot (area)", exec(scriptsDir .. "/ScreenShot.sh --area"))
b(mainMod .. " CTRL", "F6", "screenshot (5s)", exec(scriptsDir .. "/ScreenShot.sh --in5"))
b(mainMod .. " ALT", "F6", "screenshot (10s)", exec(scriptsDir .. "/ScreenShot.sh --in10"))
b("ALT", "F6", "screenshot (active window)", exec(scriptsDir .. "/ScreenShot.sh --active"))

-- ── Perso ───────────────────────────────────────────────────────
-- whisper-type : SUPER+` pour démarrer/arrêter l'enregistrement
b(mainMod, "grave", "whisper-type toggle", exec(H.home .. "/dev/whisper-type/toggle.sh"))
