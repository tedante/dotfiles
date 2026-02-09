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
  stow zellij
}

link_dotfiles
