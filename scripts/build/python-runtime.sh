#!/usr/bin/env bash
# Build standalone Python + venv with ezbids requirements, package as tarball.
# Contract: produce the path from output-path.sh with .tar.gz appended (e.g. dist/python-runtime-<PLATFORM>.tar.gz).
set -euo pipefail

# Pinned for reproducibility (astral-sh/python-build-standalone).
PBS_RELEASE="${PBS_RELEASE:-20260303}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12.13}"
BASE_URL="https://github.com/astral-sh/python-build-standalone/releases/download/"

: "${LIBRARY:?LIBRARY not set}"
: "${OS:?OS not set}"
: "${DIST:?DIST not set}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT=$("$SCRIPT_DIR/output-path.sh" "$LIBRARY" "$OS" "$DIST")
OUT="${OUT}.tar.gz"

case "$OS" in
  ubuntu-latest)  PBS_SUFFIX="x86_64-unknown-linux-gnu-install_only" ;;
  macos-latest)   PBS_SUFFIX="x86_64-apple-darwin-install_only" ;;
  windows-latest) PBS_SUFFIX="x86_64-pc-windows-msvc-install_only" ;;
  *)              echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

PBS_BASE="cpython-${PYTHON_VERSION}+${PBS_RELEASE}-${PBS_SUFFIX}"
PBS_URL="${BASE_URL}/${PBS_RELEASE}/${PBS_BASE}.tar.gz"

EZBIDS_REPO="${EZBIDS_REPO:-brainlife/ezbids}"
EZBIDS_BRANCH="${EZBIDS_BRANCH:-electron}"
EZBIDS_REQUIREMENTS_URL="https://raw.githubusercontent.com/${EZBIDS_REPO}/${EZBIDS_BRANCH}/requirements.txt"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# 1. Fetch requirements.txt from ezbids repo
curl -sSL "$EZBIDS_REQUIREMENTS_URL" -o "$WORK/requirements.txt"
if [[ ! -s "$WORK/requirements.txt" ]]; then
  echo "Failed to fetch or empty requirements.txt from $EZBIDS_REQUIREMENTS_URL" >&2
  exit 1
fi

# 2. Download and unpack python-build-standalone
curl -sSL "$PBS_URL" -o "$WORK/pbs.tar.gz"
tar -xzf "$WORK/pbs.tar.gz" -C "$WORK"
PYROOT=$(find "$WORK" -maxdepth 1 -mindepth 1 -type d | head -1)

if [[ "$OS" == "windows-latest" ]]; then
  PYEXE="$PYROOT/python.exe"
  VENV_PIP="$WORK/venv/Scripts/pip.exe"
else
  PYEXE="$PYROOT/bin/python3"
  VENV_PIP="$WORK/venv/bin/pip"
fi
if [[ ! -x "$PYEXE" ]]; then
  echo "Standalone Python not found at $PYEXE" >&2
  exit 1
fi

# 3. Create venv and install dependencies
"$PYEXE" -m venv "$WORK/venv"
"$VENV_PIP" install --no-cache-dir -r "$WORK/requirements.txt"

# 4. Package: rename standalone dir to "python", then tar python + venv
mv "$PYROOT" "$WORK/python"
tar -czf "$OUT" -C "$WORK" python venv

echo "Built: $OUT"
