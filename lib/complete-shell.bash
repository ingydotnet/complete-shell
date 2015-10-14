#!bash

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
