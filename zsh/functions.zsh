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

# Remonter d'un niveau
..()   { cd ..      }
# Remonter de 2 niveaux
...()  { cd ../..   }
# Remonter de 3 niveaux
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

# Point d'entrée des dotfiles : dots [help|search|doctor|update|edit]
dots() {
    local cmd="${1:-}"; (( $# )) && shift
    case "$cmd" in
        "")        cd "$DOTFILES_DIR" ;;
        help|h)    "$DOTFILES_DIR/script/dots-help.sh" "$@" ;;
        search|s)
            command -v fzf &>/dev/null || { echo "fzf requis — sinon : dots help <terme>"; return 1; }
            local pick
            pick=$("$DOTFILES_DIR/script/dots-help.sh" --raw \
                | fzf --delimiter='\t' --with-nth=2,3,1 --tabstop=22 \
                      --prompt='dots › ' --header='Entrée : préremplit la commande') || return
            print -z -- "${${pick#*$'\t'}%%$'\t'*}"   # 2e colonne → ligne de commande
            ;;
        doctor)    "$DOTFILES_DIR/script/doctor.sh" ;;
        update)    git -C "$DOTFILES_DIR" pull --ff-only && "$DOTFILES_DIR/install.sh" ;;
        edit)      "${EDITOR:-hx}" "$DOTFILES_DIR" ;;
        *)         echo "Usage : dots [help [terme]|search|doctor|update|edit]"; return 1 ;;
    esac
}
