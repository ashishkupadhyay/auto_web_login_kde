# VIT Portal Login — KDE Plasma 6 Widget (Plasmoid)

[![KDE Plasma](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-blue.svg)](https://kde.org/plasma-desktop/)
[![Qt](https://img.shields.io/badge/Qt-6.x-brightgreen.svg)](https://qt.io)
[![C++](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org)
[![Platform](https://img.shields.io/badge/Platform-Fedora%20KDE%20%7C%20Arch%20%7C%20openSUSE-informational.svg)](https://fedoraproject.org/spins/kde/)
[![License: GPL-2.0+](https://img.shields.io/badge/License-GPL--2.0%2B-green.svg)](https://www.gnu.org/licenses/gpl-2.0.html)

A native KDE Plasma 6 plasmoid providing automatic and manual login/logout for the **VIT Vellore Pronto Captive Portal** when connected to campus Wi-Fi networks.

Built with **C++17, Qt 6, KDE Frameworks (ECM), and Kirigami**.

---

## Features

- **Automatic Login**: Automatically authenticates when connected to recognized VIT campus Wi-Fi networks after a short DHCP stabilization period.
- **Campus Network Auto-Detection**: Monitors active NetworkManager connections via DBus and detects:
  - `VIT 2.4G` & `VIT 5G`
  - Hostel block Wi-Fi networks: `[A-T]-VIT` (e.g. `A-VIT`, `M-VIT`, `Q-VIT`, etc.)
- **Interactive Kirigami Flyout**:
  - First-time setup onboarding form to save your registration credentials.
  - Active SSID header and status messages.
  - One-click **Login** and **Logout** buttons.
  - Link to open the VIT registration portal account management page.
  - Setup reset button to update or clear saved credentials.
- **Plasma 6 Native**: Uses modern Qt 6 QML components, Kirigami themes, and Plasma 6 Applet APIs.

---

## Repository Structure

```
auto_web_login_kde/
├── CMakeLists.txt                       # Build system configuration
├── install.sh                           # 1-click build and install script for Fedora KDE
├── Makefile                             # make build, make install, make clean
├── package/                             # Plasmoid package definition
│   ├── metadata.json                    # Plasma applet metadata (ID: org.kde.plasma.vitportallogin)
│   ├── icon.svg                         # Widget icon
│   └── contents/
│       ├── config/
│       │   └── main.xml                 # KConfig configuration definition
│       ├── images/
│       │   ├── person-settings.svg      # Account settings icon
│       │   ├── wifi-portal.svg          # Main status icon
│       │   └── wifi-reset.svg           # Reset setup icon
│       └── ui/
│           └── main.qml                 # Kirigami / Plasma QML user interface
└── src/                                 # C++ Qt6 QML extension plugin
    ├── vitportal_plugin.cpp             # QML plugin registration
    ├── vitportalcontroller.h / .cpp     # HTTP captive portal client (QNetworkAccessManager)
    └── ssidwatcher.h / .cpp             # NetworkManager DBus SSID monitor
```

---

## Prerequisites (Fedora KDE)

To build the C++ plugin and install the plasmoid on Fedora KDE:

```bash
sudo dnf install cmake extra-cmake-modules gcc-c++ \
    qt6-qtbase-devel qt6-qtdeclarative-devel
```

---

## Installation on Fedora KDE

### Method 1: Using the Automated Installer (Recommended)

1. Clone or download this repository onto your Fedora machine:
   ```bash
   git clone https://github.com/your-username/auto_web_login_kde.git
   cd auto_web_login_kde
   ```

2. Run the installer script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

---

### Method 2: Manual CMake Build & Install

```bash
# 1. Configure the build
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr

# 2. Compile the Qt6 plugin
cmake --build build --parallel

# 3. Install the plugin and plasmoid
sudo cmake --install build
```

---

## Adding the Widget to Plasma

1. Right-click on your KDE panel or desktop and select **Add Widgets...** (or press `Meta + W`).
2. Search for **VIT Portal Login**.
3. Drag the widget onto your panel or desktop.
4. If the widget does not immediately appear in the list, reload Plasma Shell:
   ```bash
   systemctl --user restart plasma-plasmashell
   ```

---

## First-Time Setup & Usage

1. Click the widget on your panel.
2. If credentials are not yet configured, the onboarding screen will prompt for:
   - **Username** (Registration number, e.g. `21BCE1001`)
   - **Password**
3. Click **Save and continue**.
4. The widget will now automatically log in whenever you connect to campus Wi-Fi.

---

## License

This project is licensed under the [GNU General Public License v2.0 or later (GPL-2.0+)](LICENSE).
