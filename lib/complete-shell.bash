#! bash

IFS=' '$'\t'$'\n'
die() { echo "$@" >&2; exit 1; }

__complete-shell:add() {
  local file="$1"
  if [[ ! $file =~ ^/ ]]; then
    local dir="$(cd -P "$(dirname $file)"; pwd)"
    file="$dir/$(basename $file)"
  fi
  [[ $file =~ /complete-([^/]+).bash$ ]] ||
    die "Invalid file to add: '$file'"
  local name="${BASH_REMATCH[1]}"
  git config -f "$COMPLETE_SHELL_ROOT/config" \
    "complete-shell.$name" "$file"
  __complete-shell:rehash
}

__complete-shell:install() {
  local target="$1"
  [[ $target =~ ^([-_a-zA-Z0-9]+)/([-_a-zA-Z0-9]+)$ ]] ||
    die "Invalid install target '$target'"
  local dir="${BASH_REMATCH[2]}"
  [[ $dir =~ ^complete-([-_a-zA-Z0-9]+)$ ]] ||
    die "Invalid complete-shell repo name: '$dir'"
  local cmd_name="${BASH_REMATCH[1]}"
  local repo_path="$COMPLETE_SHELL_ROOT/source/$dir"
  git clone "https://github.com/$target" "$repo_path"
  __complete-shell:add "$repo_path/complete-$cmd_name.bash"
}

__complete-shell:rehash() {
  IFS=' '$'\t'$'\n'
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/config --get-regexp complete-shell)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    local cmd_name="${1#complete-shell.}" bash_file="$2"
    shift; shift
    source $bash_file || continue

    complete -F __complete-shell:add-completion "$cmd_name"
  done
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

# vim: set ft=sh sw=2 lisp: