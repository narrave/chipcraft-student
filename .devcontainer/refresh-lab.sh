#!/bin/bash
# ─────────────────────────────────────────────
#  ChipCraft Lab — Refresh Lab Files
#  Run this script to get the latest lab files
#  Usage: bash refresh-lab.sh
# ─────────────────────────────────────────────

WORK="${WORK:-/workspaces/projects/.build.enc}"
BUILD="${BUILD:-/workspaces/projects/build}"

export WORK BUILD

echo ""
echo "========================================"
echo "  ChipCraft Lab — Refreshing Files..."
echo "========================================"
echo ""

echo "[1/3] Downloading latest lab files from GitHub..."
if /usr/bin/git -C "$WORK" pull --quiet 2>/dev/null; then
    echo "      Done."
else
    echo "      ERROR: Could not connect to GitHub. Check your internet connection."
    exit 1
fi

echo "[2/3] Refreshing decryption key..."
/usr/local/bin/chipcraft-key-init.sh
echo ""

echo "[3/3] Re-decrypting into $BUILD..."
/usr/local/bin/chipcraft-decrypt-all.sh
echo ""

echo "========================================"
echo "  All done! Open any *.v.enc file under"
echo "  $WORK with gvim to edit it."
echo "  Read-only decrypted copies are in"
echo "  $BUILD"
echo "========================================"
echo ""
