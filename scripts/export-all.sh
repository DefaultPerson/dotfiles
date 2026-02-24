#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

export_shell() {
    info "Exporting shell configs..."
    cp ~/.bashrc "$DOTFILES_DIR/shell/.bashrc"
    [[ -f ~/.bash_profile ]] && cp ~/.bash_profile "$DOTFILES_DIR/shell/.bash_profile"
    success "Shell configs exported"
}

export_gnome() {
    info "Exporting GNOME settings..."
    gnome-extensions list --enabled > "$DOTFILES_DIR/gnome/extensions.txt"
    dconf dump /org/gnome/desktop/ > "$DOTFILES_DIR/gnome/dconf-desktop.ini"
    dconf dump /org/gnome/shell/extensions/ > "$DOTFILES_DIR/gnome/dconf-extensions.ini"
    dconf dump /org/gnome/shell/ > "$DOTFILES_DIR/gnome/dconf-shell.ini"
    dconf dump /org/gnome/shell/extensions/tilingshell/ > "$DOTFILES_DIR/gnome/dconf-tilingshell.ini" 2>/dev/null || true
    success "GNOME settings exported"
}

export_autostart() {
    info "Exporting autostart entries..."
    local autostart_dir="$DOTFILES_DIR/gnome/autostart"
    rm -f "$autostart_dir"/*.desktop
    if ls ~/.config/autostart/*.desktop &>/dev/null; then
        cp ~/.config/autostart/*.desktop "$autostart_dir/"
        success "Autostart entries exported ($(ls -1 "$autostart_dir"/*.desktop | wc -l) files)"
    else
        warn "No autostart entries found in ~/.config/autostart/"
    fi
}

export_flatpaks() {
    info "Exporting Flatpak apps..."
    flatpak list --app --columns=application > "$DOTFILES_DIR/gnome/flatpaks.txt"
    success "Flatpak list exported ($(wc -l < "$DOTFILES_DIR/gnome/flatpaks.txt") apps)"
}

export_editor_extensions() {
    info "Exporting editor extensions..."
    local ext_file="$DOTFILES_DIR/editors/vscode/cursor-extensions.txt"
    if command -v cursor &>/dev/null; then
        cursor --list-extensions > "$ext_file"
        success "Cursor extensions exported ($(wc -l < "$ext_file") extensions)"
    else
        warn "Cursor not found, skipping extensions export"
    fi
}

echo -e "${BLUE}Exporting configs to:${NC} $DOTFILES_DIR"
echo ""

export_shell
export_gnome
export_autostart
export_flatpaks
export_editor_extensions

echo ""
success "All configs exported to: $DOTFILES_DIR"
