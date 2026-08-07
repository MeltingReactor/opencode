#!/bin/bash
set -e

REPO_OWNER="MeltingReactor"
REPO_NAME="opencode"
REPO_PATH="linuxZip"
BRANCH="main"
APP="zip-unpacker"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

# --- Download if not running from a local copy ---
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
TEMP_DIR=""

if [ ! -f "$SCRIPT_DIR/$APP" ]; then
    echo "Downloading $APP from GitHub..."
    TEMP_DIR="$(mktemp -d)"
    curl -fsSL "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$REPO_PATH/$APP" \
         -o "$TEMP_DIR/$APP"
    curl -fsSL "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$REPO_PATH/archive.png" \
         -o "$TEMP_DIR/archive.png"
    SCRIPT_DIR="$TEMP_DIR"
fi

echo "=== Installing $APP (Hyprland / Wayland Optimized) ==="
echo ""

# --- Detect distro and install dependencies ---
# Added mako/dunst/fnott common deps via libnotify, and xdg-utils for Wayland handshakes
if command -v pacman &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo pacman -Sy --noconfirm python-gobject libnotify xdg-utils unarchiver p7zip hyprland-protocols xdg-desktop-portal-hyprland
elif command -v dnf &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo dnf install -y python3-gobject libnotify xdg-utils unar p7zip p7zip-plugins xdg-desktop-portal-hyprland
elif command -v apt &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo apt update
    sudo apt install -y python3-gi gir1.2-notify-0.7 xdg-utils unar p7zip-full xdg-desktop-portal-wlr
elif command -v zypper &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo zypper install -y python3-gobject libnotify xdg-utils unar p7zip xdg-desktop-portal-hyprland
else
    echo "Warning: Could not detect package manager."
    echo "Please ensure python3-gobject, libnotify, xdg-utils, and a wayland-compatible notification daemon (like mako or dunst) are installed."
fi

# --- Copy the script ---
echo "[2/4] Installing $APP to $BIN_DIR/..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/$APP" "$BIN_DIR/$APP"
chmod 755 "$BIN_DIR/$APP"

# --- Copy the icon ---
echo "[3/4] Installing icon..."
mkdir -p "$ICON_DIR"
if [ -f "$SCRIPT_DIR/archive.png" ]; then
    cp "$SCRIPT_DIR/archive.png" "$ICON_DIR/$APP.png"
fi

# --- Generate .desktop file ---
echo "[4/4] Generating desktop entry..."
mkdir -p "$APP_DIR"

cat > "$APP_DIR/$APP.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zip Unpacker
Comment=Unpack zip files easily on Hyprland
Exec=$BIN_DIR/$APP %f
Icon=$ICON_DIR/$APP.png
Terminal=false
MimeType=application/zip;application/x-7z-compressed;application/x-rar;application/x-xz-compressed-tar;
Categories=Utility;
EOF

# --- Update desktop database ---
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$APP_DIR"
fi

# --- Clean up temporary directory ---
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

echo ""
echo "=== Installation Complete ==="
echo "You can now associate ZIP files with $APP using your file manager (e.g., Thunar, Dolphin, Nemo)."
