 # Leading space so nothing gets saved to history
 OPEN_FILE="tab drop"
 ESC="<C-\\><C-N>"
 CR="<CR>"
 GOTOLINE="call cursor"
 
 cwd="$1"
 IFS=':' read -r fp LINE COL <<< "$3"

 godot=$2
 SOCKET="/tmp/neovide-unity.socket"

 # Unity passes the flag -g
 # Godot passes --goto
 # Therefore we can manage
 # the two cases with one script
 [[ "$godot" == --* ]] && SOCKET="/tmp/neovide-godot.socket"
 
 if ! pgrep -x "neovide" > /dev/null; then
     # No Neovide process found, so clean up the stale socket if it exists
     [ -S "$SOCKET" ] && rm "$SOCKET"
 fi
 
 if [ ! -S "$SOCKET" ]; then
   neovide -- --listen "$SOCKET" --cmd "cd $cwd" &
 
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

 # nvim --server "$SOCKET" --remote-send "${ESC}i$1$2$3"
 nvim --server "$SOCKET" --remote-send "$ESC:$OPEN_FILE $fp|$GOTOLINE($LINE,$COL)$CR"
