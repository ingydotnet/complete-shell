#! bash

IFS=' '$'\t'$'\n'
die() { echo "$@" >&2; exit 1; }

complete-shell:help() {
  exec man complete-shell
}

complete-shell:search() {
  :
}

complete-shell:install() {
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
    [[ ! $file_path =~ \* ]] || continue
    complete-shell:add "$file_path"
  done
}

complete-shell:add() {
  local file="$1"
  if [[ ! $file =~ ^/ ]]; then
    local dir="$(cd -P "$(dirname $file)"; pwd)"
    file="$dir/$(basename $file)"
  fi
  [[ $file =~ /complete-([^./]+)$ ]] ||
    die "Invalid file to add: '$file'"
  local name="${BASH_REMATCH[1]}"
  git config -f "$COMPLETE_SHELL_ROOT/.config" \
    "compdef.$name" "$file"
}

complete-shell:delete() {
  :
}

complete-shell:enable() {
  :
}

complete-shell:disable() {
  :
}

complete-shell:upgrade() {
  :
}

complete-shell:reactivate() {
  :
}

# vim: set ft=sh sw=2 lisp:
