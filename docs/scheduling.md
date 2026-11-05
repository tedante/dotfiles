# Scheduling

Both maintenance scripts have a matching systemd user unit in `systemd/.config/systemd/user/`. The timer runs the script from the repo, so nothing is duplicated.

| Script               | Service                     | Timer                     | Schedule      |
| -------------------- | --------------------------- | ------------------------- | ------------- |
| `organize-folder.sh` | `organize-download.service` | `organize-download.timer` | hourly, `:00` |
| `push-dotfiles.sh`   | `push-dotfiles.service`     | `push-dotfiles.timer`     | hourly, `:00` |

Both timers use `Persistent=true`: a run missed while the machine was asleep fires once on wake.

## Installing the timers

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

`setup-cachy.sh` does not stow or enable the units; automation is entirely opt-in on every distro. Run `enable-timers.sh` after any install.

## Inspecting and controlling

```bash
systemctl --user list-timers                      # next run for every timer
systemctl --user start organize-download.service  # run once now
systemctl --user start push-dotfiles.service      # run once now
journalctl --user -u organize-download -f         # follow the organizer log
journalctl --user -u push-dotfiles -f             # follow the push log
systemctl --user disable --now push-dotfiles.timer  # stop the hourly push
```

Output goes to journald only; neither script writes a log file.

## Caveats

- **The hourly push fails loudly while your tree is dirty.** That is intentional — it is your reminder that there is unpushed work. Each failed run logs an `error: uncommitted changes` line. If that noise is unwelcome, disable the timer and push by hand.
- **`systemctl --user enable` writes into the repo.** `~/.config/systemd` is stowed, so the enablement symlinks under `timers.target.wants/` land in the working tree. That path is gitignored, but it still means enabling a unit touches the repo directory.
- **The fold is not reproducible on a fresh clone.** When the target directory does not already exist, stow folds the whole directory into a symlink instead of linking individual files. Re-stow with `stow --no-folding systemd` to link only the unit files and keep `~/.config/systemd` a real directory.
