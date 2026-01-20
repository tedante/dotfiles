#!/bin/bash

# ==============================================================================
# setup-mint.sh - Teddy's Master Environment Setup
# Target OS: Linux Mint (Cinnamon) / Ubuntu-based
# ==============================================================================

# Initialization: Use the existing log file and append new data
log_file=~/install_progress_log.txt

# Function to log messages with timestamps
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Redirect stdout and stderr to tee for persistent logging
exec > >(tee -a "$log_file") 2>&1

log_message "===================================================="
log_message "Starting master environment setup (setup-mint.sh)"
log_message "===================================================="

# Stop script execution if any command fails
set -e

# Configuration variables
DOTFILES_DIR="$HOME/dotfiles"

# 1. Repository Setup
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

# 2. Main Package Installation
log_message "Step 2: Installing core CLI, GUI, and dependencies"
sudo apt install -y \
  zsh alacritty git curl tmux stow build-essential unzip \
  neovim lazygit steam fzf btop podman ripgrep eza zoxide bat \
  ulauncher flameshot code flatpak gnome-software-plugin-flatpak \
  xdotool

# Create symlink for 'bat'
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat

# 3. Default Terminal Configuration
log_message "Step 3: Setting Alacritty as the default terminal"
ALACRITTY_PATH=$(which alacritty)

if [ -n "$ALACRITTY_PATH" ]; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ALACRITTY_PATH" 50
  sudo update-alternatives --set x-terminal-emulator "$ALACRITTY_PATH"
  gsettings set org.cinnamon.desktop.default-applications.terminal exec 'alacritty'
  gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg ''
  log_message "System-wide and Cinnamon terminal preference set to Alacritty"
fi

# 4. External Keymap Setup
log_message "Step 4: Calling external keymap setup script"
if [ -f "$DOTFILES_DIR/setup-keymap.sh" ]; then
  chmod +x "$DOTFILES_DIR/setup-keymap.sh"
  bash "$DOTFILES_DIR/setup-keymap.sh"
else
  log_message "Error: setup-keymap.sh not found in $DOTFILES_DIR"
fi

# 5. Lazydocker Installation
log_message "Step 5: Setting up Lazydocker binary"
if ! command -v lazydocker &>/dev/null; then
  curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
  sudo ln -sf ~/.local/bin/lazydocker /usr/local/bin/lazydocker 2>/dev/null || true
fi

# 6. Zinit Installation
log_message "Step 6: Installing Zinit"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 7. Fonts, NVM, and LazyVim Starter
log_message "Step 7: Configuring Fonts, NVM, and LazyVim starter"
if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
  mkdir -p ~/.local/share/fonts
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
  fc-cache -f -v
  rm JetBrainsMono.zip
fi
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
mkdir -p "$DOTFILES_DIR/nvim/.config/nvim"
if [ ! -f "$DOTFILES_DIR/nvim/.config/nvim/init.lua" ]; then
  git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/nvim/.config/nvim"
  rm -rf "$DOTFILES_DIR/nvim/.config/nvim/.git"
fi

# 8. GNU Stow (Configuration Symlinking)
log_message "Step 8: Linking dotfiles with GNU Stow"
cd "$DOTFILES_DIR"
backup_for_stow() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mv "$1" "$1.bak"
    log_message "Backup created for $1"
  fi
}
backup_for_stow ~/.zshrc
backup_for_stow ~/.p10k.zsh
backup_for_stow ~/.config/alacritty
backup_for_stow ~/.config/nvim
stow zsh
stow alacritty
stow nvim
stow tmux

# 9. Post-Installation Configuration
log_message "Step 9: Finalizing services and shell"
systemctl --user enable --now ulauncher
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
fi

log_message "===================================================="
log_message "Master setup complete (setup-mint.sh)"
log_message "===================================================="

