#!/bin/sh
# Cut a hserv release: tag, build tarball, push tag, create GitHub release.
#
# Usage: scripts/release.sh <version>     # e.g. scripts/release.sh 0.1.0
set -eu

[ $# -eq 1 ] || { echo 'usage: scripts/release.sh <version>' >&2; exit 1; }

VERSION="$1"
TAG="v$VERSION"

case "$VERSION" in
  [0-9]*) ;;
  *) echo "version must start with a digit, e.g. 0.1.0" >&2; exit 1 ;;
esac

command -v gh  >/dev/null 2>&1 || { echo 'gh CLI required (https://cli.github.com)' >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo 'git required' >&2; exit 1; }

if ! git diff --quiet HEAD 2>/dev/null; then
  echo 'working tree dirty; commit or stash first' >&2; exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "tag $TAG already exists" >&2; exit 1
fi

git tag -a "$TAG" -m "hserv $TAG"
make dist VERSION="$VERSION"
git push origin "$TAG"
gh release create "$TAG" "dist/hserv-$VERSION.tar.gz" \
  --title "hserv $TAG" \
  --generate-notes

echo "released $TAG"
