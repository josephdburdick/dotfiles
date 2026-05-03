---
name: git-commit-pr
description: >
  Use this skill whenever the user wants to commit staged or unstaged changes and open a GitHub pull
  request. Triggers include: "commit and open a PR", "write a commit message", "push and create a PR",
  "make a commit", "commit this", "ship this to a PR", "open a pull request", "commit my changes",
  or any combination of committing and PRing. Also trigger when the user says things like "send this
  for review" or "get this into a PR" — even if they don't mention "commit" explicitly. Use this skill
  proactively when the user describes shipping a feature or fix and there are uncommitted changes in
  the working directory.
---

# git-commit-pr

You help the user commit their work and open a GitHub pull request. Your job is to:

1. Understand what changed and why
2. Write a clear, conventional commit message
3. Commit without adding any AI co-author attribution
4. Push the branch and open a PR with a useful description

---

## Step 1 — Understand the changes

Run these to get a full picture of what's in the working directory:

```bash
git status
git diff HEAD          # all changes (staged + unstaged)
git diff --cached      # staged only
git log --oneline -10  # recent history for context
```

If there are both staged and unstaged changes, ask the user whether they want to commit everything or just what's staged. When in doubt, assume everything.

---

## Step 2 — Write the commit message

Use the **Conventional Commits** format:

```
<type>(<scope>): <short imperative summary>

<optional body — what changed and why, wrapped at ~72 chars>
```

**Types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `ci`, `build`

**Scope:** the module, component, or file area affected (e.g. `auth`, `api`, `ui`, `deps`). Omit if the change is truly cross-cutting.

**Summary line:** imperative mood, lowercase, no trailing period, ≤72 chars. Think "this commit will…" — so "add JWT login" not "added JWT login".

**Body (include when the diff alone doesn't explain the why):**
- What problem does this solve?
- Why this approach over alternatives?
- Any important side effects or caveats?

**Examples:**

```
feat(auth): add JWT-based login

Replaces session cookies with stateless JWT tokens so the API can
scale horizontally without shared session storage. Tokens expire
after 24 h; refresh tokens are stored in an httpOnly cookie.
```

```
fix(api): handle null user in /profile endpoint

Previously threw 500 when the user row was deleted but the session
token was still valid. Now returns 404 with a clear error message.
```

---

## Step 3 — Stage and commit (NO co-author line)

Stage everything the user wants to include:

```bash
git add -A        # or specific paths if the user asked for a subset
```

Commit using `--no-edit` style with `-m` flags. **Never** include a `Co-authored-by:` trailer — not for Claude, not for any AI tool. The commit message is the user's work.

```bash
git commit -m "<subject line>" -m "<body paragraph if needed>"
```

If `git commit` returns a non-zero exit code (pre-commit hooks, lint failures, etc.), show the error to the user and stop — don't force-push or skip hooks.

---

## Step 4 — Push the branch

```bash
git push --set-upstream origin HEAD
```

If the push is rejected because the remote branch has diverged, tell the user and ask how they'd like to proceed (rebase vs. merge) — don't rewrite history without explicit permission.

---

## Step 5 — Open the PR

Generate a PR description from the diff and commit history:

```bash
git log origin/main..HEAD --oneline          # commits going into the PR
git diff origin/main...HEAD                  # full diff for the PR
```

Write the PR body in this structure:

```markdown
## What
<!-- One paragraph: what does this PR do? -->

## Why
<!-- One paragraph: motivation, problem being solved, or ticket reference -->

## How
<!-- Brief notes on the approach, key decisions, anything a reviewer should know -->

## Testing
<!-- How was this tested? Unit tests, manual steps, screenshots if relevant -->
```

Keep it factual and concise. Don't pad with filler. If something is obvious from the diff, skip that section rather than restating it.

Then open the PR:

```bash
gh pr create \
  --title "<same as commit subject, or a slightly expanded version>" \
  --body "<the markdown above>" \
  --draft        # use --draft unless user said "ready for review"
```

If the user is on a fork or a specific base branch, adjust accordingly. If `gh` isn't installed or the user isn't authenticated, tell them and show the URL they'd need to open the PR manually.

---

## What to avoid

- **No `Co-authored-by:` lines** — ever. Not `Co-authored-by: Claude`, not `Co-authored-by: GitHub Copilot`. These clutter the git log and add noise to attribution.
- **No force-pushes** without explicit user consent.
- **No empty commits** — if `git status` shows nothing to commit, say so clearly.
- **Don't invent scope or type** — if you're not sure what type fits, prefer `chore` or `refactor` over a misleading `feat`.
- **Don't open the PR as "ready"** unless the user explicitly says so — default to `--draft`.
