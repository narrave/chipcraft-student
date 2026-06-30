#!/bin/bash
# Runs when user attaches to Codespace (postAttachCommand).
# Clones lab files and fetches the decryption key once, writing it to
# ~/.chipcraft_key. Decryption itself happens inside gvim, in memory, when
# a *.v.enc file is opened — see tools/chipcraft-crypt.vim. No plaintext
# .v file is ever written to disk.

LAB_REPO="https://github.com/narrave/chipcraft-lab-files.git"

# Clone lab files if not already present, otherwise pull latest.
# Clone into a temp dir first, then merge into ~/lab — cloning directly into
# ~/lab fails because the build tmpfs mount (declared in devcontainer.json)
# already exists there, making git see a "non-empty" target.
if [ -d "$HOME/lab/.git" ]; then
    /usr/bin/git -C "$HOME/lab" pull --quiet 2>/dev/null || true
else
    TMPCLONE=$(mktemp -d)
    if /usr/bin/git -c credential.helper= clone "$LAB_REPO" "$TMPCLONE" 2>/dev/null; then
        mkdir -p "$HOME/lab"
        shopt -s dotglob
        mv "$TMPCLONE"/* "$HOME/lab"/ 2>/dev/null
        shopt -u dotglob
        rmdir "$TMPCLONE" 2>/dev/null
    else
        rm -rf "$TMPCLONE"
    fi
fi

# Fetch the key (CLASS_TOKEN Codespace secret → Cloudflare Worker) and
# write it to ~/.chipcraft_key for the gvim plugin to use.
/usr/local/bin/chipcraft-key-init.sh

# Point ~/lab to the read-only hook baked into the Docker image.
# Students cannot edit /usr/local/lib/ — runs as unprivileged ubuntu user.
/usr/bin/git -C "$HOME/lab" config core.hooksPath \
    /usr/local/lib/chipcraft-hooks

# entrypoint.sh already tried this at container start, but the key isn't
# available that early in Codespace mode (CLASS_TOKEN arrives only after
# attach) — run it again now that the key actually exists. See the script's
# own header comment for the security tradeoff this represents.
/usr/local/bin/chipcraft-decrypt-all.sh >> /tmp/lab-crypto.log 2>&1 &

echo "[setup] Lab setup complete — open *.v.enc files under ~/lab/ with gvim to edit."
