#!/usr/bin/env bash
#
# Sync Omarchy desktop configs between ~/.config and this repo (copy-based).
#
#   ./sync.sh from-system    Copy configs FROM ~/.config INTO this repo (run before commit)
#   ./sync.sh to-system      Deploy configs FROM this repo INTO ~/.config (run on the other PC)
#
# Append --dry-run to either command to preview without changing anything.
#
# Notes:
#   - monitors.conf is intentionally NOT synced (per-machine display layout).
#     A monitors.conf.example is kept in the repo for reference.
#   - *.bak / *.bak.* files are never copied.
#   - to-system never deletes local files; it only adds/overwrites tracked ones.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
SYSTEM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Tracked paths, relative to ~/.config
PATHS=(
  hypr
  waybar
  walker
  mako
  swayosd
  alacritty
  foot
  kitty
  ghostty
  omarchy/hooks
  omarchy/themes
  omarchy/backgrounds
)

EXCLUDES=(
  --exclude='*.bak'
  --exclude='*.bak.*'
  --exclude='monitors.conf'            # per-machine, kept local
  --exclude='monitors.conf.example'    # keep the reference copy out of sync/delete
)

CMD="${1:-}"
DRYRUN=()
[[ "${2:-}" == "--dry-run" ]] && DRYRUN=(--dry-run)

collect_existing() {
  local base="$1"; shift
  existing=()
  local p
  for p in "${PATHS[@]}"; do [[ -e "$base/$p" ]] && existing+=("$p"); done
}

case "$CMD" in
  from-system)
    mkdir -p "$CONFIG_SRC"
    cd "$SYSTEM_DIR"
    collect_existing "$SYSTEM_DIR"
    rsync -aR --delete "${DRYRUN[@]}" "${EXCLUDES[@]}" "${existing[@]}" "$CONFIG_SRC/"
    echo "Pulled ${#existing[@]} config path(s) into $CONFIG_SRC"
    ;;
  to-system)
    cd "$CONFIG_SRC"
    collect_existing "$CONFIG_SRC"
    rsync -aR "${DRYRUN[@]}" "${EXCLUDES[@]}" "${existing[@]}" "$SYSTEM_DIR/"
    echo "Deployed ${#existing[@]} config path(s) into $SYSTEM_DIR"
    echo "Then reload:  hyprctl reload  &&  omarchy restart waybar"
    ;;
  *)
    echo "Usage: $0 {from-system|to-system} [--dry-run]"
    exit 1
    ;;
esac
