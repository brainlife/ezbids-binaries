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
  # Full installer has 7zz (Zstandard support). Silent install to temp dir, then copy 7zz.exe.
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  curl -sSL "$URL" -o "$WORK/7z_installer.exe"
  INSTALL_DIR="$WORK/7z"
  mkdir -p "$INSTALL_DIR"
  if command -v cygpath &>/dev/null; then
    WIN_DIR=$(cygpath -w "$INSTALL_DIR")
  else
    WIN_DIR="$INSTALL_DIR"
  fi
  "$WORK/7z_installer.exe" /S "/D=$WIN_DIR" || true
  BIN=$(find "$INSTALL_DIR" -type f \( -name "7zz.exe" -o -name "7z.exe" \) 2>/dev/null | head -1)
  if [[ -z "$BIN" ]] && [[ -f "/c/Program Files/7-Zip/7zz.exe" ]]; then
    BIN="/c/Program Files/7-Zip/7zz.exe"
  fi
  if [[ -z "$BIN" ]] && [[ -f "/c/Program Files/7-Zip/7z.exe" ]]; then
    BIN="/c/Program Files/7-Zip/7z.exe"
  fi
  if [[ -z "$BIN" ]]; then
    echo "No 7zz.exe/7z.exe found after install" >&2
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
