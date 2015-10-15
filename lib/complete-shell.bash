#! bash

IFS=' '$'\t'$'\n'
die() { echo "$@" >&2; exit 1; }

__complete-shell:add() {
  local file="$1"
  if [[ ! $file =~ ^/ ]]; then
    local dir="$(cd -P "$(dirname $file)"; pwd)"
    file="$dir/$(basename $file)"
  fi
  [[ $file =~ /complete-([^./]+)$ ]] ||
    die "Invalid file to add: '$file'"
  local name="${BASH_REMATCH[1]}"
  git config -f "$COMPLETE_SHELL_ROOT/.config" \
    "complete-shell.$name" "$file"
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell-activate.bash" \
    complete-shell-activate "$file"
}

__complete-shell:install() {
  local target="$1"
  [[ $target =~ ^([-_a-zA-Z0-9]+)/([-_a-zA-Z0-9]+)$ ]] ||
    die "Invalid install target '$target'"
  local dir="${BASH_REMATCH[2]}"
  [[ $dir =~ ^complete-([-_a-zA-Z0-9]+)$ ]] ||
    die "Invalid complete-shell repo name: '$dir'"
  local cmd_name="${BASH_REMATCH[1]}"
  local repo_path="$COMPLETE_SHELL_ROOT/.src/$dir"
  git clone "https://github.com/$target" "$repo_path"
  local file_path=
  for file_path in "$repo_path"/complete-*; do
    __complete-shell:add "$file_path"
  done
}

__complete-shell:complete-shell() {
  local version=${1#v}
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell-$version.bash"
}

+() {
  local cmd="$1"; shift
  "__complete-shell:$cmd" "$@"
}

__complete-shell:rehash() {
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell-activate.bash" \
    complete-shell-activate-all
}

__complete-shell:help() {
  exec man complete-shell
}

__complete-shell:add-completion() {
  local cmd="$1" word="$2" prev="$3"
  set -- $("__complete-shell::$cmd")
  COMPREPLY=()
  for arg; do
    if [[ -z $word || $arg =~ ^$word ]]; then
      COMPREPLY+=($arg)
    fi
  done
  return 0
}

__complete-shell:check-env() {
  local rc=0
  [[ -n "$COMPLETE_SHELL_ROOT" && -d "$COMPLETE_SHELL_ROOT" ]] || {
    echo "Error: complete-shell not properly activated" >&2
    rc=1
  }
  [[ "$(type -t node)" == file ]] || {
    echo "Error: complete-shell requires 'node' (node.js) to be installed"
    rc=1
  }
  [[ "$(type -t npm)" == file ]] || {
    echo "Error: complete-shell requires 'npm' to be installed"
    rc=1
  }
  return $rc
}

# vim: set ft=sh sw=2 lisp:
