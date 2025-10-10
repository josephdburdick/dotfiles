#!/bin/zsh

#####################
# SETOPT            #
#####################

setopt autocd autopushd pushdignoredups
# set -o emacs
# setopt vi
# setopt extended_history       # record timestamp of command in HISTFILE
# setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # ignore duplicated commands history list
# setopt hist_ignore_space      # ignore commands that start with space
# setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
# setopt share_history          # share command history data
# setopt always_to_end          # cursor moved to the end in full completion
# setopt hash_list_all          # hash everything before completion
# setopt completealiases        # complete alisases
# setopt always_to_end          # when completing from the middle of a word, move the cursor to the end of the word
# setopt complete_in_word       # allow completion from within a word/phrase
# setopt nocorrect                # spelling correction for commands
# setopt list_ambiguous         # complete as much of a completion until it gets ambiguous.
# setopt nolisttypes
# setopt listpacked
# setopt automenu

#####################
# HISTORY           #
#####################

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=290000
SAVEHIST=$HISTSIZE

############
# DOTFILES #
############

export DOTFILES=${DOTFILES:-$HOME/.dotfiles}

#####################
# ENV               #
#####################

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export TERM=${TERM:-xterm-256color}
export COLORTERM=${COLORTERM:-truecolor}
export EDITOR=$(which nvim)
export PAGER=bat
export BAT_THEME="TwoDark"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export CGO_ENABLED=1
export CGO_CFLAGS="-g -O2 -Wno-return-local-addr"
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export DISABLE_MAGIC_FUNCTIONS=true
#####################
# PATH              #
#####################
# Add local binaries first
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export HOMEBREW_PREFIX="/opt/homebrew"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Node.js (pnpm)
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# LSP servers
export PATH="$HOME/.local/lsp/bin:$PATH"

# PostgreSQL client tools
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Remove duplicate entries from PATH (simple version)
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

