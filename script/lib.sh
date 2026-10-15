#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Helpers partagés entre install.sh et check-versions.sh.
# Source unique pour éviter que ces fonctions divergent
# (cf. docs/audit-dotfiles-2026-06-14.md, P3).
#
# Prérequis : la variable BIN_DIR doit être définie avant de
# sourcer ce fichier.
# ═══════════════════════════════════════════════════════════

# Retire le préfixe 'v' pour comparer deux numéros de version.
normalize() { echo "$1" | sed 's/^v//'; }

# Dernière release GitHub (tag_name) du dépôt "$1".
# Renvoie une chaîne vide si l'API est indisponible / rate-limited.
latest_release() {
    curl -fsLS "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
        | grep '"tag_name"' \
        | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' \
        || echo ""
}

# Version installée du binaire "$1" dans $BIN_DIR.
# Renvoie "absent" si le binaire n'est pas présent.
installed_version() {
    local bin="$BIN_DIR/$1"
    [ -f "$bin" ] || { echo "absent"; return; }
    case "$1" in
        starship) "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        hx)       "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 ;;
        eza)      "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        *)        echo "?" ;;
    esac
}
