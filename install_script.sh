#!bin/bash

echo 'Begin setup...'
# Добавляем мультилиб в список репозиториев pacman
sudo sed -i 's/#\[multilib\]/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf

# Устанавливаем пакеты и обновляем установленные
sudo pacman -Syyu --noconfirm  blueman bluez bluez-libs bluez-utils  discord flameshot hplip htop nitrogen \
telegram-desktop alacritty viewnior vlc pcmanfm fakeroot obs-studio mc steam qbittorrent rofi thunar ark arandr \
gedit ttf-font-awesome ttf-dejavu numlockx pavucontrol pulseaudio-bluetooth xsane redshift pacman-contrib

# Устанавливаем yay и загружаем пакеты с него
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
echo 'exec i3' >> ~/.xinitrc
yay -S --noconfirm ckb-next-git polybar foo2zjs xscreensaver-arch-logo noto-fonts

# Запускаем демона bluetooth
sudo systemctl daemon-reload
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
sudo sed -i 's/\[general\]/\[general\]\nEnable=Source,Sink,Media,Socket/' /etc/bluetooth/main.conf

# Генерируем локаль
sudo sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo fc-cache

# Включаем переключение раскладки
sudo setxkbmap -model pc105 -layout us,ru -option grp:alt_shift_toggle

# Устанавливаем шрифты
sudo sh -c "sudo rm /etc/vconsole.conf"
sudo sh -c "touch /etc/vconsole.conf"
sudo sh -c "echo '
FONT=ter-v32
KEYMAP=us
' >> /etc/vconsole.conf"

# Установка конфига i3
sudo cp $HOME/linux-misc/os-setup/config $HOME/.config/i3

# Установка скриптов для полибара
cp -r $HOME/linux-misc/polybar .config

chmod +x .config/polybar/launch.sh
chmod +x .config/polybar/polybar-scripts/aur-pacman-check-updates.sh
chmod +x .config/polybar/polybar-scripts/polybar-speedtest.py

# Установка rofi
cp -r $HOME/linux-misc/rofi .config

# Установка picom
yay -S picom-jonaburg-git
cp $HOME/linux-misc/picom.conf .config

# Установка redshift
cp $HOME/linux-misc/redshift.conf .config

# Запускаем демона для клавиатуры корсаир
sudo systemctl start ckb-next-daemon
sudo systemctl enable --now ckb-next-daemon