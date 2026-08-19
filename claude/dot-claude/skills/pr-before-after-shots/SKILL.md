---
name: pr-before-after-shots
description: Use when a PR or stack of PRs needs before/after UI screenshots — "take before/after screenshots", "capture screenshots for these PRs", "get visual evidence for the stack". Captures both states from a locally served frontend, flattens them for pasting into GitHub, and turns the pasted markdown back into per-PR comparison tables.
user_invocable: true
argument-hint: '[manifest.tsv] (optional)'
---

# Before/after screenshots for a PR stack

Repos that require before/after screenshots on every UI PR make a stack of UI PRs expensive to
evidence by hand. This automates everything except the GitHub upload, which has no API.

The shape of the run:

1. Build a route manifest
2. Capture **after** from the working branch
3. Capture **before** from a baseline worktree
4. Flatten into one folder with `-before` / `-after` in the filename
5. User pastes into a scratch PR; parse what GitHub returns into per-PR tables

## Step 1: Route manifest

A TSV of `ticket<TAB>route<TAB>name<TAB>notes`. If the work is tracked in an issue tracker,
**read the routes off the tickets** rather than grepping the router — migration tickets usually
carry the route and the QA criteria already, and that is better provenance than a guess. Two
reserved values in the ticket column make the capture skip a row and say why:

- `DYNAMIC` — the route has a `:id` that needs a real record
- `BLOCKED` — the page is unreachable in this environment

**Verify every route before a long capture run.** Navigate to each and assert the component you
expect is present, otherwise a mistyped path silently yields dozens of screenshots of a 404.

Routes that redirect are the real trap: a page behind a rollout flag may `<Redirect>` elsewhere
and capture the *destination*, producing two identical files under different names. The dedupe
check in `verify.sh` catches this after the fact; a probe catches it before.

## Step 2: Serve the frontend

Whatever the project's fastest path to a running frontend is. A frontend-only mode pointed at a
shared staging backend is ideal — no local backend to boot, and both passes differ only by
checkout.

If pages are gated by feature flags, force them **client-side** on a throwaway commit rather
than flipping flags in a shared admin tool, which usually changes state for the whole team.
Keep that commit out of every PR.

## Step 3: Capture

Requires Chrome with remote debugging on (`chrome://inspect/#remote-debugging`) and the app open
and signed in. `capture.sh` drives that tab, so it needs no credentials and no login automation.

```bash
scripts/capture.sh after <manifest.tsv> <outdir>
```

It shoots light and dark per route by setting `data-theme` on `document.documentElement`. If the
app resolves theme some other way, adjust the `shot()` helper.

Captures are **viewport-sized**. Do not resize the window between the two passes or the pairs
will not line up.

## Step 4: The before pass

The baseline is whatever the PRs branched from. It needs its own worktree, because both passes
serve from the checkout they run in:

```bash
git worktree add -b <baseline-branch> ../<name> origin/master
cd ../<name>
git cherry-pick <flag-override-commit>   # if the pages are flag-gated
```

Confirm the baseline really is the old state — grep a couple of the touched files for the old
component — then stop the first server, start one here, and:

```bash
scripts/capture.sh before <manifest.tsv> <outdir>
scripts/verify.sh <outdir>
```

`verify.sh` fails on unmatched filenames, mismatched dimensions, duplicate images within a pass,
and any pair where before and after are byte-identical — which means the swap never took.

## Step 5: Flatten and build the tables

```bash
scripts/flatten.sh <outdir>          # -> flat/<TICKET>-<name>-<theme>-<state>.png
```

GitHub has no API for attaching images to a PR body, so this part needs a human: drag the flat
folder into a scratch PR description and copy what GitHub inserts. It preserves each filename as
alt text, which is what makes the last step mechanical:

```bash
scripts/tables.py <pasted.md> <manifest.tsv> <ticket-to-pr.tsv> > tables.md
```

Emits one collapsed `<details>` block per PR with a before/after table per page, light and dark
as separate rows. Paste each into its PR.

Upload in batches of ~20; a hundred at once is where the GitHub uploader starts dropping files.
The parser lists any manifest row it found no image for, so a dropped upload is visible rather
than silent.

## Notes

- Screenshots live outside the repo. Never commit them — the PR body wants GitHub-hosted URLs.
- Re-running after review changes means repeating steps 3 and 5 only. The baseline pass stays
  valid as long as the PR base has not moved.
- One PR often covers several pages, and `ticket-to-pr.tsv` is many-to-one for that reason.
  Confirm the mapping against what each commit actually touches rather than trusting the ticket
  id in the commit subject — those get transposed.
