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
  # windows-latest has 7-Zip preinstalled. Extract the installer exe (no GUI), then copy 7zz out.
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  curl -sSL "$URL" -o "$WORK/7z_installer.exe"
  SEVENZ=$(command -v 7z 2>/dev/null || command -v 7zz 2>/dev/null || true)
  [[ -n "$SEVENZ" ]] || SEVENZ="/c/Program Files/7-Zip/7z.exe"
  [[ -x "$SEVENZ" ]] || SEVENZ="7z"
  "$SEVENZ" x "$WORK/7z_installer.exe" -o"$WORK/7z_extract" -y >/dev/null
  echo "Contents of 7z_extract:" && find "$WORK/7z_extract" -type f | sort
  # Prefer 7zz.exe (standalone, no DLL); 7z.exe needs 7z.dll for many formats.
  BIN=$(find "$WORK/7z_extract" -type f -name "7zz.exe" 2>/dev/null | head -1)
  [[ -n "$BIN" ]] || BIN=$(find "$WORK/7z_extract" -type f -name "7z.exe" 2>/dev/null | head -1)
  if [[ -z "$BIN" ]]; then
    echo "No 7zz.exe or 7z.exe found in extracted installer" >&2
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
