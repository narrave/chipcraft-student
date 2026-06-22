#!/bin/bash
# ─────────────────────────────────────────────
#  ChipCraft Lab — Refresh Lab Files
#  Run this script to get the latest lab files
#  Usage: bash refresh-lab.sh
# ─────────────────────────────────────────────

echo ""
echo "========================================"
echo "  ChipCraft Lab — Refreshing Files..."
echo "========================================"
echo ""

# Step 1: Pull latest files from GitHub
echo "[1/3] Downloading latest lab files from GitHub..."
if git -C ~/lab pull --quiet 2>/dev/null; then
    echo "      Done."
else
    echo "      ERROR: Could not connect to GitHub. Check your internet connection."
    exit 1
fi

# Step 2: Stop the old watcher
echo "[2/3] Restarting file watcher..."
pkill -f decrypt_watch.sh 2>/dev/null || true
sleep 1

# Step 3: Start fresh watcher (decrypts new files into ~/labs/)
nohup /usr/local/bin/decrypt_watch.sh >> /tmp/lab-crypto.log 2>&1 &
sleep 3

echo "      Done."
echo ""
echo "[3/3] Checking ~/labs/ for new files..."
ls ~/labs/*.v 2>/dev/null | while read f; do
    echo "      ✓  $(basename $f)"
done

echo ""
echo "========================================"
echo "  All done! Your files are in ~/labs/"
echo "========================================"
echo ""
