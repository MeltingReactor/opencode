#!/bin/bash

# Install basic plasma components message
echo "Installing basic plasma components..."

# Install basic plasma components
sudo pacman -S plasma-meta
sudo pacman -S sddm-kcm

# Install default KDE Plasma apps
sudo pacman -S --needed dolphin dolphin-plugins ark gwenview okular spectacle kate filelight konsole kcalc kwalletmanager kio-extras ffmpegthumbs kdegraphics-thumbnailers qt6-imageformats kimageformats kdeconnect elisa partitionmanager kcalc kwallet libreoffice kmail kolourpaint flatpak kwrite firefox kaddressbook kmouth kleopatra kcharselect kfind filelight korganizer qrca kamoso neochat krfb krdc akregator khelpcenter kmahjongg kmines

echo ""
echo ""
echo "The folowing packages are not available on Arch Linux: dragonplayer, Journald Browser, Skanpage, KPatience, Kontact"
sleep 2

echo ""

echo "Installing compatible packages with flatpak..."

flatpak install flathub org.kde.dragonplayer
flatpak install flathub org.kde.skanpage
flatpak install flathub org.kde.kpat
flatpak install flathub org.kde.kontact

sleep 1

echo ""
echo ""

echo "Please install Journald Browser manually via: https://apps.kde.org/en-gb/kjournaldbrowser/."
echo ""
echo "A reboot is recommended."

echo ""
sleep .1
echo "Done."
echo ""
#EOF
