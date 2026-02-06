#!/bin/bash

# Define colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Downloading Teddy's Dotfiles...${NC}"

# 1. Clone the repository into a temporary location or ~/dotfiles
if [ -d "$HOME/dotfiles" ]; then
    echo "Directory ~/dotfiles already exists. Updating..."
    cd "$HOME/dotfiles" && git pull
else
    git clone https://github.com/tedante/dotfiles.git "$HOME/dotfiles"
fi

# 2. Change directory
cd "$HOME/dotfiles"

# 3. Make scripts executable
chmod +x script/mint/setup-mint.sh script/mint/setup-keys.sh

# 4. Execute the master setup script
./script/mint/setup-mint.sh