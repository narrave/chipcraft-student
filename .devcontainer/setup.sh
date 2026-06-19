#!/bin/bash
# Runs automatically when the Codespace starts (postStartCommand).
# Clones lab files, strips key whitespace, starts decrypt_watch.

LAB_REPO="https://github.com/narrave/chipcraft-lab-files.git"

# Clone lab files if not already present, otherwise pull latest
if [ -d "$HOME/lab/.git" ]; then
    git -C "$HOME/lab" pull --quiet 2>/dev/null || true
else
    git -c credential.helper= clone "$LAB_REPO" "$HOME/lab" 2>/dev/null || true
fi

# Strip hidden CR / LF / spaces that Codespace secrets sometimes add
if [ -n "${CHIPCRAFT_KEY:-}" ]; then
    export CHIPCRAFT_KEY="$(printf '%s' "$CHIPCRAFT_KEY" | tr -d '\r\n ')"
fi

# Kill the earlier decrypt_watch that ran at container start (before ~/lab existed)
pkill -f decrypt_watch.sh 2>/dev/null || true
sleep 1

# Re-run with the correct key and lab files now in place
mkdir -p "$HOME/labs"
nohup /usr/local/bin/decrypt_watch.sh >> /tmp/lab-crypto.log 2>&1 &

echo "[setup] Lab ready — check ~/labs/ for your Verilog files."
