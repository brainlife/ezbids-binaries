#!/usr/bin/env bash
# Echo the path(s) of the built binary so the workflow can upload them.
# Must match what build.sh writes under DIST.
set -euo pipefail
LIBRARY="${1:?library name}"
OS="${2:?os}"
DIST="${3:?dist directory}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$OS" in
  ubuntu-latest)
    PLATFORM="linux-amd64"
    ;;
  macos-latest)
    case "$(uname -m)" in
      arm64|aarch64) PLATFORM="darwin-arm64" ;;
      x86_64)        PLATFORM="darwin-amd64" ;;
      *)             PLATFORM="darwin-amd64" ;;
    esac
    ;;
  windows-latest)
    PLATFORM="windows-amd64"
    ;;
  *)
    PLATFORM="$OS"
    ;;
esac

{
  echo "--------------------------------"
  echo "LIBRARY: $LIBRARY"
  echo "OS: $OS"
  echo "PLATFORM: $PLATFORM"
  echo "DIST: $DIST"
  echo "--------------------------------"
} >&2

if [[ "$LIBRARY" == "python-runtime" ]]; then
  echo "${DIST}/${LIBRARY}-${PLATFORM}.tar.gz"
elif [[ "$OS" == "windows-latest" ]]; then
  echo "${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  echo "${DIST}/${LIBRARY}-${PLATFORM}"
fi
