#!/bin/bash
# ─────────────────────────────────────────────
#  ChipCraft Lab — Refresh Lab Files
#  Run this script to get the latest lab files
#  Usage: bash refresh-lab.sh
# ─────────────────────────────────────────────

WORK_DIR="${WORK_DIR:-/home/ubuntu/lab}"

echo ""
echo "========================================"
echo "  ChipCraft Lab — Refreshing Files..."
echo "========================================"
echo ""

echo "[1/2] Downloading latest lab files from GitHub..."
if git -C "$WORK_DIR" pull --quiet 2>/dev/null; then
    echo "      Done."
else
    echo "      ERROR: Could not connect to GitHub. Check your internet connection."
    exit 1
fi

echo "[2/2] Refreshing decryption key..."
/usr/local/bin/chipcraft-key-init.sh
echo ""

echo "========================================"
echo "  All done! Open any *.v.enc file under"
echo "  $WORK_DIR with gvim to edit it."
echo "========================================"
echo ""
