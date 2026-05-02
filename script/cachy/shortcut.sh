#!/bin/bash

# ==============================================================================
# shortcut.sh - Setup KDE Plasma Keyboard Shortcuts
# ==============================================================================
# This script manages KDE Plasma global shortcuts by linking to a dotfiles
# configuration and restarting the global accelerator service.

set -e

DOTFILES_DIR="${DOTFILES_DIR:=$HOME/dotfiles}"
SHORTCUTS_CONFIG="$DOTFILES_DIR/script/cachy/kglobalshortcutsrc"
SHORTCUTS_DEST="$HOME/.config/kglobalshortcutsrc"

# Helper function for error handling
error_exit() {
  echo "ERROR: $1" >&2
  exit 1
}

# Ensure the shortcuts config exists
if [ ! -f "$SHORTCUTS_CONFIG" ]; then
  error_exit "Shortcuts config not found at $SHORTCUTS_CONFIG"
fi

# Backup existing shortcuts if they exist
if [ -f "$SHORTCUTS_DEST" ]; then
  BACKUP_FILE="$SHORTCUTS_DEST.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$SHORTCUTS_DEST" "$BACKUP_FILE"
  echo "Backed up existing shortcuts to: $BACKUP_FILE"
  
  # Remove the symlink if it already exists
  if [ -L "$SHORTCUTS_DEST" ]; then
    rm "$SHORTCUTS_DEST"
  fi
fi

# Create symlink to dotfiles shortcuts
ln -s "$SHORTCUTS_CONFIG" "$SHORTCUTS_DEST"
echo "Linked shortcuts from: $SHORTCUTS_CONFIG"

# Restart the KDE global accelerator service
systemctl --user restart plasma-kglobalaccel 2>/dev/null || {
  echo "WARNING: Could not restart plasma-kglobalaccel service"
  echo "You may need to restart KDE Plasma for shortcuts to take effect"
}

echo "KDE Plasma shortcuts setup complete!"