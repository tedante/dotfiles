#!/bin/bash

# --- SETTINGS ---
NVM_VERSION="v0.40.1"
DEFAULT_NODE="22"

# --- COLORS ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running in Docker
IS_DOCKER=false
if [ -f /.dockerenv ] || grep -q 'docker' /proc/self/cgroup; then
  IS_DOCKER=true
  echo -e "${YELLOW}>>> Docker detected. Skipping hardware-level tasks (UFW/Swap).${NC}"
fi

echo -e "${CYAN}=== Starting Server Setup ===${NC}"

# 1. Update and Basic Tools
echo -e "${GREEN}>>> Updating system...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git build-essential software-properties-common

# 2. Install Nginx
echo -e "${GREEN}>>> Installing Nginx...${NC}"
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# 3. Setup Firewall (Skip if Docker)
if [ "$IS_DOCKER" = false ]; then
  echo -e "${GREEN}>>> Configuring Firewall (UFW)...${NC}"
  sudo ufw allow OpenSSH
  sudo ufw allow 'Nginx Full'
  sudo ufw --force enable
else
  echo -e "${YELLOW}>>> Skipping Firewall setup (not supported in Docker).${NC}"
fi

# 4. Install NVM & Node.js
echo -e "${GREEN}>>> Installing NVM and Node.js v${DEFAULT_NODE}...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install $DEFAULT_NODE
nvm use $DEFAULT_NODE
nvm alias default $DEFAULT_NODE

# 5. Global Tools
echo -e "${GREEN}>>> Installing PM2 and Certbot...${NC}"
npm install -g pm2
sudo apt install -y certbot python3-certbot-nginx

# 6. Create Swap File (Skip if Docker)
if [ "$IS_DOCKER" = false ]; then
  if [ ! -f /swapfile ]; then
    echo -e "${GREEN}>>> Creating 2GB Swap...${NC}"
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi
else
  echo -e "${YELLOW}>>> Skipping Swap creation (not supported in Docker).${NC}"
fi

echo -e "${CYAN}=== Setup Complete! ===${NC}"
echo -e "${YELLOW}Run 'source ~/.bashrc' to start using Node/NVM.${NC}"
