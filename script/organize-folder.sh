#!/usr/bin/env bash
# Organize files in DIR (default: ~/Downloads) into type-based subfolders.
# Usage: organize-download.sh [-n] [DIR]
#   -n   dry run: print what would move, change nothing

set -euo pipefail

usage() {
  printf 'usage: %s [-n] [DIR]\n' "${0##*/}" >&2
  exit "${1:-0}"
}

DRY_RUN=false
while getopts ':nh' opt; do
  case "$opt" in
    n) DRY_RUN=true ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
shift $((OPTIND - 1))

DIR="${1:-$HOME/Downloads}"
if [[ ! -d "$DIR" ]]; then
  printf 'error: not a directory: %s\n' "$DIR" >&2
  exit 1
fi

# The rule table: lowercase extension -> destination subfolder.
# Add a type here and both the folder and the move rule exist.
declare -A DEST=(
  # Documents
  [pdf]=Documents   [doc]=Documents   [docx]=Documents  [odt]=Documents   [rtf]=Documents
  [txt]=Documents   [md]=Documents    [csv]=Documents   [tsv]=Documents
  [xls]=Documents   [xlsx]=Documents  [ods]=Documents
  [ppt]=Documents   [pptx]=Documents  [odp]=Documents
  [epub]=Documents  [mobi]=Documents
  # Pictures
  [jpg]=Pictures    [jpeg]=Pictures   [png]=Pictures    [gif]=Pictures
  [svg]=Pictures    [webp]=Pictures   [bmp]=Pictures    [tiff]=Pictures  [tif]=Pictures
  [heic]=Pictures   [avif]=Pictures
  # Videos
  [mp4]=Videos      [mkv]=Videos      [mov]=Videos      [webm]=Videos
  [avi]=Videos      [wmv]=Videos      [flv]=Videos      [m4v]=Videos
  # Audio
  [mp3]=Audio       [wav]=Audio       [flac]=Audio      [ogg]=Audio
  [m4a]=Audio       [aac]=Audio       [opus]=Audio
  # Archives
  [zip]=Archives    [tar]=Archives    [gz]=Archives     [bz2]=Archives
  [xz]=Archives     [7z]=Archives     [rar]=Archives    [zst]=Archives
  # Code
  [py]=Code         [js]=Code         [ts]=Code         [jsx]=Code       [tsx]=Code
  [sh]=Code         [rb]=Code         [go]=Code         [rs]=Code        [java]=Code
  [c]=Code          [h]=Code          [cpp]=Code        [hpp]=Code       [css]=Code
  [html]=Code       [json]=Code       [yaml]=Code       [yml]=Code       [toml]=Code
  [sql]=Code        [lua]=Code
  # Installers / disk images
  [deb]=Installers  [rpm]=Installers  [appimage]=Installers
  [exe]=Installers  [msi]=Installers  [dmg]=Installers  [pkg]=Installers [iso]=Installers
  # Fonts
  [ttf]=Fonts       [otf]=Fonts       [woff]=Fonts      [woff2]=Fonts
)

for sub in "${DEST[@]}"; do
  mkdir -p -- "$DIR/$sub"
done

moved=0
skipped=0
while IFS= read -r -d '' file; do
  ext="${file##*.}"
  dest="${DEST[${ext,,}]:-}"
  [[ -n $dest ]] || continue

  target="$DIR/$dest/${file##*/}"
  if [[ -e $target ]]; then
    printf 'skip: %s (already in %s/)\n' "$file" "$dest"
    skipped=$((skipped + 1))
    continue
  fi

  if $DRY_RUN; then
    printf 'would move: %s -> %s/\n' "$file" "$dest"
  else
    mv -n -- "$file" "$target"
    printf 'moved: %s -> %s/\n' "$file" "$dest"
  fi
  moved=$((moved + 1))
done < <(find "$DIR" -maxdepth 1 -type f -print0)

printf 'done: %d handled, %d skipped, in %s\n' "$moved" "$skipped" "$DIR"
