#!/bin/bash
installdir="$(dirname -- "$0";)"
cd "$installdir"
java -Xms4G -Xmx4G -jar server.jar --nogui
# /usr/local/scripts/post-message-to-discord.sh "MINECRAFT_DISCORD_WEBHOOK_URL" "Server started"
