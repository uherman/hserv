#!/bin/sh
# hserv installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/uherman/hserv/main/install.sh | sh
#
# Env vars:
#   PREFIX       Install prefix (default: /usr/local; use ~/.local for user-only)
#   VERSION      Release tag to install (default: latest)
#   HSERV_REPO   GitHub repo as 'owner/name' (default: uherman/hserv)
set -eu

REPO="${HSERV_REPO:-uherman/hserv}"
PREFIX="${PREFIX:-/usr/local}"
VERSION="${VERSION:-latest}"

die() { printf 'install: %s\n' "$*" >&2; exit 1; }

command -v curl    >/dev/null 2>&1 || die 'curl is required'
command -v tar     >/dev/null 2>&1 || die 'tar is required'
command -v python3 >/dev/null 2>&1 || die 'python3 is required'
command -v hcc     >/dev/null 2>&1 || \
  printf 'warning: hcc not found in PATH; install holyc-lang to use `hserv build`\n  https://github.com/Jamesbarford/holyc-lang\n' >&2

if [ "$VERSION" = latest ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' \
    | head -n1)
  [ -n "$VERSION" ] || die 'could not resolve latest release tag'
fi

ver_no_v=${VERSION#v}
tarball="hserv-${ver_no_v}.tar.gz"
url="https://github.com/$REPO/releases/download/$VERSION/$tarball"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'downloading %s\n' "$url"
curl -fsSL "$url" -o "$tmp/$tarball"
tar -xzf "$tmp/$tarball" -C "$tmp"

cd "$tmp/hserv-${ver_no_v}"

if [ -w "$PREFIX" ] || [ "$(id -u)" -eq 0 ]; then
  SUDO=''
else
  SUDO='sudo'
fi

$SUDO make install PREFIX="$PREFIX"
printf 'hserv %s installed\n' "$VERSION"
