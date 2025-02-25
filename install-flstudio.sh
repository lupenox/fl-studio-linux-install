#!/bin/bash

# FL Studio Linux Installation Script

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing Wine and dependencies..."
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wine64 wine32 winetricks

echo "Setting up Wine prefix..."
WINEPREFIX=~/.wine winecfg

echo "Downloading FL Studio..."
wget -O ~/flstudio_installer.exe "https://example.com/path/to/flstudio.exe"

echo "Running FL Studio Installer..."
WINEPREFIX=~/.wine wine ~/flstudio_installer.exe

echo "FL Studio installation complete!"
echo "Run 'wine ~/.wine/drive_c/Program\ Files/Image-Line/FL\ Studio\ 20/FL.exe' to start FL Studio"
