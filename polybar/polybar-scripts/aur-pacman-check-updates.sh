updates_arch=$(checkupdates | wc -l )
updates_aur=$(yay -Qum | wc -l)
# updates_aur=$(paru -Qum | wc -l)
# updates_aur=$(cower -u | wc -l)
# updates_aur=$(trizen -Su --aur --quiet | wc -l)
# updates_aur=$(pikaur | wc -l)
# updates_aur=$(rua upgrade | wc -l)

updates=$((updates_arch + updates_aur))

if [ "$updates" -gt 0 ]; then
    echo ""$updates
else
    echo "0"
fi
