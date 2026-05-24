#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# 🚀 Dotfiles Installer
# - Vérifie les dépendances (zsh, curl, tar...)
# - Crée les symlinks de configuration
# - Télécharge les binaires manquants dans dotfiles/bin/
# - Expose les binaires via ~/.local/bin/
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

# ── Repos GitHub ────────────────────────────────────────────
HX_REPO="helix-editor/helix"
STARSHIP_REPO="starship-rs/starship"
WEZTERM_REPO="wez/wezterm"
MDCAT_REPO="swsnr/mdcat"
CLANGD_REPO="clangd/clangd"

# ═══════════════════════════════════════════════════════════
# 🛠️ Fonctions utilitaires
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
skip() { echo -e "  ${BLUE}↷${NC} $1 ${BLUE}(déjà présent)${NC}"; }

# Backup + symlink
link() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        err "Source introuvable: $src"
        return 1
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backup: $(basename "$dst") → $BACKUP_DIR/"
    fi

    [ -L "$dst" ] && rm "$dst"
    ln -sf "$src" "$dst"
    ok "$(basename "$dst") → $src"
}

# Dernière release GitHub
latest_release() {
    local repo="$1"
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
        | grep '"tag_name"' \
        | sed -E 's/.*"tag_name": "([^"]+)".*/\1/'
}

# Vérifier si un binaire est déjà présent et exécutable dans bin/
bin_ok() {
    local name="$1"
    [ -f "$BIN_DIR/$name" ] && [ -x "$BIN_DIR/$name" ]
}

# ═══════════════════════════════════════════════════════════
# 🔍 Vérification des dépendances système
# ═══════════════════════════════════════════════════════════

print_header "Vérification des dépendances"

MISSING_DEPS=0

check_dep() {
    local cmd="$1"
    local hint="${2:-}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd disponible"
    else
        err "$cmd manquant${hint:+ — $hint}"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
}

# Zsh — obligatoire (le shell cible)
check_dep "zsh"   "sudo apt install zsh  |  brew install zsh"
check_dep "curl"  "sudo apt install curl"
check_dep "tar"   "sudo apt install tar"
check_dep "unzip" "sudo apt install unzip"
check_dep "git"   "sudo apt install git"

if [ "$MISSING_DEPS" -gt 0 ]; then
    echo ""
    err "$MISSING_DEPS dépendance(s) manquante(s) — installer avant de continuer."
    exit 1
fi

# Zsh installé mais pas shell par défaut ?
if [ "$SHELL" != "$(command -v zsh)" ]; then
    warn "zsh n'est pas ton shell par défaut"
    echo -e "    ${CYAN}→${NC} Pour le changer : chsh -s \$(which zsh)"
fi

# ═══════════════════════════════════════════════════════════
# 📁 Préparation des répertoires
# ═══════════════════════════════════════════════════════════

print_header "Préparation des répertoires"

mkdir -p "$LOCAL_BIN"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$BIN_DIR"
ok "Répertoires prêts"

# ═══════════════════════════════════════════════════════════
# 🔗 Symlinks de configuration
# ═══════════════════════════════════════════════════════════

print_header "Symlinks de configuration"

link "$DOTFILES_DIR/zsh/custom_zshrc.zsh" "$HOME/.zshrc"
link "$DOTFILES_DIR/helix"                "$HOME/.config/helix"

mkdir -p "$HOME/.config/wezterm"
link "$DOTFILES_DIR/wezterm/wezterm.lua"  "$HOME/.config/wezterm/wezterm.lua"

# Rendre les scripts .sh du projet exécutables
chmod +x "$DOTFILES_DIR"/*.sh 2>/dev/null || true

# ═══════════════════════════════════════════════════════════
# 📦 Téléchargement des binaires dans dotfiles/bin/
# ═══════════════════════════════════════════════════════════

print_header "Binaires → dotfiles/bin/"

# ── Starship ────────────────────────────────────────────────
if bin_ok "starship"; then
    skip "starship"
else
    info "Téléchargement de starship..."
    STARSHIP_TMP=$(mktemp -d)
    curl -fsSL "https://starship.rs/install.sh" \
        | sh -s -- --bin-dir "$STARSHIP_TMP" -y > /dev/null 2>&1
    mv "$STARSHIP_TMP/starship" "$BIN_DIR/starship"
    chmod +x "$BIN_DIR/starship"
    ok "starship installé"
    rm -rf "$STARSHIP_TMP"
fi

# ── Helix ───────────────────────────────────────────────────
if bin_ok "hx"; then
    skip "hx (helix)"
else
    info "Téléchargement de Helix..."
    HX_VERSION=$(latest_release "$HX_REPO")
    HX_TMP=$(mktemp -d)
    HX_ARCHIVE="helix-${HX_VERSION}-x86_64-linux.tar.xz"
    curl -fsSL \
        "https://github.com/${HX_REPO}/releases/download/${HX_VERSION}/${HX_ARCHIVE}" \
        -o "$HX_TMP/$HX_ARCHIVE"
    tar -xf "$HX_TMP/$HX_ARCHIVE" -C "$HX_TMP"
    HX_EXTRACTED=$(find "$HX_TMP" -maxdepth 1 -type d -name "helix-*" | head -1)
    rm -rf "$BIN_DIR/helix-runtime"
    mv "$HX_EXTRACTED" "$BIN_DIR/helix-runtime"
    cp "$BIN_DIR/helix-runtime/hx" "$BIN_DIR/hx"
    chmod +x "$BIN_DIR/hx"
    ok "hx installé ($HX_VERSION)"
    rm -rf "$HX_TMP"
fi

# ── WezTerm ─────────────────────────────────────────────────
if bin_ok "wezterm"; then
    skip "wezterm"
else
    info "Téléchargement de WezTerm..."
    WEZ_VERSION=$(latest_release "$WEZTERM_REPO")
    WEZ_URL="https://github.com/${WEZTERM_REPO}/releases/download/${WEZ_VERSION}/WezTerm-${WEZ_VERSION}-Ubuntu20.04.AppImage"
    curl -fsSL "$WEZ_URL" -o "$BIN_DIR/wezterm"
    chmod +x "$BIN_DIR/wezterm"
    # Wrappers pour wezterm-gui et wezterm-mux-server
    cat > "$BIN_DIR/wezterm-gui" << 'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/wezterm" start "$@"
WRAPPER
    cat > "$BIN_DIR/wezterm-mux-server" << 'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/wezterm" cli "$@"
WRAPPER
    chmod +x "$BIN_DIR/wezterm-gui" "$BIN_DIR/wezterm-mux-server"
    ok "wezterm installé ($WEZ_VERSION)"
fi

# ── mdcat ───────────────────────────────────────────────────
if bin_ok "mdcat"; then
    skip "mdcat"
else
    info "Téléchargement de mdcat..."
    MDCAT_VERSION=$(latest_release "$MDCAT_REPO")
    MDCAT_TAG="mdcat-${MDCAT_VERSION#v}"
    MDCAT_ARCHIVE="mdcat-${MDCAT_VERSION#v}-x86_64-unknown-linux-gnu.tar.gz"
    MDCAT_TMP=$(mktemp -d)
    curl -fsSL \
        "https://github.com/${MDCAT_REPO}/releases/download/${MDCAT_TAG}/${MDCAT_ARCHIVE}" \
        -o "$MDCAT_TMP/$MDCAT_ARCHIVE"
    tar -xf "$MDCAT_TMP/$MDCAT_ARCHIVE" -C "$MDCAT_TMP"
    MDCAT_BIN=$(find "$MDCAT_TMP" -type f -name "mdcat" | head -1)
    cp "$MDCAT_BIN" "$BIN_DIR/mdcat"
    chmod +x "$BIN_DIR/mdcat"
    ok "mdcat installé ($MDCAT_VERSION)"
    rm -rf "$MDCAT_TMP"
fi

# ── clangd ──────────────────────────────────────────────────
if bin_ok "clangd"; then
    skip "clangd"
else
    info "Téléchargement de clangd..."
    CLANGD_VERSION=$(latest_release "$CLANGD_REPO")
    CLANGD_TMP=$(mktemp -d)
    CLANGD_ARCHIVE="clangd-linux-${CLANGD_VERSION}.zip"
    curl -fsSL \
        "https://github.com/${CLANGD_REPO}/releases/download/${CLANGD_VERSION}/${CLANGD_ARCHIVE}" \
        -o "$CLANGD_TMP/$CLANGD_ARCHIVE"
    unzip -q "$CLANGD_TMP/$CLANGD_ARCHIVE" -d "$CLANGD_TMP"
    CLANGD_BIN=$(find "$CLANGD_TMP" -type f -name "clangd" | head -1)
    cp "$CLANGD_BIN" "$BIN_DIR/clangd"
    chmod +x "$BIN_DIR/clangd"
    ok "clangd installé ($CLANGD_VERSION)"
    rm -rf "$CLANGD_TMP"
fi

# ═══════════════════════════════════════════════════════════
# 🔗 Symlinks binaires → ~/.local/bin/
# ═══════════════════════════════════════════════════════════

print_header "Exposition dans ~/.local/bin/"

EXPOSED_BINS=("starship" "hx" "wezterm" "wezterm-gui" "wezterm-mux-server" "mdcat" "clangd")

for bin_name in "${EXPOSED_BINS[@]}"; do
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

# ── HELIX_RUNTIME dans exports.zsh ──────────────────────────
if [ -d "$BIN_DIR/helix-runtime/runtime" ]; then
    if ! grep -q "HELIX_RUNTIME" "$DOTFILES_DIR/zsh/exports.zsh" 2>/dev/null; then
        printf '\n# Helix runtime\nexport HELIX_RUNTIME="%s/bin/helix-runtime/runtime"\n' \
            "$DOTFILES_DIR" >> "$DOTFILES_DIR/zsh/exports.zsh"
        ok "HELIX_RUNTIME ajouté dans exports.zsh"
    fi
fi

# ═══════════════════════════════════════════════════════════
# ✅ Résumé
# ═══════════════════════════════════════════════════════════

print_header "Installation terminée 🚀"

echo ""
echo -e "  ${GREEN}Prochaines étapes :${NC}"
echo -e "    1. Définir zsh comme shell : ${CYAN}chsh -s \$(which zsh)${NC}"
echo -e "    2. Recharger le shell      : ${CYAN}exec zsh${NC}"
echo -e "    3. Vérifier les versions   : ${CYAN}./check-versions.sh${NC}"
echo -e "    4. Diagnostic complet      : ${CYAN}./doctor.sh${NC}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "  ${YELLOW}📦 Backup :${NC} $BACKUP_DIR"
    echo ""
fi
