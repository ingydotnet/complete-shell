#! bash

IFS=' '$'\t'$'\n'
die() { echo "$@" >&2; exit 1; }

__complete-shell:add() {
  local file="$1"
  if [[ ! $file =~ ^/ ]]; then
    local dir="$(cd -P "$(dirname $file)"; pwd)"
    file="$dir/$(basename $file)"
  fi
  [[ $file =~ /complete-([^/]+).yaml$ ]] ||
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
  __complete-shell:add "$repo_path/complete-$cmd_name.yaml"
}

__complete-shell:rehash() {
  IFS=' '$'\t'$'\n'
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/config --get-regexp complete-shell)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    local cmd_name="${1#complete-shell.}" yaml_file="$2"
    shift; shift

    local bash="$(
      node "$COMPLETE_SHELL_ROOT/lib/complete-shell.js" "$yaml_file"
    )" || continue
    eval "$bash" || continue

    complete -F __complete-shell:add-completion "$cmd_name" || continue
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
