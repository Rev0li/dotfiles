# Installation

## Prerequisites

Only standard Unix tools required — no `sudo`, no package manager beyond what's already on the machine.

| Tool | Purpose |
|---|---|
| `zsh` | Target shell |
| `curl` | Binary downloads |
| `tar` | Archive extraction |
| `unzip` | clangd extraction |
| `git` | Clone this repo |

---

## Quick start

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

`install.sh` is idempotent — safe to re-run. Already-present binaries in `bin/` are skipped.

---

## What install.sh does

### 1. Dependency check
Verifies `zsh`, `curl`, `tar`, `unzip`, `git` are on `PATH`. Aborts if any are missing.

### 2. Symlinks
| Source | Target |
|---|---|
| `zsh/custom_zshrc.zsh` | `~/.zshrc` |
| `helix/` | `~/.config/helix` |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |

Existing non-symlink files are backed up to `~/.dotfiles_backup_<timestamp>/` before being replaced.

### 3. Binary downloads (into `bin/`)
| Binary | Source |
|---|---|
| `starship` | `starship.rs/install.sh` → temp dir → `bin/` |
| `hx` + `helix-runtime/` | GitHub release tarball (`helix-editor/helix`) |
| `wezterm` | GitHub AppImage (`wez/wezterm`) |
| `mdcat` | GitHub tarball (`swsnr/mdcat`) |
| `clangd` | GitHub zip (`clangd/clangd`) |

All fetched at latest release via the GitHub API.

### 4. `~/.local/bin/` exposure
Symlinks each binary from `bin/` into `~/.local/bin/`. `~/.local/bin` is prepended to `PATH` in `zsh/custom_zshrc.zsh`.

### 5. `HELIX_RUNTIME` injection (one-time)
If not already set in `zsh/exports.zsh`, appends:
```bash
export HELIX_RUNTIME="$DOTFILES_DIR/bin/helix-runtime/runtime"
```

---

## Post-install steps

```bash
chsh -s $(which zsh)        # set zsh as default shell (requires logout)
exec zsh                     # reload current session
./script/check-versions.sh  # verify all binaries are up to date
dark                         # or: light / theme (toggle)
```

For GNOME users wanting `Super+E` → WezTerm:
```bash
./script/setup-wezterm-layout.sh
```

For C/C++ projects using clangd:
```bash
cd /path/to/project
~/dotfiles/script/clangd-init.sh
```

---

## Updating a binary

```bash
rm ~/dotfiles/bin/<tool>        # e.g. bin/hx  (also remove bin/helix-runtime for helix)
./install.sh                    # re-downloads latest
```

---

## Modular installation — recommended evolution

The current `install.sh` is monolithic. A better structure for multi-machine use would split it into independent modules callable individually or via an interactive menu:

```
install/
├── core.sh          # symlinks only (no downloads)
├── helix.sh
├── starship.sh
├── wezterm.sh
├── mdcat.sh
├── clangd.sh
└── install.sh       # orchestrator with interactive menu
```

The orchestrator would present a checklist:

```bash
install.sh
  [x] symlinks (always)
  [x] starship
  [x] helix
  [ ] wezterm       (headless server? skip)
  [ ] mdcat
  [x] clangd
```

Each module would be:
- Idempotent (skip if `bin_ok`)
- Callable standalone: `./install/helix.sh`
- Sourced by the orchestrator for batch install

This makes the installer usable on headless servers (skip wezterm), 42 machines (skip clangd if no C projects), or CI environments (symlinks only).

**Shared lib pattern** — extract the helpers (`ok`, `err`, `bin_ok`, `latest_release`, `link`) into `install/lib.sh` and source it from every module:

```bash
# install/helix.sh
source "$(dirname "$0")/lib.sh"
bin_ok "hx" && { skip "hx"; exit 0; }
# ... download logic
```
