# dotfiles

Environnement de dev portable : **zsh + Starship + Helix + Kitty**.
Fonctionne sur n'importe quel Linux (Fedora, Ubuntu…), y compris **sans `sudo`**
(42, machines partagées) : tout s'installe dans le repo et `~/.local/`.

## Démarrer en 2 minutes

```bash
git clone https://github.com/Rev0li/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
exec zsh
dots help          # ← tout ce que cet environnement sait faire
```

> **Tu découvres cet environnement ?** Retiens une seule commande : `dots help`.
> Elle liste les alias, fonctions et raccourcis Kitty, générés directement depuis
> les fichiers de config (donc toujours à jour). `dots search` fait pareil avec fzf
> et préremplit la commande choisie.

## La commande `dots`

| Commande | Effet |
|---|---|
| `dots` | aller dans `~/dotfiles` |
| `dots help [terme]` | aide-mémoire (filtré : `dots help git`, `dots help kitty`) |
| `dots search` | recherche fzf, Entrée préremplit la commande |
| `dots doctor` | diagnostic de l'installation |
| `dots update` | `git pull` + `./install.sh` |
| `dots edit` | ouvrir le repo dans `$EDITOR` |

## ⚠ Ce qui ne se comporte pas comme d'habitude

Si l'outil est installé, ces commandes standard sont **redirigées** :

| Tu tapes | Tu obtiens | Original |
|---|---|---|
| `ls`, `ll`, `la`, `tree` | eza (icônes) | `\ls` |
| `cat` | bat (coloration) | `\cat` |
| `grep` | **ripgrep** — syntaxe différente ! | `\grep` |
| `cd` | affiche l'arborescence du dossier | — |
| `ga` | `git add .` (tout le dossier) | `git add <fichier>` |

## Stack

| Outil | Rôle | Config |
|---|---|---|
| **Kitty** | Terminal (padding proportionnel, splits) | `kitty/` |
| **Zsh** | Shell modulaire | `zsh/` |
| **Starship** | Prompt (dark / light) | `starship/` |
| **Helix** | Éditeur modal (`$EDITOR`) | `helix/` |
| **eza, bat, rg, fzf** | Remplaçants modernes de ls, cat, grep | — |

Police : **FantasqueSansM Nerd Font** (installée par `install.sh`).

## Kitty — raccourcis principaux

| Touches | Action |
|---|---|
| `Alt+c` / `Alt+v` | split horizontal / vertical |
| `Ctrl+flèches` | changer de pane |
| `Shift+Alt+flèches` | redimensionner |
| `Super+e` | nouvel onglet |
| `Alt+q` | fermer le pane |

Le padding s'adapte à la taille de la fenêtre (7 % / 3 %) : réglable via
`PAD_H` / `PAD_V` dans `kitty/padding_watcher.py`.

## Thèmes

```bash
dark     # Tokyo Night (Kitty) + Rose Pine Moon (Helix)
light    # Tokyo Night Day (Kitty) + Rose Pine Dawn (Helix)
theme    # bascule
```

Kitty se recharge tout seul ; Starship au prochain shell.

## Personnaliser sans casser le repo

- **Config propre à ta machine** (hôtes SSH, contournements d'apps) :
  `zsh/local.zsh` — non versionné, chargé automatiquement. Une ligne
  `# ── Section ──` au-dessus de tes alias les range dans `dots help`.
- **Raccourcis système** (dnf, systemd, tailscale, Hyprland…) : `zsh/system.zsh`,
  chaque bloc ne s'active que si l'outil existe.

## Documentation

- [docs/install.md](docs/install.md) — ce que fait `install.sh`, mise à jour des binaires
- [CLAUDE.md](CLAUDE.md) — architecture détaillée
- [docs/](docs/) — rapports d'audit datés
