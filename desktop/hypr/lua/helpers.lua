-- Petits utilitaires partagés par la config Lua (migration hyprlang -> Lua, Hyprland 0.57).
local M = {}

M.home        = os.getenv("HOME")
M.hypr        = M.home .. "/.config/hypr"
M.scriptsDir  = M.hypr .. "/scripts"
M.UserScripts = M.hypr .. "/UserScripts"

-- Lit les couleurs générées par wallust (format hyprlang : $colorN = rgb(XXXXXX)).
-- Le fichier est régénéré à chaque changement de fond d'écran : on le relit à chaque chargement.
function M.wallust_colors()
    local c = {
        background = "rgb(000004)", foreground = "rgb(F8EDD8)",
        color0 = "rgb(000004)", color10 = "rgb(383943)", color12 = "rgb(C6726E)", color15 = "rgb(ECDDBF)",
    }
    local f = io.open(M.hypr .. "/wallust/wallust-hyprland.conf", "r")
    if f then
        for line in f:lines() do
            local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(%S+)")
            if name and value then c[name] = value end
        end
        f:close()
    end
    return c
end

-- Applique les lignes "monitor=" écrites par nwg-displays dans monitors.conf.
function M.load_monitors(path)
    local f = io.open(path, "r")
    if not f then return false end
    local found = false
    for line in f:lines() do
        local spec = line:match("^%s*monitor%s*=%s*([^#]*)")
        if spec then
            local parts = {}
            for p in (spec .. ","):gmatch("([^,]*),") do
                parts[#parts + 1] = p:match("^%s*(.-)%s*$")
            end
            if parts[2] == "disable" then
                hl.monitor({ output = parts[1], disabled = true })
            else
                hl.monitor({
                    output   = parts[1] or "",
                    mode     = (parts[2] ~= "" and parts[2]) or "preferred",
                    position = (parts[3] ~= "" and parts[3]) or "auto",
                    scale    = (parts[4] ~= "" and parts[4]) or "auto",
                })
            end
            found = true
        end
    end
    f:close()
    return found
end

return M
