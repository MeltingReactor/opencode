#!/bin/bash
set -euo pipefail

LOG_FILE="install.log"
echo "Installation started at $(date)" > "$LOG_FILE"

declare -A packages=(
    ["python3([0-9]{0,2})?"]="python3"
    ["qt6"]="qt6-qtbase-devel"
    ["kdialog"]="kdialog"
    ["git"]="git"
)

failures=()

check_and_install() {
    local pattern="$1"
    local pkg="$2"

    if ! dnf list installed 2>/dev/null | grep -E "^$pattern" &>/dev/null; then
        if ! sudo dnf install -y "$pkg" >> "$LOG_FILE" 2>&1; then
            failures+=("$pkg")
            echo "❌ Failed to install $pkg."
        fi
    fi
}

# Install dependencies
for pattern in "${!packages[@]}"; do
    check_and_install "$pattern" "${packages[$pattern]}"
done

if [ ${#failures[@]} -eq 0 ]; then
    echo "✅ Dependencies are installed successfully."
else
    echo "❌ The following dependencies failed to install: ${failures[*]}"
    exit 1
fi

CLONE_DIR="${CLONE_DIR:-KDEiconExporter}"
REPO_URL="https://github.com/MeltingReactor/KDE-Icon-Exporter.git"

# Safety checks
if [[ -z "$CLONE_DIR" ]]; then
    echo "❌ CLONE_DIR is empty. Aborting to prevent serious damage to system. Please report to github issues."
    exit 1
fi

if [[ "$CLONE_DIR" = /* ]]; then
    echo "❌ Absolute paths are not allowed for CLONE_DIR. Aborting to prevent serious damage to system. Please report to github issues."
    exit 1
fi

# Remove existing folder if existing.
if [[ -d "$CLONE_DIR" ]]; then
    rm -rf "$CLONE_DIR"
fi

# Clone repository
if ! git clone "$REPO_URL" "$CLONE_DIR" >> "$LOG_FILE" 2>&1; then
    echo "❌ Git clone failed.."
    exit 1
fi

cd "$CLONE_DIR" || { echo "❌ Cannot enter directory '$CLONE_DIR'"; exit 1; }

echo "python3 main.py" > start.sh
chmod +x start.sh

echo "cd \"$CLONE_DIR\" && ./start.sh" > ../start.sh
chmod +x ../start.sh

echo "✅ Installation finished."

#EOF
