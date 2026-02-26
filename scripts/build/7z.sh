#!/usr/bin/env bash

set -euo pipefail

case "$OS" in
  ubuntu-latest)  URL="https://www.7-zip.org/a/7z2600-linux-x64.tar.xz" ;;
  macos-latest)   URL="https://www.7-zip.org/a/7z2600-mac.tar.xz" ;;
  windows-latest) URL="https://www.7-zip.org/a/7z2600-x64.exe" ;;
  *)              echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

if [[ "$OS" == "windows-latest" ]]; then
  OUT="${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  OUT="${DIST}/${LIBRARY}-${PLATFORM}"
fi

if [[ "$OS" == "windows-latest" ]]; then
  curl -sSL "$URL" -o "$OUT"
else
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  curl -sSL "$URL" -o "$WORK/7z.tar.xz"
  tar -xJf "$WORK/7z.tar.xz" -C "$WORK"
  # 7-Zip extra uses "7zz" (or "7za" on older builds)
  BIN=$(find "$WORK" -maxdepth 2 \( -name "7zz" -o -name "7za" \) -type f | head -1)
  if [[ -z "$BIN" ]]; then
    echo "No 7zz/7za binary found in archive" >&2
    exit 1
  fi
  cp "$BIN" "$OUT"
  chmod +x "$OUT"
fi
