---
description: Scan GitHub + Linear activity and write it into the Obsidian daily note
allowed-tools: Bash, Read, Write, mcp__linear-server__list_issues, mcp__linear-server__get_issue
---

# Daily journal

Turn a day's GitHub and Linear activity into a written entry in the Obsidian
daily note at `/Users/jb/Documents/vaults/personal/03 - DAILY/`.

Arguments: `$ARGUMENTS`

## Resolving the date range

Interpret `$ARGUMENTS` as follows, then state the resolved range before doing anything else:

| Argument | Range |
| --- | --- |
| *(empty)* | yesterday — the default, because this runs at 5am against a finished day |
| `yesterday` | yesterday |
| `today` | today (expect an incomplete picture; say so in the entry) |
| `2026-08-07` | that single day |
| `2026-06-01..2026-08-11` | every day in that inclusive range |
| `last week` / `7 days` | the last 7 complete days, ending yesterday |

Get today's date from `date +%Y-%m-%d` — never assume it.

## Step 1 — Collect

Both scripts live in the vault repo, so every host that runs the journal (the
Mac, the NUC) shares one implementation. `run-nightly.sh` exports
`JOURNAL_SCRIPTS` for its own clone; a manual run on the Mac falls back to the
vault's usual path. Set this once, at the top of the run:

```bash
SCRIPTS="${JOURNAL_SCRIPTS:-/Users/jb/Documents/vaults/personal/99 - META/scripts/daily-journal}"
```

```bash
"$SCRIPTS/collect.sh" <START> [END] > /tmp/journal-activity.json
```

This returns PRs merged, opened, and reviewed, bucketed by **local** calendar day,
with Linear ticket IDs already scanned out of each PR's title, branch, and body.
Reviews are bucketed by when you actually submitted the review.

Check what came back before writing anything:

```bash
jq -r '.days | to_entries[] | "\(.key) merged=\(.value.merged|length) opened=\(.value.opened|length) reviewed=\(.value.reviewed|length)"' /tmp/journal-activity.json
```

Days absent from `.days` had no activity. Skip them — do not create empty notes.

**Assembled is never fetched here.** `collect.sh` excludes `-org:assembledhq` by
default, so the employer repo is never read through the API or CLI. Don't
override `JOURNAL_EXCLUDE`, and don't search for Assembled activity any other way.
Assembled sections are written by hand from the browser, and Step 3 keeps them.

## Step 2 — Enrich from Linear

Collect the distinct ticket IDs for the range:

```bash
jq -r '[.days[][][] | .tickets[]] | unique | join(" ")' /tmp/journal-activity.json
```

Look those up with `list_issues` (or `get_issue` for a handful) to get each one's
title, status, and project. Use this to say *what the work was*, not just which PR
numbers moved.

Two cautions, both learned the hard way:

- **Linear's `updatedAt` is noisy.** Bulk edits restamp dozens of issues at once, so
  "updated that day" is not evidence of work that day. Drive the entry from the PRs;
  use Linear for titles, status, and project grouping.
- **Status names are workflow-specific.** This workspace uses `Merged` and
  `Ready for Merge` as *started* states — `completedAt` is usually null. Report the
  status name as-is rather than inferring completion.

If the Linear MCP is unavailable (it can be, in a headless 5am run), continue without
it and note `Linear enrichment unavailable` at the end of the entry. Never block on it.

## Step 3 — Write the entry

For each day with activity, compose the body, then hand it to the writer:

```bash
cat > /tmp/journal-body.md <<'EOF'
...entry...
EOF
python3 "$SCRIPTS/upsert_note.py" \
  --date <DATE> --body-file /tmp/journal-body.md --tags daily,project/cue-quest
```

**Sections** — `present-day/app.cue.quest`, `present-day/cue.quest` (the marketing
site) and `present-day/clock.cue.quest` go under **Cue Quest**.
`present-day/pooltabl.es` goes under **PoolTabl.es**. Any other repo gets a section
named after its project.

**Tags** — one comma-separated argument, no spaces. Always `daily`, plus
`project/cue-quest` for Cue Quest activity and `project/present-day` for PoolTabl.es
or other `present-day` repos, but only when that project had activity that day.
Existing tags on the note are preserved and merged; you never need to repeat them.

**Keep an existing Assembled section.** Before writing a day, read its note under
`03 - DAILY/YYYY/`. `upsert_note.py` replaces the whole region between the markers,
so if that region already holds an **Assembled** section (added by hand from the
browser), copy it into your body word for word. Order the body as: the
`## Activity — …` header, then the Assembled section, then your sections. A re-run
must never drop it.

### Format

Synthesis is the whole point. A day can hold 30 merged PRs; do **not** list 30 bullets.
Group them into the three or four things that actually happened, and lead with what
changed for a user or a codebase — the PR links are supporting evidence, not the story.

```markdown
## Activity — Thursday, August 6

**Assembled** · 12 merged · 26 opened · 3 reviewed

- Moved Scheduling history into the PageHeaderV2 overflow menu, changing it from
  conditionally present to conditionally disabled so the menu stops shifting between
  companies ([#55512](url)) — UX-6184
- Opened the toolbar→tertiary migration as 11 scoped tickets covering ~180 call sites
  (UX-6506 … UX-6517)

Reviewed: [#55477](url) MultiSelect dismissal (chasen, approved) · [#55507](url) eslint seatbelt

**Cue Quest** · 7 merged

- Drawers now expand to full height when the keyboard opens, and reach the top of the
  viewport on iOS ([#1165](url), [#1169](url))
- Capped Cue Up email fallbacks per broadcast and per day, and stopped broadcasting to
  dormant accounts ([#1166](url), [#1167](url))
```

Rules for the writing itself:

- **American English** — `color`, `behavior`, `canceled`, `analyze`, `center`. Note that
  some Cue Quest PR titles use British spellings; quote them as-is, but never adopt the
  spelling in your own prose.
- Plain past tense, first person implied. No "Successfully implemented", no "Enhanced
  the user experience", no adjectives doing work a fact could do.
- Prefer the effect over the mechanism: "stopped asking for location on every visit"
  beats "refactored the geolocation hook".
- A PR title that already says it well can be used nearly verbatim. Don't pad.
- If a day is mostly one project, don't force the other sections.
- Never invent a ticket, a number, or an outcome. Everything comes from the JSON or Linear.

## What this must never do

The daily note may already hold hand-written thinking — meeting notes, journaling,
product ideas. That content is the reason the vault exists.

`upsert_note.py` protects it structurally: the generated entry lives between
`<!-- daily-journal:start -->` and `<!-- daily-journal:end -->`, and a re-run replaces
only that region. Everything above and below is preserved byte for byte, and an empty
body is a no-op rather than an erase.

So: **always write through `upsert_note.py`.** Never use Write or Edit on a file under
`03 - DAILY/`, even when the note looks empty, and never move the markers.

## Reporting back

Finish with one line per day written, and a total. If a day was skipped, say why. If
`upsert_note.py` printed a duplicate-note warning, surface it — that means two notes
exist for one date and only a human should decide how to merge them.
