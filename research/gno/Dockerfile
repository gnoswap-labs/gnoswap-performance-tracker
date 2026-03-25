FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git make

ARG GNOSWAP_REPO=https://github.com/gnoswap-labs/gnoswap.git
ARG GNOSWAP_REF=3f2642b8898ae02d14a14c4050d80919f18f3f21

RUN git clone --depth 1 https://github.com/gnolang/gno.git /src/gno
RUN git init /src/gnoswap \
    && git -C /src/gnoswap remote add origin ${GNOSWAP_REPO} \
    && git -C /src/gnoswap fetch --depth 1 origin ${GNOSWAP_REF} \
    && git -C /src/gnoswap checkout FETCH_HEAD

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
