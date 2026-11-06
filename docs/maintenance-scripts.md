# Maintenance Scripts

Three standalone scripts keep the machine tidy and in sync. None is called by the install scripts; run them by hand or schedule the first two (see [Scheduling](scheduling.md)).

## `script/organize-folder.sh`

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

## `script/git-autopush.sh`

Commits and/or pushes the repos listed in `script/repos-auto-push`. That file is gitignored because the paths are machine-specific. Copy the tracked `script/repos-auto-push.example` to create it. Each line is a path and a mode:

```
/home/you/dotfiles   push
/home/you/notes      commit
```

The default list sits next to the script, so it is found no matter where the repo is cloned or what the current directory is.

- `commit` stages everything with `git add -A`, commits with a `sync: <host> <date> (<n> files)` message, then pushes.
- `push` never commits. A dirty tree stops the run and lists what is pending.

Blank lines and `#` comments are ignored. Every entry is attempted even if an earlier one fails; the script exits non-zero at the end and names the failures.

```bash
./script/git-autopush.sh                 # dry run, every repo in the list
./script/git-autopush.sh -p              # actually commit and push
./script/git-autopush.sh -p /path/to/list   # use another list
```

Checks performed per repo, in order:

1. **Secrets in untracked files** (`commit` mode only) — scanned before they become history, because removing one afterwards needs a history rewrite rather than an edit.
2. **Dirty tree** — a `push` entry refuses and lists every pending file.
3. **Index lock** — if another git process holds `index.lock`, it waits up to 60 seconds, then gives up rather than committing a half-written index.
4. **Divergence** — if the remote has commits you do not have, it prints both sides' history and exits non-zero. It never merges or rebases.
5. **Behind** — if you are only behind, it tells you to pull and exits.
6. **Secret scan** — inspects every commit that would be pushed, not just the final diff. A secret added in one commit and deleted in a later one is still caught. Matches GitHub/AWS/OpenAI/Slack token shapes, private key headers, and credential-style assignments, plus `.env`, `*.pem`, `*.key`, `id_rsa` and similar filenames. Only `file:line` is printed, never the matched value. `.env.example`, `.sample` and `.template` are allowed.
7. **Push** — only after all of the above pass.

Requires SSH access to GitHub (`git remote -v` must show `git@github.com:...`). For HTTPS remotes run `gh auth setup-git` first, otherwise `git push` fails with `could not read Username`.

Exit codes: `0` all repos handled, `1` any repo refused or failed.

## `script/automation/link-opencode.sh`

Links the `opencode/` package into `~/.config/opencode` so the agent configuration is versioned and restorable. Linking is opt-in: no install script does it.

```bash
./script/automation/link-opencode.sh            # link (backs up conflicts first)
./script/automation/link-opencode.sh --unlink   # remove the package's symlinks
./script/automation/link-opencode.sh --status   # report linked/not linked
```

The script stows with `--no-folding`, so `~/.config/opencode` stays a real directory and each packaged file is an individual symlink. Anything that creates new files there (session history, caches) stays out of the repo instead of landing inside it.

If a real file already sits at a packaged path, it is renamed to `<path>.bak` before linking. Unrelated files in the same directory are never touched.

`--status` exits `0` when linked and `1` when not linked, and changes nothing.

### The credential is deliberately excluded

`~/.config/opencode/service.json` holds a password. This repository is public, so that file is **not** part of the package and is listed in `.gitignore`. The linking script enforces the exclusion: before stowing it inspects the package contents, and if any file matches a credential filename (`service.json`, `.env`, `id_rsa`, …) or contains a token shape, it aborts with a non-zero exit and prints the offending path. Only the path is printed, never the value.

That guard is not a formality. Adding the secret back to the package "to keep the config complete" would publish it on the next push.

`DOTFILES_DIR` overrides the repo location, which is what makes the script testable against a throwaway home directory.
