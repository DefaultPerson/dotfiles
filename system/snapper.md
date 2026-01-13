# Snapper - BTRFS Snapshots

## Install

```bash
sudo dnf install snapper python3-dnf-plugin-snapper
```

## Configure

```bash
# Root subvolume
sudo snapper -c root create-config /

# Home subvolume (optional)
sudo snapper -c home create-config /home

# Enable auto-snapshots
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

## Usage

```bash
# List snapshots
sudo snapper list

# Create manual snapshot
sudo snapper create -d "before update"

# Compare snapshots
sudo snapper diff 1..2

# Rollback
sudo snapper undochange 1..0
```

## DNF Integration

Auto-snapshots before/after `dnf` updates via `python3-dnf-plugin-snapper`.

## Config Location

- `/etc/snapper/configs/root`
- `/etc/snapper/configs/home`
