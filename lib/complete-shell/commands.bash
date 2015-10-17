#! bash

IFS=' '$'\t'$'\n'
die() { echo "$@" >&2; exit 1; }

complete-shell:help() {
  exec man complete-shell
}

complete-shell:search() {
  local term="$1"
  (
    if [[ -n $term ]]; then
      grep "$term" "$COMPLETE_SHELL_ROOT/share/index"
    else
      cat "$COMPLETE_SHELL_ROOT/share/index"
    fi
  ) |
  (
    while IFS= read line; do
      eval "vars=($line)"
      name="${vars[0]}"
      from="${vars[1]}"
      cmds="${vars[2]}"
      info="${vars[3]}"
      cat <<...
$name
  From: $from
  Cmds: $cmds
  Info: $info
...
    done
  ) | less -FRX
}

complete-shell:install() {
  local name="$1"
  line="$(grep "^$name\ " "$COMPLETE_SHELL_ROOT/share/index" | head -n1)"
  if [[ -z $line ]]; then
    echo "Invalid complete-shell install name: '$name'"
    exit 1
  fi
  eval "vars=($line)"
  local compgen_name="${vars[0]}"
  local repo_url="${vars[1]}"
  local repo_path="$COMPLETE_SHELL_ROOT/.src/$compgen_name"
  if [[ -d $repo_path ]]; then
    (
      cd "$repo_path"
      git pull --ff-only &> /dev/null
      echo "$repo_url updated"
    )
  else
    git clone "$repo_url" "$repo_path" &> /dev/null
    echo "$repo_url cloned"
  fi
  local file_path=
  for file_path in "$repo_path"/complete-*; do
    [[ ! $file_path =~ \* ]] || continue
    complete-shell:add "$file_path"
    echo "$file_path added"
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
  die "'complete-shell delete' not yet implemented"
}

complete-shell:enable() {
  die "'complete-enable delete' not yet implemented"
}

complete-shell:disable() {
  die "'complete-disable delete' not yet implemented"
}

# Just cd to the complete-shell repo and pull:
complete-shell:upgrade() {
  (
    set -x
    cd "$COMPLETE_SHELL_ROOT"
    git pull --ff-only
  )
}

# Don't do anything here. Reactivates in the `complete-shell` wrapper function:
complete-shell:reactivate() {
  :
}

# Mostly for testing:
complete-shell:__reset() {
  (
    set -x
    cd "$COMPLETE_SHELL_ROOT"
    mkdir -p /tmp/complete-shell-backup
    [[ -f .config ]] &&
      mv .config /tmp/complete-shell-backup/config-$$
    [[ -f .src ]] &&
      mv .src /tmp/complete-shell-backup/src-$$
  )
}

# vim: set ft=sh sw=2 lisp:
