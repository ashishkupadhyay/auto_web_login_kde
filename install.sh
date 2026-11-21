#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "    VIT Portal Login Plasmoid Installer for Fedora KDE    "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check required dependencies
MISSING_DEPS=""
for pkg in cmake extra-cmake-modules gcc-c++ qt6-qtbase-devel qt6-qtdeclarative-devel; do
    if ! rpm -q $pkg &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $pkg"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo "Notice: Recommended build packages may be missing: $MISSING_DEPS"
    echo "If the build fails, install them via:"
    echo "  sudo dnf install $MISSING_DEPS"
    echo ""
fi

# Configure and build
echo "[1/3] Configuring with CMake..."
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

echo "[2/3] Compiling C++ Qt6 plugin..."
cmake --build build --parallel

echo "[3/3] Installing Plasmoid and QML plugin..."
sudo cmake --install build

echo ""
echo "=========================================================="
echo " Installation Complete!"
echo "=========================================================="
echo "To add the widget to your KDE desktop or panel:"
echo "1. Right-click on your KDE panel or desktop -> 'Add Widgets...'"
echo "2. Search for 'VIT Portal Login'."
echo "3. Drag it onto your panel or desktop."
echo ""
echo "If the widget does not appear immediately, restart Plasma:"
echo "  systemctl --user restart plasma-plasmashell"
echo "=========================================================="
