# Install Darta Platform

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
curl -fsSL https://raw.githubusercontent.com/hariharasudhand/appdarta-framework/master/scripts/install_framework.sh -o install_darta.sh
bash install_darta.sh
```

The installer detects your OS and CPU, fetches available releases from GitHub, and installs your choice. When prompted, select **vDR.0.5** (the current release). No manual download needed.

You can discard `install_darta.sh` after the install completes.

> **Already on vDR.0.4?** Run the same two commands again and select vDR.0.5. The installer upgrades in place.

## Install from a local package directory

If you have already downloaded and unpacked a release locally:

```bash
bash scripts/install_framework.sh /path/to/appdarta-framework-linux-amd64
```

## Verify

```bash
darta --version
darta framework current
```

## Connect to a DHIL-DT server

Darta routes AI work through three endpoints on a DHIL-DT server:

- `--dt` — DHIL-DT design-time routing server. Used by `darta dhil-dt policy` and the UI wizard's AI routing panel.
- `--l1` — Layer-1 model endpoint (Ollama-compatible). Used for cheap first-pass routing, classification, and local drafting.
- `--litellm` — LiteLLM proxy endpoint for cloud/provider model calls.

Configure and activate a public shared server:

```bash
darta framework set-server public \
  --dt http://<server-ip>:8080 \
  --l1 http://<server-ip>:11435 \
  --litellm http://<server-ip>:4000

darta framework use public
darta framework status
```

### Step 2 — L1 authentication (shared servers)

Protected L1 endpoints require a per-developer API key. Your server admin creates one on the L1 host:

```bash
# On the L1 Ubuntu server (as root):
darta dhil l1 keys create --dev <your-name>
```

Configure your machine with the issued key (endpoint is prefilled from `framework use`):

```bash
darta dhil l1 configure --key <key-from-admin>
darta dhil l1 test
```

Or combine endpoint setup and key in one step:

```bash
darta framework set-server public --l1 http://<server-ip>:11435 --l1-key <key>
```

You can also configure the key in the UI: **AI Settings → Routing → L1 authentication**.

To run DHIL-DT locally instead:

```bash
darta dhil-dt serve --port 8080
export DHIL_DT_SERVER=http://127.0.0.1:8080
```

## Installing the runtime (Deploy/Run stage — optional)

The Darta Platform ships in two parts. The install above gives you the full Design CLI (Setup → Build). When you're ready to run agents locally or deploy to cloud, install the runtime too:

```bash
darta runtime install
```

This downloads the `darta-wasmtime-host` binary for your platform and installs it to `~/.appdarta/runtime/current/`. After install, `darta --version` will show both the CLI version and the runtime version.
