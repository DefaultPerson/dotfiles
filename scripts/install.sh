#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing dotfiles from: $DOTFILES_DIR"

# Shell configs (symlinks)
echo "Installing shell configs..."
ln -sf "$DOTFILES_DIR/shell/.bashrc" ~/.bashrc
[ -f "$DOTFILES_DIR/shell/.bash_profile" ] && ln -sf "$DOTFILES_DIR/shell/.bash_profile" ~/.bash_profile

# GNOME settings
echo "Restoring GNOME settings..."
read -p "Restore GNOME desktop settings? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    dconf load /org/gnome/desktop/ < "$DOTFILES_DIR/gnome/dconf-desktop.ini"
fi

read -p "Restore GNOME extensions settings? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    dconf load /org/gnome/shell/extensions/ < "$DOTFILES_DIR/gnome/dconf-extensions.ini"
fi

# Autostart
echo "Installing autostart entries..."
mkdir -p ~/.config/autostart
cp "$DOTFILES_DIR/gnome/autostart/"*.desktop ~/.config/autostart/ 2>/dev/null || true

# Show installed extensions list
echo ""
echo "=== GNOME Extensions to install ==="
cat "$DOTFILES_DIR/gnome/extensions.txt"
echo ""
echo "Install extensions from: https://extensions.gnome.org/"

echo ""
echo "Done! Restart shell for changes to take effect."
