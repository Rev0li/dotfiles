#!/usr/bin/env zsh
# Fonctions utilitaires

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

# Affichage arborescence à chaque cd
chpwd() {
    if command -v eza &>/dev/null; then
        eza --tree --level=2 --icons --git-ignore
    else
        ls
    fi
}
