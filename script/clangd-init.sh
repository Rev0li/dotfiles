#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# 🔧 Générateur de compile_flags.txt pour projets C/C++
# Demande à g++ ses chemins réels et génère la config clangd
# Usage : clangd-init [standard] (défaut : c++17)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# ── Standard C++ (argument optionnel) ───────────────────────
STD="${1:-c++17}"

print_header "clangd-init — compile_flags.txt"

# ── Vérifications ───────────────────────────────────────────
if ! command -v g++ &>/dev/null; then
    err "g++ introuvable"
    exit 1
fi
ok "g++ $(g++ --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

if ! command -v clangd &>/dev/null; then
    warn "clangd introuvable dans le PATH — le fichier sera créé quand même"
else
    ok "clangd $(clangd --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
fi

# ── Récupérer les include paths de g++ ──────────────────────
info "Lecture des include paths de g++..."

INCLUDE_PATHS=$(echo | g++ -v -x c++ - 2>&1 \
    | sed -n '/#include <\.\.\.> search starts here:/,/End of search list\./p' \
    | grep '^ ' \
    | tr -d ' ')

if [ -z "$INCLUDE_PATHS" ]; then
    err "Impossible de lire les include paths de g++"
    exit 1
fi

# ── Générer compile_flags.txt ───────────────────────────────
OUTPUT="$(pwd)/compile_flags.txt"

{
    echo "-std=$STD"
    while IFS= read -r path; do
        [ -d "$path" ] && echo "-I$path"
    done <<< "$INCLUDE_PATHS"
} > "$OUTPUT"

ok "compile_flags.txt généré dans $(pwd)"

# ── Afficher le contenu ─────────────────────────────────────
echo ""
echo -e "  ${BOLD}Contenu :${NC}"
while IFS= read -r line; do
    echo -e "    ${CYAN}$line${NC}"
done < "$OUTPUT"

# ── Vérifier stddef.h ───────────────────────────────────────
echo ""
STDDEF_FOUND=0
while IFS= read -r path; do
    if [ -f "$path/stddef.h" ]; then
        ok "stddef.h trouvé dans $path"
        STDDEF_FOUND=1
        break
    fi
done <<< "$INCLUDE_PATHS"

if [ "$STDDEF_FOUND" -eq 0 ]; then
    warn "stddef.h introuvable dans les include paths"
    echo -e "    ${YELLOW}→${NC} Les headers gcc sont peut-être manquants sur cette machine"
    echo -e "    ${YELLOW}→${NC} Essaie : find /usr/lib/gcc -name 'stddef.h' 2>/dev/null"
fi

print_header "Terminé 🔧"

echo ""
echo -e "  Lance ${CYAN}hx ton_fichier.cpp${NC} — clangd chargera automatiquement ce fichier."
echo ""
echo -e "  ${YELLOW}Note :${NC} place compile_flags.txt à la racine du projet,"
echo -e "  pas dans un sous-dossier."
echo ""
