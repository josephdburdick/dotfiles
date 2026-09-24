# Linux-only aliases and functions, sourced after common.sh.

ip-internal() {
  echo "Internal :: IP => $(ip -4 route get 1.1.1.1 2>/dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1) }')"
}

if _has pamac; then
  alias checkup="sudo pamac checkupdates -a"
  alias up="pamac upgrade -a --no-confirm"
  alias buildup="pamac build --no-confirm"
fi

if _has pacman; then
  alias upnup="sudo pacman -Syyuu"
  alias cleanup='sudo pacman -Rsn $(pacman -Qdtq)'
fi
