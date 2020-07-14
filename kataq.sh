#!/usr/bin/env bash
set -e -o pipefail

pushd "$(dirname "$0")" > /dev/null
  export MODE=mono
  frontend/bash/katacli.sh "$@"
popd > /dev/null
