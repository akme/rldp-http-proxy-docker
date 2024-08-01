FROM ubuntu:24.04 AS builder
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential cmake clang openssl libssl-dev zlib1g-dev gperf wget git ninja-build libsecp256k1-dev libsodium-dev libmicrohttpd-dev pkg-config autoconf automake libtool liblz4-dev && \
        rm -rf /var/lib/apt/lists/*
ENV CC clang
ENV CXX clang++
ENV CCACHE_DISABLE 1


WORKDIR /
RUN git clone --recursive https://github.com/ton-blockchain/ton
WORKDIR /ton

RUN mkdir build && \
        cd build && \
        cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=1 -DTON_ARCH= .. && \
        ninja rldp-http-proxy

FROM ubuntu:24.04
RUN apt-get update && \
        apt-get install -y openssl wget libatomic1 libsecp256k1-dev libsodium-dev libmicrohttpd-dev && \
        rm -rf /var/lib/apt/lists/*

COPY --from=builder /ton/build/rldp-http-proxy/rldp-http-proxy /usr/local/bin/

ENTRYPOINT ["rldp-http-proxy"]
