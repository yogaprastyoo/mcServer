#!/bin/sh
set -e

# Take ownership of the /fabric-server volume.
# This ensures the non-root user can write to the volume.
chown -R minecraft:minecraft /fabric-server

# Change to the server data directory
cd /fabric-server

# Accept EULA on first run if the file doesn't exist in the volume
if [ ! -f eula.txt ]; then
    echo "eula=true" > eula.txt
    chown minecraft:minecraft eula.txt
fi

if [ ! -d node_modules/ ]; then
    git clone https://github.com/vincss/mcsleepingserverstarter.git starter/
    mv starter/* .
    npm ci
    npm run build
fi

if [ -f /app/sleepingSettings.yml ]; then
    cp -f /app/sleepingSettings.yml /fabric-server/sleepingSettings.yml
fi

# Execute the command passed to the script (the CMD from the Dockerfile)
# as the 'minecraft' user.
exec gosu minecraft "$@"
