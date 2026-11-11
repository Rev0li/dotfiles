-- Règles de fenêtres et de calques (ex configs/WindowRules.conf)
local function rule(match, effects)
    effects.match = match
    return hl.window_rule(effects)
end
local function tag(class, t) rule({ class = class }, { tag = "+" .. t }) end
local function tag_title(title, t) rule({ title = title }, { tag = "+" .. t }) end
local function size(w, h) return { "monitor_w*" .. w, "monitor_h*" .. h } end

-- ── Étiquettes ──────────────────────────────────────────────────
tag("^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$", "browser")
tag("^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$", "browser")
tag("^(chrome-.+-Default)$", "browser")
tag("^([Cc]hromium)$", "browser")
tag("^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$", "browser")
tag("^(Brave-browser(-beta|-dev|-unstable)?)$", "browser")
tag("^([Tt]horium-browser|[Cc]achy-browser)$", "browser")
tag("^(zen-alpha|zen)$", "browser")
tag("^(swaync-control-center|swaync-notification-window|swaync-client|class)$", "notif")
tag_title("^(KooL Quick Cheat Sheet)$", "KooL_Cheat")
tag_title("^(KooL Hyprland Settings)$", "KooL_Settings")
tag("^(nwg-displays|nwg-look)$", "KooL-Settings")
tag("^(Alacritty|kitty|kitty-dropterm)$", "terminal")
tag("^([Tt]hunderbird|org.mozilla.Thunderbird)$", "email")
tag("^(eu.betterbird.Betterbird)$", "email")
tag("^(org.gnome.Evolution)$", "email")
tag("^(codium|codium-url-handler|VSCodium)$", "projects")
tag("^(VSCode|code|code-url-handler)$", "projects")
tag("^(jetbrains-.+)$", "projects")
tag("^(dev.zed.Zed|antigravity)$", "projects")
tag("^(com.obsproject.Studio)$", "screenshare")
tag("^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$", "im")
tag("^([Ff]erdium)$", "im")
tag("^([Ww]hatsapp-for-linux)$", "im")
tag("^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$", "im")
tag("^(teams-for-linux)$", "im")
tag("^(im.riot.Riot|Element)$", "im")
tag("^(gamescope)$", "games")
tag([[^(steam_app_\d+)$]], "games")
tag("^([Ss]team)$", "gamestore")
tag_title("^([Ll]utris)$", "gamestore")
tag("^(com.heroicgameslauncher.hgl)$", "gamestore")
tag("^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$", "file-manager")
tag("^(app.drey.Warp)$", "file-manager")
tag("^([Ww]aytrogen)$", "wallpaper")
tag("^([Aa]udacious)$", "multimedia")
tag("^([Mm]pv|vlc)$", "multimedia_video")
tag_title("^(ROG Control)$", "settings")
tag("^(wihotspot(-gui)?)$", "settings")
tag("^([Bb]aobab|org.gnome.[Bb]aobab)$", "settings")
tag("^(gnome-disks|wihotspot(-gui)?)$", "settings")
tag_title("(Kvantum Manager)", "settings")
tag("^(file-roller|org.gnome.FileRoller)$", "settings")
tag("^(nm-applet|nm-connection-editor|blueman-manager)$", "settings")
tag("^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$", "settings")
tag("^(qt5ct|qt6ct)$", "settings")
tag("(xdg-desktop-portal-gtk)", "settings")
tag("^(org.kde.polkit-kde-authentication-agent-1)$", "settings")
tag("^([Rr]ofi)$", "settings")
tag("^(btrfs-assistant)$", "settings")
tag("^(timeshift-gtk)$", "settings")
tag("^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$", "viewer")
tag("^(evince)$", "viewer")
tag("^(eog|org.gnome.Loupe)$", "viewer")

-- ── Effets par étiquette / classe ───────────────────────────────
rule({ tag = "multimedia_video" }, { no_blur = true, opacity = "1.0" })
rule({ tag = "multimedia" },       { no_blur = true, opacity = "1.0" })

rule({ tag = "KooL_Cheat" },    { center = true })
rule({ tag = "KooL-Settings" }, { center = true })
rule({ title = "^(ROG Control)$" }, { center = true })
rule({ title = "^(Keybindings)$" }, { center = true })
rule({ class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, { center = true })
rule({ class = "^([Ff]erdium)$" }, { center = true })

-- Pas de mise en veille pendant qu'une fenêtre est en plein écran
rule({ class = ".*" }, { idle_inhibit = "fullscreen" })

rule({ tag = "KooL_Cheat" },    { float = true })
rule({ tag = "wallpaper" },     { float = true, center = true })
rule({ tag = "settings" },      { float = true, center = true })
rule({ tag = "viewer" },        { float = true, center = true })
rule({ tag = "KooL-Settings" }, { float = true, center = true })
rule({ class = "([Zz]oom|onedriver|onedriver-launcher)" }, { float = true })
rule({ class = "(org.gnome.Calculator|qalculate-gtk)" }, { float = true })
rule({ class = "^(mpv|com.github.rafostar.Clapper)$" }, { float = true })
rule({ class = "^([Qq]alculate-gtk)$" }, { float = true })
rule({ class = "^([Ff]erdium)$" }, { float = true })
rule({ title = "^(Authentication Required)$" }, { float = true, center = true })
rule({ class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, { float = true })
rule({ class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, { float = true })
rule({ class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, { float = true })
rule({ title = "^(Add Folder to Workspace)$" }, { float = true, size = size(0.7, 0.6), center = true })
rule({ title = "^(Save As)$" }, { float = true, size = size(0.7, 0.6), center = true })
rule({ initial_title = "(Open Files)" }, { float = true, size = size(0.7, 0.6) })
rule({ title = "^(SDDM Background)$" }, { float = true, center = true, size = size(0.16, 0.12) })
rule({ class = "^(yad)$" }, { float = true, center = true, size = size(0.2, 0.2) })
rule({ class = "^(hyprland-donate-screen)$" }, { float = true, center = true })

rule({ tag = "browser" },      { opacity = "0.99 0.8" })
rule({ tag = "projects" },     { opacity = "0.9 0.8" })
rule({ tag = "im" },           { opacity = "0.94 0.86" })
rule({ tag = "multimedia" },   { opacity = "0.94 0.86" })
rule({ tag = "file-manager" }, { opacity = "0.9 0.8" })
rule({ tag = "terminal" },     { opacity = "0.9 0.7" })
rule({ tag = "settings" },     { opacity = "0.8 0.7" })
rule({ tag = "viewer" },       { opacity = "0.82 0.75" })
rule({ tag = "wallpaper" },    { opacity = "0.9 0.7" })
rule({ class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, { opacity = "0.8 0.7" })
rule({ class = "^(deluge)$" },  { opacity = "0.9 0.8" })
rule({ class = "^(seahorse)$" }, { opacity = "0.9 0.8" })
rule({ title = "^(Picture-in-Picture)$" }, { opacity = "0.95 0.75" })

rule({ tag = "KooL_Cheat" }, { size = size(0.65, 0.9) })
rule({ tag = "wallpaper" },  { size = size(0.7, 0.7) })
rule({ tag = "settings" },   { size = size(0.7, 0.7) })
rule({ class = "^([Ff]erdium)$" }, { size = size(0.6, 0.7) })

rule({ tag = "games" }, { no_blur = true, fullscreen = false })

rule({ class = "^(jetbrains-*)" }, { no_initial_focus = true })
rule({ title = "^(wind.*)$" },     { no_initial_focus = true })

-- Règles nommées
hl.window_rule({
    name  = "Whatsapp-zapzap",
    match = { class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" },
    size  = size(0.6, 0.7),
    center = true,
})
hl.window_rule({
    name  = "Picture-in-Picture",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    move  = { "monitor_w*0.72", "monitor_h*0.07" },
    opacity = "0.95 0.75",
    pin   = true,
    keep_aspect_ratio = true,
    size  = size(0.3, 0.3),
})
hl.window_rule({
    name  = "Thunar-Progress-bar",
    match = { class = "^(thunar)$", title = "^(File Operation Progress)$" },
    float = true,
    center = true,
    size  = size(0.26, 0.18),
})

-- SUPER+CTRL+O : opacité forcée (étiquette basculée par le raccourci)
hl.window_rule({ name = "opaque-toggle", match = { tag = "opaque_toggle" }, opaque = true })

-- ── Calques ─────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, blur = true, ignore_alpha = 0.5 })

-- Hyprland 0.57 : ignorer les demandes "maximiser" des applis (règle de la config par défaut).
-- Sans elle, un kitty flottant s'ouvre agrandi, ce qui cassait le terminal déroulant.
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
