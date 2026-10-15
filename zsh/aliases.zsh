#!/usr/bin/env zsh
# Alias et raccourcis

# ── Fichiers & navigation ────────────────────────────────────

alias ll="ls -lah"
alias la="ls -la"
alias l="ls -l"

if command -v eza &>/dev/null; then
    alias ls="eza --icons"                 # ls → eza (icônes)
    alias ll="eza -lah --icons"            # liste détaillée + fichiers cachés
    alias la="eza -la --icons"             # liste avec fichiers cachés
    alias tree="eza --tree --icons"        # arborescence
fi

if command -v bat &>/dev/null; then
    alias cat="bat --style=plain"          # cat → bat (coloration)
    alias ccat="bat"                       # bat avec numéros de ligne
fi

# ── Git ──────────────────────────────────────────────────────

alias gs="git status"
alias gd="git diff"
alias ga="git add ."                       # ⚠ ajoute TOUT le dossier
alias gc="git commit -m "
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gco="git checkout"
alias gb="git branch"

# ── Système ──────────────────────────────────────────────────

alias c="clear"
alias h="history"
alias src="source ~/.zshrc"                # recharger la config
alias reload="exec zsh"                    # relancer le shell
alias ports="ss -tuln"                     # ports en écoute
alias myip="curl -s ifconfig.me"           # IP publique

# ── Dotfiles ─────────────────────────────────────────────────

alias helix-conf="hx ~/dotfiles/helix/config.toml"
alias starship-conf="hx ~/dotfiles/starship/starship-dark.toml"
alias kitty-conf="hx ~/dotfiles/kitty/kitty.conf"
alias zsh-conf="hx ~/.zshrc"
alias clangd-init="$DOTFILES_DIR/script/clangd-init.sh"

# ── Thème ────────────────────────────────────────────────────

alias dark="$DOTFILES_DIR/script/theme-toggle.sh dark"
alias light="$DOTFILES_DIR/script/theme-toggle.sh light"
alias theme="$DOTFILES_DIR/script/theme-toggle.sh"

# ── Recherche ────────────────────────────────────────────────

alias f="find . -type f -name"             # f "*.md" : chercher un fichier
alias fdir="find . -type d -name"          # chercher un dossier

if command -v rg &>/dev/null; then
    alias grep="rg"                        # ⚠ grep → ripgrep (\grep = original)
fi
