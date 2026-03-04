#!/bin/bash

# ==============================================================================
# install-mac.sh - Teddy's macOS Environment Setup
# Target OS: macOS
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
log_message "Starting macOS environment setup"
log_message "===================================================="

# ==============================================================================
# Step 1: Install Homebrew
# ==============================================================================
log_message "Step 1: Installing Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for Apple Silicon Macs
  if [[ $(uname -m) == 'arm64' ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  log_message "Homebrew is already installed"
fi

brew update

# ==============================================================================
# Step 2: Install Core CLI Tools
# ==============================================================================
log_message "Step 2: Installing core CLI tools"
brew install \
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
  jesseduffield/lazygit/lazygit \
  jesseduffield/lazydocker/lazydocker \
  zellij \
  gh \
  ripgrep \
  fd \
  jq \
  ffmpeg \
  p7zip \
  poppler \
  imagemagick \
  yazi

# ==============================================================================
# Step 3: Install GUI Applications
# ==============================================================================
log_message "Step 3: Installing GUI applications"
brew install --cask \
  ghostty \
  visual-studio-code \
  docker \
  discord \
  slack \
  zoom \
  postman \
  mongodb-compass \
  dbeaver-community \
  sublime-merge \
  steam

# Install flameshot alternative for macOS (native screenshot tools are good on macOS)
# Or use alternative: brew install --cask shottr

# ==============================================================================
# Step 4: Setup Docker
# ==============================================================================
log_message "Step 4: Docker Desktop installed (manual start required)"
# Docker Desktop must be manually started on macOS
log_message "Please start Docker Desktop manually from Applications"

# ==============================================================================
# Step 5: Install Zinit (Zsh Plugin Manager)
# ==============================================================================
log_message "Step 5: Installing Zinit"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
  log_message "Zinit is already installed"
fi

# ==============================================================================
# Step 6: Install Fonts and Development Tools
# ==============================================================================
log_message "Step 6: Installing fonts and development tools"

# Install JetBrains Mono Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

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
# Step 7: Link Dotfiles with GNU Stow
# ==============================================================================
log_message "Step 7: Linking dotfiles with GNU Stow"
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
stow zellij

# ==============================================================================
# Step 8: Setup Local Bin Directory
# ==============================================================================
log_message "Step 8: Setting up local bin directory"
mkdir -p ~/.local/bin

# ==============================================================================
# Step 9: Change Default Shell to Zsh
# ==============================================================================
log_message "Step 9: Verifying Zsh is the default shell"
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
  log_message "Default shell changed to Zsh (requires logout to take effect)"
else
  log_message "Zsh is already the default shell"
fi

log_message "===================================================="
log_message "macOS setup complete!"
log_message "===================================================="
log_message ""
log_message "Next steps:"
log_message "  1. Start Docker Desktop from Applications"
log_message "  2. Logout and login again for shell changes to take effect"
log_message "  3. Setup Git with 'cd $DOTFILES_DIR && ./setup-git.sh'"
log_message "  4. Restart Terminal or run 'source ~/.zshrc'"
log_message ""
log_message "Log file saved to: $log_file"
