#!/usr/bin/env bash
# Fetch neurolabusc/allineate at a pinned commit and compile a standalone binary.
# Contract: write the path from output-path.sh.
# Windows release builds use Ubuntu MinGW cross (ALLINEATE_WINDOWS_CROSS=1) for a static .exe.
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
  gcc -O3 -ffast-math -fopenmp -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
}

compile_macos() {
  local omp_prefix=""
  for prefix in /opt/homebrew/opt/libomp /usr/local/opt/libomp; do
    if [[ -f "$prefix/include/omp.h" ]]; then
      omp_prefix=$prefix
      break
    fi
  done
  if [[ -n "$omp_prefix" ]]; then
    clang -O3 -ffast-math -Xclang -fopenmp \
      -I"$omp_prefix/include" -L"$omp_prefix/lib" -lomp \
      -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
  elif command -v gcc-14 >/dev/null 2>&1; then
    gcc-14 -O3 -ffast-math -fopenmp -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
  elif command -v gcc-13 >/dev/null 2>&1; then
    gcc-13 -O3 -ffast-math -fopenmp -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
  else
    echo "Building without OpenMP (install Homebrew libomp for faster builds): brew install libomp" >&2
    clang -O3 -ffast-math -DHAVE_ZLIB "${SRC[@]/#/$WORK/src/}" -lz -lm -o "$OUT"
  fi
}

compile_windows_mingw_native() {
  # Local MSYS2 MinGW64 (no OpenMP). MinGW lacks srand48/drand48 — link small shim.
  rand48_shim "$WORK"
  gcc -O3 -ffast-math -DHAVE_ZLIB \
    "$WORK/rand48_win.c" "${SRC[@]/#/$WORK/src/}" \
    -lz -lm -static-libgcc -o "$OUT"
  local dll b bins=(/mingw64/bin)
  local d
  d=$(dirname "$OUT")
  if [[ -n "${MSYSTEM_PREFIX:-}" && -d "${MSYSTEM_PREFIX}/bin" ]]; then
    bins+=("${MSYSTEM_PREFIX}/bin")
  fi
  for dll in zlib1.dll libwinpthread-1.dll libgcc_s_seh-1.dll; do
    for b in "${bins[@]}"; do
      if [[ -f "$b/$dll" ]]; then
        cp "$b/$dll" "$d/"
        break
      fi
    done
  done
}

compile_windows_mingw_cross() {
  rand48_shim "$WORK"
  x86_64-w64-mingw32-gcc -O3 -ffast-math -DHAVE_ZLIB \
    -I/usr/x86_64-w64-mingw32/include \
    "$WORK/rand48_win.c" "${SRC[@]/#/$WORK/src/}" \
    -L/usr/x86_64-w64-mingw32/lib -lz -lm -static -o "$OUT"
}

if [[ -n "${ALLINEATE_WINDOWS_CROSS:-}" ]]; then
  OUT=$("$SCRIPT_DIR/output-path.sh" "$LIBRARY" "windows-latest" "$DIST")
  fetch_and_verify_sources
  compile_windows_mingw_cross
  [[ -f "$OUT" ]] || exit 1
  exit 0
fi

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
    compile_windows_mingw_native
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
