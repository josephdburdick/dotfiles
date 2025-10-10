# AI.md

This is a concise playbook for AI agents working in this repo. It explains where things live, how to make safe edits, and the conventions to follow so changes remain idempotent and easy to maintain.

## Repo facts

- macOS-focused dotfiles using GNU Stow. Files named `dot-*` become `.*` in `$HOME`.
- Package management via Homebrew with a `Brewfile` and `brew bundle`.
- Key areas: `zsh/`, `neovim/`, `tmux/`, `starship/`, `kitty/`, `wezterm/`, `git/`, `bin/`, `scripts/`.
- See `WARP.md` for terminal-oriented ops and commands.

## Ground rules for agents

- Prefer minimal, incremental edits; avoid sweeping refactors.
- Preserve existing indentation, line endings, and formatting.
- Use absolute file paths in explanations and tooling when possible.
- Do not add index barrel files.
- Keep changes idempotent. Avoid installing packages in shell init paths.
- If you modify installation/management, prefer `brew bundle` and `stow` flows over bespoke commands.

## Stow and layout

- Every top-level directory corresponds to a tool. Inside, files mimic `$HOME` structure.
- Use `stow --dotfiles --dir ~/.dotfiles --target ~ <package>` to link and `-D` to unlink.
- When adding a new tool config, create a new top-level directory and mirror the target paths. Name files with `dot-` when they should be hidden in `$HOME`.

## Homebrew policy

- Add or remove packages only in `Brewfile`. Do not script `brew install` inside shell RCs.
- Install via `brew bundle` (see `WARP.md`). Keep the `Brewfile` tidy (group taps, brews, casks).
- Prefer documenting optional tools rather than auto-installing in RC files.

## ZSH policy

- Primary file: `zsh/dot-zshrc` (Zinit plugin manager is used here).
- Environment and PATHs: `zsh/.dotrc/config.zsh`.
- Aliases and functions: `zsh/.dotrc/extra/aliases.zsh` (and siblings under `zsh/.dotrc/extra/`).
- Keep login time fast: avoid heavy commands in RC; guard optional features; defer work.
- When adding plugins, prefer lazy-loading in Zinit; avoid duplicate functionality.

## Neovim policy

- Root: `neovim/.config/nvim/` (LazyVim-based).
- Plugins live under `neovim/.config/nvim/lua/plugins/` as small, focused files.
- Update `neovim/.config/nvim/lazy-lock.json` only as a result of intentional plugin/version changes.
- Follow LazyVim conventions; avoid rewriting core LazyVim files. Add/override via user plugin specs.

## Cursor and Warp

- Warp guidance is in `WARP.md`.
- Cursor usage: prefer small, targeted edits; keep changes self-contained per file; adhere to this guide. Place any Cursor-specific notes under `cursor/`.

## Change management

- Explain which files you changed and why.
- Keep edits narrow and reversible. Avoid breaking interactive shells or editor startup.
- When adding new configs, include a brief inline comment only when a non-obvious rationale or caveat exists.

## Safety checklist before finishing

- ZSH still starts cleanly with no errors or long delays.
- Neovim starts without errors; `:checkhealth` has no regressions for common providers.
- `brew bundle` succeeds; `stow -n` previews expected links.
- Mac-specific paths are respected; no Linux-only commands added by default.

## Useful commands

```bash
# Link a package
stow --dotfiles --dir ~/.dotfiles --target ~ <package>

# Unlink a package
stow -D --dotfiles --dir ~/.dotfiles --target ~ <package>

# Install Homebrew packages defined in Brewfile
brew bundle --file ~/.dotfiles/Brewfile
```



