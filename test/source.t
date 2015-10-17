#!/usr/bin/env bash

source test/setup
use Test::More

all=(
  .activate
  bin/complete-shell
  lib/complete-shell.bash
  lib/complete-shell/v0.0.1.bash
  lib/complete-shell/commands.bash
)

for file in ${all[@]}; do
  rc=0
  (source $file) || rc=$?
  ok $rc "source $file"
done

done_testing

# source all bash files
