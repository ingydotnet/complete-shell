#! bash

# This is a function wrapper around the real `bin/complete-shell` command. It
# is needed because certain commands like `reactivate` need to run in the
# current shell process.
complete-shell() {
  $COMPLETE_SHELL_ROOT/bin/complete-shell "$@" || return $?

  if [[ $1 =~ ^(add|delete|enable|disable|install|reactivate)$ ]]; then
    source $BASH_SOURCE complete-shell:activate-all || return $?
  fi
}

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
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell/v$version.bash"
}

# Activate a compdef file:
complete-shell:activate() {
  local rc=0
  PATH= source "$1" || rc=$?
  if [[ $(type -t .DESTROY) == function ]]; then
    .DESTROY
  fi
  return $rc
}

# Activate all the compdef files in the user's config file:
complete-shell:activate-all() {
  IFS=' '$'\t'$'\n'   # Reset IFS just in case
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/.config --get-regexp compdef)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    shift
    local complete_file="$1"
    shift
    complete-shell:activate "$complete_file"
  done
}

complete-shell:check-env() {
  local rc=0
  [[ -n "$COMPLETE_SHELL_ROOT" && -d "$COMPLETE_SHELL_ROOT" ]] || {
    echo "Error: complete-shell not properly activated" >&2
    rc=1
  }
  [[ "$(type -t git)" == file ]] || {
    echo "Error: complete-shell requires 'git' to be installed"
    rc=1
  }
  return $rc
}

# This file is meant to be `source`ed with a command:
rc=0
if [[ $0 != $BASH_SOURCE && $# -gt 0 ]]; then
  command="$1"; shift
  "$command" "$@" || rc=$?
fi

# Remove these functions from the user's shell:
unset -f \
  .complete-shell \
  complete-shell:activate \
  complete-shell:activate-all \
  complete-shell:check-env

return $rc

# vim: set ft=sh lisp:
