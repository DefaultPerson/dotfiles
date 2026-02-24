#!/bin/bash
set -euo pipefail

# =============================================================================
# Dotfiles Installer — Fedora + GNOME
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- Colors ------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# --- Utilities ---------------------------------------------------------------

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

ask_yes_no() {
    read -rp "$1 [y/N] " -n 1
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

is_installed() {
    command -v "$1" &>/dev/null
}

# =============================================================================
# 1. Repositories
# =============================================================================

setup_repos() {
    info "Setting up repositories..."

    # RPMFusion free + nonfree
    if ! dnf repolist | grep -q rpmfusion-free; then
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
        success "RPMFusion installed"
    else
        success "RPMFusion already configured"
    fi

    # Google Chrome
    if ! dnf repolist | grep -q google-chrome; then
        sudo dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/chrome/rpm/stable/x86_64
        sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
        success "Google Chrome repo added"
    else
        success "Google Chrome repo already exists"
    fi

    # Cursor
    if ! dnf repolist | grep -q cursor; then
        sudo rpm --import https://downloads.cursor.com/linux/keys/cursor-gpg-key.asc
        sudo tee /etc/yum.repos.d/cursor.repo > /dev/null <<'REPO'
[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/linux/keys/cursor-gpg-key.asc
REPO
        success "Cursor repo added"
    else
        success "Cursor repo already exists"
    fi

    # PortProton (Copr)
    if ! dnf repolist | grep -q portproton; then
        sudo dnf copr enable -y boria138/portproton
        success "PortProton Copr enabled"
    else
        success "PortProton Copr already enabled"
    fi

    success "All repositories configured"
}

# =============================================================================
# 2. DNF Packages
# =============================================================================

install_dnf_packages() {
    info "Installing DNF packages..."

    local packages=(
        google-chrome-stable
        cursor
        electerm
        obs-studio
        obs-studio-plugin-browser
        obs-studio-plugin-droidcam
        obs-studio-plugin-vlc-video
        obs-studio-plugin-x264
        input-remapper
        portproton
        bleachbit
        snapper
        python3-dnf-plugin-snapper
        glycin-thumbnailer
        tmux
        git
        nodejs
        python3-pip
        earlyoom
    )

    sudo dnf install -y "${packages[@]}"
    success "DNF packages installed"
}

# =============================================================================
# 3. Flatpak Apps
# =============================================================================

install_flatpak_apps() {
    info "Installing Flatpak apps..."

    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo

    local flatpak_file="$DOTFILES_DIR/gnome/flatpaks.txt"
    if [[ ! -f "$flatpak_file" ]]; then
        error "flatpaks.txt not found: $flatpak_file"
        return 1
    fi

    while IFS= read -r app_id; do
        [[ -z "$app_id" || "$app_id" =~ ^# ]] && continue
        if flatpak info "$app_id" &>/dev/null; then
            success "$app_id already installed"
        else
            flatpak install -y flathub "$app_id"
            success "$app_id installed"
        fi
    done < "$flatpak_file"

    success "Flatpak apps installed"
}

# =============================================================================
# 4. Custom Apps (AmneziaVPN, Throne, Telegram)
# =============================================================================

install_custom_apps() {
    info "Installing custom apps..."

    # AmneziaVPN
    if [[ -d /opt/AmneziaVPN ]]; then
        success "AmneziaVPN already installed"
    else
        warn "AmneziaVPN: скачайте установщик с https://amnezia.org/downloads"
        warn "Запустите установщик вручную, затем повторите этот шаг"
    fi

    # Throne
    local throne_dir="$HOME/.local/share/throne"
    if [[ -d "$throne_dir" ]]; then
        success "Throne already installed"
    else
        warn "Throne: скачайте бинарник с официального сайта"
        warn "Поместите его в $throne_dir/"
    fi

    # Telegram
    local telegram_dir="$HOME/.local/share/Telegram"
    if [[ -x "$telegram_dir/Telegram" ]]; then
        success "Telegram already installed"
    else
        info "Downloading Telegram..."
        local tmp_file
        tmp_file=$(mktemp /tmp/telegram-XXXXXX.tar.xz)
        curl -L -o "$tmp_file" "https://telegram.org/dl/desktop/linux"
        mkdir -p "$HOME/.local/share"
        tar -xf "$tmp_file" -C "$HOME/.local/share/"
        rm -f "$tmp_file"
        success "Telegram installed to $telegram_dir"
    fi
}

# =============================================================================
# 5. Dev Tools (uv, pnpm, deno, Claude Code)
# =============================================================================

install_dev_tools() {
    info "Installing dev tools..."

    # uv (Python package manager)
    if is_installed uv; then
        success "uv already installed"
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
        success "uv installed"
    fi

    # pnpm (Node.js package manager)
    if is_installed pnpm; then
        success "pnpm already installed"
    else
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        success "pnpm installed"
    fi

    # deno
    if is_installed deno; then
        success "deno already installed"
    else
        curl -fsSL https://deno.land/install.sh | sh
        success "deno installed"
    fi

    # Claude Code CLI
    if is_installed claude; then
        success "Claude Code already installed"
    else
        if is_installed npm; then
            npm install -g @anthropic-ai/claude-code
            success "Claude Code installed"
        else
            warn "npm not found — install nodejs first, then run: npm i -g @anthropic-ai/claude-code"
        fi
    fi
}

# =============================================================================
# 6. GNOME (dconf, autostart, wallpapers)
# =============================================================================

setup_gnome() {
    info "Setting up GNOME..."

    # dconf: shell first (broad), then desktop, then extensions (narrow, overwrites)
    if ask_yes_no "Загрузить настройки GNOME Shell?"; then
        dconf load /org/gnome/shell/ < "$DOTFILES_DIR/gnome/dconf-shell.ini"
        success "GNOME Shell settings loaded"
    fi

    if ask_yes_no "Загрузить настройки GNOME Desktop?"; then
        dconf load /org/gnome/desktop/ < "$DOTFILES_DIR/gnome/dconf-desktop.ini"
        success "GNOME Desktop settings loaded"
    fi

    if ask_yes_no "Загрузить настройки расширений GNOME?"; then
        dconf load /org/gnome/shell/extensions/ < "$DOTFILES_DIR/gnome/dconf-extensions.ini"
        dconf load /org/gnome/shell/extensions/tilingshell/ < "$DOTFILES_DIR/gnome/dconf-tilingshell.ini"
        success "GNOME extensions settings loaded"
    fi

    # Autostart — copy with $HOME replacement
    info "Installing autostart entries..."
    mkdir -p ~/.config/autostart
    for f in "$DOTFILES_DIR/gnome/autostart/"*.desktop; do
        [[ -f "$f" ]] || continue
        sed "s|/home/def|$HOME|g" "$f" > ~/.config/autostart/"$(basename "$f")"
    done
    success "Autostart entries installed"

    # Wallpapers
    info "Installing wallpapers..."
    local bg_dir="$HOME/.local/share/backgrounds"
    mkdir -p "$bg_dir"
    cp "$DOTFILES_DIR/wallpapers/"* "$bg_dir/" 2>/dev/null || true
    success "Wallpapers installed to $bg_dir"

    # Extensions reminder
    echo ""
    info "GNOME-расширения для установки вручную:"
    cat "$DOTFILES_DIR/gnome/extensions.txt"
    echo ""
    info "Установите через Extension Manager (Flatpak) или https://extensions.gnome.org/"
}

# =============================================================================
# 7. Shell (.bashrc)
# =============================================================================

setup_shell() {
    info "Setting up shell..."
    ln -sf "$DOTFILES_DIR/shell/.bashrc" ~/.bashrc
    success "Symlinked .bashrc → $DOTFILES_DIR/shell/.bashrc"
}

# =============================================================================
# 8. Editors (Cursor settings + extensions)
# =============================================================================

setup_editors() {
    info "Setting up editors..."

    # Cursor settings.json
    local cursor_config="$HOME/.config/Cursor/User"
    mkdir -p "$cursor_config"
    cp "$DOTFILES_DIR/editors/vscode/settings.json" "$cursor_config/settings.json"
    success "Cursor settings.json installed"

    # Install Cursor extensions from extensions.json
    local ext_file="$DOTFILES_DIR/editors/vscode/extensions.json"
    if [[ -f "$ext_file" ]] && is_installed cursor; then
        info "Installing Cursor extensions..."
        local extensions
        extensions=$(python3 -c "
import json, sys
data = json.load(open('$ext_file'))
for ext in data.get('recommendations', []):
    print(ext)
" 2>/dev/null) || true

        if [[ -n "$extensions" ]]; then
            while IFS= read -r ext; do
                cursor --install-extension "$ext" 2>/dev/null || warn "Failed: $ext"
            done <<< "$extensions"
            success "Cursor extensions installed"
        fi
    fi

    # Install from cursor-extensions.txt if exists
    local cursor_ext_file="$DOTFILES_DIR/editors/vscode/cursor-extensions.txt"
    if [[ -f "$cursor_ext_file" ]] && is_installed cursor; then
        while IFS= read -r ext; do
            [[ -z "$ext" ]] && continue
            cursor --install-extension "$ext" 2>/dev/null || warn "Failed: $ext"
        done < "$cursor_ext_file"
    fi
}

# =============================================================================
# 9. Performance Tweaks
# =============================================================================

setup_performance() {
    info "Setting up performance tweaks..."

    local perf_script="$DOTFILES_DIR/performance/fedora-perf-setup.sh"
    if [[ -f "$perf_script" ]]; then
        if ask_yes_no "Запустить скрипт performance/fedora-perf-setup.sh?"; then
            bash "$perf_script"
            success "Performance tweaks applied"
        fi
    else
        warn "Performance script not found: $perf_script"
    fi
}

# =============================================================================
# 10. System Fixes
# =============================================================================

apply_fixes() {
    info "Applying system fixes..."

    # LUKS brightness fix (for OLED displays)
    if ask_yes_no "Применить фикс яркости LUKS/GDM (для OLED)?"; then
        bash "$DOTFILES_DIR/fixes/fix-luks-brightness.sh"
        success "LUKS brightness fix applied"
    fi

    # Nautilus thumbnails
    if ! rpm -q glycin-thumbnailer &>/dev/null; then
        sudo dnf install -y glycin-thumbnailer
        success "glycin-thumbnailer installed"
    else
        success "glycin-thumbnailer already installed"
    fi

    # Snapper reminder
    if rpm -q snapper &>/dev/null; then
        info "Snapper установлен. Настройка: см. system/snapper.md"
    fi
}

# =============================================================================
# Interactive Menu
# =============================================================================

show_menu() {
    echo ""
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║         Dotfiles Installer               ║${NC}"
    echo -e "${BOLD}${BLUE}╠══════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  1) Репозитории (RPMFusion, Chrome...)    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  2) DNF пакеты                            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  3) Flatpak приложения                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  4) Кастомные (VPN, Telegram, Throne)     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  5) Dev tools (uv, pnpm, deno, claude)    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  6) GNOME (dconf, autostart, обои)        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  7) Shell (.bashrc)                       ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  8) Редакторы (Cursor)                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  9) Производительность                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} 10) Фиксы системы                        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  a) Всё вышеперечисленное                 ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  q) Выход                                 ${BLUE}║${NC}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

run_step() {
    case "$1" in
        1)  setup_repos ;;
        2)  install_dnf_packages ;;
        3)  install_flatpak_apps ;;
        4)  install_custom_apps ;;
        5)  install_dev_tools ;;
        6)  setup_gnome ;;
        7)  setup_shell ;;
        8)  setup_editors ;;
        9)  setup_performance ;;
        10) apply_fixes ;;
        *)  error "Unknown step: $1" ;;
    esac
}

run_all() {
    for step in $(seq 1 10); do
        echo ""
        echo -e "${BOLD}--- Step $step/10 ---${NC}"
        run_step "$step"
    done
    echo ""
    success "Все шаги выполнены!"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    echo -e "${BOLD}${BLUE}Dotfiles directory:${NC} $DOTFILES_DIR"

    # --all flag: non-interactive full install
    if [[ "${1:-}" == "--all" ]]; then
        run_all
        exit 0
    fi

    while true; do
        show_menu
        read -rp "Выберите опцию: " choice
        case "$choice" in
            [1-9])  run_step "$choice" ;;
            10)     run_step 10 ;;
            a|A)    run_all; break ;;
            q|Q)    info "Пока!"; exit 0 ;;
            *)      warn "Неизвестная опция: $choice" ;;
        esac
    done
}

main "$@"
