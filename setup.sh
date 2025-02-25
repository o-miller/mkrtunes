#!/bin/bash

# Update and install necessary dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Create Mopidy Docker directory
echo "Setting up Mopidy client..."
mkdir -p ~/mopidy-client
cd ~/mopidy-client

# Create Mopidy configuration file
cat <<EOF > mopidy.conf
[core]
cache_dir = /var/lib/mopidy/cache

[local]
media_dir = /var/lib/mopidy/media

[mpd]
enabled = true
hostname = 0.0.0.0

[http]
enabled = true
hostname = 0.0.0.0
port = 6680
static_dir = /usr/share/mopidy/static

[spotify]
enabled = true
username = YOUR_SPOTIFY_USERNAME
password = YOUR_SPOTIFY_PASSWORD

[stream]
enabled = true

EOF

# Create Docker Compose file
cat <<EOF > docker-compose.yml
version: '3'
services:
  mopidy:
    image: mopidy/mopidy:latest
    container_name: mopidy_client
    restart: always
    network_mode: host
    volumes:
      - ./mopidy.conf:/etc/mopidy/mopidy.conf:ro
      - /var/lib/mopidy:/var/lib/mopidy
    devices:
      - /dev/snd:/dev/snd
EOF

# Start the Mopidy client container
docker-compose up -d

echo "Mopidy client setup complete!"
