#!/usr/bin/env bash
# Echo the path(s) of the built binary so the workflow can upload them.
# Must match what build.sh writes under DIST.
set -euo pipefail
LIBRARY="${1:?library name}"
OS="${2:?os}"
DIST="${3:?dist directory}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM=$("$SCRIPT_DIR/platform.sh" "$OS")

OUTPUT_NAME="${LIBRARY}-${PLATFORM}"
if [[ "$OS" == "windows-latest" ]]; then
  echo "${DIST}/${OUTPUT_NAME}.exe"
else
  echo "${DIST}/${OUTPUT_NAME}"
fi
