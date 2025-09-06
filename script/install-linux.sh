log_file=~/install_progress_log.txt

echo "==================="
echo "Starting Linux setup"
echo "==================="

sudo apt update
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt update

# Essential
sudo apt -y install neovim
sudo apt -y install git
sudo apt -y install curl
sudo apt -y install tmux
sudo apt -y install wget
sudo apt -y install stow
sudo apt -y install build-essential

# Terminal
sudo apt -y install zsh
sudo apt -y install zsh-syntax-highlighting
sudo apt -y install zsh-autosuggestions

# Tools
sudo apt -y install fzf
sudo apt -y install btop
sudo apt -y install unzip
sudo apt -y install podman
sudo apt -y install flatpak

# Fonts
sudo apt -y install fonts-firacode
sudo apt -y install fonts-powerline
sudo apt -y install fonts-inter
sudo apt -y install fonts-nerd-fonts
sudo apt -y install fonts-meslo

# Homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flatpak setup
sudo apt -y install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# flatpak install --user flathub io.podman_desktop.PodmanDesktop

# Node Setup (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
nvm install --lts

echo "==================="
echo "Linux setup complete"
echo "==================="