#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Exporting configs to: $DOTFILES_DIR"

# Shell configs
echo "Exporting shell configs..."
cp ~/.bashrc "$DOTFILES_DIR/shell/.bashrc"
[ -f ~/.bash_profile ] && cp ~/.bash_profile "$DOTFILES_DIR/shell/.bash_profile"

# GNOME settings
echo "Exporting GNOME settings..."
gnome-extensions list --enabled > "$DOTFILES_DIR/gnome/extensions.txt"
dconf dump /org/gnome/desktop/ > "$DOTFILES_DIR/gnome/dconf-desktop.ini"
dconf dump /org/gnome/shell/extensions/ > "$DOTFILES_DIR/gnome/dconf-extensions.ini"
dconf dump /org/gnome/shell/ > "$DOTFILES_DIR/gnome/dconf-shell.ini"
dconf dump /org/gnome/shell/extensions/tilingshell/ > "$DOTFILES_DIR/gnome/dconf-tilingshell.ini" 2>/dev/null || true

# Autostart
echo "Exporting autostart entries..."
cp ~/.config/autostart/*.desktop "$DOTFILES_DIR/gnome/autostart/" 2>/dev/null || true

echo "Done! Exported to: $DOTFILES_DIR"
