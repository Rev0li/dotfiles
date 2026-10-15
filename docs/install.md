# Installation

## Prérequis

Uniquement des outils Unix standards, sans `sudo` : `zsh`, `curl`, `tar`, `git`,
`unzip`, `fc-cache` (fontconfig). `install.sh` s'arrête et indique ce qui manque.

```bash
git clone https://github.com/Rev0li/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
chsh -s "$(which zsh)"   # si zsh n'est pas déjà ton shell
exec zsh
```

`install.sh` peut être relancé sans risque : ce qui est déjà en place est ignoré,
et une mise à jour est proposée si une nouvelle version d'un binaire existe.

## Ce que fait `install.sh`

### 1. Symlinks de configuration

| Source | Cible |
|---|---|
| `zsh/custom_zshrc.zsh` | `~/.zshrc` |
| `helix/` | `~/.config/helix` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `kitty/padding_watcher.py` | `~/.config/kitty/padding_watcher.py` |
| `kitty/kitty-themes/*.conf` | `~/.config/kitty/kitty-themes/` (seulement si absent) |

Un fichier existant (non-symlink) est d'abord sauvegardé dans
`~/.dotfiles_backup_<date>/`.

### 2. Binaires (dans `bin/`, exposés dans `~/.local/bin/`)

| Outil | Source |
|---|---|
| `starship` | installeur officiel starship.rs |
| `hx` + `helix-runtime/` | release GitHub `helix-editor/helix` |
| `eza` | release GitHub `eza-community/eza` |
| `kitty`, `kitten` | paquet système s'il existe, sinon installeur officiel dans `bin/kitty.app` |

### 3. Police

FantasqueSansM Nerd Font (release `ryanoasis/nerd-fonts`) dans
`~/.local/share/fonts/FantasqueSansMono/`.

### 4. `HELIX_RUNTIME`

Ajouté une fois dans `zsh/exports.zsh` pour pointer vers `bin/helix-runtime/runtime`.

## Après l'installation

```bash
dots doctor                    # tout est-il en place ?
./script/check-versions.sh     # binaires à jour ?
dark                           # ou light / theme
```

- **GNOME** : `./script/shortcut.sh` associe `Super+E` à Kitty.
- **C/C++ avec clangd** : `~/dotfiles/script/clangd-init.sh` dans le projet.

## Mettre à jour

```bash
dots update                    # git pull + install.sh
# Forcer la réinstallation d'un binaire :
rm ~/dotfiles/bin/hx && ./install.sh
```
