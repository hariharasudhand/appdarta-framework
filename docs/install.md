# Install AppDarta Engine

## Interactive install from public releases

If you have the installer script from the framework package or source tree:

```bash
bash scripts/install_framework.sh
```

That flow will:

1. query the latest public AppDarta releases
2. list the most recent five
3. ask you to choose one
4. download the selected release
5. install it into `APPDARTA_HOME`

## Local install from a package directory

If you already downloaded and unpacked a release locally:

```bash
bash scripts/install_framework.sh /path/to/appdarta-framework
```

## Shell setup

Add this to your shell profile:

```bash
export APPDARTA_HOME="${APPDARTA_HOME:-$HOME/.appdarta}"
export PATH="$APPDARTA_HOME/bin:$PATH"
```

## Verify

```bash
darta framework current
```
