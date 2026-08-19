#!/usr/bin/env bash
# Check that a before/after capture pair is usable.
#
#   verify.sh <outdir>       # expects <outdir>/before and <outdir>/after
#
# Fails on: unmatched filenames, mismatched dimensions, duplicate images within
# a pass (a route that redirected elsewhere), or a byte-identical before/after
# pair (the app was never swapped between passes).
set -euo pipefail

OUT="${1:?usage: verify.sh <outdir>}"
B="$OUT/before"; A="$OUT/after"
[ -d "$B" ] && [ -d "$A" ] || { echo "need $B and $A" >&2; exit 1; }
rc=0

# sips is macOS-only; fall back to `file` elsewhere.
dimsof() {
  if command -v sips >/dev/null 2>&1; then
    sips -g pixelWidth -g pixelHeight "$1" 2>/dev/null \
      | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}'
  else
    file "$1" | grep -oE '[0-9]+ x [0-9]+' | head -1 | tr -d ' '
  fi
}
hashof() { if command -v md5 >/dev/null 2>&1; then md5 -q "$1"; else md5sum "$1" | cut -d' ' -f1; fi; }

echo "== filename sets =="
if diff <(cd "$B" && ls *.png) <(cd "$A" && ls *.png) >/dev/null 2>&1; then
  echo "  ok: $(cd "$B" && ls *.png | wc -l | tr -d ' ') matched pairs"
else
  echo "  MISMATCH:"; diff <(cd "$B" && ls *.png) <(cd "$A" && ls *.png) || true; rc=1
fi

echo "== dimensions =="
dims=$(for f in "$B"/*.png "$A"/*.png; do dimsof "$f"; done | sort -u)
if [ "$(echo "$dims" | wc -l | tr -d ' ')" = "1" ]; then
  echo "  ok: all $dims"
else
  echo "  MIXED (window resized between passes):"; echo "$dims" | sed 's/^/    /'; rc=1
fi

echo "== duplicates within a pass =="
for d in "$B" "$A"; do
  dup=$(for f in "$d"/*.png; do hashof "$f"; done | sort | uniq -d)
  if [ -n "$dup" ]; then
    echo "  $(basename "$d"): DUPLICATES -- a route probably redirected"; rc=1
    for h in $dup; do for f in "$d"/*.png; do
      [ "$(hashof "$f")" = "$h" ] && echo "    $(basename "$f")"
    done; done
  else
    echo "  $(basename "$d"): ok"
  fi
done

echo "== identical pairs =="
same=0
for f in "$B"/*.png; do
  b=$(basename "$f")
  [ -f "$A/$b" ] || continue
  if [ "$(hashof "$f")" = "$(hashof "$A/$b")" ]; then echo "  IDENTICAL: $b"; same=$((same+1)); rc=1; fi
done
[ "$same" = 0 ] && echo "  ok: every pair differs"

exit $rc
