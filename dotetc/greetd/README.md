# greetd + noctalia-greeter → Umbriel (Ubuntu 26.04 Dell laptop)

How the graphical login on this machine (`ubuntu-dell-laptop` branch) is set
up, so it can be reproduced. Set up **2026-10-13**, replacing SDDM/Plasma.

## What we ended up with

- **greetd** is the login daemon and the system `display-manager`.
- **noctalia-greeter** is the greeter: a minimal greetd greeter with its own
  bundled wlroots compositor (`noctalia-greeter-compositor`) that matches the
  Noctalia shell look. User/password prompt, **session picker (F3)** and
  **colour-scheme picker (F7)**.
- The session it launches is **Umbriel** with the Noctalia shell. niri is not
  packaged for Ubuntu, so this branch is Umbriel-only. Umbriel runs X11 apps
  through plain `xwayland` (not `xwayland-satellite`).
- Plasma and SDDM are removed (only the Plasma desktop itself; KDE apps such
  as Dolphin, Konsole, Kate, Okular, kdialog and KDE Connect stay).

Sessions the greeter lists come from `/usr/share/wayland-sessions/*.desktop`
(`noctalia-greeter sessions` prints them): Umbriel.

## The pieces in this repo

| Repo path | Installs to | What it is |
|-----------|-------------|------------|
| `scripts/setup-ubuntu-noctalia.sh` | — | system setup: Noctalia apt repo, packages, greeter state, greetd config, PAM, display-manager switch |
| `dotetc/greetd/noctalia-greeter.toml` | `/etc/greetd/noctalia-greeter.toml` | the greetd config this machine boots with (see below) |
| `dotconfig/umbriel/config.toml` | `~/.config/umbriel/config.toml` | the Umbriel session config (outputs, binds, startup) |
| `dotconfig/noctalia/settings.toml` | `~/.config/noctalia/settings.toml` | Noctalia shell settings incl. lockscreen layout; **Sync Now** pushes colours/wallpaper/monitors to the greeter |

> `dotetc/` mirrors `/etc/`. Files are copies, not symlinks, per repo
> convention; restoring them needs `sudo`.

## How the greeter is wired

The `noctalia-greeter` package ships a systemd drop-in,
`/usr/lib/systemd/system/greetd.service.d/noctalia-greeter.conf`, that runs
`greetd --config /etc/greetd/noctalia-greeter.toml`. greetd therefore ignores
the stock `/etc/greetd/config.toml` (left as Ubuntu ships it, with `agreety`)
and boots from:

```toml
[terminal]
vt = 7

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "_greetd"
```

`command` **must** be the wrapper `noctalia-greeter-session` (it starts the
bundled compositor and sets `WAYLAND_DISPLAY`); check the path with
`command -v noctalia-greeter-session`. `_greetd` is the unprivileged account
the greetd package creates.

No default session is pinned, so the greeter opens on the **last-used**
session. To force one, append `-- --session umbriel` to `command`.

### PAM / keyrings

`/etc/pam.d/greetd` unlocks **gnome-keyring** at login (`pam_gnome_keyring`,
shipped by Ubuntu). The VPN tray (`scripts/shef-vpn-toggle`) keeps the
university password there via `secret-tool`. The setup script also appends
`pam_kwallet5` lines (backup: `greetd.pre-kwallet`) so KWallet unlocks too for
KDE apps that use it.

## Reproducing on another Ubuntu 26.04 machine

```sh
# 1. System side: Noctalia repo, packages, greeter state, greetd config,
#    PAM, and greetd as display manager (takes effect on next boot)
sudo bash scripts/setup-ubuntu-noctalia.sh

# 2. User configs (copy-based repo)
install -Dm644 dotconfig/umbriel/config.toml   ~/.config/umbriel/config.toml
install -Dm644 dotconfig/noctalia/settings.toml ~/.config/noctalia/settings.toml

# 3. Reboot into the greeter, log in to Umbriel, then optionally match the
#    greeter to the shell palette:
#    Noctalia → Settings → Security → Noctalia Greeter → Sync Now
#    (stages sync.toml + wallpaper into /var/lib/noctalia-greeter/)

# 4. Once happy, remove the Plasma desktop and SDDM. Don't just purge
#    kubuntu-desktop with autoremove: that also takes bluez, LibreOffice,
#    printing, Remmina and PipeWire bits that came in as its dependencies.
#    Purge the Plasma-only packages and apt-mark manual everything else.
```

Verify: `systemctl is-active greetd` = active, and
`readlink -f /etc/systemd/system/display-manager.service` → `greetd.service`.

## Appearance / state that is NOT in git

`/var/lib/noctalia-greeter/` (root-owned) holds the greeter's live state:
`greeter.toml` (declarative: `[output]`, `[cursor]`, `[keyboard]`, `[idle]`,
default session) and `sync.toml` + wallpaper images from **Sync Now**.
Automatic syncing is off (`[shell.greeter_sync] auto_sync = false` in the
Noctalia settings) because it caused polkit password pop-ups; use Sync Now.
See `/usr/share/doc/noctalia-greeter/README.md` and
<https://docs.noctalia.dev/v5/greeter/>. Restart with
`sudo systemctl restart greetd` after changes (this ends the session).

Noctalia settings are layered: `~/.config/noctalia/*.toml` (merged
alphabetically) is the base, and `~/.local/state/noctalia/settings.toml`
(written by the Settings GUI) overrides it key by key. Capture both when
syncing to the repo.

## Troubleshooting quick refs

- Blank/black screen → `journalctl -u greetd` (syslog id `noctalia-greeter`);
  confirm `/var/lib/noctalia-greeter` exists.
- `Failed to spawn client` / `WAYLAND_DISPLAY is not set` → `command` must be
  the full path to `noctalia-greeter-session`.
- Wrong session on boot → last-used wins unless `[session].default` is set in
  `greeter.toml`; `noctalia-greeter sessions` prints exact names.
- Greeter won't come up → `Ctrl+Alt+F3` for a text console; roll back with
  `sudo systemctl disable greetd && sudo systemctl enable sddm` (only while
  SDDM is still installed).
