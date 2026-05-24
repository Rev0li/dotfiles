#!/usr/bin/env zsh
# Variables d'environnement

# ── Répertoires XDG ─────────────────────────────────────────

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── Éditeur par défaut ───────────────────────────────────────

export EDITOR="hx"
export VISUAL="hx"
export GIT_EDITOR="hx"

# ── Historique ───────────────────────────────────────────────

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# ── Couleurs ─────────────────────────────────────────────────

export CLICOLOR=1
export LS_COLORS="di=1;96:fi=0;97:ln=1;93:ex=1;92:*.md=1;95:*.txt=0;94:*.json=1;91:*.py=1;92:*.js=1;93:*.sh=1;91:*.conf=1;95:*.c=1;96:*.h=1;94"

# ── Helix runtime ────────────────────────────────────────────

export HELIX_RUNTIME="${DOTFILES_DIR:-$HOME/dotfiles}/bin/helix-runtime/runtime"
