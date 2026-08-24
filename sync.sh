#!/usr/bin/env bash
# Sync personal repo -> live plugins dir.
# Uses cp -a (not symlink) because `omarchy plugin validate` rejects symlinks.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DST="$HOME/.config/omarchy/plugins/io.github.ardfard.ytmusic-launcher"
rm -rf "$DST"
cp -a "$SRC" "$DST"
rm -rf "$DST/.git" "$DST/.jj" 2>/dev/null || true
omarchy plugin validate "$DST"
echo "Synced -> $DST (validated)."
echo "Run: omarchy restart shell   (then click \uf167 — left toggles window, unfocus hides but audio keeps playing; right opens in browser)"
