#!/usr/bin/env zsh
# Options et comportements Zsh

# ── Navigation ───────────────────────────────────────────────

setopt AUTO_CD            # taper un dossier suffit pour y aller
setopt AUTO_PUSHD         # cd alimente automatiquement la pile de dirs
setopt PUSHD_IGNORE_DUPS  # pas de doublons dans la pile
setopt CDABLE_VARS        # cd vers une variable

# ── Historique ───────────────────────────────────────────────

setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY

# ── Complétion ───────────────────────────────────────────────

setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt MENU_COMPLETE

# ── Hook cd ─────────────────────────────────────────────────

chpwd() {
    eza --tree --level=1 --group-directories-first --color=always 2>/dev/null || ls
}
