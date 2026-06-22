#!/bin/bash
# ─────────────────────────────────────────────
#  ChipCraft Lab — Refresh Lab Files
#  Run this script to get the latest lab files
#  Usage: bash refresh-lab.sh
# ─────────────────────────────────────────────

LAB_DIR="${LAB_DIR:-/home/ubuntu/labs}"
WORK_DIR="${WORK_DIR:-/home/ubuntu/lab}"

echo ""
echo "========================================"
echo "  ChipCraft Lab — Refreshing Files..."
echo "========================================"
echo ""

# Step 1: Pull latest files from GitHub
echo "[1/4] Downloading latest lab files from GitHub..."
if git -C "$WORK_DIR" pull --quiet 2>/dev/null; then
    echo "      Done."
else
    echo "      ERROR: Could not connect to GitHub. Check your internet connection."
    exit 1
fi

# Step 2: Stop the old watcher
echo "[2/4] Restarting file watcher..."
pkill -f decrypt_watch.sh 2>/dev/null || true
sleep 1

# Step 3: Start fresh watcher (decrypts all .enc files into ~/labs/ with folder structure)
nohup /usr/local/bin/decrypt_watch.sh >> /tmp/lab-crypto.log 2>&1 &
sleep 3
echo "      Done."
echo ""

# Step 4: List all decrypted files (all types, all subfolders)
echo "[4/4] Files now available in $LAB_DIR :"
echo ""
if find "$LAB_DIR" -type f ! -name ".gitignore" 2>/dev/null | grep -q .; then
    find "$LAB_DIR" -type f ! -name ".gitignore" 2>/dev/null \
    | sort \
    | while read -r f; do
        rel="${f#$LAB_DIR/}"
        echo "      ✓  $rel"
    done
else
    echo "      (no files found — check /tmp/lab-crypto.log for errors)"
fi

echo ""
echo "========================================"
echo "  All done! Your files are in ~/labs/"
echo "========================================"
echo ""
