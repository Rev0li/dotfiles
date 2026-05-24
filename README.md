# dotfiles

Configuration personnelle pour un environnement de développement portable —
fonctionne sur Linux/Ubuntu et environnements sans `sudo` (42, machines partagées).

## Stack

| Outil | Rôle |
|---|---|
| **Zsh** | Shell avec config modulaire |
| **Starship** | Prompt adaptatif (dark / light) |
| **Helix** | Éditeur modal |
| **WezTerm** | Terminal GPU-accéléré |
| **Monaspace Neon** | Police (installée automatiquement) |

## Installation

```bash
git clone https://github.com/Rev0li/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` s'occupe de tout :

- Vérifie les dépendances (`zsh`, `curl`, `tar`, `git`, `unzip`, `fc-cache`)
- Crée les symlinks de configuration
- Télécharge et installe les binaires dans `bin/` (starship, hx, wezterm)
- Installe la police Monaspace Neon dans `~/.local/share/fonts/`
- Expose les binaires via `~/.local/bin/`

> **Sans `sudo` (42, machines partagées) :** fonctionne nativement.
> WezTerm est téléchargé en AppImage — pas besoin de `libfuse2`.

## Structure

```
dotfiles/
├── bin/                     # Binaires téléchargés (gitignorés)
├── helix/
│   ├── config.toml          # Config Helix (thème, LSP, raccourcis)
│   └── languages.toml       # Surcharges LSP par langage
├── script/
│   ├── check-versions.sh    # Vérifie les mises à jour disponibles
│   ├── clangd-init.sh       # Initialise clangd pour un projet C/C++
│   ├── doctor.sh            # Diagnostic complet de l'environnement
│   └── theme-toggle.sh      # Switch dark / light
├── starship/
│   ├── starship-dark.toml   # Prompt thème sombre
│   └── starship-light.toml  # Prompt thème clair
├── wezterm/
│   └── wezterm.lua          # Config WezTerm (thème, raccourcis, splits)
├── zsh/
│   ├── custom_zshrc.zsh     # Point d'entrée (symlinké → ~/.zshrc)
│   ├── exports.zsh          # Variables d'environnement
│   ├── plugins.zsh          # Oh My Zsh plugins
│   ├── styles.zsh           # Personnalisations visuelles
│   ├── options.zsh          # Comportement du shell (history, chpwd…)
│   ├── aliases.zsh          # Aliases
│   └── functions.zsh        # Fonctions utilitaires
└── install.sh               # Installeur principal
```

## Thèmes

Switch instantané entre dark et light — affecte WezTerm, Helix et Starship.

```bash
dark     # Tokyo Night + Rose Pine Moon
light    # Tokyo Night Day + Rose Pine Dawn
theme    # toggle automatique
```

## Raccourcis WezTerm

| Combinaison | Action |
|---|---|
| `ALT+c` | Split horizontal |
| `ALT+v` | Split vertical |
| `CTRL+←/→/↑/↓` | Naviguer entre panes |
| `SHIFT+ALT+←/→/↑/↓` | Redimensionner un pane |
| `SUPER+e` | Nouvel onglet |
| `SUPER+w` | Fermer le pane |
| `SUPER+r` | Renommer l'onglet |

## Aliases utiles

```bash
# Dotfiles
dots            # cd ~/dotfiles
helix-conf      # éditer la config Helix
wezterm-conf    # éditer la config WezTerm
starship-conf   # éditer la config Starship
zsh-conf        # éditer ~/.zshrc

# Système
src / reload    # recharger le shell
c               # clear
myip            # IP publique
ports           # ports en écoute (ss -tuln)

# Git
gs gd ga gc gp gl gco gb gcb gst
```

## Mise à jour des binaires

```bash
# Vérifier ce qui est obsolète
./script/check-versions.sh

# Forcer la mise à jour d'un outil
rm ~/dotfiles/bin/hx && ./install.sh

# Diagnostic complet
./script/doctor.sh
```
