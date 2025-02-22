#!/bin/bash

# Get the current hostname
HOSTNAME=$(hostname)

# Set a default if hostname is not set
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="mopidy-client"
fi

echo "Detected hostname: $HOSTNAME"

# Replace placeholder in config file
sed "s/{{HOSTNAME}}/$HOSTNAME/g" /etc/mopidy/mopidy.conf.template > /etc/mopidy/mopidy.conf

# Start Mopidy
exec mopidy --config /etc/mopidy/mopidy.conf
