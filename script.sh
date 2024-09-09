#!/usr/bin/env bash

set -euo pipefail

watch_test() {
  while sleep 1; do
    find src test -name '*.gleam' | entr -d ding gleam test
  done
}

"$@"
