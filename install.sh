#!/usr/bin/env bash
# SHAHADATH Turbo Max — installer script
# Served at https://shahadath-serve.onrender.com/install.sh
# Detects OS/arch and downloads the correct binary from GitHub Releases.

set -e

GITHUB_OWNER="Ileana747"
GITHUB_REPO="Shahadath-Turbo-Max-CLI-ORG"
RELEASE_BASE="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest/download"

BOLD="\033[1m"
PURPLE="\033[38;2;108;99;255m"
TEAL="\033[38;2;78;205;196m"
RED="\033[38;2;255;107;107m"
YELLOW="\033[38;2;255;230;109m"
RESET="\033[0m"

say() { printf "${PURPLE}▶${RESET} %s\n" "$1"; }
ok()   { printf "${TEAL}✓${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
err()  { printf "${RED}✗${RESET} %s\n" "$1"; }

# ─── Detect OS ────────────────────────────────────────────────────────────────
detect_os() {
  local os
  os="$(uname -s 2>/dev/null || echo unknown)"
  case "$os" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

# ─── Detect architecture (armv8l maps to arm64) ───────────────────────────────
detect_arch() {
  local arch
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    i386|i486|i586|i686) echo "386" ;;
    aarch64|arm64) echo "arm64" ;;
    armv8l) echo "arm64" ;;
    armv7l|armv7) echo "armv7" ;;
    *) echo "$arch" ;;
  esac
}

# ─── Termux / Android detection ───────────────────────────────────────────────
is_termux() {
  [ -n "$PREFIX" ] && [ "${PREFIX#*com.termux}" != "$PREFIX" ]
}

is_android() {
  [ "$(detect_os)" = "android" ] || [ -n "$ANDROID_ROOT" ]
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  printf "${BOLD}${PURPLE}SHAHADATH Turbo Max${RESET} — installer\n\n"

  local os arch
  os="$(detect_os)"
  arch="$(detect_arch)"

  # Android via Termux: override os to linux (Termux uses linux binaries).
  if is_termux; then
    os="linux"
    warn "Termux detected — using linux binaries."
  fi

  say "Detected: os=${os} arch=${arch}"

  if [ "$os" = "unknown" ]; then
    err "Unsupported OS. Install manually from ${RELEASE_BASE}"
    exit 1
  fi

  # Map arch to release asset name.
  local arch_asset
  case "$arch" in
    amd64) arch_asset="x86_64" ;;
    "386") arch_asset="i386" ;;
    arm64) arch_asset="arm64" ;;
    armv7) arch_asset="armv7" ;;
    *) arch_asset="$arch" ;;
  esac

  local os_asset
  case "$os" in
    darwin) os_asset="macos" ;;
    *) os_asset="$os" ;;
  esac

  local asset="shahadath_${os_asset}_${arch_asset}.tar.gz"
  if [ "$os" = "windows" ]; then
    asset="shahadath_${os_asset}_${arch_asset}.zip"
  fi

  local url="${RELEASE_BASE}/${asset}"
  say "Downloading: ${url}"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  if ! curl -fsSL "$url" -o "${tmpdir}/${asset}"; then
    err "Download failed. Check that the release for ${os}/${arch} exists."
    exit 1
  fi
  ok "Downloaded"

  # Extract.
  say "Extracting…"
  if [ "$os" = "windows" ]; then
    if command -v unzip >/dev/null 2>&1; then
      unzip -o "${tmpdir}/${asset}" -d "${tmpdir}/out" >/dev/null
    else
      err "unzip not found. Extract ${asset} manually."
      exit 1
    fi
  else
    tar -xzf "${tmpdir}/${asset}" -C "${tmpdir}/out" 2>/dev/null || mkdir -p "${tmpdir}/out" && tar -xzf "${tmpdir}/${asset}" -C "${tmpdir}/out"
  fi

  local bin="shahadath"
  [ "$os" = "windows" ] && bin="shahadath.exe"

  local extracted="${tmpdir}/out/${bin}"
  if [ ! -f "$extracted" ]; then
    # Try finding the binary in the extracted dir.
    extracted="$(find "${tmpdir}/out" -name "$bin" -type f | head -1)"
  fi
  if [ ! -f "$extracted" ]; then
    err "Binary not found in archive."
    exit 1
  fi

  # Install.
  local install_dir
  if [ "$os" = "windows" ]; then
    install_dir="$HOME/AppData/Local/Shahadath"
  elif is_termux; then
    install_dir="$PREFIX/bin"
  elif [ -w "/usr/local/bin" ]; then
    install_dir="/usr/local/bin"
  else
    install_dir="$HOME/.local/bin"
  fi
  mkdir -p "$install_dir"

  say "Installing to ${install_dir}/${bin}"
  cp "$extracted" "${install_dir}/${bin}"
  chmod +x "${install_dir}/${bin}" 2>/dev/null || true
  ok "Installed"

  # Add to PATH (if not already).
  case ":$PATH:" in
    *":${install_dir}:"*) ;;
    *)
      warn "${install_dir} is not in your PATH."
      if [ -n "$BASH_VERSION" ]; then
        echo "export PATH=\"${install_dir}:\$PATH\"" >> "$HOME/.bashrc"
        ok "Added to ~/.bashrc. Run: source ~/.bashrc"
      elif [ -n "$ZSH_VERSION" ]; then
        echo "export PATH=\"${install_dir}:\$PATH\"" >> "$HOME/.zshrc"
        ok "Added to ~/.zshrc. Run: source ~/.zshrc"
      fi
      ;;
  esac

  # Verify.
  say "Verifying…"
  if "${install_dir}/${bin}" --version >/dev/null 2>&1; then
    ok "$("${install_dir}/${bin}" --version)"
  else
    warn "Installed but not on PATH yet. Restart your shell or run with full path."
  fi

  printf "\n${BOLD}${TEAL}Done.${RESET} Run ${BOLD}shahadath help${RESET} to get started.\n"
}

main "$@"
