#!/usr/bin/env bash
# Echo the path(s) of the built binary so the workflow can upload them.
# Must match what build.sh writes under DIST.
set -euo pipefail
LIBRARY="${1:?library name}"
OS="${2:?os}"
DIST="${3:?dist directory}"

case "$OS" in
  ubuntu-latest)   PLATFORM=linux-amd64 ;;
  macos-latest)    PLATFORM=darwin-amd64 ;;
  windows-latest)  PLATFORM=windows-amd64 ;;
  *)               PLATFORM="$OS" ;;
esac

OUTPUT_NAME="${LIBRARY}-${PLATFORM}"
if [[ "$OS" == "windows-latest" ]]; then
  echo "${DIST}/${OUTPUT_NAME}.exe"
else
  echo "${DIST}/${OUTPUT_NAME}"
fi
