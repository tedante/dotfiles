#!/bin/bash

# ==============================================================================
# setup-cachy.sh - Teddy's CachyOS Environment Setup
# Target OS: CachyOS (Arch Linux-based)
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

log_message "===================================================="
log_message "Starting CachyOS environment setup"
log_message "===================================================="

# ==============================================================================
# Step 1: System Update
# ==============================================================================
log_message "Step 1: Updating system packages"
sudo pacman -Syu --noconfirm

# ==============================================================================
# Step 2: Install Base Development Tools
# ==============================================================================
log_message "Step 2: Installing base development tools"
sudo pacman -S --needed --noconfirm base-devel git

# ==============================================================================
# Step 3: Install AUR Helper (yay)
# ==============================================================================
log_message "Step 3: Installing yay (AUR helper)"
if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/yay
else
  log_message "yay is already installed"
fi

# ==============================================================================
# Step 4: Install Core CLI Tools
# ==============================================================================
log_message "Step 4: Installing core CLI tools"
sudo pacman -S --noconfirm \
  zsh \
  git \
  stow \
  fzf \
  unzip \
  btop \
  eza \
  zoxide \
  bat \
  neovim \
  lazygit \
  lazydocker \
  zellij \
  github-cli \
  ripgrep \
  fd \
  jq \
  ffmpeg \
  p7zip \
  poppler \
  imagemagick

log_message "Installing yazi and dependencies"
sudo pacman -S --noconfirm yazi
yay -S --noconfirm resvg

# ==============================================================================
# Step 5: Install GUI Applications
# ==============================================================================
log_message "Step 5: Installing GUI applications"
sudo pacman -S --noconfirm \
  flameshot \
  code \
  ghostty \
  timeshift \
  steam \
  dbeaver

# ==============================================================================
# Step 6: Install Applications from AUR
# ==============================================================================
log_message "Step 6: Installing applications from AUR"
yay -S --noconfirm \
  zoom \
  discord \
  slack-desktop \
  xpipe \
  zen-browser-bin \
  postman-bin \
  visual-studio-code-bin \
  sublime-merge

# ==============================================================================
# Step 7: Setup Docker
# ==============================================================================
log_message "Step 7: Installing and configuring Docker"
sudo pacman -S --noconfirm docker docker-compose

# Start the Docker daemon immediately
sudo systemctl start docker.service

# Enable Docker to start automatically on system boot
sudo systemctl enable docker.service

# Add current user to docker group
sudo usermod -aG docker $USER
log_message "User $USER added to docker group (requires logout to take effect)"

# ==============================================================================
# Step 8: Install Zinit (Zsh Plugin Manager)
# ==============================================================================
log_message "Step 8: Installing Zinit"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
  log_message "Zinit is already installed"
fi

# ==============================================================================
# Step 9: Install Fonts and Development Tools
# ==============================================================================
log_message "Step 9: Installing fonts and development tools"

# Install JetBrains Mono Nerd Font
if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
  mkdir -p ~/.local/share/fonts
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
  unzip -o JetBrainsMono.zip -d ~/.local/share/fonts
  fc-cache -f -v
  rm JetBrainsMono.zip
else
  log_message "JetBrains Mono Nerd Font is already installed"
fi

# Install NVM
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  log_message "NVM is already installed"
fi

# Setup LazyVim starter
mkdir -p "$DOTFILES_DIR/nvim/.config/nvim"
if [ ! -f "$DOTFILES_DIR/nvim/.config/nvim/init.lua" ]; then
  git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/nvim/.config/nvim"
  rm -rf "$DOTFILES_DIR/nvim/.config/nvim/.git"
else
  log_message "LazyVim is already configured"
fi

# ==============================================================================
# Step 10: Link Dotfiles with GNU Stow
# ==============================================================================
log_message "Step 10: Linking dotfiles with GNU Stow"
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

# ==============================================================================
# Step 11: Setup Local Bin Directory
# ==============================================================================
log_message "Step 11: Setting up local bin directory"
mkdir -p ~/.local/bin

# Note: On Arch, bat is already named 'bat', not 'batcat'
# This symlink is only needed on Debian/Ubuntu-based systems
if command -v batcat &>/dev/null; then
  ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

# ==============================================================================
# Step 12: Change Default Shell to Zsh
# ==============================================================================
log_message "Step 12: Changing default shell to Zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
  log_message "Default shell changed to Zsh (requires logout to take effect)"
else
  log_message "Zsh is already the default shell"
fi

log_message "===================================================="
log_message "CachyOS setup complete!"
log_message "===================================================="
log_message ""
log_message "Next steps:"
log_message "  1. Logout and login again for group changes to take effect"
log_message "  2. Setup Git with 'cd $DOTFILES_DIR && ./setup-git.sh'"
log_message "  3. Reboot to ensure all changes take effect"
log_message ""
log_message "Log file saved to: $log_file"
