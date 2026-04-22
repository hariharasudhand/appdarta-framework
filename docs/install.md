# Install AppDarta Engine

## Supported platforms

| Platform | Supported |
|---|---|
| macOS — Apple Silicon (M1/M2/M3/M4) | ✓ |
| macOS — Intel | ✓ |
| Linux — x86_64 (Ubuntu, Debian, Fedora, etc.) | ✓ |
| Linux — arm64 (AWS Graviton, Raspberry Pi 64-bit) | ✓ |
| Windows via WSL2 | ✓ (follow Linux steps) |
| Windows native | — not supported |

**Windows users:** install [WSL2 with Ubuntu](https://learn.microsoft.com/en-us/windows/wsl/install), open a WSL2 terminal, and follow the Linux steps below.

## Shell setup

Add these lines to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) before running the installer:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"
```

Then reload your shell or open a new terminal.

## Install from a public release

Download and run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/hariharasudhand/appdarta-framework/main/scripts/install_framework.sh -o install_darta.sh
bash install_darta.sh
```

The installer detects your OS and CPU, fetches available releases from GitHub, and installs your choice. When prompted, select **vDR.0.4** (the current release). No manual download needed.

You can discard `install_darta.sh` after the install completes.

> **Already on vDR.0.3?** Run the same two commands again and select vDR.0.4. The installer upgrades in place.

## Install from a local package directory

If you have already downloaded and unpacked a release locally:

```bash
bash scripts/install_framework.sh /path/to/appdarta-framework-linux-amd64
```

## Verify

```bash
darta version
darta framework current
```
