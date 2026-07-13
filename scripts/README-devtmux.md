# devtmux

A tiny tmux launcher for a two-pane dev layout: a [yazi](https://yazi-rs.github.io)
file-tree pane on the left and your shell on the right. Mouse and sensible
keybinds come from the bundled `tmux.conf`.

```
┌──────────┬───────────────────────────────┐
│  yazi    │  shell                         │
│  (tree)  │  $                             │
│          │                                │
└──────────┴───────────────────────────────┘
```

## Requirements

| Tool     | Role                                             |
|----------|--------------------------------------------------|
| `tmux`   | the multiplexer                                  |
| `yazi`   | file-tree pane (required — `devtmux` launches it)|
| `neovim` | optional; for the yazi → nvim opener             |

The install script installs any missing required tools via the detected package
manager (`pacman` / `dnf` / `apt-get`).

## Install

From the repo root:

```bash
./scripts/install-devtmux.sh
```

This symlinks (so edits in the repo apply live):

- `scripts/devtmux` → `~/.local/bin/devtmux` (must be on your `PATH`)
- `dotconfig/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`

It's idempotent — safe to re-run. An existing real `~/.config/tmux/tmux.conf`
is backed up to `tmux.conf.bak` before being replaced with the symlink.

## Usage

```bash
devtmux                    # session "dev", tree rooted at the current dir
devtmux api                # named session "api", current dir
devtmux api ~/projects/api # named session "api", rooted at a specific dir
```

- If the session already exists, `devtmux` attaches to it (or switches, if
  you're already inside tmux) instead of creating a duplicate.
- Tree width defaults to 30 columns; override with `DEVTMUX_TREE_WIDTH`:

  ```bash
  DEVTMUX_TREE_WIDTH=40 devtmux
  ```

## Keybinds

Prefix is the tmux default, `C-b`.

| Keys           | Action                                        |
|----------------|-----------------------------------------------|
| `prefix` `e`   | toggle a yazi file-tree pane on the left      |
| `prefix` `r`   | reload `tmux.conf`                            |
| `prefix` `\|`  | split horizontally (keeps current dir)        |
| `prefix` `-`   | split vertically (keeps current dir)          |

Mouse is on: click panes, drag borders to resize, scroll to page back.

## Uninstall

```bash
rm ~/.local/bin/devtmux ~/.config/tmux/tmux.conf
# restore a previous config if you had one:
# mv ~/.config/tmux/tmux.conf.bak ~/.config/tmux/tmux.conf
```
