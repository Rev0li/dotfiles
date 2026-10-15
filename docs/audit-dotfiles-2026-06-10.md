# Audit des dotfiles — 2026-06-10

> Audit réalisé par Claude Code. Structure globale saine (modularité zsh,
> installation sans sudo, système de thème cohérent, démarrage shell en 0,03 s).
> Les vrais problèmes sont côté hygiène git.

---

## 🔴 Sécurité / hygiène git

### 1. `discord/`, `pulse/` et `Electron/` n'ont rien à faire dans `~/dotfiles`

- `discord/` contient des `Cookies`, `Trust Tokens` et `Local State` — un profil
  Discord complet, avec potentiellement le token de session.
- Gitignoré aujourd'hui, mais accident en attente : il suffit qu'une ligne du
  `.gitignore` saute.
- `Electron/` n'est **pas** dans le `.gitignore` — vide pour l'instant, mais dès
  qu'un fichier y atterrit il sera stageable par l'alias `ga` (`git add .`).

**Recommandation :** déplacer ces dossiers hors du repo (ils appartiennent à
`~/.config/`). Si `discord/settings.json` ou `quotes.json` méritent d'être
versionnés, ne garder que ces fichiers-là.

### 2. `pulse/cookie` est dans l'historique git d'un repo GitHub public

- Commité par le passé (commits `7254df6` → `4069329`) puis supprimé, mais
  toujours récupérable dans l'historique de `github.com/Rev0li/dotfiles`.
- Cookie d'authentification PulseAudio — criticité faible (local/réseau
  uniquement), mais le principe est mauvais.

**Recommandation :** régénérer le cookie en supprimant `~/.config/pulse/cookie`
(recréé automatiquement).

### 3. `.git` pèse 99 Mo

L'historique contient d'anciens binaires : `wezterm-gui` (74 Mo), kitty, nvim…

**Recommandation :**
```bash
git filter-repo --path wezterm/bin --path kitty --path nvim --path pulse --invert-paths
```
Purge tout (y compris le cookie du point 2) en une passe — mais c'est une
réécriture d'historique : force-push et re-clone obligatoires.

### 4. `bin/eza` est tracké alors que la politique est « binaires gitignorés »

Un binaire de 2,5 Mo est commité, contrairement à starship/hx/wezterm.
Le `.gitignore` liste les binaires un par un — fragile.

**Recommandation :** ignorer `bin/*` (avec exceptions `!bin/*.sh` si besoin),
puis `git rm --cached bin/eza`.

---

## 🟠 Bugs et code mort

### 5. `chpwd()` défini deux fois

- `zsh/options.zsh:29` **et** `zsh/functions.zsh:23`.
- `functions.zsh` est chargé en dernier : sa version gagne (avec `--git-ignore`,
  sans `--group-directories-first`) ; celle d'`options.zsh` est du code mort.

**Recommandation :** supprimer la définition dans `options.zsh` (un hook `cd`
n'est pas une « option »).

### 6. `wezterm cli reload-configuration` n'existe pas

- `script/theme-toggle.sh:111` — sous-commande inconnue de WezTerm (vérifié).
- L'erreur est avalée par `2>/dev/null` ; on tombe toujours sur le message
  « appuyer sur Ctrl+Shift+R ».

**Recommandation :** WezTerm recharge automatiquement `wezterm.lua` quand le
fichier change (mais pas `~/.config/theme`). Un
`touch ~/.config/wezterm/wezterm.lua` à la fin du script déclenche le reload.

### 7. `export STARSHIP_CONFIG` dans theme-toggle.sh est sans effet

- `script/theme-toggle.sh:97` — le script tourne dans un sous-shell : l'export
  ne remonte jamais dans le shell parent. Le prompt ne change qu'après
  `src`/`reload`.

**Recommandation :** transformer les alias `dark`/`light` en fonctions zsh qui
sourcent `~/.config/theme-env` après l'exécution du script.

### 8. Le `sed` de theme-toggle salit le repo

- `helix/config.toml` est versionné et symlinké : chaque bascule dark/light crée
  un diff git (`theme = ...` modifié en place).

**Recommandation :** choisir un thème par défaut versionné puis
`git update-index --skip-worktree helix/config.toml` — ou accepter le diff en
connaissance de cause.

---

## 🟡 Documentation désynchronisée

CLAUDE.md et README décrivent un état qui n'existe plus :

- **`zsh/plugins.zsh` n'existe pas** — l'ordre de chargement annoncé
  « exports → plugins → styles… » est faux, `custom_zshrc.zsh` ne le source pas.
- **Le layout WezTerm « 3 panes au gui-startup »** décrit dans CLAUDE.md n'est
  pas dans `wezterm.lua` — aucun handler `gui-startup`.
- **mdcat et clangd** sont décrits comme installés/symlinkés par `install.sh`,
  mais le script ne gère que starship, hx, wezterm et eza.
- **`check-versions.sh` ne couvre pas eza** alors qu'`install.sh` l'installe.
- `latest_release` / `installed_version` / `normalize` sont dupliquées entre
  `install.sh` et `check-versions.sh` — une lib commune `script/lib.sh`
  éviterait qu'elles divergent encore.

---

## 🟢 Améliorations suggérées

- **Aucun plugin zsh** : pas d'autosuggestions ni de coloration syntaxique.
  `zsh-autosuggestions` et `zsh-syntax-highlighting` s'installent par simple
  `git clone` (compatible sans-sudo 42), sourcés depuis un vrai `plugins.zsh` —
  ce qui réconcilierait la doc au passage.
- **`alias grep="rg"`** : flags incompatibles avec grep (`-r`, `-P`, etc.) —
  piège garanti en copiant une commande. Garder `grep` intact, taper `rg`
  directement.
- **`install.sh`** : pas de vérification de checksum sur les téléchargements,
  architecture `x86_64` codée en dur, `read < /dev/tty` casse toute exécution
  non-interactive (un flag `--yes` réglerait ce point).
- **Historique shell** : `HISTSIZE=10000` est vite plein ; passer à 100000 ne
  coûte rien. Historique long + fzf (Ctrl+R) = précieux.
- **`maybe_update` interroge l'API GitHub sans token** : limite anonyme de
  60 requêtes/heure — sur réseau partagé (42), `latest_release` peut renvoyer
  vide silencieusement. Ajouter un fallback explicite « API rate-limited ».

---

## ✅ Ce qui est bien (à garder tel quel)

- Découpage modulaire zsh.
- Approche `bin/` + `~/.local/bin/` sans sudo.
- Backup automatique avant symlink dans `install.sh`.
- `set -euo pipefail` partout.
- Système de thème unifié sur trois outils.
- Wrapper AppImage WezTerm qui évite `libfuse2`.
- Démarrage zsh à 0,03 s : la simplicité paie.
