#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "   VIT Portal Login Plasmoid Uninstaller for KDE Plasma   "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

# 1. Remove installed files
echo "[1/2] Removing installed files..."
if [ -f "$BUILD_DIR/install_manifest.txt" ]; then
    echo "      Using build/install_manifest.txt..."
    sudo xargs rm -f < "$BUILD_DIR/install_manifest.txt"
    echo "      Files listed in install manifest deleted."
else
    echo "      Removing files from standard installation paths..."
    sudo rm -rf /usr/share/plasma/plasmoids/org.kde.plasma.vitportallogin
    sudo rm -rf /usr/lib64/qt6/qml/org/kde/plasma/private/vitportal
    sudo rm -rf /usr/lib/qt6/qml/org/kde/plasma/private/vitportal
    sudo rm -rf /usr/local/share/plasma/plasmoids/org.kde.plasma.vitportallogin
    sudo rm -rf /usr/local/lib64/qt6/qml/org/kde/plasma/private/vitportal
    sudo rm -rf /usr/local/lib/qt6/qml/org/kde/plasma/private/vitportal
    echo "      System files removed."
fi

# 2. Restart Plasma Shell
echo "[2/2] Reloading Plasma Shell..."
if command -v systemctl &> /dev/null; then
    systemctl --user restart plasma-plasmashell || true
    echo "      Plasma Shell restarted."
else
    echo "      Please restart Plasma or log out and log back in."
fi

echo ""
echo "=========================================================="
echo " Uninstallation Complete!"
echo "=========================================================="
echo "If the widget is still active on your desktop or panel:"
echo "Right-click the panel -> 'Enter Edit Mode' -> Remove widget."
echo "=========================================================="
