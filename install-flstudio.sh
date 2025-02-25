#!/bin/bash

# FL Studio Linux Installation Script
# Author: Logan Lapierre (@Lupenox)
# Description: Installs FL Studio on Linux using Wine with automated setup and fixes.

LOG_FILE="flstudio_install.log"

# Function to log messages
echo_log() {
    echo -e "[ $(date +'%Y-%m-%d %H:%M:%S') ] $1" | tee -a "$LOG_FILE"
}

echo "================ FL Studio Linux Installer ================"
echo "This script will install FL Studio on your Linux system using Wine."
echo "==========================================================="

echo_log "Starting installation..."

# Ensure the script is run as a normal user
if [[ $EUID -eq 0 ]]; then
    echo_log "Do not run this script as root! Please run it as a regular user."
    exit 1
fi

# Check for dependencies
dependencies=("wine" "winetricks" "wget")
missing_deps=()
for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        missing_deps+=("$dep")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo_log "Missing dependencies: ${missing_deps[*]}"
    read -p "Would you like to install them now? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        sudo apt update && sudo apt install -y ${missing_deps[*]}
    else
        echo_log "Installation aborted. Please install the missing dependencies manually."
        exit 1
    fi
fi

# Set up Wine prefix
WINEPREFIX="$HOME/.flstudio-wine"
export WINEPREFIX
export WINEARCH=win64

# Configure Wine
winecfg &

echo_log "Configuring Wine to Windows 10 mode..."
wine reg add "HKCU\\Software\\Wine\\DllOverrides" /v dwrite /t REG_SZ /d "" /f

# Install required Wine components
winetricks fontsmooth-rgb gdiplus corefonts vcrun2019
echo_log "Installed necessary Wine components."

# Ask user for FL Studio installer location
read -p "Enter the path to your FL Studio installer (.exe): " FL_INSTALLER
if [[ ! -f "$FL_INSTALLER" ]]; then
    echo_log "Error: File not found. Please check the path and try again."
    exit 1
fi

# Run FL Studio Installer
wine "$FL_INSTALLER"
echo_log "FL Studio installation process started. Follow the on-screen instructions."

# Create a desktop shortcut
DESKTOP_FILE="$HOME/Desktop/fl-studio.desktop"
echo "[Desktop Entry]
Name=FL Studio
Exec=env WINEPREFIX=$WINEPREFIX wine 'C:\\Program Files\\Image-Line\\FL Studio 20\\FL64.exe'
Type=Application
StartupNotify=true
Icon=$WINEPREFIX/drive_c/Program Files/Image-Line/FL Studio 20/FL64.ico" > "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE"
echo_log "Created a desktop shortcut for FL Studio."

echo_log "Installation complete! You can now launch FL Studio from the shortcut or run:"
echo "    WINEPREFIX=$WINEPREFIX wine 'C:\\Program Files\\Image-Line\\FL Studio 20\\FL64.exe'"
exit 0



