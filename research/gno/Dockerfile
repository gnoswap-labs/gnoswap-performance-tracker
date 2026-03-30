FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git make

RUN git clone --depth 1 https://github.com/gnolang/gno.git /src/gno
COPY .docker/gnoswap-src /src/gnoswap

WORKDIR /src/gno

RUN cd contribs/gnodev && go build -o /usr/local/bin/gnodev .
RUN cd gno.land/cmd/gnokey && go build -o /usr/local/bin/gnokey .

FROM alpine:3.21

RUN apk add --no-cache bash coreutils curl git make && ln -sf /usr/bin/date /usr/bin/gdate

COPY --from=builder /usr/local/bin/gnodev /usr/local/bin/gnodev
COPY --from=builder /usr/local/bin/gnokey /usr/local/bin/gnokey
COPY --from=builder /src/gno /gnoroot
COPY --from=builder /src/gnoswap /opt/gnoswap

ENV GNOROOT=/gnoroot

COPY gno/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 26657 8888

ENTRYPOINT ["/entrypoint.sh"]
