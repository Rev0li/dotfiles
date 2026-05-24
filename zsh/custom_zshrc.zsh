#!/usr/bin/env zsh
# ~/.zshrc (via dotfiles symlink)

# ── Chemins ──────────────────────────────────────────────────

export DOTFILES_DIR="$HOME/dotfiles"
export ZSH_CONFIG_DIR="$DOTFILES_DIR/zsh"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# ── Modules ──────────────────────────────────────────────────

source "$ZSH_CONFIG_DIR/exports.zsh"
source "$ZSH_CONFIG_DIR/styles.zsh"
source "$ZSH_CONFIG_DIR/options.zsh"
source "$ZSH_CONFIG_DIR/aliases.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"

# ── Complétion ───────────────────────────────────────────────

autoload -Uz compinit
compinit

# ── Prompt (Starship) ────────────────────────────────────────

# theme-env définit STARSHIP_CONFIG (dark ou light) ; fallback sur dark
if [ -f "$HOME/.config/theme-env" ]; then
    source "$HOME/.config/theme-env"
else
    export STARSHIP_CONFIG="$DOTFILES_DIR/starship/starship-dark.toml"
fi

if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── Config locale (non versionnée) ───────────────────────────

[ -f "$ZSH_CONFIG_DIR/local.zsh" ] && source "$ZSH_CONFIG_DIR/local.zsh"

# ── FZF ──────────────────────────────────────────────────────

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
