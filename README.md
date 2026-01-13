# Dotfiles

Personal configuration files for **Fedora + GNOME** desktop.

## Quick Start

```bash
# Clone
git clone https://github.com/DefaultPerson/dotfiles.git
cd dotfiles

# Export current settings
./scripts/export-all.sh

# Install on new system
./scripts/install.sh
```

## Structure

```
dotfiles/
├── shell/           # Bash configs (.bashrc)
├── editors/         # VSCode settings
├── gnome/           # GNOME settings (dconf exports, extensions, autostart)
├── system/          # System configs (snapper)
├── fixes/           # Fedora fixes and workarounds
├── voxtype/         # Voxtype voice typing configs
├── performance/     # Fedora performance optimizations
├── scripts/         # Automation scripts
└── wallpapers/      # Desktop backgrounds
```

## GNOME Extensions

See [gnome/extensions.txt](gnome/extensions.txt) for the full list.

## Fedora Tweaks

- **fixes/** - Solutions for common issues (LUKS brightness, Nautilus thumbnails)
- **performance/** - Performance optimizations script
- **voxtype/** - Voice typing configuration with input-remapper
