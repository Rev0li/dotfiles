#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Aide-mémoire généré depuis les fichiers de config :
# alias (aliases.zsh, system.zsh, local.zsh), fonctions (functions.zsh)
# et raccourcis Kitty (kitty.conf). Rien à maintenir à la main :
# un alias ajouté avec un commentaire de section apparaît ici.
#
# Usage : dots-help.sh [terme]   → filtre (nom, description, section)
#         dots-help.sh --raw     → TSV section\tnom\tdescription (pour fzf)
# ═══════════════════════════════════════════════════════════

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
Z="$DOTFILES_DIR/zsh"

# ── Extraction → TSV : section \t nom \t description ─────────

# Alias : la section vient du dernier commentaire « # ── Nom ── »,
# la description du commentaire en fin de ligne, sinon de la commande.
parse_aliases() {
    local file="$1" prefix="$2"
    [ -f "$file" ] || return 0
    awk -v prefix="$prefix" '
        /^# ── / {
            s = $0; sub(/^# ── /, "", s); sub(/ ─+.*$/, "", s); section = s; next
        }
        /alias [A-Za-z0-9_.-]+=/ {
            line = $0
            sub(/^.*alias /, "", line)
            name = line; sub(/=.*/, "", name)
            cmd = line; sub(/^[^=]*=/, "", cmd)
            desc = ""
            if (match(cmd, /[ \t]+# /)) { desc = substr(cmd, RSTART + RLENGTH); cmd = substr(cmd, 1, RSTART - 1) }
            gsub(/^["\x27]|["\x27][ \t]*$/, "", cmd)
            if (desc == "") desc = cmd
            sec = (section == "" ? "Divers" : section)
            printf "%s%s\t%s\t%s\n", prefix, sec, name, desc
        }
    ' "$file"
}

# Fonctions : description = commentaire juste au-dessus. Les fonctions
# internes (_x) et les hooks zsh (chpwd, precmd…) sont ignorés.
parse_functions() {
    local file="$1"
    awk '
        /^#/ && !/^#!/ { c = $0; sub(/^# */, "", c); next }
        /^[A-Za-z.][A-Za-z0-9_.-]*\(\)/ {
            name = $0; sub(/\(\).*/, "", name)
            if (name !~ /^(chpwd|precmd|preexec)$/) printf "Fonctions\t%s\t%s\n", name, c
        }
        { c = "" }
    ' "$file"
}

# Kitty : « map touches action », section = dernier commentaire.
parse_kitty() {
    local file="$DOTFILES_DIR/kitty/kitty.conf"
    [ -f "$file" ] || return 0
    awk '
        /^# ── / { next }
        /^# / { s = $0; sub(/^# */, "", s); section = s; next }
        /^map / {
            keys = $2; $1 = ""; $2 = ""; action = $0; sub(/^ +/, "", action)
            printf "Kitty · %s\t%s\t%s\n", section, keys, action
        }
    ' "$file"
}

collect() {
    printf "dots\tdots\taller dans ~/dotfiles\n"
    printf "dots\tdots help [terme]\tcet aide-mémoire (filtré si terme)\n"
    printf "dots\tdots search\tchercher avec fzf et préremplir la commande\n"
    printf "dots\tdots doctor\tdiagnostic de l'installation\n"
    printf "dots\tdots update\tgit pull + ./install.sh\n"
    printf "dots\tdots edit\touvrir le repo dans \$EDITOR\n"
    parse_aliases   "$Z/aliases.zsh" ""
    parse_functions "$Z/functions.zsh"
    parse_aliases   "$Z/system.zsh"  "Système · "
    parse_aliases   "$Z/local.zsh"   "Local · "
    parse_kitty
}

# ── Sortie ───────────────────────────────────────────────────

if [ "${1:-}" = "--raw" ]; then
    collect
    exit 0
fi

filter="${1:-}"

if [ -t 1 ]; then
    B=$'\033[1m'; C=$'\033[0;36m'; G=$'\033[0;32m'; D=$'\033[2m'; N=$'\033[0m'
else
    B=""; C=""; G=""; D=""; N=""
fi

# Un alias redéfini (ex. ll fallback puis ll → eza) : seule la dernière définition compte
collect | awk -F'\t' '{ k = $1 FS $2; if (!(k in row)) order[++n] = k; row[k] = $0 }
                      END { for (i = 1; i <= n; i++) print row[order[i]] }' \
    | awk -F'\t' -v f="$filter" -v B="$B" -v C="$C" -v G="$G" -v D="$D" -v N="$N" '
    BEGIN { f = tolower(f) }
    f != "" && index(tolower($0), f) == 0 { next }
    {
        if ($1 != last) { printf "\n%s%s%s\n", B C, $1, N; last = $1 }
        printf "  %s%-20s%s %s%s%s\n", G, $2, N, D, $3, N
        n++
    }
    END {
        if (n == 0) printf "Aucun résultat pour « %s »\n", f
        else if (f == "") printf "\n%sFiltrer : dots help <terme>  ·  Chercher : dots search%s\n", D, N
    }
'
