# Aliases and functions shared by bash and zsh on every OS.
# Keep this file portable: no zsh-only syntax, no OS-specific commands.

_has() { command -v "$1" >/dev/null 2>&1; }

#####################
# EDITOR / TOOLS    #
#####################

if _has nvim; then
  alias v=nvim
  alias vi=nvim
  alias vim=nvim
fi

_has btop && alias top=btop
_has eza && alias l="eza -abghHlS --git --group-directories-first"

alias p="pnpm"
alias y="yarn"

take() {
  mkdir -p "$@" && cd "${@: -1}" || return
}

#####################
# GIT               #
#####################

# git amend commit without edit
alias gcan="git commit -v -a --no-edit --amend"

alias gst="git status"
alias gco="git checkout"
alias gcom="git checkout master"
alias gci="git commit"
alias gbr="git branch"
alias gaa="git add --all"
alias gap="git add --patch"
alias gau="git add --update"
alias gc="git commit -v"
alias gca="git commit -v -a"
alias gcm="git commit -m"
alias gcam="git commit -a -m"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
alias gunwip='git log -n 1 | grep -q -- "--wip--" && git reset HEAD~1'
alias gundo="git reset HEAD~1"

# Interactive git checkout function using fzf
gcof() {
  local branch
  branch=$(git branch --all | sed 's/^[* ]*//' | cut -d' ' -f1 | fzf) || return
  git checkout "$branch"
}

# Checkout a branch by a substring (e.g. ticket number): gcob 6014
gcob() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcob <pattern>  (e.g. gcob 6014)"
    return 1
  fi
  local matches branch
  matches=$(git branch --all --format='%(refname:short)' \
    | sed 's#^origin/##' | grep -v '^HEAD$' | sort -u | grep -- "$1")
  if [[ -z "$matches" ]]; then
    echo "gcob: no branch matching '$1'"
    return 1
  fi
  if [[ $(echo "$matches" | wc -l) -gt 1 ]]; then
    branch=$(echo "$matches" | fzf --select-1 --query "$1") || return
  else
    branch="$matches"
  fi
  git checkout "$branch"
}

# go to root git dir
cdr() {
  cd "$(git rev-parse --show-toplevel)" || return
}

# gitignore.io - Generate .gitignore files from templates
# Usage: gi node,python,rust
gi() {
  curl -sLw "\n" "https://www.toptal.com/developers/gitignore/api/$*"
}

#####################
# GITHUB CLI        #
#####################

prcreate() {
  if [ -z "$2" ]; then
    # If title is not provided then use autofill
    gh pr create -B "$1" -f
  else
    # Otherwise use provided title
    gh pr create -B "$1" -t "$2"
  fi
}
prmerge() {
  gh pr merge --merge --delete-branch=false "$1"
}
prlist() {
  gh pr list --state open
}
prcheck() {
  gh pr checkout "$1" && gh pr diff
}

#####################
# NETWORK           #
#####################

# ip-internal is defined per OS
ip-external() {
  echo "External :: IP => $(curl --silent https://ifconfig.me)"
}
ipinfo() {
  ip-internal && ip-external
}
alias myip=ip-internal

#####################
# MISC              #
#####################

if _has microk8s; then
  alias k="microk8s.kubectl"
  alias kube="microk8s.kubectl"
  alias kubectl="microk8s.kubectl"
fi
