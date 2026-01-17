#!/bin/bash

# ==============================================================================
# Script Name    : server-setup.sh
# Description    : Automated Production Server Setup for Node.js Applications.
# Features       : SSH-Keygen, NVM, PM2, Nginx, UFW, and Dotfiles (GNU Stow).
# Compatibility  : Ubuntu 22.04+ (Works on Bare Metal & Containers)
# ==============================================================================

set -e

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================================${NC}"
echo -e "${BLUE}        🚀 STARTING SERVER INITIALIZATION...           ${NC}"
echo -e "${BLUE}==========================================================${NC}"

# --- 0. Environment Detection ---
IS_CONTAINER=false
if [ -f /.dockerenv ] || [ -f /run/.containerenv ] || grep -q 'docker\|lxc\|kubepods' /proc/1/cgroup; then
  IS_CONTAINER=true
  echo -e "${YELLOW}[Info]${NC} Container environment detected. Systemd/Firewall features will be adjusted."
fi

# --- 1. Variable Initialization ---
# Load variables from .env if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Determine GitHub email from .env, argument, or prompt
GITHUB_EMAIL=${GITHUB_EMAIL:-$1}

if [ -z "$GITHUB_EMAIL" ]; then
  echo -e "${YELLOW}[Input Required]${NC} GitHub email not found."
  read -p "Enter your GitHub email for SSH generation: " GITHUB_EMAIL
fi

if [ -z "$GITHUB_EMAIL" ]; then
  echo -e "${RED}[Error]${NC} Email is required. Aborting."
  exit 1
fi

# --- 2. System Preparation & Repositories ---
echo -e "\n${BLUE}[Step 1/7] Updating system and adding repositories...${NC}"
apt update -y
apt install -y sudo gpg wget curl software-properties-common

# Enable 'universe' repository for packages like 'bat'
sudo add-apt-repository universe -y

# Add Neovim Stable PPA
sudo add-apt-repository ppa:neovim-ppa/stable -y

# Add Eza repository (Modern 'ls' replacement)
if ! command -v eza &>/dev/null; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
fi

sudo apt update -y

# --- 3. Core Package Installation ---
echo -e "\n${BLUE}[Step 2/7] Installing CLI tools and server stack...${NC}"
sudo apt install -y \
  neovim git tmux stow build-essential openssh-client \
  zsh fzf btop unzip podman ripgrep \
  zoxide bat eza \
  nginx fail2ban python3-certbot-nginx

# Fix 'bat' command (Ubuntu installs it as 'batcat')
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat

# --- 4. SSH Key Generation ---
echo -e "\n${BLUE}[Step 3/7] Generating SSH Key (Ed25519)...${NC}"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -N "" -f "$HOME/.ssh/id_ed25519"
  echo -e "${GREEN}[Success]${NC} SSH Key generated."
else
  echo -e "${YELLOW}[Skip]${NC} SSH Key already exists."
fi

# --- 5. Security & Firewall ---
if [ "$IS_CONTAINER" = false ]; then
  echo -e "\n${BLUE}[Step 4/7] Configuring UFW Firewall...${NC}"
  sudo ufw allow OpenSSH
  sudo ufw allow 'Nginx Full'
  sudo ufw --force enable
else
  echo -e "\n${YELLOW}[Step 4/7] Skipping Firewall configuration (Container Mode).${NC}"
fi

# --- 6. Node.js Environment (NVM & PM2) ---
echo -e "\n${BLUE}[Step 5/7] Setting up Node.js via NVM & PM2...${NC}"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  # Load NVM for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  nvm install --lts
  npm install -g pm2
  echo -e "${GREEN}[Success]${NC} Node.js LTS and PM2 installed."
fi

# --- 7. Dotfiles Setup ---
echo -e "\n${BLUE}[Step 6/7] Applying Dotfiles with GNU Stow...${NC}"
DOTFILES_DIR="$HOME/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
  cd "$DOTFILES_DIR"
  # Backup existing config files to avoid conflicts
  [ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak
  [ -f ~/.p10k.zsh ] && mv ~/.p10k.zsh ~/.p10k.zsh.bak

  # Link configuration folders
  stow zsh nvim tmux
  echo -e "${GREEN}[Success]${NC} Configurations linked."
else
  echo -e "${YELLOW}[Warning]${NC} Dotfiles directory not found at $DOTFILES_DIR."
fi

# --- 8. Finalization ---
echo -e "\n${BLUE}[Step 7/7] Finalizing shell settings...${NC}"
sudo chsh -s $(which zsh) $USER

echo -e "\n${GREEN}==========================================================${NC}"
echo -e "${GREEN}        🎉 SERVER SETUP COMPLETED SUCCESSFULLY!         ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo -e "\n${YELLOW}NEXT STEPS:${NC}"
echo -e "1. Add the public key below to your GitHub Settings:"
echo -e "${BLUE}----------------------------------------------------------${NC}"
cat "$HOME/.ssh/id_ed25519.pub"
echo -e "${BLUE}----------------------------------------------------------${NC}"
echo -e "2. Log out and log back in to activate Zsh."
echo -e "3. Point your domain to this IP and run: sudo certbot --nginx"

