# UMASS MAKERSPACE MUSIC CLIENT DOCKERFILE
# Version 0.1 | February 2025
# Written by owen.

# Use Raspberry Pi OS Lite as base
FROM arm64v8/debian:12.9-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Initial Package Install
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y \
	alsa-utils   \
	wget         \
	pulseaudio   \
	avahi-daemon \
	jq \
	vim \
	&& apt-get clean

RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
	&& echo 'LANG=en_US.UTF-8' > /etc/default/locale \
	&& locale-gen \
#	&& dpkg-reconfigure -f noninteractive locales

RUN ssh-keygen -A \
    && update-rc.d ssh enable \
    && invoke-rc.d ssh start


#pipx vs python3 -m pip -venv
#TODO: Locale

# Add keyring for mopidy repository 
RUN mkdir -p /etc/apt/keyrings \
    && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    	https://apt.mopidy.com/mopidy.gpg \
    && wget -q -O /etc/apt/sources.list.d/mopidy.list \
    	https://apt.mopidy.com/bookworm.list \

# Install Base Packages
RUN apt-get update && apt-get install -y \
	mopidy \
#    mopidy-mpd \
#    mopidy-iris \
#    alsa-utils \
#    pulseaudio \
#    avahi-daemon \
#    ncmpcpp \
#    jq \
	&& apt-get clean

# Install required packages
# RUN apt-get update && apt-get install -y \
#     #wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy.gpg \
#     #&& wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/bookworm.list \
#     #&& apt-get install -y \
#     mopidy \
#     #mopidy-mpd \
#     #mopidy-iris | only available thru pip \
#     alsa-utils \
#     pulseaudio \
#     avahi-daemon \
#     ncmpcpp \
#     jq \
#     vim \
#     python3-pip \
#     pipx \
#     && apt-get clean 
#     #&& python3 -m pip install Mopidy-Iris

# Copy entrypoint script and configuration template
COPY entrypoint.sh /entrypoint.sh
COPY mopidy.conf.template /etc/mopidy/mopidy.conf.template

# Make script executable
RUN chmod +x /entrypoint.sh

# Expose necessary ports (MPD default)
EXPOSE 6600 6680

# Start the script
ENTRYPOINT ["/entrypoint.sh"]

