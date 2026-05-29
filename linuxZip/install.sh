#!/bin/bash
set -e

APP="zip-unpacker"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing $APP ==="
echo ""

# --- Detect distro and install dependencies ---
if command -v apt &>/dev/null; then
    echo "[1/3] Installing system dependencies (requires sudo)..."
    sudo apt update
    sudo apt install -y python3-gi gir1.2-notify-0.7 xdg-utils unar p7zip-full
elif command -v pacman &>/dev/null; then
    echo "[1/3] Installing system dependencies (requires sudo)..."
    sudo pacman -Sy --noconfirm python-gobject libnotify xdg-utils unar p7zip
elif command -v dnf &>/dev/null; then
    echo "[1/3] Installing system dependencies (requires sudo)..."
    sudo dnf install -y python3-gobject libnotify xdg-utils unar p7zip p7zip-plugins
elif command -v zypper &>/dev/null; then
    echo "[1/3] Installing system dependencies (requires sudo)..."
    sudo zypper install -y python3-gobject libnotify xdg-utils unar p7zip
else
    echo "Warning: Could not detect package manager."
    echo "Please install: python3-gi, gir1.2-notify-0.7, xdg-utils, unar, p7zip"
    echo ""
fi

# --- Copy the script ---
echo "[2/3] Installing $APP to ~/.local/bin/..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/$APP" ~/.local/bin/$APP
chmod 755 ~/.local/bin/$APP

# --- Install .desktop file ---
echo "[3/3] Installing desktop entry..."
mkdir -p ~/.local/share/applications
cp "$SCRIPT_DIR/$APP.desktop" ~/.local/share/applications/$APP.desktop
chmod 644 ~/.local/share/applications/$APP.desktop

# Register with the desktop MIME database
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
fi

# Set as default handler for zip files
xdg-mime default $APP.desktop application/zip 2>/dev/null || true
xdg-mime default $APP.desktop application/x-zip-compressed 2>/dev/null || true

# --- Copy icon ---
cp "$SCRIPT_DIR/archive.png" ~/.local/bin/archive.png

echo ""
echo "=== Done! $APP is installed and set as the default zip handler ==="
echo ""
echo "To test it, double-click any .zip file."
echo ""
echo "Press Enter to close."
read -r
