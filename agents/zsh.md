# ZSH Agent Playbook

Zsh is managed with Zinit. Keep login shell fast and robust. Prefer guarded, lazy-loaded plugins.

## Key files

- `zsh/dot-zshrc` — main entry, plugin manager, top-level init.
- `zsh/.dotrc/config.zsh` — environment variables and PATH management.
- `shell/.dotrc/shell/` — aliases and functions shared with bash (`common.sh`, plus `darwin.sh` / `linux.sh`).
- `zsh/.dotrc/extra/` — zsh-only per-topic extras (fzf, tui).

## Guidelines

- Avoid heavy or networked work in RC files.
- Use feature detection and guards (`command -v` checks) before invoking tools.
- Put portable aliases and functions in `shell/.dotrc/shell/common.sh` rather than bloating `dot-zshrc`.
- Install CLIs with `_zinit_bin` in `dot-zshrc`; it skips anything Homebrew or the system package manager already provides.
- Prefer lazy-loading in Zinit for big plugins or CLIs.

## Safe edits

- When adding a plugin, ensure it does not duplicate existing functionality.
- Keep PATH mutations centralized in `config.zsh`.
- Use comments sparingly to document non-obvious choices.

## Quick checks

- Start a new shell; ensure no errors and prompt appears quickly.
- `type <new-cmd>` resolves as expected.





