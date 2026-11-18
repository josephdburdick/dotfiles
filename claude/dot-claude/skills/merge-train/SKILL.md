---
name: merge-train
description: 'Use when several open PRs against the same base branch should land as one merge instead of one at a time: a pile of dependabot bumps, "batch these PRs", "merge train", "land all the dependency PRs together", PRs that all touch package.json or the lockfile, or when merging one PR would make the rest go stale and need rebasing.'
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

**Package age (Joe's rule).** Never train or merge a package version published less than 7
days ago. Before building, look up each PR's target version in the npm registry
(`curl -s https://registry.npmjs.org/<name> | jq -r '.time["<version>"]'`). Leave out any PR
that's under a week old or carries the `cooldown` label, and report the date it can merge.
In app.cue.quest the "Package age" check enforces this too.

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

## app.cue.quest

The defaults don't work here: `bun run test` is vitest in watch mode and never exits. Pass
`--no-default-verify` and list the checks yourself. Don't drop the build when you do: a bundle
error (a package that lost its default export, a first-load budget) gets past types and the
mocked unit tests, and only `next build` and the `route-smoke` job catch it.

The build and the checks after it need the `route-smoke` job's dummy env from
`.github/workflows/ci.yml`. Set it only on those commands. Exported for the whole run, it breaks
`envSecret.test.ts`, which expects `AUTH_SECRET` to be missing. Write the env file to the scratchpad
(`$SCRATCH` below), not the repo, so the tree stays clean:

```bash
sed -n '/^  route-smoke:/,/^    steps:/p' .github/workflows/ci.yml \
  | grep -E '^      [A-Z_]+:' \
  | sed -E "s/^ +([A-Z_]+): *'?([^']*)'?$/\1=\2/" > "$SCRATCH/ci-smoke.env"

E="env \$(cat $SCRATCH/ci-smoke.env) SMOKE_PORT=3417 BROWSER_SMOKE_PORT=3418 BUDGET_PORT=3419"
python3 scripts/merge_train.py --dry-run --no-default-verify \
  --verify "bun install --frozen-lockfile" \
  --verify "bun run lint" \
  --verify "bun run test:run" \
  --verify "$E bun run build" \
  --verify "$E bun run smoke:routes" \
  --verify "$E bun run check:browser" \
  --verify "$E bun run check:first-load" \
  2388 2392 2389
```

`lint` runs biome and the type check. The last four steps match the `route-smoke` job, in the
same order. `check:first-load` checks each route's first-load JS against its gzip budget, so a
train can push a route over even when no single PR does. Never push a train built with
`--skip-verify`.

Each of the last three starts its own `next start` and fetches from it, by default on ports
3100, 3102 and 3101. Other worktrees run the same checks on the same ports. If one of their
servers is already listening, the check reads that worktree's pages instead: the budget check then
reports chunks that "aren't in .next/static". The `*_PORT` variables above move the checks off
the defaults. Confirm they're free with `lsof -nP -iTCP:<port> -sTCP:LISTEN`. Port 3000 is
Joe's dev server.

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
