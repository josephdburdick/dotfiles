
# toggle macOS VSCode press and hold
osx_toggle_vscode_apple_press_and_hold() {
  if [[ $1 == "off" ]]; then
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
    echo "ApplePressAndHoldEnabled is now OFF for VSCode."
  elif [[ $1 == "on" ]]; then
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool true
    echo "ApplePressAndHoldEnabled is now ON for VSCode."
  else
    echo "Usage: toggle_vscode_apple_press_and_hold [on|off]"
  fi
}



# toggle macOS Cursor IDE press and hold
osx_toggle_cursor_apple_press_and_hold() {
  if [[ $1 == "off" ]]; then
    defaults write "$(osascript -e 'id of app "Cursor"')" ApplePressAndHoldEnabled -bool false
    echo "ApplePressAndHoldEnabled is now OFF for Cursor IDE."
  elif [[ $1 == "on" ]]; then
    defaults write "$(osascript -e 'id of app "Cursor"')" ApplePressAndHoldEnabled -bool true
    echo "ApplePressAndHoldEnabled is now ON for Cursor IDE."
  else
    echo "Usage: osx_toggle_cursor_apple_press_and_hold [on|off]"
  fi
}


# toggle verbose boot mode
osx_toggle_verbose_boot() {
  if [[ $1 == "on" ]]; then
    sudo nvram boot-args="-v"
    echo "Verbose boot mode enabled."
  elif [[ $1 == "off" ]]; then
    sudo nvram -d boot-args
    echo "Verbose boot mode disabled."
  else
    echo "Usage: toggle_verbose_boot [on|off]"
  fi
}

# toggle macOS dark theme
osx_toggle_dark_mode() {
  if [[ $1 == "on" ]]; then
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
    echo "Dark mode enabled."
  elif [[ $1 == "off" ]]; then
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to false'
    echo "Dark mode disabled."
  else
    echo "Usage: toggle_dark_mode [on|off]"
  fi
}

# toggle hidden Finder files visibility
osx_toggle_hidden_files() {
  if [[ $1 == "on" ]]; then
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
    echo "Hidden files are now visible."
  elif [[ $1 == "off" ]]; then
    defaults write com.apple.finder AppleShowAllFiles -bool false
    killall Finder
    echo "Hidden files are now hidden."
  else
    echo "Usage: toggle_hidden_files [on|off]"
  fi
}

