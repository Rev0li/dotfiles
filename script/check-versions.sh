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
BIN_DIR="$DOTFILES_DIR/bin"

# Helpers partagés avec install.sh (normalize, latest_release, installed_version)
source "$DOTFILES_DIR/script/lib.sh"

declare -A REPOS=(
    ["starship"]="starship/starship"
    ["hx"]="helix-editor/helix"
    ["eza"]="eza-community/eza"
)

UPDATES=0

echo ""
for tool in starship hx eza; do
    installed=$(installed_version "$tool")
    latest=$(latest_release "${REPOS[$tool]}")
    latest=${latest:-?}

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
