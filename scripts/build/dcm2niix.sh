#!/usr/bin/env bash

set -euo pipefail

VERSION="v1.0.20250506"
BASE_URL="https://github.com/rordenlab/dcm2niix/releases/download/${VERSION}"

case "$OS" in
  ubuntu-latest)   ZIP="dcm2niix_lnx.zip" ;;
  macos-latest)    ZIP="dcm2niix_mac.zip" ;;
  windows-latest)  ZIP="dcm2niix_win.zip" ;;
  *)               echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

if [[ "$OS" == "windows-latest" ]]; then
  OUT="${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  OUT="${DIST}/${LIBRARY}-${PLATFORM}"
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

curl -sSL "${BASE_URL}/${ZIP}" -o "$WORK/dcm2niix.zip"
if [[ "$OS" == "windows-latest" ]]; then
  unzip -q -o "$WORK/dcm2niix.zip" -d "$WORK"
  # Windows zip may contain dcm2niix.exe at root or in a subdir
  EXE=$(find "$WORK" -name "dcm2niix.exe" -type f | head -1)
  cp "$EXE" "$OUT"
else
  unzip -q -o "$WORK/dcm2niix.zip" -d "$WORK"
  BIN=$(find "$WORK" -name "dcm2niix" -type f | head -1)
  cp "$BIN" "$OUT"
  chmod +x "$OUT"
fi
