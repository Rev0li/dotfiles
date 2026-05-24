#!/usr/bin/env bash
# Vérifie les versions installées vs dernières releases GitHub
# Usage : ./script/check-versions.sh

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

declare -A REPOS=(
    ["starship"]="starship/starship"
    ["hx"]="helix-editor/helix"
    ["wezterm"]="wez/wezterm"
)

normalize() { echo "$1" | sed 's/^v//'; }

latest_release() {
    curl -fsLS "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
        | grep '"tag_name"' \
        | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' \
    || echo "?"
}

installed_version() {
    local bin="$DOTFILES_DIR/bin/$1"
    [ -f "$bin" ] || { echo "absent"; return; }
    case "$1" in
        starship) "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        hx)       "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 ;;
        wezterm)  "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        *)        echo "?" ;;
    esac
}

UPDATES=0

echo ""
for tool in starship hx wezterm; do
    installed=$(installed_version "$tool")
    latest=$(latest_release "${REPOS[$tool]}")

    if [[ "$installed" == "absent" ]]; then
        printf "  ${RED}✗${NC} %-10s  absent → %s\n" "$tool" "$latest"
    elif [[ "$(normalize "$installed")" == "$(normalize "$latest")" ]]; then
        printf "  ${GREEN}✓${NC} %-10s  %s\n" "$tool" "$installed"
    else
        printf "  ${YELLOW}⚠${NC} %-10s  %s → %s disponible\n" "$tool" "$installed" "$latest"
        UPDATES=$((UPDATES + 1))
    fi
done

echo ""
if [ "$UPDATES" -gt 0 ]; then
    echo -e "  ${BOLD}→ Lancer ./install.sh pour mettre à jour${NC}"
    echo ""
fi
