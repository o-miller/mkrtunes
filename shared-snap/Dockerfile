FROM arm64v8/alpine:3.21.3
RUN apk add --no-cache -U --upgrade alsa-utils \
	snapcast \
	avahi-dev \
	npm \
	#avahi-tools \
	#=~${SNAPCAST_RELEASE} \
	&& apk add snapweb --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
	&& rm -rf /tmp/*

# FROM node:lts-alpine AS REACT-BUILDER
# RUN apk -U add git \
# 	&& git clone "https://github.com/jorenn92/Snapweb.git" \
# 	&& cd Snapweb \
# 	&& npm ci --force \
# 	&& npm run build
# RUN apk update


COPY root/ /
COPY startup.sh startup.sh
#COPY --from=REACT-BUILDER /Snapweb/build /usr/share/snapserver/snapweb
#RUN echo 'VITE_APP_SNAPSERVER_HOST = localhost:1780' > .env.local
#RUN npm install
#RUN npm run build
RUN chmod +x ./startup.sh
EXPOSE 1704
EXPOSE 1780
#ENV START_SNAPCLIENT=false

ENTRYPOINT [ "./startup.sh"  ]
