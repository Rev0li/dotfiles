#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# 🎨 Toggle thème dark / light
# Affecte : Kitty + Helix + Starship
# Usage   : theme-toggle [dark|light]
# ═══════════════════════════════════════════════════════════

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
THEME_FILE="$HOME/.config/theme"           # fichier d'état : "dark" ou "light"
HELIX_CONFIG="$DOTFILES_DIR/helix/config.toml"

# ── Thèmes ──────────────────────────────────────────────────
KITTY_DARK="Tokyo-Night"
KITTY_LIGHT="Tokyo-Night-Day"
KITTY_THEME_CONF="$HOME/.config/kitty/theme.conf"   # inclus par kitty.conf (globinclude)

HELIX_DARK="rose_pine_moon"
HELIX_LIGHT="rose_pine_dawn"

STARSHIP_DARK="$DOTFILES_DIR/starship/starship-dark.toml"
STARSHIP_LIGHT="$DOTFILES_DIR/starship/starship-light.toml"
THEME_ENV="$HOME/.config/theme-env"    # sourcé par zsh pour STARSHIP_CONFIG

# ── Couleurs terminal ────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

# ═══════════════════════════════════════════════════════════
# Lire le thème courant
# ═══════════════════════════════════════════════════════════

mkdir -p "$(dirname "$THEME_FILE")"
# Vide si jamais appliqué (machine neuve) : le thème demandé sera alors toujours écrit
CURRENT=$(cat "$THEME_FILE" 2>/dev/null || true)

# ── Déterminer la cible ─────────────────────────────────────
if [ "${1:-}" = "dark" ]; then
    TARGET="dark"
elif [ "${1:-}" = "light" ]; then
    TARGET="light"
else
    # Toggle automatique si pas d'argument
    if [ "$CURRENT" = "dark" ] || [ -z "$CURRENT" ]; then
        TARGET="light"
    else
        TARGET="dark"
    fi
fi

if [ "$TARGET" = "$CURRENT" ]; then
    echo -e "  ${YELLOW}⚠${NC} Thème déjà en mode ${BOLD}${TARGET}${NC}"
    exit 0
fi

# ═══════════════════════════════════════════════════════════
# Appliquer le thème
# ═══════════════════════════════════════════════════════════

if [ "$TARGET" = "dark" ]; then
    KITTY_THEME="$KITTY_DARK"
    HELIX_THEME="$HELIX_DARK"
    ICON="🌙"
else
    KITTY_THEME="$KITTY_LIGHT"
    HELIX_THEME="$HELIX_LIGHT"
    ICON="☀️"
fi

info "Passage en mode ${BOLD}${TARGET}${NC}..."

# ── Helix — modifier config.toml ────────────────────────────
if [ -f "$HELIX_CONFIG" ]; then
    sed -i "s/^theme = .*/theme = \"${HELIX_THEME}\"/" "$HELIX_CONFIG"
    ok "Helix → $HELIX_THEME"
else
    echo -e "  ${YELLOW}⚠${NC} $HELIX_CONFIG introuvable — Helix ignoré"
fi

# ── Starship — switcher le fichier de config ────────────────
if [ "$TARGET" = "dark" ]; then
    STARSHIP_CFG="$STARSHIP_DARK"
else
    STARSHIP_CFG="$STARSHIP_LIGHT"
fi

if [ -f "$STARSHIP_CFG" ]; then
    # Écrire la variable dans theme-env (sourcé par zsh au démarrage)
    echo "export STARSHIP_CONFIG=\"$STARSHIP_CFG\"" > "$THEME_ENV"
    # Appliquer immédiatement dans le shell courant
    export STARSHIP_CONFIG="$STARSHIP_CFG"
    ok "Starship → $(basename $STARSHIP_CFG)"
else
    warn "$(basename $STARSHIP_CFG) introuvable dans dotfiles/starship/"
fi

echo "$TARGET" > "$THEME_FILE"

# ── Kitty — écrire theme.conf puis recharger toutes les fenêtres ──
if [ -d "$HOME/.config/kitty" ]; then
    echo "include kitty-themes/${KITTY_THEME}.conf" > "$KITTY_THEME_CONF"
    pkill -USR1 -x kitty 2>/dev/null || true
    ok "Kitty → $KITTY_THEME"
fi

echo ""
echo -e "  ${BOLD}${ICON} Mode ${TARGET} activé${NC}"
echo ""
