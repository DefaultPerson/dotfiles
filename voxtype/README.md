# Voxtype — голосовой ввод по кнопке мыши

Push-to-talk голосовой ввод на Linux (GNOME Wayland) через middle click.

## Как работает

- **Hold** колёсико > 0.4 сек → запись → транскрипция → текст в clipboard
- **Tap** колёсико → вставка из primary selection (работает в терминале)

## Установка

### 1. Зависимости

```bash
sudo dnf install -y wtype wl-clipboard input-remapper
```

### 2. Voxtype

```bash
# Скачать RPM
wget -P /tmp https://github.com/peteonrails/voxtype/releases/download/v0.4.12/voxtype-0.4.12-1.x86_64.rpm
sudo dnf install -y /tmp/voxtype-0.4.12-1.x86_64.rpm

# Скачать модель (large-v3-turbo для русского)
voxtype setup --download --model large-v3-turbo

# Включить GPU (опционально)
sudo voxtype setup gpu --enable
```

### 3. Конфиги

```bash
# Voxtype
cp config.toml ~/.config/voxtype/

# Input-remapper (заменить "VXE VXE Mouse 1K Dongle" на имя своей мыши)
mkdir -p ~/.config/input-remapper-2/presets/"ИМЯ_МЫШИ"
cp input-remapper/main_preset.json ~/.config/input-remapper-2/presets/"ИМЯ_МЫШИ"/
cp input-remapper/config.json ~/.config/input-remapper-2/

# Systemd
mkdir -p ~/.config/systemd/user/voxtype.service.d
cp systemd/env.conf ~/.config/systemd/user/voxtype.service.d/
```

### 4. Symlink для ydotool

```bash
ln -sf /run/user/1000/ydotool/yd.sock /run/user/1000/.ydotool_socket
```

### 5. Запуск

```bash
# Input-remapper
input-remapper-control --command autoload

# Voxtype
systemctl --user daemon-reload
systemctl --user enable --now voxtype
```

## Файлы

| Файл | Назначение |
|------|------------|
| `config.toml` | Конфиг voxtype (hotkey, модель, язык) |
| `input-remapper/main_preset.json` | Маппинг middle click → Pause |
| `input-remapper/config.json` | Автозагрузка пресета |
| `systemd/env.conf` | Override для systemd сервиса |

## Проверка

```bash
# Статус voxtype
systemctl --user status voxtype

# Логи
journalctl --user -u voxtype -f
```
