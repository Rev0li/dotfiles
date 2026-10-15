# dotfiles

Configuration personnelle pour un environnement de développement portable —
fonctionne sur Linux/Ubuntu et environnements sans `sudo` (42, machines partagées).

## Stack

| Outil | Rôle |
|---|---|
| **Zsh** | Shell avec config modulaire |
| **Starship** | Prompt adaptatif (dark / light) |
| **Helix** | Éditeur modal |
| **Kitty** | Terminal principal (Fedora/Hyprland), padding proportionnel |
| **WezTerm** | Terminal GPU-accéléré (alternative, machines sans Kitty) |
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
- Télécharge et installe les binaires dans `bin/` (starship, hx, wezterm, eza)
- Installe la police Monaspace Neon dans `~/.local/share/fonts/`
- Expose les binaires via `~/.local/bin/`

> **Sans `sudo` (42, machines partagées) :** fonctionne nativement.
> WezTerm est téléchargé en AppImage — pas besoin de `libfuse2`.

## Architecture

Le détail de l'architecture — structure des fichiers, ordre de chargement des
modules zsh, système de thème, gestion des binaires et raccourcis WezTerm — est
documenté dans **[CLAUDE.md](CLAUDE.md)**, la source de vérité unique.

### Documentation
- [CLAUDE.md](CLAUDE.md) — architecture détaillée (source de vérité)
- [docs/install.md](docs/install.md) — détail de l'installation
- [docs/](docs/) — rapports d'audit datés

## Thèmes

Switch instantané entre dark et light — affecte WezTerm, Helix et Starship.

```bash
dark     # Tokyo Night + Rose Pine Moon
light    # Tokyo Night Day + Rose Pine Dawn
theme    # toggle automatique
```

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
gs gd ga gc gp gl gco gb
```

### Système (Fedora / Hyprland — `zsh/system.zsh`)

Actifs seulement si l'outil est installé.

```bash
dnfi / dnfr / dnfu / dnfs   # dnf install / remove / upgrade --refresh / search
failed                      # services en échec
jerr / jf                   # erreurs du boot courant / logs en direct
snaps                       # snapshots snapper
ts / tsup / tsdown          # tailscale status / up / down
hreload                     # recharger Hyprland
audio                       # périphériques audio (wpctl status)
```

### Remplacements à connaître

Si l'outil est installé, ces commandes standard sont redirigées :
`ls`/`ll`/`la`/`tree` → **eza**, `cat` → **bat**, `grep` → **rg** (syntaxe ripgrep !).
Pour l'original : `command grep …` ou `\grep …`. Chaque `cd` affiche l'arborescence du dossier.

Les alias propres à la machine (hôtes SSH, contournements d'apps) vont dans
`zsh/local.zsh`, non versionné.

## Mise à jour des binaires

```bash
# Vérifier ce qui est obsolète
./script/check-versions.sh

# Forcer la mise à jour d'un outil
rm ~/dotfiles/bin/hx && ./install.sh

# Diagnostic complet
./script/doctor.sh
```
