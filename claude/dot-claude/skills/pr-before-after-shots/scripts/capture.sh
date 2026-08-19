#!/usr/bin/env bash
# Capture one pass (before|after) of a route manifest by driving an already
# signed-in Chrome tab through the chrome-cdp skill.
#
#   capture.sh <before|after> <manifest.tsv> <outdir>
#
# Manifest rows: ticket<TAB>route<TAB>name<TAB>notes
#   ticket DYNAMIC or BLOCKED -> row is skipped with its note printed
#
# Env:
#   BASE_URL    default http://localhost:8080
#   SETTLE      seconds to wait after navigation, default 2.5
#   CDP_SCRIPT  path to chrome-cdp's cdp.mjs, if not discoverable
set -euo pipefail

LABEL="${1:?usage: capture.sh <before|after> <manifest.tsv> <outdir>}"
MANIFEST="${2:?manifest.tsv required}"
OUTROOT="${3:?outdir required}"
case "$LABEL" in before|after) ;; *) echo "label must be before or after" >&2; exit 2 ;; esac

# chrome-cdp may live in the project or in personal skills.
CDP="${CDP_SCRIPT:-}"
if [ -z "$CDP" ]; then
  for c in \
    "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/skills/chrome-cdp/scripts/cdp.mjs" \
    "$HOME/.claude/skills/chrome-cdp/scripts/cdp.mjs"
  do
    [ -f "$c" ] && { CDP="$c"; break; }
  done
fi
[ -n "$CDP" ] && [ -f "$CDP" ] || {
  echo "chrome-cdp's cdp.mjs not found. Set CDP_SCRIPT to its path." >&2; exit 1; }

BASE="${BASE_URL:-http://localhost:8080}"
SETTLE="${SETTLE:-2.5}"
OUT="$OUTROOT/$LABEL"
mkdir -p "$OUT"

# Match the URL column only: a devtools:// window whose title mentions localhost
# must not win, and neither must a production tab.
LISTING="$(node "$CDP" list 2>/dev/null)"
TARGET="$(echo "$LISTING" | awk -v b="$BASE" '$NF ~ "^" b {print $1; exit}')"
if [ -z "$TARGET" ]; then
  echo "No tab whose URL starts with $BASE." >&2
  echo "Enable chrome://inspect/#remote-debugging and open the app there." >&2
  echo "$LISTING" >&2
  exit 1
fi
echo "Driving $TARGET -> $OUT"
echo "$LISTING" | awk -v t="$TARGET" '$1 == t {print "  tab: " $NF}'

shot() { # shot <url> <file> <theme>
  node "$CDP" nav "$TARGET" "$1" >/dev/null
  sleep "$SETTLE"
  node "$CDP" eval "$TARGET" "document.documentElement.setAttribute('data-theme','$3')" >/dev/null
  sleep 0.6
  node "$CDP" shot "$TARGET" "$2" >/dev/null
  echo "  $(basename "$2")"
}

n=0
while IFS=$'\t' read -r ticket route name notes; do
  case "$ticket" in \#*|"") continue ;; esac
  if [ "$ticket" = "DYNAMIC" ] || [ "$ticket" = "BLOCKED" ]; then
    echo "SKIP [$ticket]: $route  -- $notes"
    continue
  fi
  echo "$ticket $route"
  for theme in light dark; do
    shot "$BASE$route" "$OUT/$ticket-$name-$theme.png" "$theme"
    n=$((n+1))
  done
done < "$MANIFEST"

node "$CDP" eval "$TARGET" "document.documentElement.setAttribute('data-theme','light')" >/dev/null
echo "Done: $n screenshots in $OUT"
