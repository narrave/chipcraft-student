#!/bin/bash
# Runs when user attaches to Codespace (postAttachCommand).
# Clones lab files and fetches the decryption key once, writing it to
# ~/.chipcraft_key. Decryption itself happens inside gvim, in memory, when
# a *.v.enc file is opened — see tools/chipcraft-crypt.vim. No plaintext
# .v file is ever written to disk.

LAB_REPO="https://github.com/narrave/chipcraft-lab-files.git"

# Clone lab files if not already present, otherwise pull latest
if [ -d "$HOME/lab/.git" ]; then
    /usr/bin/git -C "$HOME/lab" pull --quiet 2>/dev/null || true
else
    /usr/bin/git -c credential.helper= clone "$LAB_REPO" "$HOME/lab" 2>/dev/null || true
fi

# Fetch the key (CLASS_TOKEN Codespace secret → Cloudflare Worker) and
# write it to ~/.chipcraft_key for the gvim plugin to use.
/usr/local/bin/chipcraft-key-init.sh

# Point ~/lab to the read-only hook baked into the Docker image.
# Students cannot edit /usr/local/lib/ — runs as unprivileged ubuntu user.
/usr/bin/git -C "$HOME/lab" config core.hooksPath \
    /usr/local/lib/chipcraft-hooks

echo "[setup] Lab setup complete — open *.v.enc files under ~/lab/ with gvim to edit."
