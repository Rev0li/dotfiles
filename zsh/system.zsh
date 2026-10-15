#!/usr/bin/env zsh
# Raccourcis système (Fedora / Hyprland) — chaque bloc ne s'active que si l'outil existe

# ── Paquets (dnf) ────────────────────────────────────────────

if command -v dnf &>/dev/null; then
    alias dnfi="sudo dnf install"
    alias dnfr="sudo dnf remove"
    alias dnfu="sudo dnf upgrade --refresh"
    alias dnfs="dnf search"
fi

# ── Services & logs (systemd) ────────────────────────────────

alias failed="systemctl --failed"
alias jerr="journalctl -b -p err --no-pager"   # erreurs du boot courant
alias jf="journalctl -f"                       # logs en direct

# ── Snapshots (snapper) ──────────────────────────────────────

command -v snapper &>/dev/null && alias snaps="sudo snapper list"

# ── Réseau (tailscale) ───────────────────────────────────────

if command -v tailscale &>/dev/null; then
    alias ts="tailscale status"
    alias tsup="sudo tailscale up"
    alias tsdown="sudo tailscale down"
fi

# ── Bureau (Hyprland / PipeWire) ─────────────────────────────

command -v hyprctl &>/dev/null && alias hreload="hyprctl reload"
command -v wpctl   &>/dev/null && alias audio="wpctl status"
