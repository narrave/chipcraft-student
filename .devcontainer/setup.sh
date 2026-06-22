#!/bin/bash
# Runs when user attaches to Codespace (postAttachCommand).
# Clones lab files, fetches key from Cloudflare Worker, starts decrypt_watch.
# Skips if ~/labs/ already has decrypted files (already set up this session).

if ls "$HOME/labs/"*.v 2>/dev/null | grep -q .; then
    echo "[setup] Lab already ready — ~/labs/ has files."
    exit 0
fi

WORKER_URL="https://chipcraft-key.nagajyothibonthagorla.workers.dev"
LAB_REPO="https://github.com/narrave/chipcraft-lab-files.git"

# Clone lab files if not already present, otherwise pull latest
if [ -d "$HOME/lab/.git" ]; then
    /usr/bin/git -C "$HOME/lab" pull --quiet 2>/dev/null || true
else
    /usr/bin/git -c credential.helper= clone "$LAB_REPO" "$HOME/lab" 2>/dev/null || true
fi

# Fetch key from Cloudflare Worker using CLASS_TOKEN
# We do this here (not inside decrypt_watch.sh) because postStartCommand
# may not reliably pass env vars to background subprocesses.
if [ -n "${CLASS_TOKEN:-}" ]; then
    CLEAN_TOKEN="$(printf '%s' "$CLASS_TOKEN" | tr -d '\r\n ')"
    USER="${GITHUB_USER:-student}"
    echo "[setup] Fetching key from Cloudflare Worker …"
    export LAB_KEY
    LAB_KEY=$(curl -sf --max-time 15 \
        -X POST "$WORKER_URL" \
        -H "Content-Type: application/json" \
        -d "{\"class_token\":\"$CLEAN_TOKEN\",\"user\":\"$USER\"}" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['key'])" 2>/dev/null || echo "")
    if [ -n "$LAB_KEY" ]; then
        echo "[setup] Key obtained from Worker."
    else
        echo "[setup] ERROR: could not fetch key from Worker. Check CLASS_TOKEN secret."
    fi
fi

# Kill the earlier decrypt_watch that ran at container start (before ~/lab existed)
pkill -f decrypt_watch.sh 2>/dev/null || true
sleep 1

# Re-run with LAB_KEY now set (inherited by the subprocess)
mkdir -p "$HOME/labs"
nohup /usr/local/bin/decrypt_watch.sh >> /tmp/lab-crypto.log 2>&1 &

# Point ~/lab to the read-only hook baked into the Docker image.
# Students cannot edit /usr/local/lib/ — runs as unprivileged ubuntu user.
/usr/bin/git -C "$HOME/lab" config core.hooksPath \
    /usr/local/lib/chipcraft-hooks

echo "[setup] Lab setup complete — check ~/labs/ for your Verilog files."