#! bash

# This compdef command loads the version specific runtime for the other
# commands:
.complete-shell() {
  local version="${1#v}"
  [[ $version =~ [0-9]+\.[0-9]+\.[0-9]+ ]] || {
    cat <<...
Bad header directive in '$complete_file'.
The '.complete-shell' has a invalid version '$version'.
...
    return 1
  }
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell-$version.bash"
}

# Activate a compdef file:
complete-shell-activate() {
  local rc=0
  PATH= source "$1" || rc=$?
  if [[ $(type -t .DESTROY) == function ]]; then
    .DESTROY
  fi
  return $rc
}

# Activate all the compdef files in the user's config file:
complete-shell-activate-all() {
  IFS=' '$'\t'$'\n'   # Reset IFS just in case
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/.config --get-regexp complete-shell)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    shift
    local complete_file="$1"
    shift
    complete-shell-activate "$complete_file"
  done
}

[[ $0 == $BASH_SOURCE && $# -gt 0 ]] || {
  command="$1"; shift
  "$command" "$@"
}

unset -f \
  .complete-shell \
  complete-shell-activate \
  complete-shell-activate-all

# vim: set ft=sh lisp:
