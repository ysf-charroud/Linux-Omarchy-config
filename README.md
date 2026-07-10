# Linux Omarchy config

My [Omarchy](https://omarchy.org/) desktop configuration, synced across machines.

Copy-based sync (no symlinks): the `config/` directory mirrors the tracked parts
of `~/.config`, and `sync.sh` copies files in either direction.

## Tracked

`hypr` (window manager), `waybar`, `walker`, `mako`, `swayosd`, terminals
(`alacritty`, `foot`, `kitty`, `ghostty`), and Omarchy `hooks` / `themes` /
`backgrounds`.

Not tracked: secrets and app state (1Password, browser profiles, `gh` tokens,
Signal, etc.), and `hypr/monitors.conf` (per-machine display layout, see
`config/hypr/monitors.conf.example`).

## Usage

Pull the latest config from this machine into the repo, then commit:

```bash
./sync.sh from-system
git add -A && git commit -m "Update configs" && git push
```

Deploy the repo's config onto another machine:

```bash
git pull
./sync.sh to-system
hyprctl reload && omarchy restart waybar
```

Preview any sync without touching files by appending `--dry-run`.

### Per-machine monitors

`monitors.conf` is not synced. On a new machine, start from the example:

```bash
cp config/hypr/monitors.conf.example ~/.config/hypr/monitors.conf
# then edit for that machine's displays; see: hyprctl monitors
```
