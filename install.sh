#!/usr/bin/env bash
set -e

THEME_NAME="gruvbox-dark-cyber-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "Installing $THEME_NAME to $THEME_DIR..."

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (using sudo)"
  exit 1
fi

mkdir -p "$THEME_DIR"
cp -r * "$THEME_DIR/"

echo "Installation complete!"
echo "To use this theme, make sure your /etc/sddm.conf or /etc/sddm.conf.d/ files have:"
echo "[Theme]"
echo "Current=$THEME_NAME"
