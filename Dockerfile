FROM golang:1.14.5-alpine AS binarybuilder
RUN apk --no-cache --no-progress add --virtual build-deps build-base git linux-pam-dev
RUN git clone https://github.com/gogs/gogs gogs
RUN cd gogs && go build -tags "sqlite pam cert" -o gogs

FROM gogs/gogs:latest
COPY --from=binarybuilder /go/gogs/gogs /app/gogs/