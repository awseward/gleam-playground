#!/usr/bin/env bash

set -euo pipefail

watch_test() {
  (
    # This error behavior in a subshell is needed for entr to be able to start
    # back up when a file is added or removed to any directories it's watching.
    set +e

    while true; do
      find src test -name '*.gleam' | entr -d ding gleam test
      >&2 echo '^C to exit…'
      sleep 2
    done
  )
}

"$@"
