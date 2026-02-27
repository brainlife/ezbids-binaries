#!/usr/bin/env bash

set -euo pipefail

VERSION="2600"
BASE_URL="https://www.7-zip.org/a/7z${VERSION}"

# Resolve scripts dir so we work regardless of cwd (build.sh exports these; verify for standalone use).
: "${LIBRARY:?LIBRARY not set}"
: "${OS:?OS not set}"
: "${DIST:?DIST not set}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT=$("$SCRIPT_DIR/output-path.sh" "$LIBRARY" "$OS" "$DIST")

case "$OS" in
  ubuntu-latest)  URL="${BASE_URL}-linux-x64.tar.xz" ;;
  macos-latest)   URL="${BASE_URL}-mac.tar.xz" ;;
  windows-latest) URL="${BASE_URL}-x64.exe" ;;
  *)              echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

if [[ "$OS" == "windows-latest" ]]; then
  # windows-latest has 7-Zip preinstalled. Extract the installer exe (no GUI), then copy 7zz out.
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  curl -sSL "$URL" -o "$WORK/7z_installer.exe"
  SEVENZ=$(command -v 7z 2>/dev/null || command -v 7zz 2>/dev/null || true)
  [[ -n "$SEVENZ" ]] || SEVENZ="/c/Program Files/7-Zip/7z.exe"
  [[ -x "$SEVENZ" ]] || SEVENZ="7z"
  "$SEVENZ" x "$WORK/7z_installer.exe" -o"$WORK/7z_extract" -y >/dev/null
  # Windows installer has 7z.exe (not 7zz.exe). 7z.exe needs 7z.dll for many formats (e.g. Zstandard).
  BIN=$(find "$WORK/7z_extract" -type f -name "7z.exe" 2>/dev/null | head -1)
  if [[ -z "$BIN" ]]; then
    echo "No 7z.exe found in extracted installer" >&2
    exit 1
  fi
  cp "$BIN" "$OUT"
  DLL=$(find "$WORK/7z_extract" -type f -name "7z.dll" 2>/dev/null | head -1)
  if [[ -n "$DLL" ]]; then
    cp "$DLL" "${OUT%.exe}.dll"
  fi
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
