# Fedora Performance Optimization

Оптимизации для Fedora 43 на Lenovo XiaoXinPro 14 (Ryzen 8845H, 27GB RAM, NVMe).

## Установка

```bash
sudo bash fedora-perf-setup.sh
reboot
```

## Что делает скрипт

| Оптимизация | Эффект |
|-------------|--------|
| `vm.swappiness=100` | Активнее использует ZRAM (swap в RAM), освобождает память для file cache |
| `vm.vfs_cache_pressure=50` | Дольше держит inode/dentry cache — быстрее доступ к файлам |
| `earlyoom` | Убивает процессы при OOM по одному, а не всю cgroup (как systemd-oomd) |
| `scheduler=none` для NVMe | Минимальная latency — NVMe имеет свою очередь |
| `BBR` + `fq_codel` | Лучше throughput на WiFi/VPN, борьба с bufferbloat |
| `tcp_fastopen=3` | -1 RTT для повторных TCP соединений |
| WiFi powersave auto | От сети — низкая latency, от батареи — экономия |
| NetworkManager-wait-online off | Быстрее загрузка (~5-10s) |

## Проверка

```bash
sysctl vm.swappiness vm.vfs_cache_pressure  # 100, 50
cat /sys/block/nvme*/queue/scheduler        # [none]
systemctl status earlyoom                   # active
sysctl net.ipv4.tcp_congestion_control      # bbr
iw dev wlp2s0 get power_save                # off (от сети)
```

## Дополнительно (вручную)

WiFi powersave при загрузке (если не сработал udev):
```bash
sudo tee /etc/systemd/system/wifi-powersave.service << 'EOF'
[Unit]
Description=Set WiFi power save based on AC status
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-powersave-auto.sh

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable wifi-powersave.service
```

## Откат

```bash
sudo rm /etc/sysctl.d/99-desktop-perf.conf && sudo sysctl --system
sudo rm /etc/udev/rules.d/60-ioscheduler.rules && sudo udevadm trigger
sudo systemctl disable earlyoom && sudo systemctl enable systemd-oomd
sudo rm /usr/local/bin/wifi-powersave-auto.sh /etc/udev/rules.d/99-wifi-powersave.rules
```

## Не включено (осознанно)

- `mitigations=off` — небезопасно
- `preload` — бесполезен на SSD
- `ananicy-cpp` — минимальный эффект на мощной системе
- Dracut hostonly / GRUB params — высокий риск, делать вручную
