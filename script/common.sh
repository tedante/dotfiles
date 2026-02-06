#!/bin/bash

# ==============================================================================
# common.sh - Shared functions for all setup scripts
# ==============================================================================

# Logging setup
log_file=~/install_progress_log.txt

# Function to log messages with timestamps
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Redirect stdout and stderr to tee for persistent logging
exec > >(tee -a "$log_file") 2>&1

# Stop script execution if any command fails
set -e

# Configuration variables
DOTFILES_DIR="$HOME/dotfiles"

# ==============================================================================
# Repository Setup
# ==============================================================================
setup_repositories() {
  log_message "Step 1: Configuring Repositories and PPAs"
  sudo apt update && sudo apt install -y wget gpg apt-transport-https

  # Add PPAs
  sudo add-apt-repository ppa:neovim-ppa/stable -y
  sudo add-apt-repository ppa:agornostal/ulauncher -y
  sudo add-apt-repository ppa:aslatter/ppa -y
  sudo add-apt-repository ppa:lazygit-team/ppa -y

  # Add official VS Code Repository
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg

  sudo apt update
}

# ==============================================================================
# Core Package Installation
# ==============================================================================
install_core_packages() {
  local de_specific_packages="$1"
  
  log_message "Step 2: Installing core CLI, GUI, and dependencies"
  
  # Core packages that are common to all environments
  local core_packages="zsh alacritty git curl tmux stow build-essential unzip \
    neovim lazygit steam fzf btop podman ripgrep eza zoxide bat \
    ulauncher flameshot code flatpak xdotool"
  
  sudo apt install -y $core_packages $de_specific_packages

  # Create symlink for 'bat'
  mkdir -p ~/.local/bin
  ln -sf /usr/bin/batcat ~/.local/bin/bat
}

# ==============================================================================
# Ghostty Terminal Installation
# ==============================================================================
install_ghostty() {
  log_message "Installing Ghostty terminal"
  if ! command -v ghostty &>/dev/null; then
    GHOSTTY_VERSION="1.0.1"
    wget -q "https://github.com/ghostty-org/ghostty/releases/download/v${GHOSTTY_VERSION}/ghostty_${GHOSTTY_VERSION}_amd64.deb" -O /tmp/ghostty.deb
    sudo dpkg -i /tmp/ghostty.deb || sudo apt-get install -f -y
    rm /tmp/ghostty.deb
  fi
}

# ==============================================================================
# Terminal Configuration (Desktop Environment Specific)
# ==============================================================================
configure_terminal() {
  local de_type="$1"
  
  log_message "Step 3: Setting Ghostty as the default terminal"
  GHOSTTY_PATH=$(which ghostty)

  if [ -n "$GHOSTTY_PATH" ]; then
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$GHOSTTY_PATH" 50
    sudo update-alternatives --set x-terminal-emulator "$GHOSTTY_PATH"
    
    case "$de_type" in
      "cinnamon")
        gsettings set org.cinnamon.desktop.default-applications.terminal exec 'ghostty'
        gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg ''
        log_message "System-wide and Cinnamon terminal preference set to Ghostty"
        ;;
      "kde")
        kwriteconfig5 --file kdeglobals --group General --key TerminalApplication ghostty
        log_message "System-wide and KDE Plasma terminal preference set to Ghostty"
        ;;
    esac
  fi
}

# ==============================================================================
# Lazydocker Installation
# ==============================================================================
install_lazydocker() {
  log_message "Step 5: Setting up Lazydocker binary"
  if ! command -v lazydocker &>/dev/null; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    sudo ln -sf ~/.local/bin/lazydocker /usr/local/bin/lazydocker 2>/dev/null || true
  fi
}

# ==============================================================================
# Zinit Installation
# ==============================================================================
install_zinit() {
  log_message "Step 6: Installing Zinit"
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  fi
}

# ==============================================================================
# Fonts, NVM, and LazyVim Setup
# ==============================================================================
setup_development_tools() {
  log_message "Step 7: Configuring Fonts, NVM, and LazyVim starter"
  
  # Install JetBrains Mono Nerd Font
  if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
    mkdir -p ~/.local/share/fonts
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
    fc-cache -f -v
    rm JetBrainsMono.zip
  fi
  
  # Install NVM
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
  
  # Setup LazyVim starter
  mkdir -p "$DOTFILES_DIR/nvim/.config/nvim"
  if [ ! -f "$DOTFILES_DIR/nvim/.config/nvim/init.lua" ]; then
    git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/nvim/.config/nvim"
    rm -rf "$DOTFILES_DIR/nvim/.config/nvim/.git"
  fi
}

# ==============================================================================
# GNU Stow Configuration Linking
# ==============================================================================
link_dotfiles() {
  log_message "Step 8: Linking dotfiles with GNU Stow"
  cd "$DOTFILES_DIR"
  
  backup_for_stow() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
      mv "$1" "$1.bak"
      log_message "Backup created for $1"
    fi
  }
  
  # Backup existing configs
  backup_for_stow ~/.zshrc
  backup_for_stow ~/.p10k.zsh
  backup_for_stow ~/.config/alacritty
  backup_for_stow ~/.config/ghostty
  backup_for_stow ~/.config/nvim
  backup_for_stow ~/.config/zellij
  
  # Stow configurations
  stow zsh
  stow alacritty
  stow ghostty
  stow nvim
  stow tmux
  stow zellij
}

# ==============================================================================
# Post-Installation Configuration
# ==============================================================================
post_install_config() {
  log_message "Step 9: Finalizing services and shell"
  
  systemctl --user enable --now ulauncher
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
  fi
}
