# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Portable development environment (zsh + Starship + Helix + Kitty) for any Linux (Fedora, Ubuntu…) including sudo-less environments (42, shared machines). All binaries are downloaded to `bin/` (gitignored) and exposed via `~/.local/bin/` symlinks — no system-wide installation needed.

## Key Commands

```bash
./install.sh                   # Full setup: symlinks + binary downloads
./script/check-versions.sh     # Compare installed vs latest GitHub releases
./script/doctor.sh             # Full environment diagnostic
./script/theme-toggle.sh       # Toggle dark/light (or pass "dark"/"light")
./script/clangd-init.sh        # Initialize clangd for a C/C++ project
./script/shortcut.sh           # Register GNOME keybinding Super+E → Kitty
./script/dots-help.sh [term]   # Cheatsheet (= `dots help`), --raw for TSV
```

To update a binary: delete `bin/<tool>` then re-run `./install.sh`.

## Architecture

### Symlinks created by install.sh
| Source | Target |
|---|---|
| `zsh/custom_zshrc.zsh` | `~/.zshrc` |
| `helix/` | `~/.config/helix` |
| `kitty/kitty.conf`, `kitty/padding_watcher.py` | `~/.config/kitty/` (only terminal supported) |
| `kitty/kitty-themes/*.conf` | `~/.config/kitty/kitty-themes/` (only if absent — never overwrites) |
| `bin/<tool>` | `~/.local/bin/<tool>` (starship, hx, eza, kitty, kitten — kitty only if no system package) |

### Zsh module load order
`custom_zshrc.zsh` sources these in sequence: `exports.zsh` → `styles.zsh` → `options.zsh` → `aliases.zsh` → `functions.zsh` → `system.zsh` (Fedora/Hyprland shortcuts: dnf, systemd, snapper, tailscale, hyprctl, wpctl — each guarded by `command -v`). Starship init must stay last. Machine-local config (personal hosts, app workarounds) goes in `zsh/local.zsh` (not versioned). The `chpwd` hook (tree on every cd) only runs in interactive shells.

### Kitty padding
`kitty/padding_watcher.py` is a Kitty watcher (`watcher` option) that sets padding as a % of the window size on every resize (`PAD_H`, `PAD_V` at the top of the file). The fixed `window_padding_width` in `kitty.conf` is the fallback.

### Theme system
`script/theme-toggle.sh` writes `"dark"` or `"light"` to `~/.config/theme` and updates `~/.config/theme-env` (sourced by zsh for `STARSHIP_CONFIG`). Kitty: the script writes `~/.config/kitty/theme.conf` (`include kitty-themes/<Theme>.conf`), pulled in by `globinclude theme.conf` in `kitty.conf`, then reloads all Kitty instances with `SIGUSR1`. Helix config is patched in-place via `sed`. Two Starship configs: `starship/starship-dark.toml` and `starship/starship-light.toml`.

**Dark:** Tokyo Night (Kitty) + Rose Pine Moon (Helix)  
**Light:** Tokyo Night Day (Kitty) + Rose Pine Dawn (Helix)

### Kitty key bindings
Defined in `kitty/kitty.conf`: `ALT+c` hsplit, `ALT+v` vsplit, `CTRL+arrows` navigate panes, `SHIFT+ALT+arrows` resize, `SUPER+e` new tab, `SUPER+w` close (confirm), `ALT+q` close.

### `dots` command and cheatsheet
`dots` is a zsh function in `functions.zsh` (`help`, `search`, `doctor`, `update`, `edit`; no arg = cd). `script/dots-help.sh` builds the cheatsheet by parsing files — keep these conventions so entries show up correctly:
- Aliases (`aliases.zsh`, `system.zsh`, `local.zsh`): section = last `# ── Name ──` header; description = trailing `# comment` on the alias line, else the command itself.
- Functions (`functions.zsh`): description = the comment line directly above `name() {`. Names starting with `_` and zsh hooks are skipped.
- Kitty: `map` lines, section = last plain `# comment` above them.

### Binary management
`install.sh` fetches latest releases from GitHub via the API (`latest_release()` helper). Helix ships a `helix-runtime/` directory alongside its binary — `HELIX_RUNTIME` env var in `exports.zsh` must point to `bin/helix-runtime/runtime`. Kitty uses the system package when present, else the official installer into `bin/kitty.app`. Font: FantasqueSansM Nerd Font (nerd-fonts release).
