#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dotfiles Doctor — diagnostic complet
# Vérifie symlinks, binaires, PATH, variables d'env, thème
# Usage : ./script/doctor.sh
# ═══════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$DOTFILES_DIR/bin"

ERRORS=0
WARNINGS=0

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
}

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
err()  { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }

# Vérifie qu'un symlink pointe vers la bonne cible
check_link() {
    local dst="$1" expected_src="$2" label="${3:-$1}"
    if [ ! -e "$dst" ]; then
        err "$label — absent"
    elif [ ! -L "$dst" ]; then
        warn "$label — existe mais n'est pas un symlink"
    else
        local actual
        actual=$(readlink "$dst")
        if [ "$actual" = "$expected_src" ]; then
            ok "$label → $expected_src"
        else
            warn "$label pointe vers $actual (attendu : $expected_src)"
        fi
    fi
}

# Vérifie qu'un binaire est présent et exécutable
check_bin() {
    local name="$1" bin="$BIN_DIR/$1"
    if [ ! -f "$bin" ]; then
        err "$name absent de bin/ — lancer ./install.sh"
    elif [ ! -x "$bin" ]; then
        err "$name présent mais non exécutable"
    else
        local version
        version=$("$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "?")
        ok "$name ($version)"
    fi
}

# Vérifie qu'une variable d'env est définie
check_env() {
    local var="$1"
    local value="${!var:-}"
    if [ -z "$value" ]; then
        warn "$var non définie (recharger le shell : exec zsh)"
    else
        ok "$var = $value"
    fi
}

# ═══════════════════════════════════════════════════════════
# Symlinks de configuration
# ═══════════════════════════════════════════════════════════

print_header "Symlinks de configuration"

check_link "$HOME/.zshrc" \
    "$DOTFILES_DIR/zsh/custom_zshrc.zsh" \
    "~/.zshrc"

check_link "$HOME/.config/helix" \
    "$DOTFILES_DIR/helix" \
    "~/.config/helix"

check_link "$HOME/.config/wezterm/wezterm.lua" \
    "$DOTFILES_DIR/wezterm/wezterm.lua" \
    "~/.config/wezterm/wezterm.lua"

# ═══════════════════════════════════════════════════════════
# Binaires dans dotfiles/bin/
# ═══════════════════════════════════════════════════════════

print_header "Binaires (dotfiles/bin/)"

check_bin "starship"
check_bin "hx"
check_bin "wezterm"

# ═══════════════════════════════════════════════════════════
# Exposition dans ~/.local/bin/
# ═══════════════════════════════════════════════════════════

print_header "Symlinks ~/.local/bin/"

for name in starship hx wezterm; do
    local_link="$HOME/.local/bin/$name"
    if [ ! -L "$local_link" ]; then
        err "$name absent de ~/.local/bin/ — lancer ./install.sh"
    else
        ok "$name → $(readlink "$local_link")"
    fi
done

# ═══════════════════════════════════════════════════════════
# PATH
# ═══════════════════════════════════════════════════════════

print_header "PATH"

if echo "$PATH" | tr ':' '\n' | grep -q "$HOME/.local/bin"; then
    ok "~/.local/bin dans PATH"
else
    err "~/.local/bin absent du PATH — vérifier exports.zsh"
fi

if echo "$PATH" | tr ':' '\n' | grep -q "$BIN_DIR"; then
    ok "$BIN_DIR dans PATH"
else
    warn "$BIN_DIR absent du PATH (optionnel si ~/.local/bin est présent)"
fi

# ═══════════════════════════════════════════════════════════
# Variables d'environnement
# ═══════════════════════════════════════════════════════════

print_header "Variables d'environnement"

check_env "EDITOR"
check_env "VISUAL"
check_env "HELIX_RUNTIME"
check_env "DOTFILES_DIR"
check_env "STARSHIP_CONFIG"

# Vérifier que HELIX_RUNTIME pointe vers un vrai dossier
if [ -n "${HELIX_RUNTIME:-}" ]; then
    if [ -d "$HELIX_RUNTIME" ]; then
        ok "HELIX_RUNTIME existe"
    else
        err "HELIX_RUNTIME pointe vers un dossier inexistant : $HELIX_RUNTIME"
    fi
fi

# ═══════════════════════════════════════════════════════════
# Polices
# ═══════════════════════════════════════════════════════════

print_header "Polices"

if command -v fc-list &>/dev/null; then
    if fc-list 2>/dev/null | grep -i "monaspace neon" > /dev/null; then
        ok "Monaspace Neon installée"
    else
        err "Monaspace Neon absente — lancer ./install.sh"
    fi
else
    warn "fc-list indisponible — vérification police ignorée"
fi

# ═══════════════════════════════════════════════════════════
# Système de thème
# ═══════════════════════════════════════════════════════════

print_header "Thème"

THEME_FILE="$HOME/.config/theme"
THEME_ENV="$HOME/.config/theme-env"

if [ -f "$THEME_FILE" ]; then
    ok "~/.config/theme = $(cat "$THEME_FILE")"
else
    warn "~/.config/theme absent — lancer : dark ou light"
fi

if [ -f "$THEME_ENV" ]; then
    ok "~/.config/theme-env présent"
else
    warn "~/.config/theme-env absent — lancer : dark ou light"
fi

if [ -f "$DOTFILES_DIR/starship/starship-dark.toml" ]; then
    ok "starship-dark.toml présent"
else
    err "starship-dark.toml manquant"
fi

if [ -f "$DOTFILES_DIR/starship/starship-light.toml" ]; then
    ok "starship-light.toml présent"
else
    err "starship-light.toml manquant"
fi

# ═══════════════════════════════════════════════════════════
# Résumé
# ═══════════════════════════════════════════════════════════

print_header "Résumé"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}Tout est en ordre.${NC}"
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${YELLOW}${BOLD}$WARNINGS avertissement(s), aucune erreur.${NC}"
else
    echo -e "  ${RED}${BOLD}$ERRORS erreur(s), $WARNINGS avertissement(s).${NC}"
    echo ""
    echo -e "  ${CYAN}→${NC} Lancer ${CYAN}./install.sh${NC} pour corriger les erreurs de setup."
fi

echo ""
