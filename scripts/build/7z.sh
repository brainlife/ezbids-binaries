#!/usr/bin/env bash

set -euo pipefail

case "$OS" in
  ubuntu-latest)  URL="https://www.7-zip.org/a/7z2600-linux-x64.tar.xz" ;;
  macos-latest)   URL="https://www.7-zip.org/a/7z2600-mac.tar.xz" ;;
  windows-latest) URL="https://www.7-zip.org/a/7z2600-extra.7z" ;;
  *)              echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

if [[ "$OS" == "windows-latest" ]]; then
  OUT="${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  OUT="${DIST}/${LIBRARY}-${PLATFORM}"
fi

if [[ "$OS" == "windows-latest" ]]; then
  # Standalone console version: extract from 7z2600-extra.7z using 7zr.exe
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  curl -sSL "https://www.7-zip.org/a/7zr.exe" -o "$WORK/7zr.exe"
  curl -sSL "$URL" -o "$WORK/extra.7z"
  "$WORK/7zr.exe" x -o"$WORK" "$WORK/extra.7z" -y >/dev/null
  find "$WORK" -type f -name "*.exe"
  # Extra package: 7zz.exe or 7za.exe, often in x64/ for 64-bit. Search full tree.
  BIN=$(find "$WORK" -type f \( -name "7zz.exe" -o -name "7za.exe" -o -name "7z.exe" \) | head -1)
  if [[ -z "$BIN" ]]; then
    echo "No 7zz.exe/7za.exe/7z.exe found in 7-Zip extra archive" >&2
    exit 1
  fi
  cp "$BIN" "$OUT"
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
