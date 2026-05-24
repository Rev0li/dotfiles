#!/usr/bin/env zsh
# 🎨 Configuration des styles - Version minimaliste

############################
# 🎨 Couleurs de base
############################

export RESET="\033[0m"
export BOLD="\033[1m"
export DIM="\033[2m"

# Couleurs standards
export CYAN="\033[36m"
export WHITE="\033[37m"
export BRIGHT_CYAN="\033[96m"
export BRIGHT_WHITE="\033[97m"

############################
# 🎨 Configuration LS_COLORS
############################

# Couleurs pour ls et tree (dossiers en bleu vif, fichiers en blanc)
export LS_COLORS="di=1;96:fi=0;97:ln=1;93:ex=1;92:*.md=1;95:*.txt=0;94:*.json=1;91:*.py=1;92:*.js=1;93:*.sh=1;91:*.conf=1;95:*.c=1;96:*.h=1;94"

############################
# 📁 Affichage après cd
############################

# Fonction d'affichage sobre avec tree centré (bloc aligné à gauche)
function display_tree_centered() {
    clear  # Nettoyer l'écran avant d'afficher
    
    local term_width=$(tput cols)
    
    # Séparer fichiers normaux et cachés
    local normal_items=()
    local hidden_items=()
    
    # Lister tous les éléments
    for item in *(N) .*(N); do
        # Ignorer . et .. et .git
        if [[ "$item" == "." || "$item" == ".." || "$item" == ".git" ]]; then
            continue
        fi
        
        # Séparer cachés et normaux
        if [[ "$item" == .* ]]; then
            hidden_items+=("$item")
        else
            normal_items+=("$item")
        fi
    done
    
    # Trier les listes (dossiers en premier)
    normal_items=(${(o)normal_items})
    hidden_items=(${(o)hidden_items})
    
    # Construire l'affichage
    local output_lines=()
    local max_lines=$(( ${#normal_items[@]} > ${#hidden_items[@]} ? ${#normal_items[@]} : ${#hidden_items[@]} ))
    
    # Largeur des colonnes (40% pour chaque colonne, 20% pour l'espace)
    local col_width=$(( term_width * 35 / 100 ))
    local spacing="    "  # Espacement entre colonnes
    
    # Ligne d'en-tête si il y a des fichiers cachés
    if [[ ${#hidden_items[@]} -gt 0 ]]; then
        local header=$(printf "\033[2m%-${col_width}s${spacing}%s\033[0m" "Fichiers visibles" "Fichiers cachés")
        output_lines+=("$header")
        output_lines+=("\033[2m$(printf '─%.0s' {1..80})\033[0m")  # Ligne de séparation
    fi
    
    # Construire les lignes
    for ((i=0; i<max_lines; i++)); do
        local left_item=""
        local right_item=""
        
        # Colonne gauche (fichiers normaux)
        if [[ $i -lt ${#normal_items[@]} ]]; then
            local item="${normal_items[$((i+1))]}"
            if [[ -d "$item" ]]; then
                # Dossiers en cyan sobre
                left_item="\033[36m├── ${item}/\033[0m"
            else
                # Fichiers en blanc sobre
                left_item="\033[37m├── ${item}\033[0m"
            fi
        fi
        
        # Colonne droite (fichiers cachés)
        if [[ $i -lt ${#hidden_items[@]} ]]; then
            local item="${hidden_items[$((i+1))]}"
            if [[ -d "$item" ]]; then
                # Dossiers cachés en cyan atténué
                right_item="\033[2;36m├── ${item}/\033[0m"
            else
                # Fichiers cachés en gris
                right_item="\033[2;37m├── ${item}\033[0m"
            fi
        fi
        
        # Calculer la longueur sans codes couleur pour l'alignement
        local clean_left=$(echo -e "$left_item" | sed 's/\x1b\[[0-9;]*[mK]//g')
        local left_len=${#clean_left}
        local padding=$((col_width - left_len))
        
        # Construire la ligne
        if [[ -n "$right_item" ]]; then
            output_lines+=("$(printf "%s%*s%s%s" "$left_item" $padding "" "$spacing" "$right_item")")
        else
            output_lines+=("$left_item")
        fi
    done
    
    # Ajouter le résumé
    local total_dirs=$(find . -maxdepth 1 -type d ! -name '.' | wc -l)
    local total_files=$(find . -maxdepth 1 -type f | wc -l)
    output_lines+=("")
    output_lines+=("\033[2m${total_dirs} directories, ${total_files} files\033[0m")
    
    # Calculer le padding pour centrer le bloc
    local max_len=0
    for line in "${output_lines[@]}"; do
        local clean_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*[mK]//g')
        local line_len=${#clean_line}
        if [[ $line_len -gt $max_len ]]; then
            max_len=$line_len
        fi
    done
    
    local block_padding=$(( (term_width - max_len) / 2 ))
    if [[ $block_padding -lt 0 ]]; then
        block_padding=0
    fi
    
    # Afficher tout avec le même padding
    echo ""
    for line in "${output_lines[@]}"; do
        printf "%*s" $block_padding ""
        echo -e "$line"
    done
    echo ""
}

