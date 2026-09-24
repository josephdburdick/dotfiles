# Entry point for the shared shell layer. Sourced by ~/.zshrc and ~/.bashrc.

__dotrc_shell="$HOME/.dotrc/shell"

[ -f "$__dotrc_shell/common.sh" ] && . "$__dotrc_shell/common.sh"

case "$OSTYPE" in
  darwin*) [ -f "$__dotrc_shell/darwin.sh" ] && . "$__dotrc_shell/darwin.sh" ;;
  linux*) [ -f "$__dotrc_shell/linux.sh" ] && . "$__dotrc_shell/linux.sh" ;;
esac

unset __dotrc_shell
