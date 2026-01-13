#!/bin/bash
# Fedora Performance Optimization Setup
# See README.md for details
# Run: sudo bash fedora-perf-setup.sh
set -e

echo "=== Fedora Performance Optimization Setup ==="
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root (sudo bash $0)"
    exit 1
fi

# === Phase 1: DNF Cleanup + Config ===
echo "=== Phase 1: DNF Cleanup + Config ==="
dnf clean all
dnf autoremove -y
journalctl --rotate --vacuum-time=2weeks

# DNF config
cat > /etc/dnf/dnf.conf << 'EOF'
# see `man dnf.conf` for defaults and possible options

[main]
gpgcheck=True
installonly_limit=3
clean_requirements_on_remove=True
max_parallel_downloads=10
deltarpm=False
EOF
echo "✓ DNF configured"

# === Phase 2: Sysctl ===
echo ""
echo "=== Phase 2: Sysctl ==="
cat > /etc/sysctl.d/99-desktop-perf.conf << 'EOF'
# Memory management for ZRAM
vm.swappiness = 100
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.page-cluster = 0

# inotify for IDEs/file watchers
fs.inotify.max_user_watches = 524288

# Network (BBR + fq_codel)
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq_codel
net.ipv4.tcp_fastopen = 3
EOF
sysctl --system > /dev/null
echo "✓ Sysctl applied"

# === Phase 2.2: Earlyoom ===
echo ""
echo "=== Phase 2.2: Earlyoom ==="
systemctl disable --now systemd-oomd 2>/dev/null || true
dnf install -y earlyoom
systemctl enable --now earlyoom
echo "✓ Earlyoom installed and enabled"

# === Phase 3.1: I/O Scheduler ===
echo ""
echo "=== Phase 3.1: I/O Scheduler ==="
cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
EOF
udevadm control --reload-rules
udevadm trigger
echo "✓ I/O scheduler rule created"

# === Phase 5.1: Disable NetworkManager-wait-online ===
echo ""
echo "=== Phase 5.1: Boot optimization ==="
systemctl disable --now NetworkManager-wait-online 2>/dev/null || true
echo "✓ NetworkManager-wait-online disabled"

# === Phase 7.2: WiFi Auto Powersave ===
echo ""
echo "=== Phase 7.2: WiFi Auto Powersave ==="
cat > /usr/local/bin/wifi-powersave-auto.sh << 'EOF'
#!/bin/bash
# Автоматическое управление WiFi power save

WIFI_IFACE=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')
[ -z "$WIFI_IFACE" ] && exit 0

AC_ONLINE=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "0")

if [ "$AC_ONLINE" = "1" ]; then
    /usr/sbin/iw dev "$WIFI_IFACE" set power_save off
else
    /usr/sbin/iw dev "$WIFI_IFACE" set power_save on
fi
EOF
chmod +x /usr/local/bin/wifi-powersave-auto.sh

cat > /etc/udev/rules.d/99-wifi-powersave.rules << 'EOF'
# При изменении питания — переключить WiFi power save
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/local/bin/wifi-powersave-auto.sh"
EOF
udevadm control --reload-rules
echo "✓ WiFi auto-powersave configured"

# === Done ===
echo ""
echo "=========================================="
echo "✅ Setup complete! Reboot recommended."
echo "=========================================="
echo ""
echo "Verification commands:"
echo "  sysctl vm.swappiness vm.vfs_cache_pressure"
echo "  cat /sys/block/nvme*/queue/scheduler"
echo "  systemctl status earlyoom"
echo "  iw dev wlp2s0 get power_save"
echo ""
echo "SKIPPED (high risk, manual):"
echo "  - Phase 5.2-5.3: Dracut/GRUB changes"
echo "  - Phase 3.2: fstab noatime"
echo "  - Phase 8.3: GRUB gaming params"
echo ""
