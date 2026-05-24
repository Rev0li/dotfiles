#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Dotfiles Installer
# - Vérifie les dépendances (zsh, curl, tar)
# - Crée les symlinks de configuration
# - Installe / met à jour les binaires dans dotfiles/bin/
# - Expose les binaires via ~/.local/bin/
# Usage : ./install.sh
# ═══════════════════════════════════════════════════════════

set -euo pipefail

# ── Couleurs ────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Chemins ─────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
BIN_DIR="$DOTFILES_DIR/bin"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ── Dépôts GitHub ───────────────────────────────────────────

STARSHIP_REPO="starship/starship"
HX_REPO="helix-editor/helix"
WEZTERM_REPO="wez/wezterm"
MONASPACE_REPO="githubnext/monaspace"

# ═══════════════════════════════════════════════════════════
# Fonctions utilitaires
# ═══════════════════════════════════════════════════════════

print_header() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════${NC}"
}

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()  { echo -e "  ${RED}✗${NC} $1"; }
skip() { echo -e "  ${BLUE}↷${NC} $1 ${BLUE}(déjà à jour)${NC}"; }

# Backup + symlink
link() {
    local src="$1" dst="$2"
    if [ ! -e "$src" ]; then
        err "Source introuvable : $src"
        return 1
    fi
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backup : $(basename "$dst") → $BACKUP_DIR/"
    fi
    [ -L "$dst" ] && rm "$dst"
    ln -sf "$src" "$dst"
    ok "$(basename "$dst") → $src"
}

# Dernière release GitHub
latest_release() {
    curl -fsLS "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
        | grep '"tag_name"' \
        | sed -E 's/.*"tag_name": "([^"]+)".*/\1/' \
        || echo ""
}

# Binaire présent et exécutable dans bin/
bin_ok() { [ -f "$BIN_DIR/$1" ] && [ -x "$BIN_DIR/$1" ]; }

# Retirer le préfixe 'v' pour comparer
normalize() { echo "$1" | sed 's/^v//'; }

# Version installée du binaire
installed_version() {
    local bin="$BIN_DIR/$1"
    case "$1" in
        starship) "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        hx)       "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 ;;
        wezterm)  "$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 ;;
        *)        echo "?" ;;
    esac
}

# ═══════════════════════════════════════════════════════════
# Fonctions d'installation
# ═══════════════════════════════════════════════════════════

do_install_starship() {
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL "https://starship.rs/install.sh" \
        | sh -s -- --bin-dir "$tmp" -y > /dev/null 2>&1
    mv "$tmp/starship" "$BIN_DIR/starship"
    chmod +x "$BIN_DIR/starship"
    rm -rf "$tmp"
    ok "starship installé ($("$BIN_DIR/starship" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1))"
}

do_install_hx() {
    local version tmp archive extracted
    version=$(latest_release "$HX_REPO")
    tmp=$(mktemp -d)
    archive="helix-${version}-x86_64-linux.tar.xz"
    info "Téléchargement de Helix $version..."
    curl -fsSL \
        "https://github.com/${HX_REPO}/releases/download/${version}/${archive}" \
        -o "$tmp/$archive"
    tar -xf "$tmp/$archive" -C "$tmp"
    extracted=$(find "$tmp" -maxdepth 1 -type d -name "helix-*" | head -1)
    rm -rf "$BIN_DIR/helix-runtime"
    mv "$extracted" "$BIN_DIR/helix-runtime"
    cp "$BIN_DIR/helix-runtime/hx" "$BIN_DIR/hx"
    chmod +x "$BIN_DIR/hx"
    rm -rf "$tmp"
    ok "hx installé ($version)"
}

do_install_wezterm() {
    local version url
    version=$(latest_release "$WEZTERM_REPO")
    url="https://github.com/${WEZTERM_REPO}/releases/download/${version}/WezTerm-${version}-Ubuntu20.04.AppImage"
    info "Téléchargement de WezTerm $version..."
    curl -fsSL "$url" -o "$BIN_DIR/wezterm"
    chmod +x "$BIN_DIR/wezterm"
    cat > "$BIN_DIR/wezterm-gui" << 'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/wezterm" start "$@"
WRAPPER
    cat > "$BIN_DIR/wezterm-mux-server" << 'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/wezterm" cli "$@"
WRAPPER
    chmod +x "$BIN_DIR/wezterm-gui" "$BIN_DIR/wezterm-mux-server"
    ok "wezterm installé ($version)"
}

# ═══════════════════════════════════════════════════════════
# Installe ou propose une mise à jour
# ═══════════════════════════════════════════════════════════

maybe_update() {
    local name="$1" repo="$2"

    if ! bin_ok "$name"; then
        "do_install_$name"
        return
    fi

    local installed latest
    installed=$(installed_version "$name")
    latest=$(latest_release "$repo")

    if [[ "$(normalize "$installed")" == "$(normalize "$latest")" ]]; then
        skip "$name $installed"
        return
    fi

    warn "$name : $installed → $latest disponible"
    printf "    Mettre à jour ? [y/N] "
    read -r answer < /dev/tty
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -f "$BIN_DIR/$name"
        "do_install_$name"
    else
        skip "$name (màj ignorée)"
    fi
}

# ═══════════════════════════════════════════════════════════
# Vérification des dépendances système
# ═══════════════════════════════════════════════════════════

print_header "Vérification des dépendances"

MISSING=0
check_dep() {
    local cmd="$1" hint="${2:-}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd"
    else
        err "$cmd manquant${hint:+ — $hint}"
        MISSING=$((MISSING + 1))
    fi
}

check_dep "zsh"    "sudo apt install zsh"
check_dep "curl"   "sudo apt install curl"
check_dep "tar"    "sudo apt install tar"
check_dep "git"    "sudo apt install git"
check_dep "unzip"  "sudo apt install unzip"
check_dep "fc-cache" "sudo apt install fontconfig"

if [ "$MISSING" -gt 0 ]; then
    echo ""
    err "$MISSING dépendance(s) manquante(s) — installer avant de continuer."
    exit 1
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
    warn "zsh n'est pas ton shell par défaut"
    echo -e "    ${CYAN}→${NC} Pour le changer : chsh -s \$(which zsh)"
fi

# ═══════════════════════════════════════════════════════════
# Préparation des répertoires
# ═══════════════════════════════════════════════════════════

print_header "Préparation des répertoires"

mkdir -p "$LOCAL_BIN" "$HOME/.config" "$HOME/.local/share/fonts" "$BIN_DIR"
ok "Répertoires prêts"

# ═══════════════════════════════════════════════════════════
# Symlinks de configuration
# ═══════════════════════════════════════════════════════════

print_header "Symlinks de configuration"

link "$DOTFILES_DIR/zsh/custom_zshrc.zsh" "$HOME/.zshrc"
link "$DOTFILES_DIR/helix"                "$HOME/.config/helix"
mkdir -p "$HOME/.config/wezterm"
link "$DOTFILES_DIR/wezterm/wezterm.lua"  "$HOME/.config/wezterm/wezterm.lua"

# ═══════════════════════════════════════════════════════════
# Binaires → dotfiles/bin/
# ═══════════════════════════════════════════════════════════

print_header "Binaires → dotfiles/bin/"

maybe_update "starship" "$STARSHIP_REPO"
maybe_update "hx"       "$HX_REPO"
maybe_update "wezterm"  "$WEZTERM_REPO"

# ═══════════════════════════════════════════════════════════
# Exposition dans ~/.local/bin/
# ═══════════════════════════════════════════════════════════

print_header "Exposition dans ~/.local/bin/"

for bin_name in starship hx wezterm wezterm-gui wezterm-mux-server; do
    if [ -f "$BIN_DIR/$bin_name" ] && [ -x "$BIN_DIR/$bin_name" ]; then
        [ -L "$LOCAL_BIN/$bin_name" ] && rm "$LOCAL_BIN/$bin_name"
        if [ -f "$LOCAL_BIN/$bin_name" ] && [ ! -L "$LOCAL_BIN/$bin_name" ]; then
            mkdir -p "$BACKUP_DIR"
            mv "$LOCAL_BIN/$bin_name" "$BACKUP_DIR/"
        fi
        ln -sf "$BIN_DIR/$bin_name" "$LOCAL_BIN/$bin_name"
        ok "$bin_name → ~/.local/bin/$bin_name"
    fi
done

# ═══════════════════════════════════════════════════════════
# Polices → ~/.local/share/fonts/
# ═══════════════════════════════════════════════════════════

print_header "Polices"

if fc-list 2>/dev/null | grep -qi "monaspace neon"; then
    skip "Monaspace Neon"
else
    info "Téléchargement de Monaspace Neon..."
    MONO_VERSION=$(latest_release "$MONASPACE_REPO")
    MONO_TMP=$(mktemp -d)
    MONO_ZIP="monaspace-${MONO_VERSION}.zip"
    curl -fsSL \
        "https://github.com/${MONASPACE_REPO}/releases/download/${MONO_VERSION}/${MONO_ZIP}" \
        -o "$MONO_TMP/$MONO_ZIP"
    unzip -q "$MONO_TMP/$MONO_ZIP" -d "$MONO_TMP"
    find "$MONO_TMP" -name "MonaspaceNeon-*.otf" \
        -exec cp {} "$HOME/.local/share/fonts/" \;
    fc-cache -f "$HOME/.local/share/fonts/" 2>/dev/null
    rm -rf "$MONO_TMP"
    ok "Monaspace Neon installée ($MONO_VERSION)"
fi

# ── HELIX_RUNTIME dans exports.zsh ──────────────────────────
if [ -d "$BIN_DIR/helix-runtime/runtime" ]; then
    if ! grep -q "HELIX_RUNTIME" "$DOTFILES_DIR/zsh/exports.zsh" 2>/dev/null; then
        printf '\nexport HELIX_RUNTIME="%s/bin/helix-runtime/runtime"\n' \
            "$DOTFILES_DIR" >> "$DOTFILES_DIR/zsh/exports.zsh"
        ok "HELIX_RUNTIME ajouté dans exports.zsh"
    fi
fi

# ═══════════════════════════════════════════════════════════
# Résumé
# ═══════════════════════════════════════════════════════════

print_header "Installation terminée"

echo ""
echo -e "  ${GREEN}Prochaines étapes :${NC}"
echo -e "    1. Définir zsh comme shell : ${CYAN}chsh -s \$(which zsh)${NC}"
echo -e "    2. Recharger le shell      : ${CYAN}exec zsh${NC}"
echo -e "    3. Diagnostic complet      : ${CYAN}./script/doctor.sh${NC}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "  ${YELLOW}Backup :${NC} $BACKUP_DIR"
    echo ""
fi
