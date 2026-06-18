#!/bin/bash
export USER="${USER:-ubuntu}"
export HOME="${HOME:-/home/ubuntu}"

mkdir -p "$HOME/.vnc" /tmp/runtime-ubuntu
chmod 700 /tmp/runtime-ubuntu
touch "$HOME/.Xresources"

if [[ ! -f "$HOME/.vnc/passwd" ]]; then
    printf 'novnc' | vncpasswd -f > "$HOME/.vnc/passwd"
    chmod 600 "$HOME/.vnc/passwd"
fi

cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/bash
export XDG_RUNTIME_DIR=/tmp/runtime-ubuntu
xrdb $HOME/.Xresources 2>/dev/null || true
startxfce4 &
sleep 2
xfce4-terminal &
EOF
chmod +x "$HOME/.vnc/xstartup"

vncserver :1 -geometry 1280x720 -depth 24 -rfbport 5901 2>/dev/null || true

# find websockify regardless of PATH
WS=""
for candidate in /usr/bin/websockify /usr/local/bin/websockify $(which websockify 2>/dev/null); do
    if [[ -x "$candidate" ]]; then WS="$candidate"; break; fi
done

if [[ -z "$WS" ]]; then
    WS="python3 -m websockify"
fi

nohup $WS --web=/usr/share/novnc/ 6080 localhost:5901 >> /tmp/novnc.log 2>&1 &

sleep 1
if ps aux | grep -q "[w]ebsockify\|[w]ebsock"; then
    echo "Lab desktop ready — open port 6080 in the Ports tab"
else
    echo "ERROR: websockify failed to start. Check /tmp/novnc.log" >&2
    cat /tmp/novnc.log >&2
fi
