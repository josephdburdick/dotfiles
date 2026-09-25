# claude

Claude Code configuration, stowed to `~/.claude`.

`stow --dotfiles` maps `dot-claude` → `.claude`. Because nothing else in the package
collides, stow *folds* it: `~/.claude` is a single symlink to `claude/dot-claude`, not a
tree of per-file links. Everything Claude Code writes at runtime therefore lands directly
in this repo, which is why `.gitignore` here is mostly a list of runtime noise to ignore.

## Layout

| Path | Tracked | What it is |
| --- | --- | --- |
| `dot-claude/CLAUDE.md` | yes | Global instructions for every project |
| `dot-claude/skills/` | yes | Personal skills (see below) |
| `dot-claude/commands/` | yes | Slash commands — currently `/journal` |
| `dot-claude/templates/` | yes | Templates referenced by skills |
| `dot-claude/plugins.txt` | yes | Plugin manifest, read by the installer |
| `dot-claude/plugins/` | **no** | Downloaded by Claude Code, like `node_modules` |
| `dot-claude/settings.json` | **no** | Machine-specific and auto-generated |
| `dot-claude/projects/` | **no** | Session transcripts *and* per-project memory (see caveat) |

> **Caveat:** `.gitignore` reads as though per-project memory is kept ("keep memory/ but
> ignore conversation logs"), but the later `dot-claude/projects/-Users-joe-*/` rule
> matches every project directory on this machine, so memory is ignored too and does not
> travel to a new machine. Narrow that rule if you want memory to sync.

`settings.json` is deliberately untracked. Claude Code generates it on first run, so
shipping a copy would make `stow` conflict on a fresh machine and block the whole package.
Anything that must survive a reinstall belongs in `plugins.txt` or `CLAUDE.md` instead.

## Commands

`dot-claude/commands/*.md` are relative symlinks to specs in the Obsidian vault
(`../../../../notes/...`, i.e. `~/notes/...` when the repo is at `~/.dotfiles`), so each
machine runs the vault's current spec and nothing needs copying back into the repo. On
macOS `make setup` links `~/notes` to `~/Documents/vaults/personal`; on Linux the vault is
synced to `~/notes` directly.

On Linux `~/.claude` already exists before stow runs, so stow links individual files and
skill directories into it instead of folding the whole directory. Runtime data
(`settings.json`, `projects/`, …) then stays out of the repo.

## Skills

Three different provenances, kept deliberately separate:

**Authored — edit freely.**

- `git-commit-pr` — commit and open a PR
- `llm-tools` — pairs with `bin/.local/bin/llm-{ask,write,extract}` and
  `templates/llm-tools.CLAUDE.md`; delegates bulk reads off the main context
- `pr-before-after-shots` — before/after UI screenshots for a PR stack. Resolves
  `cdp.mjs` from a `chrome-cdp` skill in the *project* being worked on, not from here
- `pr-stack-review-asks` — works out which PR in a stack unblocks the most reviewers

**Vendored — do not hand-edit casually.**

- `use-railway` — Railway's own skill, tracked at v1.3.5, carrying one local patch
  (`6f455e0`) that keeps the API token out of `argv`. Re-vendoring upstream will drop
  that patch; re-apply it.

**Plugin-managed — read-only, updated by Claude Code.** Everything in `plugins.txt`.

### History

An earlier setup vendored 23 skills from `addyosmani/agent-skills` and 121 agent personas
by copy-paste, with no upstream reference recorded. Over three months of sessions, not one
of the 23 skills and not one of the 121 personas was ever invoked, while together they
cost roughly 8,900 tokens of every system prompt. Both were removed in favor of the
`mattpocock-skills` plugin, which is upstream-tracked and roughly 1,600 always-on tokens.

The lesson worth keeping: skills that fire are the ones you *type*. The vendored pack was
entirely model-invoked with ambient descriptions ("Use when making any code change"), so
it competed with the model's own defaults and lost. The four authored skills that do get
used all set `user_invocable: true` with an `argument-hint`. Prefer that shape.

## Plugins

Claude Code owns `~/.claude/plugins/` and records which plugins are enabled in the
untracked `settings.json`, so neither survives a fresh install on its own. `plugins.txt`
is the tracked source of truth; `scripts/.dotscripts/install` installs each entry after
stowing.

Add one:

```bash
echo 'some-plugin' >>claude/dot-claude/plugins.txt
claude plugin install some-plugin --scope user --yes
```

Inspect, update, or remove:

```bash
claude plugin list                      # what is installed and enabled
claude plugin details mattpocock-skills # component inventory + token cost
claude plugin uninstall mattpocock-skills
```

Plugins from `anthropics/claude-plugins-official` need no `marketplace add` step — that
marketplace ships with Claude Code. It pins each plugin to a SHA, so updates arrive when
the pin moves rather than when upstream tags a release.

Before adding a second process-oriented pack, check it against what is already installed.
`superpowers`, for instance, ships its own TDD and code-review skills that would compete
with `mattpocock-skills` for the same triggers.
