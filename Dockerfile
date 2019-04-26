FROM golang:1.10.1-alpine3.7
RUN apk update \
    && apk add ca-certificates curl git \
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

WORKDIR /go/src/github.com/justinbarrick/fluxcloud

COPY cmd/ ./cmd/
COPY pkg/ ./pkg/
COPY Gopkg.lock Gopkg.toml ./

RUN dep ensure
RUN go build -ldflags "-s -w" cmd/*

FROM alpine
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=0 /go/src/github.com/justinbarrick/fluxcloud/fluxcloud /bin/fluxcloud

EXPOSE 3031
CMD ["/bin/fluxcloud"]
