# Teddy's Dotfiles & Workspace Setup

This repository contains my personal configuration files and automation scripts to bootstrap a Node.js development and DevOps environment across multiple Linux distributions.

**Supported Distributions:**

- **Linux Mint (Cinnamon)** - Ubuntu-based
- **Kubuntu (KDE Plasma)** - Ubuntu-based
- **CachyOS** - Arch Linux-based
- **macOS** - Darwin-based

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

### macOS

#### Using Curl

```bash
curl -sSL https://raw.githubusercontent.com/tedante/dotfiles/main/install-mac.sh | bash
```

#### Using Wget

```bash
wget -qO- https://raw.githubusercontent.com/tedante/dotfiles/main/install-mac.sh | bash
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
├── systemd/            # Stowed user units (.config/systemd/user)
├── script/
│   ├── common.sh       # Shared functions for Ubuntu-based distros
│   ├── install-mac.sh  # macOS master installation script
│   ├── install-server.sh    # VPS bootstrap (nginx, ufw, nvm, pm2)
│   ├── organize-folder.sh   # Sort a Downloads folder by file type
│   ├── push-dotfiles.sh     # Push committed changes, never commits
│   ├── automation/
│   │   └── enable-timers.sh # Opt-in: enable/disable the hourly timers
│   ├── cachy/          # CachyOS (Arch Linux) specific scripts
│   │   ├── setup-cachy.sh   # Arch/CachyOS master setup script
│   │   └── shortcut.sh      # KDE shortcut symlinking
│   ├── kde/            # Kubuntu/KDE Plasma specific scripts
│   │   ├── setup-kde.sh     # KDE master installation script
│   │   └── setup-keys.sh    # KDE keybinding automation
│   └── mint/           # Linux Mint specific scripts
│       ├── setup-mint.sh    # Mint master installation script
│       └── setup-keys.sh    # Cinnamon keybinding automation
```

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

### macOS

The `install-mac.sh` script is idempotent and handles:

1. **Homebrew:** Automatic installation with Apple Silicon support.
2. **Core CLI Tools:** git, stow, fzf, btop, eza, zoxide, bat, neovim, lazygit, lazydocker, zellij, gh, ripgrep, fd, jq, ffmpeg, p7zip, poppler, imagemagick, yazi.
3. **GUI Applications:** Ghostty, VS Code, Docker Desktop, Discord, Slack, Zoom, Postman, MongoDB Compass, DBeaver, Sublime Merge, Steam.
4. **Zinit:** Zsh plugin manager installation.
5. **Fonts:** JetBrainsMono Nerd Font via Homebrew Cask.
6. **Language Managers:** NVM for Node.js.
7. **LazyVim:** Neovim starter configuration.
8. **Linking:** Automatic symlinking of configs via GNU Stow.

## Installation Details

The `setup-mint.sh` script is idempotent and handles:

1. **PPA Registration:** Neovim, Ulauncher, Alacritty, and Lazygit.
2. **Core Tools:** Podman, Steam, VS Code, eza, bat, and more.
3. **Fonts:** JetBrainsMono Nerd Font.
4. **Language Managers:** NVM for Node.js.
5. **Linking:** Automatic symlinking of configs via GNU Stow.

---

## Configuration

### Local Zsh Customization

If you want to add machine-specific configurations (like custom aliases, environment variables, or paths that shouldn't be tracked in git), you can use `.zshrc_local`:

```bash
cp ~/dotfiles/zsh/.zshrc_local_example ~/dotfiles/zsh/.zshrc_local
```

Then edit `~/dotfiles/zsh/.zshrc_local` with your local customizations. This file is sourced by `.zshrc` but ignored by git.

---

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

## Maintenance Scripts

Two standalone scripts keep the machine tidy. Neither is called by the install scripts; run them by hand or schedule them (see [Scheduling](#scheduling)).

### `script/organize-folder.sh`

Sorts files in a directory into type-based subfolders by extension. Defaults to `~/Downloads`.

```bash
./script/organize-folder.sh                  # organize ~/Downloads
./script/organize-folder.sh /path/to/folder  # organize another directory
./script/organize-folder.sh -n               # dry run, change nothing
```

| Folder        | Extensions                                                                 |
| ------------- | -------------------------------------------------------------------------- |
| `Documents/`  | pdf doc docx odt rtf txt md csv tsv xls xlsx ods ppt pptx odp epub mobi    |
| `Pictures/`   | jpg jpeg png gif svg webp bmp tiff tif heic avif                           |
| `Videos/`     | mp4 mkv mov webm avi wmv flv m4v                                           |
| `Audio/`      | mp3 wav flac ogg m4a aac opus                                              |
| `Archives/`   | zip tar gz bz2 xz 7z rar zst                                               |
| `Code/`       | py js ts jsx tsx sh rb go rs java c h cpp hpp css html json yaml yml toml sql lua |
| `Installers/` | deb rpm appimage exe msi dmg pkg iso                                       |
| `Fonts/`      | ttf otf woff woff2                                                         |

Behavior:

- Only files at the top level of the directory are moved; subfolders are left alone.
- Extension matching is case-insensitive, so `.PDF` and `.pdf` both work.
- Existing files are never overwritten. A name collision prints `skip:` and leaves the file where it is.
- Files matching no rule (no extension, `README`, `.part`, …) stay put.
- Safe to run repeatedly. A second run moves nothing.

To add a type, add one entry to the `DEST` array at the top of the script — the folder is created automatically.

### `script/push-dotfiles.sh`

Pushes committed changes in the dotfiles repo to `origin`. It **never commits**: if the working tree is dirty it stops and prints what is pending, so you stay in control of what gets published.

```bash
./script/push-dotfiles.sh                    # dry run, show what would be pushed
./script/push-dotfiles.sh -p                 # actually push
./script/push-dotfiles.sh -p /path/to/repo   # operate on another clone
```

Checks performed, in order:

1. **Dirty tree** — refuses to run and lists every pending file. Commit or discard first.
2. **Divergence** — if the remote has commits you do not have, it prints both sides' history and exits non-zero. It never merges or rebases.
3. **Behind** — if you are only behind, it tells you to pull and exits.
4. **Secret scan** — inspects every commit that would be pushed, not just the final diff. A secret added in one commit and deleted in a later one is still caught. Matches GitHub/AWS/OpenAI/Slack token shapes, private key headers, and credential-style assignments, plus `.env`, `*.pem`, `*.key`, `id_rsa` and similar filenames. Only `file:line` is printed, never the matched value. `.env.example`, `.sample` and `.template` are allowed.
5. **Push** — only after all of the above pass.

Requires SSH access to GitHub (`git remote -v` must show `git@github.com:...`). For HTTPS remotes run `gh auth setup-git` first, otherwise `git push` fails with `could not read Username`.

Exit codes: `0` pushed or nothing to do, `1` refused (dirty, diverged, behind) or failed.

---

## Scheduling

Both scripts have a matching systemd user unit in `systemd/.config/systemd/user/`. The timer runs the script from the repo, so nothing is duplicated.

| Script               | Service                     | Timer                     | Schedule      |
| -------------------- | --------------------------- | ------------------------- | ------------- |
| `organize-folder.sh` | `organize-download.service` | `organize-download.timer` | hourly, `:00` |
| `push-dotfiles.sh`   | `push-dotfiles.service`     | `push-dotfiles.timer`     | hourly, `:00` |

Both timers use `Persistent=true`: a run missed while the machine was asleep fires once on wake.

### Installing the timers

Timers are **opt-in**. The install scripts do not enable them, so a fresh setup never starts moving files or pushing to GitHub without you asking.

Use `script/automation/enable-timers.sh`:

```bash
./script/automation/enable-timers.sh            # stow units, reload, enable both
./script/automation/enable-timers.sh --disable  # stop and disable both
./script/automation/enable-timers.sh --status   # show state, change nothing
```

What it does on enable: stows the `systemd` package, runs `systemctl --user daemon-reload`, then `enable --now` on both timers. Before touching anything it checks that the repo exists, the unit files are present, `stow` is installed, and a systemd user session is reachable.

Doing it by hand is equivalent:

```bash
cd ~/dotfiles
stow systemd
systemctl --user daemon-reload
systemctl --user enable --now organize-download.timer
systemctl --user enable --now push-dotfiles.timer
```

`setup-cachy.sh` does not stow or enable the units; automation is entirely opt-in. On Mint/Kubuntu `common.sh` behaves the same way. Run `enable-timers.sh` after any install.

### Inspecting and controlling

```bash
systemctl --user list-timers                      # next run for every timer
systemctl --user start organize-download.service  # run once now
systemctl --user start push-dotfiles.service      # run once now
journalctl --user -u organize-download -f         # follow the organizer log
journalctl --user -u push-dotfiles -f             # follow the push log
systemctl --user disable --now push-dotfiles.timer  # stop the hourly push
```

Output goes to journald only; neither script writes a log file.

### Caveats

- **The hourly push fails loudly while your tree is dirty.** That is intentional — it is your reminder that there is unpushed work. Each failed run logs an `error: uncommitted changes` line. If that noise is unwelcome, disable the timer and push by hand.
- **`systemctl --user enable` writes into the repo.** `~/.config/systemd` is stowed, so the enablement symlinks under `timers.target.wants/` land in the working tree. That path is gitignored, but it still means enabling a unit touches the repo directory.
- **The fold is not reproducible on a fresh clone.** When the target directory does not already exist, stow folds the whole directory into a symlink instead of linking individual files. Re-stow with `stow --no-folding systemd` to link only the unit files and keep `~/.config/systemd` a real directory.
- **Automation is opt-in on every distro.** No install script stows or enables the timer units. Use `enable-timers.sh`.

---


All installation progress is appended to `~/install_progress_log.txt`. No previous logs are deleted, allowing you to track your machine's history.

```

```
