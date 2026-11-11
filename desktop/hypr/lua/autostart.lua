-- Lancement au démarrage (ex configs/Startup_Apps.conf, UserConfigs/Startup_Apps.conf, hyprland.conf)
local H = require("lua.helpers")
local s = H.scriptsDir

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon --format xrgb")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- Terminal déroulant (SUPER+SHIFT+Entrée) pré-créé, caché dans le scratchpad
    hl.exec_cmd(s .. "/Dropterminal.sh --hidden kitty &")
    hl.exec_cmd(s .. "/Polkit.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("swaync")
    hl.exec_cmd("waybar")
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(s .. "/Hyprsunset.sh init")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("blueman-applet")

    -- Perso
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    -- Micro Razer (jack) : entrée par défaut, 30 %, non muet
    hl.exec_cmd("sleep 3 && wpctl set-default alsa_input.pci-0000_00_1f.3.analog-stereo && wpctl set-volume alsa_input.pci-0000_00_1f.3.analog-stereo 0.30 && wpctl set-mute alsa_input.pci-0000_00_1f.3.analog-stereo 0")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd(H.home .. "/dev/whisper-type/start.sh")
end)
