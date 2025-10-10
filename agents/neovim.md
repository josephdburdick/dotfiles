# Neovim Agent Playbook

This repo uses LazyVim. Keep plugin specs small and focused. Avoid editing LazyVim core; extend via user plugins.

## Where to make changes

- `neovim/.config/nvim/lua/plugins/` — add or adjust plugin spec files.
- `neovim/.config/nvim/lazy-lock.json` — updated automatically by Lazy; commit only when intentionally changing versions.
- `neovim/.config/nvim/lua/` — user config modules if needed (avoid sprawling config).

## Adding a plugin (example outline)

1. Create a new file under `neovim/.config/nvim/lua/plugins/` named after the plugin purpose.
2. Return a spec table with minimal configuration.
3. Prefer lazy-loading via `event`, `cmd`, `ft`.

## Do

- Keep one concern per file in `lua/plugins/`.
- Prefer small options tables over large custom code.
- Use `keys` to define mappings close to the plugin that needs them.
- Align with LazyVim patterns and naming.

## Don't

- Edit LazyVim core files.
- Overwrite `init.lua` wholesale.
- Add heavy plugins without lazy-loading.
- Commit lockfile churn unrelated to the change.

## Quick checks

- Start Neovim and ensure no startup errors.
- Run `:Lazy sync` and `:checkhealth` for regressions.
- Verify filetype-specific features if applicable.


