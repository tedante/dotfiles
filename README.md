# Teddy's Dotfiles & Workspace Setup

This repository contains my personal configuration files and automation scripts to bootstrap a Node.js development and DevOps environment across multiple Linux distributions.

**Supported Distributions:**

- **Linux Mint (Cinnamon)** - Ubuntu-based
- **Kubuntu (KDE Plasma)** - Ubuntu-based
- **CachyOS** - Arch Linux-based

## Quick One-Line Installation

For a fresh installation, you can set up everything with a single command. This will clone the repository, install all dependencies, and configure your system:

### Linux Mint

#### Using Curl

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash
```

#### Using Wget

```bash
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash
```

### CachyOS (Arch Linux)

#### Using Curl

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-cachy.sh | bash
```

#### Using Wget

```bash
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-cachy.sh | bash
```

---

## Overview

The setup follows a "Modern Unix" philosophy, replacing standard tools with faster, more efficient alternatives.

### Key Components:

- **Shell:** Zsh managed by `Zinit` with the `Powerlevel10k` theme.
- **Terminal:** Alacritty (System-wide default).
- **Editor:** Neovim (LazyVim distribution) & VS Code.
- **Containers:** Podman (aliased to Docker), Lazydocker.
- **Keymap:** Hybrid Omarchy-style keybindings for Cinnamon.
- **Package Management:** GNU Stow for symlinking configurations.

---

## Repository Structure

```text
~/dotfiles/
├── alacritty/          # Alacritty terminal configuration (.toml)
├── ghostty/            # Ghostty terminal configuration
├── nvim/               # LazyVim configuration and plugins
├── tmux/               # Tmux terminal multiplexer config
├── zsh/                # .zshrc, .p10k.zsh, and custom functions
├── zellij/             # Zellij multiplexer configuration
├── script/
│   ├── common.sh       # Shared functions for Ubuntu-based distros
│   ├── cachy/          # CachyOS (Arch Linux) specific scripts
│   │   └── setup-cachy.sh   # Arch/CachyOS master setup script
│   ├── kde/            # Kubuntu/KDE Plasma specific scripts
│   │   ├── setup-kde.sh     # KDE master installation script
│   │   └── setup-keys.sh    # KDE keybinding automation
│   └── mint/           # Linux Mint specific scripts
│       ├── setup-mint.sh    # Mint master installation script
│       └── setup-keys.sh    # Cinnamon keybinding automation
### Linux Mint / Kubuntu (Ubuntu-based)

The `setup-mint.sh` and `setup-kde.sh` scripts are idempotent and handle:

1. **PPA Registration:** Neovim, Ulauncher, Alacritty, and Lazygit.
2. **Core Tools:** Podman, Steam, VS Code, eza, bat, and more.
3. **Fonts:** JetBrainsMono Nerd Font.
4. **Language Managers:** NVM for Node.js.
5. **Linking:** Automatic symlinking of configs via GNU Stow.

### CachyOS (Arch Linux)

The `setup-cachy.sh` script is idempotent and handles:

1. **System Update:** Full system upgrade via pacman.
2. **AUR Helper:** Automatic installation of yay for AUR packages.
3. **Core Tools:** Docker, Zsh, Neovim, Lazygit, Lazydocker, yazi, and more.
4. **GUI Applications:** Ghostty, VS Code, Steam, Flameshot, DBeaver.
5. **AUR Packages:** Zoom, Discord, Slack, Zen Browser, Postman, Sublime Merge.
6. **Fonts:** JetBrainsMono Nerd Font.
7. **Language Managers:** NVM for Node.js.
8
## Installation Details

The `setup-mint.sh` script is idempotent and handles:

1. **PPA Registration:** Neovim, Ulauncher, Alacritty, and Lazygit.
2. **Core Tools:** Podman, Steam, VS Code, eza, bat, and more.
3. **Fonts:** JetBrainsMono Nerd Font.
4. **Language Managers:** NVM for Node.js.
5. **Linking:** Automatic symlinking of configs via GNU Stow.

### Manual Steps (Required)

Due to desktop environment limitations, these must be set manually in **System Settings -> Keyboard -> Shortcuts -> Custom Shortcuts**:

| Name                | Command                                             | Shortcut            |
| ------------------- | --------------------------------------------------- | ------------------- |
| **Universal Copy**  | `sh -c 'xdotool key --clearmodifiers ctrl+c'`       | `Super + C`         |
| **Universal Paste** | `sh -c 'xdotool key --clearmodifiers shift+insert'` | `Super + V`         |
| **Lazydocker**      | `alacritty -e lazydocker`                           | `Super + Shift + D` |

---

## Master Keybindings (Highlights)

| Action                 | Shortcut                           |
| ---------------------- | ---------------------------------- |
| **Open Terminal**      | `Super + Return`                   |
| **Close Window**       | `Super + Q`                        |
| **Search (Ulauncher)** | `Ctrl + Space`                     |
| **File Manager**       | `Super + Shift + F` or `Super + E` |
| **Switch Workspace**   | `Super + 1, 2, 3, 4`               |
| **Screenshot (Area)**  | `Super + Shift + S`                |

---

## Logging

All installation progress is appended to `~/install_progress_log.txt`. No previous logs are deleted, allowing you to track your machine's history.
```
