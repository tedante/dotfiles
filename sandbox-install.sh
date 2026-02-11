sudo pacman -Syu
sudo pacman -S zsh
chsh -s $(which zsh)
sudo pacman -S git stow fzf unzip btop eza zoxide bat flameshot code ghostty
sudo pacman -S timeshift
sudo pacman -S zellij
sudo pacman -S lazygit
sudo pacman -S lazydocker
sudo pacman -S neovim
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
sudo pacman -S docker docker-compose
# Start the Docker daemon immediately
sudo systemctl start docker.service

# Enable Docker to start automatically on system boot
sudo systemctl enable docker.service

yay -S zoom discord slack-desktop xpipe
yay -S zen-browser-bin
yay -S postman-bin
sudo pacman -S steam
sudo pacman -S dbeaver
yay -S visual-studio-code-bin
sudo pacman -S github-cli
sudo pacman -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
