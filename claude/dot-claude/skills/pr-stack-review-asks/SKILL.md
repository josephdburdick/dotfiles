---
name: pr-stack-review-asks
description: Use when asking colleagues to review a backlog of stacked PRs — "who needs to review what", "post a review ask", "which PR unblocks the most", "daily review roundup". Groups open PRs into stacks by base-branch chain, finds the one PR per stack whose review actually unblocks work, and writes a pasteable Slack or Markdown message.
user_invocable: true
argument-hint: '[--author <login>] [--format md]'
---

# Review asks for a stack backlog

When you have dozens of open PRs across several Graphite-style stacks, "please review my PRs" is
useless to a colleague — they can't tell which one matters, and most of them don't. The only PR
worth anyone's time is the **bottom-most unapproved PR in each stack**, because stacks merge
bottom-up. A review three PRs up the chain unblocks nothing.

This skill finds those PRs and writes the ask.

## Run it

```bash
python3 scripts/next_review.py -c                    # composer-safe, copied to clipboard
python3 scripts/next_review.py --format mrkdwn -c    # compact links (see below)
python3 scripts/next_review.py --format md           # GitHub markdown
python3 scripts/next_review.py --json                # raw data to post-process
```

Needs `gh` authenticated and the working directory inside the repo. The repo is read from
`gh repo view`, so nothing is hardcoded. `-c/--copy` tries `pbcopy`, `wl-copy`, then `xclip`.

## Pasting into Slack

Slack has two incompatible input modes, and the right format depends on which one is on.

**`paste` (default)** — no markup at all, with each PR's bare URL on its own line under the title.
Slack's WYSIWYG composer renders pasted text literally, so `*bold*` would show its asterisks and
`<url|text>` would show as raw angle brackets. A bare URL is the only thing the composer reliably
auto-links. The title goes on the line above so each entry reads even before the link resolves.

The cost is unfurling: bare GitHub links expand into previews, and ten of them is a wall. Delete
the previews before sending, or use the other format.

**`mrkdwn`** — the compact `<url|text>` form, one line per PR, with real bold and italics. This
needs *Preferences → Advanced → Format messages with markup* enabled, and then it's strictly
better: links carry their own text, so Slack skips the unfurl. Also the correct format for posting
through a webhook or the Slack API, where markup is always interpreted.

If you don't know which mode a workspace is in, `paste` degrades gracefully — worst case it's
verbose. `mrkdwn` in a WYSIWYG composer produces unreadable punctuation soup.

## How stacks are derived

A PR is in the same stack as another when its `baseRefName` is that other PR's `headRefName`.
Follow the chain down until the base is no longer one of your open PRs — that's the root. Depth is
the number of hops. The walk is cycle-guarded, because a mid-stack rebase gone wrong can produce a
base loop that would otherwise hang.

Grouping by base chain rather than by branch-name prefix matters: naming conventions drift, and
stacks get re-parented. The base pointer is what GitHub actually merges against.

## What the script decides, and why

**Drafts are excluded from being the ask** but still count toward stack size. Nobody should be
asked to review a draft, but the drafts above a PR are real work that its review unblocks.

**A stack whose bottom is already approved produces no ask.** It's not blocked on review — it's
blocked on someone pressing merge. Don't put it in a review request; it's a different verb.

**`DIRTY` PRs are flagged, not hidden.** A PR with conflicts will waste a reviewer's time, so the
message says it needs a rebase first rather than silently dropping it (which would make the
backlog look smaller than it is).

**Ranking is by how many PRs sit behind the ask**, not by age or size. That's the number that
tells a reviewer what their fifteen minutes buys.

**`mergeStateStatus` is eventually consistent — treat a missing flag as unknown, not as clean.**
GitHub recomputes mergeability whenever the base branch moves, and returns `UNKNOWN` while it
does. On a busy trunk that's most of the time, so the same PR can report `BLOCKED` on one run and
nothing on the next. The `blocked` and `has conflicts` annotations are therefore best-effort: when
they appear they're true, but their absence proves nothing. Never tell a reviewer a PR is
conflict-free on the strength of one poll.

## The inversion check

The most useful thing this surfaces: a stack where PRs *above* the unreviewed one are already
approved. That means a reviewer worked top-down, and the whole stack is now stuck behind a
foundation nobody looked at.

The script calls these out by number. They're the cheapest wins in the list — the reviewer is
already familiar with the code and has demonstrably been through the stack, so a targeted "you
approved 8 above this one, the base is still blocking" lands better than a generic ask.

## Writing the message

The script's output is postable as-is, but a per-PR line about *what kind of read it is* gets
faster reviews than a bare title. Add it when you know:

- **Codemod-generated?** Say so and give the re-derive command. A reviewer who can regenerate the
  diff doesn't have to read all of it.
- **Provably zero-visual?** Say why — e.g. "the PR below already made the prop inert, so removing
  it can't change rendering, and `tsc` is at 0". That converts a careful read into a skim.
- **Known open findings?** Mention them. A reviewer who discovers a bot's P1 themselves feels
  ambushed; one who was told up front can decide whether to wait.

Don't reorder the asks to steer reviewers at the PR you most want eyes on. If the work you just
changed is mid-stack, the honest ask is still the bottom one — mention the mid-stack PR separately
as context rather than promoting it.

## Cadence

This is worth re-running rather than editing by hand: stacks change shape as things merge, and a
stale ask sends people to a PR that already landed. Regenerate before each post.

If it's genuinely daily, a cron or a shell alias beats remembering. The output is deterministic
given the same PR state, so diffing yesterday's against today's shows what moved.
