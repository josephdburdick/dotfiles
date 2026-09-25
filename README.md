<h1 align="center">~/.dotfiles</h1>

<p align='center'><sub>~~ Little things that you can't live without ~~</sub></p>

<!-- ### ⚠️ Requirements -->

### AI & Agent Guides

- See [WARP.md](WARP.md) for terminal usage and repo operations.
- See [AI.md](AI.md) for repo-wide agent conventions and safety checklist.

#### Commands

- sudo (maybe)
- git
- bash
- make
- unzip
- GNU tar
- [GNU stow](https://github.com/aspiers/stow)
- gcc or clang (for compiling neovim treesitter parsers)

#### Fonts

These dotfiles doesn't contains any font installation so you have install them beforehand.

- [powerline-fonts](https://github.com/powerline/fonts)
- [ttf-nerds-fonts-symbol](https://www.archlinux.org/packages/community/x86_64/ttf-nerd-fonts-symbols/)
- [fira-code](https://github.com/tonsky/firacode)

### 🚀 Installation

- Clone the repository into `$HOME/.dotfiles` and `cd` into it.

```
git clone https://github.com/josephdburdick/dotfiles ~/.dotfiles
cd ~/.dotfiles
```

- macOS: brew install everything with `$ ./migrate.sh`
- Linux: install `stow` (and optionally `zsh`, `git-delta`) with your package manager
- Now run `make setup`

`make setup` detects the platform (`darwin`, `omarchy` or `linux`) and stows the packages in `packages.<os>`, or every package when there is no list. Override detection with `make setup OS=linux`.

On [Omarchy](https://omarchy.org) the terminal, editor, tmux and prompt configs are left to Omarchy, bash stays the default shell, and the shared aliases/functions in `shell/` are hooked into `~/.bashrc`. To use zsh instead (syntax highlighting as you type), `sudo pacman -S zsh && chsh -s /usr/bin/zsh`; `~/.zshrc` loads Omarchy's aliases and functions too.

> NOTE: After the installation, when you'll open your terminal, or a different tab then `zinit` will start downloading some command line tools that are used inside the dotfiles.

### ✨ Commands

For convenience, I've added some `make` commands to do some regular stuff which are following:

- `setup` - For setting up the dotfiles on a new machine

- `install` - To reinstall the dotfiles, it doesn't include the setup part

- `update` - For updating the dotfiles, which will pull the latest commits and install them

- `purge` - Removes everything

- `system` - Linux only: installs the files in `system/linux/` (a mirror of `/`) with sudo. Currently: turn Wi-Fi off while ethernet is connected (NetworkManager dispatcher) and per-interface ARP replies so Wi-Fi and ethernet on the same subnet don't conflict

### 🖥️ Software

- OS: Linux
- Distro: Manjaro
- Desktop: KDE Plasma
- Terminal: kitty

### 🙏 Credits

- @caarlos0's [dotfiles](https://github.com/caarlos0/dotfiles)
- ThePrimeagen for this [masterpiece](https://youtu.be/tkUllCAGs3c)
