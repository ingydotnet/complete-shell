#! bash

.complete-shell() {
  local version="${1#v}"
  [[ $version =~ [0-9]+\.[0-9]+\.[0-9]+ ]] || {
    echo "'$complete_file' has '.complete-shell' directive with invalid version"
    return 1
  }
  source "$COMPLETE_SHELL_ROOT/lib/complete-shell-$version.bash"
}

complete-shell-activate() {
  PATH= source "$1"
  [[ $(type -t .DESTROY) != function ]] || .DESTROY
}

complete-shell-activate-all() {
  IFS=' '$'\t'$'\n'
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/.config --get-regexp complete-shell)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    local cmd_name="${1#complete-shell.}" complete_file="$2"
    shift; shift
    complete-shell-activate "$complete_file"
  done
}

[[ $0 == $BASH_SOURCE ]] || {
  command="$1"; shift
  "$command" "$@"
}

unset -f \
  .complete-shell \
  complete-shell-activate \
  complete-shell-activate-all
