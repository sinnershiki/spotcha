#!/bin/bash

xvfbpid=""
ckpid=""
installdir="$(dirname -- "$0";)"
exepath="$installdir/CoreKeeperServer"
requirements=( "libxi6" "xvfb" )

sudo="sudo" && [[ $(id -u) == 0 ]] && sudo=""

function kill_corekeeperserver {
 if [[ ! -z "$ckpid" ]]; then
        kill $ckpid
        wait $ckpid
 fi
 if [[ ! -z "$xvfbpid" ]]; then
        kill $xvfbpid
        wait $xvfbpid
 fi
}

trap kill_corekeeperserver EXIT

set -m

rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
xvfbpid=$!

rm -f GameID.txt

chmod +x "$exepath"

DISPLAY=:99 LD_LIBRARY_PATH="$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/" "$exepath" "${params[@]}"&

ckpid=$!

echo "Started server process with pid $ckpid"

while [ ! -f GameID.txt ]; do
 sleep 0.1
done

echo "Game ID: $(cat GameID.txt)"
bash "/usr/local/scripts/post-message-to-discord.sh" "Server started with Game ID: $(cat GameID.txt)"

wait $ckpid
ckpid=""
