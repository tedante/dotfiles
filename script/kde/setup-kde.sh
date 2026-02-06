#!/bin/bash

# ==============================================================================
# setup-kde.sh - Teddy's Master Environment Setup
# Target OS: Kubuntu / KDE Plasma / Ubuntu-based
# ==============================================================================

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

log_message "===================================================="
log_message "Starting master environment setup (setup-kde.sh)"
log_message "===================================================="

# Run setup steps
setup_repositories
install_core_packages "plasma-discover-backend-flatpak kio-extras"
install_ghostty
configure_terminal "kde"

# 4. External Keymap Setup
log_message "Step 4: Calling external keymap setup script"
if [ -f "$DOTFILES_DIR/script/kde/setup-keys.sh" ]; then
  chmod +x "$DOTFILES_DIR/script/kde/setup-keys.sh"
  bash "$DOTFILES_DIR/script/kde/setup-keys.sh"
else
  log_message "Warning: setup-keys.sh not found in $DOTFILES_DIR/script/kde"
fi

install_lazydocker
install_zinit
setup_development_tools
link_dotfiles
post_install_config

log_message "===================================================="
log_message "Master setup complete (setup-kde.sh)"
log_message "===================================================="
