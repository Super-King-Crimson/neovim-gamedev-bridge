#!/bin/bash -i
# Configs:
# /path/to/file/neovide-godot-bridge.sh
# {file} {line} {col}

SOCKET="/tmp/godot.socket"

OPEN_FILE="tab drop"
ESC="<C-\\><C-N>"
CR="<CR>"
GOTOLINE="call cursor"

file="${1:-}"
line="${2:-1}"
col="${3:-0}"

if ! pgrep -x "neovide" > /dev/null; then
    # No Neovide process found, so clean up the stale socket if it exists
    [ -S "$SOCKET" ] && rm "$SOCKET"
fi

if [ ! -S "$SOCKET" ]; then
  neovide $FILE -- --listen "$SOCKET" &

  MAX_RETRIES=100
  COUNT=0
  while [ ! -S "$SOCKET" ]; do 
    sleep 0.05
    ((COUNT++))
    if [ $COUNT -ge $MAX_RETRIES ]; then
      echo "Error: Neovide socket timed out." >&2
      exit 1
    fi
  done
fi

nvim --server "$SOCKET" --remote-send "$ESC:$OPEN_FILE $file|$GOTOLINE($line,$col)$CR"
