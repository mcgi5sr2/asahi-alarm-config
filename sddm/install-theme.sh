#!/usr/bin/env bash
# Install the custom "250956" sddm-astronaut-theme variant — a warm-amber
# palette matching the hyprlock lock screen.
#
# Vendors:
#   sddm-astronaut-theme/Themes/250956.conf      custom theme config
#   sddm-astronaut-theme/Backgrounds/250956.mp4  background video
#   sddm.conf                                    selects the theme in sddm
#
# The base sddm-astronaut-theme is large and lives upstream; this script
# clones the fork if the base theme isn't already installed, then overlays
# the custom config on top. Uses sudo for the system paths under
# /usr/share/sddm and /etc.
#
# Usage:  ./install-theme.sh
set -euo pipefail

THEME_NAME="sddm-astronaut-theme"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
FORK_REPO="https://github.com/mcgi5sr2/sddm-astronaut-theme.git"
FORK_BRANCH="dev-new-themes"

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${BASE}/${THEME_NAME}"

# 1. Ensure the base theme exists; clone the fork if it doesn't.
if [[ ! -d "$THEME_DIR" ]]; then
    echo ":: Base theme missing — cloning fork ($FORK_BRANCH)…"
    tmp="$(mktemp -d)"
    git clone --depth 1 --branch "$FORK_BRANCH" "$FORK_REPO" "$tmp/theme"
    rm -rf "$tmp/theme/.git"
    sudo mkdir -p "$(dirname "$THEME_DIR")"
    sudo cp -r "$tmp/theme" "$THEME_DIR"
    rm -rf "$tmp"
fi

# 2. Overlay the custom theme config + background.
echo ":: Installing 250956 theme overlay…"
sudo install -Dm644 "$SRC_DIR/Themes/250956.conf"     "$THEME_DIR/Themes/250956.conf"
sudo install -Dm644 "$SRC_DIR/Backgrounds/250956.mp4" "$THEME_DIR/Backgrounds/250956.mp4"

# 3. Point the theme's metadata at our variant.
echo ":: Selecting Themes/250956.conf in metadata.desktop…"
sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/250956.conf|' "$THEME_DIR/metadata.desktop"

# 4. Make sddm use the theme (back up any existing /etc/sddm.conf first).
if [[ -f /etc/sddm.conf ]]; then
    sudo cp /etc/sddm.conf /etc/sddm.conf.bak
fi
echo ":: Setting sddm Current theme in /etc/sddm.conf…"
sudo install -Dm644 "$BASE/sddm.conf" /etc/sddm.conf

echo ":: Done. Preview without logging out:"
echo "   sddm-greeter-qt6 --test-mode --theme $THEME_DIR"
