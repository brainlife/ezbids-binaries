#!/usr/bin/env bash
# Echo the platform suffix for binary naming given a runner OS.
# Usage: scripts/platform.sh <OS>
set -euo pipefail
OS="${1:?OS (e.g. ubuntu-latest)}"

case "$OS" in
  ubuntu-latest)   echo linux-amd64 ;;
  macos-latest)    echo darwin-amd64 ;;
  windows-latest)  echo windows-amd64 ;;
  *)               echo "$OS" ;;
esac
