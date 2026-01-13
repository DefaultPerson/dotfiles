# Fix: Низкая яркость на LUKS/GDM (OLED)

## Проблема

Тёмный экран на этапе ввода пароля LUKS и на экране входа GDM.

**Причина**: DRM-драйвер сбрасывает яркость при инициализации, а `systemd-backlight` восстанавливает её только после разблокировки LUKS.

## Что делает скрипт

```
sudo ./fix-luks-brightness.sh
```

1. Создаёт udev-правило `/etc/udev/rules.d/99-brightness.rules` — ставит max яркость при появлении backlight-устройства
2. Добавляет правило в initramfs через `/etc/dracut.conf.d/brightness.conf`
3. Пересобирает initramfs командой `dracut -f`

## Результат

- **LUKS prompt** → максимальная яркость ✓
- **GDM** → яркость из сохранённого значения (`/var/lib/systemd/backlight/`)

## Диагностика

```bash
# Текущая яркость
cat /sys/class/backlight/amdgpu_bl1/brightness

# Максимальная
cat /sys/class/backlight/amdgpu_bl1/max_brightness

# Сохранённое значение
cat /var/lib/systemd/backlight/*
```