# UMASS MAKERSPACE MUSIC CLIENT DOCKERFILE
# Version 0.1 | February 2025
# Written by owen.

#ULTRA-DEBUGGING MODE, uncomment to enable
#SHELL ["/bin/sh", "-exc"]
ARG BUILD_FROM="12.9-slim"
ARG ARCH="arm64v8"

FROM ${ARCH}/debian:${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive
ENV TUNE_SINK="/tmp/tunesink_$(hostname)"

# Set environment variables
#Disabled for now, going to have specific commands marked as non-interactive 

#sticky bit fifo attacker disabling
RUN sysctl fs.protected_regular=0

# init before init
RUN set -ex \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
		wget \
		curl \
		gnupg \
		python3 \
		python3-venv \
		python3-distutils \
		#python3-cryptography \
		#python3-distutils \
		#python3-pip \
		gstreamer1.0-alsa \
		#gstreamer1.0-plugins-bad \
		#pipx \
		dumb-init \
		vim \
		jq \
		#openssl-client \
		alsa-utils \
		libasound2-dev \
		build-essential \
		avahi-daemon \
		snapserver \
	&& apt-get clean



# RUN set -ex \
# 	&& sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
# 	&& echo 'LANG=en_US.UTF-8' > /etc/default/locale \
# 	&& locale-gen 
#	&& dpkg-reconfigure -f noninteractive locales


# Add keyring for mopidy repository 
RUN set -ex \
	mkdir -p /etc/apt/keyrings \
    && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    	https://apt.mopidy.com/mopidy.gpg \
    && wget -q -O /etc/apt/sources.list.d/mopidy.list \
    	https://apt.mopidy.com/bookworm.list \
	&& apt-get update \
	&& apt-get install -y mopidy #\
		#mopidy-mpd
# WE are doing something bad here, and not adhereing to the guidelines put forth in PEP668 and enforced as of Debian 12. 
# If at any point shit is super broken, you are going to have to switch this method `--break-system-install` with a `pipenv` and virtual environments, but then also make sure that you append the python env variable path so these are available system-wide. 
#mopidy needs to be run as system user mopidy:audio (:group), you might need to chmod 777  
RUN set -ex \
	&& RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 - --break-system-packages \
	#COMMENTED OUT BUT PRESERVING FOR FUTURE GENERATOINS #beautifulCodebase <3
	# && python3 -m venv /opt/mopidy-venv \
	# && /opt/mopidy-venv/bin/pip install --upgrade pip pipenv \
	# && /opt/mopidy-venv/bin/pipenv install mopidy-iris mopidy-mpd mopidy-alsamixer \
	# && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache
RUN set -ex \
	&& pip install --no-cache-dir \
	mopidy-spotify \
	mopidy-iris \
	mopidy-mpd \
	mopidy-alsamixer
#THIS GOES IN TO DEPLOY SCRIPT TO INSTALL DOCKER AND ENABLE SSH, NOT IN CONTIANER
#RUN ssh-keygen -A \
#    && update-rc.d ssh enable \
#    && invoke-rc.d ssh start

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

