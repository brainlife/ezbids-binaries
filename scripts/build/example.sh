#!/usr/bin/env bash
# Example library build: produces a placeholder binary.
# Copy this to scripts/build/<yourlib>.sh and replace with real fetch/build steps.
# Contract: create the file at the path output-path.sh returns.
set -euo pipefail

# Invoked from repo root by build.sh; paths are relative to that.
OUT=$(scripts/output-path.sh "$LIBRARY" "$OS" "$DIST")

# Stub: replace with e.g. clone repo, go build / cargo build / make, cp binary "$OUT"
echo "Built: $LIBRARY for $PLATFORM" > "$OUT"
if [[ "$OS" != "windows-latest" ]]; then
  chmod +x "$OUT"
fi
