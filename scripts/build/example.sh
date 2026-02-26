#!/usr/bin/env bash
# Example library build: produces a placeholder binary.
# Copy this to scripts/build/<yourlib>.sh and replace with real fetch/build steps.
# Contract: create $DIST/$LIBRARY-$PLATFORM (or .exe on Windows).
set -euo pipefail

if [[ "$OS" == "windows-latest" ]]; then
  OUT="${DIST}/${LIBRARY}-${PLATFORM}.exe"
else
  OUT="${DIST}/${LIBRARY}-${PLATFORM}"
fi

# Stub: replace with e.g. clone repo, go build / cargo build / make, cp binary "$OUT"
echo "Built: $LIBRARY for $PLATFORM" > "$OUT"
if [[ "$OS" != "windows-latest" ]]; then
  chmod +x "$OUT"
fi
