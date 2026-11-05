# Maintenance Scripts

Two standalone scripts keep the machine tidy. Neither is called by the install scripts; run them by hand or schedule them (see [Scheduling](scheduling.md)).

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

## `script/push-dotfiles.sh`

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
