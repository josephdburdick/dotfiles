---
name: merge-train
description: Use when several open PRs against the same base branch should land as one merge instead of one at a time: a pile of dependabot bumps, "batch these PRs", "merge train", "land all the dependency PRs together", PRs that all touch package.json or the lockfile, or when merging one PR would make the rest go stale and need rebasing.
user_invocable: true
argument-hint: '[PR numbers in order] [--dry-run] [--author app/dependabot] [--verify CMD]'
---

# Merge train

Batch N open PRs into one integration branch, verify once, open one PR. The originals ride
along as merge commits, so they are marked Merged when the train lands.

Five dependabot PRs that each bump the lockfile will all conflict with each other after the
first one merges. Merging them one by one means five rebases, five CI runs, five merges. A
train is one of each.

## Run it

```bash
python3 scripts/merge_train.py --list                  # candidates against the default branch
python3 scripts/merge_train.py --dry-run               # build + verify locally, no push
python3 scripts/merge_train.py                         # push and open the train PR
python3 scripts/merge_train.py 91 89 92 93 90          # explicit order (default: ascending PR number)
python3 scripts/merge_train.py --author app/dependabot --verify "bun run storybook:build"
```

Needs `gh` authenticated, a clean working tree, and the cwd inside the repo. Run `--help` for
every flag. Always do `--dry-run` first and read the summary before opening the PR. The dry run
leaves you on the train branch for inspection; the last line of output says how to get back.
Re-running resets the train branch from the base and rebuilds it. `--verify` adds to the
default scripts, it does not replace them. Dependabot's login for `--author` is `app/dependabot`.

## What the script does for you

- Fetches each PR by `refs/pull/N/head` (works for forks), merges them with `--no-ff` in order.
- Lockfile conflict: keeps the train's lockfile, re-applies the incoming PR's bumps with the
  package manager (`bun update name@version`, or npm/pnpm/yarn equivalents), restores any
  package.json range the update widened, runs a frozen install as an integrity check, and folds
  the result into that PR's merge commit.
- Reads each PR's intended versions (dependabot body, else lockfile diff) and confirms every one
  is a top-level entry in the final lockfile. Nested copies do not count. A bump that cannot be
  reproduced drops that PR with a reason.
- Any non-lockfile conflict drops the PR. It never guesses at source conflicts.
- Runs the repo's `lint`, `typecheck`/`type-check`, `test`, `build` scripts once on the result.

## Judgment calls the script leaves to you

**Extra verification.** Read the workflows that run on push to the base branch. Anything they
build that the default scripts do not (a Storybook or docs build, an e2e suite) goes in
`--verify`. "Mergeable" on GitHub means no conflicts, not that anything passes; many repos run
no tests on PRs at all.

**Landing.** Merge the train PR with a merge commit (`gh pr merge --merge`). The included PR
heads become ancestors of the base branch and GitHub marks them Merged. If the repo squashes,
pass `--close-keywords` so the body carries `Closes #N`, or close the originals by hand after.

**Dropped PRs.** A dropped PR stays open, untouched. Report why. Source conflicts need a human
rebase; a bump that "stayed at X" usually means the PR's package.json range needs widening.

**Order.** Default is ascending PR number, which is arbitrary. Look at `--list` and pass numbers
explicitly when it matters: a PR others depend on goes first (react before react-dom), the
riskiest goes last so it can be dropped without losing the rest.

**Nested duplicates.** A bump can leave an older copy nested under another package (vitest
still pinning its own vite). The train reproduces what the original PR would have done; deduping
is a separate `<pm> update <parent>` follow-up, not part of the train.

## Common mistakes

| Mistake | Why it bites |
|---|---|
| Resolving a lockfile conflict with `--theirs` | The incoming side predates earlier train members; their bumps silently revert and tests still pass. |
| Hand-editing bun.lock / package-lock.json | Nested entries and integrity hashes drift; frozen install fails later on CI. |
| Squash-merging the train with no closing keywords | Originals stay open until dependabot's next run notices. |
| Skipping `--dry-run` | The summary is where you see what got dropped and why, before anything is public. |
| Trusting "mergeable: clean" | Says nothing about lint, types, or tests. |

## Prevent the next pile

For dependabot, add `groups:` to `.github/dependabot.yml` so a week's bumps arrive as one PR.
The train is still the tool for human PRs and for a backlog that already exists.
