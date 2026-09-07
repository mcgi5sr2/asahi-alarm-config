#!/usr/bin/env bash
# install-devtmux.sh — set up the `devtmux` dev-session launcher on this machine.
#
# Links (symlinks, so they track the repo — edit here, changes apply live):
#   scripts/devtmux            -> ~/.local/bin/devtmux      (put on PATH)
#   dotconfig/tmux/tmux.conf   -> ~/.config/tmux/tmux.conf  (mouse + keybinds)
#
# Also installs the runtime dependencies via the system package manager when
# they are missing:
#   required : tmux, yazi   (devtmux and the prefix+e binding both launch yazi)
#   optional : neovim       (recommended; for the yazi -> nvim opener)
#
# Idempotent — safe to re-run. An existing *real* tmux.conf is backed up to
# tmux.conf.bak before being replaced with the symlink.
#
# Usage:  ./scripts/install-devtmux.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${HOME}/.local/bin"
TMUX_CFG_DIR="${HOME}/.config/tmux"

REQUIRED=(tmux yazi)
OPTIONAL=(nvim)

pkg_for() {   # map command name -> package name
    case "$1" in
        nvim) echo neovim ;;
        *)    echo "$1" ;;
    esac
}

detect_pm() {
    for pm in pacman dnf apt-get; do
        command -v "$pm" >/dev/null 2>&1 && { echo "$pm"; return; }
    done
}

install_pkgs() {
    local pm="$1"; shift
    [[ $# -eq 0 ]] && return 0
    echo ":: Installing: $* (via $pm)"
    case "$pm" in
        pacman)  sudo pacman -S --needed --noconfirm "$@" ;;
        dnf)     sudo dnf install -y "$@" ;;
        apt-get) sudo apt-get update && sudo apt-get install -y "$@" ;;
    esac
}

# --- 1. Dependencies -------------------------------------------------------
missing=()
for cmd in "${REQUIRED[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$(pkg_for "$cmd")")
done
for cmd in "${OPTIONAL[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || echo ":: note: optional '$cmd' not found (skipping)"
done

if [[ ${#missing[@]} -gt 0 ]]; then
    pm="$(detect_pm)"
    if [[ -n "$pm" ]]; then
        install_pkgs "$pm" "${missing[@]}"
    else
        echo "!! Missing required deps: ${missing[*]}" >&2
        echo "!! No supported package manager found — install them manually." >&2
        exit 1
    fi
fi

# --- 2. Link the launcher onto PATH ---------------------------------------
mkdir -p "$BIN_DIR"
ln -sfn "${REPO_ROOT}/scripts/devtmux" "${BIN_DIR}/devtmux"
echo ":: Linked ${BIN_DIR}/devtmux -> scripts/devtmux"

# --- 3. Link the tmux config ----------------------------------------------
mkdir -p "$TMUX_CFG_DIR"
target="${TMUX_CFG_DIR}/tmux.conf"
if [[ -e "$target" && ! -L "$target" ]]; then
    cp "$target" "${target}.bak"
    echo ":: Backed up existing tmux.conf -> tmux.conf.bak"
fi
ln -sfn "${REPO_ROOT}/dotconfig/tmux/tmux.conf" "$target"
echo ":: Linked ${target} -> dotconfig/tmux/tmux.conf"

# --- 4. PATH sanity check --------------------------------------------------
case ":${PATH}:" in
    *":${BIN_DIR}:"*) : ;;
    *) echo ":: note: ${BIN_DIR} is not on your PATH — add this to your shell rc:"
       echo "         export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo ":: Done. Run 'devtmux' in a project dir (or 'devtmux <session> <dir>')."
