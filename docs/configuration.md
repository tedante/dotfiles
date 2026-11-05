# Configuration

## Local Zsh Customization

Machine-specific settings (aliases, env vars, paths) belong in `.zshrc_local`, which is sourced at the end of `.zshrc` and ignored by git.

```bash
cp ~/dotfiles/zsh/.zshrc_local_example ~/dotfiles/zsh/.zshrc_local
```

Edit `~/dotfiles/zsh/.zshrc_local` with your local customizations.

The repo path is deliberate: `~/.zshrc_local` is a symlink to `~/dotfiles/zsh/.zshrc_local` (stow creates it alongside `~/.zshrc`). Editing either path changes the same file. Because the real file lives inside the repo, the ignore pattern in `.gitignore` is what keeps it out of version control — do not remove that line.

## Manual Steps (Required)

These cannot be automated because the desktop environment does not expose them. Set them in **System Settings → Keyboard → Shortcuts → Custom Shortcuts**.

| Name                | Command                                             | Shortcut            |
| ------------------- | --------------------------------------------------- | ------------------- |
| **Universal Copy**  | `sh -c 'xdotool key --clearmodifiers ctrl+c'`       | `Super + C`         |
| **Universal Paste** | `sh -c 'xdotool key --clearmodifiers shift+insert'` | `Super + V`         |
| **Lazydocker**      | `alacritty -e lazydocker`                           | `Super + Shift + D` |
