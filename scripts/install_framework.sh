#!/usr/bin/env bash
set -euo pipefail

repo_slug="${APPDARTA_PUBLIC_FRAMEWORK_REPO:-hariharasudhand/appdarta-framework}"
api_base="${APPDARTA_RELEASE_API_BASE:-https://api.github.com/repos/$repo_slug}"
src_input="${1:-${FRAMEWORK_PACKAGE_DIR:-}}"
appdarta_home="${APPDARTA_HOME:-$HOME/.appdarta}"
tmp_root=""

cleanup() {
  if [ -n "${tmp_root:-}" ] && [ -d "$tmp_root" ]; then
    rm -rf "$tmp_root"
  fi
}
trap cleanup EXIT

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "required command not found: $1" >&2
    exit 2
  fi
}

write_launchers() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"

  cat > "$bin_dir/darta" <<EOF
#!/usr/bin/env sh
set -eu
appdarta_home="\${APPDARTA_HOME:-$appdarta_home}"
export APPDARTA_HOME="\$appdarta_home"
if [ -z "\${APPDARTA_FRAMEWORK_HOME:-}" ]; then
  export APPDARTA_FRAMEWORK_HOME="\$appdarta_home/framework/current"
fi
exec "\$APPDARTA_FRAMEWORK_HOME/bin/appdarta" "\$@"
EOF
  chmod +x "$bin_dir/darta"

  cat > "$bin_dir/appdarta" <<EOF
#!/usr/bin/env sh
set -eu
appdarta_home="\${APPDARTA_HOME:-$appdarta_home}"
export APPDARTA_HOME="\$appdarta_home"
if [ -z "\${APPDARTA_FRAMEWORK_HOME:-}" ]; then
  export APPDARTA_FRAMEWORK_HOME="\$appdarta_home/framework/current"
fi
exec "\$APPDARTA_FRAMEWORK_HOME/bin/appdarta" "\$@"
EOF
  chmod +x "$bin_dir/appdarta"

  cat > "$bin_dir/darta.cmd" <<EOF
@echo off
setlocal
if "%APPDARTA_HOME%"=="" set "APPDARTA_HOME=$appdarta_home"
if "%APPDARTA_FRAMEWORK_HOME%"=="" set "APPDARTA_FRAMEWORK_HOME=%APPDARTA_HOME%\framework\current"
"%APPDARTA_FRAMEWORK_HOME%\bin\appdarta.exe" %*
EOF

  cat > "$bin_dir/darta.ps1" <<EOF
if (-not \$env:APPDARTA_HOME) { \$env:APPDARTA_HOME = "$appdarta_home" }
if (-not \$env:APPDARTA_FRAMEWORK_HOME) { \$env:APPDARTA_FRAMEWORK_HOME = Join-Path \$env:APPDARTA_HOME "framework/current" }
& (Join-Path \$env:APPDARTA_FRAMEWORK_HOME "bin/appdarta.exe") @args
EOF
}

install_package_dir() {
  local src_dir="$1"
  src_dir="$(cd "$src_dir" && pwd)"

  local manifest_path="$src_dir/share/release/manifest.json"
  if [ ! -f "$manifest_path" ]; then
    echo "missing framework manifest at $manifest_path" >&2
    exit 2
  fi

  local release_version
  release_version="$(sed -n 's/.*"release_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest_path" | head -n1)"
  if [ -z "${release_version:-}" ]; then
    echo "could not determine release_version from $manifest_path" >&2
    exit 2
  fi

  local releases_dir="$appdarta_home/framework/releases"
  local framework_dir="$releases_dir/$release_version"
  local current_dir="$appdarta_home/framework/current"
  local bin_dir="$appdarta_home/bin"

  mkdir -p "$releases_dir" "$bin_dir"
  rm -rf "$framework_dir"
  cp -R "$src_dir" "$framework_dir"
  rm -rf "$current_dir"
  ln -s "$framework_dir" "$current_dir" 2>/dev/null || cp -R "$framework_dir" "$current_dir"

  write_launchers "$bin_dir"

  echo "Installed AppDarta Engine to $framework_dir"
  echo "Current engine -> $current_dir"
  echo "Add this to your shell profile if needed:"
  echo "  export APPDARTA_HOME=\"$appdarta_home\""
  echo "  export PATH=\"\$APPDARTA_HOME/bin:\$PATH\""
}

choose_release_asset() {
  local releases_json="$1"
  python3 - "$releases_json" <<'PY'
import json, sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
if not data:
    print("NO_RELEASES")
    sys.exit(0)

for idx, release in enumerate(data[:5], start=1):
    name = release.get("name") or release.get("tag_name") or f"release-{idx}"
    tag = release.get("tag_name") or ""
    prerelease = " prerelease" if release.get("prerelease") else ""
    print(f"{idx}. {name} ({tag}){prerelease}")
PY
}

download_selected_release() {
  local releases_json="$1"
  local choice="$2"
  python3 - "$releases_json" "$choice" <<'PY'
import json, sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
choice = int(sys.argv[2]) - 1
if choice < 0 or choice >= min(len(data), 5):
    raise SystemExit("invalid release selection")
release = data[choice]
assets = release.get("assets") or []
for asset in assets:
    name = asset.get("name") or ""
    url = asset.get("browser_download_url") or ""
    if name.endswith(".tar.gz") and "appdarta-framework" in name and url:
        print(url)
        raise SystemExit(0)
raise SystemExit("no downloadable appdarta-framework .tar.gz asset found for selected release")
PY
}

download_and_extract_release() {
  require_command curl
  require_command tar
  require_command python3

  tmp_root="$(mktemp -d)"
  local releases_json="$tmp_root/releases.json"
  curl -fsSL "$api_base/releases?per_page=5" -o "$releases_json"

  echo "Available AppDarta Engine releases:"
  choose_release_asset "$releases_json"
  printf "Select a release [1-5]: "
  read -r choice

  local asset_url
  asset_url="$(download_selected_release "$releases_json" "$choice")"
  local archive_path="$tmp_root/appdarta-framework.tar.gz"
  curl -fL "$asset_url" -o "$archive_path"

  local extract_dir="$tmp_root/extract"
  mkdir -p "$extract_dir"
  tar -xzf "$archive_path" -C "$extract_dir"

  local package_dir
  package_dir="$(find "$extract_dir" -type f -path '*/share/release/manifest.json' -print | head -n1)"
  if [ -z "${package_dir:-}" ]; then
    echo "downloaded archive does not contain an AppDarta release manifest" >&2
    exit 2
  fi
  dirname "$(dirname "$(dirname "$package_dir")")"
}

if [ -n "$src_input" ] && [ -d "$src_input" ]; then
  install_package_dir "$src_input"
  exit 0
fi

if [ -n "$src_input" ]; then
  echo "package directory not found: $src_input" >&2
  exit 2
fi

package_dir="$(download_and_extract_release)"
install_package_dir "$package_dir"
