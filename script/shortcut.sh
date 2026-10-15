#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# ⌨️  Ajout du raccourci clavier GNOME : Super+E → Kitty
# Compatible : Ubuntu, Debian, Fedora (bureau GNOME)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# ── Couleurs ────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
}

# ═══════════════════════════════════════════════════════════
# 🔍 Vérifications
# ═══════════════════════════════════════════════════════════

print_header "Vérification de l'environnement"

# GNOME requis
if ! command -v gsettings &>/dev/null; then
    err "gsettings introuvable — ce script nécessite un bureau GNOME"
    exit 1
fi
ok "GNOME détecté"

# Trouver le binaire kitty
KITTY_BIN=""
for candidate in \
    "$(command -v kitty 2>/dev/null || true)" \
    "$HOME/.local/bin/kitty" \
    "$HOME/dotfiles/bin/kitty"; do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
        KITTY_BIN="$candidate"
        break
    fi
done

if [ -z "$KITTY_BIN" ]; then
    err "Binaire kitty introuvable — lancer ./install.sh"
    exit 1
fi
ok "kitty trouvé : $KITTY_BIN"

# ═══════════════════════════════════════════════════════════
# ⌨️  Ajout du raccourci GNOME
# ═══════════════════════════════════════════════════════════

print_header "Configuration du raccourci Super+E"

SHORTCUT_NAME="Kitty"
SHORTCUT_CMD="$KITTY_BIN"
SHORTCUT_KEY="<Super>e"
SHORTCUT_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty/"
SHORTCUTS_LIST_KEY="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Lire la liste actuelle des raccourcis custom
CURRENT=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

# Vérifier si notre raccourci est déjà dans la liste
if echo "$CURRENT" | grep -q "custom-keybindings/kitty/"; then
    warn "Raccourci kitty déjà présent dans la liste — mise à jour..."
    NEW_LIST="$CURRENT"
else
    # Ajouter notre path à la liste existante
    if [ "$CURRENT" = "@as []" ] || [ "$CURRENT" = "[]" ]; then
        NEW_LIST="['${SHORTCUT_PATH}']"
    else
        # Insérer avant le ']' final
        NEW_LIST="${CURRENT%]}, '${SHORTCUT_PATH}']"
    fi
fi

# Appliquer la liste mise à jour
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"
ok "Liste des raccourcis mise à jour"

# Définir les propriétés du raccourci
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$SHORTCUT_PATH" \
    name    "$SHORTCUT_NAME"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$SHORTCUT_PATH" \
    command "$SHORTCUT_CMD"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$SHORTCUT_PATH" \
    binding "$SHORTCUT_KEY"

ok "Nom    : $SHORTCUT_NAME"
ok "Cmd    : $SHORTCUT_CMD"
ok "Touche : Super + E"

# ═══════════════════════════════════════════════════════════
# ✅ Résumé
# ═══════════════════════════════════════════════════════════

print_header "Raccourci ajouté 🎉"

echo ""
echo -e "  ${GREEN}Super + E${NC} → ouvre Kitty"
echo ""
echo -e "  ${YELLOW}Note :${NC} Le raccourci est actif immédiatement, sans redémarrage."
echo -e "  Pour le supprimer :"
echo -e "    ${CYAN}gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \"[]\"${NC}"
echo ""
