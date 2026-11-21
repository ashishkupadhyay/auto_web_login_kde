#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "    VIT Portal Login Plasmoid Installer for KDE Plasma    "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check for essential build tools
MISSING_TOOLS=""
for tool in cmake gcc g++ make; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS="$MISSING_TOOLS $tool"
    fi
done

if [ -n "$MISSING_TOOLS" ]; then
    echo "Error: Required build tools missing:$MISSING_TOOLS"
    echo "Please install CMake, GCC, and Make using your distribution's package manager."
    exit 1
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
echo "If the widget does not appear immediately, restart Plasma Shell:"
echo "  systemctl --user restart plasma-plasmashell"
echo "=========================================================="
