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

echo "[1/3] Downloading latest lab files from GitHub..."
if /usr/bin/git -C "$WORK_DIR" pull --quiet 2>/dev/null; then
    echo "      Done."
else
    echo "      ERROR: Could not connect to GitHub. Check your internet connection."
    exit 1
fi

echo "[2/3] Refreshing decryption key..."
/usr/local/bin/chipcraft-key-init.sh
echo ""

echo "[3/3] Re-decrypting into ~/lab/build (multi-file projects, e.g. tarang2_dp1)..."
/usr/local/bin/chipcraft-decrypt-all.sh
echo ""

echo "========================================"
echo "  All done! Open any *.v.enc file under"
echo "  $WORK_DIR with gvim to edit it, or work"
echo "  directly in $WORK_DIR/build for projects"
echo "  like tarang2_dp1."
echo "========================================"
echo ""
