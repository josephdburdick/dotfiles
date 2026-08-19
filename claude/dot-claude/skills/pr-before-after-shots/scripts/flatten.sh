#!/usr/bin/env bash
# Flatten before/ and after/ into one folder, moving the state into the filename
# so GitHub's alt text carries it through the upload.
#
#   flatten.sh <outdir>      # -> <outdir>/flat/<TICKET>-<name>-<theme>-<state>.png
set -euo pipefail

OUT="${1:?usage: flatten.sh <outdir>}"
FLAT="$OUT/flat"
mkdir -p "$FLAT"
rm -f "$FLAT"/*.png

for state in before after; do
  d="$OUT/$state"
  [ -d "$d" ] || { echo "missing $d" >&2; exit 1; }
  for f in "$d"/*.png; do
    cp "$f" "$FLAT/$(basename "$f" .png)-$state.png"
  done
done

echo "flattened $(ls "$FLAT"/*.png | wc -l | tr -d ' ') files into $FLAT ($(du -sh "$FLAT" | cut -f1))"
echo
echo "Next: drag these into a scratch PR description in batches of ~20,"
echo "copy the markdown GitHub inserts, then run tables.py on it."
