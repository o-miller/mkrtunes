# UMASS MAKERSPACE MUSIC CLIENT DOCKERFILE
# Version 0.1 | February 2025
# Written by owen.

#ULTRA-DEBUGGING MODE, uncomment to enable
#SHELL ["/bin/sh", "-exc"]
FROM arm64v8/debian:12.9-slim


# Set environment variables
#ENV DEBIAN_FRONTEND=noninteractive
#Disabled for now, going to have specific commands marked as non-interactive 


# init before init
RUN set -ex \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
		wget \
		curl \
		gnupg \
		python3 \
		python3-cryptography \
		python3-distutils \
		#python3-venv \
		#python3-pip \
		gstreamer1.0-alsa \
		#gstreamer1.0-plugins-bad \
		pipx \
		dumb-init \
		vim \
		jq \
		alsa-utils \
		avahi-daemon \
	&& curl -L https://packaging.python.org/en/latest/tutorials/installing-packages/ | python3 - \
	&& pip install pipenv \
	&& apt-get clean \
	&& rm  -rm /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache


RUN set -ex \
	&& sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
	&& echo 'LANG=en_US.UTF-8' > /etc/default/locale \
	&& locale-gen 
#	&& dpkg-reconfigure -f noninteractive locales


# Add keyring for mopidy repository 
RUN set -ex \
	mkdir -p /etc/apt/keyrings \
    && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    	https://apt.mopidy.com/mopidy.gpg \
    && wget -q -O /etc/apt/sources.list.d/mopidy.list \
    	https://apt.mopidy.com/bookworm.list \
	&& apt-get update

RUN set -ex \
	&& apt-get install -y mopidy

RUN ssh-keygen -A \
    && update-rc.d ssh enable \
    && invoke-rc.d ssh start

#pipx vs python3 -m pip -venv
#TODO: Locale


# Copy entrypoint script and configuration template
COPY entrypoint.sh /entrypoint.sh
COPY mopidy.conf.template /etc/mopidy/mopidy.conf.template

# Make script executable
RUN chmod +x /entrypoint.sh

# Expose necessary ports (MPD default)
EXPOSE 6600 6680 5550/udp

# Start the script
ENTRYPOINT ["/entrypoint.sh"]

