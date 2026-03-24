FROM bash:5.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "/workspace/gno/entrypoint.sh"]
