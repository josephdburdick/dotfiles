#!/usr/bin/env bash

# -xeo prints all executed commands, exit if any fails, prevent error from being masked
set -x
set -eo pipefail

xcode-select --install

# Check if Homebrew is installed
if ! [ -x "$(command -v brew)" ]; then
	echo "Installing Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Homebrew is already installed"
fi

# Install brew formula and casks
brew bundle
