# UMASS MAKERSPACE MUSIC CLIENT DOCKERFILE
# Version 0.1 | February 2025

ARG BUILD_FROM="12.9-slim"
ARG ARCH="arm64v8"
ARG TUNEHOST=$(hostname)

FROM ${ARCH}/debian:${BUILD_FROM}

ENV DEBIAN_FRONTEND=noninteractive
ENV TUNE_SINK="/tmp/tunesink_${TUNEHOST}"
ENV TZ="America/New_York"

#sticky bit fifo attacker disabling

SHELL ["/bin/sh", "-exc"]

#RUN sysctl fs.protected_regular=0
#RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen 
#RUN echo 'LANG=en_US.UTF-8' > /etc/default/locale
#RUN locale-gen

RUN apt-get update \
	&& apt-get install -y \
		curl \
		wget \
		gnupg \
		gstreamer1.0-alsa \
		python3-distutils \
		dumb-init \
		#alsa-utils \
		build-essential \
		libasound2-dev \
		#jq \
		#avahi-daemon \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

RUN set -ex \
	mkdir -p /etc/apt/keyrings \
    && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    	https://apt.mopidy.com/mopidy.gpg \
    && wget -q -O /etc/apt/sources.list.d/mopidy.list \
    	https://apt.mopidy.com/bookworm.list \
	&& apt-get install -y mopidy 

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 - --break-system-packages \
	&& rm -rf ~/.cache/pip

#RUN set -ex \
	#&& pip install --no-cache-dir --break-system-packages \
	#mopidy-spotify \
	#mopidy-iris \
	#mopidy-mpd \
	#mopidy-alsamixer

#mopidy needs to be run as system user mopidy:audio (:group), you might need to chmod 777  

# Copy entrypoint script and configuration template
COPY entrypoint.sh /entrypoint.sh
COPY mopidy.conf.template /etc/mopidy/mopidy.conf.template

# Make script executable
RUN chmod +x /entrypoint.sh

# Expose necessary ports (MPD default)
EXPOSE 6600 6680 5550/udp

# Start the script
ENTRYPOINT ["/entrypoint.sh"]
