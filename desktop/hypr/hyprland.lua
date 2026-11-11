-- Config Hyprland (Lua, Hyprland >= 0.57) — migrée depuis hyprland.conf (KooL Hyprland-Dots v2.3.20)
-- le 2026-11-11. Les anciens fichiers .conf restent en place mais ne sont plus lus par Hyprland.
-- L'original auto-généré par Hyprland est sauvegardé dans hyprland.lua.auto-0.57.bak.
--
-- Fichiers :
--   lua/helpers.lua   chemins, lecture des couleurs wallust et de monitors.conf
--   lua/env.lua       variables d'environnement
--   lua/settings.lua  réglages, décorations, animations, gestes
--   lua/binds.lua     raccourcis
--   lua/rules.lua     règles de fenêtres et de calques
--   lua/autostart.lua programmes lancés au démarrage

local H = require("lua.helpers")

-- Écrans : monitors.conf (nwg-displays) s'il contient des lignes "monitor=", sinon défaut
if not H.load_monitors(H.hypr .. "/monitors.conf") then
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
end

require("lua.env")
require("lua.settings")
require("lua.binds")
require("lua.rules")
require("lua.autostart")
