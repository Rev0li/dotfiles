#!/usr/bin/env zsh
# ~/.zshrc (via dotfiles symlink)
# Configuration Zsh modulaire et épurée

# ═══════════════════════════════════════════════════════════
# 📁 Chemins et variables
# ═══════════════════════════════════════════════════════════

export DOTFILES_DIR="$HOME/dotfiles"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/zsh"

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# ═══════════════════════════════════════════════════════════
# 📜 Chargement des modules
# ═══════════════════════════════════════════════════════════

# Charger tous les modules dans l'ordre
source "$ZSH_CONFIG_DIR/exports.zsh"
source "$ZSH_CONFIG_DIR/styles.zsh"
source "$ZSH_CONFIG_DIR/options.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"

# ═══════════════════════════════════════════════════════════
# 🎨 Complétion et prompt
# ═══════════════════════════════════════════════════════════

# Initialiser la complétion Zsh
autoload -Uz compinit
compinit

# Starship (DOIT être en dernier)
if command -v starship &> /dev/null; then
  export STARSHIP_CONFIG="$DOTFILES_DIR/starship/starship-dark.toml"
  eval "$(starship init zsh)"
fi

# ═══════════════════════════════════════════════════════════
# 🔧 Configuration locale (optionnelle)
# ═══════════════════════════════════════════════════════════

# Charger les configurations locales (non versionnées)
[ -f "$ZSH_CONFIG_DIR/local.zsh" ] && source "$ZSH_CONFIG_DIR/local.zsh"

# FZF si installé
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Thème actif (dark/light) — géré par theme-toggle.sh
[ -f "$HOME/.config/theme-env" ] && source "$HOME/.config/theme-env"
