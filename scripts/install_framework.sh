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

detect_platform() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "$os" in
    linux|darwin) ;;
    *) echo "unsupported OS: $os — AppDarta supports macOS and Linux (including WSL2)" >&2; exit 2 ;;
  esac
  case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "unsupported architecture: $arch" >&2; exit 2 ;;
  esac
  echo "${os}-${arch}"
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
  # Remove current: unlink if symlink, otherwise move aside to avoid "Operation not permitted"
  # warnings from trying to delete files that are in use by the running framework process.
  if [ -L "$current_dir" ]; then
    rm -f "$current_dir"
  elif [ -d "$current_dir" ]; then
    mv "$current_dir" "${current_dir}.old.$$" 2>/dev/null || rm -rf "$current_dir" || true
    rm -rf "${current_dir}.old.$$" 2>/dev/null || true
  fi
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
    print(f"{idx}. {name} [{tag}]{prerelease}")
PY
}

release_count() {
  local releases_json="$1"
  python3 - "$releases_json" <<'PY'
import json, sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
print(min(len(data), 5))
PY
}

download_selected_release() {
  local releases_json="$1"
  local choice="$2"
  local platform="$3"
  python3 - "$releases_json" "$choice" "$platform" <<'PY'
import json, sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text())
raw = sys.argv[2].strip()
platform = sys.argv[3].strip()
selected = None

if raw.isdigit():
    choice = int(raw) - 1
    if choice < 0 or choice >= min(len(data), 5):
        raise SystemExit("invalid release selection")
    selected = data[choice]
else:
    for release in data[:5]:
        tag = (release.get("tag_name") or "").strip()
        normalized = tag[1:] if tag.startswith("v") else tag
        if raw == tag or raw == normalized:
            selected = release
            break
    if selected is None:
        raise SystemExit("invalid release selection")

release = selected
assets = release.get("assets") or []

# Prefer platform-specific asset, fall back to generic for older releases
platform_specific = f"appdarta-framework-{platform}.tar.gz"
generic = "appdarta-framework.tar.gz"
url_by_name = {(asset.get("name") or ""): (asset.get("browser_download_url") or "") for asset in assets}

if platform_specific in url_by_name and url_by_name[platform_specific]:
    print(url_by_name[platform_specific])
    raise SystemExit(0)

# Fall back to legacy generic archive
if generic in url_by_name and url_by_name[generic]:
    print(url_by_name[generic], file=sys.stderr)  # warn via stderr
    print("warning: no platform-specific release found for '{}', using generic archive (may be wrong platform)".format(platform), file=sys.stderr)
    print(url_by_name[generic])
    raise SystemExit(0)

raise SystemExit("no downloadable appdarta-framework asset found for platform '{}' in selected release".format(platform))
PY
}

download_and_extract_release() {
  require_command curl
  require_command tar
  require_command python3

  local platform
  platform="$(detect_platform)"
  echo "Detected platform: ${platform}" >&2

  tmp_root="$(mktemp -d)"
  local releases_json="$tmp_root/releases.json"
  curl -fsSL "$api_base/releases?per_page=5" -o "$releases_json"

  local count
  count="$(release_count "$releases_json")"
  if [ "$count" -eq 0 ]; then
    echo "No published AppDarta Engine releases were found for $repo_slug." >&2
    echo "A maintainer needs to publish a release asset first, or install from a local package directory." >&2
    exit 2
  fi

  echo "Available AppDarta Engine releases:" >&2
  choose_release_asset "$releases_json" >&2

  local choice=""
  while :; do
    printf "Select one of the listed releases by number or tag [1-%s]: " "$count" >&2
    read -r choice
    case "$choice" in
      '' )
        echo "Please enter a release number or tag." >&2
        ;;
      * )
        if download_selected_release "$releases_json" "$choice" "$platform" >/dev/null 2>&1; then
          break
        fi
        echo "Selection must match one of the listed release numbers or tags." >&2
        ;;
    esac
  done

  local asset_url
  asset_url="$(download_selected_release "$releases_json" "$choice" "$platform")"
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
