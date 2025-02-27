FROM arm64v8/alpine:3.21.3
RUN apk add --no-cache -U --upgrade alsa-utils \
	snapcast \
	#=~${SNAPCAST_RELEASE} \
	&& apk add snapweb --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
	&& rm -rf /tmp/*
