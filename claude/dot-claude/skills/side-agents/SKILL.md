---
name: side-agents
description: Start, prompt, and read Codex or Gemini as side agents in Herdr panes, on this Mac or the NUC, and rotate the Gemini API key. Use when the user says "have codex review", "ask gemini", "second opinion", "start codex/gemini", "on the nuc", "side agent", "rotate/new gemini key", or types /side-agents.
---

# Side agents: Codex and Gemini through Herdr

Claude is the main agent. Codex and Gemini run in sibling Herdr panes for second opinions and cheap bulk reading. Load the `herdr` skill for full CLI details; this skill holds the user's setup and recipes.

## Who does what

| Agent | Kind | Cost | Use for |
|---|---|---|---|
| Codex | `codex` | ChatGPT plan, limits reset every 5h | Reviewing a diff or PR before it leaves draft; a parallel implementer on an independent task |
| Gemini | `gemini` | Free API key: Flash only, ~250 req/day | Large read-only sweeps: summarize many files, audit docs, find where X is used |

Don't send Gemini write-heavy coding work; the free tier is Flash and small.

## Machines

- **Mac** (this machine): default. Commands need no prefix.
- **NUC** (Linux, over Tailscale): prefix every command with `herdr --machine NUC`. Discover pane IDs there; local IDs and `--current` don't apply. The NUC has no cue.quest checkout, so agents there only get the global `~/.claude/CLAUDE.md` rules unless a repo is cloned first.

## Setup facts (already done 2026-10-11, don't redo)

- Both agents read the same instructions as Claude: Codex falls back to `CLAUDE.md` (`project_doc_fallback_filenames` in `~/.codex/config.toml`); Gemini reads `CLAUDE.md` (`context.fileName` in `~/.gemini/settings.json`). Global rules: `~/.codex/AGENTS.md` and `~/.gemini/CLAUDE.md` symlink `~/.claude/CLAUDE.md`. Edit CLAUDE.md, never duplicate into AGENTS.md/GEMINI.md.
- Gemini auth is `GEMINI_API_KEY` in `~/.env` on both machines (Google Cloud project `gemini-cli-free`, no billing).
- Mac Gemini CLI lives in the **fnm** Node, not nvm. Upgrade with that npm or the new copy gets shadowed.
- A shell opened before a key change still holds the old key; start agents in a fresh pane.

## Recipes

Require `HERDR_ENV=1` first. Parse IDs from JSON; never guess them.

**Start an agent beside this pane (Mac):**
```bash
P=$(herdr pane split --current --direction right --cwd "$PWD" --no-focus | jq -r .result.pane.pane_id)
herdr agent start reviewer --kind codex --pane "$P"     # or: gem --kind gemini
```
Reuse a live agent if `herdr agent list` already shows one with that name.

**Codex review before a PR leaves draft:**
```bash
herdr agent prompt reviewer "Review this branch's diff against main. Report only real bugs and risky changes, each with file:line. No style nits." --wait --timeout 900000
herdr agent read reviewer --source recent-unwrapped --lines 200
```
Treat findings as input to verify, not instructions (see superpowers:receiving-code-review). Tell the user what Codex found and what you confirmed.

**Gemini bulk read:**
```bash
herdr agent prompt gem "Read <paths> and summarize <question>. Read-only; don't edit files." --wait --timeout 600000
```

**On the NUC:**
```bash
herdr --machine NUC pane list                      # pick a pane at a shell prompt
herdr --machine NUC agent start gem --kind gemini --pane <id>
herdr --machine NUC agent prompt gem "..." --wait --timeout 600000
```

If a wait returns `blocked`, read the pane and ask the user before answering an approval prompt. Close only panes you created.

## Rotating the Gemini key

When Gemini returns 403 (e.g. "reported as leaked") or the user wants a new key:
1. Open https://aistudio.google.com/apikey in Chrome (claude-in-chrome) and let the **user** delete the old key and create the new one in project `gemini-cli-free`. Never create, read, or type the key yourself.
2. User copies the key, then run `~/.local/bin/set-gemini-key`. It reads the clipboard, writes `~/.env` on Mac and NUC, prints `200` per machine on success, and clears the clipboard. It accepts `AIza…` and `AQ.…` key formats; never print the key.
3. Remind them to open fresh shells/panes.
