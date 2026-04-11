#!/usr/bin/env bash
# Install OS packages needed to compile allineate in CI.
# Usage: scripts/build-deps/allineate.sh <library> <os>
#   library: matrix.library (only "allineate" does anything)
#   os:      ubuntu-latest | macos-latest | windows-latest | windows-cross
#
# windows-cross: MinGW cross-compile deps on Ubuntu (build-allineate-windows job).
# windows-latest: no-op here (allineate Windows binary is built via windows-cross).
set -euo pipefail

LIBRARY="${1:?library name}"
OS="${2:?runner os or windows-cross}"

if [[ "$LIBRARY" != "allineate" ]]; then
  exit 0
fi

case "$OS" in
  ubuntu-latest)
    sudo apt-get update
    sudo apt-get install -y libomp-dev zlib1g-dev
    ;;
  macos-latest)
    brew install libomp
    ;;
  windows-cross)
    sudo apt-get update
    sudo apt-get install -y gcc-mingw-w64-x86-64 libz-mingw-w64-dev
    ;;
  windows-latest)
    exit 0
    ;;
  *)
    echo "Unknown OS for allineate build deps: $OS" >&2
    exit 1
    ;;
esac
