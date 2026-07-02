#!/bin/bash
# Runs when user attaches to Codespace (postAttachCommand).
# Clones lab files into WORK and fetches the decryption key once, writing it
# to ~/.chipcraft_key. Decryption itself happens inside gvim, in memory, when
# a *.v.enc file is opened — see tools/chipcraft-crypt.vim. No plaintext
# .v file is ever written to disk.

WORK="${WORK:-/workspaces/projects/.build.enc}"
BUILD="${BUILD:-/workspaces/projects/build}"
LAB_REPO="https://github.com/narrave/chipcraft-lab-files.git"

export WORK BUILD
# Class token for Cloudflare Worker key delivery
export CLASS_TOKEN=vlsi2026

# Clone lab files if not already present, otherwise pull latest.
# Clone into a temp dir first, then merge into WORK — cloning directly into
# WORK fails because the build tmpfs mount already exists there, making git
# see a "non-empty" target.
if [ -d "$WORK/.git" ]; then
    timeout 20 /usr/bin/git -C "$WORK" -c credential.helper= pull --quiet 2>/dev/null || true
else
    TMPCLONE=$(mktemp -d)
    if timeout 30 /usr/bin/git -c credential.helper= clone "$LAB_REPO" "$TMPCLONE" 2>/dev/null; then
        mkdir -p "$WORK"
        shopt -s dotglob
        mv "$TMPCLONE"/* "$WORK"/ 2>/dev/null
        shopt -u dotglob
        rmdir "$TMPCLONE" 2>/dev/null
        # Lock all cloned files read-only
        find "$WORK" -type f -exec chmod a-w {} \; 2>/dev/null || true
    else
        rm -rf "$TMPCLONE"
    fi
fi



# Fetch the key (CLASS_TOKEN → Cloudflare Worker) and write it to
# ~/.chipcraft_key for the gvim plugin and decrypt-all to use.
/usr/local/bin/chipcraft-key-init.sh

# entrypoint.sh already tried decrypt at container start, but the key isn't
# available that early in Codespace mode (CLASS_TOKEN arrives only after
# attach) — run it again now that the key actually exists.
/usr/local/bin/chipcraft-decrypt-all.sh >> /tmp/lab-crypto.log 2>&1 &

echo "[setup] Lab ready — open *.v.enc files under $WORK with gvim to edit."
echo "[setup] Decrypted read-only copies are in $BUILD"
