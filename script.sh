#!/usr/bin/env bash

set -euo pipefail

watch_test() {
  # shellcheck disable=SC2012 # (TODO)
  while sleep 0.1; do ls src/*.gleam test/*.gleam | entr -d gleam test; done
}

"$@"
