#!/usr/bin/env bash
# Dispatcher: run the library-specific build script for the given library.
# Each library has its own script in scripts/build/<library>.sh with its own fetch/build logic.
set -euo pipefail
LIBRARY="${1:?library name}"
OS="${2:?os (e.g. ubuntu-latest)}"
DIST="${3:?dist directory}"

# Map runner OS to platform suffix for binary naming
case "$OS" in
  ubuntu-latest)   PLATFORM=linux-amd64 ;;
  macos-latest)    PLATFORM=darwin-amd64 ;;
  windows-latest)  PLATFORM=windows-amd64 ;;
  *)               PLATFORM="$OS" ;;
esac

SCRIPT="$(dirname "$0")/build/${LIBRARY}.sh"
if [[ ! -f "$SCRIPT" ]]; then
  echo "No build script for library '$LIBRARY'. Add scripts/build/${LIBRARY}.sh" >&2
  exit 1
fi

mkdir -p "$DIST"
export LIBRARY OS PLATFORM DIST
"$SCRIPT"

# Emit path of the binary we expect the script to have produced (for the workflow)
if [[ "$OS" == "windows-latest" ]]; then
  echo "${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  echo "${DIST}/${LIBRARY}-${PLATFORM}"
fi
