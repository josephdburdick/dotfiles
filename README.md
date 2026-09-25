<h1 align="center">~/.dotfiles</h1>

<p align="center"><sub>One repo for my macOS and Arch Linux machines — shell, git, editor, terminal and Claude Code config, managed with GNU Stow.</sub></p>

## Highlights

- **One command per machine.** `make setup` detects macOS, [Omarchy](https://omarchy.org) or other Linux and links only the configs that make sense there.
- **Plays nicely with Omarchy.** Terminal, editor, tmux and prompt configs are left to Omarchy so its theme switching keeps working; you still get the shell layer, git, scripts and Claude Code config.
- **Same commands in bash and zsh.** Git/GitHub helpers like `gcob 6014` (check out the branch matching a ticket number), `gcof` (fzf branch picker) and `cdr` (jump to repo root) work in both shells, on both OSes.
- **Fast zsh.** Zinit with turbo loading, syntax highlighting and autosuggestions; CLIs are only downloaded when Homebrew or pacman hasn't already installed them.
- **Claude Code config that travels.** Global `CLAUDE.md`, personal skills, slash commands and a plugin manifest, stowed into `~/.claude`.

## Platforms

| Platform | Detected as | What gets linked |
| --- | --- | --- |
| macOS (Apple Silicon) | `darwin` | Every package. Apps and CLIs come from the [`Brewfile`](Brewfile). |
| Omarchy (Arch + Hyprland) | `omarchy` | [`packages.omarchy`](packages.omarchy): `shell zsh git bin fd gitui claude scripts` |
| Other Linux (e.g. plain Arch) | `linux` | [`packages.linux`](packages.linux): the above plus `starship tmux neovim kitty ghostty alacritty wezterm` |

Detection lives in [`scripts/.dotscripts/lib`](scripts/.dotscripts/lib). Override it with `OS=`, e.g. `make setup OS=linux`.

## Install

Clone into `~/.dotfiles` (paths in the config assume this location):

```sh
git clone https://github.com/josephdburdick/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

### macOS

```sh
./migrate.sh    # installs Homebrew if needed, then `brew bundle`
make setup
```

### Omarchy

```sh
sudo pacman -S stow git-delta
make setup
make system     # optional, see "Linux system config" below
```

Bash stays the login shell and gets the shared commands through one line appended to `~/.bashrc`. To switch to zsh (syntax highlighting and autosuggestions as you type):

```sh
sudo pacman -S zsh
chsh -s /usr/bin/zsh    # then log out and back in
```

`~/.zshrc` loads Omarchy's own aliases and functions (`ff`, `n`, `t`, `open`, `compress`, `ga`/`gd`, …), its environment and fzf key bindings, so nothing is lost by switching.

### Other Linux

Install `stow` and ideally `zsh`, `git-delta`, `neovim`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide` and `starship` with your package manager, then `make setup`. Zinit fetches any of those CLIs that are missing on first zsh start.

### What `make setup` does

1. Asks for your git name and email if none are configured.
2. Stows the packages for the platform into `$HOME`.
3. Installs Claude Code plugins listed in `claude/dot-claude/plugins.txt` (when `claude` is on `PATH`).
4. Includes `~/.gitconfig.extra` in git's config (only when `delta` is installed, since it's the pager).
5. macOS: links `~/notes` to the Obsidian vault at `~/Documents/vaults/personal`.
6. Linux: hooks `shell/` into `~/.bashrc`.
7. Installs the tmux plugin manager when the `tmux` package is linked.
8. Offers to make zsh the login shell (not on Omarchy).

The first zsh start afterwards takes ~30 s while zinit installs plugins; after that it starts in about half a second.

## Make commands

| Command | What it does |
| --- | --- |
| `make setup` | Full first-time setup (above) |
| `make install` | Re-link packages and reinstall Claude plugins |
| `make update` | Pull the latest commits, then `install` |
| `make purge` | Remove every link stow created |
| `make system` | Linux only: install `system/linux/` into `/etc` with sudo |

## Shell

### Shared commands (bash and zsh)

Defined in [`shell/.dotrc/shell/`](shell/.dotrc/shell): `common.sh` everywhere, plus `darwin.sh` or `linux.sh`.

| Command | What it does |
| --- | --- |
| `gcob <text>` | Check out the branch whose name contains `<text>` (e.g. a ticket number); fzf picks when several match |
| `gcof` | Pick any local or remote branch with fzf and check it out |
| `cdr` | `cd` to the root of the current git repo |
| `gwip` / `gunwip` | Commit everything as a `--wip--` commit / undo it |
| `gcan` | Amend the last commit with all changes, keeping the message |
| `gundo` | `git reset HEAD~1` |
| `glog` / `gloga` | One-line graph of the current branch / all branches |
| `gst` `gco` `gc` `gcm` `gca` `gcam` `gp` `gl` `gaa` `gap` `gau` `gbr` | Short git aliases |
| `prcreate <base> [title]` | Open a PR against `<base>` (autofills when no title) |
| `prlist` / `prcheck <n>` / `prmerge <n>` | List open PRs / check one out and show its diff / merge it |
| `take <dir>` | `mkdir -p` and `cd` into it |
| `gi node,python` | Print a `.gitignore` from gitignore.io templates |
| `ipinfo` / `myip` | Internal and external IP / internal only |
| `v` / `vi` / `vim` | `nvim` |
| `l` | `eza` long listing with git status |
| `top` | `btop` |
| `upnup` / `cleanup` | Linux: full pacman upgrade / remove orphaned packages |
| `osx_toggle_*` | macOS: dark mode, hidden files, verbose boot, press-and-hold in VS Code/Cursor |

### zsh

- [`zsh/dot-zshrc`](zsh/dot-zshrc) uses [zinit](https://github.com/zdharma-continuum/zinit). Plugins load after the first prompt (turbo mode):
  [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting),
  [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) (→ or End to accept),
  LS_COLORS and Oh My Zsh's git/completion/key-binding libraries.
- CLIs (starship, zoxide, fzf, ripgrep, fd, bat, delta, eza, jq, stylua, gitui) are fetched from GitHub releases for the current OS/arch **only if not already installed**.
- Environment and `PATH` live in [`zsh/.dotrc/config.zsh`](zsh/.dotrc/config.zsh); macOS-only paths (Homebrew, libpq, `~/Library/pnpm`) and appearance-based bat/delta themes are guarded by `$OSTYPE`.
- On Linux, `mise` is activated; on Omarchy, Omarchy's aliases, functions and env are loaded.

### Local overrides

| File | Purpose |
| --- | --- |
| `~/.localrc` | Machine-specific aliases and secrets, sourced last by zsh (not tracked) |
| `~/.zsh_pre` | Sourced before the rest of the zsh config |
| `~/.env` | Environment variables loaded at zsh start |
| `~/.zsh_safe_mode` | If this file exists, zsh skips zinit and loads a minimal config — handy when something breaks |

## Linux system config

`make system` copies files from [`system/linux/`](system/linux) (a mirror of `/`) with `sudo install`, only when they changed, and skips anything for software that isn't installed.

| File | Effect |
| --- | --- |
| `etc/NetworkManager/dispatcher.d/70-wifi-off-on-ethernet` | Disconnects Wi-Fi once ethernet has a default route; reconnects it when ethernet goes down. Uses a device disconnect, so booting without a cable still brings Wi-Fi up. |
| `etc/sysctl.d/90-arp-per-interface.conf` | `arp_ignore=1`, `arp_announce=2`, so Wi-Fi and ethernet on the same subnet don't answer for each other's address (NetworkManager treats that as an IP conflict). |

## Claude Code

The [`claude`](claude) package stows into `~/.claude`:

- `CLAUDE.md` — global instructions for every project
- `skills/` — personal skills (`git-commit-pr`, `llm-tools`, `pr-before-after-shots`, `pr-stack-review-asks`, `use-railway`)
- `commands/` — `/journal` and `/monthly-report`, symlinked to their specs in the Obsidian vault via `~/notes`, so both machines run the vault's current version
- `plugins.txt` — plugin manifest installed by `make install`

`settings.json`, session history and memory are machine-specific and stay out of the repo. See [`claude/README.md`](claude/README.md) for details.

## Scripts

Linked into `~/.local/bin` by the [`bin`](bin/.local/bin) package:

| Script | What it does |
| --- | --- |
| `llm-ask` / `llm-write` / `llm-extract` | Offload bulk file reading, boilerplate generation and transcript compression to a cheap OpenAI-compatible model (used by the `llm-tools` skill) |
| `claude-md-bootstrap` | Add the `llm-tools` delegation block to a project's `CLAUDE.md` |
| `pr-unblock-daily` / `pr-unblock-post` | Rank the PRs whose review unblocks the most stacked work; post to Slack or archive |
| `gitssh` | Generate a per-host ed25519 SSH key in `~/.ssh/keys/<host>/` and print it for pasting into GitHub (or another host) |
| `shrinkpdf` | Compress a PDF with Ghostscript |
| `lsp` | Install language servers into `~/.local/lsp/bin` |

## Repo layout

Each tool directory is a stow package whose contents mirror `$HOME`; files named `dot-*` become `.*`. `system/` is the exception: it mirrors `/` and is copied by `make system`.

| Package | Contents |
| --- | --- |
| `shell` | Aliases and functions shared by bash and zsh |
| `zsh` | `.zshrc`, env/`PATH`, fzf options |
| `git` | `.gitconfig.extra` (delta, diff3 merges) |
| `bin` | Scripts in `~/.local/bin` |
| `claude` | Claude Code config |
| `neovim` | LazyVim-based Neovim config |
| `tmux` | tmux config (prefix `Ctrl-Space`) |
| `starship` | Prompt |
| `kitty` `ghostty` `alacritty` `wezterm` `neovide` | Terminals / GUI editor |
| `fd` `gitui` | Tool configs |
| `cursor` | Cursor editor notes |
| `scripts` | `make` helpers (`~/.dotscripts`) |
| `system` | Linux files for `/`, installed by `make system` (not stowed) |

To add a config: create `<tool>/` mirroring its path under `$HOME`, add it to the Linux package lists if it belongs there, then `make install`.

## For AI agents

- [AI.md](AI.md) — repo conventions and a safety checklist
- [WARP.md](WARP.md) — terminal operations
- [`agents/`](agents) — playbooks for zsh, Neovim and Homebrew/Stow

## Credits

Started as a fork of [numToStr/dotfiles](https://github.com/numToStr/dotfiles), which set up the stow + zinit structure. Also inspired by [@caarlos0's dotfiles](https://github.com/caarlos0/dotfiles).
