# Install AppDarta Framework

## 1. Download a release

Download a versioned AppDarta Engine release from GitHub Releases.

## 2. Install it under `APPDARTA_HOME`

Recommended shell profile:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"
```

Then install the release with:

```bash
darta framework install --package /path/to/appdarta-framework
```

## 3. Confirm the active release

```bash
darta framework current
```

## 4. Work inside a vertical project

```bash
cd /path/to/vertical-project
darta project bootstrap
darta doctor --skip-stack
```
