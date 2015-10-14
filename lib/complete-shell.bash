#!bash

complete-shell:activate-all() {
  local all=(
    $(git config -f $COMPLETE_SHELL_ROOT/config --get-regexp complete-shell)
  )
  set -- "${all[@]}"
  while [[ $# -gt 0 ]]; do
    local cmd_name="${1#complete-shell.}" bash_file="$2"
    shift; shift
    source $bash_file || continue
    complete -F complete-shell:add-completion "$cmd_name"
  done
}

complete-shell:add-completion() {
  local cmd="$1" word="$2" prev="$3"
  set -- $("complete-shell::$cmd")
  COMPREPLY=()
  for arg; do
    if [[ -z $word || $arg =~ ^$word ]]; then
      COMPREPLY+=($arg)
    fi
  done
  return 0
}
