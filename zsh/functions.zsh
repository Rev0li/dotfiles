#!/usr/bin/env zsh
# Fonctions utilitaires

# Restaure le curseur beam après qu'une app (ex: Helix) l'ait changé
_reset_cursor() { printf '\e[5 q'; }
precmd_functions+=(_reset_cursor)

# Créer un répertoire et y entrer
mkcd() {
    [[ -z "$1" ]] && { echo "Usage: mkcd <dir>"; return 1; }
    mkdir -p "$1" && cd "$1"
}

# Remonter de N niveaux (défaut : 1)
up() {
    local levels=${1:-1} path=""
    for ((i=0; i<levels; i++)); do path="../$path"; done
    cd "$path"
}

# Raccourcis navigation
..()   { cd ..      }
...()  { cd ../..   }
....() { cd ../../.. }

# Affichage arborescence à chaque cd (shell interactif uniquement :
# sinon les scripts et outils qui lancent zsh -c affichent/bloquent)
chpwd() {
    [[ -o interactive && -t 1 ]] || return
    if command -v eza &>/dev/null; then
        eza --tree --level=1 --icons --git-ignore
    else
        ls
    fi
}
