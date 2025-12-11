#!/usr/bin/env bash
set -e

echo "==> Installing theme dependencies..."
sudo pacman -S --noconfirm \
  qt5ct qt6ct kvantum \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  xdg-desktop-portal-wlr

echo "==> Installing Catppuccin GTK theme (prebuilt mirror)..."
yay -S catppuccin-gtk-theme


echo "==> Installing Catppuccin Kvantum theme..."
mkdir -p ~/.config/Kvantum
git clone --depth=1 https://github.com/catppuccin/Kvantum.git /tmp/catppuccin-kvantum
cp -r /tmp/catppuccin-kvantum/Catppuccin-Mocha ~/.config/Kvantum/

echo "==> Installing BeautyLine icons..."
mkdir -p ~/.local/share/icons
git clone --depth=1 https://github.com/yeyushengfan258/BeautyLine.git /tmp/beautyline
cp -r /tmp/beautyline/* ~/.local/share/icons/

echo "==> Configuring GTK3..."
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Blue
gtk-icon-theme-name=BeautyLine
gtk-font-name=Noto Sans 10
EOF

echo "==> Configuring GTK4..."
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Blue
gtk-icon-theme-name=BeautyLine
gtk-font-name=Noto Sans 10
EOF

echo "==> Setting Qt platform theme..."
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/qt.conf <<EOF
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=kvantum
EOF

echo "==> Configuring Kvantum..."
mkdir -p ~/.config/Kvantum
cat > ~/.config/Kvantum/kvantum.kvconfig <<EOF
[General]
theme=Catppuccin-Mocha
EOF

echo "==> Selecting Kvantum theme..."
# Logic: Kvantum reads kvantum.kvconfig automatically on next run.

echo "==> Finishing..."
echo "Done! Log out and back in to activate Qt vars."

