#!/usr/bin/env bash
# System-level setup for Noctalia + Umbriel + greetd/noctalia-greeter on
# Ubuntu 26.04 (resolute). Run from the repo root:
#
#   sudo bash scripts/setup-ubuntu-noctalia.sh
#
# Idempotent. It enables greetd as the display manager but does NOT stop the
# current one — that would kill the running desktop session. The switch takes
# effect on the next reboot. Plasma (or any other session in
# /usr/share/wayland-sessions) stays selectable from the greeter (F3).
#
# Rollback: sudo systemctl disable greetd && sudo systemctl enable sddm
#           (or from a TTY, Ctrl+Alt+F3, if the greeter won't come up).
#
# User-level configs (~/.config/umbriel, ~/.config/noctalia, ...) are copied
# separately — see dotetc/greetd/README.md.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }
cd "$(dirname "$0")/.."
. /etc/os-release
[[ $VERSION_CODENAME == resolute ]] || echo "warning: written for Ubuntu 26.04 (resolute), this is $VERSION_CODENAME" >&2

# 1. Noctalia apt repo (https://docs.noctalia.dev/umbriel/installation/).
#    Flat repo: noctalia/xdg-desktop-portal-umbriel in resolute/,
#    umbriel/noctalia-greeter/libwlroots-0.20 in resolute-backports/.
if [[ ! -f /usr/share/keyrings/nickh-archive-keyring.gpg ]]; then
    tmp=$(mktemp -d)
    wget -qO "$tmp/nickh-archive-keyring.deb" https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb
    dpkg -i "$tmp/nickh-archive-keyring.deb"
    rm -rf "$tmp"
fi
wget -qO /etc/apt/sources.list.d/noctalia-resolute.sources \
    https://pkg.noctalia.dev/deb/noctalia-resolute.sources

# 2. Packages. niri is not packaged for Ubuntu, so this machine runs Umbriel.
#    xwayland (not xwayland-satellite) is what umbriel uses for X11 clients.
apt-get update
apt-get install -y \
    noctalia umbriel xdg-desktop-portal-umbriel xwayland \
    greetd noctalia-greeter \
    kitty playerctl upower wtype

# 3. Greeter system state (state dir, greeter user, PAM) — the package ships
#    the setup scripts; only needed if the state dir is missing.
if [[ ! -d /var/lib/noctalia-greeter ]]; then
    setup=$(dpkg -L noctalia-greeter | grep -m1 'setup_greeter_system\.sh$' || true)
    if [[ -n $setup ]]; then bash "$setup"
    else echo "warning: /var/lib/noctalia-greeter missing and no setup_greeter_system.sh shipped" >&2; fi
fi

# 4. greetd config. The noctalia-greeter package's systemd drop-in runs
#    greetd --config /etc/greetd/noctalia-greeter.toml.
install -Dm644 dotetc/greetd/noctalia-greeter.toml /etc/greetd/noctalia-greeter.toml
session=$(command -v noctalia-greeter-session || true)
grep -q "command = \"$session\"" /etc/greetd/noctalia-greeter.toml \
    || echo "warning: noctalia-greeter-session is at '$session', not what noctalia-greeter.toml says" >&2
systemctl cat greetd.service | grep -q noctalia-greeter.toml \
    || echo "warning: greetd drop-in not found — greetd would ignore noctalia-greeter.toml" >&2

# 5. KWallet auto-unlock at login, as SDDM did for Plasma (/etc/pam.d/sddm).
if [[ -f /etc/pam.d/greetd ]] && ! grep -q pam_kwallet5 /etc/pam.d/greetd; then
    cp /etc/pam.d/greetd /etc/pam.d/greetd.pre-kwallet
    printf '%s\n' '-auth   optional        pam_kwallet5.so' \
                  '-session optional       pam_kwallet5.so auto_start' >> /etc/pam.d/greetd
fi

# 6. Display manager: greetd on next boot, SDDM off. No --now (see header).
systemctl disable sddm.service
systemctl enable --force greetd.service
echo /usr/sbin/greetd > /etc/X11/default-display-manager

echo
echo "display-manager -> $(readlink -f /etc/systemd/system/display-manager.service)"
echo "Sessions the greeter will offer:"; ls /usr/share/wayland-sessions/
echo "Done. Copy the user configs, then reboot."
