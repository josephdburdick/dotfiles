# Homebrew & Stow Agent Playbook

Manage installation state declaratively via `Brewfile` and GNU Stow. Do not add imperative installs to shell init files.

## Homebrew

- Make changes only in `Brewfile`.
- Use `brew bundle` to apply.
- Keep taps, brews, casks organized and deduplicated.

## Stow

- Each top-level directory mirrors `$HOME` layout.
- Use `stow --dotfiles --dir ~/.dotfiles --target ~ <package>` to link.
- Use `stow -D ... <package>` to unlink.
- Use `stow -n` for dry runs before linking.

## Safety checks

- `brew bundle` passes with no errors.
- `stow -n` shows expected links only.


