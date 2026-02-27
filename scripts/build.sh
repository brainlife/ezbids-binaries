#!/usr/bin/env bash
# Dispatcher: run the library-specific build script for the given library.
# Each library has its own script in scripts/build/<library>.sh with its own fetch/build logic.
set -euo pipefail
LIBRARY="${1:?library name}"
OS="${2:?os (e.g. ubuntu-latest)}"
DIST="${3:?dist directory}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM=$("$SCRIPT_DIR/platform.sh" "$OS")

SCRIPT="$SCRIPT_DIR/build/${LIBRARY}.sh"
if [[ ! -f "$SCRIPT" ]]; then
  echo "No build script for library '$LIBRARY'. Add scripts/build/${LIBRARY}.sh" >&2
  exit 1
fi

mkdir -p "$DIST"
export LIBRARY OS PLATFORM DIST
"$SCRIPT"
