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

# ── SSH ──────────────────────────────────────────────────────

# Se connecter à un serveur avec un nom court (« ssh monserveur ») :
# déclarer l'hôte une fois dans ~/.ssh/config (jamais versionné, il reste privé) :
#
#   Host monserveur                  # nom court à taper
#       HostName 203.0.113.10        # IP ou domaine
#       User moi
#       Port 22
#       IdentityFile ~/.ssh/ma_cle   # clé privée (créée avec ssh-keygen)
#
# Puis, si tu veux encore plus court, ajouter un alias ici ou dans local.zsh :
#   alias srv="kitten ssh monserveur"
# kitten ssh = ssh qui emporte la config du terminal Kitty sur le serveur.
# Préfixer par TERM=xterm-256color si le serveur ne connaît pas « xterm-kitty »
# (erreurs d'affichage, touches qui ne marchent pas : c'est le cas du NAS Synology).

alias nas="TERM=xterm-256color kitten ssh nas-songsurf"   # NAS Synology (Host nas-songsurf dans ~/.ssh/config)

# ── Recherche ────────────────────────────────────────────────

alias f="find . -type f -name"             # f "*.md" : chercher un fichier
alias fdir="find . -type d -name"          # chercher un dossier

if command -v rg &>/dev/null; then
    alias grep="rg"                        # ⚠ grep → ripgrep (\grep = original)
fi
