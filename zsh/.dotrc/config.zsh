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
# nvm
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  source "$NVM_DIR/bash_completion"
fi

# bun completions
if [ -s "$HOME/.bun/_bun" ]; then
  source "$HOME/.bun/_bun"
fi

export PYTHON_PATH="$HOME/.pyenv/shims" 
export LSP_BIN_PATH="$HOME/.local/lsp/bin"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PNPM_HOME="$HOME/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"
export BUN_PATH="$BUN_INSTALL/bin"
export CARGO_PATH="$HOME/.cargo/bin"
export LIB_PQ_BIN_PATH="/opt/homebrew/opt/libpq/bin"
export TPM_PATH="/opt/homebrew/opt/tpm"

# Adding all paths to PATH variable
export PATH="$PYTHON_PATH:$LSP_BIN_PATH:$GOBIN:$CARGO_PATH:$BUN_PATH:$PNPM_HOME:$LIB_PQ_BIN_PATH:$TPM_PATH:$PATH"

