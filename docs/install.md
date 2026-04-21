# Install AppDarta Engine

## Shell setup

Add these lines to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) before running the installer:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"
```

## Install from a public release

Download and run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/hariharasudhand/appdarta-framework/main/scripts/install_framework.sh -o install_darta.sh
bash install_darta.sh
```

The installer fetches available releases from GitHub, lists them, and installs your choice. When prompted, select **vDR.0.3** (the current release). No manual download needed.

You can discard `install_darta.sh` after the install completes.

> **Already on vDR.0.2?** Run the same two commands again and select vDR.0.3. The installer upgrades in place.

## Install from a local package directory

If you have already downloaded and unpacked a release locally:

```bash
bash scripts/install_framework.sh /path/to/appdarta-framework
```

## Verify

```bash
darta version
darta framework current
```
