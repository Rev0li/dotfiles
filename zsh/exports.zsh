#!/usr/bin/env zsh
# Variables d'environnement

# ═══════════════════════════════════════════════════════════
# 👤 Informations personnelles
# ═══════════════════════════════════════════════════════════

export MAIL="okientzl@student.42lyon.fr"
export USER="okientzl"

# ═══════════════════════════════════════════════════════════
# 📁 Répertoires XDG
# ═══════════════════════════════════════════════════════════

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ═══════════════════════════════════════════════════════════
# 🔧 Configuration des outils
# ═══════════════════════════════════════════════════════════

# Éditeur par défaut (Helix)
export EDITOR="hx"
export VISUAL="hx"
export GIT_EDITOR="hx"

# ═══════════════════════════════════════════════════════════
# 📜 Historique
# ═══════════════════════════════════════════════════════════

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# ═══════════════════════════════════════════════════════════
# 🎨 Couleurs
# ═══════════════════════════════════════════════════════════

# Activer les couleurs pour les commandes
export CLICOLOR=1

# Helix runtime
export HELIX_RUNTIME="${DOTFILES_DIR:-$HOME/dotfiles}/bin/helix-runtime/runtime"
