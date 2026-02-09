#!/bin/bash

echo "🚀 Git & SSH Setup Wizard"
echo "--------------------------"

# Function to handle 'read' for both Bash and Zsh
prompt_input() {
    local prompt_text=$1
    local default_value=$2
    local var_name=$3
    local input

    if [ -n "$ZSH_VERSION" ]; then
        read "input?$prompt_text [$default_value]: "
    else
        read -p "$prompt_text [$default_value]: " input
    fi

    # Use default if input is empty
    eval "$var_name=\"${input:-$default_value}\""
}

# 1. Get User Input
prompt_input "Enter Git Name" "Teddy" GIT_NAME
prompt_input "Enter Git Email" "your-email@example.com" GIT_EMAIL

echo "✅ Configured as: $GIT_NAME <$GIT_EMAIL>"

# 2. Configure Git Global
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

# 3. Setup SSH
SSH_FILE="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_FILE" ]; then
    echo "🔑 Generating new SSH key (Ed25519)..."
    # -N "" means no passphrase for automation
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_FILE" -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_FILE"
else
    echo "⚠️  SSH Key already exists at $SSH_FILE. Skipping generation."
fi

# 4. Display Public Key
echo ""
echo "-------------------------------------------------------"
echo "📋 Copy this public key to GitHub (https://github.com/settings/keys):"
echo ""
cat "${SSH_FILE}.pub"
echo ""
echo "-------------------------------------------------------"