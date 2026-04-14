#!/usr/bin/env bash
# Install OS packages needed to compile allineate in CI.
# Usage: scripts/build-deps/allineate.sh <library> <os>
#   library: matrix.library (only "allineate" does anything)
#   os:      ubuntu-latest | macos-latest | windows-latest (MinGW deps on Ubuntu only; windows-cross alias)

set -euo pipefail

LIBRARY="${1:?library name}"
OS="${2:?runner os label}"

if [[ "$LIBRARY" != "allineate" ]]; then
  exit 0
fi

case "$OS" in
  ubuntu-latest)
    sudo apt-get update
    sudo apt-get install -y zlib1g-dev
    ;;
  macos-latest)
    # Clang + system zlib provided by default in macos-latest github actions images
    :
    ;;
  windows-latest|windows-cross)
    sudo apt-get update
    sudo apt-get install -y gcc-mingw-w64-x86-64 libz-mingw-w64-dev
    ;;
  *)
    echo "Unknown OS for allineate build deps: $OS" >&2
    exit 1
    ;;
esac
