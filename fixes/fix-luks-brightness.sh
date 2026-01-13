#!/bin/bash
# Fix low brightness on LUKS/Plymouth/GDM for OLED displays
# Run with: sudo ./fix-luks-brightness.sh

set -e

echo "=== Fixing LUKS/Plymouth brightness for amdgpu_bl1 ==="

# 1. Create udev rule
echo 'SUBSYSTEM=="backlight", ACTION=="add", KERNEL=="amdgpu_bl1", ATTR{brightness}="$attr{max_brightness}"' \
  > /etc/udev/rules.d/99-brightness.rules
echo "[OK] Created /etc/udev/rules.d/99-brightness.rules"

# 2. Add to dracut initramfs
echo 'install_items+=" /etc/udev/rules.d/99-brightness.rules "' \
  > /etc/dracut.conf.d/brightness.conf
echo "[OK] Created /etc/dracut.conf.d/brightness.conf"

# 3. Rebuild initramfs
echo "[...] Rebuilding initramfs (this may take a minute)..."
dracut -f
echo "[OK] Initramfs rebuilt"

echo ""
echo "=== Done! Reboot to apply changes ==="
echo "After reboot, LUKS prompt should have full brightness."
