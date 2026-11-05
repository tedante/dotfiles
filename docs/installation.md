# Installation

The install scripts are idempotent: running one twice is safe, and existing configs are backed up to `<path>.bak` before being replaced.

Each one-line command below clones the repo to `~/dotfiles` (or updates it if it already exists), then runs the matching setup script.

## Linux Mint (Cinnamon)

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash
```

`setup-mint.sh` sources `script/common.sh` and runs:

1. **PPA registration** — Neovim, Ulauncher, Alacritty, Lazygit.
2. **Core packages** — `zsh alacritty git curl tmux stow build-essential unzip neovim lazygit steam fzf btop podman ripgrep eza zoxide bat ulauncher flameshot code flatpak xdotool` plus `gnome-software-plugin-flatpak`.
3. **Ghostty** — installed from the upstream `.deb`.
4. **Default terminal** — Ghostty set system-wide via `update-alternatives` and as the Cinnamon default.
5. **Keybindings** — `script/mint/setup-keys.sh`.
6. **Lazydocker**, **Zinit**, **JetBrainsMono Nerd Font**, **NVM**, LazyVim starter.
7. **Linking** — configs symlinked with GNU Stow.
8. **Post-install** — Ulauncher service enabled, Flathub remote added, default shell switched to Zsh.

## Kubuntu (KDE Plasma)

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-kde.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-kde.sh | bash
```

Same as Mint, with two differences: the Flatpak backend is `plasma-discover-backend-flatpak kio-extras`, and the default terminal is set through `kdeglobals` instead of `gsettings`.

## CachyOS (Arch Linux)

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-cachy.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-cachy.sh | bash
```

`setup-cachy.sh` is standalone and runs:

1. **System update** — full upgrade via `pacman`.
2. **AUR helper** — `yay` installed if missing.
3. **Core CLI tools** — `zsh git stow fzf unzip btop eza zoxide bat neovim lazygit lazydocker zellij github-cli ripgrep fd jq ffmpeg p7zip poppler tmux zed emacs mise obsidian imagemagick`, plus `yazi`/`resvg`, plus `herdr` via `mise`.
4. **GUI applications** — `flameshot ghostty steam kdenlive audacity vlc obs-studio dbeaver`.
5. **AUR packages** — `zoom discord slack-desktop xpipe zen-browser-bin brave-bin postman-bin visual-studio-code-bin mongodb-compass heroic-games-launcher-bin flameshot-git openwork-bin stremio sublime-merge`.
6. **Docker** — installed, service enabled, user added to the `docker` group.
7. **Zinit**, **JetBrainsMono Nerd Font**, **NVM**, LazyVim starter.
8. **Linking** — configs symlinked with GNU Stow.
9. **KDE keyboard shortcuts** — `script/cachy/shortcut.sh` symlinks `kglobalshortcutsrc` and restarts `plasma-kglobalaccel`.

Unlike Mint/Kubuntu, the CachyOS script does not set Ghostty as the default terminal — it only installs it.

Automation timers are **not** enabled by any install script; see [Scheduling](scheduling.md).

## macOS

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mac.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-mac.sh | bash
```

`setup-mac.sh` runs:

1. **Homebrew** — installed with Apple Silicon detection.
2. **Core CLI tools** — `zsh git stow fzf unzip btop eza zoxide bat neovim lazygit lazydocker zellij gh ripgrep fd jq ffmpeg p7zip poppler imagemagick yazi`.
3. **GUI applications** — `ghostty visual-studio-code docker discord slack zoom postman mongodb-compass dbeaver-community sublime-merge steam`.
4. **Zinit**, **NVM**, **LazyVim** starter.
5. **Linking** — configs symlinked with GNU Stow.

Docker Desktop must be started manually after installation.

## Logging

Every install script appends to `~/install_progress_log.txt`. Nothing is rotated or deleted, so the file becomes a history of every machine you have set up.
