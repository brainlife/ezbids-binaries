# ezbids-binaries

Build and release binaries for ezbids libraries on Linux, macOS, and Windows.

## Skeleton

- **`.github/workflows/release-binaries.yml`** – On version tag push (`v*`), builds each library on each OS, uploads artifacts, then creates a GitHub release with named binaries (e.g. `example-linux-amd64`, `example-windows-amd64.exe`).

- **`scripts/build.sh`** – Dispatcher: takes `(library, os, dist dir)` and runs `scripts/build/<library>.sh`. Each library has its own script so fetch/build can differ per library.

- **`scripts/build/<name>.sh`** – One script per library. Receives env: `LIBRARY`, `OS`, `PLATFORM`, `DIST`. Must produce `$DIST/$LIBRARY-$PLATFORM` (or `.exe` on Windows). Use any method: clone + make, go build, cargo build, download prebuilt, etc.

- **`scripts/output-path.sh`** – Returns the path of the binary for the workflow; naming is fixed by the contract above.

## One script per library

You **do** have a different build script for each library: add `scripts/build/<library>.sh`.

Each script gets the same env and one job: write the binary to the right path.

| Env var    | Example          | Use |
|------------|------------------|-----|
| `LIBRARY`  | `example`        | Library name (and part of output filename). |
| `OS`       | `ubuntu-latest`  | Runner OS. |
| `PLATFORM` | `linux-amd64`   | Suffix for the binary name. |
| `DIST`     | `dist`           | Directory to write the binary into. |

**Contract:** create exactly one file:

- Windows: `$DIST/$LIBRARY-$PLATFORM.exe`
- Otherwise: `$DIST/$LIBRARY-$PLATFORM` (and `chmod +x` if needed)

**Examples of what a library script can do:**

- **Go:** clone repo, `go build -o "$OUT" ./cmd/...`
- **Rust:** clone repo, `cargo build --release`, copy `target/release/foo` to `$OUT`
- **Prebuilt:** `curl -L <url> -o "$OUT"`
- **Make:** clone repo, `make`, copy the built binary to `$OUT`

See `scripts/build/example.sh` for a minimal stub; copy it to `scripts/build/<yourlib>.sh` and replace the body with your fetch/build.

## Adding a library

1. Add the library name to the `matrix.library` list in `.github/workflows/release-binaries.yml`.
2. Add `scripts/build/<library>.sh` that sets up the build (clone/fetch), builds, and writes the binary to `$DIST/$LIBRARY-$PLATFORM` (or `.exe` on Windows).

## Releasing

```bash
git tag v1.0.0
git push origin v1.0.0
```

Binaries will appear on the GitHub release for that tag.
