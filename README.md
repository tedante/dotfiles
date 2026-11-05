# Teddy's Dotfiles & Workspace Setup

Personal configuration files and automation scripts for a Node.js development and DevOps environment across multiple Linux distributions and macOS.

**Supported Distributions:**

- **Linux Mint (Cinnamon)** — Ubuntu-based
- **Kubuntu (KDE Plasma)** — Ubuntu-based
- **CachyOS** — Arch Linux-based
- **macOS** — Darwin-based

## Quick One-Line Installation

Clones the repository to `~/dotfiles`, installs dependencies, and configures the system.

```bash
# Linux Mint
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mint.sh | bash

# Kubuntu (KDE Plasma)
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-kde.sh | bash

# CachyOS (Arch Linux)
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-cachy.sh | bash

# macOS
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mac.sh | bash
```

Any of them also works as `wget -qO- <url> | bash`. For what each script installs and does, see [Installation](docs/installation.md).

## Overview

The setup follows a "Modern Unix" philosophy, replacing standard tools with faster alternatives.

- **Shell:** Zsh managed by `Zinit`, with the Powerlevel10k theme.
- **Terminal:** Ghostty (Alacritty config also shipped).
- **Editor:** Neovim (LazyVim) and VS Code.
- **Containers:** Podman on Ubuntu, Docker on Arch; Lazydocker for the TUI. A `docker`→`podman` alias is available but commented out in `.zshrc_local_example` — enable it yourself if you want it.
- **Multiplexers:** Tmux and Zellij.
- **Keymap:** hybrid Omarchy-style bindings for Cinnamon and KDE.
- **Package management:** GNU Stow for symlinking configurations.

## Repository Structure

```text
~/dotfiles/
├── alacritty/          # Alacritty terminal configuration (.toml)
├── ghostty/            # Ghostty terminal configuration
├── herdr/              # Herdr configuration
├── nvim/               # LazyVim configuration and plugins
├── zsh/                # .zshrc and custom functions
├── zellij/             # Zellij multiplexer configuration
├── tmux/               # Tmux multiplexer config and plugins
├── systemd/            # Stowed user units (.config/systemd/user)
├── templates/          # Project scaffolding used by zsh's cjsbe
├── script/
│   ├── common.sh       # Shared functions for Ubuntu-based distros
│   ├── install-server.sh    # VPS bootstrap (nginx, ufw, nvm, pm2)
│   ├── organize-folder.sh   # Sort a Downloads folder by file type
│   ├── push-dotfiles.sh     # Push committed changes, never commits
│   ├── automation/
│   │   └── enable-timers.sh # Opt-in: enable/disable the hourly timers
│   ├── cachy/          # CachyOS (Arch Linux) specific scripts
│   ├── kde/            # Kubuntu/KDE Plasma specific scripts
│   └── mint/           # Linux Mint specific scripts
├── install-*.sh        # One-line installers per distribution
└── docs/               # Detailed documentation (see below)
```

## Documentation

| Document                                                 | Contents                                                        |
| -------------------------------------------------------- | --------------------------------------------------------------- |
| [Installation](docs/installation.md)                     | Per-distro setup details, packages installed, logging           |
| [Configuration](docs/configuration.md)                   | Local Zsh customization, manual shortcut steps                  |
| [Maintenance Scripts](docs/maintenance-scripts.md)       | `organize-folder.sh`, `push-dotfiles.sh`                        |
| [Scheduling](docs/scheduling.md)                         | Systemd timers, `enable-timers.sh`, caveats                     |
| [Keybindings](docs/keybindings.md)                       | Desktop shortcuts, Vim cheatsheet                               |

## Local Customization

Machine-specific settings go in `.zshrc_local`, which is sourced by `.zshrc` and ignored by git:

```bash
cp ~/dotfiles/zsh/.zshrc_local_example ~/dotfiles/zsh/.zshrc_local
```

See [Configuration](docs/configuration.md) for details.
