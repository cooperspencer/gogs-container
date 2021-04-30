FROM golang:alpine AS binarybuilder
RUN apk --no-cache --no-progress add --virtual build-deps build-base git linux-pam-dev
RUN git clone https://github.com/gogs/gogs gogs
RUN cd gogs && go build -tags "sqlite pam cert" -o gogs

ADD https://github.com/tianon/gosu/releases/download/1.12/gosu-arm64 /usr/sbin/gosu
RUN chmod +x /usr/sbin/gosu \
  && echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories \
  && apk --no-cache --no-progress add \
  bash \
  ca-certificates \
  curl \
  git \
  linux-pam \
  openssh \
  s6 \
  shadow \
  socat \
  tzdata \
  rsync

ENV GOGS_CUSTOM /data/gogs

# Configure LibC Name Service
COPY --from=binarybuilder /go/gogs/docker/nsswitch.conf /etc/nsswitch.conf

WORKDIR /app/gogs
COPY --from=binarybuilder /go/gogs/docker ./docker
COPY --from=binarybuilder /go/gogs/gogs .

RUN ./docker/finalize.sh

# Configure Docker Container
VOLUME ["/data", "/backup"]
EXPOSE 22 3000
ENTRYPOINT ["/app/gogs/docker/start.sh"]
CMD ["/bin/s6-svscan", "/app/gogs/docker/s6/"]
