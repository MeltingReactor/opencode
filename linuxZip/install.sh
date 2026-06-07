#!/bin/bash
set -e

REPO_OWNER="MeltingReactor"
REPO_NAME="opencode"
REPO_PATH="linuxZip"
BRANCH="main"
APP="zip-unpacker"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

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

echo "=== Installing $APP ==="
echo ""

# --- Detect distro and install dependencies ---
if command -v apt &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo apt update
    sudo apt install -y python3-gi gir1.2-notify-0.7 xdg-utils unar p7zip-full
elif command -v pacman &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo pacman -Sy --noconfirm python-gobject libnotify xdg-utils unarchiver p7zip
elif command -v dnf &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo dnf install -y python3-gobject libnotify xdg-utils unar p7zip p7zip-plugins
elif command -v zypper &>/dev/null; then
    echo "[1/4] Installing system dependencies (requires sudo)..."
    sudo zypper install -y python3-gobject libnotify xdg-utils unar p7zip
else
    echo "Warning: Could not detect package manager."
    echo "Please install: python3-gi, gir1.2-notify-0.7, xdg-utils, unar, p7zip"
fi

# --- Copy the script ---
echo "[2/4] Installing $APP to $BIN_DIR/..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/$APP" "$BIN_DIR/$APP"
chmod 755 "$BIN_DIR/$APP"

# --- Generate .desktop file ---
echo "[3/4] Generating desktop entry..."
mkdir -p "$APP_DIR"

cat > "$APP_DIR/$APP.desktop" << EOF
[Desktop Entry]
Name=Zip Unpacker
Comment=Extract archive files quickly
Exec=$BIN_DIR/$APP %f
Icon=$BIN_DIR/archive.png
Terminal=false
Type=Application
MimeType=application/zip;application/x-zip-compressed;application/x-tar;application/gzip;application/x-bzip2;application/x-xz;application/x-lzma;application/x-7z-compressed;application/x-rar;
Categories=Utility;Compression;
NoDisplay=false
EOF
chmod 644 "$APP_DIR/$APP.desktop"

# Register MIME database
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$APP_DIR" 2>/dev/null || true
fi

# Set as default handler
for mime in application/zip application/x-zip-compressed application/x-tar application/gzip application/x-bzip2 application/x-xz; do
    xdg-mime default "$APP.desktop" "$mime" 2>/dev/null || true
done

# --- Copy icon ---
echo "[4/4] Installing icon..."
cp "$SCRIPT_DIR/archive.png" "$BIN_DIR/archive.png"

# --- Cleanup ---
[ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"

echo ""
echo "=== Done! $APP is installed and set as the default archive handler ==="
echo ""
echo "To test it, double-click any .zip file."
