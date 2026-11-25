<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/brand/brainlife-mark-on-dark.svg">
    <img src=".github/brand/brainlife-mark-on-light.svg" alt="brainlife.io" width="140">
  </picture>
</p>

<h1 align="center">ezbids-binaries</h1>

<p align="center">
  Native tools for the ezBIDS desktop app, built for Linux, macOS and Windows on every release tag.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-active-brightgreen.svg" alt="Status: active">
  <a href="https://brainlife.io"><img src="https://img.shields.io/badge/brainlife.io-site-3b9fd0.svg" alt="brainlife.io"></a>
  <a href="https://brainlife.io/docs"><img src="https://img.shields.io/badge/Docs-brainlife.io%2Fdocs-005981.svg" alt="Documentation"></a>
  <a href="https://doi.org/10.1038/s41592-024-02237-2"><img src="https://img.shields.io/badge/DOI-10.1038%2Fs41592--024--02237--2-e57536.svg" alt="Nature Methods paper"></a>
</p>

## 🧠 At a glance

| | |
|---|---|
| 🧭 **What** | GitHub Actions matrix that builds one binary per library per OS and attaches them to a GitHub release |
| 📦 **Libraries** | `7z` · `python-runtime` · `allineate` (AFNI 3dAllineate + MNI templates, used for skull-stripping/defacing) · `dcm2niix` |
| 🔌 **Used by** | [ezbids](https://github.com/brainlife/ezbids): `fetch-binaries.sh <platform> [arch]` downloads a pinned release into `handler/bin` for the Electron desktop build (ezBIDS takes dcm2niix from the official rordenlab release instead) |
| 🏷️ **Latest** | See [Releases](https://github.com/brainlife/ezbids-binaries/releases) |

## 🚀 Releasing

```bash
git tag v0.0.6 && git push origin v0.0.6
```

[`release-binaries.yml`](.github/workflows/release-binaries.yml) builds every library on `ubuntu-latest`, `macos-latest` and `windows-latest` (Windows `allineate` is cross-built with MinGW on Linux), then publishes the binaries (for example `7z-linux-amd64`, `7z-windows-amd64.exe`) on the release for that tag. Then bump `RELEASE_TAG` in ezBIDS `fetch-binaries.sh`.

## ➕ Adding a library

1. Add the name to `matrix.library` in `.github/workflows/release-binaries.yml`.
2. Copy [`scripts/build/example.sh`](scripts/build/example.sh) to `scripts/build/<library>.sh` and make it write exactly one file: `$DIST/$LIBRARY-$PLATFORM` (or `.exe` on Windows). Extra build dependencies go in `scripts/build-deps/<library>.sh`.

<details>
<summary><b>🧩 Build-script contract</b></summary>

[`scripts/build.sh`](scripts/build.sh) dispatches `(library, os, dist dir)` to `scripts/build/<library>.sh`; [`scripts/output-path.sh`](scripts/output-path.sh) returns where the workflow finds the result. Each script receives:

| Env var | Example | Use |
|---|---|---|
| `LIBRARY` | `7z` | Library name (and part of the output filename) |
| `OS` | `ubuntu-latest` | Runner OS |
| `PLATFORM` | `linux-amd64` | Suffix for the binary name |
| `DIST` | `dist` | Directory to write the binary into |

A script can build any way it likes: clone and `make`, `go build`, `cargo build --release`, or download a prebuilt binary with `curl`.

</details>

## 🔗 Related repositories

| Repository | Role |
|---|---|
| [ezbids](https://github.com/brainlife/ezbids) | Neuroscience data to BIDS, from instruments to shared datasets |

## 📚 Citing

If you use brainlife.io in your work, please cite:

> Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)

## 💰 Funding

brainlife.io is developed by the Pestilli Lab at The University of Texas at Austin and is publicly funded; acknowledging that support helps keep it running.

<details>
<summary>Grants (verified list, from <a href="https://github.com/brainlife/ezbids/blob/master/CREDITS.md#funding">ezbids CREDITS.md</a>)</summary>

| Funder | Award | Title |
|---|---|---|
| NIH NINDS | [U24NS140384](https://reporter.nih.gov/project-details/U24NS140384) | BRAIN CONNECTS: The Axonal Projectome EXchange (APEX) |
| NIH NIMH | [R01MH126699](https://reporter.nih.gov/project-details/R01MH126699) | Community-driven development of BIDS |
| NIH NIBIB | [R01EB030896](https://reporter.nih.gov/project-details/R01EB030896) | CRCNS US-France: open science and cloud computing of MEEG |
| NIH NIBIB | [R01EB029272](https://reporter.nih.gov/project-details/R01EB029272) | CRCNS US-France: lowering the barrier of entry to network neuroscience |
| NSF | [BCS-1636893](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893), [2148729](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729) | BD Spokes: Advanced Computational Neuroscience Network |
| NSF | [BCS-1734853](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853), [2203524](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524) | NCS-FO: Connectome mapping algorithms |
| NSF | [IIS-1912270](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270), [2148700](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700) | CRCNS US-German: DataLad |
| NSF | [ACI-1916518](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518) | BD Hubs: Midwest Big Data Hub |
| Wellcome Trust | [226486](https://grantnav.threesixtygiving.org/grant/360G-Wellcome-226486_Z_22_Z) | Developing an international governance framework to advance global brain and mental health data equity and innovation |

</details>

## 🤝 Contributing

Issues and pull requests are welcome in this repository. For help using brainlife.io, see the [documentation](https://brainlife.io/docs).

## ⚖️ License

This repository does not include a license file yet.

<p align="center"><sub>brainlife.io · Brain data across scales. One place to analyze, share and publish it. · The University of Texas at Austin</sub></p>
