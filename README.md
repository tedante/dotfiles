# Teddy's Dotfiles & Workspace Setup

This repository contains my personal configuration files and automation scripts to bootstrap a Node.js development and DevOps environment on **Linux Mint (Cinnamon)**.

## Quick One-Line Installation

For a fresh Linux Mint installation, you can set up everything with a single command. This will clone the repository, install all dependencies, and configure your system:

### Using Curl

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash

```

### Using Wget

```bash
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash

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
├── alacritty/      # Alacritty terminal configuration (.toml)
├── nvim/           # LazyVim configuration and plugins
├── tmux/           # Tmux terminal multiplexer config
├── zsh/            # .zshrc, .p10k.zsh, and custom functions
├── script/
│   └── mint/       # Linux Mint specific scripts
│       ├── setup-mint.sh   # Master installation & automation script
│       └── setup-keys.sh   # Cinnamon desktop keybinding automation
└── install-mint.sh # Remote bootstrap script for curl/wget

```

---

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
