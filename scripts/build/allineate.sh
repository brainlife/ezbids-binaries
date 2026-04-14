#!/usr/bin/env bash
# Fetch neurolabusc/allineate at a pinned commit and compile a standalone binary.
# Contract: write the path from output-path.sh.
#
# Portable binaries: no OpenMP — avoids runtime libgomp (Linux) / libomp (macOS) that users may not have.
# Upstream supports single-threaded builds when _OPENMP is unset. Windows: static MinGW link on Linux CI.
# zlib uses the OS/SDK shared libz (standard on macOS/Linux); Windows is statically linked.
#
# windows-latest: MinGW cross-compile on Linux only (Ubuntu in CI).
set -euo pipefail

ALLINEATE_REPO="${ALLINEATE_REPO:-neurolabusc/allineate}"
ALLINEATE_REF="${ALLINEATE_REF:-dd250449d46752f84761657fbaf0fb26c8aaf20e}"

: "${LIBRARY:?LIBRARY not set}"
: "${DIST:?DIST not set}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rand48_shim() {
  cat > "$1/rand48_win.c" <<'EOF'
#include <stdlib.h>
void srand48(long s) { srand((unsigned)s); }
double drand48(void) { return (double)rand() / (double)RAND_MAX; }
EOF
}

fetch_and_verify_sources() {
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  ARCHIVE_URL="https://github.com/${ALLINEATE_REPO}/archive/${ALLINEATE_REF}.tar.gz"
  curl -fsSL "$ARCHIVE_URL" -o "$WORK/allineate.tgz"
  tar -xzf "$WORK/allineate.tgz" -C "$WORK"
  shopt -s nullglob
  local extracted=( "$WORK"/allineate-* )
  shopt -u nullglob
  if [[ ${#extracted[@]} -ne 1 || ! -d "${extracted[0]}" ]]; then
    echo "Expected exactly one allineate-* directory from archive" >&2
    exit 1
  fi
  mv "${extracted[0]}" "$WORK/src"
  SRC=(main.c allineate.c nifti_io.c powell_newuoa.c)
  for f in "${SRC[@]}"; do
    if [[ ! -f "$WORK/src/$f" ]]; then
      echo "Missing source file $f in allineate checkout" >&2
      exit 1
    fi
  done
}

compile_linux() {
  gcc -O3 -ffast-math -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
}

compile_macos() {
  clang -O3 -ffast-math -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
}

compile_windows() {
  # x86_64-w64-mingw32-gcc on Ubuntu (or other Linux with libz-mingw-w64-dev). MinGW lacks
  # srand48/drand48 — link small shim.
  if [[ "$(uname -s)" != Linux ]]; then
    echo "allineate: OS=windows-latest is only built on Linux (MinGW cross). Use Ubuntu." >&2
    exit 1
  fi
  rand48_shim "$WORK"
  x86_64-w64-mingw32-gcc -O3 -ffast-math -DHAVE_ZLIB \
    -I/usr/x86_64-w64-mingw32/include \
    "$WORK/rand48_win.c" "${SRC[@]/#/$WORK/src/}" \
    -L/usr/x86_64-w64-mingw32/lib -lz -lm -static -o "$OUT"
}

: "${OS:?OS not set}"
OUT=$("$SCRIPT_DIR/output-path.sh" "$LIBRARY" "$OS" "$DIST")
fetch_and_verify_sources

case "$OS" in
  ubuntu-latest)
    compile_linux
    chmod +x "$OUT"
    ;;
  macos-latest)
    compile_macos
    chmod +x "$OUT"
    ;;
  windows-latest)
    compile_windows
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

if [[ ! -f "$OUT" ]]; then
  echo "Build did not produce $OUT" >&2
  exit 1
fi
