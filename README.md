# Dotfiles — Fedora 43 + GNOME

Конфигурационные файлы и скрипты автоматической установки для рабочей станции на базе **Fedora 43**, **GNOME**, ноутбук **Lenovo XiaoXinPro 14** (Ryzen 8845H, 27 GB RAM, NVMe, OLED).

> Этот README служит двойной цели: документация для человека и инструкция для AI-ассистента по настройке системы с нуля.

## Быстрый старт

```bash
git clone https://github.com/DefaultPerson/dotfiles.git
cd dotfiles
./scripts/install.sh        # интерактивное меню
./scripts/install.sh --all  # полная установка без вопросов
```

## Структура репозитория

```
dotfiles/
├── editors/
│   └── vscode/
│       ├── settings.json           # Cursor/VSCode настройки
│       └── extensions.json         # Рекомендуемые расширения
├── fixes/
│   ├── fix-luks-brightness.sh      # Фикс яркости для LUKS + OLED
│   ├── fix-luks-brightness.md      # Документация фикса
│   └── fix-nautilus-thumbnails.md  # Фикс миниатюр Nautilus
├── gnome/
│   ├── autostart/                  # .desktop файлы автозапуска
│   ├── dconf-desktop.ini           # GNOME Desktop настройки
│   ├── dconf-extensions.ini        # Настройки расширений
│   ├── dconf-shell.ini             # GNOME Shell настройки
│   ├── dconf-tilingshell.ini       # Tiling Shell конфиг
│   ├── extensions.txt              # Список расширений GNOME
│   └── flatpaks.txt                # Список Flatpak приложений
├── performance/
│   ├── fedora-perf-setup.sh        # Оптимизации производительности
│   └── README.md                   # Документация оптимизаций
├── scripts/
│   ├── install.sh                  # Установщик системы (10 шагов)
│   └── export-all.sh               # Экспорт текущих настроек
├── shell/
│   └── .bashrc                     # Bash конфигурация + алиасы
├── system/
│   └── snapper.md                  # Настройка BTRFS-снапшотов
├── voxtype/
│   ├── config.toml                 # Голосовой ввод (Whisper)
│   ├── input-remapper/             # Маппинг кнопок мыши
│   └── systemd/                    # Systemd override
└── wallpapers/                     # 11 обоев рабочего стола
```

## Полная установка с нуля

### 1. Базовая система

Установить Fedora 43 Workstation с параметрами:
- Шифрование: **LUKS**
- Файловая система: **BTRFS**
- Раскладки: Английская + Русская

### 2. Репозитории

```bash
# RPMFusion (free + nonfree)
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Google Chrome
sudo dnf config-manager addrepo --from-repofile=https://dl.google.com/linux/chrome/rpm/stable/x86_64

# Cursor (AI Code Editor)
sudo rpm --import https://downloads.cursor.com/linux/keys/cursor-gpg-key.asc
# + /etc/yum.repos.d/cursor.repo (baseurl=https://downloads.cursor.com/yumrepo)

# PortProton (Copr)
sudo dnf copr enable -y boria138/portproton
```

### 3. DNF пакеты

```bash
sudo dnf install -y \
  google-chrome-stable cursor electerm \
  obs-studio obs-studio-plugin-browser obs-studio-plugin-droidcam \
  obs-studio-plugin-vlc-video obs-studio-plugin-x264 \
  input-remapper portproton bleachbit \
  snapper python3-dnf-plugin-snapper glycin-thumbnailer \
  tmux git nodejs python3-pip earlyoom
```

### 4. Flatpak приложения

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub \
  app.zen_browser.zen \
  com.anydesk.Anydesk \
  com.getpostman.Postman \
  com.github.qarmin.czkawka \
  com.mattjakeman.ExtensionManager \
  it.mijorus.gearlever \
  nl.hjdskes.gcolor3 \
  org.qbittorrent.qBittorrent
```

### 5. Кастомные приложения

- **AmneziaVPN** — скачать установщик с [amnezia.org](https://amnezia.org/downloads), установится в `/opt/AmneziaVPN/`
- **Throne** — бинарник в `~/.local/share/throne/`
- **Telegram** — скачать с [telegram.org](https://telegram.org/dl/desktop/linux), распаковать в `~/.local/share/Telegram/`

### 6. Dev tools

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh      # uv (Python)
curl -fsSL https://get.pnpm.io/install.sh | sh -      # pnpm (Node.js)
curl -fsSL https://deno.land/install.sh | sh           # deno
npm install -g @anthropic-ai/claude-code                # Claude Code CLI
```

### 7. GNOME настройки

```bash
# Порядок загрузки dconf (широкий → узкий):
dconf load /org/gnome/shell/ < gnome/dconf-shell.ini
dconf load /org/gnome/desktop/ < gnome/dconf-desktop.ini
dconf load /org/gnome/shell/extensions/ < gnome/dconf-extensions.ini
dconf load /org/gnome/shell/extensions/tilingshell/ < gnome/dconf-tilingshell.ini
```

Автозапуск: при копировании .desktop файлов заменить `/home/def` на `$HOME`:
```bash
sed "s|/home/def|$HOME|g" gnome/autostart/*.desktop > ~/.config/autostart/
```

Обои: скопировать `wallpapers/*` в `~/.local/share/backgrounds/`.

### 8. Shell

```bash
ln -sf $(pwd)/shell/.bashrc ~/.bashrc
```

Включает: алиасы Claude Code (`cc`, `ccr`, `ccd`), функции tmux-сеток (`tg`, `tg2`, `tg3`, `ta`).

### 9. Редакторы (Cursor)

```bash
cp editors/vscode/settings.json ~/.config/Cursor/User/settings.json
```

Расширения из `editors/vscode/extensions.json` устанавливаются через `cursor --install-extension`.

### 10. Производительность

```bash
sudo bash performance/fedora-perf-setup.sh
```

Включает: sysctl-оптимизации (vm.swappiness, TCP BBR), earlyoom, NVMe-планировщик, WiFi powersave off.

### 11. Фиксы

- **LUKS яркость** — `fixes/fix-luks-brightness.sh` (udev-правило для OLED при GDM)
- **Миниатюры Nautilus** — `sudo dnf install glycin-thumbnailer`
- **Snapper** — настройка BTRFS-снапшотов, см. `system/snapper.md`

## Экспорт настроек

```bash
./scripts/export-all.sh
```

Экспортирует в репозиторий:
- Shell-конфиги (`.bashrc`)
- GNOME dconf-дампы (desktop, shell, extensions, tiling)
- Autostart-записи
- Список Flatpak-приложений (`gnome/flatpaks.txt`)
- Расширения Cursor (`editors/vscode/cursor-extensions.txt`)

## GNOME-расширения

| Расширение | Описание |
|---|---|
| AppIndicator Support | Иконки в системном трее |
| Auto Move Windows | Автоматическое перемещение окон по рабочим столам |
| Blur my Shell | Размытие фона панелей и обзора |
| Caffeine | Запрет блокировки экрана |
| Clipboard Indicator | Менеджер буфера обмена |
| Coverflow Alt-Tab | 3D-переключатель окон |
| Dash to Dock | Док-панель |
| GSConnect | Интеграция с Android (KDE Connect) |
| Just Perfection | Тонкая настройка GNOME Shell |
| Tiling Shell | Тайловый менеджер окон |
| Window Title is Back | Заголовок окна в панели |

## Автозапуск

| Приложение | Файл |
|---|---|
| AmneziaVPN | `AmneziaVPN.desktop` |
| Cursor | `cursor.desktop` |
| Google Chrome | `google-chrome.desktop` |
| Telegram | `org.telegram.desktop.desktop` |
| Throne | `Throne.desktop` |

## Заметки

- Файлы `.desktop` хранятся с путями `/home/def` — при установке `install.sh` заменяет их на `$HOME` текущего пользователя
- Flatpak-список (`gnome/flatpaks.txt`) генерируется `export-all.sh` и используется `install.sh`
- Voxtype (голосовой ввод) настраивается отдельно, конфиги в `voxtype/`
