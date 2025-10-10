# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages configuration for development tools, shell environment, and applications on macOS. The repository uses GNU Stow for symlink management and Homebrew for package installation.

## Core Commands

### Initial Setup (New Machine)
```bash
# Clone repository
git clone https://github.com/josephdburdick/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Install Homebrew and all packages
./migrate.sh

# Set up dotfiles (interactive - prompts for git config)
make setup
```

### Development Commands
```bash
# Install/reinstall dotfiles (no setup prompts)
make install

# Update dotfiles (pull latest changes and reinstall)
make update

# Remove all dotfiles symlinks
make purge

# Install specific tools manually
brew bundle  # Install all Homebrew packages from Brewfile
```

### Testing Configuration Changes
```bash
# Test single package installation
stow --dotfiles --dir ~/.dotfiles --target ~ <package_name>

# Remove single package
stow -D --dotfiles --dir ~/.dotfiles --target ~ <package_name>

# Check what would be installed (dry run)
stow -n --dotfiles --dir ~/.dotfiles --target ~ <package_name>
```

## Architecture

### Directory Structure Pattern
Each tool/application has its own directory containing the configuration files in their expected relative paths:

```
<tool_name>/
  .config/
    <tool_name>/
      config_file
  .local/
    bin/
      scripts
```

### Package Organization
- **Terminal/Shell**: `zsh/`, `starship/`, `tmux/`
- **Editors**: `neovim/`, `cursor/`
- **Terminal Emulators**: `kitty/`, `alacritty/`, `wezterm/`
- **Development Tools**: `git/`, `bat/`, `fd/`
- **Scripts**: `bin/`, `scripts/`

### Key Configuration Files

#### ZSH Configuration
- **Main**: `zsh/dot-zshrc` - Primary zsh configuration with Zinit plugin manager
- **Config**: `zsh/.dotrc/config.zsh` - Environment variables, history, and PATH setup  
- **Aliases**: `zsh/.dotrc/extra/aliases.zsh` - Custom command aliases and functions

#### Build System
- **Makefile**: Defines `setup`, `install`, `update`, `purge` commands
- **Scripts**: `scripts/.dotscripts/` contains the actual implementation scripts
- **Dependencies**: `Brewfile` defines all Homebrew packages and casks

### Stow Integration
The repository uses GNU Stow's `--dotfiles` flag, which means:
- Files prefixed with `dot-` become `.` files (e.g., `dot-zshrc` → `.zshrc`)  
- Directory structure mirrors the target home directory structure
- All symlinks point back to the dotfiles repository

### Environment Management
- **Path Management**: Centralized in `zsh/.dotrc/config.zsh` with support for:
  - Node.js (nvm, fnm, pnpm, bun)
  - Go (GOPATH, GOBIN)
  - Python (pyenv)
  - Rust (cargo)
  - LSP servers
- **Plugin Management**: Uses Zinit for zsh plugins and tools installation
- **Theme**: Uses Starship prompt with custom configuration

### Development Tools Included
- **Editors**: Neovim (with LazyVim), Neovide, VS Code, Cursor
- **Version Control**: Git, Lazygit, GitUI, GitHub CLI
- **Languages**: Node.js, Go, Python, Rust toolchains
- **Terminal Tools**: bat, ripgrep, fd, fzf, btop, jq
- **Containers**: Docker
- **Databases**: PostgreSQL client tools

## Important Notes

### Git Configuration
The setup script will interactively configure git user.name and user.email on first run. Existing git configuration is preserved and marked as `dotfiles.managed = true`.

### Homebrew Dependencies
All GUI applications and command-line tools are defined in the `Brewfile`. The `migrate.sh` script handles Homebrew installation and runs `brew bundle`.

### Platform Specific
This configuration is optimized for macOS (Apple Silicon). Some aliases and paths may need adjustment for other platforms.

### Custom Scripts
Binary scripts are located in `bin/.local/bin/` and include utilities like:
- `lsp` - LSP server management
- `npmnuke` - Node modules cleanup
- `gitssh` - Git SSH helper