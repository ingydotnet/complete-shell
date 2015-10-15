#! bash

.cmd() {
  cs_cmd="$1"
  cs_opt=()
  cs_sub=()
}

.opt() {
  cs_opt+=("$1")
}

.sub() {
  cs_sub+=("$1")
}

.end() {
  complete -W "${cs_sub[*]}" "$cs_cmd"
}

.DESTROY() {
  unset cs_cmd cs_opt cs_sub
  unset -f .cmd .opt .sub .end .DESTROY
}
